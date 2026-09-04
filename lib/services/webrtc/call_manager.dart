import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

import '../api/api_client.dart';
import '../../config/app_config.dart';
import '../auth/token_storage.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'webrtc_signaling_service.dart';
import '../runtime_translations.dart';

enum CallState {
  idle,
  outgoing,
  incoming,
  connected,
}

class CallManager extends ChangeNotifier {
  final ApiClient _apiClient;
  final WebRTCSignalingService _signalingService;
  final AudioPlayer _ringtonePlayer = AudioPlayer();

  CallState _state = CallState.idle;
  CallState get state => _state;

  String? _activeCallId;
  String? get activeCallId => _activeCallId;

  String? _targetUserId;
  String? get targetUserId => _targetUserId;

  String? _targetName;
  String? get targetName => _targetName;

  String? _targetAvatar;
  String? get targetAvatar => _targetAvatar;

  String? _targetGradient;
  String? get targetGradient => _targetGradient;

  String _callType = 'audio'; // 'audio' or 'video'
  String get callType => _callType;

  Room? _room;
  Room? get room => _room;

  VideoTrack? _localVideoTrack;
  VideoTrack? get localVideoTrack => _localVideoTrack;

  VideoTrack? _remoteVideoTrack;
  VideoTrack? get remoteVideoTrack => _remoteVideoTrack;

  bool _isMicrophoneMuted = false;
  bool get isMicrophoneMuted => _isMicrophoneMuted;

  bool _isCameraOff = false;
  bool get isCameraOff => _isCameraOff;

  bool _isNearEar = false;
  bool get isNearEar => _isNearEar;

  bool _isSpeakerOn = false;
  bool get isSpeakerOn => _isSpeakerOn;

  StreamSubscription<dynamic>? _proximitySubscription;

  bool _isGroupCall = false;
  bool get isGroupCall => _isGroupCall;

  String? _groupCallId;
  String? get groupCallId => _groupCallId;

  EventsListener<RoomEvent>? _roomListener;

  CallManager({
    required ApiClient apiClient,
    required WebRTCSignalingService signalingService,
  })  : _apiClient = apiClient,
        _signalingService = signalingService {
    // Подписываемся на события сигнального WebSocket
    _signalingService.onIncomingCall = _handleIncomingCall;
    _signalingService.onCallAnswered = _handleCallAnswered;
    _signalingService.onCallRejected = _handleCallRejected;
    _signalingService.onCallEnded = _handleCallEnded;
    _signalingService.onCallOfferSent = _handleCallOfferSent;
    _signalingService.onCallAnsweredElsewhere = _handleCallAnsweredElsewhere;
    _signalingService.onIncomingGroupCall = _handleIncomingGroupCall;
    _signalingService.onGroupCallOfferSent = _handleGroupCallOfferSent;
    _signalingService.onGroupCallEnded = _handleGroupCallEnded;
    _signalingService.onGroupParticipantJoined = _handleGroupParticipantJoined;
    _signalingService.onGroupParticipantLeft = _handleGroupParticipantLeft;
  }

  final Map<String, Map<String, dynamic>> _groupParticipants = {};
  Map<String, Map<String, dynamic>> get groupParticipants => _groupParticipants;

  /// Инициировать исходящий групповой звонок
  Future<void> startOutgoingGroupCall({
    required String groupId,
    required String groupName,
    String? groupAvatar,
    String? groupGradient,
    required String callType,
  }) async {
    if (_state != CallState.idle) return;

    _state = CallState.outgoing;
    _isGroupCall = true;
    _targetUserId = groupId;
    _targetName = groupName;
    _targetAvatar = groupAvatar;
    _targetGradient = groupGradient;
    _callType = callType;
    _isMicrophoneMuted = false;
    _isCameraOff = false;
    _isSpeakerOn = (callType == 'video');
    try {
      Helper.setSpeakerphoneOn(_isSpeakerOn);
    } catch (_) {}
    _groupParticipants.clear();
    _startRingtone(isIncoming: false);
    _startProximityListener();
    notifyListeners();

    _signalingService.startGroupCall(
      groupId: groupId,
      callType: callType,
    );
  }

