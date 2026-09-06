import 'dart:async';
import 'dart:convert';
import 'dart:math' show max, min, pi;
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../models/chat/chat_model.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../widgets/common/video_thumbnail_widget.dart';
import '../../widgets/common/track_artwork.dart';
import '../../models/auth/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appearance_provider.dart';
import '../../models/message_color_presets.dart';
import '../../services/auth/token_storage.dart';
import '../../services/api/api_client.dart';
import '../../services/chat/chat_local_repository.dart';
import '../../services/chat/chat_service.dart';
import '../../services/chat/chat_websocket_service.dart';
import '../../services/chat/group_channel_service.dart';
import '../../services/crypto/crypto_service.dart';
import '../../services/grpc_service.dart';
import '../../services/database/app_database.dart';
import '../../styles/app_styles.dart';
import '../../utils/audio_metadata.dart';
import '../../utils/chat_name_localizer.dart';
import '../../utils/avatar_resolver.dart';
import '../../widgets/common/chat_info_modal.dart';
import '../../widgets/common/chat_context_menu.dart';
import '../../widgets/common/base_custom_modal.dart';
import '../../widgets/common/compress_image_modal.dart';
import '../../widgets/common/confirm_action_modal.dart';
import '../../widgets/common/music_playlist_modal.dart';
import '../../services/webrtc/call_manager.dart';
import '../webrtc/active_call_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../utils/local_proxy.dart';
import 'package:record/record.dart';
import 'widgets/todo_poll_widgets.dart';
import '../../widgets/common/create_poll_todo_modals.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/video_message_player.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/playback_provider.dart';
import '../../widgets/voice_waveform_slider.dart';
import '../../widgets/emoji_picker_panel.dart';
import 'package:xaneo/l10n/app_localizations.dart';
import '../../services/runtime_translations.dart';

/// Immutable state class для оптимизации Selector
String? _parseReplyField(dynamic val) {
  if (val == null) return null;
  final str = val.toString().trim();
  if (str.isEmpty || str == 'null' || str == 'None' || str == '0') return null;
  return str;
}

bool _areSameChat(String? id1, String? id2) {
  if (id1 == null || id2 == null) return false;
  if (id1 == id2) return true;

  final s1 = id1.toString().trim();
  final s2 = id2.toString().trim();
  if (s1 == s2) return true;

  if (s1.startsWith('personal_') && s2.startsWith('personal_')) {
    final parts1 = s1.replaceFirst('personal_', '').split('_');
    final parts2 = s2.replaceFirst('personal_', '').split('_');
    if (parts1.length == 2 && parts2.length == 2) {
      return (parts1[0] == parts2[0] && parts1[1] == parts2[1]) ||
          (parts1[0] == parts2[1] && parts1[1] == parts2[0]);
    }
  }

  String norm(String s) {
    if (s.startsWith('group_')) return s.replaceFirst('group_', '');
    if (s.startsWith('channel_')) return s.replaceFirst('channel_', '');
    if (s.startsWith('favorites_')) return s.replaceFirst('favorites_', '');
    return s;
  }

  return norm(s1) == norm(s2);
}

class _VoicePlaybackState {
  final String? currentAudioUrl;
  final bool isPlaying;
  final bool isInitialized;
  final bool isLoading;
  final double downloadProgress;
  final Duration position;
  final Duration duration;

