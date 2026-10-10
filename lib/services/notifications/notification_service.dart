import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/message_color_presets.dart';
import '../../services/chat/chat_local_repository.dart';
import '../../models/chat/chat_model.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/webrtc/active_call_screen.dart';
import '../../services/webrtc/call_manager.dart';
import '../../services/webrtc/webrtc_signaling_service.dart';
import '../../widgets/common/premium_page_route.dart';
import '../../services/auth/token_storage.dart';
import '../../services/api/api_client.dart';
import '../../services/crypto/crypto_service.dart';
import '../../config/app_config.dart';

class NotificationService with WidgetsBindingObserver {
  static const _notificationStylePreference = 'appearance_notification_style';

  static Future<bool> _usesRavenNotificationStyle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final style = NotificationStyle.values.firstWhere(
        (value) => value.name == prefs.getString(_notificationStylePreference),
        orElse: () => NotificationStyle.standard,
      );
      return style == NotificationStyle.raven;
    } catch (_) {
      return false;
    }
  }

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const _backgroundConnectionPreference = 'background_connection_enabled';
  WebSocket? _socket;
  static const _connectionChannel = MethodChannel('net.xaneo/notification_connection');
  bool _backgroundServiceRunning = false;
  static int _nextMessageId = DateTime.now().millisecondsSinceEpoch % 2000000000;
  final bool _listenEnabled = true;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  bool _initialized = false;

  /// Флаг готовности интерфейса приложения (MainScreen)
  static bool isAppReady = false;

  /// Хранилище в памяти для быстрого перенаправления звонка при холодном старте
  static Map<String, dynamic>? pendingCallPayload;
  static final Map<String, String> _callKitIds = {};

  Future<void> initialize() async {
    if (_initialized) return;

    // Настройка локальных уведомлений.
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      settings:
          const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Создаём каналы уведомлений
    await _ensureNotificationChannels();
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    WidgetsBinding.instance.addObserver(this);
    Connectivity().onConnectivityChanged.listen((_) => _socket?.close());
    await _syncBackgroundService();
    unawaited(_listenToNotifications());

    // 8. Проверяем уведомление, которое запустило приложение
    await _checkLaunchNotification();

    // 9. События CallKit
    _listenToCallKitEvents();

    _initialized = true;
    debugPrint('NotificationService: Initialized successfully');
  }

  Future<void> _listenToNotifications() async {
    var retries = 0;
    while (_listenEnabled) {
      try {
        final enabled = (await SharedPreferences.getInstance())
            .getBool(_backgroundConnectionPreference) ?? true;
        final token = await TokenStorage().getAccessToken();
        final accountKey = await TokenStorage().getActiveAccountKey();
        if (!enabled || token == null || token.isEmpty) {
          await _syncBackgroundService();
          _socket?.close();
          await Future.delayed(const Duration(seconds: 5));
          continue;
        }
        final origin = Uri.parse(AppConfig.serverOrigin);
        final uri = origin.replace(scheme: origin.scheme == 'https' ? 'wss' : 'ws',
            path: '/ws/notifications/');
        final socket = await WebSocket.connect(uri.toString(),
            headers: {'Authorization': 'Bearer $token'})
            .timeout(const Duration(seconds: 10));
        _socket = socket;
        retries = 0;
        socket.pingInterval = const Duration(seconds: 30);
        final accountWatch = Timer.periodic(const Duration(seconds: 15), (_) async {
          if (await TokenStorage().getAccessToken() != token) socket.close();
        });
        try {
          await for (final frame in socket) {
            if (frame is String) {
              // Decryption or notification errors must not block the socket or calls.
              unawaited(handleNotificationFrame(frame, token, accountKey: accountKey));
            }
          }
        } finally {
          accountWatch.cancel();
        }
      } catch (error) {
        debugPrint('Notification socket: ${error.runtimeType}');
      } finally {
        _socket?.close();
        _socket = null;
      }
      retries = (retries + 1).clamp(0, 6);
      await Future.delayed(Duration(seconds: min(60, 1 << retries)));
    }
  }

  @visibleForTesting
  Future<void> handleNotificationFrame(String frame, String token, {String? accountKey}) async {
    try {
      if (!await _matchesSession(token, accountKey)) return;
      await _handlePushBytes(Uint8List.fromList(utf8.encode(frame)), token, accountKey);
    } catch (error) {
      debugPrint('Notification event failed: ${error.runtimeType}');
    }
  }

  static Future<bool> _matchesSession(String token, String? accountKey) async {
    final storage = TokenStorage();
    final currentToken = await storage.getAccessToken();
    if (currentToken == null || currentToken.isEmpty) return false;
    // Refreshing the JWT must not discard a notification for the same account.
    return accountKey == null
        ? currentToken == token
        : await storage.getActiveAccountKey() == accountKey;
  }

  Future<void> _syncBackgroundService() async {
    if (!Platform.isAndroid) return;
    final enabled = (await SharedPreferences.getInstance())
        .getBool(_backgroundConnectionPreference) ?? true;
    final token = await TokenStorage().getAccessToken();
    final shouldRun = enabled && token != null && token.isNotEmpty;
    if (shouldRun == _backgroundServiceRunning) return;
    try {
      await _connectionChannel.invokeMethod<void>(shouldRun ? 'start' : 'stop');
      _backgroundServiceRunning = shouldRun;
    } on PlatformException catch (error) {
      // Android can reject a start from the background; retry on resume.
      debugPrint('Notification background service: ${error.code}');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncBackgroundService());
    }
  }

  // ─── Каналы уведомлений ───────────────────────────────────────────

  /// Создание каналов уведомлений (вызывается и из foreground, и из background)
  static Future<void> _ensureNotificationChannels() async {
    final localNotifications = FlutterLocalNotificationsPlugin();
    final plugin = localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (plugin != null) {
      await plugin.createNotificationChannel(const AndroidNotificationChannel(
        'xaneo_messages_v2',
        'Xaneo Messages',
        description: 'Channel for message notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ));
      await plugin.createNotificationChannel(const AndroidNotificationChannel(
        'xaneo_calls_v4',
        'Входящие звонки Xaneo',
        description: 'Рингтон и вибрация при входящих звонках',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('incoming_call'),
        enableVibration: true,
      ));
    }
  }

  // ─── Обработка холодного старта (launch notification) ─────────────

  /// Проверяет, было ли приложение запущено по нажатию на уведомление
  Future<void> _checkLaunchNotification() async {
    try {
      final details =
          await _localNotifications.getNotificationAppLaunchDetails();
      debugPrint(
          'NotificationService: _checkLaunchNotification details=$details didLaunch=${details?.didNotificationLaunchApp} response=${details?.notificationResponse}');
      if (details != null &&
          details.didNotificationLaunchApp &&
          details.notificationResponse != null) {
        debugPrint(
            'NotificationService: App was launched from notification, actionId=${details.notificationResponse!.actionId}');
        await _onNotificationTapped(details.notificationResponse!);
      }
    } catch (e) {
      debugPrint('NotificationService: Error checking launch notification: $e');
    }
  }

  /// Проверить и обработать отложенный звонок при холодном старте.
  /// Вызывается из main.dart после полной инициализации виджетов.
  static Future<void> checkPendingCallPayload() async {
    try {
      debugPrint(
          'NotificationService: checking pending call, isAppReady=$isAppReady');
      if (pendingCallPayload != null) {
        final data = pendingCallPayload!;
        pendingCallPayload = null; // Очищаем сразу
        final callId = data['call_id']?.toString() ?? '';
        debugPrint('NotificationService: pending call found');
        if (callId.isNotEmpty) {
          // Ждём пока navigator станет доступен
          int attempts = 0;
          while (navigatorKey.currentState == null && attempts < 50) {
            debugPrint(
                'NotificationService: waiting for navigatorState... attempt=$attempts');
            await Future.delayed(const Duration(milliseconds: 100));
            attempts++;
          }
          final context = navigatorKey.currentContext;
          debugPrint(
              'NotificationService: navigatorState is ready, context=$context, state=${navigatorKey.currentState}');
          if (context != null) {
            debugPrint(
                'NotificationService: Navigating to pending call $callId via push');
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ActiveCallScreen()),
            );
            debugPrint(
                'NotificationService: Pushed ActiveCallScreen, now calling CallManager.acceptCallById($callId)');
            context.read<CallManager>().acceptCallById(
                  callId,
                  callerName: data['caller_name']?.toString(),
                  callerId: data['caller_id']?.toString(),
                );
          } else {
            debugPrint(
                'NotificationService: Cannot navigate, context is null!');
          }
        }
      }
    } catch (e) {
      debugPrint('NotificationService: Error checking pending call: $e');
    }
  }

  Future<void> setBackgroundConnectionEnabled(bool enabled) async {
    await (await SharedPreferences.getInstance())
        .setBool(_backgroundConnectionPreference, enabled);
    if (!enabled) await _socket?.close();
    await _syncBackgroundService();
  }

  Future<void> reconnect() async {
    await _socket?.close();
    await _syncBackgroundService();
  }

  bool sendCallAnswer(String callId) {
    final socket = _socket;
    if (socket == null || socket.readyState != WebSocket.open) return false;
    socket.add(jsonEncode({
      'type': 'call_answer', 'call_id': callId, 'answer': 'livekit',
    }));
    return true;
  }

  // ─── Foreground сообщения ─────────────────────────────────────────

  // ─── Локальные уведомления ────────────────────────────────────────

  void _showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    final useRavenStyle = await _usesRavenNotificationStyle();
    final androidDetails = AndroidNotificationDetails(
      'xaneo_messages_v2',
      'Xaneo Messages',
      channelDescription: 'Channel for message notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'ticker',
      color: useRavenStyle ? const Color(0xFF111111) : null,
      colorized: useRavenStyle,
      actions: [
        const AndroidNotificationAction(
          'mark_read',
          'Отметить как прочитанное',
          showsUserInterface: false,
        ),
      ],
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // ─── Уведомление о входящем звонке ────────────────────────────────

  static Future<void> _showIncomingCallNotification(
      Map<String, dynamic> data) async {
    // Гарантируем создание канала (критично для фонового изолята)
    await _ensureNotificationChannels();

    final callerName = data['caller_name'] ?? 'Пользователь';
    final callId = data['call_id'] ?? '';

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final random = Random.secure();
      final bytes = List<int>.generate(16, (_) => random.nextInt(256));
      bytes[6] = (bytes[6] & 0x0f) | 0x40;
      bytes[8] = (bytes[8] & 0x3f) | 0x80;
      final hex = bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
      final uuid = '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
          '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
      _callKitIds[uuid] = callId.toString();
      await FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
        id: uuid,
        nameCaller: callerName.toString(),
        appName: 'Xaneo',
        handle: 'Xaneo',
        type: data['call_type'] == 'video' ? 1 : 0,
        duration: 30000,
        extra: data,
        ios: const IOSParams(handleType: 'generic', supportsVideo: true),
      ));
      return;
    }

    final List<int> vibratePattern = [
      0,
      1000,
      500,
      1000,
      500,
      1000,
      500,
      1000,
      500,
      1000,
      500,
      1000,
      500,
      1000,
      500,
      1000,
      500,
      1000
    ];

    final androidDetails = AndroidNotificationDetails(
      'xaneo_calls_v4',
      'Входящие звонки Xaneo',
      channelDescription: 'Рингтон и вибрация при входящих звонках',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('incoming_call'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList(vibratePattern),
      ongoing: true,
      autoCancel: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      timeoutAfter: 30000,
      actions: [
        const AndroidNotificationAction(
          'accept_call',
          'Принять',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'decline_call',
          'Отклонить',
          showsUserInterface: false,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'incoming-call.mp3',
      interruptionLevel: InterruptionLevel.critical,
    );

    final localNotifications = FlutterLocalNotificationsPlugin();
    await localNotifications.show(
      id: callId.hashCode,
      title: 'Входящий звонок',
      body: callerName,
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(data),
    );
  }

  // ─── Обработка нажатий на уведомления ─────────────────────────────

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    debugPrint(
        'NotificationService: _onNotificationTapped triggered, actionId=${response.actionId}, payload=${response.payload}');
    if (response.actionId == 'mark_read') {
      if (response.payload != null) {
        try {
          final data = jsonDecode(response.payload!) as Map<String, dynamic>;
          final chatId = data['chat_id']?.toString() ?? '';
          if (chatId.isNotEmpty) {
            final tokenStorage = TokenStorage();
            final apiClient = ApiClient(tokenStorage: tokenStorage);
            await apiClient.post(
              '/messages/mark-read/',
              data: {'chat_id': chatId},
            );
            debugPrint(
                'Notification Action: Marked chat $chatId as read successfully');
          }
        } catch (e) {
          debugPrint('Notification Action: Error marking read: $e');
        }
      }
      return;
    }

    if (response.actionId == 'accept_call') {
      if (response.payload != null) {
        try {
          final data = jsonDecode(response.payload!) as Map<String, dynamic>;
          final callId = data['call_id']?.toString() ?? '';
          debugPrint('Notification Action: accept_call');
          if (callId.isNotEmpty) {
            await _acceptCallWithNavigation(callId, data);
          }
        } catch (e) {
          debugPrint('Notification Action: Error accepting call: $e');
        }
      }
      return;
    }

    if (response.actionId == 'decline_call') {
      if (response.payload != null) {
        try {
          final data = jsonDecode(response.payload!) as Map<String, dynamic>;
          final callId = data['call_id']?.toString() ?? '';
          debugPrint('Notification Action: decline_call');
          if (callId.isNotEmpty) {
            final context = navigatorKey.currentContext;
            if (context != null) {
              context.read<CallManager>().rejectCallById(callId);
            } else {
              final tokenStorage = TokenStorage();
              final apiClient = ApiClient(tokenStorage: tokenStorage);
              final callManager = CallManager(
                  apiClient: apiClient,
                  signalingService:
                      WebRTCSignalingService(apiClient: apiClient));
              await callManager.rejectCallById(callId);
            }
          }
        } catch (e) {
          debugPrint('Notification Action: Error declining call: $e');
        }
      }
      return;
    }

    // Тап по самому уведомлению (без конкретной кнопки)
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        final type = data['type']?.toString();
        debugPrint(
            'Notification Service: Tap notification body, type=$type, payload=$data');
        if (type == 'call') {
          final callId = data['call_id']?.toString() ?? '';
          if (callId.isNotEmpty) {
            await _acceptCallWithNavigation(callId, data);
          }
        } else {
          _handleNotificationClick(data);
        }
      } catch (e) {
        debugPrint(
            'NotificationService: Tap payload decode error: ${e.runtimeType}');
      }
    }
  }

  // ─── Навигация при принятии звонка ────────────────────────────────

  /// Принять звонок с навигацией на экран звонка.
  /// Если навигатор доступен — переходит напрямую.
  /// Иначе сохраняет payload в переменную pendingCallPayload для обработки при старте.
  static Future<void> _acceptCallWithNavigation(
      String callId, Map<String, dynamic> data) async {
    final context = navigatorKey.currentContext;
    debugPrint(
        'NotificationService: _acceptCallWithNavigation called, context=$context, isAppReady=$isAppReady');
    if (context != null && isAppReady) {
      debugPrint(
          'NotificationService: Accepting call $callId (UI alive & ready), pushing ActiveCallScreen');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ActiveCallScreen()),
      );
      context.read<CallManager>().acceptCallById(
            callId,
            callerName: data['caller_name']?.toString(),
            callerId: data['caller_id']?.toString(),
          );
      return;
    }

    // UI недоступен или приложение еще запускается — сохраняем pending payload для обработки при старте
    debugPrint(
        'NotificationService: Saving pending call $callId in memory for cold start (isAppReady=$isAppReady)');
    pendingCallPayload = data;
  }

  // ─── Навигация при клике на сообщение ─────────────────────────────

  static void _handleNotificationClick(Map<String, dynamic> data) async {
    final chatId = data['chat_id']?.toString();
    if (chatId != null) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final localChatRepo = context.read<LocalChatRepository>();
        var chat = await localChatRepo.getChatByServerId(chatId);
        if (chat == null) {
          chat = ChatModel(
            id: chatId,
            name: data['sender_name'] ?? 'Чат',
            avatar: data['sender_avatar'],
            isPersonal: data['chat_type'] == 'personal',
          );
        }
        Navigator.of(context).push(
          PremiumPageRoute(
            page: ChatScreen(chat: chat),
            transitionType: PremiumTransitionType.chatReveal,
            settings: RouteSettings(name: 'chat_$chatId'),
          ),
        );
      }
    }
  }

  // ─── CallKit events ───────────────────────────────────────────────

  void _listenToCallKitEvents() {
    FlutterCallkitIncoming.onEvent.listen((event) async {
      if (event == null) return;
      debugPrint('NotificationService: CallKit event ${event.runtimeType}');

      String callId = '';
      if (event is CallEventActionCallAccept) {
        callId = event.callKitParams.id;
      } else if (event is CallEventActionCallDecline) {
        callId = event.callKitParams.id;
      } else if (event is CallEventActionCallEnded) {
        callId = event.callKitParams.id;
      } else if (event is CallEventActionCallTimeout) {
        callId = event.id;
      }

      if (callId.isEmpty) return;

      if (event is CallEventActionCallAccept ||
          event is CallEventActionCallDecline ||
          event is CallEventActionCallEnded) {
        final params = event is CallEventActionCallAccept
            ? event.callKitParams
            : event is CallEventActionCallDecline
                ? event.callKitParams
                : (event as CallEventActionCallEnded).callKitParams;
        callId = params.extra?['call_id']?.toString() ??
            _callKitIds[callId] ?? callId;
      } else {
        callId = _callKitIds[callId] ?? callId;
      }

      final context = navigatorKey.currentContext;
      debugPrint(
          'NotificationService: CallKit Event mapping: callId=$callId, context=$context');

      if (event is CallEventActionCallAccept) {
        if (context != null) {
          debugPrint(
              'NotificationService: CallKit accept event, pushing ActiveCallScreen');
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ActiveCallScreen()),
          );
          context.read<CallManager>().acceptCallById(callId);
        } else {
          debugPrint(
              'NotificationService: CallKit accept event, but context is null!');
        }
      } else if (event is CallEventActionCallDecline ||
          event is CallEventActionCallEnded ||
          event is CallEventActionCallTimeout) {
        if (context != null) {
          context.read<CallManager>().rejectCallById(callId);
        } else {
          final tokenStorage = TokenStorage();
          final apiClient = ApiClient(tokenStorage: tokenStorage);
          final callManager = CallManager(
              apiClient: apiClient,
              signalingService: WebRTCSignalingService(apiClient: apiClient));
          await callManager.rejectCallById(callId);
        }
      }
    });
  }

  // ─── E2EE дешифровка ──────────────────────────────────────────────

  Future<String> _decryptOrFallback(String encryptedText, String chatId) async {
    if (encryptedText.isEmpty) return 'Новое сообщение';
    try {
      final context = navigatorKey.currentContext;
      CryptoService? crypto;
      if (context != null) {
        crypto = Provider.of<CryptoService>(context, listen: false);
      }

      if (crypto == null) {
        final tokenStorage = TokenStorage();
        final apiClient = ApiClient(tokenStorage: tokenStorage);
        crypto = CryptoService(apiClient: apiClient);
        await crypto.init();
      }

      final decrypted = await crypto.decryptMessage(encryptedText, chatId);
      if (decrypted != null && decrypted.isNotEmpty) {
        return decrypted;
      }
    } catch (e) {
      debugPrint('NotificationService decryption error: $e');
    }
    return 'Новое зашифрованное сообщение';
  }

  // ─── Background message handler ───────────────────────────────────

  static Future<void> _handleBackgroundMessage(
      Map<String, dynamic> data, String token, String? accountKey) async {
    final chatId = data['chat_id']?.toString() ?? '';
    final senderName = data['sender_name']?.toString() ?? 'Сообщение';
    final encryptedText = data['encrypted_text']?.toString() ?? '';

    String displayBody = 'Новое зашифрованное сообщение';
    if (encryptedText.isNotEmpty) {
      try {
        displayBody = await NotificationService()._decryptOrFallback(encryptedText, chatId)
            .timeout(const Duration(seconds: 4),
                onTimeout: () => 'Новое зашифрованное сообщение');
      } catch (e) {
        debugPrint('Push: Error decrypting message: $e');
      }
    }

    // Гарантируем наличие канала
    await _ensureNotificationChannels();

    final localNotifications = FlutterLocalNotificationsPlugin();
    final useRavenStyle =
        await NotificationService._usesRavenNotificationStyle();
    final androidDetails = AndroidNotificationDetails(
      'xaneo_messages_v2',
      'Xaneo Messages',
      channelDescription: 'Channel for message notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      color: useRavenStyle ? const Color(0xFF111111) : null,
      colorized: useRavenStyle,
      actions: [
        const AndroidNotificationAction(
          'mark_read',
          'Отметить как прочитанное',
          showsUserInterface: false,
        ),
      ],
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Never show a decrypted result belonging to a session that was switched out.
    if (!await _matchesSession(token, accountKey)) return;
    _nextMessageId = (_nextMessageId + 1) % 2000000000;
    await localNotifications.show(
      id: _nextMessageId,
      title: senderName,
      body: displayBody,
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(data),
    );
  }
}

Future<void> _handlePushBytes(Uint8List bytes, String token, String? accountKey) async {
  final dynamic decoded;
  try {
    decoded = jsonDecode(utf8.decode(bytes));
  } catch (_) {
    return;
  }
  if (decoded is! Map<String, dynamic>) return;
  final Map<String, dynamic> data = decoded;
  final type = data['type']?.toString();

  if (type == 'call') {
    await NotificationService._showIncomingCallNotification(data);
  } else if (type == 'message') {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      await NotificationService._handleBackgroundMessage(data, token, accountKey);
    }
  }
}