  void _handleIncomingGroupCall(Map<String, dynamic> data) {
    if (_state != CallState.idle) return;

    _state = CallState.incoming;
    _isGroupCall = true;
    _groupCallId = data['group_call_id']?.toString();
    _activeCallId = _groupCallId;
    _targetUserId = data['group_id']?.toString();
    _targetName = data['group_name']?.toString() ??
        RuntimeTranslations.instance.resolveByText('Групповой звонок');
    _targetAvatar = data['group_avatar']?.toString();
    _targetGradient = data['group_gradient']?.toString();
    _callType = data['call_type']?.toString() ?? 'video';
    _isMicrophoneMuted = false;
    _isCameraOff = false;
    _groupParticipants.clear();

    final initId = data['initiator_id']?.toString();
    if (initId != null) {
      _groupParticipants[initId] = {
        'user_id': initId,
        'name': data['initiator_name']?.toString() ??
            RuntimeTranslations.instance.resolveByText('Организатор'),
        'avatar': data['initiator_avatar'],
        'gradient': data['initiator_gradient'],
        'status': 'connected',
      };
    }

    _startRingtone();
    notifyListeners();
  }

  void _handleGroupCallOfferSent(Map<String, dynamic> data) {
    final gCallId = data['group_call_id']?.toString();
    if (gCallId != null) {
      _stopRingtone();
      _groupCallId = gCallId;
      _activeCallId = gCallId;
      _state = CallState.connected;
      notifyListeners();
      _connectToLiveKit(gCallId);
    }
  }

  void _handleGroupCallEnded(Map<String, dynamic> data) {
    _groupParticipants.clear();
    _cleanup();
  }

  void _handleGroupParticipantJoined(Map<String, dynamic> data) {
    final uid = data['user_id']?.toString();
    if (uid != null) {
      final name = data['first_name']?.toString() ??
          data['username']?.toString() ??
          'Участник $uid';
      _groupParticipants[uid] = {
        'user_id': uid,
        'name': name.isNotEmpty ? name : 'Участник $uid',
        'avatar': data['avatar'],
        'gradient': data['gradient'],
        'status': 'connected',
      };
    }
    if (data['connected_participants'] is Map) {
      final cp = data['connected_participants'] as Map;
      cp.forEach((key, val) {
        final kStr = key.toString();
        if (val is Map) {
          _groupParticipants[kStr] = {
            'user_id': kStr,
            'name': val['first_name'] ?? val['username'] ?? 'Участник $kStr',
            'avatar': val['avatar'],
            'gradient': val['gradient'],
            'status': val['status'] ?? 'connected',
          };
        }
      });
    }
    notifyListeners();
  }

  void _handleGroupParticipantLeft(Map<String, dynamic> data) {
    final uid = data['user_id']?.toString();
    if (uid != null) {
      _groupParticipants.remove(uid);
    }
    notifyListeners();
  }

  /// Инициировать исходящий звонок
  Future<void> startOutgoingCall({
    required String targetUserId,
    required String targetName,
    required String callerName,
    String? targetAvatar,
    String? targetGradient,
    required String callType,
  }) async {
    if (_state != CallState.idle) return;

    _state = CallState.outgoing;
    _isGroupCall = false;
    _groupCallId = null;
    _groupParticipants.clear();
    _targetUserId = targetUserId;
    _targetName = targetName;
    _targetAvatar = targetAvatar;
    _targetGradient = targetGradient;
    _callType = callType;
    _isMicrophoneMuted = false;
    _isCameraOff = false;
    _isSpeakerOn = (callType == 'video');
    try {
      Helper.setSpeakerphoneOn(_isSpeakerOn);
    } catch (_) {}
    _startRingtone(isIncoming: false);
    _startProximityListener();
    notifyListeners();

    // Отправляем сигнальное сообщение о начале звонка
    _signalingService.startCall(
      targetUserId: targetUserId,
      callType: callType,
      callerName: callerName,
    );
  }

