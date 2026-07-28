import 'dart:async';
import 'package:grpc/grpc.dart';
import 'package:fixnum/fixnum.dart';
import '../generated/grpc/chat_service.pbgrpc.dart';
import '../generated/grpc/presence_service.pbgrpc.dart';


class XaneoGrpcService {
  static final XaneoGrpcService _instance = XaneoGrpcService._internal();
  factory XaneoGrpcService() => _instance;
  XaneoGrpcService._internal();

  ClientChannel? _chatChannel;
  ClientChannel? _presenceChannel;

  ChatWebServiceClient? _chatClient;
  PresenceServiceClient? _presenceClient;

  bool _isInitialized = false;

  void init({String host = '127.0.0.1', int chatPort = 50051, int presencePort = 50053}) {
    if (_isInitialized) return;

    _chatChannel = ClientChannel(
      host,
      port: chatPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _chatClient = ChatWebServiceClient(_chatChannel!);

    _presenceChannel = ClientChannel(
      host,
      port: presencePort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _presenceClient = PresenceServiceClient(_presenceChannel!);

    _isInitialized = true;
    print('🚀 [Xaneo Dart gRPC] Channel initialized to $host:$chatPort (Chat) & $presencePort (Presence)');
  }

  /// Stream message history for a chat over gRPC
  Stream<MessageItem>? getMessageHistory(String chatId, {int limit = 50, String beforeMessageId = ''}) {
    if (!_isInitialized || _chatClient == null) {
      print('⚠️ [gRPC] Client not initialized. Call init() first.');
      return null;
    }

    final req = HistoryRequest()
      ..chatId = chatId
      ..limit = limit
      ..beforeMessageId = beforeMessageId;

    print('🚀 [gRPC Stream] Requesting history for chat: $chatId');
    return _chatClient!.getMessageHistory(req);
  }

  /// Fast Mark As Read via gRPC
  Future<bool> markAsRead(String chatId, String userId) async {
    if (!_isInitialized || _chatClient == null) return false;

    try {
      final req = MarkAsReadRequest()
        ..chatId = chatId
        ..userId = userId;

      final res = await _chatClient!.markAsRead(req).timeout(const Duration(seconds: 2));
      print('📖 [gRPC ACK] Marked messages as read: count=${res.markedCount}');
      return res.success;
    } catch (e) {
      print('⚠️ [gRPC Offline] markAsRead fallback to REST/WS: $e');
      return false;
    }
  }

  /// Send Presence Ping (Online / Typing / Idle)
  Future<bool> sendPresence(String userId, String status, {String chatId = ''}) async {
    if (!_isInitialized || _presenceClient == null) return false;

    try {
      final req = PresencePing()
        ..userId = userId
        ..status = status
        ..chatId = chatId
        ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

      final res = await _presenceClient!.sendPresence(req).timeout(const Duration(seconds: 2));
      return res.success;
    } catch (e) {
      print('⚠️ [gRPC Offline] sendPresence fallback to WebSocket: $e');
      return false;
    }
  }

  /// Subscribe to contact presence updates (Server Streaming)
  Stream<PresenceUpdate>? streamPresenceUpdates(String userId, List<String> contactIds) {
    if (!_isInitialized || _presenceClient == null) return null;

    final req = PresenceSubscription()
      ..userId = userId
      ..contactIds.addAll(contactIds);

    return _presenceClient!.streamPresenceUpdates(req);
  }

  void dispose() {
    _chatChannel?.shutdown();
    _presenceChannel?.shutdown();
    _isInitialized = false;
  }
}
