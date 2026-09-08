import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../../config/app_config.dart';
import '../auth/token_storage.dart';
import '../api/api_client.dart';

class WebRTCSignalingService {
  final TokenStorage _tokenStorage;
  final ApiClient? _apiClient;

  final StreamController<Map<String, dynamic>> _eventsController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  IOWebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  String? _currentUserId;
  bool _manualDisconnect = false;
  int _reconnectAttempt = 0;

  // Callbacks для интеграции с UI/менеджером звонков
  Function(Map<String, dynamic>)? onIncomingCall;
  Function(Map<String, dynamic>)? onCallAnswered;
  Function(Map<String, dynamic>)? onCallRejected;
  Function(Map<String, dynamic>)? onCallEnded;
  Function(Map<String, dynamic>)? onCallOfferSent;
  Function(Map<String, dynamic>)? onCallAnsweredElsewhere;
  void Function(Map<String, dynamic>)? onIncomingGroupCall;
  void Function(Map<String, dynamic>)? onGroupCallOfferSent;
  void Function(Map<String, dynamic>)? onGroupCallEnded;
  void Function(Map<String, dynamic>)? onGroupParticipantJoined;
  void Function(Map<String, dynamic>)? onGroupParticipantLeft;

  WebRTCSignalingService({TokenStorage? tokenStorage, ApiClient? apiClient})
      : _tokenStorage = tokenStorage ?? TokenStorage(),
        _apiClient = apiClient;