  /// Принять входящий звонок
  Future<void> acceptIncomingCall() async {
    final callId = _activeCallId;
    if (_state != CallState.incoming || callId == null) return;

    _stopRingtone();
    _state = CallState.connected;
    _isSpeakerOn = (_callType == 'video');
    try {
      Helper.setSpeakerphoneOn(_isSpeakerOn);
    } catch (_) {}
    _startProximityListener();
    notifyListeners();

    // 1. Отвечаем по WebSocket
    if (_isGroupCall) {
      _signalingService.acceptGroupCall(callId);
    } else {
      _signalingService.acceptCall(callId);
    }

    // 2. Подключаемся к LiveKit
    try {
      await _connectToLiveKit(callId);
    } catch (e) {
      debugPrint('CallManager: accept error: $e');
      hangUp(reason: 'Ошибка подключения к LiveKit');
    }
  }

  /// Отклонить входящий звонок
  void rejectIncomingCall() {
    final callId = _activeCallId;
    if (_state != CallState.incoming || callId == null) return;

    if (_isGroupCall) {
      _signalingService.rejectGroupCall(callId);
    } else {
      _signalingService.rejectCall(callId);
    }
    _cleanup();
  }

  /// Принять звонок по ID (для запуска из фонового режима/убитого состояния)
  Future<void> acceptCallById(String callId,
      {String? callerName, String? callerId}) async {
    debugPrint(
        'CallManager: acceptCallById $callId, callerName=$callerName, callerId=$callerId');

    // Синхронно переводим состояние, чтобы UI не закрывал ActiveCallScreen
    _activeCallId = callId;
    _state = CallState.incoming;
    if (callerName != null) _targetName = callerName;
    if (callerId != null) _targetUserId = callerId;
    notifyListeners();

    try {
      final storageUserId = await TokenStorage()
          .getUserData()
          .then((data) => data?['id']?.toString());
      if (storageUserId != null) {
        await _signalingService.connect(storageUserId);
        await acceptIncomingCall();
      }
    } catch (e) {
      debugPrint('CallManager: acceptCallById error: $e');
      hangUp(reason: 'Ошибка принятия звонка при старте');
    }
  }

  /// Отклонить звонок по ID (для запуска из фонового режима/убитого состояния)
  Future<void> rejectCallById(String callId) async {
    debugPrint('CallManager: rejectCallById $callId');
    if (_activeCallId == callId && _state == CallState.incoming) {
      rejectIncomingCall();
      return;
    }
    try {
      final storageUserId = await TokenStorage()
          .getUserData()
          .then((data) => data?['id']?.toString());
      if (storageUserId != null) {
        final tempSignaling = WebRTCSignalingService(apiClient: _apiClient);
        await tempSignaling.connect(storageUserId);
        await Future.delayed(const Duration(milliseconds: 500));
        tempSignaling.rejectCall(callId);
        await Future.delayed(const Duration(milliseconds: 500));
        tempSignaling.disconnect();
      }
    } catch (e) {
      debugPrint('CallManager: rejectCallById error: $e');
    }
    await FlutterCallkitIncoming.endCall(callId);
  }

  /// Завершить текущий звонок (сброс)
  void hangUp({String reason = 'Звонок завершен'}) {
    final callId = _activeCallId;
    if (callId != null) {
      if (_isGroupCall) {
        if (_state == CallState.incoming) {
          _signalingService.rejectGroupCall(callId, reason: reason);
        } else {
          _signalingService.leaveGroupCall(callId, reason: reason);
        }
      } else {
        if (_state == CallState.incoming) {
          _signalingService.rejectCall(callId, reason: reason);
        } else {
          _signalingService.endCall(callId, reason: reason);
        }
      }
    }
    _cleanup();
  }