  const _VoicePlaybackState({
    required this.currentAudioUrl,
    required this.isPlaying,
    required this.isInitialized,
    required this.isLoading,
    required this.downloadProgress,
    required this.position,
    required this.duration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _VoicePlaybackState &&
          runtimeType == other.runtimeType &&
          currentAudioUrl == other.currentAudioUrl &&
          isPlaying == other.isPlaying &&
          isInitialized == other.isInitialized &&
          isLoading == other.isLoading &&
          downloadProgress == other.downloadProgress &&
          position == other.position &&
          duration == other.duration;

  @override
  int get hashCode =>
      currentAudioUrl.hashCode ^
      isPlaying.hashCode ^
      isInitialized.hashCode ^
      isLoading.hashCode ^
      downloadProgress.hashCode ^
      position.hashCode ^
      duration.hashCode;
}

class ChatScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late final LocalChatRepository _localChatRepo;
  late final ChatService _chatService;
  late final ChatWebSocketService _chatWebSocketService;
  StreamSubscription? _wsEventsSub;

  final _messageController = FormattedTextEditingController();
  final List<AttachmentComposition> _attachments = [];
  final _messageFocusNode = FocusNode();
  final _scrollController = ScrollController();
  final GlobalKey _messageListKey = GlobalKey();
  bool _floatingDateUpdateScheduled = false;
  List<Message>? _lastFloatingDateMessagesSnapshot;
  String? _floatingDateText;
  bool _showFloatingDate = false;
  bool _isEmojiPickerVisible = false;
  double _emojiPickerHeight = 300;
  TextSelection _emojiInsertionSelection = const TextSelection.collapsed(
    offset: 0,
  );

  int? _localChatId;
  bool _isLoading = true;
  bool _isVoiceMode = true;
  late bool _isChatPinned;
  late bool _isChatMuted;

  // Recording state variables
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingDurationSeconds = 0;
  double _dragOffset = 0.0;
  bool _isHoldingButton = false;

  // Video recording state variables
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isRecordingVideo = false;
  Timer? _videoRecordingTimer;
  double _videoRecordingDurationSeconds = 0.0;
  final Map<String, String> _pendingVideoTempIds =
      {}; // file_id -> temp serverMessageId
  final Map<String, String> _pendingVideoLocalPaths =
      {}; // file_id -> локальный путь к записи
  late Stream<List<Message>> _messagesStream;

  // Local copy of otherUser to reflect WS status updates
  Map<String, dynamic>? _otherUser;
  static final Map<String, List<Map<String, String>>> _botCommandsCache = {};
  List<Map<String, String>> _botCommands = const [];

  // State variables for pagination/virtualization
  bool _isHistoryLoading = false;
  bool _hasMoreMessages = true;
  int _limit = 20;
  String? _highlightedMessageId;
  List<Message> _loadedMessages = [];

  // In-memory reactions cache: serverMessageId -> list of reaction maps
  final Map<String, List<dynamic>> _messageReactions = {};

  Future<void> _loadCachedReactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_reactions_${widget.chat.id}';
      final jsonStr = prefs.getString(key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map) {
          if (mounted) {
            setState(() {
              decoded.forEach((k, v) {
                if (v is List) {
                  _messageReactions[k.toString()] = List<dynamic>.from(v);
                }
              });
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading cached reactions: $e');
    }
  }

  Future<void> _saveCachedReactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_reactions_${widget.chat.id}';
      await prefs.setString(key, jsonEncode(_messageReactions));
    } catch (e) {
      debugPrint('Error saving cached reactions: $e');
    }
  }

  // Typing state variables (sending)
  bool _isTyping = false;
  Timer? _typingRepeatTimer;
  Timer? _typingStopTimer;

  // Typing state variables (receiving)
  String? _typingText;
  Timer? _typingTimer;
  String? _activeLottiePath;
  String? _jwtToken;
  final Map<String, String> _typingUsers = {};
  final Map<String, String> _typingLottiePaths = {};
  final Map<String, Timer> _typingTimers = {};
  final Map<String, Map<String, dynamic>> _userProfiles = {};

  void _cacheUserProfileFromMap(Map<String, dynamic> item) {
    final senderId = item['author_username']?.toString() ??
        item['sender_id']?.toString() ??
        item['author_id']?.toString();
    if (senderId != null && senderId.isNotEmpty && senderId != 'unknown') {
      String? firstName;
      String? avatar;
      String? gradient;

      if (item['author'] is Map) {
        final authorMap = Map<String, dynamic>.from(item['author']);
        firstName = authorMap['first_name']?.toString();
        avatar = authorMap['avatar']?.toString() ??
            authorMap['avatar_url']?.toString();
        gradient = authorMap['avatar_gradient']?.toString();
      }

      firstName ??= item['author_first_name']?.toString() ??
          item['first_name']?.toString();
      avatar ??=
          item['author_avatar']?.toString() ?? item['avatar']?.toString();
      gradient ??= item['author_avatar_gradient']?.toString() ??
          item['avatar_gradient']?.toString();

      final existing = _userProfiles[senderId];
      if (existing != null) {
        firstName ??= existing['first_name']?.toString();
        avatar ??= existing['avatar']?.toString();
        if (gradient == null || gradient.isEmpty) {
          gradient = existing['avatar_gradient']?.toString();
        }
      }

      if (firstName != null ||
          avatar != null ||
          (gradient != null && gradient.isNotEmpty)) {
        _userProfiles[senderId] = {
          'first_name': (firstName != null && firstName.isNotEmpty)
              ? firstName
              : senderId,
          'avatar': avatar,
          'avatar_gradient': gradient,
        };
      }
    }
  }

  // Sets of message IDs to manage animations
  final Set<String> _initialMessageIds = {};
  bool _isInitialLoadDone = false;
  final Set<String> _animatedMessageIds = {};
  final Set<String> _messagesToAnimate = {};
  bool _isOwner = false;
  bool _isMember = true;
  bool _canWrite = true;
  bool _isJoining = false;
  bool _isEphemeralPreview = false;
  String? _chatName;
  Message? _replyingToMessage;

  Future<int?> _ensureLocalChatId({ChatModel? overrideChat}) async {
    final chatToSave = overrideChat ?? widget.chat;
    await _localChatRepo.saveChat(chatToSave);
    final localId = await _localChatRepo.getLocalChatId(chatToSave.id);
    if (mounted && localId != null) {
      if (_localChatId != localId || _isEphemeralPreview) {
        setState(() {
          _localChatId = localId;
          _isEphemeralPreview = false;
        });
      }
    }
    return localId ?? _localChatId;
  }

  Future<void> _ensureChatSavedLocally() async {
    await _ensureLocalChatId();
  }

  // Оптимистичная отправка голосовых: temp-сообщение показывается сразу,
  // затем сверяется с эхом сервера по file_id (чтобы не плодить дубли).
  final Map<String, String> _pendingVoiceTempIds =
      {}; // file_id -> temp serverMessageId
  final Map<String, String> _pendingVoiceLocalPaths =
      {}; // file_id -> локальный путь к записи
  final List<String> _pendingTextTempIds =
      []; // temp serverMessageId for optimistic text messages

  Future<void> _loadJwtToken() async {
    final token = await TokenStorage().getAccessToken();
    if (mounted) {
      setState(() {
        _jwtToken = token;
      });
    }
  }

  Future<void> _loadCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint('Error loading cameras: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatName = widget.chat.name;
    _isChatPinned = widget.chat.isPinned;
    _isChatMuted = widget.chat.isMuted;
    _loadJwtToken();
    _loadCameras();
    _otherUser = widget.chat.otherUser != null
        ? Map<String, dynamic>.from(widget.chat.otherUser!)
        : null;
    _localChatRepo = context.read<LocalChatRepository>();
    _chatService = ChatService(apiClient: context.read<ApiClient>());
    _loadBotCommands();
    _messagesStream = _localChatRepo.watchMessagesForServerChat(widget.chat.id,
        limit: _limit);
    _chatWebSocketService = ChatWebSocketService(
      tokenStorage: TokenStorage(),
      apiClient: context.read<ApiClient>(),
    );

    _scrollController.addListener(_scrollListener);
    _messageController.addListener(_onTextChanged);
    _initChat();

    if (widget.chat.isGroup) {
      final callsEnabled = widget.chat.groupCallsEnabled;
      final rawCallsEnabled = widget.chat.raw['group_calls_enabled'];
      final otherCallsEnabled = widget.chat.otherUser?['group_calls_enabled'];
      debugPrint('====================================================');
      debugPrint(
          '👥 [GROUP CALL LOG] Заход в групповой чат ID=${widget.chat.id} "${widget.chat.name}":');
      debugPrint('   -> widget.chat.groupCallsEnabled = $callsEnabled');
      debugPrint(
          '   -> widget.chat.raw["group_calls_enabled"] = $rawCallsEnabled');
      debugPrint(
          '   -> widget.chat.otherUser["group_calls_enabled"] = $otherCallsEnabled');
      debugPrint(
          '   -> Кнопка звонка разрешена в UI (_canCall()): ${_canCall()}');
      debugPrint('====================================================');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    _messageController.removeListener(_onTextChanged);
    _wsEventsSub?.cancel();
    _chatWebSocketService.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();

    _typingRepeatTimer?.cancel();
    _typingStopTimer?.cancel();
    _typingTimer?.cancel();
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _videoRecordingTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _chatWebSocketService.reconnect(widget.chat.id);
    }
  }

  void _onTextChanged() {
    final text = _messageController.text;
    if (text.isNotEmpty) {
      _startTypingState();
    } else {
      _stopTypingState();
    }
  }

  void _sendTypingEvent(bool isTypingNow, {String action = 'typing'}) {
    _chatWebSocketService.send({
      'type': 'typing',
      'is_typing': isTypingNow,
      'action': action,
    });
  }

  void _startTypingState() {
    if (_isTyping) {
      _typingStopTimer?.cancel();
      _typingStopTimer = Timer(const Duration(seconds: 2), _stopTypingState);
      return;
    }

    _isTyping = true;
    _sendTypingEvent(true);

    _typingRepeatTimer?.cancel();
    _typingRepeatTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isTyping) {
        _sendTypingEvent(true);
      }
    });

    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(seconds: 2), _stopTypingState);
  }

  void _stopTypingState() {
    if (!_isTyping) return;
    _isTyping = false;
    _sendTypingEvent(false);

    _typingRepeatTimer?.cancel();
    _typingRepeatTimer = null;
    _typingStopTimer?.cancel();
    _typingStopTimer = null;
  }

  void _scrollListener() {
    // If we scroll close to the top (maxScrollExtent), load more history
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMessages();
    }
  }

  Future<void> _initChat() async {
    // Pre-load saved user profiles from widget.chat.otherUser
    if (widget.chat.otherUser != null &&
        widget.chat.otherUser!['user_profiles'] is Map) {
      try {
        final savedProfiles =
            widget.chat.otherUser!['user_profiles'] as Map<String, dynamic>;
        savedProfiles.forEach((key, val) {
          if (val is Map) {
            _userProfiles[key] = Map<String, dynamic>.from(val);
          }
        });
      } catch (e) {
        debugPrint('Error restoring user_profiles from otherUser: $e');
      }
    }

    if (widget.chat.otherUser != null) {
      if (widget.chat.otherUser!['is_member'] != null) {
        _isMember = widget.chat.otherUser!['is_member'] == true;
      }
      if (widget.chat.otherUser!['can_write'] != null) {
        _canWrite = widget.chat.otherUser!['can_write'] == true;
      }
    }

    // 0. Сначала восстанавливаем кэшированные реакции для чата
    await _loadCachedReactions();

    // 1. Check if chat exists locally
    var localId = await _localChatRepo.getLocalChatId(widget.chat.id);
    final isGroupOrChannel = widget.chat.isGroup || widget.chat.isChannel;
    final bool initialIsMember;
    if (!isGroupOrChannel) {
      initialIsMember = true;
    } else if (widget.chat.otherUser?['is_member'] != null) {
      initialIsMember = widget.chat.otherUser!['is_member'] == true;
    } else if (localId != null) {
      initialIsMember = true;
    } else {
      // Brand new group/channel not in local DB with no explicit is_member -> default to false
      initialIsMember = false;
    }

    if (localId == null) {
      final existingOtherUser =
          Map<String, dynamic>.from(widget.chat.otherUser ?? {});
      if (isGroupOrChannel) {
        existingOtherUser['is_member'] = initialIsMember;
      }
      final chatToSave = widget.chat.copyWith(otherUser: existingOtherUser);
      await _localChatRepo.saveChat(chatToSave);
      localId = await _localChatRepo.getLocalChatId(widget.chat.id);
    }

    _isEphemeralPreview = !initialIsMember;
    _isMember = initialIsMember;

    if (localId != null) {
      await _localChatRepo.cleanupFakeFileMessages(localId);
      final localCount = await _localChatRepo.getMessageCount(localId);

      if (localCount > 0) {
        await _warmVisibleImageCache(localId);
      }

      if (mounted) {
        setState(() {
          _localChatId = localId;
          _isEphemeralPreview = !initialIsMember;
          _isMember = initialIsMember;
          if (localCount > 0) {
            _isLoading = false;
          }
          // Set initial limit up to the number of local messages (or at least 20)
          _limit = localCount > 0 ? (localCount < 20 ? localCount : 20) : 20;
          _updateStream();
        });
      }

      if (localCount > 0) {
        // If we have messages locally, sync the latest ones in the background without blocking the UI
        _syncLatestMessages();
      } else {
        // If we have no messages locally, do a blocking load of the first page
        await _loadMoreMessages();
        await _warmVisibleImageCache(localId);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    // 3. Connect to WebSocket for E2EE updates
    await _chatWebSocketService.connect(widget.chat.id);
    _wsEventsSub = _chatWebSocketService.events.listen(_handleWsEvent);

    // 4. Mark messages as read since the chat is open
    _markChatAsRead();

    // 5. Fetch group/channel details for owner check
    _fetchChatDetails();

    if (_localChatId != null) {
      _sweepEncryptedMessages(_localChatId!);
    }
  }

  bool _isImageFileData(Map<String, dynamic> fileData) {
    final type = (fileData['mime_type'] ?? fileData['type'] ?? '')
        .toString()
        .toLowerCase();
    final name = (fileData['file_name'] ?? fileData['name'] ?? '')
        .toString()
        .toLowerCase();
    return type == 'image' ||
        type.startsWith('image/') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.gif') ||
        name.endsWith('.webp') ||
        name.endsWith('.bmp');
  }

  String _remoteFileUrl(Map<String, dynamic> fileData) {
    final fileId = fileData['file_id']?.toString() ?? '';
    var suffix = fileData['file_url']?.toString() ?? '';
    if (suffix.isEmpty && fileId.isNotEmpty) {
      suffix = '/api/files/download/$fileId/';
    }
    if (suffix.isEmpty || suffix.startsWith('http')) return suffix;

    final uri = Uri.parse(AppConfig.apiBaseUrl);
    final host =
        '${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}';
    return '$host${suffix.startsWith('/') ? '' : '/'}$suffix';
  }

  Future<bool> _cacheHistoricalImage(
    Map<String, dynamic> fileData,
    Directory cacheDir,
    ApiClient apiClient,
  ) async {
    if (!_isImageFileData(fileData)) return false;

    final oldLocalPath = fileData['local_path']?.toString();
    if (oldLocalPath != null &&
        oldLocalPath.isNotEmpty &&
        await File(oldLocalPath).exists()) {
      return false;
    }

    final fileId = fileData['file_id']?.toString() ?? '';
    final remoteUrl = _remoteFileUrl(fileData);
    if (fileId.isEmpty || remoteUrl.isEmpty) return false;

    final rawName =
        (fileData['file_name'] ?? fileData['name'] ?? 'image').toString();
    final extensionMatch = RegExp(r'\.[a-zA-Z0-9]{1,8}$').firstMatch(rawName);
    final extension = extensionMatch?.group(0)?.toLowerCase() ?? '.img';
    final safeId = fileId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final cachedFile = File('${cacheDir.path}/$safeId$extension');

    if (!await cachedFile.exists() || await cachedFile.length() == 0) {
      final partialFile = File('${cachedFile.path}.part');
      try {
        final cancelToken = CancelToken();
        await apiClient.dio
            .download(
          remoteUrl,
          partialFile.path,
          cancelToken: cancelToken,
        )
            .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            cancelToken.cancel('Historical image cache timeout');
            throw TimeoutException(
                'Historical image cache timeout for $fileId');
          },
        );
        if (await cachedFile.exists()) {
          await cachedFile.delete();
        }
        await partialFile.rename(cachedFile.path);
      } catch (error) {
        if (await partialFile.exists()) {
          await partialFile.delete();
        }
        debugPrint('Historical image cache failed: ${error.runtimeType}');
        return false;
      }
    }

    fileData['local_path'] = cachedFile.path;
    return true;
  }

  Future<void> _warmVisibleImageCache(int localId) async {
    final apiClient = context.read<ApiClient>();
    final messages = await _localChatRepo.getMessagesForChat(localId);
    if (messages.isEmpty) return;

    final tempDir = await getTemporaryDirectory();
    final safeChatId = widget.chat.id.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    final cacheDir =
        Directory('${tempDir.path}/xaneo_media/$safeChatId/history');
    await cacheDir.create(recursive: true);

    Future<void> cacheMessage(Message message) async {
      final rawFileInfo = message.fileUrl;
      if (rawFileInfo == null || rawFileInfo.isEmpty) return;
      try {
        final decoded = jsonDecode(rawFileInfo);
        if (decoded is! Map) return;
        final fileInfo = Map<String, dynamic>.from(decoded);
        var changed = false;

        final files = fileInfo['files'];
        if (files is List) {
          final mutableFiles = <dynamic>[];
          for (final item in files) {
            if (item is Map) {
              final file = Map<String, dynamic>.from(item);
              changed =
                  await _cacheHistoricalImage(file, cacheDir, apiClient) ||
                      changed;
              mutableFiles.add(file);
            } else {
              mutableFiles.add(item);
            }
          }
          fileInfo['files'] = mutableFiles;
        } else {
          changed = await _cacheHistoricalImage(fileInfo, cacheDir, apiClient);
        }

        if (changed) {
          await _localChatRepo.updateMessageCompanion(
            MessagesCompanion(
              id: Value(message.id),
              fileUrl: Value(jsonEncode(fileInfo)),
            ),
          );
        }
      } catch (error) {
        debugPrint(
            'Failed to prepare cached media for ${message.serverMessageId}: $error');
      }
    }

    // Достаточно прогреть сообщения первого экрана. Параллельная загрузка не
    // заставляет пользователя ждать по 12 секунд на каждую старую фотографию.
    final visibleMessages = messages.take(_limit < 8 ? _limit : 8);
    await Future.wait(visibleMessages.map(cacheMessage));
  }

  Future<void> _sweepEncryptedMessages(int localId) async {
    try {
      final messages = await _localChatRepo.getMessagesForChat(localId);
      final List<MessagesCompanion> companionsToUpdate = [];
      final cryptoService = context.read<CryptoService>();

      for (final m in messages) {
        bool needsUpdate = false;
        String? newTextContent = m.textContent;
        String? newReplyText = m.replyText;

        if (cryptoService.isEncryptedMessage(m.textContent)) {
          final decrypted = await cryptoService.decryptChatMessage(
              m.textContent, widget.chat.id);
          if (decrypted != null && decrypted != m.textContent) {
            newTextContent = decrypted;
            needsUpdate = true;
          }
        }

        if (m.replyText != null &&
            cryptoService.isEncryptedMessage(m.replyText!)) {
          final decryptedReply = await cryptoService.decryptChatMessage(
              m.replyText!, widget.chat.id);
          if (decryptedReply != null && decryptedReply != m.replyText) {
            newReplyText = decryptedReply;
            needsUpdate = true;
          }
        }

        if (needsUpdate) {
          companionsToUpdate.add(MessagesCompanion(
            id: Value(m.id),
            serverMessageId: Value(m.serverMessageId),
            chatId: Value(m.chatId),
            senderId: Value(m.senderId),
            textContent: Value(newTextContent),
            fileUrl: Value(m.fileUrl),
            isRead: Value(m.isRead),
            timestamp: Value(m.timestamp),
            messageType: Value(m.messageType),
            messageId: Value(m.messageId),
            completionStatus: Value(m.completionStatus),
            votesByOption: Value(m.votesByOption),
            userVotes: Value(m.userVotes),
            replyToId: Value(m.replyToId),
            replyText: Value(newReplyText),
            replyAuthorName: Value(m.replyAuthorName),
          ));
        }
      }

      if (companionsToUpdate.isNotEmpty) {
        await _localChatRepo.saveMessagesBatch(companionsToUpdate);
        debugPrint(
            'XSEC-2: Swept and decrypted ${companionsToUpdate.length} previously encrypted messages');
      }
    } catch (e) {
      debugPrint('XSEC-2: Error during encrypted messages sweep: $e');
    }
  }

  bool _parseIsRead(Map<String, dynamic> item, {bool isFavorites = false}) {
    if (isFavorites) {
      return true;
    }

    final isReadVal = item['is_read_by_recipient'] ??
        item['is_read'] ??
        item['isRead'] ??
        item['read'] ??
        item['is_read_by_current_user'];

    if (isReadVal == true ||
        isReadVal == 1 ||
        isReadVal == 'true' ||
        isReadVal == '1') {
      return true;
    }

    final status = item['status']?.toString().toLowerCase();
    if (status == 'read' || status == 'seen') {
      return true;
    }

    final readAt = item['read_at'] ?? item['readAt'] ?? item['read_time'];
    if (readAt != null &&
        readAt.toString().isNotEmpty &&
        readAt.toString() != 'null') {
      return true;
    }

    final readBy = item['read_by'] ?? item['readBy'] ?? item['readers'];
    if (readBy is List && readBy.isNotEmpty) {
      return true;
    }
    return false;
  }

  void _markChatAsRead() async {
    final localId = _localChatId;
    if (localId != null) {
      await _localChatRepo.markMessagesAsReadInDb(localId);
      if (mounted) {
        setState(() {});
      }
    }
    _chatService.markMessagesAsRead(widget.chat.id);
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser != null) {
      XaneoGrpcService().markAsRead(widget.chat.id, currentUser.id.toString());
    }
    _chatWebSocketService.send({
      'type': 'mark_read',
      'chat_id': widget.chat.id,
    });
  }

  String? _parseFileInfo(Map<String, dynamic> item, String? decrypted) {
    if ((item['message_type'] == 'call' || item['type'] == 'call') &&
        item['message_data'] != null) {
      return jsonEncode(item['message_data']);
    }
    // 1. Check if it's already inside decrypted text (polls/todos or file info JSON)
    final hasServerFile = (item['attached_file_id'] != null &&
            item['attached_file_id'].toString().isNotEmpty) ||
        (item['file_id'] != null && item['file_id'].toString().isNotEmpty) ||
        (item['file_url'] != null && item['file_url'].toString().isNotEmpty);
    if (hasServerFile &&
        decrypted != null &&
        decrypted.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(decrypted);
        if (parsed is Map &&
            (parsed['type'] == 'file' ||
                parsed['type'] == 'audio' ||
                parsed['type'] == 'music' ||
                parsed['type'] == 'voice' ||
                parsed['type'] == 'video' ||
                parsed['type'] == 'image' ||
                parsed['type'] == 'video_message') &&
            parsed['file_id'] != null &&
            parsed['file_id'].toString().isNotEmpty) {
          return jsonEncode(audioPayloadWithMetadata(
            Map<String, dynamic>.from(parsed),
            item,
          ));
        }
      } catch (_) {}
    }

    // 2. Check if we have multiple images (collage)
    final imagesList = item['images'];
    if (imagesList is List && imagesList.isNotEmpty) {
      if (imagesList.length > 1) {
        final List<Map<String, dynamic>> files = [];
        for (final img in imagesList) {
          if (img is Map) {
            final fId = img['file_id']?.toString();
            if (fId != null && fId.isNotEmpty) {
              final fName = img['name']?.toString() ??
                  img['file_name']?.toString() ??
                  'file';
              final fSize =
                  img['size'] as int? ?? img['file_size'] as int? ?? 0;
              final fType = img['file_type']?.toString() ??
                  img['type']?.toString() ??
                  img['mime_type']?.toString() ??
                  'image/jpeg';
              String fUrl =
                  img['url']?.toString() ?? img['file_url']?.toString() ?? '';
              if (fUrl.isEmpty) {
                fUrl = '/api/files/download/$fId/';
              }
              files.add({
                'file_id': fId,
                'file_name': fName,
                'file_size': fSize,
                'file_type': fType,
                'mime_type': fType,
                'file_url': fUrl,
                'blur_hash': img['blur_hash']?.toString(),
              });
            }
          }
        }
        if (files.isNotEmpty) {
          return jsonEncode({
            'type': 'collage',
            'files': files,
          });
        }
      } else {
        // Одиночный файл внутри списка images (отправленный сокета)
        final first = imagesList.first;
        if (first is Map) {
          final fId =
              first['file_id']?.toString() ?? item['file_id']?.toString();
          if (fId != null && fId.isNotEmpty) {
            final fName = first['name']?.toString() ??
                first['file_name']?.toString() ??
                'file';
            final fSize =
                first['size'] as int? ?? first['file_size'] as int? ?? 0;
            final fType = first['file_type']?.toString() ??
                first['type']?.toString() ??
                first['mime_type']?.toString() ??
                'application/octet-stream';
            String fUrl =
                first['url']?.toString() ?? first['file_url']?.toString() ?? '';
            if (fUrl.isEmpty) {
              fUrl = '/api/files/download/$fId/';
            }
            final lowerName = fName.toLowerCase();
            String detectedType = 'file';
            if (fType == 'document') {
              detectedType = 'file';
            } else if (fType == 'audio' ||
                fType == 'music' ||
                fType.startsWith('audio/') ||
                lowerName.endsWith('.mp3') ||
                lowerName.endsWith('.wav') ||
                lowerName.endsWith('.ogg') ||
                lowerName.endsWith('.m4a') ||
                lowerName.endsWith('.flac') ||
                lowerName.endsWith('.aac') ||
                lowerName.endsWith('.wma') ||
                lowerName.endsWith('.opus') ||
                lowerName.endsWith('.aiff') ||
                lowerName.endsWith('.alac')) {
              detectedType = 'audio';
            } else if (fType == 'video' ||
                fType.startsWith('video/') ||
                lowerName.endsWith('.mp4') ||
                lowerName.endsWith('.mov') ||
                lowerName.endsWith('.avi') ||
                lowerName.endsWith('.mkv') ||
                lowerName.endsWith('.webm')) {
              detectedType = 'video';
            } else if (fType == 'image' ||
                fType.startsWith('image/') ||
                lowerName.endsWith('.jpg') ||
                lowerName.endsWith('.jpeg') ||
                lowerName.endsWith('.png') ||
                lowerName.endsWith('.gif') ||
                lowerName.endsWith('.webp')) {
              detectedType = 'image';
            }
            return jsonEncode({
              'type': detectedType,
              'file_id': fId,
              'file_name': fName,
              'file_size': fSize,
              'mime_type': fType,
              'file_url': fUrl,
            });
          }
        }
      }
    }

    // 3. Check for single attached file
    Map<String, dynamic>? attachedDict;
    if (item['attached_file'] is Map) {
      attachedDict = Map<String, dynamic>.from(item['attached_file']);
    } else if (item['file'] is Map) {
      attachedDict = Map<String, dynamic>.from(item['file']);
    }

    final fileId = item['attached_file_id']?.toString() ??
        item['file_id']?.toString() ??
        attachedDict?['file_id']?.toString() ??
        attachedDict?['id']?.toString();

    if (fileId != null && fileId.isNotEmpty) {
      final fileName = item['attached_file_name']?.toString() ??
          item['file_name']?.toString() ??
          attachedDict?['original_filename']?.toString() ??
          attachedDict?['file_name']?.toString() ??
          attachedDict?['name']?.toString() ??
          'file';
      final fileSize = item['attached_file_size'] as int? ??
          item['file_size'] as int? ??
          attachedDict?['file_size'] as int? ??
          attachedDict?['size'] as int? ??
          0;
      final fileType = item['attached_file_kind']?.toString() ??
          item['file_type']?.toString() ??
          attachedDict?['file_type']?.toString() ??
          item['attached_file_type']?.toString() ??
          item['mime_type']?.toString() ??
          attachedDict?['mime_type']?.toString() ??
          'application/octet-stream';
      String fileUrlSuffix = item['attached_file_url']?.toString() ??
          item['file_url']?.toString() ??
          attachedDict?['file_url']?.toString() ??
          attachedDict?['url']?.toString() ??
          '';
      if (fileUrlSuffix.isEmpty) {
        fileUrlSuffix = '/api/files/download/$fileId/';
      }

      final lowerName = fileName.toLowerCase();
      String detectedType = 'file';
      if (fileType == 'document') {
        detectedType = 'file';
      } else if (fileType == 'audio' ||
          fileType == 'music' ||
          fileType.startsWith('audio/') ||
          lowerName.endsWith('.mp3') ||
          lowerName.endsWith('.wav') ||
          lowerName.endsWith('.ogg') ||
          lowerName.endsWith('.m4a') ||
          lowerName.endsWith('.flac') ||
          lowerName.endsWith('.aac') ||
          lowerName.endsWith('.wma') ||
          lowerName.endsWith('.opus') ||
          lowerName.endsWith('.aiff') ||
          lowerName.endsWith('.alac')) {
        detectedType = 'audio';
      } else if (fileType == 'video' ||
          fileType.startsWith('video/') ||
          lowerName.endsWith('.mp4') ||
          lowerName.endsWith('.mov') ||
          lowerName.endsWith('.avi') ||
          lowerName.endsWith('.mkv') ||
          lowerName.endsWith('.webm')) {
        detectedType = 'video';
      } else if (fileType == 'image' ||
          fileType.startsWith('image/') ||
          lowerName.endsWith('.jpg') ||
          lowerName.endsWith('.jpeg') ||
          lowerName.endsWith('.png') ||
          lowerName.endsWith('.gif') ||
          lowerName.endsWith('.webp')) {
        detectedType = 'image';
      }

      return jsonEncode(audioPayloadWithMetadata({
        'type': detectedType,
        'file_id': fileId,
        'file_name': fileName,
        'file_size': fileSize,
        'mime_type': fileType,
        'file_url': fileUrlSuffix,
      }, item, attachedDict));
    }

    return null;
  }

  String? _mergeFileInfoWithCache(String? fresh, String? cached) {
    if (fresh == null || fresh.isEmpty) return cached;
    if (cached == null || cached.isEmpty) return fresh;

    try {
      final freshDecoded = jsonDecode(fresh);
      final cachedDecoded = jsonDecode(cached);
      if (freshDecoded is! Map || cachedDecoded is! Map) return fresh;

      final merged = Map<String, dynamic>.from(freshDecoded);
      if (cachedDecoded['local_path'] != null) {
        merged['local_path'] = cachedDecoded['local_path'];
      }

      final freshFiles = merged['files'];
      final cachedFiles = cachedDecoded['files'];
      if (freshFiles is List && cachedFiles is List) {
        merged['files'] = List.generate(freshFiles.length, (index) {
          final freshFile = freshFiles[index];
          if (freshFile is! Map) return freshFile;
          final file = Map<String, dynamic>.from(freshFile);
          if (index < cachedFiles.length && cachedFiles[index] is Map) {
            final cachedFile = cachedFiles[index] as Map;
            if (cachedFile['local_path'] != null) {
              file['local_path'] = cachedFile['local_path'];
            }
          }
          return file;
        });
      }
      return jsonEncode(merged);
    } catch (_) {
      return fresh;
    }
  }

  Future<void> _syncLatestMessages() async {
    final localId = _localChatId;
    if (localId == null) return;

    try {
      final cryptoService = context.read<CryptoService>();
      final response = await _chatService.getEncryptedMessages(
        widget.chat.id,
        limit: 20,
        offset: 0,
      );

      if (response != null) {
        final results = response['results'] as List<dynamic>? ?? [];
        if (results.isEmpty) return;

        final List<MessagesCompanion> companions = [];
        final msgIds = results
            .map((item) => item['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList();

        final existingMessages =
            await _localChatRepo.getMessagesByServerIds(msgIds);
        final existingMap = {
          for (final m in existingMessages) m.serverMessageId: m
        };

        int newMessagesCount = 0;
        for (final item in results) {
          _cacheUserProfileFromMap(Map<String, dynamic>.from(item));
          final msgId = item['id']?.toString() ?? '';
          if (msgId.isNotEmpty) {
            if (!existingMap.containsKey(msgId)) {
              newMessagesCount++;
            }
            if (item['reactions'] != null && item['reactions'] is List) {
              _messageReactions[msgId] = List<dynamic>.from(item['reactions']);
            }
          }
          final senderId = item['author_username']?.toString() ?? 'unknown';
          final encryptedText = item['encrypted_text']?.toString() ?? '';
          final timestamp =
              _parseDateTime(item['created_at']) ?? DateTime.now();

          String? decrypted;
          String? existingFileUrl;
          if (existingMap.containsKey(msgId)) {
            final existingMsg = existingMap[msgId]!;
            final existingText = existingMsg.textContent;
            existingFileUrl = existingMsg.fileUrl;
            if (cryptoService.isEncryptedMessage(existingText) &&
                encryptedText.isNotEmpty) {
              decrypted = await cryptoService.decryptChatMessage(
                  encryptedText, widget.chat.id);
              await Future.delayed(Duration.zero);
            } else {
              decrypted = existingText;
            }
          } else if (encryptedText.isNotEmpty) {
            decrypted = await cryptoService.decryptChatMessage(
                encryptedText, widget.chat.id);
            // Yield event loop to prevent UI stutter during heavy decryption loop
            await Future.delayed(Duration.zero);
          }

          final fileInfoJson = _mergeFileInfoWithCache(
            _parseFileInfo(Map<String, dynamic>.from(item), decrypted),
            existingFileUrl,
          );

          final messageType = item['message_type']?.toString() ??
              existingMap[msgId]?.messageType;
          final messageId = item['message_id']?.toString();
          final completionStatusVal = item['completion_status'] != null
              ? jsonEncode(item['completion_status'])
              : null;
          final votesByOptionVal = item['votes_by_option'] != null
              ? jsonEncode(item['votes_by_option'])
              : null;
          final itemMessageData = item['message_data'];
          final replyMarkupVal = (itemMessageData is Map &&
                  itemMessageData['reply_markup'] != null)
              ? jsonEncode(itemMessageData['reply_markup'])
              : null;

          final isServerRead = _parseIsRead(Map<String, dynamic>.from(item),
              isFavorites: widget.chat.isFavorites);
          final isReadFinal = isServerRead ||
              (existingMap.containsKey(msgId) && existingMap[msgId]!.isRead);
          final replyToIdVal = _parseReplyField(
              item['reply_to_id'] ?? item['reply_to_ref'] ?? item['reply_to']);
          final replyTextRaw = _parseReplyField(item['reply_text']);
          String? replyTextVal;
          if (replyTextRaw != null) {
            replyTextVal = await cryptoService.decryptChatMessage(
                    replyTextRaw, widget.chat.id) ??
                replyTextRaw;
          }
          final replyAuthorNameVal = _parseReplyField(
              item['reply_author_name'] ?? item['reply_author']);

          companions.add(
            MessagesCompanion(
              serverMessageId: Value(msgId),
              chatId: Value(localId),
              senderId: Value(senderId),
              textContent: Value(decrypted ?? encryptedText),
              timestamp: Value(timestamp),
              fileUrl: Value(fileInfoJson),
              messageType: Value(messageType),
              messageId: Value(messageId),
              completionStatus: Value(completionStatusVal),
              votesByOption: Value(votesByOptionVal),
              isRead: Value(isReadFinal),
              replyToId: Value(replyToIdVal),
              replyText: Value(replyTextVal),
              replyAuthorName: Value(replyAuthorNameVal),
              replyMarkup: Value(replyMarkupVal),
            ),
          );
        }

        if (companions.isNotEmpty) {
          await _localChatRepo.saveMessagesBatch(companions);
        }

        if (mounted) {
          setState(() {
            if (newMessagesCount > 0) {
              _limit += newMessagesCount;
              _updateStream();
            }
          });
          _saveCachedReactions();
        }
      }
    } catch (e) {
      debugPrint('Error syncing latest messages: $e');
    }
  }

  double _estimateMessageHeight(Message msg) {
    double height = 7.0 +
        3.0 +
        14.0 +
        5.0; // vertical padding/margins + time row + safety margin

    if (msg.textContent.isNotEmpty && !msg.textContent.startsWith('{')) {
      final textLength = msg.textContent.length;
      final lines = (textLength / 32).ceil();
      height += lines * 19.0;
    }

    if (msg.fileUrl != null && msg.fileUrl!.isNotEmpty) {
      try {
        final fileData = jsonDecode(msg.fileUrl!);
        if (fileData is Map) {
          final type = fileData['type'];
          if (type == 'collage') {
            final filesList = fileData['files'] as List?;
            final fileCount = filesList?.length ?? 0;
            if (fileCount > 0) {
              height += ((fileCount / 2).ceil() * 120.0).clamp(120.0, 360.0);
            }
          } else if (type == 'video_message') {
            height += 170.0;
          } else if (type == 'voice') {
            height += 48.0;
          } else {
            final mime = (fileData['mime_type'] ?? '').toString().toLowerCase();
            final fileName =
                (fileData['file_name'] ?? '').toString().toLowerCase();
            final isImage = mime.startsWith('image/') ||
                fileName.endsWith('.jpg') ||
                fileName.endsWith('.jpeg') ||
                fileName.endsWith('.png') ||
                fileName.endsWith('.gif') ||
                fileName.endsWith('.webp');
            final isVideo = mime.startsWith('video/') ||
                fileName.endsWith('.mp4') ||
                fileName.endsWith('.mov') ||
                fileName.endsWith('.avi');

            if (isImage || isVideo) {
              height += 200.0;
            } else {
              height += 68.0;
            }
          }
        }
      } catch (_) {}
    } else if (msg.messageType == 'poll') {
      height += 220.0;
    } else if (msg.messageType == 'todo_list') {
      height += 200.0;
    }

    return height;
  }

  double _calculateScrollOffsetForIndex(int targetIndex) {
    double offset = 16.0; // bottom padding
    for (int i = 0; i < targetIndex; i++) {
      if (i >= _loadedMessages.length) break;
      offset += _estimateMessageHeight(_loadedMessages[i]);

      // Add estimated height of date separator (approx.loc_50.0 pixels including padding and margins)
      bool hasDateSeparator = false;
      if (i == _loadedMessages.length - 1) {
        hasDateSeparator = true;
      } else {
        final currentMsg = _loadedMessages[i];
        final nextMsg =
            _loadedMessages[i + 1]; // visually above currentMsg (older)
        if (currentMsg.timestamp.year != nextMsg.timestamp.year ||
            currentMsg.timestamp.month != nextMsg.timestamp.month ||
            currentMsg.timestamp.day != nextMsg.timestamp.day) {
          hasDateSeparator = true;
        }
      }
      if (hasDateSeparator) {
        offset += 50.0;
      }
    }
    return offset;
  }

  String _formatDateSeparator(DateTime dt) {
    dt = dt.toLocal();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(dt.year, dt.month, dt.day);

    if (targetDate == today) {
      return l10n?.today ?? 'Today';
    } else if (targetDate == yesterday) {
      return l10n?.yesterday ?? 'Yesterday';
    } else {
      final months = [
        l10n?.monthJan ?? 'January',
        l10n?.monthFeb ?? 'February',
        l10n?.monthMar ?? 'March',
        l10n?.monthApr ?? 'April',
        l10n?.monthMay ?? 'May',
        l10n?.monthJun ?? 'June',
        l10n?.monthJul ?? 'July',
        l10n?.monthAug ?? 'August',
        l10n?.monthSep ?? 'September',
        l10n?.monthOct ?? 'October',
        l10n?.monthNov ?? 'November',
        l10n?.monthDec ?? 'December',
      ];
      final monthStr = months[dt.month - 1];
      if (dt.year == now.year) {
        return '${dt.day} $monthStr';
      } else {
        return '${dt.day} $monthStr ${dt.year}';
      }
    }
  }

  Widget _buildDateSeparator(DateTime dt) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 0.8,
          ),
        ),
        child: Text(
          _formatDateSeparator(dt),
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.62)
                : Colors.black.withValues(alpha: 0.58),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: AppStyles.fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingDateBadge(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: const BoxDecoration(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.xaneoOverlay(0.16),
                context.xaneoOverlay(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.xaneoDivider,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: context.xaneoTextPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFamily: AppStyles.fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  void _updateFloatingDate() {
    if (!mounted || _loadedMessages.isEmpty) {
      if (_floatingDateText != null || _showFloatingDate) {
        setState(() {
          _floatingDateText = null;
          _showFloatingDate = false;
        });
      }
      return;
    }

    final rootRenderObject = _messageListKey.currentContext?.findRenderObject();
    if (rootRenderObject == null) return;

    RenderSliverMultiBoxAdaptor? sliver;
    void findSliver(RenderObject object) {
      if (object is RenderSliverMultiBoxAdaptor) {
        sliver = object;
        return;
      }
      object.visitChildren(findSliver);
    }

    findSliver(rootRenderObject);
    if (sliver == null) return;

    RenderBox? viewportBox;
    RenderObject? parent = sliver;
    while (parent != null) {
      if (parent is RenderBox && parent is! RenderSliver) {
        viewportBox = parent;
        break;
      }
      parent = parent.parent;
    }
    viewportBox ??= rootRenderObject is RenderBox ? rootRenderObject : null;
    if (viewportBox == null || !viewportBox.hasSize) return;

    final visibleTop = MediaQuery.paddingOf(context).top + 64;
    final viewportHeight = viewportBox.size.height;
    int? topVisibleIndex;
    var minTop = double.infinity;
    var isInlineDividerNearTop = false;

    RenderBox? child = sliver!.firstChild;
    while (child != null) {
      final parentData = child.parentData as SliverMultiBoxAdaptorParentData?;
      final index = parentData?.index;
      if (index != null && index >= 0 && index < _loadedMessages.length) {
        try {
          final offset = child.localToGlobal(
            Offset.zero,
            ancestor: viewportBox,
          );
          final childTop = offset.dy;
          final childBottom = childTop + child.size.height;

          if (childBottom > visibleTop && childTop < viewportHeight) {
            if (childTop < minTop && childBottom > visibleTop + 10) {
              minTop = childTop;
              topVisibleIndex = index;
            }

            final hasDivider = index == _loadedMessages.length - 1 ||
                !_isSameMessageDay(
                  _loadedMessages[index].timestamp,
                  _loadedMessages[index + 1].timestamp,
                );
            if (hasDivider &&
                childTop >= visibleTop - 20 &&
                childTop <= visibleTop + 12) {
              isInlineDividerNearTop = true;
            }
          }
        } catch (_) {}
      }
      child = sliver!.childAfter(child);
    }

    final newDateText = topVisibleIndex == null
        ? null
        : _formatDateSeparator(_loadedMessages[topVisibleIndex].timestamp);
    final shouldShow = newDateText != null && !isInlineDividerNearTop;

    if (newDateText != _floatingDateText || shouldShow != _showFloatingDate) {
      setState(() {
        _floatingDateText = newDateText;
        _showFloatingDate = shouldShow;
      });
    }
  }

  void _scheduleFloatingDateUpdate() {
    if (_floatingDateUpdateScheduled || !mounted) return;
    _floatingDateUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _floatingDateUpdateScheduled = false;
      if (!mounted) return;

      // A bottom sheet keeps the chat route alive underneath its transition.
      // Avoid walking the sliver render tree while that transition is active;
      // the badge will be refreshed by the next scroll or message emission.
      if (ModalRoute.of(context)?.isCurrent != true) return;
      _updateFloatingDate();
    });
  }

  bool _isSameMessageDay(DateTime first, DateTime second) {
    final a = first.toLocal();
    final b = second.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Element? _findElementByKey(Key key) {
    Element? foundElement;
    void visitor(Element element) {
      if (foundElement != null) return;
      if (element.widget.key == key) {
        foundElement = element;
        return;
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);
    return foundElement;
  }

  Future<void> _scrollToMessage(String msgId) async {
    final index =
        await _localChatRepo.getMessageIndexByServerId(widget.chat.id, msgId);
    debugPrint(
        '[_scrollToMessage] Target msgId: $msgId, resolved index in SQLite: $index');
    if (index != null && index != -1) {
      if (index >= _limit) {
        setState(() {
          _limit = index + 15;
          _updateStream();
        });

        int retries = 0;
        while (retries < 20 &&
            !_loadedMessages.any((m) => m.serverMessageId == msgId)) {
          await Future.delayed(const Duration(milliseconds: 100));
          retries++;
        }
        await Future.delayed(const Duration(milliseconds: 150));
      }

      if (_loadedMessages.isEmpty) {
        debugPrint('[_scrollToMessage] Warning: _loadedMessages is empty!');
        return;
      }

      final actualIndex =
          _loadedMessages.indexWhere((m) => m.serverMessageId == msgId);
      debugPrint(
          '[_scrollToMessage] Index in active list: $actualIndex, loaded count: ${_loadedMessages.length}');
      if (actualIndex != -1) {
        setState(() {
          _highlightedMessageId = msgId;
        });

        // Iterative jump loop: maxScrollExtent grows lazily as ListView
        // builds more off-screen items, so a single jump from offset 0
        // usually lands short. We keep recalculating and jumping until
        // the target element actually appears in the widget tree.
        Element? element;
        final targetKey = ValueKey('msg_${_loadedMessages[actualIndex].id}');
        final totalCount = _loadedMessages.length;
        final ratio = actualIndex / totalCount;

        for (int attempt = 0; attempt < 5; attempt++) {
          if (!_scrollController.hasClients) break;

          final maxScroll = _scrollController.position.maxScrollExtent;
          final targetOffset = (ratio * maxScroll).clamp(0.0, maxScroll);

          debugPrint(
              '[_scrollToMessage] Attempt ${attempt + 1}: jumpTo $targetOffset (maxScroll: $maxScroll)');
          _scrollController.jumpTo(targetOffset);

          // Let Flutter build the newly visible items
          await Future.delayed(const Duration(milliseconds: 80));

          element = _findElementByKey(targetKey);
          if (element != null) break;
        }

        // Final centering with smooth animation
        if (element != null) {
          debugPrint('[_scrollToMessage] Found element, centering...');
          await Scrollable.ensureVisible(
            element,
            alignment: 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        } else {
          debugPrint(
              '[_scrollToMessage] Warning: Element not found after all attempts');
        }

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && _highlightedMessageId == msgId) {
            setState(() {
              _highlightedMessageId = null;
            });
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text((AppLocalizations.of(context)
                    ?.soobschenieNahoditsyaVysheVIstorii_dc90 ??
                'Fallback'))),
      );
    }
  }

  /// Helper: only recreates the stream when needed, avoiding redundant StreamBuilder resets.
  void _updateStream() {
    _messagesStream = _localChatRepo.watchMessagesForServerChat(
      widget.chat.id,
      limit: _limit,
    );
  }

  Future<void> _loadMoreMessages() async {
    if (_isHistoryLoading) return;

    final localId = _localChatId;
    if (localId == null) return;

    // Set loading flag without rebuilding stream
    setState(() => _isHistoryLoading = true);

    try {
      final localCount = await _localChatRepo.getMessageCount(localId);

      // If we have more messages locally than what we are currently showing, just show them
      if (localCount > _limit) {
        if (mounted) {
          setState(() {
            _limit = (_limit + 20).clamp(0, localCount);
            _updateStream();
            _isHistoryLoading = false;
          });
        }
        return;
      }

      // If we don't have more messages locally, fetch from the server
      if (!_hasMoreMessages) {
        if (mounted) setState(() => _isHistoryLoading = false);
        return;
      }

      final cryptoService = context.read<CryptoService>();
      final response = await _chatService.getEncryptedMessages(
        widget.chat.id,
        limit: 20,
        offset: localCount,
      );

      if (response != null) {
        final results = response['results'] as List<dynamic>? ?? [];
        if (results.isEmpty) {
          if (mounted) {
            setState(() {
              _hasMoreMessages = false;
              _isHistoryLoading = false;
            });
          }
          return;
        }

        final List<MessagesCompanion> companions = [];
        final msgIds = results
            .map((item) => item['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList();

        final existingMessages =
            await _localChatRepo.getMessagesByServerIds(msgIds);
        final existingMap = {
          for (final m in existingMessages) m.serverMessageId: m
        };

        for (final item in results) {
          _cacheUserProfileFromMap(Map<String, dynamic>.from(item));
          final msgId = item['id']?.toString() ?? '';
          if (msgId.isNotEmpty &&
              item['reactions'] != null &&
              item['reactions'] is List) {
            _messageReactions[msgId] = List<dynamic>.from(item['reactions']);
          }
          final senderId = item['author_username']?.toString() ?? 'unknown';
          final encryptedText = item['encrypted_text']?.toString() ?? '';
          final timestamp =
              _parseDateTime(item['created_at']) ?? DateTime.now();

          String? decrypted;
          String? existingFileUrl;
          if (existingMap.containsKey(msgId)) {
            final existingMsg = existingMap[msgId]!;
            final existingText = existingMsg.textContent;
            existingFileUrl = existingMsg.fileUrl;
            if (cryptoService.isEncryptedMessage(existingText) &&
                encryptedText.isNotEmpty) {
              decrypted = await cryptoService.decryptChatMessage(
                  encryptedText, widget.chat.id);
              await Future.delayed(Duration.zero);
            } else {
              decrypted = existingText;
            }
          } else if (encryptedText.isNotEmpty) {
            decrypted = await cryptoService.decryptChatMessage(
                encryptedText, widget.chat.id);
            // Yield event loop to prevent UI stutter during heavy decryption loop
            await Future.delayed(Duration.zero);
          }

          final fileInfoJson = _mergeFileInfoWithCache(
            _parseFileInfo(Map<String, dynamic>.from(item), decrypted),
            existingFileUrl,
          );

          final messageType = item['message_type']?.toString() ??
              existingMap[msgId]?.messageType;
          final messageId = item['message_id']?.toString();
          final completionStatusVal = item['completion_status'] != null
              ? jsonEncode(item['completion_status'])
              : null;
          final votesByOptionVal = item['votes_by_option'] != null
              ? jsonEncode(item['votes_by_option'])
              : null;
          final itemMessageData = item['message_data'];
          final replyMarkupVal = (itemMessageData is Map &&
                  itemMessageData['reply_markup'] != null)
              ? jsonEncode(itemMessageData['reply_markup'])
              : null;

          final isServerRead = _parseIsRead(Map<String, dynamic>.from(item),
              isFavorites: widget.chat.isFavorites);
          final isReadFinal = isServerRead ||
              (existingMap.containsKey(msgId) && existingMap[msgId]!.isRead);

          final replyToIdVal = _parseReplyField(
              item['reply_to_id'] ?? item['reply_to_ref'] ?? item['reply_to']);
          final replyTextRaw = _parseReplyField(item['reply_text']);
          String? replyTextVal;
          if (replyTextRaw != null) {
            replyTextVal = await cryptoService.decryptChatMessage(
                    replyTextRaw, widget.chat.id) ??
                replyTextRaw;
          }
          final replyAuthorNameVal = _parseReplyField(
              item['reply_author_name'] ?? item['reply_author']);

          companions.add(
            MessagesCompanion(
              serverMessageId: Value(msgId),
              chatId: Value(localId),
              senderId: Value(senderId),
              textContent: Value(decrypted ?? encryptedText),
              timestamp: Value(timestamp),
              fileUrl: Value(fileInfoJson),
              messageType: Value(messageType),
              messageId: Value(messageId),
              completionStatus: Value(completionStatusVal),
              votesByOption: Value(votesByOptionVal),
              isRead: Value(isReadFinal),
              replyToId: Value(replyToIdVal),
              replyText: Value(replyTextVal),
              replyAuthorName: Value(replyAuthorNameVal),
              replyMarkup: Value(replyMarkupVal),
            ),
          );
        }

        if (companions.isNotEmpty) {
          await _localChatRepo.saveMessagesBatch(companions);
        }

        if (mounted) {
          // Single setState: update limit + stream + hasMore + loading flag all at once
          setState(() {
            _limit = localCount + results.length;
            _updateStream();
            if (results.length < 20) _hasMoreMessages = false;
            _isHistoryLoading = false;
          });
          _saveCachedReactions();
        }
      } else {
        if (mounted) {
          setState(() {
            _hasMoreMessages = false;
            _isHistoryLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading message history: $e');
      if (mounted) setState(() => _isHistoryLoading = false);
    }
  }

  Future<void> _handleWsEvent(Map<String, dynamic> event) async {
    final type = event['type']?.toString();
    if (type == 'user_typing' || type == 'typing') {
      final userId =
          event['user_id']?.toString() ?? event['username']?.toString();
      if (userId != null && userId.isNotEmpty) {
        final eventIsTyping = event['is_typing'] == true;
        final action = event['action']?.toString() ?? 'typing';

        // 🟢 Игнорируем собственные события "печатает"
        final currentUser = context.read<AuthProvider>().user;
        final currentUserId = currentUser?.id.toString();
        final currentUsername = currentUser?.username;
        if ((currentUserId != null &&
                currentUserId.isNotEmpty &&
                userId == currentUserId) ||
            (currentUsername != null &&
                currentUsername.isNotEmpty &&
                event['username']?.toString() == currentUsername)) {
          return;
        }

        String getActionText(String? action) {
          switch (action) {
            case 'recording_voice':
              return (AppLocalizations.of(context)?.zapisyvaetGolosovoe_2a5c ??
                  'Fallback');
            case 'sending_photo':
              return (AppLocalizations.of(context)?.otpravlyaetFoto_67c1 ??
                  'Fallback');
            case 'sending_video':
              return (AppLocalizations.of(context)?.otpravlyaetVideo_ce80 ??
                  'Fallback');
            case 'sending_file':
              return (AppLocalizations.of(context)?.otpravlyaetFayl_5e88 ??
                  'Fallback');
            case 'typing':
            default:
              return (AppLocalizations.of(context)?.pechataet_812c ??
                  'Fallback');
          }
        }

        String getLottieAsset(String? action) {
          switch (action) {
            case 'recording_voice':
              return 'assets/animations/recording_voice.json';
            case 'sending_photo':
              return 'assets/animations/sending_photo.json';
            case 'sending_video':
              return 'assets/animations/sending_video.json';
            case 'sending_file':
              return 'assets/animations/sending_file.json';
            case 'typing':
            default:
              return 'assets/animations/typing.json';
          }
        }

        if (widget.chat.isPersonal) {
          final otherId = _otherUser?['id']?.toString();
          final otherUsername = _otherUser?['username']?.toString();
          if (userId == otherId ||
              event['username']?.toString() == otherUsername) {
            if (eventIsTyping) {
              setState(() {
                _typingText = getActionText(action);
                _activeLottiePath = getLottieAsset(action);
              });
              _typingTimer?.cancel();
              _typingTimer = Timer(const Duration(seconds: 5), () {
                if (mounted) {
                  setState(() {
                    _typingText = null;
                    _activeLottiePath = null;
                  });
                }
              });
            } else {
              setState(() {
                _typingText = null;
                _activeLottiePath = null;
              });
              _typingTimer?.cancel();
            }
          }
        } else {
          // Для групповых чатов
          if (eventIsTyping) {
            setState(() {
              _typingUsers[userId] = getActionText(action);
              _typingLottiePaths[userId] = getLottieAsset(action);
            });
            _typingTimers[userId]?.cancel();
            _typingTimers[userId] = Timer(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() {
                  _typingUsers.remove(userId);
                  _typingLottiePaths.remove(userId);
                });
              }
            });
          } else {
            setState(() {
              _typingUsers.remove(userId);
              _typingLottiePaths.remove(userId);
            });
            _typingTimers[userId]?.cancel();
          }
        }
        return;
      }

      if (type == 'user_status_update') {
        if (mounted && widget.chat.isPersonal && _otherUser != null) {
          final eventUserId = event['user_id']?.toString();
          final eventUsername = event['username']?.toString();
          final otherId = _otherUser!['id']?.toString();
          final otherUsername = _otherUser!['username']?.toString();

          if ((eventUserId != null && eventUserId == otherId) ||
              (eventUsername != null && eventUsername == otherUsername)) {
            setState(() {
              _otherUser!['is_online'] = event['is_online'];
              _otherUser!['online'] =
                  event['is_online']; // Sync both properties
              _otherUser!['last_seen'] = event['timestamp'];
            });
          }
        }
        return;
      }

      if (type == 'chat_user_status') {
        if (mounted) {
          setState(() {
            _otherUser ??= {};
            _otherUser!['online_count'] = event['online_count'];
          });
        }
        return;
      }
    }

    if (type == 'reaction_update') {
      final msgIdRaw = event['message_id'];
      final msgId =
          msgIdRaw is int ? msgIdRaw : int.tryParse(msgIdRaw?.toString() ?? '');
      final action = event['action']?.toString();
      final emoji = event['emoji']?.toString();
      final userIdRaw = event['user_id'];
      final userId = userIdRaw is int
          ? userIdRaw
          : int.tryParse(userIdRaw?.toString() ?? '');

      if (msgId != null && emoji != null && userId != null) {
        if (mounted) {
          setState(() {
            // Find the matching message in _loadedMessages by numeric server id
            final match = _loadedMessages.cast<Message?>().firstWhere(
              (m) {
                final parsed = int.tryParse(m!.serverMessageId) ?? m.id;
                return parsed == msgId;
              },
              orElse: () => null,
            );
            final key = match?.serverMessageId ?? msgId.toString();
            final reactions = List<dynamic>.from(_messageReactions[key] ?? []);

            reactions.removeWhere((r) {
              final rUserIdRaw = r['user_id'];
              final rUserId = rUserIdRaw is int
                  ? rUserIdRaw
                  : int.tryParse(rUserIdRaw?.toString() ?? '');
              return rUserId == userId &&
                  (action == 'remove' ? r['emoji'] == emoji : true);
            });

            if (action == 'add') {
              reactions.add({
                'user_id': userId,
                'user_username': event['user_username'] ?? '',
                'user_first_name': event['user_first_name'] ?? '',
                'user_avatar': event['user_avatar'] ?? '',
                'user_avatar_gradient': event['user_avatar_gradient'] ?? '',
                'emoji': emoji,
                'created_at':
                    event['timestamp'] ?? DateTime.now().toIso8601String(),
              });
            }
            _messageReactions[key] = reactions;
          });
          _saveCachedReactions();
        }
      }
      return;
    }

    if (type == 'messages_read' ||
        type == 'message_read' ||
        type == 'read_event' ||
        type == 'messages_marked_read' ||
        type == 'read_receipt') {
      final eventChatId =
          event['chat_id']?.toString() ?? event['chatId']?.toString();
      if (eventChatId == null || _areSameChat(eventChatId, widget.chat.id)) {
        final localId = _localChatId;
        if (localId != null) {
          final rawIds = event['message_ids'] ??
              event['ids'] ??
              event['message_id'] ??
              event['server_message_id'];
          List<String>? serverMessageIds;
          if (rawIds is List) {
            serverMessageIds = rawIds.map((e) => e.toString()).toList();
          } else if (rawIds != null) {
            serverMessageIds = [rawIds.toString()];
          }
          await _localChatRepo.markMessagesAsReadInDb(localId,
              serverMessageIds: serverMessageIds);
          if (mounted) {
            setState(() {});
          }
        }
      }
      return;
    }

    if (type == 'voice_message') {
      await _handleIncomingVoiceMessage(event);
      return;
    }

    if (type == 'video_message') {
      await _handleIncomingVideoMessage(event);
      return;
    }

    if (type != 'encrypted_message' &&
        type != 'poll_message' &&
        type != 'todo_list_message' &&
        type != 'file_message' &&
        type != 'file') {
      if (type == 'todo_completion_update') {
        await _handleTodoCompletionUpdate(event);
        return;
      }
      if (type == 'poll_vote_update') {
        await _handlePollVoteUpdate(event);
        return;
      }
      return;
    }

    final chatId = event['chat_id']?.toString();
    final encryptedText = event['encrypted_text']?.toString() ??
        event['encrypted_content']?.toString();

    if (chatId == null ||
        !_areSameChat(chatId, widget.chat.id) ||
        encryptedText == null) return;

    _cacheUserProfileFromMap(Map<String, dynamic>.from(event));

    final cryptoService = context.read<CryptoService>();
    final decrypted =
        await cryptoService.decryptChatMessage(encryptedText, widget.chat.id);

    final localId = _localChatId;
    if (localId != null) {
      final timestamp = _parseDateTime(event['created_at']) ?? DateTime.now();
      final senderId = event['author_username']?.toString() ??
          event['author_id']?.toString() ??
          event['sender_id']?.toString() ??
          event['creator_username']?.toString() ??
          event['creator_id']?.toString() ??
          'system';
      final msgId = event['id']?.toString() ??
          'ws_${DateTime.now().millisecondsSinceEpoch}';

      String? fileInfoJson =
          _parseFileInfo(Map<String, dynamic>.from(event), decrypted);

      String? messageType = event['message_type']?.toString();
      messageType = inferChatMessageType(event, fallback: messageType);
      if (messageType == null) {
        if (type == 'todo_list_message') messageType = 'todo_list';
        if (type == 'poll_message') messageType = 'poll';
      }
      final messageId = event['message_id']?.toString();
      final completionStatusVal = event['completion_status'] != null
          ? jsonEncode(event['completion_status'])
          : null;
      final votesByOptionVal = event['votes_by_option'] != null
          ? jsonEncode(event['votes_by_option'])
          : null;
      final eventMessageData = event['message_data'];
      final replyMarkupVal =
          (eventMessageData is Map && eventMessageData['reply_markup'] != null)
              ? jsonEncode(eventMessageData['reply_markup'])
              : null;

      final bool isAlreadyKnown = _initialMessageIds.contains(msgId) ||
          _animatedMessageIds.contains(msgId);
      final currentUser2 = context.read<AuthProvider>().user;
      final isOutgoing = senderId == currentUser2?.username ||
          senderId == currentUser2?.id?.toString();

      final replyToIdVal = _parseReplyField(
          event['reply_to_id'] ?? event['reply_to_ref'] ?? event['reply_to']);
      final replyTextRaw = _parseReplyField(event['reply_text']);
      String? replyTextVal;
      if (replyTextRaw != null) {
        replyTextVal = await cryptoService.decryptChatMessage(
                replyTextRaw, widget.chat.id) ??
            replyTextRaw;
      }
      final replyAuthorNameVal =
          _parseReplyField(event['reply_author_name'] ?? event['reply_author']);

      // A bot response can arrive while our optimistic message is still
      // pending. Only an echo authored by the current user may acknowledge it.
      if (isOutgoing && _pendingTextTempIds.isNotEmpty) {
        final tempId = _pendingTextTempIds.removeAt(0);
        String? finalFileUrl = fileInfoJson;
        String? finalMessageType = messageType;
        try {
          final existing =
              await _localChatRepo.getMessagesByServerIds([tempId]);
          if (existing.isNotEmpty && existing.first.fileUrl != null) {
            final oldParsed = jsonDecode(existing.first.fileUrl!);
            if (oldParsed is Map) {
              final newParsed =
                  finalFileUrl != null ? jsonDecode(finalFileUrl) : null;
              final Map<String, dynamic> merged = newParsed is Map
                  ? Map<String, dynamic>.from(newParsed)
                  : Map<String, dynamic>.from(oldParsed);
              if (oldParsed['local_path'] != null) {
                merged['local_path'] = oldParsed['local_path'];
              }
              final oldFiles = oldParsed['files'];
              final newFiles = merged['files'];
              if (oldFiles is List && newFiles is List) {
                merged['files'] = List.generate(newFiles.length, (index) {
                  final newFile = newFiles[index];
                  if (newFile is! Map) return newFile;
                  final file = Map<String, dynamic>.from(newFile);
                  if (index < oldFiles.length && oldFiles[index] is Map) {
                    final oldFile = oldFiles[index] as Map;
                    if (oldFile['local_path'] != null) {
                      file['local_path'] = oldFile['local_path'];
                    }
                  }
                  return file;
                });
              }
              if (oldParsed['type'] != null &&
                  (merged['type'] == null || merged['type'] == 'file')) {
                merged['type'] = oldParsed['type'];
              }
              finalFileUrl = jsonEncode(merged);
              if (existing.first.messageType != null &&
                  (finalMessageType == null || finalMessageType == 'file')) {
                finalMessageType = existing.first.messageType;
              }
            }
          }
        } catch (_) {}

        await _localChatRepo.updateMessageServerId(
          tempId,
          msgId,
          fileUrl: finalFileUrl,
          messageType: finalMessageType,
          timestamp: timestamp,
        );
        _messagesToAnimate.remove(tempId);
        _animatedMessageIds.add(msgId);
      } else {
        await _localChatRepo.saveMessage(
          MessagesCompanion(
            serverMessageId: Value(msgId),
            chatId: Value(localId),
            senderId: Value(senderId),
            textContent: Value(decrypted ?? encryptedText),
            timestamp: Value(timestamp),
            fileUrl: Value(fileInfoJson),
            messageType: Value(messageType),
            messageId: Value(messageId),
            completionStatus: Value(completionStatusVal),
            votesByOption: Value(votesByOptionVal),
            isRead: Value(isOutgoing
                ? false
                : _parseIsRead(Map<String, dynamic>.from(event),
                    isFavorites: widget.chat.isFavorites)),
            replyToId: Value(replyToIdVal),
            replyText: Value(replyTextVal),
            replyAuthorName: Value(replyAuthorNameVal),
            replyMarkup: Value(replyMarkupVal),
          ),
        );
      }

      if (!isAlreadyKnown) {
        _messagesToAnimate.add(msgId);
        if (mounted) {
          setState(() {
            _limit++;
            _updateStream();
          });
        }
      }

      // Mark the message as read on the server only for incoming messages
      final currentUser = context.read<AuthProvider>().user;
      final isMyMessage = senderId == currentUser?.username ||
          senderId == currentUser?.id?.toString();
      if (!isMyMessage) {
        _markChatAsRead();
      }

      // Update local chat preview
      final updatedChat = ChatModel(
        id: widget.chat.id,
        name: widget.chat.name,
        avatar: widget.chat.avatar,
        avatarGradient: widget.chat.avatarGradient,
        lastMessage: decrypted ?? encryptedText,
        lastMessageTime: timestamp,
        unreadCount: 0,
        isGroup: widget.chat.isGroup,
        isChannel: widget.chat.isChannel,
        isPersonal: widget.chat.isPersonal,
        isFavorites: widget.chat.isFavorites,
        otherUser: _otherUser,
        isEncrypted: decrypted == null,
        isArchived: widget.chat.isArchived,
        archivedAt: widget.chat.archivedAt,
        lastMessageType: messageType,
      );
      await _localChatRepo.saveChat(updatedChat);
    }
  }

  Future<void> _handleIncomingVoiceMessage(Map<String, dynamic> event) async {
    final chatId = event['chat_id']?.toString();
    if (chatId == null || !_areSameChat(chatId, widget.chat.id)) return;

    final localId = _localChatId;
    if (localId == null) return;

    final fileId = event['file_id']?.toString();
    if (fileId == null) return;

    final timestamp = _parseDateTime(event['created_at']) ?? DateTime.now();
    final senderId = event['author_username']?.toString() ??
        event['author_id']?.toString() ??
        event['sender_id']?.toString() ??
        'system';
    final msgId = event['id']?.toString() ??
        event['message_id']?.toString() ??
        'ws_${timestamp.millisecondsSinceEpoch}';

    final duration = event['duration'] is num
        ? (event['duration'] as num).toInt()
        : int.tryParse(event['duration']?.toString() ?? '') ?? 0;
    final mimeType = event['mime_type']?.toString() ?? 'audio/wav';

    // Сверка с оптимистичной отправкой: если это эхо нашего же ГС,
    // схлопываем temp-сообщение в реальное (без дубля и без новой анимации),
    // сохраняя local_path — чтобы наше сообщение проигрывалось из локального файла.
    final String? tempId = _pendingVoiceTempIds.remove(fileId);
    final String? localPath = _pendingVoiceLocalPaths.remove(fileId);
    final bool isOwnEcho = tempId != null;

    if (isOwnEcho) {
      await _localChatRepo.deleteMessageByServerId(tempId);
      _messagesToAnimate.remove(tempId);
      _animatedMessageIds
          .add(msgId); // считаем уже "проявленным" — не анимируем заново
    }

    // Шаблон голосового: плеер сам подгрузит и расшифрует файл по file_id.
    // Для своего сообщения добавляем local_path для мгновенного проигрывания.
    final fileInfoJson = jsonEncode({
      'type': 'voice',
      'file_id': fileId,
      'duration': duration,
      'mime_type': mimeType,
      if (localPath != null) 'local_path': localPath,
    });

    final bool isAlreadyKnown = isOwnEcho ||
        _initialMessageIds.contains(msgId) ||
        _animatedMessageIds.contains(msgId);

    await _localChatRepo.saveMessage(
      MessagesCompanion(
        serverMessageId: Value(msgId),
        chatId: Value(localId),
        senderId: Value(senderId),
        textContent: Value(fileInfoJson),
        timestamp: Value(timestamp),
        fileUrl: Value(fileInfoJson),
        messageType: const Value('voice'),
      ),
    );

    if (!isAlreadyKnown) {
      _messagesToAnimate.add(msgId);
    }
    if (mounted) {
      setState(() {
        if (!isAlreadyKnown) _limit++;
        _updateStream();
      });
    }

    _markChatAsRead();

    final updatedChat = ChatModel(
      id: widget.chat.id,
      name: widget.chat.name,
      avatar: widget.chat.avatar,
      avatarGradient: widget.chat.avatarGradient,
      lastMessage: (AppLocalizations.of(context)?.golosovoeSoobschenie_4a85 ??
          'Fallback'),
      lastMessageTime: timestamp,
      unreadCount: 0,
      isGroup: widget.chat.isGroup,
      isChannel: widget.chat.isChannel,
      isPersonal: widget.chat.isPersonal,
      isFavorites: widget.chat.isFavorites,
      otherUser: _otherUser,
      isEncrypted: false,
      isArchived: widget.chat.isArchived,
      archivedAt: widget.chat.archivedAt,
      lastMessageType: 'voice',
    );
    await _localChatRepo.saveChat(updatedChat);
  }

  Future<void> _handleIncomingVideoMessage(Map<String, dynamic> event) async {
    final chatId = event['chat_id']?.toString();
    if (chatId == null || !_areSameChat(chatId, widget.chat.id)) return;

    final localId = _localChatId;
    if (localId == null) return;

    final fileId = event['file_id']?.toString();
    if (fileId == null) return;

    final timestamp = _parseDateTime(event['created_at']) ?? DateTime.now();
    final senderId = event['author_username']?.toString() ??
        event['author_id']?.toString() ??
        event['sender_id']?.toString() ??
        'system';
    final msgId = event['id']?.toString() ??
        event['message_id']?.toString() ??
        'ws_${timestamp.millisecondsSinceEpoch}';

    final duration = event['duration'] is num
        ? (event['duration'] as num).toDouble()
        : double.tryParse(event['duration']?.toString() ?? '') ?? 0.0;

    final String? tempId = _pendingVideoTempIds.remove(fileId);
    final String? localPath = _pendingVideoLocalPaths.remove(fileId);
    final bool isOwnEcho = tempId != null;

    if (isOwnEcho) {
      await _localChatRepo.deleteMessageByServerId(tempId);
      _messagesToAnimate.remove(tempId);
      _animatedMessageIds.add(msgId);
    }

    final fileInfoJson = jsonEncode({
      'type': 'video_message',
      'file_id': fileId,
      'duration': duration,
      'mime_type': 'video/mp4',
      if (localPath != null) 'local_path': localPath,
    });

    final bool isAlreadyKnown = isOwnEcho ||
        _initialMessageIds.contains(msgId) ||
        _animatedMessageIds.contains(msgId);

    await _localChatRepo.saveMessage(
      MessagesCompanion(
        serverMessageId: Value(msgId),
        chatId: Value(localId),
        senderId: Value(senderId),
        textContent: Value(fileInfoJson),
        timestamp: Value(timestamp),
        fileUrl: Value(fileInfoJson),
        messageType: const Value('video_message'),
        messageId: Value(msgId),
      ),
    );

    if (!isAlreadyKnown) {
      _messagesToAnimate.add(msgId);
    }
    if (mounted) {
      setState(() {
        if (!isAlreadyKnown) _limit++;
        _updateStream();
      });
    }

    _markChatAsRead();

    final updatedChat = ChatModel(
      id: widget.chat.id,
      name: widget.chat.name,
      avatar: widget.chat.avatar,
      avatarGradient: widget.chat.avatarGradient,
      lastMessage:
          (AppLocalizations.of(context)?.videosoobschenie_57f1 ?? 'Fallback'),
      lastMessageTime: timestamp,
      unreadCount: 0,
      isGroup: widget.chat.isGroup,
      isChannel: widget.chat.isChannel,
      isPersonal: widget.chat.isPersonal,
      isFavorites: widget.chat.isFavorites,
      otherUser: _otherUser,
      isEncrypted: false,
      isArchived: widget.chat.isArchived,
      archivedAt: widget.chat.archivedAt,
      lastMessageType: 'video_message',
    );
    await _localChatRepo.saveChat(updatedChat);
  }

  Future<String?> _insertOptimisticVideoMessage(
      String path, double duration) async {
    final localId = _localChatId;
    if (localId == null) return null;

    final currentUser = context.read<AuthProvider>().user;
    final senderId =
        currentUser?.username ?? currentUser?.id.toString() ?? 'me';
    final timestamp = DateTime.now();
    final tempId = 'temp_video_${timestamp.millisecondsSinceEpoch}';

    final fileInfoJson = jsonEncode({
      'type': 'video_message',
      'file_id': tempId,
      'duration': duration,
      'mime_type': 'video/mp4',
      'local_path': path,
    });

    await _localChatRepo.saveMessage(
      MessagesCompanion(
        serverMessageId: Value(tempId),
        chatId: Value(localId),
        senderId: Value(senderId),
        textContent: Value(fileInfoJson),
        timestamp: Value(timestamp),
        fileUrl: Value(fileInfoJson),
        messageType: const Value('video_message'),
        messageId: Value(tempId),
      ),
    );

    if (mounted) {
      setState(() {
        _limit++;
        _updateStream();
      });
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    final updatedChat = ChatModel(
      id: widget.chat.id,
      name: widget.chat.name,
      avatar: widget.chat.avatar,
      avatarGradient: widget.chat.avatarGradient,
      lastMessage:
          '${AppLocalizations.of(context)?.videoMessage ?? 'Video message'} • ${duration.toStringAsFixed(1)}s',
      lastMessageTime: timestamp,
      unreadCount: widget.chat.unreadCount,
      isGroup: widget.chat.isGroup,
      isChannel: widget.chat.isChannel,
      isPersonal: widget.chat.isPersonal,
      isFavorites: widget.chat.isFavorites,
      otherUser: _otherUser,
      isEncrypted: false,
      isArchived: widget.chat.isArchived,
      archivedAt: widget.chat.archivedAt,
      lastMessageType: 'video_message',
    );
    await _localChatRepo.saveChat(updatedChat);

    return tempId;
  }

  Future<bool> _requestCameraPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  Future<CameraDescription?> _getCameraToUse() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    if (_cameras.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final savedDirection =
        prefs.getString('last_used_camera_lens_direction') ?? 'front';

    CameraDescription? selectedCamera;
    if (savedDirection == 'back') {
      selectedCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
    } else {
      selectedCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );
    }
    return selectedCamera;
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    if (_cameraController == null) return;

    final currentLens = _cameraController!.description.lensDirection;
    final nextLens = currentLens == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    final nextCam = _cameras.firstWhere(
      (cam) => cam.lensDirection == nextLens,
      orElse: () => _cameras.first,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_used_camera_lens_direction',
      nextLens == CameraLensDirection.back ? 'back' : 'front',
    );

    await _cameraController!.dispose();
    _cameraController = CameraController(
      nextCam,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      if (_isRecordingVideo) {
        await _cameraController!.startVideoRecording();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error toggling camera: $e');
    }
  }

  Future<void> _startVideoRecording() async {
    try {
      final hasPermission = await _requestCameraPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text((AppLocalizations.of(context)
                        ?.trebuetsyaRazreshenieNaKameruI_06fa ??
                    'Fallback'))),
          );
        }
        return;
      }

      final camera = await _getCameraToUse();
      if (camera == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    (AppLocalizations.of(context)?.kameraNeNaydena_208d ??
                        'Fallback'))),
          );
        }
        return;
      }

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      try {
        await Feedback.forLongPress(context);
      } catch (_) {}

      await _cameraController!.initialize();

      if (!_isHoldingButton) {
        await _cameraController!.dispose();
        _cameraController = null;
        return;
      }

      await _cameraController!.startVideoRecording();

      if (!_isHoldingButton) {
        try {
          await _cameraController!.stopVideoRecording();
        } catch (_) {}
        await _cameraController!.dispose();
        _cameraController = null;
        return;
      }

      _sendTypingEvent(true, action: 'recording_voice');

      if (mounted) {
        setState(() {
          _isRecordingVideo = true;
          _videoRecordingDurationSeconds = 0.0;
          _dragOffset = 0.0;
        });
      }

      _videoRecordingTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (mounted) {
          setState(() {
            _videoRecordingDurationSeconds += 0.1;
          });
          if (_videoRecordingDurationSeconds >= 60.0) {
            _stopAndSendVideoRecording();
          }
        }
      });
    } catch (e) {
      debugPrint('Error starting video recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.kameraNeNaydena_208d ?? 'Camera error'}: $e')),
        );
      }
    }
  }

  Future<void> _cancelVideoRecording() async {
    if (!_isRecordingVideo) return;
    try {
      _videoRecordingTimer?.cancel();
      _videoRecordingTimer = null;

      if (_cameraController != null) {
        try {
          final file = await _cameraController!.stopVideoRecording();
          final localFile = File(file.path);
          if (await localFile.exists()) {
            await localFile.delete();
          }
        } catch (_) {}
        await _cameraController!.dispose();
        _cameraController = null;
      }

      _sendTypingEvent(false);

      if (mounted) {
        setState(() {
          _isRecordingVideo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                (AppLocalizations.of(context)?.zapisVideoOtmenena_1db7 ??
                    'Fallback')),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error cancelling video recording: $e');
    }
  }

  Future<void> _stopAndSendVideoRecording() async {
    if (!_isRecordingVideo) return;
    try {
      _videoRecordingTimer?.cancel();
      _videoRecordingTimer = null;

      if (_cameraController == null) return;

      final XFile file;
      try {
        file = await _cameraController!.stopVideoRecording();
      } catch (e) {
        debugPrint('Error stopping video recording: $e');
        return;
      } finally {
        await _cameraController!.dispose();
        _cameraController = null;
      }

      _sendTypingEvent(false);

      final path = file.path;
      final duration = _videoRecordingDurationSeconds;

      if (mounted) {
        setState(() {
          _isRecordingVideo = false;
        });
      }

      if (duration < 1.0) {
        final localFile = File(path);
        if (await localFile.exists()) {
          await localFile.delete();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((AppLocalizations.of(context)
                      ?.slishkomKorotkoeVideosoobschenie_4676 ??
                  'Fallback')),
              backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        return;
      }

      final tempId = await _insertOptimisticVideoMessage(path, duration);
      await _uploadAndSendVideoMessage(path, duration, tempId);
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
    }
  }

  Future<void> _uploadAndSendVideoMessage(String path, double duration,
      [String? tempId]) async {
    try {
      final file = File(path);
      if (!await file.exists()) return;

      final filename = path.split('/').last;

      final formData = FormData.fromMap({
        'file_type': 'video_message',
        'chat_id': widget.chat.id,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: filename,
        ),
        'duration': duration,
      });

      final apiClient = context.read<ApiClient>();

      final response = await apiClient.post(
        '/files/upload/',
        data: formData,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final fileId = response.data['file_id'] as String;

        if (tempId != null) {
          _pendingVideoTempIds[fileId] = tempId;
          _pendingVideoLocalPaths[fileId] = path;
        }

        final cryptoService = context.read<CryptoService>();

        final videoMetadata = jsonEncode({
          'type': 'video_message',
          'file_id': fileId,
          'duration': duration,
          'mime_type': 'video/mp4',
        });

        final encryptedText =
            await cryptoService.encryptMessage(videoMetadata, widget.chat.id);

        if (encryptedText != null) {
          await _chatWebSocketService.send({
            'type': 'video_message',
            'file_id': fileId,
            'duration': duration,
            'chat_id': widget.chat.id,
            'encrypted_text': encryptedText,
          });
        } else {
          await _chatWebSocketService.send({
            'type': 'video_message',
            'file_id': fileId,
            'duration': duration,
            'chat_id': widget.chat.id,
          });
        }
      } else {
        throw Exception('Failed to upload video message to backend');
      }
    } catch (e) {
      debugPrint('Error uploading video message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.videoMessage ?? 'Video message'}: $e')),
        );
      }
    }
  }

  Future<void> _handleTodoCompletionUpdate(Map<String, dynamic> event) async {
    final messageId = event['todo_message_id']?.toString();
    final itemIndex = event['item_index'];
    final isCompleted = event['is_completed'] as bool?;

    if (messageId == null || itemIndex == null || isCompleted == null) return;

    final repo = context.read<LocalChatRepository>();
    final dbMsg = await repo.getMessageByMessageId(messageId);
    if (dbMsg != null) {
      final statusMap = dbMsg.completionStatus != null
          ? Map<String, dynamic>.from(jsonDecode(dbMsg.completionStatus!))
          : <String, dynamic>{};

      statusMap[itemIndex.toString()] = isCompleted;
      final updatedStatus = jsonEncode(statusMap);

      await repo.updateMessageCompanion(
        MessagesCompanion(
          id: Value(dbMsg.id),
          completionStatus: Value(updatedStatus),
        ),
      );
    }
  }

  Future<void> _handlePollVoteUpdate(Map<String, dynamic> event) async {
    final messageId = event['poll_message_id']?.toString();
    if (messageId == null) return;

    final optionId = event['option_id']?.toString();
    if (optionId == null) return;

    final removeVote = event['remove_vote'] == true;
    final userId = event['user_id']?.toString();
    final username = event['username']?.toString();

    final repo = context.read<LocalChatRepository>();
    final dbMsg = await repo.getMessageByMessageId(messageId);
    if (dbMsg != null) {
      // 1. Update userVotes (if this vote belongs to the current user)
      final currentUser = context.read<AuthProvider>().user;
      final isCurrentUser = (currentUser != null &&
          (userId == currentUser.id.toString() ||
              username == currentUser.username));

      List<String> userVotes = [];
      if (dbMsg.userVotes != null && dbMsg.userVotes!.isNotEmpty) {
        try {
          userVotes = List<String>.from(jsonDecode(dbMsg.userVotes!));
        } catch (_) {}
      }

      if (isCurrentUser) {
        if (removeVote) {
          if (!userVotes.contains(optionId)) {
            // Vote already removed locally, skip duplicate increment/decrement
            return;
          }
          userVotes.remove(optionId);
        } else {
          if (userVotes.contains(optionId)) {
            // Vote already added locally, skip duplicate increment/decrement
            return;
          }
          userVotes.add(optionId);
        }
      }

      // 2. Update votesByOption
      Map<String, dynamic> votesByOption = {};
      if (dbMsg.votesByOption != null && dbMsg.votesByOption!.isNotEmpty) {
        try {
          votesByOption =
              Map<String, dynamic>.from(jsonDecode(dbMsg.votesByOption!));
        } catch (_) {}
      }

      final int currentOptionCount = votesByOption[optionId] is num
          ? (votesByOption[optionId] as num).toInt()
          : int.tryParse(votesByOption[optionId]?.toString() ?? '') ?? 0;

      if (removeVote) {
        votesByOption[optionId] = (currentOptionCount - 1).clamp(0, 999999);
      } else {
        votesByOption[optionId] = currentOptionCount + 1;
      }

      await repo.updateMessageCompanion(
        MessagesCompanion(
          id: Value(dbMsg.id),
          votesByOption: Value(jsonEncode(votesByOption)),
          userVotes: Value(jsonEncode(userVotes)),
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _attachments.isEmpty) return;

    if (_attachments.any((a) => a.status == 'error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.oshibkaZagruzkiFayla_86e5 ??
                'File upload error',
          ),
        ),
      );
      return;
    }

    final localAttachments = List<AttachmentComposition>.from(_attachments);
    _messageController.clear();
    setState(() {
      _attachments.clear();
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    final cryptoService = context.read<CryptoService>();
    final timestamp = DateTime.now();

    String previewText = text;
    String? previewMessageType;
    if (previewText.isEmpty && localAttachments.isNotEmpty) {
      previewText = localAttachments.length == 1
          ? '${AppLocalizations.of(context)?.file ?? 'File'}: ${localAttachments[0].fileName}'
          : '${AppLocalizations.of(context)?.files ?? 'Files'} (${localAttachments.length})';

      if (localAttachments.length > 1 &&
          localAttachments.every(
              (attachment) => attachment.fileType.toLowerCase() == 'image')) {
        previewMessageType = 'collage';
      } else if (localAttachments.length == 1) {
        previewMessageType =
            switch (localAttachments.first.fileType.toLowerCase()) {
          'image' => 'image',
          'video' => 'video',
          'audio' => 'audio',
          'document' => 'file',
          final type => type.isEmpty ? 'file' : type,
        };
      } else {
        previewMessageType = 'file';
      }
    }

    final updatedChat = ChatModel(
      id: widget.chat.id,
      name: widget.chat.name,
      avatar: widget.chat.avatar,
      avatarGradient: widget.chat.avatarGradient,
      lastMessage: previewText,
      lastMessageTime: timestamp,
      unreadCount: 0,
      isGroup: widget.chat.isGroup,
      isChannel: widget.chat.isChannel,
      isPersonal: widget.chat.isPersonal,
      isFavorites: widget.chat.isFavorites,
      otherUser: _otherUser,
      isEncrypted: false,
      isArchived: widget.chat.isArchived,
      archivedAt: widget.chat.archivedAt,
      lastMessageType: previewMessageType,
    );
    final localId = await _ensureLocalChatId(overrideChat: updatedChat);
    if (localId == null) return;

    final replyToId = _replyingToMessage?.serverMessageId;
    final replyText = _replyingToMessage?.textContent;
    if (_replyingToMessage != null) {
      setState(() {
        _replyingToMessage = null;
      });
    }

    String? optimisticFileInfoJson;
    if (localAttachments.isNotEmpty) {
      if (localAttachments.length == 1) {
        final att = localAttachments[0];
        optimisticFileInfoJson = jsonEncode({
          'file_id': att.fileId,
          'file_name': att.fileName,
          'file_size': att.fileSize,
          'type': att.fileType,
          'mime_type': att.fileType,
          if (att.file.path.isNotEmpty) 'local_path': att.file.path,
        });
      } else {
        optimisticFileInfoJson = jsonEncode({
          'type': 'collage',
          'files': localAttachments
              .map((att) => {
                    'file_id': att.fileId,
                    'file_name': att.fileName,
                    'file_size': att.fileSize,
                    'type': att.fileType,
                    'mime_type': att.fileType,
                    if (att.file.path.isNotEmpty) 'local_path': att.file.path,
                  })
              .toList(),
        });
      }
    }

    final tempId = 'temp_text_${timestamp.millisecondsSinceEpoch}';
    final currentUser = context.read<AuthProvider>().user;
    final currentSenderId =
        currentUser?.username ?? currentUser?.id.toString() ?? 'me';

    await _localChatRepo.saveMessage(
      MessagesCompanion(
        serverMessageId: Value(tempId),
        chatId: Value(localId),
        senderId: Value(currentSenderId),
        textContent: Value(text),
        timestamp: Value(timestamp),
        fileUrl: Value(optimisticFileInfoJson),
        messageType: Value(previewMessageType ??
            (optimisticFileInfoJson != null ? 'file' : null)),
        isRead: const Value(false),
        replyToId: Value(replyToId),
        replyText: Value(replyText),
      ),
    );

    _messagesToAnimate.add(tempId);
    if (mounted) {
      setState(() {
        _limit++;
        _updateStream();
      });
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    try {
      await Future.wait(
        localAttachments
            .map((attachment) => attachment.uploadFuture)
            .whereType<Future<void>>(),
      );
      if (localAttachments.any((attachment) =>
          attachment.status != 'success' ||
          attachment.fileId == null ||
          attachment.fileId!.isEmpty)) {
        throw StateError('One or more attachments failed to upload');
      }

      if (localAttachments.isNotEmpty) {
        final uploadedFileInfoJson = localAttachments.length == 1
            ? jsonEncode({
                'file_id': localAttachments.first.fileId,
                'file_name': localAttachments.first.fileName,
                'file_size': localAttachments.first.fileSize,
                'type': localAttachments.first.fileType,
                'mime_type': localAttachments.first.fileType,
                'local_path': localAttachments.first.file.path,
              })
            : jsonEncode({
                'type': 'collage',
                'files': localAttachments
                    .map((attachment) => {
                          'file_id': attachment.fileId,
                          'file_name': attachment.fileName,
                          'file_size': attachment.fileSize,
                          'type': attachment.fileType,
                          'mime_type': attachment.fileType,
                          'local_path': attachment.file.path,
                        })
                    .toList(),
              });
        await _localChatRepo.updateMessageServerId(
          tempId,
          tempId,
          fileUrl: uploadedFileInfoJson,
          messageType: previewMessageType,
        );
      }

      final encryptedText =
          await cryptoService.encryptMessage(text, widget.chat.id);
      if (encryptedText == null) {
        throw StateError(
            'Encryption key is not available for chat ${widget.chat.id}');
      }

      final String? firstFileId =
          localAttachments.isNotEmpty ? localAttachments[0].fileId : null;

      final allFilesList = localAttachments
          .map((file) => {
                'file_id': file.fileId,
                'name': file.fileName,
                'size': file.fileSize,
                'type': file.fileType,
                'mime_type': file.fileType,
              })
          .toList();

      final bool sent;
      _pendingTextTempIds.add(tempId);
      if (localAttachments.isNotEmpty) {
        sent = await _chatWebSocketService.send({
          'type': 'encrypted_message',
          'chat_id': widget.chat.id,
          'encrypted_text': encryptedText,
          'file_id': firstFileId,
          'images': allFilesList,
          if (replyToId != null) 'reply_to_id': replyToId,
        });
      } else {
        sent = await _chatWebSocketService.send({
          'type': 'encrypted_message',
          'chat_id': widget.chat.id,
          'encrypted_text': encryptedText,
          'images': [],
          'image': null,
          if (replyToId != null) 'reply_to_id': replyToId,
        });
      }
      if (!sent) {
        throw StateError('WebSocket is not connected');
      }
    } catch (e) {
      debugPrint('Error sending E2EE message over WS: $e');
      _pendingTextTempIds.remove(tempId);
      try {
        await _localChatRepo.deleteMessageByServerId(tempId);
      } catch (deleteError) {
        debugPrint('Failed to remove unsent local message: $deleteError');
      }
      if (mounted) {
        setState(() {
          for (final attachment in localAttachments.reversed) {
            if (!_attachments.contains(attachment)) {
              _attachments.insert(0, attachment);
            }
          }
          if (text.isNotEmpty && _messageController.text.trim().isEmpty) {
            _messageController.text = text;
            _messageController.selection = TextSelection.collapsed(
              offset: _messageController.text.length,
            );
          }
          _updateStream();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Не удалось отправить сообщение. Попробуйте ещё раз.'),
          ),
        );
      }
    }
  }

  Future<void> _sendPollMessage(
      String question, List<String> options, bool isMultipleChoice) async {
    final cryptoService = context.read<CryptoService>();
    final List<Map<String, String>> optionsList = options
        .asMap()
        .entries
        .map((e) => {'id': 'opt_${e.key}', 'text': e.value})
        .toList();

    final payload = jsonEncode({
      'type': 'poll',
      'question': question,
      'options': optionsList,
      'is_multiple_choice': isMultipleChoice,
      'is_native': true,
    });

    try {
      final encryptedText =
          await cryptoService.encryptMessage(payload, widget.chat.id);
      final encryptedQuestion =
          await cryptoService.encryptMessage(question, widget.chat.id);

      if (encryptedText != null && encryptedQuestion != null) {
        await _chatWebSocketService.send({
          'type': 'poll_message',
          'encrypted_content': encryptedText,
          'encrypted_question': encryptedQuestion,
          'question': question,
          'chat_id': widget.chat.id,
        });
      }
    } catch (e) {
      debugPrint('Error sending poll over WS: $e');
    }
  }

  Future<void> _sendTodoListMessage(String title, List<String> items) async {
    final cryptoService = context.read<CryptoService>();
    final List<Map<String, dynamic>> itemsList = items
        .map((item) => {
              'text': item,
              'completed': false,
            })
        .toList();

    final payload = jsonEncode({
      'type': 'todo_list',
      'title': title,
      'items': itemsList,
      'is_native': true,
    });

    try {
      final encryptedText =
          await cryptoService.encryptMessage(payload, widget.chat.id);
      final encryptedTitle =
          await cryptoService.encryptMessage(title, widget.chat.id);

      if (encryptedText != null && encryptedTitle != null) {
        await _chatWebSocketService.send({
          'type': 'todo_list_message',
          'encrypted_content': encryptedText,
          'encrypted_title': encryptedTitle,
          'title': title,
          'chat_id': widget.chat.id,
        });
      }
    } catch (e) {
      debugPrint('Error sending todo list over WS: $e');
    }
  }

  String _detectFileType(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.gif') ||
        lowerPath.endsWith('.webp') ||
        lowerPath.endsWith('.bmp') ||
        lowerPath.endsWith('.svg')) {
      return 'image';
    }
    if (lowerPath.endsWith('.mp4') ||
        lowerPath.endsWith('.avi') ||
        lowerPath.endsWith('.mov') ||
        lowerPath.endsWith('.wmv') ||
        lowerPath.endsWith('.flv') ||
        lowerPath.endsWith('.webm') ||
        lowerPath.endsWith('.mkv') ||
        lowerPath.endsWith('.loc_3gp') ||
        lowerPath.endsWith('.ogv') ||
        lowerPath.endsWith('.m4v')) {
      return 'video';
    }
    if (lowerPath.endsWith('.mp3') ||
        lowerPath.endsWith('.wav') ||
        lowerPath.endsWith('.ogg') ||
        lowerPath.endsWith('.m4a') ||
        lowerPath.endsWith('.flac') ||
        lowerPath.endsWith('.aac') ||
        lowerPath.endsWith('.wma') ||
        lowerPath.endsWith('.opus') ||
        lowerPath.endsWith('.aiff') ||
        lowerPath.endsWith('.alac')) {
      return 'audio';
    }
    return 'document';
  }

  /// Выбор представления: фото в чате или обычный файл.
  /// Оба режима передают исходные байты без JPEG-перекодирования.
  Future<bool?> _showCompressImageDialog() {
    return CompressImageModal.show(context);
  }

  Future<File> _cachePickedFile(File source) async {
    final tempDir = await getTemporaryDirectory();
    final safeChatId = widget.chat.id.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    final cacheDir = Directory('${tempDir.path}/xaneo_media/$safeChatId');
    await cacheDir.create(recursive: true);

    final sourceName = source.path.split(Platform.pathSeparator).last;
    final safeName = sourceName.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    final cachePath =
        '${cacheDir.path}/${DateTime.now().microsecondsSinceEpoch}_$safeName';
    return source.copy(cachePath);
  }

  Future<void> _processPickedFiles(List<File> files) async {
    if (files.isEmpty || !mounted) return;

    bool isCompressibleImage(File f) =>
        _detectFileType(f.path) == 'image' &&
        !f.path.toLowerCase().endsWith('.gif');

    bool displayImagesAsPhotos = true;
    if (files.any(isCompressibleImage)) {
      final choice = await _showCompressImageDialog();
      if (!mounted || choice == null) return; // Отменено пользователем
      displayImagesAsPhotos = choice;
    }

    final List<AttachmentComposition> newAttachments = [];
    for (final file in files) {
      final type = _detectFileType(file.path);
      final uploadType = type == 'image' &&
              !file.path.toLowerCase().endsWith('.gif') &&
              !displayImagesAsPhotos
          ? 'document'
          : type;
      final effectiveFile = await _cachePickedFile(file);
      if (!mounted) return;
      final name = effectiveFile.path.split(Platform.pathSeparator).last;
      final size = await effectiveFile.length();
      newAttachments.add(AttachmentComposition(
        file: effectiveFile,
        status: 'uploading',
        fileType: uploadType,
        fileSize: size,
        fileName: name,
      ));
    }
    if (mounted && newAttachments.isNotEmpty) {
      setState(() {
        _attachments.addAll(newAttachments);
      });
      for (final attachment in newAttachments) {
        attachment.uploadFuture = _uploadAttachment(attachment);
      }
    }
  }

  Future<void> _pickFilesUnified() async {
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (!mounted) return;
      if (result != null && result.files.isNotEmpty) {
        final List<File> files = [];
        for (final pf in result.files) {
          if (pf.path != null) {
            files.add(File(pf.path!));
          }
        }
        if (files.isNotEmpty) {
          await _processPickedFiles(files);
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.otpravkaFaylov_aaca ?? 'Files'}: $e')),
        );
      }
    }
  }

  Future<void> _uploadAttachment(AttachmentComposition attachment) async {
    try {
      final apiClient = context.read<ApiClient>();
      final formData = FormData.fromMap({
        'file_type': attachment.fileType,
        'chat_id': widget.chat.id,
        'file': await MultipartFile.fromFile(
          attachment.file.path,
          filename: attachment.fileName,
        ),
      });

      final response = await apiClient.post(
        '/files/upload/',
        data: formData,
      );

      final isSuccess = response.statusCode != null &&
          (response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null &&
          (response.data['success'] == true ||
              response.data['file_id'] != null);

      if (isSuccess) {
        final fileId =
            (response.data['file_id'] ?? response.data['id'])?.toString();
        if (fileId != null && fileId.isNotEmpty) {
          attachment.status = 'success';
          attachment.fileId = fileId;
          if (mounted) {
            setState(() {});
          }
        } else {
          throw Exception('No file_id in response');
        }
      } else {
        throw Exception('Failed to upload file (HTTP ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error uploading attachment: $e');
      attachment.status = 'error';
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildAttachmentsPreviewPanel() {
    if (_attachments.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _attachments.length,
        itemBuilder: (context, index) {
          final att = _attachments[index];
          final isMedia = att.fileType == 'image' || att.fileType == 'video';

          Widget previewChild;
          if (isMedia) {
            previewChild = Image.file(
              att.file,
              fit: BoxFit.cover,
              width: 74,
              height: 74,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.black26,
                child: const Icon(Icons.broken_image,
                    color: Colors.white54, size: 24),
              ),
            );
          } else {
            final icon = att.fileType == 'audio'
                ? FontAwesomeIcons.music
                : FontAwesomeIcons.fileLines;
            previewChild = Container(
              color: Colors.black26,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(icon, color: Colors.white70, size: 24),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        att.fileName,
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 8),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: 74,
            height: 74,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: previewChild,
                ),
                if (att.status == 'uploading')
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (att.status == 'error')
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 20),
                    ),
                  ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _attachments.removeAt(index);
                      });
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(3),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCallTypeMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF141416),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.phone_rounded, color: Colors.white),
                    ),
                    title: Text(
                        (AppLocalizations.of(context)?.audiozvonok_dcf6 ??
                            'Fallback'),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        (AppLocalizations.of(context)
                                ?.pozvonitPoGolosovoySvyazi_4069 ??
                            'Fallback'),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      _initiateCall('audio');
                    },
                  ),
                  Divider(color: Colors.white.withOpacity(0.04), height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.videocam_rounded, color: Colors.white),
                    ),
                    title: Text(
                        (AppLocalizations.of(context)?.videozvonok_8142 ??
                            'Fallback'),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        (AppLocalizations.of(context)
                                ?.pozvonitSVklyuchennoyKameroy_fb05 ??
                            'Fallback'),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      _initiateCall('video');
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF141416),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.insert_drive_file_rounded,
                          color: Colors.white),
                    ),
                    title: Text(
                        (AppLocalizations.of(context)?.fayly_200c ??
                            'Fallback'),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        (AppLocalizations.of(context)
                                ?.otpravitFotoVideoAudioIli_37e9 ??
                            'Fallback'),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      _pickFilesUnified();
                    },
                  ),
                  Divider(color: Colors.white.withOpacity(0.04), height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.poll_rounded, color: Colors.white),
                    ),
                    title: Text(
                        (AppLocalizations.of(context)?.sozdatOpros_8401 ??
                            'Fallback'),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        (AppLocalizations.of(context)
                                ?.provedenieGolosovaniyaVChate_a629 ??
                            'Fallback'),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      CreatePollModal.show(context, _sendPollMessage);
                    },
                  ),
                  Divider(color: Colors.white.withOpacity(0.04), height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_box_rounded, color: Colors.white),
                    ),
                    title: Text(
                        (AppLocalizations.of(context)?.sozdatToDoSpisok_cb50 ??
                            'Fallback'),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        (AppLocalizations.of(context)
                                ?.spisokZadachSOtmetkamiVypolneniya_c778 ??
                            'Fallback'),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      CreateTodoModal.show(context, _sendTodoListMessage);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text((AppLocalizations.of(context)
                        ?.trebuetsyaRazreshenieNaZapisAudio_8175 ??
                    'Fallback'))),
          );
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      // WAV PCM16 даёт точный seek. 48 kHz не срезает верхнюю
      // полосу голоса; backend теперь сохраняет этот файл без транскодирования.
      final path =
          '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Haptic feedback
      try {
        await Feedback.forLongPress(context);
      } catch (_) {}

      await _audioRecorder.start(
        const RecordConfig(
          // AudioEncoder.wav = PCM16 С RIFF/WAVE заголовком.
          // pcm16bits писал headerless raw PCM → ffmpeg на бэке не мог его распознать,
          // а клиенты не могли декодировать. wav даёт валидный самодостаточный файл.
          encoder: AudioEncoder.wav,
          sampleRate: 48000,
          bitRate: 768000,
          numChannels: 1,
        ),
        path: path,
      );

      _sendTypingEvent(true, action: 'recording_voice');

      if (mounted) {
        setState(() {
          _isRecording = true;
          _recordingDurationSeconds = 0;
          _dragOffset = 0.0;
        });
      }

      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && _isRecording) {
          setState(() {
            _recordingDurationSeconds++;
          });
        }
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording) return;
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _sendTypingEvent(false);

      if (mounted) {
        setState(() {
          _isRecording = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((AppLocalizations.of(context)?.zapisOtmenena_1609 ??
                'Fallback')),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
    }
  }

  Future<void> _stopAndSendRecording() async {
    if (!_isRecording) return;
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final path = await _audioRecorder.stop();
      _sendTypingEvent(false);

      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }

      if (path == null) return;

      final duration = _recordingDurationSeconds;
      if (duration < 1) {
        // Delete file if too short
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((AppLocalizations.of(context)
                      ?.slishkomKorotkoeSoobschenie_c2ee ??
                  'Fallback')),
              backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        return;
      }

      // Оптимистично показываем ГС СРАЗУ (играется из локального файла),
      // а загрузка/отправка идут в фоне.
      final tempId = await _insertOptimisticVoice(path, duration);

      // Upload file в фоне; tempId нужен для сверки с эхом сервера.
      await _uploadAndSendVoiceMessage(path, duration, tempId);
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  /// Вставляет локальное "temp" голосовое сообщение, которое отображается мгновенно
  /// и проигрывается прямо из записанного файла. Возвращает его serverMessageId (temp).
  Future<String?> _insertOptimisticVoice(String path, int duration) async {
    final localId = await _ensureLocalChatId();
    if (localId == null) return null;

    final currentUser = context.read<AuthProvider>().user;
    final senderId =
        currentUser?.username ?? currentUser?.id.toString() ?? 'me';
    final timestamp = DateTime.now();
    final tempId = 'temp_voice_${timestamp.millisecondsSinceEpoch}';

    final fileInfoJson = jsonEncode({
      'type': 'voice',
      'file_id': '',
      'duration': duration,
      'mime_type': 'audio/wav',
      'local_path': path,
    });

    await _localChatRepo.saveMessage(
      MessagesCompanion(
        serverMessageId: Value(tempId),
        chatId: Value(localId),
        senderId: Value(senderId),
        textContent: Value(fileInfoJson),
        timestamp: Value(timestamp),
        fileUrl: Value(fileInfoJson),
        messageType: const Value('voice'),
      ),
    );

    _messagesToAnimate.add(tempId);
    if (mounted) {
      setState(() {
        _limit++;
        _updateStream();
      });
    }

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    // Обновляем превью чата
    final updatedChat = ChatModel(
      id: widget.chat.id,
      name: widget.chat.name,
      avatar: widget.chat.avatar,
      avatarGradient: widget.chat.avatarGradient,
      lastMessage: (AppLocalizations.of(context)?.golosovoeSoobschenie_4a85 ??
          'Fallback'),
      lastMessageTime: timestamp,
      unreadCount: 0,
      isGroup: widget.chat.isGroup,
      isChannel: widget.chat.isChannel,
      isPersonal: widget.chat.isPersonal,
      isFavorites: widget.chat.isFavorites,
      otherUser: _otherUser,
      isEncrypted: false,
      isArchived: widget.chat.isArchived,
      archivedAt: widget.chat.archivedAt,
      lastMessageType: 'voice',
    );
    await _localChatRepo.saveChat(updatedChat);

    return tempId;
  }

  Future<void> _uploadAndSendVoiceMessage(String path, int duration,
      [String? tempId]) async {
    try {
      final file = File(path);
      if (!await file.exists()) return;

      final filename = path.split('/').last;

      final formData = FormData.fromMap({
        'file_type': 'voice',
        'chat_id': widget.chat.id,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: filename,
        ),
        'mime_type': 'audio/wav',
      });

      final apiClient = context.read<ApiClient>();

      final response = await apiClient.post(
        '/files/upload/',
        data: formData,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final fileId = response.data['file_id'] as String;

        // Связываем temp-сообщение и локальный файл с реальным file_id,
        // чтобы эхо сервера схлопнулось в уже показанное сообщение.
        if (tempId != null) {
          _pendingVoiceTempIds[fileId] = tempId;
          _pendingVoiceLocalPaths[fileId] = path;
        }

        final cryptoService = context.read<CryptoService>();

        final voiceMetadata = jsonEncode({
          'type': 'voice',
          'file_id': fileId,
          'duration': duration,
          'mime_type': 'audio/wav',
        });

        final encryptedText =
            await cryptoService.encryptMessage(voiceMetadata, widget.chat.id);

        if (encryptedText != null) {
          await _chatWebSocketService.send({
            'type': 'voice_message',
            'file_id': fileId,
            'duration': duration,
            'chat_id': widget.chat.id,
            'encrypted_text': encryptedText,
          });
        } else {
          debugPrint('Failed to encrypt voice metadata');
        }
      } else {
        throw Exception('Failed to upload file to backend');
      }
    } catch (e) {
      debugPrint('Error uploading/sending voice: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.voiceMessage ?? 'Voice message'}: $e')),
        );
      }
    }
  }

  String _formatRecordingDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _applyFormatting(
      String prefix, String suffix, EditableTextState editableTextState) {
    final value = editableTextState.textEditingValue;
    final text = value.text;
    final selection = value.selection;

    if (selection.isCollapsed) return;

    final selectedText = selection.textInside(text);
    final newText = text.replaceRange(
        selection.start, selection.end, '$prefix$selectedText$suffix');

    final newSelection = TextSelection(
      baseOffset: selection.start,
      extentOffset: selection.end + prefix.length + suffix.length,
    );

    _messageController.value = TextEditingValue(
      text: newText,
      selection: newSelection,
    );

    editableTextState.hideToolbar();
  }

  void _toggleEmojiPicker() {
    if (_isEmojiPickerVisible) {
      setState(() => _isEmojiPickerVisible = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _messageFocusNode.requestFocus();
      });
      return;
    }

    final selection = _messageController.selection;
    _emojiInsertionSelection = selection.isValid
        ? selection
        : TextSelection.collapsed(offset: _messageController.text.length);

    final media = MediaQuery.of(context);
    final keyboardHeight = media.viewInsets.bottom;
    _emojiPickerHeight = keyboardHeight >= 200
        ? keyboardHeight.clamp(260.0, 360.0)
        : (media.size.height * 0.38).clamp(280.0, 340.0);

    _messageFocusNode.unfocus();
    setState(() => _isEmojiPickerVisible = true);
  }

  void _closeEmojiPicker() {
    if (_isEmojiPickerVisible) {
      setState(() => _isEmojiPickerVisible = false);
    }
  }

  void _insertEmoji(String emoji) {
    final value = _messageController.value;
    final selection = value.selection.isValid
        ? value.selection
        : _emojiInsertionSelection.isValid
            ? _emojiInsertionSelection
            : TextSelection.collapsed(offset: value.text.length);
    final start = selection.start.clamp(0, value.text.length);
    final end = selection.end.clamp(start, value.text.length);
    final nextSelection = TextSelection.collapsed(offset: start + emoji.length);

    _messageController.value = value.copyWith(
      text: value.text.replaceRange(start, end, emoji),
      selection: nextSelection,
      composing: TextRange.empty,
    );
    _emojiInsertionSelection = nextSelection;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;
    final wallpaper = context.watch<AppearanceProvider>().wallpaper;
    final wallpaperDecoration = wallpaper.resolveDecoration();
    final media = MediaQuery.of(context);
    final maximumEmojiHeight = max(
      160.0,
      media.size.height - media.viewInsets.bottom - 140,
    );
    final effectiveEmojiHeight = min(
      _emojiPickerHeight,
      maximumEmojiHeight,
    );

    return Provider<ChatWebSocketService>.value(
      value: _chatWebSocketService,
      child: PopScope(
        canPop: !_isEmojiPickerVisible,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _closeEmojiPicker();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          resizeToAvoidBottomInset: true,
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context),
          body: Stack(
            children: [
              // Stunning Liquid Glass Background decoration
              RepaintBoundary(child: _buildGlassBackground()),
              if (wallpaperDecoration != null)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: DecoratedBox(decoration: wallpaperDecoration),
                  ),
                ),

              // The list fills the whole chat area. The composer is drawn over
              // it, so messages remain visible through its translucent surface.
              Positioned.fill(
                child: RepaintBoundary(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white54,
                          ),
                        )
                      : _buildMessagesList(currentUser),
                ),
              ),

              Positioned(
                top: MediaQuery.paddingOf(context).top + 58,
                left: 0,
                right: 0,
                child: Center(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _showFloatingDate && _floatingDateText != null
                          ? 1
                          : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      child: _floatingDateText == null
                          ? const SizedBox.shrink()
                          : _buildFloatingDateBadge(_floatingDateText!),
                    ),
                  ),
                ),
              ),

              // Compact input bar overlay.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: RepaintBoundary(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            4,
                            16,
                            _isEmojiPickerVisible ? 4 : 8,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildAttachmentsPreviewPanel(),
                              _buildBottomBar(context),
                            ],
                          ),
                        ),
                        ClipRect(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            height: _isEmojiPickerVisible
                                ? effectiveEmojiHeight
                                : 0,
                            child: EmojiPickerPanel(
                              isDark: Theme.of(context).brightness ==
                                  Brightness.dark,
                              onEmojiSelected: _insertEmoji,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Mini Media Player
              _buildMiniPlayer(),

              if (_isRecordingVideo &&
                  _cameraController != null &&
                  _cameraController!.value.isInitialized)
                _buildVideoRecordingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoRecordingOverlay() {
    return Positioned.fill(
      child: Stack(
        children: [
          // 1. Background dimmer & preview circle - ignores pointer events to prevent blocking input gestures underneath
          IgnorePointer(
            ignoring: true,
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: 260,
                              height:
                                  260 * _cameraController!.value.aspectRatio,
                              child: CameraPreview(_cameraController!),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _formatRecordingDuration(
                            _videoRecordingDurationSeconds.toInt()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      (AppLocalizations.of(context)
                              ?.uderzhivayteKnopkuDlyaZapisi_a762 ??
                          'Fallback'),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Interactive overlay controls - positioned to be clickable without overlapping the record button
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height / 2 + 180,
            child: Center(
              child: GestureDetector(
                onTap: _toggleCamera,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    final topOffset =
        MediaQuery.of(context).padding.top + 64; // Under the AppBar
    // Positioned всегда в дереве (он в Stack). Анимация появления/исчезновения
    // делается внутри через AnimatedSwitcher: slide-down + fade на появление,
    // slide-up + fade на исчезновение.
    return Positioned(
      top: topOffset,
      left: 16,
      right: 16,
      child: Consumer<PlaybackProvider>(
        builder: (context, playbackProvider, child) {
          final isVisible = playbackProvider.showPlayerControls;

          return AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (widget, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.6),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic)),
                  child: widget,
                ),
              );
            },
            child: isVisible
                ? TopChatAudioMiniPlayer(
                    playbackProvider: playbackProvider,
                    onTapTitle: () => _showMusicPlaylistModal(context),
                  )
                : const SizedBox.shrink(key: ValueKey('mini_player_hidden')),
          );
        },
      ),
    );
  }

  // Pre-cached color constants — avoids creating new Color objects on every build
  static const _glowIndigo = Color(0x3F6366F1); // 0.25 opacity
  static const _glowIndigoT = Color(0x006366F1); // 0.0 opacity
  static const _glowFuchsia = Color(0x2ED946EF); // 0.18 opacity
  static const _glowFuchsiaT = Color(0x00D946EF); // 0.0 opacity
  static const _glassTint =
      Color(0xD9000000); // ~0.85 opacity replaces blur+0.75

  Map<String, dynamic>? _getAttachmentData(Message msg) {
    if (msg.fileUrl != null && msg.fileUrl!.isNotEmpty) {
      try {
        final decoded = jsonDecode(msg.fileUrl!);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {}
    }
    return null;
  }

  List<PlaybackItem> _getMusicPlaylistFromChat() {
    final playlist = <PlaybackItem>[];
    final uri = Uri.parse(AppConfig.apiBaseUrl);
    final hostUrl =
        '${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}';
    final tokenToUse = _jwtToken;

    for (final msg in _loadedMessages) {
      final fileData = _getAttachmentData(msg);
      if (fileData == null) continue;
      final type = fileData['type']?.toString().toLowerCase() ?? '';
      if (type == 'voice' || type == 'video_message') continue;

      final fileName = fileData['file_name']?.toString() ??
          fileData['name']?.toString() ??
          (AppLocalizations.of(context)?.audiozapis_867d ?? 'Fallback');
      final lowerName = fileName.toLowerCase();
      final mime = fileData['mime_type']?.toString().toLowerCase() ??
          fileData['type']?.toString().toLowerCase() ??
          '';

      final isAudioMusic = type == 'audio' ||
          (mime.startsWith('audio/') &&
              !lowerName.contains('voice') &&
              !lowerName.endsWith('.ogg') &&
              !lowerName.endsWith('.opus')) ||
          lowerName.endsWith('.mp3') ||
          lowerName.endsWith('.wav') ||
          lowerName.endsWith('.m4a') ||
          lowerName.endsWith('.flac') ||
          lowerName.endsWith('.aac') ||
          lowerName.endsWith('.wma');

      if (isAudioMusic) {
        final fileUrlSuffix = fileData['file_url']?.toString() ??
            fileData['url']?.toString() ??
            '';
        String absoluteUrl = '';
        if (fileUrlSuffix.startsWith('http')) {
          absoluteUrl =
              '$fileUrlSuffix${tokenToUse != null ? (fileUrlSuffix.contains('?') ? "&token=$tokenToUse" : "?token=$tokenToUse") : ""}';
        } else {
          final prefix = fileUrlSuffix.startsWith('/') ? '' : '/';
          absoluteUrl =
              '$hostUrl$prefix$fileUrlSuffix${tokenToUse != null ? "?token=$tokenToUse" : ""}';
        }
        final coverUriStr = audioTrackCoverUri(fileData);
        final artUri = coverUriStr != null && coverUriStr.isNotEmpty
            ? Uri.tryParse(coverUriStr.startsWith('http')
                ? coverUriStr
                : '$hostUrl${coverUriStr.startsWith('/') ? '' : '/'}$coverUriStr')
            : null;

        final trackDurationSec = audioTrackDuration(fileData);
        final localPath = fileData['local_path']?.toString();
        playlist.add(PlaybackItem(
          url: localPath != null && localPath.isNotEmpty
              ? localPath
              : absoluteUrl,
          title: audioTrackTitle(fileData, fileName),
          subtitle: audioTrackArtist(fileData, fileName),
          mimeType: mime,
          duration:
              trackDurationSec > 0 ? Duration(seconds: trackDurationSec) : null,
          artUri: artUri,
          payload: fileData,
        ));
      }
    }
    return playlist;
  }

  void _showMusicPlaylistModal(BuildContext context) {
    final playbackProvider = context.read<PlaybackProvider>();
    MusicPlaylistModal.show(
      context,
      chatServerId: widget.chat.id,
      initialMessages: _loadedMessages,
      initialPlaylist: playbackProvider.playlist,
      jwtToken: _jwtToken,
    );
  }

  Widget _buildGlassBackground() {
    // Instead of BackdropFilter (which recomputes blur every frame during scroll),
    // we use a solid dark layer over subtle gradient orbs.
    // This achieves the same "frosted glass" visual at zero GPU cost.
    return Stack(
      children: [
        // Floating glow bubble 1 (Top right)
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 280,
            height: 280,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_glowIndigo, _glowIndigoT],
              ),
            ),
          ),
        ),
        // Floating glow bubble 2 (Bottom left)
        Positioned(
          bottom: 120,
          left: -85,
          child: Container(
            width: 320,
            height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_glowFuchsia, _glowFuchsiaT],
              ),
            ),
          ),
        ),
        // Theme-aware translucent overlay (replaces BackdropFilter blur)
        Positioned.fill(
          child: Container(
            color: context.isDarkTheme ? _glassTint : const Color(0xEAF7F7FA),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderDroplet({
    required Widget child,
    VoidCallback? onTap,
    bool isCircle = true,
  }) {
    final borderRadius = BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: const BoxDecoration(),
        child: Container(
          width: isCircle ? 40 : null,
          height: 40,
          decoration: BoxDecoration(
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.xaneoOverlay(0.13),
                context.xaneoOverlay(0.05),
              ],
            ),
            border: Border.all(
              color: context.xaneoDivider,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: onTap != null
                ? InkWell(
                    customBorder: isCircle ? const CircleBorder() : null,
                    borderRadius: isCircle ? null : borderRadius,
                    onTap: onTap,
                    child: Center(child: child),
                  )
                : Center(child: child),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // Replaced BackdropFilter with solid semi-transparent background.
    // BackdropFilter on AppBar was recomputing blur on every scroll frame
    // because extendBodyBehindAppBar makes the list scroll underneath.
    final displayName = widget.chat.isFavorites
        ? localizedChatName(context, widget.chat)
        : (_chatName ?? widget.chat.name);
    final headerAvatar = _otherUser?['avatar_url']?.toString() ??
        _otherUser?['avatar']?.toString() ??
        widget.chat.avatar;
    final headerAvatarGradient = _otherUser?['avatar_gradient']?.toString() ??
        widget.chat.avatarGradient;

    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 52,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _buildHeaderDroplet(
              isCircle: true,
              onTap: () => Navigator.of(context).pop(),
              child: FaIcon(FontAwesomeIcons.chevronLeft,
                  color: context.xaneoTextPrimary, size: 14),
            ),
          ),
        ),
        centerTitle: true,
        title: _buildHeaderDroplet(
          isCircle: false,
          onTap: () async {
            final currentChat = ChatModel(
              id: widget.chat.id,
              name: widget.chat.name,
              avatar: widget.chat.avatar,
              avatarGradient: widget.chat.avatarGradient,
              lastMessage: widget.chat.lastMessage,
              lastMessageTime: widget.chat.lastMessageTime,
              unreadCount: widget.chat.unreadCount,
              isGroup: widget.chat.isGroup,
              isChannel: widget.chat.isChannel,
              isPersonal: widget.chat.isPersonal,
              isFavorites: widget.chat.isFavorites,
              otherUser: _otherUser,
              isEncrypted: widget.chat.isEncrypted,
              lastMessageType: widget.chat.lastMessageType,
            );
            final targetMsgId = await ChatInfoModal.show(context, currentChat);
            if (targetMsgId != null && mounted) {
              _scrollToMessage(targetMsgId);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 14, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AvatarWidget(
                  username: displayName,
                  avatar: headerAvatar,
                  avatarGradient: headerAvatarGradient,
                  hasAvatar:
                      headerAvatar != null && headerAvatar.trim().isNotEmpty,
                  size: 30,
                  icon: widget.chat.isFavorites
                      ? FontAwesomeIcons.solidBookmark
                      : null,
                ),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.bodyMedium.copyWith(
                          color: context.xaneoTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      _buildAppBarSubtitle(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (_canCall()) ...[
            Center(
              child: _buildHeaderDroplet(
                isCircle: true,
                onTap: _showCallTypeMenu,
                child: FaIcon(FontAwesomeIcons.phone,
                    color: context.xaneoTextSecondary, size: 16),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Center(
            child: _buildHeaderDroplet(
              isCircle: true,
              onTap: _showCurrentChatContextMenu,
              child: FaIcon(
                FontAwesomeIcons.ellipsisVertical,
                color: context.xaneoTextSecondary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  bool _isDeleted() {
    final name = widget.chat.name.toLowerCase();
    if (name.contains(
            (AppLocalizations.of(context)?.udalennyy_40c6 ?? 'Fallback')) ||
        name.contains(
            (AppLocalizations.of(context)?.udalennyy_c2c8 ?? 'Fallback')) ||
        name.contains('deleted')) {
      return true;
    }
    if (_otherUser != null) {
      final other = _otherUser!;
      if (other['is_deleted'] == true ||
          other['deleted'] == true ||
          other['status'] == 'deleted') {
        return true;
      }
    }
    return false;
  }

  bool _isBot() {
    if (_otherUser != null) {
      final other = _otherUser!;
      if (other['is_bot'] == true || other['bot'] == true) {
        return true;
      }
      final username = other['username']?.toString().toLowerCase() ?? '';
      if (username == 'bot_constructor' ||
          username.startsWith('bot_') ||
          username.endsWith('bot')) {
        return true;
      }
    }
    if (widget.chat.name.toLowerCase().endsWith('bot')) {
      return true;
    }
    return false;
  }

  String? _botUsername() {
    if (!widget.chat.isPersonal || !_isBot()) return null;
    final username = _otherUser?['username']?.toString().trim() ?? '';
    return username.isEmpty ? null : username;
  }

  Future<void> _loadBotCommands() async {
    final username = _botUsername();
    if (username == null) return;

    final cached = _botCommandsCache[username];
    if (cached != null) {
      if (mounted) setState(() => _botCommands = cached);
      return;
    }

    final commands = await _chatService.getBotCommands(username);
    _botCommandsCache[username] = commands;
    if (mounted && _botUsername() == username) {
      setState(() => _botCommands = commands);
    }
  }

  void _sendBotCommand(String command) {
    _messageController.text = '/$command';
    _messageController.selection = TextSelection.collapsed(
      offset: _messageController.text.length,
    );
    _sendMessage();
  }

  Future<void> _showBotCommandsMenu() async {
    if (_botCommands.isEmpty) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.55,
            ),
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF202024) : const Color(0xFFF8F8FA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _botCommands.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              itemBuilder: (context, index) {
                final command = _botCommands[index];
                final name = command['command'] ?? '';
                final description = command['description'] ?? '';
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 3,
                  ),
                  title: Text(
                    '/$name',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF202024),
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: description.isEmpty
                      ? null
                      : Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.58)
                                : Colors.black.withValues(alpha: 0.55),
                            fontSize: 12.5,
                          ),
                        ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _sendBotCommand(name);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  bool _canCall() {
    final chat = widget.chat;

    // 1. Избранное -> звонки запрещены
    if (chat.isFavorites) return false;

    // 2. Каналы -> звонки запрещены
    if (chat.isChannel) return false;

    // 3. Личные чаты (собеседники)
    if (chat.isPersonal) {
      if (_isBot() || _isDeleted()) return false;

      // Проверяем настройки приватности с бэка в Map otherUser
      final other = _otherUser;
      if (other != null) {
        if (other['allow_calls'] == false ||
            other['can_call'] == false ||
            other['calls_allowed'] == false ||
            other['calls_enabled'] == false) {
          return false;
        }
      }
      return true;
    }

    // 4. Группы
    if (chat.isGroup) {
      return widget.chat.groupCallsEnabled;
    }

    return false;
  }

  Future<void> _initiateCall(String callType) async {
    final hasMic = await Permission.microphone.request().isGranted;
    final hasCam = callType == 'video'
        ? await Permission.camera.request().isGranted
        : true;

    if (!hasMic || !hasCam) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((AppLocalizations.of(context)
                    ?.neobhodimyRazresheniyaNaMikrofonI_224b ??
                'Fallback')),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
      return;
    }

    final callManager = context.read<CallManager>();
    final authProvider = context.read<AuthProvider>();

    if (widget.chat.isGroup) {
      final groupId =
          widget.chat.id.toString().replaceAll(RegExp(r'[^0-9]'), '');
      await callManager.startOutgoingGroupCall(
        groupId: groupId,
        groupName: widget.chat.name,
        groupAvatar: widget.chat.avatar,
        groupGradient: widget.chat.avatarGradient,
        callType: callType,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ActiveCallScreen(),
          ),
        );
      }
      return;
    }

    String targetId = widget.chat.id.toString();
    if (widget.chat.isPersonal && _otherUser != null) {
      targetId = _otherUser!['id']?.toString() ?? targetId;
    }

    await callManager.startOutgoingCall(
      targetUserId: targetId,
      targetName: widget.chat.name,
      targetAvatar: preferredAvatar([
        _otherUser?['avatar_url'],
        _otherUser?['avatar'],
        widget.chat.avatar,
      ]),
      targetGradient: widget.chat.avatarGradient,
      callerName: authProvider.user?.username ?? 'User',
      callType: callType,
    );

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ActiveCallScreen(),
        ),
      );
    }
  }

  String _pluralizeParticipants(int count) {
    return AppLocalizations.of(context)?.membersCount(count) ??
        '$count members';
  }

  String _formatSubscribers(int count) {
    return AppLocalizations.of(context)?.subscribersCount(count) ??
        '$count subscribers';
  }

  String _formatDecimal(double value) {
    if (value == value.toInt().toDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  String _formatUserStatus(Map<String, dynamic>? otherUser) {
    if (otherUser == null) return '';

    if (otherUser['is_online'] == true || otherUser['online'] == true) {
      return (AppLocalizations.of(context)?.vSeti_d902 ?? 'Fallback');
    }

    final lastSeenVal = otherUser['last_seen'] ??
        otherUser['last_login'] ??
        otherUser['last_activity'];
    if (lastSeenVal == null)
      return (AppLocalizations.of(context)?.bylANedavno_168d ?? 'Fallback');

    DateTime? lastSeen;
    if (lastSeenVal is String) {
      lastSeen = DateTime.tryParse(lastSeenVal);
    } else if (lastSeenVal is int) {
      lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenVal);
    } else if (lastSeenVal is DateTime) {
      lastSeen = lastSeenVal;
    }

    if (lastSeen == null)
      return (AppLocalizations.of(context)?.bylANedavno_168d ?? 'Fallback');

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return (AppLocalizations.of(context)?.bylATolkoChto_9ac0 ?? 'Fallback');
    }

    if (difference.inMinutes < 60) {
      return AppLocalizations.of(context)?.lastSeenRecently ??
          'last seen recently';
    }

    final today = DateTime(now.year, now.month, now.day);
    final lastSeenDay = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);

    final hour = lastSeen.hour.toString().padLeft(2, '0');
    final minute = lastSeen.minute.toString().padLeft(2, '0');

    if (lastSeenDay == today) {
      return '${AppLocalizations.of(context)?.today ?? 'Today'} • $hour:$minute';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (lastSeenDay == yesterday) {
      return '${AppLocalizations.of(context)?.yesterday ?? 'Yesterday'} • $hour:$minute';
    }

    final day = lastSeen.day.toString().padLeft(2, '0');
    final month = lastSeen.month.toString().padLeft(2, '0');
    return '$day.$month.${lastSeen.year} • $hour:$minute';
  }

  Widget _buildAppBarSubtitle() {
    if (widget.chat.isFavorites || _isDeleted()) {
      return const SizedBox.shrink();
    }

    String statusText = '';
    dynamic icon;
    Color color = context.xaneoTextMuted;
    String? lottiePath;

    if (widget.chat.isPersonal) {
      if (_isBot()) {
        statusText = (AppLocalizations.of(context)?.bot_2712 ?? 'Fallback');
        icon = FontAwesomeIcons.robot;
      } else {
        if (_typingText != null) {
          statusText = _typingText!;
          color = const Color(0xFF38BDF8); // sky blue for typing
          lottiePath = _activeLottiePath;
        } else {
          statusText = _formatUserStatus(_otherUser);
          if (statusText ==
              (AppLocalizations.of(context)?.vSeti_d902 ?? 'Fallback')) {
            color = const Color(0xE64ADE80); // green for online
          }
        }
      }
    } else if (widget.chat.isGroup) {
      if (_typingUsers.isNotEmpty) {
        statusText = _typingUsers.values.join(', ');
        color = const Color(0xFF38BDF8); // sky blue for typing
        lottiePath = _typingLottiePaths.isNotEmpty
            ? _typingLottiePaths.values.first
            : null;
      } else {
        final rawMem = _otherUser?['members_count'];
        final membersCount = rawMem is int
            ? rawMem
            : (rawMem is num
                ? rawMem.toInt()
                : int.tryParse(rawMem?.toString() ?? '') ?? 0);
        final rawOnline = _otherUser?['online_count'];
        final onlineCount = rawOnline is int
            ? rawOnline
            : (rawOnline is num
                ? rawOnline.toInt()
                : int.tryParse(rawOnline?.toString() ?? '') ?? 0);

        statusText = _pluralizeParticipants(membersCount);
        if (onlineCount > 0) {
          statusText +=
              ' • $onlineCount ${AppLocalizations.of(context)?.online ?? 'online'}';
        }
      }
      icon = FontAwesomeIcons.users;
    } else if (widget.chat.isChannel) {
      final rawSub = _otherUser?['subscribers_count'];
      final subscribersCount = rawSub is int
          ? rawSub
          : (rawSub is num
              ? rawSub.toInt()
              : int.tryParse(rawSub?.toString() ?? '') ?? 0);
      statusText = _formatSubscribers(subscribersCount);
      icon = FontAwesomeIcons.bullhorn;
    }

    if (statusText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottiePath != null) ...[
            SizedBox(
              height: 14,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                child: Lottie.asset(
                  lottiePath,
                  fit: BoxFit.contain,
                  animate: !MediaQuery.disableAnimationsOf(context),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ] else if (icon != null) ...[
            FaIcon(
              icon,
              size: 11,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(UserModel? currentUser) {
    if (_localChatId == null) {
      return Center(
          child: Text(
              (AppLocalizations.of(context)?.chatNeNayden_ba4f ?? 'Fallback'),
              style: TextStyle(color: context.xaneoTextPrimary)));
    }

    return StreamBuilder<List<Message>>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        // Prevent full-screen loading spinner flicker when switching/re-subscribing to the stream
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(color: context.xaneoTextMuted));
        }

        final messages = snapshot.data ?? [];
        _loadedMessages = messages;
        if (!identical(_lastFloatingDateMessagesSnapshot, messages)) {
          _lastFloatingDateMessagesSnapshot = messages;
          _scheduleFloatingDateUpdate();
        }

        if (messages.isEmpty && _isHistoryLoading) {
          return Center(
              child: CircularProgressIndicator(color: context.xaneoTextMuted));
        }

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.lockOpen,
                    size: 40, color: context.xaneoOverlay(0.2)),
                SizedBox(height: 12),
                Text(
                  (AppLocalizations.of(context)
                          ?.napishitePervoeSoobschenie_8260 ??
                      'Fallback'),
                  style: TextStyle(color: context.xaneoTextMuted, fontSize: 14),
                ),
              ],
            ),
          );
        }

        if (!_isInitialLoadDone && messages.isNotEmpty) {
          _initialMessageIds.addAll(messages.map((m) => m.serverMessageId));
          _isInitialLoadDone = true;
        }

        final topPadding = MediaQuery.of(context).padding.top + 64 + 16;
        final bottomPadding = _messageListBottomPadding(context);
        final showSpinner = _isHistoryLoading && _hasMoreMessages;

        return NotificationListener<ScrollNotification>(
          onNotification: (_) {
            _scheduleFloatingDateUpdate();
            return false;
          },
          child: ListView.builder(
            key: _messageListKey,
            controller: _scrollController,
            padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
            reverse: true, // Newer messages at the bottom
            itemCount: messages.length + (showSpinner ? 1 : 0),
            cacheExtent:
                600, // Кешируем виджеты в пределах 600 пикселей для плавной прокрутки без пересборок
            itemBuilder: (context, index) {
              if (index == messages.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white54),
                      ),
                    ),
                  ),
                );
              }
              final msg = messages[index];
              final isMe = msg.senderId == currentUser?.username ||
                  msg.senderId == currentUser?.id.toString() ||
                  msg.senderId == 'me';
              final myName = (currentUser?.firstName != null &&
                      currentUser!.firstName!.isNotEmpty)
                  ? currentUser.firstName!
                  : (AppLocalizations.of(context)?.vy_0101 ?? 'Fallback');
              final otherFirstName =
                  widget.chat.otherUser?['first_name']?.toString() ??
                      widget.chat.otherUser?['firstName']?.toString() ??
                      widget.chat.otherUser?['name']?.toString();
              final otherName =
                  (otherFirstName != null && otherFirstName.isNotEmpty)
                      ? otherFirstName
                      : widget.chat.name;

              final senderProfile = _userProfiles[msg.senderId];
              final senderFirstName = senderProfile?['first_name']?.toString();
              final senderAvatar = senderProfile?['avatar']?.toString();
              final senderGradient =
                  senderProfile?['avatar_gradient']?.toString();

              final senderRealName = (isMe || widget.chat.isFavorites)
                  ? myName
                  : (widget.chat.isGroup
                      ? ((senderFirstName != null && senderFirstName.isNotEmpty)
                          ? senderFirstName
                          : msg.senderId)
                      : otherName);

              final bool isNewMessage =
                  _messagesToAnimate.contains(msg.serverMessageId);
              final isHighlighted =
                  msg.serverMessageId == _highlightedMessageId;

              bool showDateSeparator = false;
              if (index == messages.length - 1) {
                showDateSeparator = true;
              } else {
                final prevMsg =
                    messages[index + 1]; // Visually above (older message)
                final messageDate = msg.timestamp.toLocal();
                final previousDate = prevMsg.timestamp.toLocal();
                if (messageDate.year != previousDate.year ||
                    messageDate.month != previousDate.month ||
                    messageDate.day != previousDate.day) {
                  showDateSeparator = true;
                }
              }

              final messageWidget = AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                color: isHighlighted
                    ? Colors.indigo.withOpacity(0.24)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: NewMessageAnimator(
                  key: ValueKey('anim_${msg.id}'),
                  animate: isNewMessage,
                  animateSize:
                      msg.replyMarkup == null || msg.replyMarkup!.isEmpty,
                  onStartAnimating: isNewMessage
                      ? () {
                          _messagesToAnimate.remove(msg.serverMessageId);
                          _animatedMessageIds.add(msg.serverMessageId);
                        }
                      : null,
                  child: MessageBubble(
                    key: ValueKey('msg_${msg.id}'),
                    message: msg,
                    isMe: isMe,
                    isGroup: widget.chat.isGroup,
                    isChannel: widget.chat.isChannel,
                    channelName: widget.chat.name,
                    currentUser: currentUser,
                    jwtToken: _jwtToken,
                    senderRealName: senderRealName,
                    senderAvatar: senderAvatar,
                    senderGradient: senderGradient,
                    reactions: _messageReactions[msg.serverMessageId] ?? [],
                    myId: currentUser?.id?.toString(),
                    onToggleReaction: (emoji) => _toggleReaction(msg, emoji),
                    onLongPress: (messageToOptions) =>
                        _showMessageContextMenu(messageToOptions),
                    onReply: (messageToReply) {
                      setState(() {
                        _replyingToMessage = messageToReply;
                      });
                    },
                    onTapReplyQuote: (replyServerId) {
                      _scrollToReplyMessage(replyServerId);
                    },
                    onPlayMusicRequested: (selectedUrl) =>
                        context.read<PlaybackProvider>().playFromPlaylist(
                              _getMusicPlaylistFromChat(),
                              selectedUrl: selectedUrl,
                            ),
                    onInlineButtonTap: (buttonId, tappedMessage) async {
                      final serverId =
                          int.tryParse(tappedMessage.serverMessageId);
                      if (serverId == null)
                        return 'Сообщение ещё не отправлено';
                      return _chatService.activateBotCallback(
                          serverId, buttonId);
                    },
                  ),
                ),
              );

              if (showDateSeparator) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDateSeparator(msg.timestamp),
                    messageWidget,
                  ],
                );
              }

              return messageWidget;
            },
          ),
        );
      },
    );
  }

  double _messageListBottomPadding(BuildContext context) {
    final media = MediaQuery.of(context);
    var padding = 76.0 + media.padding.bottom;

    if (_replyingToMessage != null) padding += 68;
    if (_attachments.isNotEmpty) padding += 98;
    if (_isEmojiPickerVisible) {
      padding += min(
        _emojiPickerHeight,
        max(160.0, media.size.height - media.viewInsets.bottom - 140),
      );
    }

    return padding;
  }

  void _scrollToReplyMessage(String replyServerId) async {
    setState(() {
      _highlightedMessageId = replyServerId;
    });
    final idx = await _localChatRepo.getMessageIndexByServerId(
        widget.chat.id, replyServerId);
    if (idx != null && _scrollController.hasClients) {
      _scrollController.animateTo(
        idx * 65.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _highlightedMessageId == replyServerId) {
        setState(() {
          _highlightedMessageId = null;
        });
      }
    });
  }

  Widget _buildReplyPreviewBar(BuildContext context) {
    if (_replyingToMessage == null) return const SizedBox.shrink();

    final currentUser = context.read<AuthProvider>().user;
    final isMe = _replyingToMessage!.senderId == currentUser?.id?.toString() ||
        _replyingToMessage!.senderId == currentUser?.username;
    final senderName = isMe
        ? (AppLocalizations.of(context)?.vy_0101 ?? 'Fallback')
        : (widget.chat.isPersonal
            ? widget.chat.name
            : _replyingToMessage!.senderId);

    String textPreview = _replyingToMessage!.textContent;
    if (textPreview.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(textPreview);
        if (parsed is Map) {
          if (parsed['type'] == 'voice')
            textPreview =
                (AppLocalizations.of(context)?.golosovoeSoobschenie_4a85 ??
                    'Fallback');
          else if (parsed['type'] == 'video_message')
            textPreview =
                (AppLocalizations.of(context)?.videosoobschenie_57f1 ??
                    'Fallback');
          else if (parsed['type'] == 'file')
            textPreview =
                '📁 ${AppLocalizations.of(context)?.file ?? 'File'}: ${parsed['file_name'] ?? ''}';
          else if (parsed['type'] == 'todo_list')
            textPreview =
                (AppLocalizations.of(context)?.spisokZadach_cfa4 ?? 'Fallback');
          else if (parsed['type'] == 'poll')
            textPreview =
                (AppLocalizations.of(context)?.opros_5902 ?? 'Fallback');
        }
      } catch (_) {}
    }
    if (textPreview.isEmpty && _replyingToMessage!.fileUrl != null) {
      textPreview =
          (AppLocalizations.of(context)?.vlozhenie_2474 ?? 'Fallback');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFF3B82F6), width: 4),
        ),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.reply,
              size: 14, color: Color(0xFF3B82F6)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppLocalizations.of(context)?.reply ?? 'Reply'}: $senderName',
                  style: const TextStyle(
                    color: Color(0xFF60A5FA),
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  textPreview,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _replyingToMessage = null;
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.close, color: Colors.white54, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if ((widget.chat.isGroup || widget.chat.isChannel) && !_isMember) {
      return _buildJoinButton(context);
    }

    if (widget.chat.isChannel && _isMember && !_canWrite) {
      return _buildChannelSubscribedBar(context);
    }

    if (_replyingToMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildReplyPreviewBar(context),
          _buildInputArea(context),
        ],
      );
    }

    return _buildInputArea(context);
  }

  Widget _buildJoinButton(BuildContext context) {
    final String label = widget.chat.isChannel
        ? (AppLocalizations.of(context)?.prisoedinitsyaKKanalu_f863 ??
            'Fallback')
        : (AppLocalizations.of(context)?.prisoedinitsyaKGruppe_eb45 ??
            'Fallback');

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: _isJoining ? null : _handleJoinGroupOrChannel,
          child: Center(
            child: _isJoining
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.userPlus,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppStyles.fontFamily,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelSubscribedBar(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: Color(0xFF1B1B22),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const FaIcon(
            FontAwesomeIcons.bullhorn,
            color: Colors.white54,
            size: 16,
          ),
          const SizedBox(width: 10),
          Text(
            (AppLocalizations.of(context)?.vyPodpisany_5fb9 ?? 'Fallback'),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: AppStyles.fontFamily,
            ),
          ),
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _isJoining ? null : _handleUnsubscribeChannel,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: _isJoining
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: Colors.redAccent,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.arrowRightFromBracket,
                            color: Colors.redAccent,
                            size: 13,
                          ),
                          SizedBox(width: 6),
                          Text(
                            (AppLocalizations.of(context)?.otpisatsya_ee2d ??
                                'Fallback'),
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppStyles.fontFamily,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleJoinGroupOrChannel() async {
    if (_isJoining) return;
    setState(() {
      _isJoining = true;
    });

    try {
      final apiClient = context.read<ApiClient>();
      final groupChannelService = GroupChannelService(apiClient: apiClient);
      bool success = false;

      if (widget.chat.isGroup) {
        final groupId = int.tryParse(widget.chat.id.replaceFirst('group_', ''));
        if (groupId != null) {
          success = await groupChannelService.joinGroup(groupId);
        }
      } else if (widget.chat.isChannel) {
        final channelId =
            int.tryParse(widget.chat.id.replaceFirst('channel_', ''));
        if (channelId != null) {
          success = await groupChannelService
              .toggleChannelSubscription(channelId, subscribe: true);
        }
      }

      if (success) {
        await _ensureChatSavedLocally();
        if (mounted) {
          setState(() {
            _isMember = true;
            _isJoining = false;
          });
          _fetchChatDetails();
          // Загружаем сообщения, так как мы только что вступили
          _loadMoreMessages();
          if (_localChatId != null) {
            _sweepEncryptedMessages(_localChatId!);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.chat.isChannel
                  ? (AppLocalizations.of(context)
                          ?.vyUspeshnoPodpisalisNaKanal_9c99 ??
                      'Fallback')
                  : (AppLocalizations.of(context)
                          ?.vyUspeshnoVstupiliVGruppu_61a1 ??
                      'Fallback')),
              backgroundColor: const Color(0xFF6366F1),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isJoining = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((AppLocalizations.of(context)
                      ?.neUdalosPrisoedinitsyaPoprobuyteEsche_bce5 ??
                  'Fallback')),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error joining chat: $e');
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  Future<void> _handleUnsubscribeChannel() async {
    if (_isJoining) return;
    setState(() {
      _isJoining = true;
    });

    try {
      final apiClient = context.read<ApiClient>();
      final groupChannelService = GroupChannelService(apiClient: apiClient);
      final channelId =
          int.tryParse(widget.chat.id.replaceFirst('channel_', ''));
      bool success = false;

      if (channelId != null) {
        success = await groupChannelService.toggleChannelSubscription(channelId,
            subscribe: false);
      }

      if (success) {
        if (mounted) {
          setState(() {
            _isMember = false;
            _isJoining = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  (AppLocalizations.of(context)?.vyOtpisalisOtKanala_7698 ??
                      'Fallback')),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isJoining = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error unsubscribing channel: $e');
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000), // 0.15 opacity
            blurRadius: 25,
            spreadRadius: -5,
            offset: Offset(0, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.xaneoOverlay(0.13),
                context.xaneoOverlay(0.05),
              ],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                onTap: _closeEmojiPicker,
                style: TextStyle(
                    color: context.xaneoTextPrimary, fontSize: 15, height: 1.3),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                contextMenuBuilder: (context, editableTextState) {
                  final selection =
                      editableTextState.textEditingValue.selection;
                  final List<Widget> items = [];

                  if (editableTextState.cutEnabled) {
                    items.add(_buildToolbarButton(
                      icon: FontAwesomeIcons.scissors,
                      label: (AppLocalizations.of(context)?.vyrezat_a195 ??
                          'Fallback'),
                      onTap: () => editableTextState
                          .cutSelection(SelectionChangedCause.toolbar),
                    ));
                  }
                  if (editableTextState.copyEnabled) {
                    items.add(_buildToolbarButton(
                      icon: FontAwesomeIcons.copy,
                      label: (AppLocalizations.of(context)?.kopirovat_112b ??
                          'Fallback'),
                      onTap: () => editableTextState
                          .copySelection(SelectionChangedCause.toolbar),
                    ));
                  }
                  if (editableTextState.pasteEnabled) {
                    items.add(_buildToolbarButton(
                      icon: FontAwesomeIcons.clipboard,
                      label: (AppLocalizations.of(context)?.vstavit_dcc4 ??
                          'Fallback'),
                      onTap: () => editableTextState
                          .pasteText(SelectionChangedCause.toolbar),
                    ));
                  }
                  if (editableTextState.selectAllEnabled) {
                    items.add(_buildToolbarButton(
                      icon: FontAwesomeIcons.squareCheck,
                      label: (AppLocalizations.of(context)?.vybratVse_4d09 ??
                          'Fallback'),
                      onTap: () => editableTextState
                          .selectAll(SelectionChangedCause.toolbar),
                    ));
                  }

                  if (!selection.isCollapsed) {
                    items.addAll([
                      _buildToolbarButton(
                        icon: FontAwesomeIcons.bold,
                        label: (AppLocalizations.of(context)?.zhirnyy_7774 ??
                            'Fallback'),
                        onTap: () =>
                            _applyFormatting('**', '**', editableTextState),
                      ),
                      _buildToolbarButton(
                        icon: FontAwesomeIcons.italic,
                        label: (AppLocalizations.of(context)?.kursiv_e0b1 ??
                            'Fallback'),
                        onTap: () =>
                            _applyFormatting('*', '*', editableTextState),
                      ),
                      _buildToolbarButton(
                        icon: FontAwesomeIcons.code,
                        label: (AppLocalizations.of(context)?.kod_3f34 ??
                            'Fallback'),
                        onTap: () =>
                            _applyFormatting('`', '`', editableTextState),
                      ),
                      _buildToolbarButton(
                        icon: FontAwesomeIcons.strikethrough,
                        label: (AppLocalizations.of(context)?.zacherknut_02fc ??
                            'Fallback'),
                        onTap: () =>
                            _applyFormatting('~~', '~~', editableTextState),
                      ),
                    ]);
                  }

                  if (items.isEmpty) return const SizedBox.shrink();

                  final List<Widget> rowChildren = [];
                  for (int i = 0; i < items.length; i++) {
                    rowChildren.add(items[i]);
                    if (i < items.length - 1) {
                      rowChildren.add(_buildToolbarDivider());
                    }
                  }

                  return TextSelectionToolbar(
                    anchorAbove:
                        editableTextState.contextMenuAnchors.primaryAnchor,
                    anchorBelow:
                        editableTextState.contextMenuAnchors.secondaryAnchor ??
                            editableTextState.contextMenuAnchors.primaryAnchor,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 32,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: rowChildren,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                decoration: InputDecoration(
                  hintText: (AppLocalizations.of(context)?.soobschenie_8b9b ??
                      'Fallback'),
                  hintStyle:
                      TextStyle(color: context.xaneoTextMuted, fontSize: 15),
                  filled: true,
                  fillColor: Colors.transparent,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: context.xaneoDivider,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: context.xaneoDivider,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  prefixIcon: Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 4, bottom: 2),
                    child: Align(
                      alignment: Alignment.center,
                      widthFactor: 1.0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: _toggleEmojiPicker,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            child: FaIcon(
                              _isEmojiPickerVisible
                                  ? FontAwesomeIcons.keyboard
                                  : FontAwesomeIcons.faceSmile,
                              key: ValueKey(_isEmojiPickerVisible),
                              color: Colors.white.withValues(alpha: 0.55),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_botCommands.isNotEmpty) ...[
                        Tooltip(
                          message: 'Команды бота',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: _showBotCommandsMenu,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Transform.rotate(
                                  angle: pi / 6,
                                  child: FaIcon(
                                    FontAwesomeIcons.slash,
                                    color: Colors.white.withValues(alpha: 0.65),
                                    size: 17,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                      ],
                      // 1. Attach Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: _showAttachmentMenu,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FaIcon(
                              FontAwesomeIcons.plus,
                              color: Colors.white.withValues(alpha: 0.65),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // 2. Dynamic Send / Mic Button
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 6, bottom: 2, top: 2),
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _messageController,
                          builder: (context, value, child) {
                            final hasText = value.text.trim().isNotEmpty ||
                                _attachments.isNotEmpty;
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: hasText
                                  ? GestureDetector(
                                      key: const ValueKey('send'),
                                      onTap: _sendMessage,
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.arrowUp,
                                            color: Colors.black,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      key: const ValueKey('mic_video_toggle'),
                                      onLongPressStart: (_) async {
                                        _isHoldingButton = true;
                                        if (_isVoiceMode) {
                                          await _startRecording();
                                        } else {
                                          await _startVideoRecording();
                                        }
                                      },
                                      onLongPressMoveUpdate: (details) {
                                        if (_isVoiceMode && _isRecording) {
                                          setState(() {
                                            _dragOffset = details
                                                .offsetFromOrigin.dx
                                                .clamp(-120.0, 0.0);
                                          });
                                          if (_dragOffset < -100) {
                                            _isHoldingButton = false;
                                            _cancelRecording();
                                          }
                                        } else if (!_isVoiceMode &&
                                            _isRecordingVideo) {
                                          setState(() {
                                            _dragOffset = details
                                                .offsetFromOrigin.dx
                                                .clamp(-120.0, 0.0);
                                          });
                                          if (_dragOffset < -100) {
                                            _isHoldingButton = false;
                                            _cancelVideoRecording();
                                          }
                                        }
                                      },
                                      onLongPressEnd: (_) async {
                                        _isHoldingButton = false;
                                        if (_isVoiceMode && _isRecording) {
                                          await _stopAndSendRecording();
                                        } else if (!_isVoiceMode &&
                                            _isRecordingVideo) {
                                          await _stopAndSendVideoRecording();
                                        }
                                      },
                                      onLongPressCancel: () async {
                                        _isHoldingButton = false;
                                        if (_isVoiceMode) {
                                          await _cancelRecording();
                                        } else {
                                          await _cancelVideoRecording();
                                        }
                                      },
                                      onTap: () {
                                        setState(() {
                                          _isVoiceMode = !_isVoiceMode;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width:
                                            (_isRecording || _isRecordingVideo)
                                                ? 42
                                                : 38,
                                        height:
                                            (_isRecording || _isRecordingVideo)
                                                ? 42
                                                : 38,
                                        decoration: BoxDecoration(
                                          color: (_isRecording ||
                                                  _isRecordingVideo)
                                              ? Colors.red
                                              : Colors.white
                                                  .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            transitionBuilder: (Widget child,
                                                Animation<double> animation) {
                                              return RotationTransition(
                                                turns: child.key ==
                                                        const ValueKey('mic')
                                                    ? Tween<double>(
                                                            begin: 0.15,
                                                            end: 0.0)
                                                        .animate(animation)
                                                    : Tween<double>(
                                                            begin: -0.15,
                                                            end: 0.0)
                                                        .animate(animation),
                                                child: ScaleTransition(
                                                  scale: animation,
                                                  child: FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: FaIcon(
                                              _isVoiceMode
                                                  ? FontAwesomeIcons.microphone
                                                  : FontAwesomeIcons.video,
                                              key: ValueKey(_isVoiceMode
                                                  ? 'mic'
                                                  : 'video'),
                                              color: Colors.white,
                                              size: (_isRecording ||
                                                      _isRecordingVideo)
                                                  ? 18
                                                  : 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  suffixIconConstraints: BoxConstraints(
                    minWidth: 80,
                    minHeight: 44,
                  ),
                ),
              ),
              if (_isRecording)
                Positioned(
                  left: 4,
                  top: 4,
                  bottom: 4,
                  right: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      color: const Color(0xFF161618),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const _BlinkingRedDot(),
                          const SizedBox(width: 10),
                          Text(
                            _formatRecordingDuration(_recordingDurationSeconds),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Transform.translate(
                            offset: Offset(_dragOffset, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chevron_left,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 16,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  (AppLocalizations.of(context)
                                          ?.smahniteDlyaOtmeny_e976 ??
                                      'Fallback'),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_isRecordingVideo)
                Positioned(
                  left: 4,
                  top: 4,
                  bottom: 4,
                  right: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      color: const Color(0xFF161618),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const _BlinkingRedDot(),
                          const SizedBox(width: 10),
                          Text(
                            _formatRecordingDuration(
                                _videoRecordingDurationSeconds.toInt()),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Transform.translate(
                            offset: Offset(_dragOffset, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chevron_left,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 16,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  (AppLocalizations.of(context)
                                          ?.smahniteDlyaOtmeny_e976 ??
                                      'Fallback'),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required FaIconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarDivider() {
    return Container(
      width: 1,
      height: 18,
      color: Colors.white.withOpacity(0.12),
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Future<void> _fetchChatDetails() async {
    if (widget.chat.isFavorites || widget.chat.isPersonal) {
      return;
    }

    try {
      final apiClient = context.read<ApiClient>();
      final String endpoint;
      if (widget.chat.isGroup) {
        final groupId = widget.chat.id.replaceFirst('group_', '');
        endpoint = '/groups/$groupId/';
      } else if (widget.chat.isChannel) {
        final channelId = widget.chat.id.replaceFirst('channel_', '');
        endpoint = '/channels/$channelId/';
      } else {
        return;
      }

      final response = await apiClient.get(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final fetchedGradient = data['avatar_gradient']?.toString() ??
              data['gradient']?.toString();
          final fetchedAvatar =
              data['avatar']?.toString() ?? data['avatar_url']?.toString();
          final fetchedName =
              data['name']?.toString() ?? data['title']?.toString();

          if (data['members'] is List) {
            for (final m in (data['members'] as List)) {
              if (m is Map) {
                final username = m['username']?.toString();
                final firstName = m['first_name']?.toString();
                final avatar =
                    m['avatar']?.toString() ?? m['avatar_url']?.toString();
                final gradient = m['avatar_gradient']?.toString();

                if (username != null && username.isNotEmpty) {
                  _userProfiles[username] = {
                    'first_name': (firstName != null && firstName.isNotEmpty)
                        ? firstName
                        : username,
                    'avatar': avatar,
                    'avatar_gradient': gradient,
                  };
                }
              }
            }
          }

          final isOwner =
              data['is_creator'] == true || data['is_owner'] == true;
          final isMember = data['is_member'] == true ||
              data['is_joined'] == true ||
              data['is_subscribed'] == true ||
              isOwner;

          bool canWrite = true;
          if (widget.chat.isChannel) {
            canWrite = data['can_post'] == true ||
                data['can_write'] == true ||
                data['is_admin'] == true ||
                isOwner;
          } else if (widget.chat.isGroup) {
            canWrite = isMember &&
                (data['can_post'] != false && data['can_write'] != false);
          }

          final existingOtherUser =
              Map<String, dynamic>.from(widget.chat.otherUser ?? {});
          existingOtherUser['user_profiles'] = _userProfiles;
          existingOtherUser['is_member'] = isMember;
          existingOtherUser['can_write'] = canWrite;
          if (data['description'] != null) {
            existingOtherUser['description'] = data['description'];
          }
          if (data['username'] != null) {
            existingOtherUser['username'] = data['username'];
          }
          if (data['members_count'] != null) {
            existingOtherUser['members_count'] = data['members_count'];
          }
          if (data['subscribers_count'] != null) {
            existingOtherUser['subscribers_count'] = data['subscribers_count'];
          } else if (data['subscribersCount'] != null) {
            existingOtherUser['subscribers_count'] = data['subscribersCount'];
          }

          final updatedChat = widget.chat.copyWith(
            name: (fetchedName != null && fetchedName.isNotEmpty)
                ? fetchedName
                : widget.chat.name,
            avatar: fetchedAvatar ?? widget.chat.avatar,
            avatarGradient: fetchedGradient ?? widget.chat.avatarGradient,
            otherUser: existingOtherUser,
          );

          // Сохраняем обновленный чат в локальной БД (с установленным флагом членства)
          await _localChatRepo.saveChat(updatedChat);

          if (mounted) {
            setState(() {
              _otherUser = existingOtherUser;
              _isOwner = isOwner;
              _isMember = isMember;
              _canWrite = canWrite;
              _isEphemeralPreview = !isMember;
              if (fetchedName != null && fetchedName.isNotEmpty) {
                _chatName = fetchedName;
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching chat details: $e');
      bool shouldDelete = false;
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 403 || statusCode == 404) {
          shouldDelete = true;
        }
      } else if (e.toString().contains('403') || e.toString().contains('404')) {
        shouldDelete = true;
      }

      if (shouldDelete) {
        if (!_isEphemeralPreview) {
          await _localChatRepo.deleteChatByServerId(widget.chat.id);
        }
        if (mounted) {
          setState(() {
            _isEphemeralPreview = true;
            _localChatId = null;
            _isMember = false;
          });
        }
      }
    }
  }

  Future<void> _showCurrentChatContextMenu() async {
    final action = await ChatContextMenu.show(
      context: context,
      isPinned: _isChatPinned,
      isArchived: widget.chat.isArchived,
      isMuted: _isChatMuted,
      canDelete: !widget.chat.isFavorites,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case ChatContextAction.pin:
        await _setCurrentChatPinned(!_isChatPinned);
      case ChatContextAction.archive:
        await _setCurrentChatArchived(!widget.chat.isArchived);
      case ChatContextAction.mute:
        await _setCurrentChatMuted(!_isChatMuted);
      case ChatContextAction.clearHistory:
        await _confirmClearHistory();
      case ChatContextAction.delete:
        await _confirmDeleteChat();
    }
  }

  Future<void> _setCurrentChatPinned(bool isPinned) async {
    final success = await _chatService.pinChat(widget.chat.id, isPinned);
    if (!mounted) return;
    if (!success) {
      _showCurrentChatActionError();
      return;
    }
    await _localChatRepo.updateChatSettings(
      widget.chat.id,
      isPinned: isPinned,
    );
    if (mounted) setState(() => _isChatPinned = isPinned);
  }

  Future<void> _setCurrentChatMuted(bool isMuted) async {
    final success = await _chatService.muteChat(widget.chat.id, isMuted);
    if (!mounted) return;
    if (!success) {
      _showCurrentChatActionError();
      return;
    }
    await _localChatRepo.updateChatSettings(
      widget.chat.id,
      isMuted: isMuted,
    );
    if (mounted) setState(() => _isChatMuted = isMuted);
  }

  Future<void> _setCurrentChatArchived(bool isArchived) async {
    final success = await _chatService.archiveChat(widget.chat.id, isArchived);
    if (!mounted) return;
    if (!success) {
      _showCurrentChatActionError();
      return;
    }

    await _localChatRepo.updateArchiveStatus(widget.chat.id, isArchived);
    if (isArchived) {
      await _localChatRepo.updateChatSettings(
        widget.chat.id,
        isPinned: false,
        isMuted: true,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _showCurrentChatActionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.serverError ?? 'Server error',
        ),
        backgroundColor: AppStyles.errorColor,
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    final List<PopupMenuEntry<String>> items = [];

    PopupMenuItem<String> buildItem({
      required String value,
      required FaIconData icon,
      required String text,
      bool isDanger = false,
    }) {
      return PopupMenuItem<String>(
        value: value,
        height: 44,
        child: Row(
          children: [
            FaIcon(
              icon,
              size: 16,
              color: isDanger ? Colors.redAccent : Colors.white70,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDanger ? Colors.redAccent : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.chat.isPersonal) {
      items.add(buildItem(
        value: 'search',
        icon: FontAwesomeIcons.magnifyingGlass,
        text: (AppLocalizations.of(context)?.poisk_bfc9 ?? 'Fallback'),
      ));
      items.add(buildItem(
        value: 'clear',
        icon: FontAwesomeIcons.trash,
        text:
            (AppLocalizations.of(context)?.ochistitIstoriyu_837a ?? 'Fallback'),
      ));
      if (!_isBot() && !_isDeleted()) {
        items.add(buildItem(
          value: 'delete',
          icon: FontAwesomeIcons.trashCan,
          text: (AppLocalizations.of(context)?.udalitChat_4b2b ?? 'Fallback'),
          isDanger: true,
        ));
      }
    } else if (widget.chat.isFavorites) {
      items.add(buildItem(
        value: 'search',
        icon: FontAwesomeIcons.magnifyingGlass,
        text: (AppLocalizations.of(context)?.poisk_bfc9 ?? 'Fallback'),
      ));
      items.add(buildItem(
        value: 'clear',
        icon: FontAwesomeIcons.trash,
        text:
            (AppLocalizations.of(context)?.ochistitIstoriyu_837a ?? 'Fallback'),
      ));
    } else if (widget.chat.isChannel) {
      if (_isOwner) {
        items.add(buildItem(
          value: 'clear',
          icon: FontAwesomeIcons.trash,
          text: (AppLocalizations.of(context)?.ochistitIstoriyu_837a ??
              'Fallback'),
        ));
        items.add(buildItem(
          value: 'search',
          icon: FontAwesomeIcons.magnifyingGlass,
          text: (AppLocalizations.of(context)?.poisk_bfc9 ?? 'Fallback'),
        ));
        items.add(buildItem(
          value: 'delete',
          icon: FontAwesomeIcons.trashCan,
          text: (AppLocalizations.of(context)?.udalitKanal_482f ?? 'Fallback'),
          isDanger: true,
        ));
      } else {
        items.add(buildItem(
          value: 'search',
          icon: FontAwesomeIcons.magnifyingGlass,
          text: (AppLocalizations.of(context)?.poisk_bfc9 ?? 'Fallback'),
        ));
        items.add(buildItem(
          value: 'report',
          icon: FontAwesomeIcons.flag,
          text:
              (AppLocalizations.of(context)?.pozhalovatsya_a7d9 ?? 'Fallback'),
        ));
      }
    } else if (widget.chat.isGroup) {
      if (_isOwner) {
        items.add(buildItem(
          value: 'edit',
          icon: FontAwesomeIcons.pen,
          text: (AppLocalizations.of(context)?.redaktirovatGruppu_e40a ??
              'Fallback'),
        ));
        items.add(buildItem(
          value: 'search',
          icon: FontAwesomeIcons.magnifyingGlass,
          text: (AppLocalizations.of(context)?.poisk_bfc9 ?? 'Fallback'),
        ));
        items.add(buildItem(
          value: 'clear',
          icon: FontAwesomeIcons.trash,
          text: (AppLocalizations.of(context)?.ochistitIstoriyu_837a ??
              'Fallback'),
        ));
        items.add(buildItem(
          value: 'delete',
          icon: FontAwesomeIcons.trashCan,
          text: (AppLocalizations.of(context)?.udalitGruppu_dff8 ?? 'Fallback'),
          isDanger: true,
        ));
        items.add(buildItem(
          value: 'leave',
          icon: FontAwesomeIcons.rightFromBracket,
          text:
              (AppLocalizations.of(context)?.pokinutGruppu_e6ce ?? 'Fallback'),
          isDanger: true,
        ));
      } else {
        items.add(buildItem(
          value: 'search',
          icon: FontAwesomeIcons.magnifyingGlass,
          text: (AppLocalizations.of(context)?.poisk_bfc9 ?? 'Fallback'),
        ));
        items.add(buildItem(
          value: 'clear',
          icon: FontAwesomeIcons.trash,
          text: (AppLocalizations.of(context)?.ochistitIstoriyu_837a ??
              'Fallback'),
        ));
        items.add(buildItem(
          value: 'report',
          icon: FontAwesomeIcons.flag,
          text:
              (AppLocalizations.of(context)?.pozhalovatsya_a7d9 ?? 'Fallback'),
        ));
        items.add(buildItem(
          value: 'leave',
          icon: FontAwesomeIcons.rightFromBracket,
          text:
              (AppLocalizations.of(context)?.pokinutGruppu_e6ce ?? 'Fallback'),
          isDanger: true,
        ));
      }
    }

    return items;
  }

  void _toggleReaction(Message message, String emoji) {
    final currentUser = context.read<AuthProvider>().user;
    final myId = currentUser?.id;
    if (currentUser == null || myId == null) return;

    final key = message.serverMessageId;
    final reactions = List<dynamic>.from(_messageReactions[key] ?? []);
    final existingIndex = reactions.indexWhere((r) {
      final rUserId = r['user_id'] is int
          ? r['user_id']
          : int.tryParse(r['user_id']?.toString() ?? '');
      return rUserId == myId && r['emoji'] == emoji;
    });

    final isRemove = existingIndex != -1;

    // 1. Оптимистичное обновление UI
    setState(() {
      if (isRemove) {
        reactions.removeAt(existingIndex);
      } else {
        reactions.add({
          'user_id': myId,
          'user_username': currentUser.username,
          'user_first_name': currentUser.firstName ?? currentUser.username,
          'user_avatar': currentUser.avatar ?? '',
          'user_avatar_gradient': currentUser.avatarGradient ?? '',
          'emoji': emoji,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      _messageReactions[key] = reactions;
    });
    _saveCachedReactions();

    final parsedServerMsgId = int.tryParse(message.serverMessageId);
    final msgId = parsedServerMsgId ?? message.id;
    final chatIdParsed = int.tryParse(widget.chat.id);

    // 2. Отправка через WebSocket с полными параметрами
    _chatWebSocketService.send({
      'type': isRemove ? 'remove_reaction' : 'add_reaction',
      'action': isRemove ? 'remove' : 'add',
      'message_id': msgId,
      'chat_id': chatIdParsed ?? widget.chat.id,
      'emoji': emoji,
    });

    // 3. Fallback через REST API
    try {
      final apiClient = context.read<ApiClient>();
      () async {
        try {
          if (isRemove) {
            await apiClient.delete(
              '/chats/${widget.chat.id}/messages/$msgId/reactions/',
              data: {'emoji': emoji},
            );
          } else {
            await apiClient.post(
              '/chats/${widget.chat.id}/messages/$msgId/reactions/',
              data: {'emoji': emoji},
            );
          }
        } catch (_) {}
      }();
    } catch (_) {}
  }

  Set<String> _getMyReactionEmojis(Message message) {
    final currentUser = context.read<AuthProvider>().user;
    final myId = currentUser?.id;
    if (myId == null) return {};

    final key = message.serverMessageId;
    final reactions = List<dynamic>.from(_messageReactions[key] ?? []);
    final myReactionEmojis = <String>{};

    for (final r in reactions) {
      if (r is Map) {
        final uId = r['user_id'] is int
            ? r['user_id']
            : int.tryParse(r['user_id']?.toString() ?? '');
        if (uId == myId) {
          final emoji = r['emoji']?.toString();
          if (emoji != null) myReactionEmojis.add(emoji);
        }
      }
    }
    return myReactionEmojis;
  }

  void _showMessageContextMenu(Message message) {
    final myReactionEmojis = _getMyReactionEmojis(message);

    ChatMessageContextMenuModal.show(
      context: context,
      message: message,
      myReactionEmojis: myReactionEmojis,
      onSelectEmoji: (emoji) => _toggleReaction(message, emoji),
      onReply: (msg) {
        setState(() {
          _replyingToMessage = msg;
        });
      },
      onShowFullEmojiPicker: (msg) => _showFullEmojiPicker(msg),
    );
  }

  void _showFullEmojiPicker(Message message) {
    final myReactionEmojis = _getMyReactionEmojis(message);

    FullEmojiPickerModal.show(
      context: context,
      myReactionEmojis: myReactionEmojis,
      onSelectEmoji: (emoji) => _toggleReaction(message, emoji),
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'search':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((AppLocalizations.of(context)
                    ?.poiskSoobscheniyVremennoNedostupenV_4443 ??
                'Fallback')),
            backgroundColor: Color(0xFF1E1E22),
          ),
        );
        break;
      case 'clear':
        _confirmClearHistory();
        break;
      case 'delete':
        _confirmDeleteChat();
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((AppLocalizations.of(context)
                    ?.zhalobaOtpravlenaModeratoram_4547 ??
                'Fallback')),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((AppLocalizations.of(context)
                    ?.redaktirovanieGruppyVremennoNedostupnoV_05d0 ??
                'Fallback')),
            backgroundColor: Color(0xFF1E1E22),
          ),
        );
        break;
      case 'leave':
        _confirmLeaveGroup();
        break;
    }
  }

  Future<void> _confirmClearHistory() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ChatActionConfirmationModal.confirm(
      context: context,
      title: l10n.clearHistory,
      message: l10n.vyUverenyChtoHotiteOchistit_7c3a,
      confirmLabel: l10n.ochistit_7074,
    );

    if (confirmed) {
      await _clearHistory();
    }
  }

  Future<void> _clearHistory() async {
    try {
      final String chatType;
      if (widget.chat.isFavorites) {
        chatType = 'favorites';
      } else if (widget.chat.isChannel) {
        chatType = 'channel';
      } else if (widget.chat.isGroup) {
        chatType = 'group';
      } else {
        chatType = 'personal';
      }

      var chatId = widget.chat.id;
      if (chatId == 'favorites') {
        final userId = context.read<AuthProvider>().user?.id;
        if (userId != null) chatId = 'favorites_user_$userId';
      }
      final success = await _chatService.clearChatHistory(
        chatId,
        chatType,
      );

      if (!success) {
        if (mounted) _showCurrentChatActionError();
        return;
      }

      final localId = _localChatId;
      if (localId != null) {
        await _localChatRepo.deleteMessagesForChat(localId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)?.clearHistory ?? 'Clear history'}: "${localizedChatName(context, widget.chat)}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)?.clearHistory ?? 'Clear history'}: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteChat() async {
    final String titleText;
    final String contentText;
    if (widget.chat.isChannel) {
      titleText =
          (AppLocalizations.of(context)?.udalitKanal_482f ?? 'Fallback');
      contentText =
          '$titleText "${localizedChatName(context, widget.chat)}". ${AppLocalizations.of(context)?.irreversibleAction ?? 'Irreversible action'}.';
    } else if (widget.chat.isGroup) {
      titleText =
          (AppLocalizations.of(context)?.udalitGruppu_dff8 ?? 'Fallback');
      contentText =
          '$titleText "${localizedChatName(context, widget.chat)}". ${AppLocalizations.of(context)?.irreversibleAction ?? 'Irreversible action'}.';
    } else {
      titleText = (AppLocalizations.of(context)?.udalitChat_4b2b ?? 'Fallback');
      contentText =
          '$titleText "${localizedChatName(context, widget.chat)}". ${AppLocalizations.of(context)?.irreversibleAction ?? 'Irreversible action'}.';
    }

    final confirmed = await ChatActionConfirmationModal.confirm(
      context: context,
      title: titleText,
      message: contentText,
      confirmLabel: (AppLocalizations.of(context)?.udalit_ed2b ?? 'Delete'),
    );

    if (confirmed) {
      await _deleteChatAction();
    }
  }

  Future<void> _deleteChatAction() async {
    try {
      final success = await _chatService.deleteChat(widget.chat.id);
      if (!success) {
        if (mounted) _showCurrentChatActionError();
        return;
      }
      await _localChatRepo.deleteChatByServerId(widget.chat.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)?.deleteChat ?? 'Delete chat'}: "${localizedChatName(context, widget.chat)}"'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error deleting chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)?.deleteChat ?? 'Delete chat'}: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _confirmLeaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E22),
        title: Text(
            (AppLocalizations.of(context)?.pokinutGruppu_e6ce ?? 'Fallback'),
            style: TextStyle(color: Colors.white)),
        content: Text(
          '${AppLocalizations.of(context)?.leaveGroup ?? 'Leave group'}: "${localizedChatName(context, widget.chat)}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
                (AppLocalizations.of(context)?.otmena_987b ?? 'Fallback'),
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
                (AppLocalizations.of(context)?.vyyti_0f05 ?? 'Fallback'),
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _leaveGroupAction();
    }
  }

  Future<void> _leaveGroupAction() async {
    try {
      final apiClient = context.read<ApiClient>();
      final groupId = widget.chat.id.replaceFirst('group_', '');

      final response = await apiClient.post('/groups/$groupId/leave/');

      if (response.statusCode == 200) {
        await _localChatRepo.deleteChatByServerId(widget.chat.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.leaveGroup ?? 'Leave group'}: "${localizedChatName(context, widget.chat)}"'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('Error leaving group: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)?.leaveGroup ?? 'Leave group'}: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}

class FormattedTextEditingController extends TextEditingController {
  FormattedTextEditingController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];
    final RegExp regExp = RegExp(
      r'(\*\*(.*?)\*\*)|(\*(.*?)\*)|(__(.*?)__)|(_(.*?)_)|(`(.*?)`)|(~~(.*?)~~)|([^\*_`~]+|[\*_`~])',
    );

    final Iterable<Match> matches = regExp.allMatches(text);

    final invisibleStyle = (style ?? const TextStyle()).copyWith(
      color: Colors.transparent,
      fontSize: 0.1,
    );

    for (final Match match in matches) {
      final String fullMatch = match.group(0) ?? '';

      // Match bold: **text**
      if (match.group(2) != null) {
        final content = match.group(2)!;
        children.add(TextSpan(text: '**', style: invisibleStyle));
        children.add(TextSpan(
          text: content,
          style: style?.copyWith(fontWeight: FontWeight.bold) ??
              const TextStyle(fontWeight: FontWeight.bold),
        ));
        children.add(TextSpan(text: '**', style: invisibleStyle));
      }
      // Match italic: *text*
      else if (match.group(4) != null) {
        final content = match.group(4)!;
        children.add(TextSpan(text: '*', style: invisibleStyle));
        children.add(TextSpan(
          text: content,
          style: style?.copyWith(fontStyle: FontStyle.italic) ??
              const TextStyle(fontStyle: FontStyle.italic),
        ));
        children.add(TextSpan(text: '*', style: invisibleStyle));
      }
      // Match underline: __text__
      else if (match.group(6) != null) {
        final content = match.group(6)!;
        children.add(TextSpan(text: '__', style: invisibleStyle));
        children.add(TextSpan(
          text: content,
          style: style?.copyWith(decoration: TextDecoration.underline) ??
              const TextStyle(decoration: TextDecoration.underline),
        ));
        children.add(TextSpan(text: '__', style: invisibleStyle));
      }
      // Match italic: _text_
      else if (match.group(8) != null) {
        final content = match.group(8)!;
        children.add(TextSpan(text: '_', style: invisibleStyle));
        children.add(TextSpan(
          text: content,
          style: style?.copyWith(fontStyle: FontStyle.italic) ??
              const TextStyle(fontStyle: FontStyle.italic),
        ));
        children.add(TextSpan(text: '_', style: invisibleStyle));
      }
      // Match code: `text`
      else if (match.group(10) != null) {
        final content = match.group(10)!;
        children.add(TextSpan(text: '`', style: invisibleStyle));
        children.add(TextSpan(
          text: content,
          style: style?.copyWith(
                fontFamily: 'monospace',
                backgroundColor: Colors.white.withOpacity(0.1),
              ) ??
              TextStyle(
                fontFamily: 'monospace',
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
        ));
        children.add(TextSpan(text: '`', style: invisibleStyle));
      }
      // Match strikethrough: ~~text~~
      else if (match.group(12) != null) {
        final content = match.group(12)!;
        children.add(TextSpan(text: '~~', style: invisibleStyle));
        children.add(TextSpan(
          text: content,
          style: style?.copyWith(decoration: TextDecoration.lineThrough) ??
              const TextStyle(decoration: TextDecoration.lineThrough),
        ));
        children.add(TextSpan(text: '~~', style: invisibleStyle));
      }
      // Plain text
      else {
        children.add(TextSpan(text: fullMatch, style: style));
      }
    }

    return TextSpan(style: style, children: children);
  }
}

class FormattedText extends StatelessWidget {
  final String content;
  final TextStyle baseStyle;

  const FormattedText({
    super.key,
    required this.content,
    required this.baseStyle,
  });

  static final RegExp _regExp = RegExp(
    r'(\*\*(.*?)\*\*)|(\*(.*?)\*)|(__(.*?)__)|(_(.*?)_)|(`(.*?)`)|(~~(.*?)~~)|([^\*_`~]+|[\*_`~])',
  );

  // Simple check: if the text has no formatting markers at all, skip regex
  static final RegExp _hasMarkers = RegExp(r'[*_`~]');

  // Cached code-highlight background color
  static const _codeBg = Color(0x1FFFFFFF); // ~0.12 white
  static const _codeColor = Color(0xFF4ADE80);

  // ── Static memoization cache ────────────────────────────────────
  // Key: content string, Value: pre-built TextSpan.
  // Avoids re-running regex on every build frame during scroll.
  // Bounded to last 200 messages to prevent unbounded memory growth.
  static final Map<String, TextSpan> _cache = {};
  static const _maxCacheSize = 200;

  TextSpan _buildSpans() {
    // Check cache first
    final cached = _cache[content];
    if (cached != null) return cached;

    final rootStyle = baseStyle.copyWith(fontFamily: AppStyles.fontFamily);

    // Fast path: plain text (most messages)
    if (!_hasMarkers.hasMatch(content)) {
      final span = TextSpan(text: content, style: rootStyle);
      _addToCache(content, span);
      return span;
    }

    // Pre-compute style variants once (not per-match)
    final boldStyle = rootStyle.copyWith(fontWeight: FontWeight.bold);
    final italicStyle = rootStyle.copyWith(fontStyle: FontStyle.italic);
    final underlineStyle =
        rootStyle.copyWith(decoration: TextDecoration.underline);
    final codeStyle = rootStyle.copyWith(
      fontFamily: 'monospace',
      backgroundColor: _codeBg,
      color: _codeColor,
    );
    final strikeStyle =
        rootStyle.copyWith(decoration: TextDecoration.lineThrough);

    final List<TextSpan> spans = [];
    final matches = _regExp.allMatches(content);

    for (final Match match in matches) {
      final String fullMatch = match.group(0) ?? '';

      if (match.group(2) != null) {
        spans.add(TextSpan(text: match.group(2), style: boldStyle));
      } else if (match.group(4) != null) {
        spans.add(TextSpan(text: match.group(4), style: italicStyle));
      } else if (match.group(6) != null) {
        spans.add(TextSpan(text: match.group(6), style: underlineStyle));
      } else if (match.group(8) != null) {
        spans.add(TextSpan(text: match.group(8), style: italicStyle));
      } else if (match.group(10) != null) {
        spans.add(TextSpan(text: match.group(10), style: codeStyle));
      } else if (match.group(12) != null) {
        spans.add(TextSpan(text: match.group(12), style: strikeStyle));
      } else {
        spans.add(TextSpan(text: fullMatch, style: rootStyle));
      }
    }

    final result = TextSpan(style: rootStyle, children: spans);
    _addToCache(content, result);
    return result;
  }

  static void _addToCache(String key, TextSpan value) {
    if (_cache.length >= _maxCacheSize) {
      // Evict oldest entries (first 50)
      final keysToRemove = _cache.keys.take(50).toList();
      for (final k in keysToRemove) {
        _cache.remove(k);
      }
    }
    _cache[key] = value;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(text: _buildSpans());
  }
}

class NewMessageAnimator extends StatefulWidget {
  final Widget child;
  final bool animate;
  final bool animateSize;
  final VoidCallback? onStartAnimating;

  const NewMessageAnimator({
    super.key,
    required this.child,
    required this.animate,
    this.animateSize = true,
    this.onStartAnimating,
  });

  @override
  State<NewMessageAnimator> createState() => _NewMessageAnimatorState();
}

class _NewMessageAnimatorState extends State<NewMessageAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _sizeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _motionInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !widget.animate) {
      _controller.value = 1;
    } else if (!_motionInitialized) {
      _controller.forward();
      if (widget.onStartAnimating != null) {
        // Run after current frame layout pass is finished to avoid triggering setState warnings
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onStartAnimating!();
        });
      }
    }
    _motionInitialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animatedChild = FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );

    if (!widget.animateSize) return animatedChild;

    return SizeTransition(
      sizeFactor: _sizeAnimation,
      alignment: Alignment.bottomCenter,
      child: animatedChild,
    );
  }
}

class MessageBubble extends StatelessWidget {
  static const int _decodedJsonCacheLimit = 256;
  static final Map<String, Map<String, dynamic>?> _decodedJsonCache = {};

  final Message message;
  final bool isMe;
  final bool isGroup;
  final bool isChannel;
  final String? channelName;
  final UserModel? currentUser;
  final String? jwtToken;
  final String senderRealName;
  final String? senderAvatar;
  final String? senderGradient;
  final void Function(Message)? onReply;
  final void Function(String replyToId)? onTapReplyQuote;
  final List<dynamic> reactions;
  final String? myId;
  final void Function(String emoji)? onToggleReaction;
  final void Function(Message message)? onLongPress;
  final Future<void> Function(String selectedUrl)? onPlayMusicRequested;
  final Future<String?> Function(String buttonId, Message message)?
      onInlineButtonTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isGroup = false,
    this.isChannel = false,
    this.channelName,
    required this.currentUser,
    required this.jwtToken,
    required this.senderRealName,
    this.senderAvatar,
    this.senderGradient,
    this.onReply,
    this.onTapReplyQuote,
    this.reactions = const [],
    this.myId,
    this.onToggleReaction,
    this.onLongPress,
    this.onPlayMusicRequested,
    this.onInlineButtonTap,
  });

  static Map<String, dynamic>? _decodeJsonMap(String raw) {
    if (_decodedJsonCache.containsKey(raw)) {
      return _decodedJsonCache[raw];
    }

    Map<String, dynamic>? parsedMap;
    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map) {
        parsedMap = Map<String, dynamic>.from(parsed);
      }
    } catch (_) {}

    if (_decodedJsonCache.length >= _decodedJsonCacheLimit) {
      _decodedJsonCache.remove(_decodedJsonCache.keys.first);
    }
    _decodedJsonCache[raw] = parsedMap;
    return parsedMap;
  }

  Widget _buildImagePlaceholder({
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(
        color: Color(0xFF242428),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: Colors.white30,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildReplyQuote(BuildContext context) {
    final replyAuthor = message.replyAuthorName ??
        (AppLocalizations.of(context)?.soobschenie_3715 ?? 'Fallback');
    String replyText = message.replyText ?? '';

    if (replyText.trim().startsWith('{')) {
      final parsed = _decodeJsonMap(replyText);
      if (parsed?['type'] == 'voice')
        replyText = (AppLocalizations.of(context)?.golosovoeSoobschenie_4a85 ??
            'Fallback');
      else if (parsed?['type'] == 'video_message')
        replyText =
            (AppLocalizations.of(context)?.videosoobschenie_57f1 ?? 'Fallback');
      else if (parsed?['type'] == 'file')
        replyText =
            '📁 ${AppLocalizations.of(context)?.file ?? 'File'}: ${parsed?['file_name'] ?? ''}';
      else if (parsed?['type'] == 'todo_list')
        replyText =
            (AppLocalizations.of(context)?.spisokZadach_cfa4 ?? 'Fallback');
      else if (parsed?['type'] == 'poll')
        replyText = (AppLocalizations.of(context)?.opros_5902 ?? 'Fallback');
    }
    if (replyText.isEmpty)
      replyText = (AppLocalizations.of(context)?.vlozhenie_ef44 ?? 'Fallback');

    return GestureDetector(
      onTap: () {
        if (message.replyToId != null && message.replyToId!.isNotEmpty) {
          onTapReplyQuote?.call(message.replyToId!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isMe ? Colors.white70 : const Color(0xFF60A5FA),
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              replyAuthor,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : const Color(0xFF60A5FA),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              replyText,
              style: TextStyle(
                fontSize: 11.5,
                color: isMe ? Colors.white70 : Colors.white60,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollageWidget(BuildContext context, List<dynamic> filesList,
      String hostUrl, String? tokenToUse) {
    final List<Map<String, dynamic>> files = [];
    for (final item in filesList) {
      if (item is Map) {
        files.add(Map<String, dynamic>.from(item));
      }
    }

    if (files.isEmpty) return const SizedBox.shrink();

    // 1. Separate media and documents
    bool isMediaFile(Map<String, dynamic> fileData) {
      final fileName = (fileData['file_name'] ?? fileData['name'] ?? '')
          .toString()
          .toLowerCase();
      final mime = (fileData['mime_type'] ?? fileData['type'] ?? '')
          .toString()
          .toLowerCase();

      final isImage = mime.startsWith('image/') ||
          fileName.endsWith('.jpg') ||
          fileName.endsWith('.jpeg') ||
          fileName.endsWith('.png') ||
          fileName.endsWith('.gif') ||
          fileName.endsWith('.webp') ||
          fileName.endsWith('.bmp') ||
          fileName.endsWith('.svg');

      final isVideo = mime.startsWith('video/') ||
          fileName.endsWith('.mp4') ||
          fileName.endsWith('.avi') ||
          fileName.endsWith('.mov') ||
          fileName.endsWith('.wmv') ||
          fileName.endsWith('.flv') ||
          fileName.endsWith('.webm') ||
          fileName.endsWith('.mkv') ||
          fileName.endsWith('.loc_3gp') ||
          fileName.endsWith('.ogv') ||
          fileName.endsWith('.m4v');

      return isImage || isVideo;
    }

    final List<Map<String, dynamic>> mediaFiles = [];
    final List<Map<String, dynamic>> documentFiles = [];
    for (final item in files) {
      if (isMediaFile(item)) {
        mediaFiles.add(item);
      } else {
        documentFiles.add(item);
      }
    }

    // Helper to build document download card
    Widget buildDocumentCard(Map<String, dynamic> fileData) {
      final fileId = fileData['file_id']?.toString() ?? '';
      final fileName = fileData['file_name'] ?? fileData['name'] ?? 'file';
      final fileSize =
          fileData['file_size'] as int? ?? fileData['size'] as int? ?? 0;
      String fileUrlSuffix = fileData['file_url']?.toString() ?? '';
      if (fileUrlSuffix.isEmpty) {
        fileUrlSuffix = '/api/files/download/$fileId/';
      }

      String absoluteUrl = '';
      if (fileUrlSuffix.startsWith('http')) {
        absoluteUrl =
            '$fileUrlSuffix${tokenToUse != null ? (fileUrlSuffix.contains('?') ? "&token=$tokenToUse" : "?token=$tokenToUse") : ""}';
      } else {
        final prefix = fileUrlSuffix.startsWith('/') ? '' : '/';
        absoluteUrl =
            '$hostUrl$prefix$fileUrlSuffix${tokenToUse != null ? "?token=$tokenToUse" : ""}';
      }

      return GestureDetector(
        onTap: () => _downloadFileSilent(context, absoluteUrl, fileName),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const FaIcon(FontAwesomeIcons.fileLines,
                    color: Colors.white70, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatFileSize(fileSize, fileName),
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const FaIcon(FontAwesomeIcons.download,
                  color: Colors.white54, size: 14),
            ],
          ),
        ),
      );
    }

    Widget? collageWidget;
    if (mediaFiles.isNotEmpty) {
      final displayedFiles = mediaFiles.take(4).toList();
      final remainingCount = mediaFiles.length - displayedFiles.length;

      Widget buildMediaItem(Map<String, dynamic> fileData,
          {bool isLastWithOverlay = false}) {
        final fileId = fileData['file_id']?.toString() ?? '';
        final fileName = fileData['file_name'] ?? fileData['name'] ?? '';
        final mime = (fileData['mime_type'] ?? fileData['type'] ?? '')
            .toString()
            .toLowerCase();
        String fileUrlSuffix = fileData['file_url']?.toString() ?? '';
        if (fileUrlSuffix.isEmpty) {
          fileUrlSuffix = '/api/files/download/$fileId/';
        }

        String absoluteUrl = '';
        if (fileUrlSuffix.startsWith('http')) {
          absoluteUrl =
              '$fileUrlSuffix${tokenToUse != null ? (fileUrlSuffix.contains('?') ? "&token=$tokenToUse" : "?token=$tokenToUse") : ""}';
        } else {
          final prefix = fileUrlSuffix.startsWith('/') ? '' : '/';
          absoluteUrl =
              '$hostUrl$prefix$fileUrlSuffix${tokenToUse != null ? "?token=$tokenToUse" : ""}';
        }
        final localPath = fileData['local_path']?.toString();
        final localFile =
            localPath == null || localPath.isEmpty ? null : File(localPath);
        final hasLocalFile = localFile?.existsSync() == true;
        final mediaSource = hasLocalFile ? localPath! : absoluteUrl;

        final isVideo = mime.startsWith('video/') ||
            fileName.toLowerCase().endsWith('.mp4') ||
            fileName.toLowerCase().endsWith('.mov') ||
            fileName.toLowerCase().endsWith('.avi');

        Widget mediaWidget;
        if (isVideo) {
          mediaWidget = Stack(
            alignment: Alignment.center,
            children: [
              VideoThumbnailWidget(
                videoUrl: mediaSource,
                jwtToken: tokenToUse,
                width: 300,
                height: 300,
                borderRadius: BorderRadius.circular(8),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const FaIcon(FontAwesomeIcons.play,
                    color: Colors.white, size: 16),
              ),
            ],
          );
        } else {
          mediaWidget = hasLocalFile
              ? Image.file(
                  localFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImagePlaceholder(),
                )
              : Image.network(
                  absoluteUrl,
                  key: ValueKey('${absoluteUrl}_${tokenToUse ?? ""}'),
                  headers: tokenToUse != null
                      ? {'Authorization': 'Bearer $tokenToUse'}
                      : null,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black12,
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white54, size: 24),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildImagePlaceholder();
                  },
                );
        }

        return GestureDetector(
          onTap: () {
            if (isVideo) {
              _showFullScreenVideo(
                context,
                mediaSource,
                senderRealName,
                message.timestamp,
                fileName: fileName,
                downloadUrl: absoluteUrl,
              );
            } else {
              _showFullScreenImage(
                context,
                mediaSource,
                senderRealName,
                message.timestamp,
                fileName: fileName,
                downloadUrl: absoluteUrl,
              );
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              mediaWidget,
              if (isLastWithOverlay && remainingCount > 0)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Text(
                      '+$remainingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }

      final count = displayedFiles.length;
      double collageHeight = 200;
      if (count == 1) {
        collageHeight = 180;
      } else if (count == 2) {
        collageHeight = 120;
      } else {
        collageHeight = 220;
      }

      Widget grid;
      if (count == 1) {
        grid = ClipRRect(
          borderRadius: isMe ? _myCorners : _otherCorners,
          child: buildMediaItem(displayedFiles[0]),
        );
      } else if (count == 2) {
        grid = ClipRRect(
          borderRadius: isMe ? _myCorners : _otherCorners,
          child: Row(
            children: [
              Expanded(child: buildMediaItem(displayedFiles[0])),
              const SizedBox(width: 4),
              Expanded(child: buildMediaItem(displayedFiles[1])),
            ],
          ),
        );
      } else if (count == 3) {
        grid = ClipRRect(
          borderRadius: isMe ? _myCorners : _otherCorners,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: buildMediaItem(displayedFiles[0]),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(child: buildMediaItem(displayedFiles[1])),
                    const SizedBox(height: 4),
                    Expanded(child: buildMediaItem(displayedFiles[2])),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        grid = ClipRRect(
          borderRadius: isMe ? _myCorners : _otherCorners,
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              buildMediaItem(displayedFiles[0]),
              buildMediaItem(displayedFiles[1]),
              buildMediaItem(displayedFiles[2]),
              buildMediaItem(displayedFiles[3], isLastWithOverlay: true),
            ],
          ),
        );
      }

      collageWidget = Container(
        width: 250,
        height: collageHeight,
        margin: const EdgeInsets.only(bottom: 6),
        child: grid,
      );
    }

    if (collageWidget != null && documentFiles.isEmpty) {
      return collageWidget;
    } else if (collageWidget == null && documentFiles.isNotEmpty) {
      return Container(
        width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: documentFiles.map((doc) => buildDocumentCard(doc)).toList(),
        ),
      );
    } else if (collageWidget != null && documentFiles.isNotEmpty) {
      return Container(
        width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            collageWidget,
            const SizedBox(height: 4),
            ...documentFiles.map((doc) => buildDocumentCard(doc)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ── Pre-cached constants ─────────────────────────────────────────
  static const _systemIconColor = Color(0xB34ADE80); // ~0.7 green
  static const _checkColor = Color(0x4DFFFFFF); // ~0.3 white
  static const _checkReadColor = Color(0xFF4ADE80);

  static const _myCorners = BorderRadius.only(
    topLeft: Radius.circular(18),
    topRight: Radius.circular(18),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(4),
  );

  static const _otherCorners = BorderRadius.only(
    topLeft: Radius.circular(18),
    topRight: Radius.circular(18),
    bottomLeft: Radius.circular(4),
    bottomRight: Radius.circular(18),
  );

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildMessageStatusIcon(Message message, {Color? color}) {
    final isPending = message.serverMessageId.startsWith('temp_');
    if (isPending) {
      return FaIcon(
        FontAwesomeIcons.clock,
        size: 10,
        color: color ?? (message.isRead ? _checkReadColor : _checkColor),
      );
    }
    return FaIcon(
      message.isRead ? FontAwesomeIcons.checkDouble : FontAwesomeIcons.check,
      size: 10,
      color: message.isRead ? _checkReadColor : (color ?? _checkColor),
    );
  }

  String _formatFileSize(int bytes, [String? fileName]) {
    String extensionPrefix = '';
    if (fileName != null &&
        fileName.contains('.') &&
        !fileName.startsWith('.')) {
      final ext = fileName.split('.').last.trim().toUpperCase();
      if (ext.isNotEmpty && ext.length <= 12) {
        extensionPrefix = '$ext • ';
      }
    }
    if (bytes <= 0) return '${extensionPrefix}0 B';
    var suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '$extensionPrefix${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  Widget _buildDroplet({
    required Widget child,
    VoidCallback? onTap,
    bool isCircle = true,
  }) {
    final borderRadius = isCircle ? null : BorderRadius.circular(20);
    return Container(
      width: isCircle ? 40 : null,
      height: isCircle ? 40 : null,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: isCircle ? const CircleBorder() : null,
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: isCircle
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: isCircle ? Center(child: child) : child,
          ),
        ),
      ),
    );
  }

  Future<void> _showMediaActions(
    BuildContext context, {
    required String downloadUrl,
    required String fileName,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: sheetContext.xaneoSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sheetContext.xaneoDivider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.download_rounded,
                  color: sheetContext.xaneoTextSecondary,
                ),
                title: Text(
                  l10n.downloadVersion,
                  style: TextStyle(color: sheetContext.xaneoTextPrimary),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _downloadFileSilent(context, downloadUrl, fileName);
                },
              ),
              Divider(height: 1, color: sheetContext.xaneoDivider),
              ListTile(
                leading: Icon(
                  Icons.link_rounded,
                  color: sheetContext.xaneoTextSecondary,
                ),
                title: Text(
                  l10n.copy,
                  style: TextStyle(color: sheetContext.xaneoTextPrimary),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: downloadUrl));
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    String imageUrl,
    String senderName,
    DateTime timestamp, {
    required String fileName,
    required String downloadUrl,
  }) {
    final localImage = File(imageUrl);
    final hasLocalImage = localImage.existsSync();
    final timeStr = _formatTime(timestamp);
    final months = [
      (AppLocalizations.of(context)?.yanvarya_d861 ?? 'Fallback'),
      (AppLocalizations.of(context)?.fevralya_fcf9 ?? 'Fallback'),
      (AppLocalizations.of(context)?.marta_bb77 ?? 'Fallback'),
      (AppLocalizations.of(context)?.aprelya_2b5a ?? 'Fallback'),
      (AppLocalizations.of(context)?.maya_4dbb ?? 'Fallback'),
      (AppLocalizations.of(context)?.iyunya_adcb ?? 'Fallback'),
      (AppLocalizations.of(context)?.iyulya_3236 ?? 'Fallback'),
      (AppLocalizations.of(context)?.avgusta_e3aa ?? 'Fallback'),
      (AppLocalizations.of(context)?.sentyabrya_a146 ?? 'Fallback'),
      (AppLocalizations.of(context)?.oktyabrya_7abd ?? 'Fallback'),
      (AppLocalizations.of(context)?.noyabrya_6e78 ?? 'Fallback'),
      (AppLocalizations.of(context)?.dekabrya_29cc ?? 'Fallback')
    ];
    final dateStr =
        '${timestamp.day} ${months[timestamp.month - 1]} • $timeStr';

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (viewerContext, animation, secondaryAnimation) =>
            _FullScreenImageViewer(
          imageUrl: imageUrl,
          localImage: hasLocalImage ? localImage : null,
          jwtToken: jwtToken,
          senderName: senderName,
          dateText: dateStr,
          routeAnimation: animation,
          onShowMenu: (context) => _showMediaActions(
            context,
            downloadUrl: downloadUrl,
            fileName: fileName,
          ),
        ),
      ),
    );
  }

  Future<void> _downloadFileSilent(
    BuildContext context,
    String url,
    String fileName, {
    ValueChanged<double>? onProgress,
  }) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context)?.zagruzkaFayla_f817 ?? 'Downloading file'} $fileName'),
            duration: const Duration(seconds: 1)),
      );

      Directory? dir;
      try {
        if (Platform.isAndroid) {
          try {
            dir = Directory('/storage/emulated/0/Download/Xaneo');
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
          } catch (_) {
            final extDir = await getExternalStorageDirectory();
            if (extDir != null) {
              dir = Directory('${extDir.path}/Xaneo');
              if (!await dir.exists()) {
                await dir.create(recursive: true);
              }
            }
          }
        } else {
          final downloadsDir = await getDownloadsDirectory();
          if (downloadsDir != null) {
            dir = Directory('${downloadsDir.path}/Xaneo');
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
          }
        }
      } catch (_) {}

      dir ??= await getApplicationDocumentsDirectory();
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final savePath = '${dir.path}/$fileName';
      final dio = Dio();
      if (jwtToken != null && jwtToken!.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $jwtToken';
      }
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress?.call(received >= total ? 1.0 : received / total);
          }
        },
      );
      onProgress?.call(1.0);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.faylZagruzhenIPrikreplen_dc24 ?? 'File saved'}: $savePath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.oshibkaSkachivaniyaFayla_34ac ?? 'Download error'}: $e')),
        );
      }
    }
  }

  void _showFullScreenVideo(
    BuildContext context,
    String videoUrl,
    String senderName,
    DateTime timestamp, {
    required String fileName,
    required String downloadUrl,
  }) {
    final timeStr = _formatTime(timestamp);
    final months = [
      (AppLocalizations.of(context)?.yanvarya_d861 ?? 'Fallback'),
      (AppLocalizations.of(context)?.fevralya_fcf9 ?? 'Fallback'),
      (AppLocalizations.of(context)?.marta_bb77 ?? 'Fallback'),
      (AppLocalizations.of(context)?.aprelya_2b5a ?? 'Fallback'),
      (AppLocalizations.of(context)?.maya_4dbb ?? 'Fallback'),
      (AppLocalizations.of(context)?.iyunya_adcb ?? 'Fallback'),
      (AppLocalizations.of(context)?.iyulya_3236 ?? 'Fallback'),
      (AppLocalizations.of(context)?.avgusta_e3aa ?? 'Fallback'),
      (AppLocalizations.of(context)?.sentyabrya_a146 ?? 'Fallback'),
      (AppLocalizations.of(context)?.oktyabrya_7abd ?? 'Fallback'),
      (AppLocalizations.of(context)?.noyabrya_6e78 ?? 'Fallback'),
      (AppLocalizations.of(context)?.dekabrya_29cc ?? 'Fallback')
    ];
    final dateStr =
        '${timestamp.day} ${months[timestamp.month - 1]} • $timeStr';

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Video Player Viewer
              Center(
                child: FullScreenVideoPlayer(
                    videoUrl: videoUrl, jwtToken: jwtToken),
              ),

              // Animated UI elements
              FadeTransition(
                opacity: animation,
                child: Stack(
                  children: [
                    // Top Left: Back Button Droplet
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 16,
                      left: 16,
                      child: _buildDroplet(
                        isCircle: true,
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 22),
                      ),
                    ),

                    // Top Right: Context Menu Droplet
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 16,
                      right: 16,
                      child: _buildDroplet(
                        isCircle: true,
                        onTap: () => _showMediaActions(
                          context,
                          downloadUrl: downloadUrl,
                          fileName: fileName,
                        ),
                        child: const Icon(Icons.more_vert,
                            color: Colors.white, size: 22),
                      ),
                    ),

                    // Bottom Center: Sender & Date Droplet
                    Positioned(
                      bottom: MediaQuery.paddingOf(context).bottom + 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildDroplet(
                          isCircle: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                senderName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url, String fileId) async {
    try {
      String finalUrl = url;
      // Если токен отсутствует в URL, попробуем получить новый токен доступа через API
      if (!url.contains('token=')) {
        try {
          final apiClient = context.read<ApiClient>();
          final response = await apiClient
              .post('/files/share/$fileId/', data: {'expires_in_days': 0});
          if (response.statusCode == 200 || response.statusCode == 201) {
            final token = response.data['token']?.toString();
            if (token != null) {
              final uri = Uri.parse(url);
              finalUrl = uri.replace(queryParameters: {
                ...uri.queryParameters,
                'token': token,
              }).toString();
            }
          }
        } catch (e) {
          // Игнорируем ошибку и пробуем открыть оригинальный URL
          debugPrint('Ошибка при получении токена доступа к файлу: $e');
        }
      }

      final uri = Uri.parse(finalUrl);
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw '${AppLocalizations.of(context)?.oshibkaSkachivaniyaFayla_34ac ?? 'Unable to open file'}: $finalUrl';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.oshibkaSkachivaniyaFayla_34ac ?? 'Unable to open file'}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceProvider>();
    final usesMyStyle = !isChannel && isMe;
    final bubbleResolution =
        (usesMyStyle ? appearance.myMessageColor : appearance.otherMessageColor)
            .resolve(
      solidPresets:
          usesMyStyle ? kMyMessageSolidPresets : kOtherMessageSolidPresets,
      gradientPresets: usesMyStyle
          ? kMyMessageGradientPresets
          : kOtherMessageGradientPresets,
      defaultCustomSolid: usesMyStyle
          ? kMyMessageDefaultCustomSolid
          : kOtherMessageDefaultCustomSolid,
    );
    final defaultBubble = bubbleResolution.isDefault;
    final bubbleForeground = defaultBubble && !context.isDarkTheme
        ? context.xaneoTextPrimary
        : Colors.white;
    final bodyStyle = TextStyle(
      color: bubbleForeground,
      fontSize: appearance.chatFontSize,
      height: 1.35,
      fontFamily: AppStyles.fontFamily,
    );
    final timeStyle = TextStyle(
      fontSize: 9.5,
      color: defaultBubble ? context.xaneoTextMuted : Colors.white60,
      fontFamily: AppStyles.fontFamily,
    );
    final systemTypes = {
      'system',
      'user_joined',
      'user_left',
      'user_joined_group',
      'user_left_group',
      'user_invited_group',
      'user_invited_channel',
      'user_subscribed_channel',
      'user_unsubscribed_channel'
    };
    if (message.senderId == 'system' ||
        systemTypes.contains(message.messageType)) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.xaneoOverlay(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.xaneoDivider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.shield,
                  color: _systemIconColor, size: 11),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.textContent,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.xaneoTextMuted,
                    height: 1.3,
                    fontFamily: AppStyles.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Map<String, dynamic>? fileData;
    String displayContent = message.textContent;

    final isPoll = message.messageType == 'poll';
    final isTodo = message.messageType == 'todo_list';
    final isCall = message.messageType == 'call';
    final hasFile = message.fileUrl != null && message.fileUrl!.isNotEmpty;

    if (isPoll || isTodo || isCall || hasFile) {
      if (hasFile) {
        fileData = _decodeJsonMap(message.fileUrl!);
        if (fileData != null) {
          if (isCall) {
            displayContent = '';
          } else if (message.textContent.trim().startsWith('{')) {
            final textParsed = _decodeJsonMap(message.textContent);
            if (textParsed != null &&
                (textParsed['type'] == 'file' ||
                    textParsed['type'] == 'voice' ||
                    textParsed['type'] == 'video_message' ||
                    textParsed['type'] == 'collage')) {
              displayContent = '';
            }
          }
        }
      } else {
        // 1. Попытка распарсить JSON из textContent (для todo/poll)
        if (message.textContent.trim().startsWith('{')) {
          final parsed = _decodeJsonMap(message.textContent);
          if (parsed != null) {
            final type = parsed['type']?.toString();
            if (type == 'todo_list' || type == 'poll') {
              fileData = parsed;
              displayContent = '';
            }
          }
        }
      }
    }

    Widget? attachmentWidget;
    bool isOnlyFile = false;
    bool isOnlyMedia = false;
    if (fileData != null) {
      if (fileData['type'] == 'collage') {
        final uri = Uri.parse(AppConfig.apiBaseUrl);
        final hostUrl =
            '${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}';
        final tokenToUse = fileData['access_token']?.toString() ?? jwtToken;
        final filesList = fileData['files'] as List<dynamic>? ?? [];

        isOnlyFile = displayContent.isEmpty;
        isOnlyMedia =
            false; // Коллаж всегда рендерится внутри bubble-контейнера с общим временем
        attachmentWidget =
            _buildCollageWidget(context, filesList, hostUrl, tokenToUse);
      } else if (message.messageType == 'call') {
        attachmentWidget = _buildCallWidget(context, fileData, isMe);
      } else {
        final fileId = fileData['file_id']?.toString() ?? '';
        final fileName = fileData['file_name']?.toString() ?? 'file';
        final fileSize = fileData['file_size'] as int? ?? 0;
        String mime = (fileData['mime_type'] ?? '').toString().toLowerCase();
        final accessToken = fileData['access_token']?.toString();

        final lowerName = fileName.toLowerCase();
        if (mime.isEmpty) {
          if (lowerName.endsWith('.wav'))
            mime = 'audio/wav';
          else if (lowerName.endsWith('.mp3'))
            mime = 'audio/mp3';
          else if (lowerName.endsWith('.ogg'))
            mime = 'audio/ogg';
          else if (lowerName.endsWith('.webm'))
            mime = 'audio/webm';
          else if (lowerName.endsWith('.m4a')) mime = 'audio/m4a';
        }

        final isImage = mime.startsWith('image/') ||
            lowerName.endsWith('.jpg') ||
            lowerName.endsWith('.jpeg') ||
            lowerName.endsWith('.png') ||
            lowerName.endsWith('.gif') ||
            lowerName.endsWith('.webp') ||
            lowerName.endsWith('.bmp') ||
            lowerName.endsWith('.svg');

        final isVideo = mime.startsWith('video/') ||
            lowerName.endsWith('.mp4') ||
            lowerName.endsWith('.avi') ||
            lowerName.endsWith('.mov') ||
            lowerName.endsWith('.wmv') ||
            lowerName.endsWith('.flv') ||
            lowerName.endsWith('.webm') ||
            lowerName.endsWith('.mkv') ||
            lowerName.endsWith('.loc_3gp') ||
            lowerName.endsWith('.ogv') ||
            lowerName.endsWith('.m4v');

        // Формируем абсолютную ссылку для скачивания с JWT или access токеном
        final uri = Uri.parse(AppConfig.apiBaseUrl);
        final hostUrl =
            '${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}';
        String fileUrlSuffix = fileData['file_url']?.toString() ?? '';
        if (fileUrlSuffix.isEmpty) {
          fileUrlSuffix = '/api/files/download/$fileId/';
        }
        String absoluteUrl = '';
        final tokenToUse = accessToken ?? jwtToken;
        if (fileUrlSuffix.startsWith('http')) {
          absoluteUrl =
              '$fileUrlSuffix${tokenToUse != null ? (fileUrlSuffix.contains('?') ? "&token=$tokenToUse" : "?token=$tokenToUse") : ""}';
        } else {
          final prefix = fileUrlSuffix.startsWith('/') ? '' : '/';
          absoluteUrl =
              '$hostUrl$prefix$fileUrlSuffix${tokenToUse != null ? "?token=$tokenToUse" : ""}';
        }
        final localPath = fileData['local_path']?.toString();
        final localFile =
            localPath == null || localPath.isEmpty ? null : File(localPath);
        final hasLocalFile = localFile?.existsSync() == true;
        final mediaSource = hasLocalFile ? localPath! : absoluteUrl;

        final isVoice = fileData['type'] == 'voice' ||
            message.messageType == 'voice' ||
            (mime.startsWith('audio/') &&
                (fileData['type'] == 'voice' ||
                    lowerName.contains('voice') ||
                    lowerName.startsWith('voice_')));

        final isAudioMusic = !isVoice &&
            (fileData['type'] == 'audio' ||
                fileData['type'] == 'music' ||
                message.messageType == 'audio' ||
                message.messageType == 'music' ||
                mime.startsWith('audio/') ||
                lowerName.endsWith('.mp3') ||
                lowerName.endsWith('.wav') ||
                lowerName.endsWith('.m4a') ||
                lowerName.endsWith('.flac') ||
                lowerName.endsWith('.aac') ||
                lowerName.endsWith('.wma') ||
                lowerName.endsWith('.ogg') ||
                lowerName.endsWith('.opus') ||
                lowerName.endsWith('.aiff') ||
                lowerName.endsWith('.alac'));

        final isVideoMessage = fileData['type'] == 'video_message';

        isOnlyFile = displayContent.isEmpty;
        final hasReply = _parseReplyField(message.replyToId) != null ||
            _parseReplyField(message.replyText) != null ||
            _parseReplyField(message.replyAuthorName) != null;
        isOnlyMedia =
            isOnlyFile && !hasReply && (isImage || isVideo || isVideoMessage);

        if (fileData['type'] == 'todo_list') {
          attachmentWidget = TodoListWidget(
            message: message,
            chatWebSocketService: context.watch<ChatWebSocketService>(),
            localChatRepo: context.watch<LocalChatRepository>(),
            onStateChanged: () {},
            foregroundColor: bubbleForeground,
          );
        } else if (fileData['type'] == 'poll') {
          attachmentWidget = PollWidget(
            message: message,
            chatWebSocketService: context.watch<ChatWebSocketService>(),
            localChatRepo: context.watch<LocalChatRepository>(),
            onStateChanged: () {},
            foregroundColor: bubbleForeground,
          );
        } else if (isVideoMessage) {
          final duration = fileData['duration'] is num
              ? (fileData['duration'] as num).toDouble()
              : double.tryParse(fileData['duration']?.toString() ?? '') ?? 0.0;
          final localPath = fileData['local_path']?.toString();

          final videoWidget = VideoMessagePlayer(
            videoUrl: absoluteUrl,
            jwtToken: jwtToken,
            duration: duration,
            localPath: localPath,
            senderName: isChannel
                ? ((channelName != null && channelName!.isNotEmpty)
                    ? channelName!
                    : senderRealName)
                : (isMe
                    ? (AppLocalizations.of(context)?.vy_0101 ?? 'Fallback')
                    : senderRealName),
            messageId: message.serverMessageId,
          );

          attachmentWidget = Stack(
            alignment: Alignment.center,
            children: [
              videoWidget,
              if (isOnlyMedia)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          _buildMessageStatusIcon(message, color: Colors.white),
                        ]
                      ],
                    ),
                  ),
                ),
            ],
          );
        } else if (isVoice) {
          final duration = fileData['duration'] is num
              ? (fileData['duration'] as num).toInt()
              : int.tryParse(fileData['duration']?.toString() ?? '') ?? 0;
          // Если есть локальный путь (только что записанное наше ГС) — играем из него,
          // не дожидаясь скачивания. Иначе — обычная ссылка на скачивание.
          final localPath = fileData['local_path']?.toString();
          final voiceSource = (localPath != null && localPath.isNotEmpty)
              ? localPath
              : absoluteUrl;
          attachmentWidget = VoiceMessagePlayer(
            audioUrl: voiceSource,
            duration: duration,
            jwtToken: jwtToken,
            isMe: isMe,
            mimeType: fileData['mime_type']?.toString() ?? mime,
            senderName: senderRealName,
          );
        } else if (isAudioMusic) {
          final duration = audioTrackDuration(fileData);
          final localPath = fileData['local_path']?.toString();
          final audioSource = (localPath != null && localPath.isNotEmpty)
              ? localPath
              : absoluteUrl;
          final coverUriStr = audioTrackCoverUri(fileData);
          final artUri = coverUriStr != null && coverUriStr.isNotEmpty
              ? Uri.tryParse(coverUriStr.startsWith('http')
                  ? coverUriStr
                  : '$hostUrl${coverUriStr.startsWith('/') ? '' : '/'}$coverUriStr')
              : null;
          final fileMap = fileData;
          final titleStr =
              fileMap != null ? audioTrackTitle(fileMap, fileName) : fileName;
          final artistStr =
              fileMap != null ? audioTrackArtist(fileMap, fileName) : '';
          final mimeStr =
              (fileMap != null ? fileMap['mime_type']?.toString() : null) ??
                  mime;
          attachmentWidget = MusicMessagePlayer(
            audioUrl: audioSource,
            title: titleStr,
            artist: artistStr,
            duration: duration,
            mimeType: mimeStr,
            artUri: artUri,
            onPlayRequested: onPlayMusicRequested == null
                ? null
                : () => onPlayMusicRequested!(audioSource),
            onDownload: (onProgress) => _downloadFileSilent(
              context,
              absoluteUrl,
              fileName,
              onProgress: onProgress,
            ),
          );
        } else if (isImage) {
          attachmentWidget = GestureDetector(
            onTap: () => _showFullScreenImage(
              context,
              mediaSource,
              senderRealName,
              message.timestamp,
              fileName: fileName,
              downloadUrl: absoluteUrl,
            ),
            child: Container(
              margin: isOnlyMedia
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(bottom: 8),
              width: 260,
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: isOnlyMedia
                  ? null
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
              child: ClipRRect(
                borderRadius: isOnlyMedia
                    ? (isMe ? _myCorners : _otherCorners)
                    : BorderRadius.circular(11),
                child: Stack(
                  children: [
                    Hero(
                      tag: mediaSource,
                      child: hasLocalFile
                          ? Image.file(
                              localFile!,
                              width: 260,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildImagePlaceholder(
                                width: 260,
                                height: 120,
                              ),
                            )
                          : Image.network(
                              absoluteUrl,
                              key: ValueKey('${absoluteUrl}_${jwtToken ?? ""}'),
                              headers: jwtToken != null
                                  ? {'Authorization': 'Bearer $jwtToken'}
                                  : null,
                              width: 260,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                    'IMAGE PREVIEW LOAD ERROR: ${error.runtimeType}');
                                return _buildImagePlaceholder(
                                  width: 260,
                                  height: 120,
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return _buildImagePlaceholder(
                                  width: 260,
                                  height: 150,
                                );
                              },
                            ),
                    ),
                    if (isOnlyMedia)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(message.timestamp),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                _buildMessageStatusIcon(message,
                                    color: Colors.white),
                              ]
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        } else if (isVideo) {
          attachmentWidget = GestureDetector(
            onTap: () => _showFullScreenVideo(
              context,
              mediaSource,
              senderRealName,
              message.timestamp,
              fileName: fileName,
              downloadUrl: absoluteUrl,
            ),
            child: Container(
              margin: isOnlyMedia
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(bottom: 8),
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: isOnlyMedia
                  ? null
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
              child: ClipRRect(
                borderRadius: isOnlyMedia
                    ? (isMe ? _myCorners : _otherCorners)
                    : BorderRadius.circular(11),
                child: Stack(
                  children: [
                    VideoThumbnailWidget(
                      videoUrl: mediaSource,
                      jwtToken: jwtToken,
                      width: 280,
                      height: 200,
                      borderRadius: isOnlyMedia
                          ? (isMe ? _myCorners : _otherCorners)
                          : BorderRadius.circular(11),
                    ),
                    Container(
                      height: 200,
                      width: 280,
                      color: Colors.black26,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const FaIcon(FontAwesomeIcons.play,
                              color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                    if (isOnlyMedia)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(message.timestamp),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                _buildMessageStatusIcon(message,
                                    color: Colors.white),
                              ]
                            ],
                          ),
                        ),
                      )
                    else
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.video,
                                color: Colors.white70, size: 10),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                fileName,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatFileSize(fileSize, fileName),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // Обычные файлы (документы, архивы и др.)
          attachmentWidget = GestureDetector(
            onTap: () => _downloadFileSilent(context, absoluteUrl, fileName),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const FaIcon(FontAwesomeIcons.fileLines,
                        color: Colors.white70, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatFileSize(fileSize, fileName),
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const FaIcon(FontAwesomeIcons.download,
                      color: Colors.white54, size: 14),
                ],
              ),
            ),
          );
        }
      }
    }

    final effectiveIsMe = isChannel ? false : isMe;
    final showGroupSenderInfo = !effectiveIsMe && isGroup && !isChannel;
    final showChannelSenderHeader = isChannel;
    final displayName = isChannel
        ? ((channelName != null && channelName!.isNotEmpty)
            ? channelName!
            : senderRealName)
        : senderRealName;
    final senderNameColor = isChannel
        ? const Color(0xFF60A5FA)
        : _getSenderNameColor(senderRealName, senderGradient);

    return Align(
      alignment: effectiveIsMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 12),
        // Клавиатура бота — отдельный блок ПОД баблом (Column), а не внутри
        // декорированного контейнера самого бабла (см. Row ниже).
        child: Column(
          crossAxisAlignment:
              effectiveIsMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: effectiveIsMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (showGroupSenderInfo) ...[
                  AvatarWidget(
                    username: senderRealName,
                    avatar: senderAvatar,
                    avatarGradient: senderGradient,
                    size: 32,
                  ),
                  const SizedBox(width: 6),
                ],
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.70,
                  ),
                  child: GestureDetector(
                    onTap: () => onReply?.call(message),
                    onLongPress: () => onLongPress?.call(message),
                    child: Container(
                      padding: isOnlyMedia
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isOnlyMedia || bubbleResolution.gradient != null
                            ? Colors.transparent
                            : (bubbleResolution.solidColor ??
                                (effectiveIsMe
                                    ? context.xaneoOverlay(0.12)
                                    : context.xaneoOverlay(0.04))),
                        gradient:
                            isOnlyMedia ? null : bubbleResolution.gradient,
                        borderRadius:
                            effectiveIsMe ? _myCorners : _otherCorners,
                        border: isOnlyMedia
                            ? null
                            : Border.all(color: context.xaneoDivider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showGroupSenderInfo ||
                              showChannelSenderHeader) ...[
                            Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: senderNameColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                          ],
                          if (_parseReplyField(message.replyToId) != null ||
                              _parseReplyField(message.replyText) != null ||
                              _parseReplyField(message.replyAuthorName) != null)
                            _buildReplyQuote(context),
                          if (attachmentWidget != null) attachmentWidget,
                          if (reactions.isNotEmpty) ...[
                            IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (displayContent.isNotEmpty)
                                    FormattedText(
                                      content: displayContent,
                                      baseStyle: bodyStyle,
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: _buildReactionsRow(context),
                                      ),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 1),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _formatTime(message.timestamp),
                                              style: timeStyle,
                                            ),
                                            if (effectiveIsMe) ...[
                                              const SizedBox(width: 4),
                                              _buildMessageStatusIcon(message,
                                                  color: timeStyle.color),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            if (attachmentWidget == null &&
                                !showGroupSenderInfo &&
                                !showChannelSenderHeader &&
                                _parseReplyField(message.replyToId) == null &&
                                _parseReplyField(message.replyText) == null &&
                                _parseReplyField(message.replyAuthorName) ==
                                    null &&
                                displayContent.isNotEmpty &&
                                !isOnlyMedia)
                              Wrap(
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.end,
                                children: [
                                  FormattedText(
                                    content: displayContent,
                                    baseStyle: bodyStyle,
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 1),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatTime(message.timestamp),
                                          style: timeStyle,
                                        ),
                                        if (effectiveIsMe) ...[
                                          const SizedBox(width: 4),
                                          _buildMessageStatusIcon(message,
                                              color: timeStyle.color),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              if (displayContent.isNotEmpty)
                                FormattedText(
                                  content: displayContent,
                                  baseStyle: bodyStyle,
                                ),
                              if (!isOnlyMedia)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatTime(message.timestamp),
                                        style: timeStyle,
                                      ),
                                      if (effectiveIsMe) ...[
                                        const SizedBox(width: 4),
                                        _buildMessageStatusIcon(message,
                                            color: timeStyle.color),
                                      ],
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (message.replyMarkup != null && message.replyMarkup!.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: _BotInlineKeyboard(
                  message: message,
                  onButtonTap: onInlineButtonTap,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionsRow(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var r in reactions) {
      if (r is Map<String, dynamic>) {
        final emoji = r['emoji']?.toString() ?? '👍';
        grouped.putIfAbsent(emoji, () => []).add(r);
      }
    }

    if (grouped.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.zero,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: grouped.entries.map((entry) {
          final emoji = entry.key;
          final users = entry.value;
          final count = users.length;

          final hasMyReaction = myId != null &&
              users.any((u) {
                final uId = u['user_id']?.toString();
                return uId == myId;
              });

          final String userNames = users.map((u) {
            final name = u['user_first_name']?.toString();
            return (name != null && name.isNotEmpty)
                ? name
                : (u['user_username']?.toString() ?? '');
          }).join(', ');

          return Tooltip(
            message: userNames,
            child: InkWell(
              onTap: () => onToggleReaction?.call(emoji),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: hasMyReaction ? Colors.white : const Color(0x99000000),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasMyReaction
                        ? const Color(0x66C8C8C8)
                        : const Color(0xB3000000),
                    width: 1,
                  ),
                  boxShadow: hasMyReaction
                      ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (users.isNotEmpty) ...[
                      SizedBox(
                        height: 16,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              users.take(3).toList().asMap().entries.map((e) {
                            final idx = e.key;
                            final u = e.value;
                            final avatarUrl = u['user_avatar']?.toString();
                            final avatarGradient =
                                u['user_avatar_gradient']?.toString();
                            final name = u['user_first_name']?.toString() ??
                                u['user_username']?.toString() ??
                                'U';
                            return Transform.translate(
                              offset: Offset(-4.0 * idx, 0),
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: hasMyReaction
                                        ? Colors.black.withOpacity(0.2)
                                        : Colors.white.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: AvatarWidget(
                                  username: name,
                                  avatar: avatarUrl,
                                  avatarGradient: avatarGradient,
                                  size: 16,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        width: (4 - (users.take(3).length - 1) * 4).toDouble(),
                      ),
                    ],
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (count > 1) ...[
                      const SizedBox(width: 4),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: hasMyReaction ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Получить цвет имени отправителя в групповом чате (первый цвет градиента или вычисленный акцентный цвет)
  Color _getSenderNameColor(String senderName, String? senderGradient) {
    if (senderGradient != null && senderGradient.isNotEmpty) {
      try {
        String clean = senderGradient;
        if (clean.contains('linear-gradient')) {
          final match = RegExp(r'#(?:[0-9a-fA-F]{3,8})').firstMatch(clean);
          if (match != null) {
            clean = match.group(0)!.substring(1);
          }
        }
        final firstPart = clean.split(RegExp(r'[,|]')).first.trim();
        var colorStr =
            firstPart.startsWith('#') ? firstPart.substring(1) : firstPart;
        if (colorStr.length == 3) {
          colorStr = colorStr.split('').map((c) => '$c$c').join();
        }
        if (colorStr.length == 6) {
          colorStr = 'FF$colorStr';
        }
        if (colorStr.length == 8) {
          final val = int.tryParse(colorStr, radix: 16);
          if (val != null) return Color(val);
        }
      } catch (_) {}
    }

    final code = senderName.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    final colors = [
      const Color(0xFF38BDF8), // Sky Blue
      const Color(0xFFF472B6), // Pink
      const Color(0xFF34D399), // Emerald
      const Color(0xFFFBBF24), // Amber
      const Color(0xFFA78BFA), // Purple
      const Color(0xFFF87171), // Rose
      const Color(0xFF60A5FA), // Light Blue
      const Color(0xFFFB923C), // Orange
    ];
    return colors[code % colors.length];
  }

  Widget _buildCallWidget(
      BuildContext context, Map<String, dynamic> fileData, bool isMe) {
    final status = fileData['status']?.toString();
    final duration = fileData['duration'] as int? ?? 0;
    final callType = fileData['call_type']?.toString() ?? 'audio';

    final isVideo = callType == 'video';
    FaIconData callIcon =
        isVideo ? FontAwesomeIcons.video : FontAwesomeIcons.phone;
    Color iconColor = Colors.grey;
    Color iconBg = Colors.grey.withValues(alpha: 0.15);
    String callTitle = '';
    String callSubtext = '';

    if (isMe) {
      // Outgoing
      callTitle =
          (AppLocalizations.of(context)?.ishodyaschiyZvonok_8381 ?? 'Fallback');
      if (status == 'connected') {
        iconColor = const Color(0xFF10B981);
        iconBg = const Color(0xFF10B981).withValues(alpha: 0.15);
        final mins = duration ~/ 60;
        final secs = duration % 60;
        if (mins > 0) {
          callSubtext =
              '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
        } else {
          callSubtext = '00:${secs.toString().padLeft(2, '0')}';
        }
      } else {
        iconColor = const Color(0xFF9CA3AF);
        iconBg = const Color(0xFF9CA3AF).withValues(alpha: 0.15);
        callSubtext =
            (AppLocalizations.of(context)?.razgovorNeSostoyalsya_67fb ??
                'Fallback');
      }
    } else {
      // Incoming
      if (status == 'connected') {
        callTitle = (AppLocalizations.of(context)?.vhodyaschiyZvonok_5ce9 ??
            'Fallback');
        iconColor = const Color(0xFF10B981);
        iconBg = const Color(0xFF10B981).withValues(alpha: 0.15);
        final mins = duration ~/ 60;
        final secs = duration % 60;
        if (mins > 0) {
          callSubtext =
              '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
        } else {
          callSubtext = '00:${secs.toString().padLeft(2, '0')}';
        }
      } else if (status == 'rejected') {
        callTitle = (AppLocalizations.of(context)?.otklonennyyZvonok_d499 ??
            'Fallback');
        iconColor = const Color(0xFFEF4444);
        iconBg = const Color(0xFFEF4444).withValues(alpha: 0.15);
        callIcon =
            isVideo ? FontAwesomeIcons.videoSlash : FontAwesomeIcons.phoneSlash;
        callSubtext =
            (AppLocalizations.of(context)?.vyOtkloniliVyzov_8d1d ?? 'Fallback');
      } else {
        callTitle = (AppLocalizations.of(context)?.propuschennyyZvonok_e98d ??
            'Fallback');
        iconColor = const Color(0xFFEF4444);
        iconBg = const Color(0xFFEF4444).withValues(alpha: 0.15);
        callIcon =
            isVideo ? FontAwesomeIcons.videoSlash : FontAwesomeIcons.phoneSlash;
        callSubtext = (AppLocalizations.of(context)?.vyPropustiliVyzov_f17a ??
            'Fallback');
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                callIcon,
                color: iconColor,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                callTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                callSubtext,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Inline-клавиатура бота под сообщением (Telegram-style callback/url кнопки).
/// Отдельный StatefulWidget, чтобы держать локальное состояние "кнопка нажата,
/// ждём ответ сервера" без превращения MessageBubble в StatefulWidget.
class _BotInlineKeyboard extends StatefulWidget {
  final Message message;
  final Future<String?> Function(String buttonId, Message message)? onButtonTap;

  const _BotInlineKeyboard({required this.message, this.onButtonTap});

  @override
  State<_BotInlineKeyboard> createState() => _BotInlineKeyboardState();
}

class _BotInlineKeyboardState extends State<_BotInlineKeyboard> {
  final Set<String> _pendingIds = {};
  late List<List<Map<String, dynamic>>> _rows;

  @override
  void initState() {
    super.initState();
    _decodeRows();
  }

  @override
  void didUpdateWidget(covariant _BotInlineKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.replyMarkup != widget.message.replyMarkup) {
      _decodeRows();
    }
  }

  void _decodeRows() {
    final raw = widget.message.replyMarkup;
    if (raw == null || raw.isEmpty) {
      _rows = const [];
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      final replyMarkup = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : const <String, dynamic>{};
      final rawRows = replyMarkup['inline_keyboard'] as List? ?? const [];
      _rows = rawRows
          .whereType<List>()
          .map((row) => row
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList())
          .where((row) => row.isNotEmpty)
          .toList();
    } catch (_) {
      _rows = const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _rows.map<Widget>((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                for (int i = 0; i < row.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: _buildButton(
                      context,
                      row[i],
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton(BuildContext context, Map<String, dynamic> item) {
    final text = item['text']?.toString() ?? '';
    final buttonId = item['id']?.toString();
    final action = item['action']?.toString();
    if (text.isEmpty || buttonId == null) return const SizedBox.shrink();

    final bgColor =
        _parseHexColor(item['color']?.toString()) ?? const Color(0xFF426B63);
    final fgColor =
        bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final isPending = _pendingIds.contains(buttonId);

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: isPending
            ? null
            : () => _handleTap(context, item, buttonId, action),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withOpacity(0.7),
          disabledForegroundColor: fgColor.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: isPending
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            : Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    Map<String, dynamic> item,
    String buttonId,
    String? action,
  ) async {
    if (action == 'url') {
      final urlStr = item['url']?.toString();
      Uri? uri;
      if (urlStr != null) {
        try {
          uri = Uri.parse(urlStr);
        } catch (_) {
          uri = null;
        }
      }
      if (uri == null || uri.scheme != 'https') {
        _showError(context, 'Ссылка недоступна');
        return;
      }
      final confirmed = await ConfirmActionModal.confirm(
        context: context,
        title: 'Перейти по ссылке?',
        message: uri.host,
        confirmLabel: 'Перейти',
      );
      if (confirmed) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    if (action != 'callback' || widget.onButtonTap == null) return;

    setState(() => _pendingIds.add(buttonId));
    try {
      final error = await widget.onButtonTap!(buttonId, widget.message);
      if (error != null && mounted) _showError(context, error);
    } finally {
      if (mounted) setState(() => _pendingIds.remove(buttonId));
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null) return null;
    final match = RegExp(r'^#([0-9A-Fa-f]{6})$').firstMatch(hex);
    if (match == null) return null;
    return Color(int.parse('FF${match.group(1)}', radix: 16));
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({
    required this.imageUrl,
    required this.localImage,
    required this.jwtToken,
    required this.senderName,
    required this.dateText,
    required this.routeAnimation,
    required this.onShowMenu,
  });

  final String imageUrl;
  final File? localImage;
  final String? jwtToken;
  final String senderName;
  final String dateText;
  final Animation<double> routeAnimation;
  final void Function(BuildContext context) onShowMenu;

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  bool _showUi = true;

  void _toggleUi() {
    final showUi = !_showUi;
    setState(() => _showUi = showUi);
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        showUi ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  Widget _buildDroplet({
    required Widget child,
    required VoidCallback onTap,
    bool isCircle = true,
  }) {
    final borderRadius = isCircle ? null : BorderRadius.circular(20);
    return Container(
      width: isCircle ? 40 : null,
      height: isCircle ? 40 : null,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: isCircle ? const CircleBorder() : null,
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: isCircle
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: isCircle ? Center(child: child) : child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleUi,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: widget.imageUrl,
                  child: widget.localImage != null
                      ? Image.file(widget.localImage!, fit: BoxFit.contain)
                      : Image.network(
                          widget.imageUrl,
                          headers: widget.jwtToken != null
                              ? {'Authorization': 'Bearer ${widget.jwtToken}'}
                              : null,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)
                                          ?.neUdalosZagruzitIzobrazhenie_3fa0 ??
                                      'Не удалось загрузить изображение',
                                  style: const TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
            IgnorePointer(
              ignoring: !_showUi,
              child: AnimatedOpacity(
                opacity: _showUi ? 1 : 0,
                duration: animationsDisabled
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                child: FadeTransition(
                  opacity: widget.routeAnimation,
                  child: Stack(
                    children: [
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 16,
                        left: 16,
                        child: _buildDroplet(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 16,
                        right: 16,
                        child: _buildDroplet(
                          onTap: () => widget.onShowMenu(context),
                          child: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: MediaQuery.paddingOf(context).bottom + 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _buildDroplet(
                            isCircle: false,
                            onTap: () {},
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.senderName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.dateText,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? jwtToken;
  const FullScreenVideoPlayer({Key? key, required this.videoUrl, this.jwtToken})
      : super(key: key);

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  bool _isLoading = true;
  double _downloadProgress = 0.0;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final sourceFile = File(widget.videoUrl);
      late final File tempFile;
      if (await sourceFile.exists()) {
        tempFile = sourceFile;
      } else {
        final hash = widget.videoUrl.hashCode.toString();
        final tempDir = await getTemporaryDirectory();
        tempFile = File('${tempDir.path}/video_cache_$hash.mp4');

        if (!await tempFile.exists()) {
          final dio = Dio();
          if (widget.jwtToken != null) {
            dio.options.headers['Authorization'] = 'Bearer ${widget.jwtToken}';
          }
          await dio.download(
            widget.videoUrl,
            tempFile.path,
            onReceiveProgress: (count, total) {
              if (total != -1 && mounted) {
                setState(() {
                  _downloadProgress = count / total;
                });
              }
            },
          );
        }
      }

      _videoPlayerController = VideoPlayerController.file(tempFile);
      await _videoPlayerController.initialize();
      _videoPlayerController.addListener(_onVideoEvent);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _videoPlayerController.play();
        _startHideTimer();
      }
    } catch (e) {
      debugPrint('Video init error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onVideoEvent() {
    if (mounted) setState(() {});
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _videoPlayerController.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlay() {
    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
      setState(() => _showControls = true);
      _hideControlsTimer?.cancel();
    } else {
      _videoPlayerController.play();
      setState(() => _showControls = true);
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _videoPlayerController.removeListener(_onVideoEvent);
    _videoPlayerController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString();
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildProgressBar() {
    final position = _videoPlayerController.value.position;
    final duration = _videoPlayerController.value.duration;
    final remaining = duration - position;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Text(_formatDuration(position),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: position.inMilliseconds.toDouble(),
                max: duration.inMilliseconds.toDouble() > 0
                    ? duration.inMilliseconds.toDouble()
                    : 1.0,
                onChanged: (v) {
                  _videoPlayerController
                      .seekTo(Duration(milliseconds: v.toInt()));
                  _startHideTimer();
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('-${_formatDuration(remaining)}',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            if (_downloadProgress > 0) ...[
              const SizedBox(height: 16),
              Text(
                '${AppLocalizations.of(context)?.preparingDownload ?? 'Downloading'} ${(_downloadProgress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white70),
              ),
            ]
          ],
        ),
      );
    } else if (_videoPlayerController.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController),
            ),
          ),
          GestureDetector(
            onTap: _togglePlay,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _videoPlayerController.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _showControls
                ? MediaQuery.paddingOf(context).bottom + 90
                : -100,
            left: 24,
            right: 24,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildProgressBar(),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text(
                (AppLocalizations.of(context)?.oshibkaVosproizvedeniya_ac8a ??
                    'Fallback'),
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }
  }
}

class VoiceMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final int duration;
  final String? jwtToken;
  final bool isMe;
  final String? mimeType;
  final String senderName;

  const VoiceMessagePlayer({
    super.key,
    required this.audioUrl,
    required this.duration,
    required this.jwtToken,
    required this.isMe,
    this.mimeType,
    required this.senderName,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  String _formatDuration(Duration d) {
    final s = d.inSeconds % 60;
    final m = d.inMinutes;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.isMe;
    final playBtnColor = isMe ? const Color(0xFF4ADE80) : Colors.white;
    final iconColor = Colors.black;
    final activeTrackColor = isMe ? const Color(0xFF4ADE80) : Colors.white;
    final inactiveTrackColor = Colors.white.withValues(alpha: 0.2);

    return Selector<PlaybackProvider, _VoicePlaybackState>(
      selector: (_, provider) => _VoicePlaybackState(
        currentAudioUrl: provider.currentAudioUrl,
        isPlaying: provider.isPlaying,
        isInitialized: provider.isInitialized,
        isLoading: provider.isLoading,
        downloadProgress: provider.downloadProgressFor(widget.audioUrl),
        position: provider.position,
        duration: provider.duration,
      ),
      shouldRebuild: (prev, next) {
        // Ребилдим только если это наш audioUrl и состояние изменилось
        final isCurrent = next.currentAudioUrl == widget.audioUrl;
        final wasCurrent = prev.currentAudioUrl == widget.audioUrl;

        if (!isCurrent && !wasCurrent) {
          return prev.downloadProgress != next.downloadProgress;
        }

        // Наш audio - проверяем значимые изменения
        return prev != next;
      },
      builder: (context, state, child) {
        final audioUrl = widget.audioUrl;
        final isCurrent = state.currentAudioUrl == audioUrl;
        final isPlaying = isCurrent && state.isPlaying;
        final isInitialized = isCurrent && state.isInitialized;
        final isLoading = isCurrent && state.isLoading;

        final position = isCurrent ? state.position : Duration.zero;
        final durationVal =
            isCurrent && state.isInitialized && state.duration > Duration.zero
                ? state.duration
                : Duration(seconds: widget.duration);

        final displayDuration =
            isPlaying || (isCurrent && position > Duration.zero)
                ? position
                : durationVal;

        return Container(
          constraints: const BoxConstraints(maxWidth: 240),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Play/Pause circular button
              GestureDetector(
                onTap: () {
                  if (isLoading) return;
                  final playbackProvider = context.read<PlaybackProvider>();
                  playbackProvider.play(
                    audioUrl,
                    (AppLocalizations.of(context)?.golosovoeSoobschenie_33d5 ??
                        'Fallback'),
                    isMe
                        ? (AppLocalizations.of(context)?.vy_0101 ?? 'Fallback')
                        : widget.senderName,
                    mimeType: widget.mimeType,
                    duration: Duration(seconds: widget.duration),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: playBtnColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: playBtnColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  iconColor.withValues(alpha: 0.5)),
                            ),
                          )
                        : Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: iconColor,
                            size: 26,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Progress & Duration column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Waveform Slider
                    VoiceWaveformSlider(
                      position: position,
                      duration: durationVal,
                      isActive: isCurrent && isInitialized,
                      // Финальный seek — один раз, когда палец отпущен.
                      // Тяжёлая операция: пересоздаёт AudioSource.
                      onSeek: isCurrent && isInitialized
                          ? (newPosition) {
                              context
                                  .read<PlaybackProvider>()
                                  .seek(newPosition);
                            }
                          : null,
                      // Превью во время драга — на каждое движение пальца.
                      // Лёгкая операция: просто двигает позицию в UI,
                      // не трогает плеер. Без этого guard _isSeeking в
                      // провайдере отбрасывал бы почти все промежуточные
                      // вызовы seek(), и слайдер выглядел нерабочим.
                      onSeekPreview: isCurrent && isInitialized
                          ? (newPosition) {
                              context
                                  .read<PlaybackProvider>()
                                  .seekPreview(newPosition);
                            }
                          : null,
                      activeColor: activeTrackColor,
                      inactiveColor: inactiveTrackColor,
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        _formatDuration(displayDuration),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10.5,
                          fontFamily: AppStyles.fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MusicMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String artist;
  final int duration;
  final String? mimeType;
  final Uri? artUri;
  final Future<void> Function()? onPlayRequested;
  final Future<void> Function(ValueChanged<double> onProgress)? onDownload;

  const MusicMessagePlayer({
    super.key,
    required this.audioUrl,
    required this.title,
    required this.artist,
    required this.duration,
    this.mimeType,
    this.artUri,
    this.onPlayRequested,
    this.onDownload,
  });

  @override
  State<MusicMessagePlayer> createState() => _MusicMessagePlayerState();
}

class _MusicMessagePlayerState extends State<MusicMessagePlayer> {
  double? _dragValue;
  bool _isStartingPlayback = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  Future<void> _handlePlay(
    BuildContext context,
    bool isLoading,
    Duration totalDuration,
  ) async {
    if (isLoading || _isStartingPlayback || _isDownloading) return;
    setState(() => _isStartingPlayback = true);
    try {
      if (widget.onPlayRequested != null) {
        await widget.onPlayRequested!();
        return;
      }
      await context.read<PlaybackProvider>().play(
            widget.audioUrl,
            widget.title,
            widget.artist,
            mimeType: widget.mimeType,
            duration: totalDuration > Duration.zero ? totalDuration : null,
            artUri: widget.artUri,
          );
    } finally {
      if (mounted) setState(() => _isStartingPlayback = false);
    }
  }

  Future<void> _handleDownload() async {
    if (_isDownloading || _isStartingPlayback || widget.onDownload == null) {
      return;
    }
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });
    try {
      await widget.onDownload!((progress) {
        if (!mounted) return;
        setState(
          () => _downloadProgress = progress.clamp(0.0, 1.0).toDouble(),
        );
      });
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const foregroundColor = Colors.white;
    const mutedColor = Colors.white60;
    final fallbackDuration = Duration(seconds: widget.duration);

    return Selector<PlaybackProvider, _VoicePlaybackState>(
      selector: (_, provider) => _VoicePlaybackState(
        currentAudioUrl: provider.currentAudioUrl,
        isPlaying: provider.isPlaying,
        isInitialized: provider.isInitialized,
        isLoading: provider.isLoading,
        downloadProgress: provider.downloadProgressFor(widget.audioUrl),
        position: provider.position,
        duration: provider.duration,
      ),
      shouldRebuild: (prev, next) {
        final isCurrent = next.currentAudioUrl == widget.audioUrl;
        final wasCurrent = prev.currentAudioUrl == widget.audioUrl;
        if (!isCurrent && !wasCurrent) {
          return prev.downloadProgress != next.downloadProgress;
        }
        return prev != next;
      },
      builder: (context, state, child) {
        final audioUrl = widget.audioUrl;
        final isCurrent = state.currentAudioUrl == audioUrl;
        final isPlaying = isCurrent && state.isPlaying;
        final isInitialized = isCurrent && state.isInitialized;
        final isLoading = isCurrent && state.isLoading;
        final activeDownloadProgress = _isDownloading
            ? _downloadProgress
            : state.downloadProgress.clamp(0.0, 1.0).toDouble();
        final downloadComplete =
            _downloadProgress >= 1.0 || state.downloadProgress >= 1.0;
        final showPlayProgress =
            (isLoading || _isStartingPlayback || _isDownloading) &&
                !downloadComplete;

        final position = isCurrent ? state.position : Duration.zero;
        final totalDuration =
            isCurrent && state.isInitialized && state.duration > Duration.zero
                ? state.duration
                : fallbackDuration;

        final currentSliderPos = _dragValue ??
            (totalDuration > Duration.zero
                ? (position.inMilliseconds / totalDuration.inMilliseconds)
                    .clamp(0.0, 1.0)
                : 0.0);
        final displayPosition =
            _dragValue != null && totalDuration > Duration.zero
                ? Duration(
                    milliseconds:
                        (_dragValue! * totalDuration.inMilliseconds).round(),
                  )
                : position;

        return Container(
          constraints: const BoxConstraints(maxWidth: 270),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: InkResponse(
                            onTap: () =>
                                _handlePlay(context, isLoading, totalDuration),
                            radius: 20,
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: ClipOval(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    TrackArtwork(
                                      uri: widget.artUri,
                                      fallback: const ColoredBox(
                                        color: foregroundColor,
                                      ),
                                    ),
                                    if (widget.artUri != null)
                                      ColoredBox(
                                        color: Colors.black
                                            .withValues(alpha: 0.38),
                                      ),
                                    Center(
                                      child: showPlayProgress
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                value: activeDownloadProgress,
                                                strokeWidth: 2.3,
                                                backgroundColor: Colors.white24,
                                                color: widget.artUri != null
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            )
                                          : Icon(
                                              isPlaying
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: widget.artUri != null
                                                  ? Colors.white
                                                  : Colors.black,
                                              size: 23,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget.onDownload != null && !downloadComplete)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkResponse(
                              onTap: showPlayProgress ? null : _handleDownload,
                              radius: 12,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.42),
                                  border: Border.all(color: Colors.white54),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.download_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: foregroundColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        if (isCurrent)
                          SizedBox(
                            height: 16,
                            child: SliderTheme(
                              data: const SliderThemeData(
                                trackHeight: 2,
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 4),
                                overlayShape:
                                    RoundSliderOverlayShape(overlayRadius: 10),
                                activeTrackColor: foregroundColor,
                                inactiveTrackColor: Colors.white24,
                                thumbColor: foregroundColor,
                                overlayColor: Colors.white12,
                              ),
                              child: Slider(
                                value: currentSliderPos.clamp(0.0, 1.0),
                                onChanged: (val) {
                                  setState(() => _dragValue = val);
                                  if (isInitialized &&
                                      totalDuration > Duration.zero) {
                                    final targetMs =
                                        (val * totalDuration.inMilliseconds)
                                            .round();
                                    context
                                        .read<PlaybackProvider>()
                                        .seekPreview(
                                            Duration(milliseconds: targetMs));
                                  }
                                },
                                onChangeEnd: (val) {
                                  setState(() => _dragValue = null);
                                  if (totalDuration <= Duration.zero) return;
                                  context.read<PlaybackProvider>().seek(
                                        Duration(
                                          milliseconds: (val *
                                                  totalDuration.inMilliseconds)
                                              .round(),
                                        ),
                                      );
                                },
                              ),
                            ),
                          )
                        else
                          Text(
                            widget.artist.isNotEmpty
                                ? widget.artist
                                : (AppLocalizations.of(context)
                                        ?.audiozapis_867d ??
                                    'Audio'),
                            style: const TextStyle(
                              color: mutedColor,
                              fontSize: 10.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const SizedBox(width: 45),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(displayPosition),
                          style: const TextStyle(
                            color: mutedColor,
                            fontSize: 10,
                            fontFamily: AppStyles.fontFamily,
                          ),
                        ),
                        Text(
                          _formatDuration(totalDuration),
                          style: const TextStyle(
                            color: mutedColor,
                            fontSize: 10,
                            fontFamily: AppStyles.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BlinkingRedDot extends StatefulWidget {
  const _BlinkingRedDot();

  @override
  State<_BlinkingRedDot> createState() => _BlinkingRedDotState();
}

class _BlinkingRedDotState extends State<_BlinkingRedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class TopChatAudioMiniPlayer extends StatelessWidget {
  final PlaybackProvider playbackProvider;
  final VoidCallback onTapTitle;

  const TopChatAudioMiniPlayer({
    super.key,
    required this.playbackProvider,
    required this.onTapTitle,
  });

  @override
  Widget build(BuildContext context) {
    final playback = playbackProvider;
    final isPlaying = playback.isPlaying;
    final title = playback.title.isEmpty
        ? (AppLocalizations.of(context)?.golosovoeSoobschenie_33d5 ??
            'Fallback')
        : playback.title;
    final subtitle = playback.subtitle;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapTitle,
      child: Container(
        key: const ValueKey('mini_player_visible'),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppStyles.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: isPlaying ? playback.pause : playback.resume,
              child: SizedBox(
                width: 36,
                height: 36,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      TrackArtwork(
                        uri: playback.currentArtUri,
                        fallback: const ColoredBox(color: Color(0xFF27272A)),
                      ),
                      ColoredBox(color: Colors.black.withValues(alpha: 0.28)),
                      Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppStyles.textPrimaryColor,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTapTitle,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppStyles.textPrimaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppStyles.fontFamily,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppStyles.textSecondaryColor,
                          fontSize: 10.5,
                          fontFamily: AppStyles.fontFamily,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: playback.dismissPlayerControls,
              icon: const Icon(
                Icons.close_rounded,
                color: AppStyles.textMutedColor,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            ),
          ],
        ),
      ),
    );
  }
}

class AttachmentComposition {
  final File file;
  String status; // 'uploading', 'success', 'error'
  String? fileId;
  final String fileType; // 'image', 'video', 'audio', 'document'
  final int fileSize;
  final String fileName;
  Future<void>? uploadFuture;

  AttachmentComposition({
    required this.file,
    this.status = 'uploading',
    this.fileId,
    required this.fileType,
    required this.fileSize,
    required this.fileName,
  });
}

class ChatMessageContextMenuModal extends BaseCustomModal {
  final Message message;
  final Set<String> myReactionEmojis;
  final void Function(String emoji) onSelectEmoji;
  final void Function(Message message) onReply;
  final void Function(Message message) onShowFullEmojiPicker;

  const ChatMessageContextMenuModal({
    super.key,
    required this.message,
    required this.myReactionEmojis,
    required this.onSelectEmoji,
    required this.onReply,
    required this.onShowFullEmojiPicker,
  });

  static Future<void> show({
    required BuildContext context,
    required Message message,
    required Set<String> myReactionEmojis,
    required void Function(String emoji) onSelectEmoji,
    required void Function(Message message) onReply,
    required void Function(Message message) onShowFullEmojiPicker,
  }) {
    return BaseCustomModal.show<void>(
      context: context,
      enableDrag: true,
      child: ChatMessageContextMenuModal(
        message: message,
        myReactionEmojis: myReactionEmojis,
        onSelectEmoji: onSelectEmoji,
        onReply: onReply,
        onShowFullEmojiPicker: onShowFullEmojiPicker,
      ),
    );
  }

  @override
  State<ChatMessageContextMenuModal> createState() =>
      _ChatMessageContextMenuModalState();
}

class _ChatMessageContextMenuModalState
    extends BaseCustomModalState<ChatMessageContextMenuModal> {
  static const popularEmojis = [
    '👍',
    '❤️',
    '🔥',
    '😂',
    '😮',
    '😢',
    '🤡',
    '👏',
    '🎉',
    '💩'
  ];

  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...popularEmojis.map((emoji) {
                final hasMyReaction = widget.myReactionEmojis.contains(emoji);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelectEmoji(emoji);
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: hasMyReaction
                            ? const Color(0xFF2563EB).withValues(alpha: 0.25)
                            : context.xaneoOverlay(0.06),
                        shape: BoxShape.circle,
                        border: hasMyReaction
                            ? Border.all(
                                color: const Color(0xFF2563EB), width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  widget.onShowFullEmojiPicker(widget.message);
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: context.xaneoOverlay(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.circlePlus,
                      size: 20,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: context.xaneoDivider, height: 1),
        const SizedBox(height: 8),
        ListTile(
          leading: FaIcon(
            FontAwesomeIcons.reply,
            size: 16,
            color: context.xaneoTextSecondary,
          ),
          title: Text(
            AppLocalizations.of(context)?.reply ??
                RuntimeTranslations.instance.resolveByText('Ответить'),
            style: TextStyle(color: context.xaneoTextPrimary, fontSize: 15),
          ),
          onTap: () {
            Navigator.pop(context);
            widget.onReply(widget.message);
          },
        ),
        if (widget.message.textContent.isNotEmpty)
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.copy,
              size: 16,
              color: context.xaneoTextSecondary,
            ),
            title: Text(
              AppLocalizations.of(context)?.copy ??
                  RuntimeTranslations.instance.resolveByText('Копировать'),
              style: TextStyle(color: context.xaneoTextPrimary, fontSize: 15),
            ),
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(
                  ClipboardData(text: widget.message.textContent));
            },
          ),
      ],
    );
  }
}

class FullEmojiPickerModal extends BaseCustomModal {
  final Set<String> myReactionEmojis;
  final void Function(String emoji) onSelectEmoji;

  const FullEmojiPickerModal({
    super.key,
    required this.myReactionEmojis,
    required this.onSelectEmoji,
  });

  static Future<void> show({
    required BuildContext context,
    required Set<String> myReactionEmojis,
    required void Function(String emoji) onSelectEmoji,
  }) {
    return BaseCustomModal.show<void>(
      context: context,
      enableDrag: true,
      child: FullEmojiPickerModal(
        myReactionEmojis: myReactionEmojis,
        onSelectEmoji: onSelectEmoji,
      ),
    );
  }

  @override
  State<FullEmojiPickerModal> createState() => _FullEmojiPickerModalState();
}

class _FullEmojiPickerModalState
    extends BaseCustomModalState<FullEmojiPickerModal> {
  static const Map<String, List<String>> _emojiCategories = {
    'Эмоции': [
      '😀',
      '😃',
      '😄',
      '😁',
      '😆',
      '😅',
      '🤣',
      '😂',
      '🙂',
      '🙃',
      '😉',
      '😊',
      '😇',
      '🥰',
      '😍',
      '🤩',
      '😘',
      '😗',
      '😚',
      '😋',
      '😛',
      '😜',
      '🤪',
      '😝',
      '🤑',
      '🤗',
      '🤭',
      '🤫',
      '🤔',
      '🤐',
      '🤨',
      '😐',
      '😑',
      '😶',
      '😏',
      '😒',
      '🙄',
      '😬',
      '🤥',
      '😌',
      '😔',
      '😪',
      '🤤',
      '😴',
      '😷',
      '🤒',
      '🤕',
      '🤢',
      '🤮',
      '🤧',
      '🥵',
      '🥶',
      '🥴',
      '😵',
      '🤯',
      '🤠',
      '🥳',
      '😎',
      '🤓',
      '🧐',
      '😕',
      '😟',
      '🙁',
      '😮',
      '😯',
      '😲',
      '😳',
      '🥺',
      '😦',
      '😧',
      '😨',
      '😰',
      '😥',
      '😢',
      '😭',
      '😱',
      '😖',
      '😣',
      '😞',
      '😓',
      '😩',
      '😫',
      '🥱',
      '😤',
      '😡',
      '😠',
      '🤬',
      '😈',
      '👿',
      '💀',
      '☠️',
      '💩',
      '🤡',
      '👹',
      '👺',
      '👻',
      '👽',
      '👾',
      '🤖'
    ],
    'Жесты и тело': [
      '👋',
      '🤚',
      '🖐️',
      '✋',
      '🖖',
      '👌',
      '🤏',
      '✌️',
      '🤞',
      '🤟',
      '🤘',
      '🤙',
      '👈',
      '👉',
      '👆',
      '🖕',
      '👇',
      '☝️',
      '👍',
      '👎',
      '✊',
      '👊',
      '🤛',
      '🤜',
      '👏',
      '🙌',
      '👐',
      '🤲',
      '🤝',
      '🙏',
      '✍️',
      '💅',
      '🤳',
      '💪',
      '🦾',
      '🦿',
      '🦵',
      '🦶',
      '👂',
      '🦻',
      '👃',
      '🧠',
      '🫀',
      '🫁',
      '🦷',
      '🦴',
      '👀',
      '👁️',
      '👅',
      '👄'
    ],
    'Сердца и символы': [
      '❤️',
      '🧡',
      '💛',
      '💚',
      '💙',
      '💜',
      '🖤',
      '🤍',
      '🤎',
      '💔',
      '❣️',
      '💕',
      '💞',
      '💓',
      '💗',
      '💖',
      '💘',
      '💝',
      '💟',
      '☮️',
      '✝️',
      '☪️',
      '🕉️',
      '☸️',
      '✡️',
      '🔯',
      '🕎',
      '☯️',
      '☦️',
      '🛐',
      '⛎',
      '♈',
      '♉',
      '♊',
      '♋',
      '♌',
      '♍',
      '♎',
      '♏',
      '♐',
      '♑',
      '♒',
      '♓',
      '🎯',
      '💯',
      '🔥',
      '💥',
      '✨',
      '⚡',
      '🌟',
      '💫',
      '⭐️'
    ],
    'Еда и предметы': [
      '🍏',
      '🍎',
      '🍐',
      '🍊',
      '🍋',
      '🍌',
      '🍉',
      '🍇',
      '🍓',
      '🫐',
      '🍈',
      '🍒',
      '🍑',
      '🥭',
      '🍍',
      '🥥',
      '🥝',
      '🍅',
      '🍆',
      '🥑',
      '🥦',
      '🥬',
      '🥒',
      '🌶️',
      '🫑',
      '🌽',
      '🥕',
      '🫒',
      '🧄',
      '🧅',
      '🥔',
      '🍠',
      '🥐',
      '🥯',
      '🍞',
      '🥖',
      '🥨',
      '🧀',
      '🍳',
      '🥞',
      '🧇',
      '🥓',
      '🥩',
      '🍗',
      '🍖',
      '🌭',
      '🍔',
      '🍟',
      '🍕',
      '🥪',
      '🥙',
      '🧆',
      '🌮',
      '🌯',
      '🥗',
      '🥘',
      '🍝',
      '🍜',
      '🍲',
      '🍛',
      '🍣',
      '🍱',
      '🥟',
      '🍤',
      '🍙',
      '🍧',
      '🍨',
      '🍦',
      '🥧',
      '🧁',
      '🍰',
      '🎂',
      '🍮',
      '🍭',
      '🍬',
      '🍫',
      '🍿',
      '🍩'
    ],
  };

  String _searchQuery = '';

  @override
  double get initialExtent => 0.70;
  @override
  double get minExtent => 0.40;
  @override
  double get maxExtent => 0.90;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              RuntimeTranslations.instance.resolveByText('Все реакции'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const FaIcon(
                FontAwesomeIcons.xmark,
                size: 16,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (val) {
            setState(() {
              _searchQuery = val.trim();
            });
          },
          style: const TextStyle(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            hintText:
                RuntimeTranslations.instance.resolveByText('Поиск эмодзи...'),
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search,
              size: 18,
              color: Colors.white54,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: _emojiCategories.length,
            itemBuilder: (context, catIdx) {
              final entry = _emojiCategories.entries.elementAt(catIdx);
              final categoryTitle = entry.key;
              final emojis = entry.value
                  .where(
                      (e) => _searchQuery.isEmpty || e.contains(_searchQuery))
                  .toList();

              if (emojis.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      RuntimeTranslations.instance.resolveByText(categoryTitle),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: emojis.length,
                    itemBuilder: (context, emojiIdx) {
                      final emoji = emojis[emojiIdx];
                      final hasMyReaction =
                          widget.myReactionEmojis.contains(emoji);

                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSelectEmoji(emoji);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: hasMyReaction
                                ? const Color(0xFF2563EB)
                                    .withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                            border: hasMyReaction
                                ? Border.all(
                                    color: const Color(0xFF2563EB), width: 1.5)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
