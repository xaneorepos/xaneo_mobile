import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:just_audio/just_audio.dart';

import '../api/api_client.dart';
import '../auth/token_storage.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'webrtc_signaling_service.dart';

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
    _targetUserId = targetUserId;
    _targetName = targetName;
    _targetAvatar = targetAvatar;
    _targetGradient = targetGradient;
    _callType = callType;
    _isMicrophoneMuted = false;
    _isCameraOff = false;
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
    notifyListeners();

    // 1. Отвечаем по WebSocket
    _signalingService.acceptCall(callId);

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

    _signalingService.rejectCall(callId);
    _cleanup();
  }

  /// Принять звонок по ID (для запуска из фонового режима/убитого состояния)
  Future<void> acceptCallById(String callId, {String? callerName, String? callerId}) async {
    debugPrint('CallManager: acceptCallById $callId, callerName=$callerName, callerId=$callerId');
    
    // Синхронно переводим состояние, чтобы UI не закрывал ActiveCallScreen
    _activeCallId = callId;
    _state = CallState.incoming;
    if (callerName != null) _targetName = callerName;
    if (callerId != null) _targetUserId = callerId;
    notifyListeners();

    try {
      final storageUserId = await TokenStorage().getUserData().then((data) => data?['id']?.toString());
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
      final storageUserId = await TokenStorage().getUserData().then((data) => data?['id']?.toString());
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
      if (_state == CallState.incoming) {
        _signalingService.rejectCall(callId, reason: reason);
      } else {
        _signalingService.endCall(callId, reason: reason);
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

  /// Включить/выключить камеру
  void toggleCamera() {
    if (_callType != 'video') return;
    _isCameraOff = !_isCameraOff;
    _room?.localParticipant?.setCameraEnabled(!_isCameraOff);
    notifyListeners();
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
        _signalingService.rejectCall(callId, reason: 'Линия занята');
      }
      return;
    }

    _state = CallState.incoming;
    _activeCallId = data['call_id']?.toString();
    _targetUserId = data['caller_id']?.toString();
    _targetName = data['caller_first_name']?.toString() ?? data['caller_name']?.toString() ?? 'Пользователь';
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
      final lkUrl = response.data['url']?.toString() ?? '';

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
      await _room!.connect(lkUrl, token);

      // 4. Публикуем микрофон
      await _room!.localParticipant?.setMicrophoneEnabled(true);

      // 5. Публикуем камеру, если видеозвонок
      if (_callType == 'video') {
        await _room!.localParticipant?.setCameraEnabled(true);
        _localVideoTrack = _room!.localParticipant?.videoTrackPublications.firstOrNull?.track as VideoTrack?;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('CallManager: LiveKit connection error: $e');
      hangUp(reason: 'Ошибка подключения к комнате');
    }
  }

  void _startRingtone() async {
    try {
      await _ringtonePlayer.setAsset('assets/sounds/incoming-call.mp3');
      await _ringtonePlayer.setLoopMode(LoopMode.one);
      await _ringtonePlayer.setVolume(0.7);
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

  void _cleanup() {
    _stopRingtone();
    _roomListener?.dispose();
    _roomListener = null;

    _room?.disconnect();
    _room = null;

    _localVideoTrack = null;
    _remoteVideoTrack = null;
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
    _cleanup();
    _ringtonePlayer.dispose();
    super.dispose();
  }
}