  /// Включить/выключить микрофон
  void toggleMicrophone() {
    _isMicrophoneMuted = !_isMicrophoneMuted;
    _room?.localParticipant?.setMicrophoneEnabled(!_isMicrophoneMuted);
    notifyListeners();
  }

  void toggleAudio() => toggleMicrophone();

  /// Включить/выключить камеру
  void toggleCamera() {
    if (_callType != 'video') return;
    _isCameraOff = !_isCameraOff;
    _room?.localParticipant?.setCameraEnabled(!_isCameraOff);
    notifyListeners();
  }

  void toggleVideo() => toggleCamera();

  /// Включить/выключить динамик
  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    if (!_isNearEar) {
      try {
        Helper.setSpeakerphoneOn(_isSpeakerOn);
      } catch (e) {
        debugPrint('CallManager: toggleSpeaker error: $e');
      }
    }
    notifyListeners();
  }

  /// Переключить камеру
  void switchCamera() {
    // В будущем здесь будет переключение передней/задней камеры LiveKit
    notifyListeners();
  }

  /// Завершить звонок
  void endCall() {
    hangUp();
  }

  // ==================== СИГНАЛЬНЫЕ ОБРАБОТЧИКИ ====================

  void _handleCallOfferSent(Map<String, dynamic> data) {
    if (_state != CallState.outgoing) return;
    _activeCallId = data['call_id']?.toString();

    // Подключаемся к LiveKit комнате сразу и ждем собеседника
    if (_activeCallId != null) {
      _connectToLiveKit(_activeCallId!);
    }
  }

  void _handleIncomingCall(Map<String, dynamic> data) {
    if (_state != CallState.idle) {
      // Занято
      final callId = data['call_id']?.toString();
      if (callId != null) {
        _signalingService.rejectCall(callId,
            reason: RuntimeTranslations.instance.resolveByText('Линия занята'));
      }
      return;
    }

    _state = CallState.incoming;
    _activeCallId = data['call_id']?.toString();
    _targetUserId = data['caller_id']?.toString();
    _targetName = data['caller_first_name']?.toString() ??
        data['caller_name']?.toString() ??
        RuntimeTranslations.instance.resolveByText('Пользователь');
    _targetAvatar = data['caller_avatar']?.toString();
    _targetGradient = data['caller_gradient']?.toString();
    _callType = data['call_type']?.toString() ?? 'audio';
    _isMicrophoneMuted = false;
    _isCameraOff = false;
    _startRingtone();
    notifyListeners();
  }

  void _handleCallAnswered(Map<String, dynamic> data) {
    if (_state != CallState.outgoing) return;
    _stopRingtone();
    _state = CallState.connected;
    notifyListeners();
  }

  void _handleCallRejected(Map<String, dynamic> data) {
    _cleanup();
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    _cleanup();
  }

  void _handleCallAnsweredElsewhere(Map<String, dynamic> data) {
    if (_state == CallState.connected) return;
    _cleanup();
  }

  // ==================== LIVEKIT ПОДКЛЮЧЕНИЕ ====================

  Future<void> _connectToLiveKit(String roomName) async {
    try {
      // 1. Получаем токен с бэка через наш ApiClient
      final response = await _apiClient.get(
        '/../webrtc/livekit-token/',
        queryParameters: {'room': roomName},
      );

      final token = response.data['token']?.toString() ?? '';
      var lkUrl = response.data['url']?.toString() ?? '';

      // Форматируем URL для LiveKit в зависимости от адреса бэкенда в локальной сети
      final apiUri = Uri.parse(AppConfig.apiBaseUrl);
      final apiHost = apiUri.host;
      if (lkUrl.isNotEmpty) {
        final parsedLk = Uri.parse(lkUrl);
        if (apiHost != 'xaneo.ru') {
          final scheme = parsedLk.scheme == 'wss' ? 'ws' : parsedLk.scheme;
          final port = parsedLk.hasPort ? parsedLk.port : 7880;
          lkUrl = Uri(
            scheme: scheme,
            host: apiHost,
            port: port,
            path: parsedLk.path.isNotEmpty ? parsedLk.path : null,
          ).toString();
        }
      }
      debugPrint('CallManager: Mobile connecting to LiveKit URL: $lkUrl');

      // 2. Создаем комнату
      _room = Room();
      _roomListener = _room!.createListener();

      // Слушаем появление удаленных треков
      _roomListener!.on<TrackSubscribedEvent>((event) {
        if (event.track.kind == TrackType.VIDEO) {
          _remoteVideoTrack = event.track as VideoTrack;
          notifyListeners();
        }
      });

      // 3. Подключаемся
      await _room!.connect(
        lkUrl,
        token,
        connectOptions: const ConnectOptions(
          autoSubscribe: true,
        ),
      );

      // 4. Публикуем микрофон
      await _room!.localParticipant?.setMicrophoneEnabled(true);

      // 5. Публикуем камеру, если видеозвонок
      if (_callType == 'video') {
        await _room!.localParticipant?.setCameraEnabled(true);
        _localVideoTrack = _room!.localParticipant?.videoTrackPublications
            .firstOrNull?.track as VideoTrack?;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('CallManager: LiveKit connection error: $e');
      hangUp(reason: 'Ошибка подключения к комнате');
    }
  }

  void _startRingtone({bool isIncoming = true}) async {
    try {
      final assetPath = isIncoming
          ? 'assets/sounds/incoming-call.mp3'
          : 'assets/sounds/outgoing-call.mp3';
      await _ringtonePlayer.setAsset(assetPath);
      await _ringtonePlayer.setLoopMode(LoopMode.one);
      await _ringtonePlayer.setVolume(isIncoming ? 0.7 : 0.6);
      _ringtonePlayer.play();
    } catch (e) {
      debugPrint('CallManager: error playing ringtone: $e');
    }
  }

  void _stopRingtone() async {
    try {
      if (_ringtonePlayer.playing) {
        await _ringtonePlayer.stop();
      }
    } catch (e) {
      debugPrint('CallManager: error stopping ringtone: $e');
    }
  }

  void _startProximityListener() {
    _stopProximityListener();
    try {
      _proximitySubscription = ProximitySensor.events.listen((int event) {
        final isNear = event > 0;
        if (_isNearEar != isNear) {
          _isNearEar = isNear;
          if (_isNearEar) {
            // Телефон поднесен к уху -> переключаем звук на разговорный динамик (earpiece)
            try {
              Helper.setSpeakerphoneOn(false);
            } catch (_) {}
          } else {
            // Отодвинули от уха -> восстанавливаем текущий режим громкой связи
            try {
              Helper.setSpeakerphoneOn(_isSpeakerOn);
            } catch (_) {}
          }
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('CallManager: ProximitySensor error: $e');
    }
  }

  void _stopProximityListener() {
    _proximitySubscription?.cancel();
    _proximitySubscription = null;
    if (_isNearEar) {
      _isNearEar = false;
      notifyListeners();
    }
  }

  void _cleanup() {
    _stopProximityListener();
    try {
      Helper.setSpeakerphoneOn(true);
    } catch (_) {}

    _stopRingtone();
    _roomListener?.dispose();
    _roomListener = null;

    _room?.disconnect();
    _room = null;

    _localVideoTrack = null;
    _remoteVideoTrack = null;
    _isGroupCall = false;
    _groupCallId = null;
    _groupParticipants.clear();
    _activeCallId = null;
    _targetUserId = null;
    _targetName = null;
    _targetAvatar = null;
    _targetGradient = null;
    _state = CallState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopProximityListener();
    _cleanup();
    _ringtonePlayer.dispose();
    super.dispose();
  }
}
