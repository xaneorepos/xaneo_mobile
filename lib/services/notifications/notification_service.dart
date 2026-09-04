import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
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

class NotificationService {
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

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  bool _initialized = false;

  /// Флаг готовности интерфейса приложения (MainScreen)
  static bool isAppReady = false;

  /// Хранилище в памяти для быстрого перенаправления звонка при холодном старте
  static Map<String, dynamic>? pendingCallPayload;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Инициализация Firebase
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('NotificationService: Firebase init error: $e');
    }

    // 2. Настройка фонового обработчика
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Инициализация локальных уведомлений
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

    // 4. Запрос разрешений
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // 5. Передний план (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // 6. Клик при свернутом приложении (Resume)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data);
    });

    // 7. Клик при закрытом приложении (Launch)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationClick(message.data);
      }
    });

    // 8. Проверяем уведомление, которое запустило приложение
    await _checkLaunchNotification();

    // 9. События CallKit
    _listenToCallKitEvents();

    _initialized = true;
    debugPrint('NotificationService: Initialized successfully');
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
          'NotificationService: checkPendingCallPayload called, pendingCallPayload=$pendingCallPayload, isAppReady=$isAppReady');
      if (pendingCallPayload != null) {
        final data = pendingCallPayload!;
        pendingCallPayload = null; // Очищаем сразу
        final callId = data['call_id']?.toString() ?? '';
        debugPrint('NotificationService: found pending callId=$callId');
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

  // ─── FCM Token ────────────────────────────────────────────────────

  Future<String?> getDeviceToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('NotificationService: Error getting token: $e');
      return null;
    }
  }

  // ─── Foreground сообщения ─────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) async {
    // В режиме переднего плана (Foreground) системные всплывающие уведомления НЕ показываются.
    // Все обновления списка чатов и сообщений осуществляются исключительно в реальном времени через WebSocket.
    debugPrint(
        'NotificationService: Message push received in foreground, ignoring banner in favor of WebSocket');
  }

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
          debugPrint('Notification Action: accept_call for callId=$callId');
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
          debugPrint('Notification Action: decline_call for callId=$callId');
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
        debugPrint('NotificationService: Tap payload decode error: $e');
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
      debugPrint('NotificationService: CallKit Event: $event');

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
      Map<String, dynamic> data) async {
    final chatId = data['chat_id']?.toString() ?? '';
    final senderName = data['sender_name']?.toString() ?? 'Сообщение';
    final encryptedText = data['encrypted_text']?.toString() ?? '';

    String displayBody = 'Новое зашифрованное сообщение';
    if (encryptedText.isNotEmpty) {
      try {
        final tokenStorage = TokenStorage();
        final apiClient = ApiClient(tokenStorage: tokenStorage);
        final crypto = CryptoService(apiClient: apiClient);
        await crypto.init();
        final decrypted = await crypto.decryptMessage(encryptedText, chatId);
        if (decrypted != null && decrypted.isNotEmpty) {
          displayBody = decrypted;
        }
      } catch (e) {
        debugPrint('FCM Background: Error decrypting message: $e');
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

    await localNotifications.show(
      id: DateTime.now().millisecond,
      title: senderName,
      body: displayBody,
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(data),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  await Firebase.initializeApp();
  final data = message.data;
  final type = data['type']?.toString();

  if (type == 'call') {
    await NotificationService._showIncomingCallNotification(data);
  } else if (type == 'message') {
    await NotificationService._handleBackgroundMessage(data);
  }
}