  Future<void> connect(String userId) async {
    if (_currentUserId == userId && _channel != null) return;

    await disconnect();
    _manualDisconnect = false;
    _currentUserId = userId;

    var token = await _tokenStorage.getAccessToken();
    bool isExpired = token == null || token.isEmpty || _isTokenExpired(token);

    if (isExpired && _apiClient != null) {
      debugPrint('WebRTC WS: token expired, refreshing...');
      final newToken = await _apiClient!.refreshToken();
      if (newToken != null && newToken.isNotEmpty) {
        token = newToken;
        isExpired = false;
      }
    }

    if (token == null || token.isEmpty || isExpired) {
      debugPrint(
          'WebRTC WS: Auth token missing or expired. Connection aborted.');
      return;
    }

    final uri = _buildWsUri(userId, token);
    final safeUri = uri.replace(queryParameters: {'token': '***'});
    debugPrint('WebRTC WS: connecting to $safeUri');

    isConnected.value = false;

    try {
      final socket = await _openSocketWithFallback(uri);
      _channel = IOWebSocketChannel(socket);
      _subscription = _channel!.stream.listen(
        _handleRawEvent,
        onError: (error) {
          debugPrint('WebRTC WS: stream error: $error');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('WebRTC WS: stream closed');
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
      _reconnectAttempt = 0;
      isConnected.value = true;
      debugPrint('WebRTC WS: connected successfully');
    } catch (e) {
      debugPrint('WebRTC WS: connect error: $e');
      _scheduleReconnect();
    }
  }

  Future<WebSocket> _openSocketWithFallback(Uri uri) async {
    final customClient = _buildDebugHttpClientForSelfSigned(uri);
    final token = uri.queryParameters['token'];
    final headers = <String, dynamic>{
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      return await WebSocket.connect(
        uri.toString(),
        headers: headers,
        customClient: customClient,
      );
    } catch (e) {
      final isIpHost = InternetAddress.tryParse(uri.host) != null;
      final isTlsCertIssue = e.toString().contains('CERTIFICATE_VERIFY_FAILED');
      final isPrivate = _isPrivateIp(uri.host);

      if ((!kReleaseMode || isPrivate) &&
          isIpHost &&
          uri.scheme == 'wss' &&
          isTlsCertIssue) {
        final fallbackUri = uri.replace(scheme: 'ws');
        final safeFallbackUri =
            fallbackUri.replace(queryParameters: {'token': '***'});
        debugPrint(
            'WebRTC WS: TLS failed, trying fallback to $safeFallbackUri');

        return await WebSocket.connect(
          fallbackUri.toString(),
          headers: headers,
        );
      }
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    isConnected.value = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _currentUserId = null;

    _subscription?.cancel();
    _subscription = null;

    _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
  }

  Future<void> send(Map<String, dynamic> payload) async {
    final channel = _channel;
    if (channel == null) {
      debugPrint('WebRTC WS: Cannot send, socket disconnected.');
      return;
    }
    channel.sink.add(jsonEncode(payload));
  }

  void startCall(
      {required String targetUserId,
      required String callType,
      required String callerName}) {
    send({
      'type': 'call_offer',
      'target_user_id': int.tryParse(targetUserId) ?? 0,
      'offer': 'livekit',
      'caller_name': callerName,
      'call_type': callType,
    });
  }

  void startGroupCall({
    required String groupId,
    required String callType,
  }) {
    send({
      'type': 'group_call_offer',
      'group_id': int.tryParse(groupId) ?? groupId,
      'call_type': callType,
    });
  }

  void acceptGroupCall(String groupCallId) {
    send({
      'type': 'group_call_accept',
      'group_call_id': groupCallId,
    });
  }

  void rejectGroupCall(String groupCallId, {String reason = 'Отклонено'}) {
    send({
      'type': 'group_call_reject',
      'group_call_id': groupCallId,
      'reason': reason,
    });
  }

  void leaveGroupCall(String groupCallId, {String reason = 'Покинул звонок'}) {
    send({
      'type': 'group_call_leave',
      'group_call_id': groupCallId,
      'reason': reason,
    });
  }

  void acceptCall(String callId) {
    send({
      'type': 'call_answer',
      'call_id': callId,
      'answer': 'livekit',
    });
  }

  void rejectCall(String callId, {String reason = 'Звонок отклонен'}) {
    send({
      'type': 'call_reject',
      'call_id': callId,
      'reason': reason,
    });
  }

  void endCall(String callId, {String reason = 'Звонок завершен'}) {
    send({
      'type': 'call_end',
      'call_id': callId,
      'reason': reason,
    });
  }

  Future<void> dispose() async {
    await disconnect();
    await _eventsController.close();
  }

  Uri _buildWsUri(String userId, String token) {
    final apiUri = Uri.parse(AppConfig.apiBaseUrl);
    final shouldUseInsecureWs = apiUri.scheme != 'https';
    final wsScheme = shouldUseInsecureWs ? 'ws' : 'wss';
    final query = <String, String>{'token': token};

    return Uri(
      scheme: wsScheme,
      host: apiUri.host,
      port: apiUri.hasPort ? apiUri.port : null,
      path: '/ws/webrtc/signal/$userId/',
      queryParameters: query,
    );
  }

  HttpClient? _buildDebugHttpClientForSelfSigned(Uri uri) {
    if (kReleaseMode && !_isPrivateIp(uri.host)) return null;

    final isIpHost = InternetAddress.tryParse(uri.host) != null;
    if (uri.scheme != 'wss' || !isIpHost) return null;

    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      debugPrint('WebRTC WS: bypass TLS self-signed cert for $host:$port');
      return true;
    };
    return client;
  }

  bool _isPrivateIp(String host) {
    if (host == 'localhost' || host == '127.0.loc_0.1') return true;
    final address = InternetAddress.tryParse(host);
    if (address == null) return false;

    if (address.type == InternetAddressType.IPv4) {
      final parts = host.split('.').map(int.tryParse).toList();
      if (parts.length == 4 && parts[0] != null) {
        if (parts[0] == 10) return true;
        if (parts[0] == 192 && parts[1] == 168) return true;
        if (parts[0] == 172 &&
            parts[1] != null &&
            parts[1]! >= 16 &&
            parts[1]! <= 31) return true;
      }
    }
    return false;
  }

  void _handleRawEvent(dynamic raw) {
    try {
      final parsed = raw is String ? jsonDecode(raw) : raw;
      Map<String, dynamic> event;
      if (parsed is Map<String, dynamic>) {
        event = parsed;
      } else if (parsed is Map) {
        event = parsed.cast<String, dynamic>();
      } else {
        return;
      }

      if (event['type'] == 'session_revoked') {
        _manualDisconnect = true;
        _reconnectTimer?.cancel();
        _apiClient?.onSessionExpired?.call();
        return;
      }

      _eventsController.add(event);

      // Прокидываем в специфичные коллбэки
      final type = event['type']?.toString();
      switch (type) {
        case 'incoming_call':
          onIncomingCall?.call(event);
          break;
        case 'call_answered':
          onCallAnswered?.call(event);
          break;
        case 'call_rejected':
          onCallRejected?.call(event);
          break;
        case 'call_ended':
          onCallEnded?.call(event);
          break;
        case 'call_offer_sent':
          onCallOfferSent?.call(event);
          break;
        case 'call_answered_elsewhere':
          onCallAnsweredElsewhere?.call(event);
          break;
        case 'incoming_group_call':
          onIncomingGroupCall?.call(event);
          break;
        case 'group_call_offer_sent':
          onGroupCallOfferSent?.call(event);
          break;
        case 'group_call_ended':
          onGroupCallEnded?.call(event);
          break;
        case 'group_participant_joined':
          onGroupParticipantJoined?.call(event);
          break;
        case 'group_participant_left':
          onGroupParticipantLeft?.call(event);
          break;
      }
    } catch (e) {
      debugPrint('WebRTC WS: failed to parse/route event: $e');
    }
  }

  void _scheduleReconnect() {
    isConnected.value = false;
    if (_manualDisconnect || _currentUserId == null) return;

    _reconnectTimer?.cancel();
    _reconnectAttempt += 1;

    final exponent = _reconnectAttempt > 6 ? 6 : _reconnectAttempt;
    final baseDelaySeconds = 1 << exponent;
    final jitterMs = Random().nextInt(1000);
    final delay = Duration(milliseconds: baseDelaySeconds * 1000 + jitterMs);
    debugPrint(
        'WebRTC WS: reconnect in ${baseDelaySeconds}s + ${jitterMs}ms (attempt $_reconnectAttempt)');

    _reconnectTimer = Timer(delay, () {
      final userId = _currentUserId;
      if (userId == null) return;
      connect(userId);
    });
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      var normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
      final pad = normalized.length % 4;
      if (pad == 2) {
        normalized += '==';
      } else if (pad == 3) {
        normalized += '=';
      }
      final decodedBytes = base64Decode(normalized);
      final decodedString = utf8.decode(decodedBytes);
      final jsonMap = jsonDecode(decodedString) as Map<String, dynamic>;

      if (jsonMap.containsKey('exp')) {
        final exp = jsonMap['exp'] as int;
        final expiry =
            DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
        return DateTime.now()
            .toUtc()
            .isAfter(expiry.subtract(AppConfig.tokenRefreshThreshold));
      }
      return true;
    } catch (e) {
      debugPrint('WebRTC WS: error parsing token expiry: ${e.runtimeType}');
      return true;
    }
  }
}
