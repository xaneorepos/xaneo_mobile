import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:record/record.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../providers/scale_provider.dart';
import '../providers/playback_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/advanced_background.dart';
import '../widgets/voice_waveform_slider.dart';
import '../widgets/settings_modal.dart'; // деактивировано — используем XaneoSettingsModal
import '../widgets/xaneo_settings_modal.dart';
import '../widgets/global_search_modal.dart';
import '../widgets/music_playlist_modal.dart';
import '../services/api_service.dart';
import '../services/crypto_service.dart';
import '../services/account_service.dart';
import '../services/websocket_service.dart';
import '../services/logger_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../widgets/custom_toast.dart';
import '../widgets/custom_context_menu.dart';
import '../utils/local_proxy.dart';
import '../services/webrtc/call_manager.dart';
import '../services/webrtc/webrtc_signaling_service.dart';
import 'webrtc/incoming_call_screen.dart';
import 'webrtc/active_call_screen.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:window_manager/window_manager.dart';
import '../services/notification_service.dart';
import '../models/app_version_info.dart';
import '../services/update_service.dart';
import '../widgets/update_banner_widget.dart';


class MessengerScreen extends StatefulWidget {
  const MessengerScreen({super.key});

  @override
  State<MessengerScreen> createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
  final ApiService _apiService = ApiService();
  final CryptoService _cryptoService = CryptoService();
  final GlobalKey<SettingsButtonState> _settingsKey = GlobalKey<SettingsButtonState>();
  final GlobalKey _attachmentKey = GlobalKey();
  Map<String, dynamic>? _attachedFile;
  final Map<String, Map<String, dynamic>> _fileMetadataCache = {};
  final Set<String> _fetchingFileMetadata = {};

  List<dynamic> _chats = [];
  List<dynamic> _archivedChats = [];
  bool _viewingArchive = false;
  Map<String, dynamic>? _selectedChat;
  Map<int, Map<String, dynamic>> _contactsMap = {};
  List<dynamic> _messages = [];
  Map<String, dynamic>? _replyingToMessage;
  bool _isChatsLoading = true;
  bool _isMessagesLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  
  // Decrypted messages store: message_id -> plaintext
  final Map<int, String> _decryptedMessages = {};
  final Set<int> _messagesToAnimate = {};

  // Keys cache
  final Map<String, String> _peerPublicKeys = {};
  final Map<String, String> _chatSymmetricKeys = {};

  // Current user info
  Map<String, dynamic>? _myProfile;
  int? _myId;
  String? _myUsername;
  List<AccountInfo> _accounts = [];

  // Предзагруженные профили собеседников (userId -> данные с применённой приватностью)
  final Map<int, Map<String, dynamic>> _userProfileCache = {};

  // Кеш профилей авторов сообщений в группах (username/id -> {first_name, avatar, avatar_gradient})
  final Map<String, Map<String, dynamic>> _msgAuthorProfiles = {};

  // Search dialog state
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearchLoading = false;

  // Message input controller
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Polling timer
  Timer? _pollingTimer;
  WebSocketService? _webSocketService;
  final Map<String, String> _sentPlaintexts = {};
  final Map<String, String> _localVideoPaths = {};
  double _chatListWidth = 320.0;

  // Membership / Subscription state
  Set<String> _joinedChatIds = {};
  bool _isJoiningOrLeavingChat = false;
  final GlobalKey _headerSettingsKey = GlobalKey();

  // Typing status variables
  final Map<String, _TypingState> _activeTypingUsers = {};
  Timer? _typingExpiryTimer;
  Timer? _typingTimer;
  bool _isMeTyping = false;
  bool _showSendButton = false;
  bool _isVoiceMode = true;
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  bool _isHoveringRecordButton = false;
  String? _recordingPath;
  // На Linux используем Process напрямую (arecord), т.к. record_linux крашится.
  // На других платформах используем пакет record.
  Process? _arecordProcess;
  Process? _ffmpegProcess;
  CameraController? _cameraController;
  AudioRecorder? _audioRecorder;

  late final FocusNode _messageFocusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
          if (isShiftPressed) {
            return KeyEventResult.ignored;
          } else {
            if (_messageController.text.trim().isNotEmpty) {
              _sendMessage();
            }
            return KeyEventResult.handled;
          }
        }
      }
      return KeyEventResult.ignored;
    },
  );

  AppVersionInfo? _availableUpdate;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageTextChanged);
    _scrollController.addListener(_onScroll);
    _startTypingExpiryTimer();
    _loadPreferences();
    _initMessenger();
    _checkAppUpdate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CallManager>().addListener(_handleCallStateChanged);
        
        // Listen to multi-window methods (for custom notification replies)
        DesktopMultiWindow.setMethodHandler((MethodCall call, int fromWindowId) async {
          if (call.method == 'reply_message') {
            final data = call.arguments as Map;
            final chatId = data['chat_id']?.toString() ?? '';
            final text = data['text']?.toString() ?? '';
            _sendOverlayReply(chatId, text);
          } else if (call.method == 'accept_call') {
            final callManager = context.read<CallManager>();
            await callManager.acceptIncomingCall();
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ActiveCallScreen(),
                ),
              );
              await windowManager.show();
              await windowManager.focus();
            }
          } else if (call.method == 'decline_call') {
            final callManager = context.read<CallManager>();
            callManager.rejectIncomingCall();
          }
          return null;
        });
      }
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWidth = prefs.getDouble('chat_list_width');
    if (savedWidth != null && mounted) {
      setState(() {
        _chatListWidth = savedWidth;
      });
    }
  }

  Future<void> _checkAppUpdate() async {
    final update = await UpdateService().checkForUpdates();
    if (mounted && update != null) {
      setState(() {
        _availableUpdate = update;
      });
    }
  }

  @override
  void dispose() {
    // На Linux не трогаем AudioRecorder — он не используется.
    // Убиваем arecord если вдруг запущен.
    if (Platform.isLinux) {
      _arecordProcess?.kill();
      _ffmpegProcess?.kill();
    } else {
      _audioRecorder?.dispose();
    }
    try {
      context.read<CallManager>().removeListener(_handleCallStateChanged);
    } catch (_) {}
    _messageController.removeListener(_onMessageTextChanged);
    _webSocketService?.dispose();
    _pollingTimer?.cancel();
    _typingExpiryTimer?.cancel();
    _typingTimer?.cancel();
    _searchController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initMessenger() async {
    // 1. Load keys from local storage
    if (!_cryptoService.hasKeys) {
      final loaded = await _cryptoService.loadKeysFromLocalStorage();
      if (!loaded) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
          return;
        }
      }
    }

    // 2. Load profile & save current account to switcher list
    final profileRes = await _apiService.getProfile();
    if (profileRes.success && profileRes.data != null) {
      await AccountService().saveCurrentAccount(profileRes.data!);
      if (mounted) {
        setState(() {
          _myProfile = profileRes.data;
          final dynamic rawMyId = profileRes.data!['id'];
          _myId = rawMyId is int ? rawMyId : int.tryParse(rawMyId.toString());
          _myUsername = profileRes.data!['username'] as String?;
        });
        
        // Connect signaling service
        if (_myId != null) {
          final signaling = Provider.of<WebRTCSignalingService>(context, listen: false);
          if (!signaling.isConnected.value) {
            signaling.connect(_myId!.toString());
          }
        }
      }
    } else {
      if (profileRes.statusCode == 401) {
        if (mounted) {
          await _logout();
          return;
        }
      }
    }

  // Load active accounts list
    final accountsList = await AccountService().getAccounts();
    if (mounted) {
      setState(() {
        _accounts = accountsList;
      });
    }

    // 3. Load contacts, chats & start polling
    await _loadContactsCache();
    await _loadChats();
    _startPolling();
  }

  Future<void> _loadContactsCache() async {
    try {
      final res = await _apiService.dio.get('/contacts/list/');
      final data = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : {};
      final list = data['contacts'] is List ? data['contacts'] as List : [];
      final map = <int, Map<String, dynamic>>{};
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final userId = item['contact_user_id'];
          final idInt = userId is int ? userId : int.tryParse(userId?.toString() ?? '');
          if (idInt != null) {
            map[idInt] = item;
          }
        }
      }
      if (mounted) {
        setState(() {
          _contactsMap = map;
        });
      }
    } catch (_) {}
  }

  bool _isCallDialogShowing = false;

  void _handleCallStateChanged() {
    if (!mounted) return;
    final callManager = context.read<CallManager>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (callManager.state == CallState.incoming) {
      if (_isCallDialogShowing) return;
      _isCallDialogShowing = true;

      showGeneralDialog(
        context: context,
        barrierLabel: "IncomingCallDialog",
        barrierDismissible: false,
        barrierColor: isDark ? Colors.black.withOpacity(0.85) : Colors.black.withOpacity(0.3),
        transitionDuration: const Duration(milliseconds: 200),
        transitionBuilder: (context, anim1, anim2, child) {
          return FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                CurvedAnimation(parent: anim1, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        pageBuilder: (context, anim1, anim2) {
          return const IncomingCallDialog();
        },
      ).then((_) {
        _isCallDialogShowing = false;
      });
    }
  }

  bool _canMakeCallInCurrentChat() {
    if (_selectedChat == null) return false;
    final chatType = _selectedChat!['chat_type'] as String?;
    final otherUser = _selectedChat!['other_user'] as Map<String, dynamic>?;
    final isBot = otherUser != null && (
      otherUser['is_bot'] == true ||
      otherUser['bot'] == true ||
      (otherUser['username']?.toString().toLowerCase().endsWith('bot') ?? false)
    );

    if (chatType == 'personal' && !isBot) {
      return true;
    }
    if (chatType == 'group') {
      final enabled = _selectedChat!['group_calls_enabled'];
      if (enabled == null) return true;
      return enabled == true || enabled == 1 || enabled == 'true';
    }
    return false;
  }

  Future<void> _startCall(String callType) async {
    try {
      if (_selectedChat == null) return;
      final callManager = context.read<CallManager>();
      final chatType = _selectedChat!['chat_type'] as String?;

      if (chatType == 'group') {
        final groupId = _selectedChat!['chat_id']?.toString().replaceFirst('group_', '') ?? '';
        final groupName = _getChatName(_selectedChat!);
        final groupAvatar = _selectedChat!['avatar_url'] as String? ?? _selectedChat!['avatar'] as String?;
        final groupGradient = _selectedChat!['avatar_gradient'] as String?;

        await callManager.startOutgoingGroupCall(
          groupId: groupId,
          groupName: groupName,
          groupAvatar: groupAvatar,
          groupGradient: groupGradient,
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

      final otherUser = _selectedChat!['other_user'] as Map<String, dynamic>?;
      if (otherUser == null) return;

      final targetId = otherUser['id']?.toString() ?? '';
      final targetName = otherUser['first_name'] ?? otherUser['username'] ?? 'User';
      final targetAvatar = otherUser['avatar'];
      final targetGradient = otherUser['avatar_gradient'];
      final myUsername = _myUsername ?? 'User';

      await callManager.startOutgoingCall(
        targetUserId: targetId,
        targetName: targetName,
        targetAvatar: targetAvatar,
        targetGradient: targetGradient,
        callerName: myUsername,
        callType: callType,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ActiveCallScreen(),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('WebRTC Call error: $e\n$stack');
      if (mounted) {
        CustomToast.show(
          context,
          'Ошибка старта звонка: $e',
          type: ToastType.error,
        );
      }
    }
  }

  void _showCallChoiceModal(BuildContext context, double scale, bool isDark) {
    final l10n = AppLocalizations.of(context);
    showGeneralDialog(
      context: context,
      barrierLabel: "CallChoiceDialog",
      barrierDismissible: true,
      barrierColor: isDark ? Colors.black.withOpacity(0.85) : Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        final bgColor = isDark ? const Color(0xFF0C0C0C) : Colors.white;
        final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB);

        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: 340 * scale,
              margin: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.6 : 0.06),
                    blurRadius: 24 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 12 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.startCall ?? 'Начать звонок',
                          style: TextStyle(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5 * scale,
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontFamily: 'Inter',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Icon(
                              Icons.close_rounded,
                              size: 16 * scale,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Call options list
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 8 * scale),
                    child: Column(
                      children: [
                        // Audio Call
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              _startCall('audio');
                            },
                            hoverColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                            splashColor: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8 * scale),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 10 * scale),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10 * scale),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF10B981).withOpacity(0.15) : const Color(0xFF10B981).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.phone_rounded,
                                      color: const Color(0xFF10B981),
                                      size: 18 * scale,
                                    ),
                                  ),
                                  SizedBox(width: 14 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n?.audioCall ?? 'Голосовой звонок',
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black87,
                                            fontSize: 13.5 * scale,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        SizedBox(height: 2 * scale),
                                        Text(
                                          l10n?.audioCallDesc ?? 'Позвонить по голосовой связи',
                                          style: TextStyle(
                                            color: isDark ? Colors.white38 : Colors.black38,
                                            fontSize: 11.5 * scale,
                                            fontFamily: 'Inter',
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

                        SizedBox(height: 4 * scale),
                        Divider(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          height: 1,
                          indent: 10 * scale,
                          endIndent: 10 * scale,
                        ),
                        SizedBox(height: 4 * scale),

                        // Video Call
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              _startCall('video');
                            },
                            hoverColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                            splashColor: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8 * scale),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 10 * scale),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10 * scale),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF3B82F6).withOpacity(0.15) : const Color(0xFF3B82F6).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.videocam_rounded,
                                      color: const Color(0xFF3B82F6),
                                      size: 18 * scale,
                                    ),
                                  ),
                                  SizedBox(width: 14 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n?.videoCall ?? 'Видеозвонок',
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black87,
                                            fontSize: 13.5 * scale,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        SizedBox(height: 2 * scale),
                                        Text(
                                          l10n?.videoCallDesc ?? 'Позвонить с включенной камерой',
                                          style: TextStyle(
                                            color: isDark ? Colors.white38 : Colors.black38,
                                            fontSize: 11.5 * scale,
                                            fontFamily: 'Inter',
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
                  SizedBox(height: 12 * scale),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendOverlayReply(String chatId, String plaintextToEncrypt) async {
    final myUserId = _myId?.toString();
    
    // Find otherUser details for encryption from our chats list
    Map<String, dynamic>? targetChat;
    for (var c in _chats) {
      if (c['chat_id'] == chatId) {
        targetChat = c;
        break;
      }
    }
    
    final otherUser = targetChat?['other_user'] as Map<String, dynamic>?;

    String encryptedText = "";
    try {
      if (chatId.startsWith('favorites_') || chatId == 'favorites') {
        if (myUserId == null) return;
        encryptedText = await _cryptoService.encryptFavoritesMessage(plaintextToEncrypt, myUserId);
      } else if (chatId.startsWith('personal_')) {
        final peerPubKey = await _getPeerPublicKey(otherUser);
        if (peerPubKey == null) return;
        if (peerPubKey == 'bot') {
          final chatKeyHex = await _getGroupChatKey(chatId);
          if (chatKeyHex == null) return;
          encryptedText = await _cryptoService.encryptGroupMessage(plaintextToEncrypt, chatKeyHex);
        } else {
          encryptedText = await _cryptoService.encryptPersonalMessage(plaintextToEncrypt, peerPubKey, chatId);
        }
      } else if (chatId.startsWith('group_') || chatId.startsWith('channel_')) {
        final chatKeyHex = await _getGroupChatKey(chatId);
        if (chatKeyHex == null) return;
        encryptedText = await _cryptoService.encryptGroupMessage(plaintextToEncrypt, chatKeyHex);
      }
    } catch (e) {
      debugPrint("Overlay reply encryption failed: $e");
      return;
    }

    _sentPlaintexts[encryptedText] = plaintextToEncrypt;

    bool sentViaWs = false;
    if (_webSocketService != null && _webSocketService!.isConnected && _selectedChat?['chat_id'] == chatId) {
      sentViaWs = _webSocketService!.sendMessage({
        'type': 'encrypted_message',
        'encrypted_text': encryptedText,
      });
    }

    if (!sentViaWs) {
      _sentPlaintexts.remove(encryptedText);
      final res = await _apiService.sendMessage(chatId, encryptedText);
      if (res.success && res.data != null) {
        final newMsg = res.data!;
        final dynamic rawId = newMsg['id'];
        final id = rawId is int ? rawId : (int.tryParse(rawId.toString()) ?? 0);
        _decryptedMessages[id] = plaintextToEncrypt;

        if (mounted && _selectedChat?['chat_id'] == chatId) {
          setState(() {
            _messages.insert(0, newMsg);
            _messagesToAnimate.add(id);
          });
          _scrollToBottom();
        }
        _loadChats(silent: true);
      }
    }
  }

  Future<void> _checkForNewMessages(List<dynamic> oldChats, List<dynamic> newChats) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('settings_notifications') ?? true;
    if (!notificationsEnabled) return;

    for (var newChat in newChats) {
      final chatId = newChat['chat_id'] as String?;
      if (chatId == null) continue;
      
      final isFocused = await windowManager.isFocused();
      if (chatId == _selectedChat?['chat_id'] && isFocused) {
        continue;
      }

      final oldChat = oldChats.cast<Map<String, dynamic>?>().firstWhere(
        (c) => c != null && c['chat_id'] == chatId,
        orElse: () => null,
      );

      final oldUnread = oldChat?['unread_count'] as int? ?? 0;
      final newUnread = newChat['unread_count'] as int? ?? 0;

      if (newUnread > oldUnread) {
        final lastMsg = newChat['last_message'];
        if (lastMsg == null) continue;

        final encryptedText = lastMsg['encrypted_text'] as String?;
        if (encryptedText == null || encryptedText.isEmpty) continue;

        final otherUser = newChat['other_user'] as Map<String, dynamic>?;
        final senderName = otherUser != null 
            ? (otherUser['first_name'] ?? otherUser['username'] ?? (AppLocalizations.of(context)?.novoeSoobschenie_1d49 ?? 'Fallback')) 
            : (AppLocalizations.of(context)?.novoeSoobschenie_1d49 ?? 'Fallback');
        
        final avatar = otherUser?['avatar']?.toString();
        final gradient = otherUser?['avatar_gradient']?.toString();

        String body = "";
        try {
          body = await _decryptForChat(encryptedText, chatId, otherUser);
        } catch (_) {
          body = (AppLocalizations.of(context)?.zashifrovannoeSoobschenie_ca35 ?? 'Fallback');
        }

        if (body.startsWith('{')) {
          try {
            final parsed = jsonDecode(body);
            if (parsed['type'] == 'voice') {
              body = (AppLocalizations.of(context)?.golosovoeSoobschenie_4a85 ?? 'Fallback');
            } else if (parsed['type'] == 'video_message') {
              body = (AppLocalizations.of(context)?.videosoobschenie_d687 ?? 'Fallback');
            } else if (parsed['type'] == 'file') {
              body = (AppLocalizations.of(context)?.fayl_826d ?? 'Fallback');
            } else if (parsed['type'] == 'call') {
              body = (AppLocalizations.of(context)?.zvonok_e8d5 ?? 'Fallback');
            }
          } catch (_) {}
        }

        await NotificationService().showMessageNotification(
          chatId: chatId,
          title: senderName,
          body: body,
          avatar: avatar,
          gradient: gradient,
        );
      }
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _loadChats(silent: true);
      
      final wsActive = _webSocketService?.isConnected ?? false;
      if (_selectedChat != null && !wsActive) {
        _loadMessages(_selectedChat!['chat_id'] as String, silent: true);
      }
    });
  }

  Future<void> _connectWebSocket(String chatId) async {
    await _webSocketService?.disconnect();
    
    final token = await _apiService.getAccessToken();
    final wsUrl = ApiService.getWebSocketUrl(chatId, token);
    
    _webSocketService = WebSocketService(
      onMessageReceived: (data) => _handleWebSocketMessage(data, chatId),
      onError: (err) {
        print("WS error callback: $err");
        if (mounted && _selectedChat?['chat_id'] == chatId) {
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted && _selectedChat?['chat_id'] == chatId && !(_webSocketService?.isConnected ?? false)) {
              _connectWebSocket(chatId);
            }
          });
        }
      },
      onDone: () {
        print("WS done callback");
        if (mounted && _selectedChat?['chat_id'] == chatId) {
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted && _selectedChat?['chat_id'] == chatId && !(_webSocketService?.isConnected ?? false)) {
              _connectWebSocket(chatId);
            }
          });
        }
      },
    );
    
    try {
      await _webSocketService!.connect(wsUrl);
    } catch (e) {
      print("Failed to connect to WS: $e");
    }
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

  Future<void> _handleWebSocketMessage(Map<String, dynamic> data, String activeChatId) async {
    final type = data['type'] as String?;

    if (type == 'encrypted_message' ||
        type == 'todo_list_message' ||
        type == 'poll_message' ||
        type == 'voice_message' ||
        type == 'video_message' ||
        type == 'file_message' ||
        type == 'file') {
      final msgChatId = data['chat_id'] as String?;
      if (!_areSameChat(msgChatId, activeChatId)) return;

      final dynamic rawMsgId = data['id'];
      final msgId = rawMsgId is int ? rawMsgId : int.tryParse(rawMsgId.toString());
      if (msgId == null) return;

      final exists = _messages.any((m) => m['id'] == msgId);
      if (exists) return;



      if (type == 'todo_list_message') {
        data['message_type'] = 'todo_list';
        data['author_id'] = data['creator_id'];
      } else if (type == 'poll_message') {
        data['message_type'] = 'poll';
        data['author_id'] = data['creator_id'];
      } else if (type == 'voice_message') {
        data['message_type'] = 'voice';
      } else {
        data['message_type'] ??= 'regular';
      }
      
      final encryptedText = (data['encrypted_text'] ?? data['encrypted_content']) as String?;
      final otherUser = _selectedChat?['other_user'] as Map<String, dynamic>?;
      
      String decryptedText = "";
      if (type == 'voice_message') {
        decryptedText = jsonEncode({
          'type': 'voice',
          'file_id': data['file_id'],
          'duration': data['duration'],
          'mime_type': data['mime_type'] ?? 'audio/wav',
        });
      } else if (type == 'video_message') {
        final fileId = data['file_id']?.toString() ?? '';
        final localPath = _localVideoPaths[fileId];
        decryptedText = jsonEncode({
          'type': 'video_message',
          'file_id': fileId,
          'file_url': data['file_url'],
          'duration': data['duration'],
          'mime_type': data['mime_type'] ?? 'video/mp4',
          if (localPath != null) 'local_path': localPath,
        });
      } else if (data['message_type'] == 'call' || type == 'call') {
        decryptedText = jsonEncode({
          'type': 'call',
          'status': data['message_data']?['status'] ?? data['status'] ?? 'connected',
          'duration': data['message_data']?['duration'] ?? data['duration'] ?? 0,
          'call_type': data['message_data']?['call_type'] ?? data['call_type'] ?? 'audio',
          'caller_id': data['message_data']?['caller_id'] ?? data['caller_id'],
          'callee_id': data['message_data']?['callee_id'] ?? data['callee_id'],
        });
      } else if (encryptedText != null && encryptedText.isNotEmpty) {
        if (_sentPlaintexts.containsKey(encryptedText)) {
          decryptedText = _sentPlaintexts[encryptedText]!;
          _sentPlaintexts.remove(encryptedText);
        } else {
          try {
            decryptedText = await _decryptForChat(encryptedText, activeChatId, otherUser);
          } catch (_) {
            decryptedText = (AppLocalizations.of(context)?.oshibkaDeshifrovaniya_4146 ?? 'Fallback');
          }
        }
      }
      
      // Кешируем профиль автора для отображения аватарки в группе
      _cacheAuthorProfileFromMsg(data);
      
      if (mounted) {
        final isMyEcho = data['author_id']?.toString() == _myId?.toString();
        final pendingIndex = isMyEcho
            ? _messages.indexWhere((m) =>
                m['is_pending'] == true ||
                (m['id'] is int && (m['id'] as int) < 0) ||
                m['id'].toString().startsWith('temp_'))
            : -1;

        setState(() {
          _decryptedMessages[msgId] = decryptedText;
          if (pendingIndex != -1) {
            final oldId = _messages[pendingIndex]['id'];
            _messages[pendingIndex] = Map<String, dynamic>.from(data);
            _messages[pendingIndex]['is_pending'] = false;
            if (oldId != null && _decryptedMessages.containsKey(oldId)) {
              _decryptedMessages.remove(oldId);
            }
          } else {
            _messages.insert(0, data);
            _messagesToAnimate.add(msgId);
            _scrollToBottom();
          }
        });
      }
      _loadChats(silent: true);
      
      final isMe = data['author_id']?.toString() == _myId?.toString();
      if (!isMe) {
        _markChatAsRead(activeChatId);
        
        final isFocused = await windowManager.isFocused();
        if (!isFocused) {
          final prefs = await SharedPreferences.getInstance();
          final notificationsEnabled = prefs.getBool('settings_notifications') ?? true;
          if (notificationsEnabled) {
            final senderName = otherUser != null 
                ? (otherUser['first_name'] ?? otherUser['username'] ?? (AppLocalizations.of(context)?.novoeSoobschenie_1d49 ?? 'Fallback')) 
                : (AppLocalizations.of(context)?.novoeSoobschenie_1d49 ?? 'Fallback');
            
            final avatar = otherUser?['avatar']?.toString();
            final gradient = otherUser?['avatar_gradient']?.toString();
            
            String body = decryptedText;
            if (body.startsWith('{')) {
              try {
                final parsed = jsonDecode(body);
                if (parsed['type'] == 'voice') {
                  body = (AppLocalizations.of(context)?.golosovoeSoobschenie_4a85 ?? 'Fallback');
                } else if (parsed['type'] == 'video_message') {
                  body = (AppLocalizations.of(context)?.videosoobschenie_d687 ?? 'Fallback');
                } else if (parsed['type'] == 'file') {
                  body = (AppLocalizations.of(context)?.fayl_826d ?? 'Fallback');
                } else if (parsed['type'] == 'call') {
                  body = (AppLocalizations.of(context)?.zvonok_e8d5 ?? 'Fallback');
                }
              } catch (_) {}
            }

            NotificationService().showMessageNotification(
              chatId: activeChatId,
              title: senderName,
              body: body,
              avatar: avatar,
              gradient: gradient,
            );
          }
        }
      }
    } else if (type == 'todo_completion_update') {
      final todoMsgId = data['todo_message_id']?.toString();
      final itemIndex = data['item_index'];
      final isCompleted = data['is_completed'] as bool?;
      if (todoMsgId != null && itemIndex != null && isCompleted != null) {
        _updateTodoLocalCompletion(todoMsgId, itemIndex, isCompleted);
      }
    } else if (type == 'poll_vote_update' || type == 'poll_vote') {
      final pollMsgId = data['poll_message_id']?.toString();
      final optionId = data['option_id']?.toString();
      final removeVote = data['remove_vote'] == true;
      final userId = data['user_id']?.toString() ?? data['sender_id']?.toString();
      if (pollMsgId != null && optionId != null) {
        _updatePollLocalVote(pollMsgId, optionId, removeVote, userId ?? '');
      }
    } else if (type == 'chat_list_update' || type == 'new_chat') {
      _loadChats(silent: true);
    } else if (type == 'typing') {
      final userId = data['user_id']?.toString();
      final isTyping = data['is_typing'] == true;
      final action = data['action']?.toString() ?? 'typing';
      final username = data['username']?.toString() ?? '';
      final firstName = data['first_name']?.toString() ?? username;
      
      if (userId != null && userId != _myId?.toString()) {
        setState(() {
          if (isTyping) {
            _activeTypingUsers[userId] = _TypingState(
              username: username,
              firstName: firstName,
              action: action,
              timestamp: DateTime.now(),
            );
          } else {
            _activeTypingUsers.remove(userId);
          }
        });
      }
    } else if (type == 'messages_read' ||
        type == 'message_read' ||
        type == 'read_receipt' ||
        type == 'read') {
      // Собеседник прочитал сообщения — обновляем статус прямо в списке
      final readerId = data['reader_id']?.toString() ?? data['user_id']?.toString();
      // Не обрабатываем собственные события прочтения
      if (readerId != null && readerId == _myId?.toString()) return;

      final chatId = data['chat_id']?.toString();
      if (!_areSameChat(chatId, activeChatId)) return;

      // Список конкретных ID — если пустой, помечаем все исходящие
      final rawIds = data['message_ids'];
      final List<dynamic> messageIds = rawIds is List ? rawIds : [];

      if (mounted) {
        setState(() {
          if (messageIds.isNotEmpty) {
            for (final id in messageIds) {
              final idx = _messages.indexWhere(
                  (m) => m['id']?.toString() == id.toString());
              if (idx != -1) {
                _messages[idx]['is_read'] = true;
                _messages[idx]['is_read_by_recipient'] = true;
              }
            }
          } else {
            // Помечаем все наши исходящие сообщения
            for (final msg in _messages) {
              if (msg['author_id']?.toString() == _myId?.toString() ||
                  msg['sender_id']?.toString() == _myId?.toString()) {
                msg['is_read'] = true;
                msg['is_read_by_recipient'] = true;
              }
            }
          }
        });
      }
    }
  }

  void _onMessageTextChanged() {
    final text = _messageController.text;
    
    final bool hasText = text.trim().isNotEmpty || _attachedFile != null;
    if (hasText != _showSendButton) {
      setState(() {
        _showSendButton = hasText;
      });
    }

    if (text.isNotEmpty && !_isMeTyping) {
      _sendTypingStatus(true, 'typing');
    } else if (text.isEmpty && _isMeTyping) {
      _sendTypingStatus(false, 'typing');
    }
    
    if (text.isNotEmpty) {
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isMeTyping) {
          _sendTypingStatus(false, 'typing');
        }
      });
    }
  }

  void _sendTypingStatus(bool isTyping, String action) {
    if (_webSocketService != null && _webSocketService!.isConnected) {
      _isMeTyping = isTyping;
      _webSocketService!.sendMessage({
        'type': 'typing',
        'is_typing': isTyping,
        'action': action,
      });
    }
  }

  void _startTypingExpiryTimer() {
    _typingExpiryTimer?.cancel();
    _typingExpiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final now = DateTime.now();
      bool changed = false;
      _activeTypingUsers.removeWhere((userId, state) {
        final expired = now.difference(state.timestamp).inSeconds > 5;
        if (expired) changed = true;
        return expired;
      });
      if (changed) {
        setState(() {});
      }
    });
  }

  String? _getTypingStatusText({Map<String, dynamic>? chat}) {
    final targetChat = chat ?? _selectedChat;
    if (targetChat == null) return null;
    if (_selectedChat == null || targetChat['chat_id'] != _selectedChat!['chat_id']) return null;
    
    if (_activeTypingUsers.isEmpty) return null;
    
    final l10n = AppLocalizations.of(context);
    final chatType = targetChat['chat_type'] as String?;
    if (chatType == 'personal') {
      final state = _activeTypingUsers.values.first;
      if (state.action == 'recording_voice') {
        return l10n?.isRecordingVoice ?? 'записывает голосовое...';
      }
      return l10n?.isTyping ?? 'печатает...';
    } else {
      if (_activeTypingUsers.length == 1) {
        final state = _activeTypingUsers.values.first;
        final name = state.firstName.isNotEmpty ? state.firstName : state.username;
        if (state.action == 'recording_voice') {
          return '$name ${l10n?.isRecordingVoice ?? "записывает голосовое..."}';
        }
        return '$name ${l10n?.isTyping ?? "печатает..."}';
      } else {
        final names = _activeTypingUsers.values
            .map((s) => s.firstName.isNotEmpty ? s.firstName : s.username)
            .join(', ');
        return '$names ${l10n?.areTyping ?? "печатают..."}';
      }
    }
  }

  Future<void> _loadChats({bool silent = false}) async {
    if (!silent) {
      setState(() => _isChatsLoading = true);
    }
    final res = await _apiService.getChats();
    if (res.success && res.data != null) {
      final chatList = (res.data!['chats'] as List? ?? [])
          .map((c) => Map<String, dynamic>.from(c as Map))
          .toList();
      final archivedList = (res.data!['archived_chats'] as List? ?? [])
          .map((c) => Map<String, dynamic>.from(c as Map))
          .toList();

      if (mounted) {
        if (_chats.isNotEmpty) {
          _checkForNewMessages(_chats, chatList);
        }
        setState(() {
          _chats = chatList;
          _archivedChats = archivedList;
          _isChatsLoading = false;
          
          final joinedIds = <String>{};
          for (final c in [...chatList, ...archivedList]) {
            final id = c['chat_id'] as String?;
            if (id != null) joinedIds.add(id);
          }
          _joinedChatIds = joinedIds;
          
          if (_selectedChat != null) {
            final allChats = [...chatList, ...archivedList];
            final updatedChat = allChats.cast<Map<String, dynamic>?>().firstWhere(
                  (c) => c != null && c['chat_id'] == _selectedChat!['chat_id'],
                  orElse: () => null,
                );
            if (updatedChat != null) {
              _selectedChat = updatedChat;
            }
          }
        });
        
        // Decrypt latest message preview in each chat
        for (var chat in [...chatList, ...archivedList]) {
          final lastMsg = chat['last_message'];
          if (lastMsg != null) {
            _decryptSingleMessage(lastMsg, chat['chat_id'] as String, chat['other_user']);
          }
        }
      }
    } else {
      if (mounted) {
        setState(() => _isChatsLoading = false);
      }
    }
  }

  int _getArchivedUnreadCount() {
    int count = 0;
    for (var chat in _archivedChats) {
      final dynamic rawUnread = chat['unread_count'];
      final unreadCount = rawUnread is int ? rawUnread : int.tryParse(rawUnread.toString()) ?? 0;
      count += unreadCount;
    }
    return count;
  }

  Future<void> _toggleArchive(Map<String, dynamic> chat) async {
    final chatId = chat['chat_id'] as String;
    final isArchived = chat['is_archived'] as bool? ?? false;
    final newStatus = !isArchived;

    // Optimistically update the UI status
    setState(() {
      if (newStatus) {
        _chats.removeWhere((c) => c['chat_id'] == chatId);
        chat['is_archived'] = true;
        if (!_archivedChats.any((c) => c['chat_id'] == chatId)) {
          _archivedChats.add(chat);
        }
        if (_selectedChat != null && _selectedChat!['chat_id'] == chatId) {
          _selectedChat = null;
        }
      } else {
        _archivedChats.removeWhere((c) => c['chat_id'] == chatId);
        chat['is_archived'] = false;
        if (!_chats.any((c) => c['chat_id'] == chatId)) {
          _chats.add(chat);
        }
        if (_selectedChat != null && _selectedChat!['chat_id'] == chatId) {
          _selectedChat = null;
        }
      }
    });

    final res = await _apiService.archiveChat(chatId, newStatus);
    if (!res.success) {
      CustomToast.show(
        context,
        newStatus ? (AppLocalizations.of(context)?.neUdalosArhivirovatChat_ab89 ?? 'Fallback') : (AppLocalizations.of(context)?.neUdalosRazarhivirovatChat_f0d7 ?? 'Fallback'),
        type: ToastType.error,
      );
      _loadChats(silent: true);
    }
  }

  Widget _buildArchiveFolderItem(BuildContext context, bool isDark, double scale) {
    final unreadCount = _getArchivedUnreadCount();
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _viewingArchive = true;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.archive_outlined,
                  color: isDark ? Colors.white70 : Colors.black54,
                  size: 20 * scale,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (AppLocalizations.of(context)?.arhiv_56aa ?? 'Fallback'),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13.5 * scale,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (AppLocalizations.of(context)?.arhivirovannyeChaty_d990 ?? 'Fallback'),
                      style: TextStyle(
                        fontSize: 11 * scale,
                        color: isDark ? Colors.white30 : Colors.black38,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: TextStyle(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Кешируем first_name + avatar + avatar_gradient автора из любого сообщения
  void _cacheAuthorProfileFromMsg(Map<String, dynamic> msg) {
    final key = msg['author_username']?.toString() ??
        msg['author_id']?.toString() ??
        msg['sender_id']?.toString();
    if (key == null || key.isEmpty) return;

    String? firstName;
    String? avatar;
    String? gradient;

    if (msg['author'] is Map) {
      final authorMap = Map<String, dynamic>.from(msg['author'] as Map);
      firstName = authorMap['first_name']?.toString();
      avatar = authorMap['avatar']?.toString() ?? authorMap['avatar_url']?.toString();
      gradient = authorMap['avatar_gradient']?.toString();
    }

    firstName ??= msg['author_first_name']?.toString() ?? msg['first_name']?.toString();
    avatar ??= msg['author_avatar']?.toString() ?? msg['avatar']?.toString();
    gradient ??= msg['author_avatar_gradient']?.toString() ?? msg['avatar_gradient']?.toString();

    final existing = _msgAuthorProfiles[key];
    firstName ??= existing?['first_name']?.toString();
    if (avatar == null || avatar.isEmpty) avatar = existing?['avatar']?.toString();
    if (gradient == null || gradient.isEmpty) gradient = existing?['avatar_gradient']?.toString();

    if (firstName != null || avatar != null || gradient != null) {
      _msgAuthorProfiles[key] = {
        'first_name': (firstName != null && firstName.isNotEmpty) ? firstName : key,
        'avatar': avatar,
        'avatar_gradient': gradient ?? '',
      };
    }
  }

  /// Рендерит аватарку пользователя для группового сообщения.
  /// Если есть png — показываем его, иначе — градиентный кружок с инициалом.
  Widget _buildGroupAvatar(String? avatar, String? gradient, String displayName, double size) {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    // Парсим градиент из строки вида "linear-gradient(135deg, #A, #B)"
    List<Color> gradientColors = [const Color(0xFF2563EB), const Color(0xFF7C3AED)];
    if (gradient != null && gradient.isNotEmpty) {
      final hexMatches = RegExp(r'#([0-9a-fA-F]{6})').allMatches(gradient);
      final parsed = hexMatches
          .map((m) => Color(int.parse('FF${m.group(1)}', radix: 16)))
          .toList();
      if (parsed.length >= 2) gradientColors = parsed;
      else if (parsed.length == 1) gradientColors = [parsed[0], parsed[0]];
    }

    final hasRealAvatar = avatar != null &&
        avatar.isNotEmpty &&
        !avatar.contains('gradient') &&
        (avatar.startsWith('http') || avatar.startsWith('/'));

    if (hasRealAvatar) {
      final url = avatar.startsWith('http') ? avatar : 'https://xaneo.ru$avatar';
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildGradientAvatar(gradientColors, initial, size),
        ),
      );
    }

    return _buildGradientAvatar(gradientColors, initial, size);
  }

  Widget _buildGradientAvatar(List<Color> colors, String initial, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }

  Future<void> _loadMessages(String chatId, {bool silent = false}) async {
    if (!silent) {
      setState(() => _isMessagesLoading = true);
    }
    _hasMoreMessages = true;
    _isLoadingMore = false;
    final res = await _apiService.getMessages(chatId, limit: 20, offset: 0);
    if (res.success && res.data != null) {
      final msgList = res.data!['results'] as List? ?? [];
      for (final msg in msgList) {
        if (msg is Map<String, dynamic>) _cacheAuthorProfileFromMsg(msg);
      }
      if (mounted) {
        setState(() {
          _messages = msgList.toList();
          _isMessagesLoading = false;
          _hasMoreMessages = msgList.length >= 20;
        });
        
        // Decrypt all fetched messages
        _decryptAllMessages(_messages, chatId, _selectedChat?['other_user']);
      }
    } else {
      if (mounted) {
        setState(() => _isMessagesLoading = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 100) {
        _loadMoreMessages();
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages || _selectedChat == null) return;

    final chatId = _selectedChat!['chat_id'] as String;
    setState(() {
      _isLoadingMore = true;
    });

    final currentOffset = _messages.length;
    final res = await _apiService.getMessages(chatId, limit: 20, offset: currentOffset);

    if (res.success && res.data != null) {
      final msgList = res.data!['results'] as List? ?? [];
      for (final msg in msgList) {
        if (msg is Map<String, dynamic>) _cacheAuthorProfileFromMsg(msg);
      }
      if (mounted) {
        setState(() {
          _messages.addAll(msgList.toList());
          _isLoadingMore = false;
          _hasMoreMessages = msgList.length >= 20;
        });

        // Decrypt only the new batch of messages
        _decryptAllMessages(msgList, chatId, _selectedChat?['other_user']);
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  /// Get the peer's public key hex for personal chats
  Future<String?> _getPeerPublicKey(Map<String, dynamic>? otherUser) async {
    if (otherUser == null) return null;

    final isBot = otherUser['is_bot'] == true ||
        otherUser['bot'] == true ||
        (otherUser['username']?.toString().toLowerCase().endsWith('bot') ?? false);
    if (isBot) {
      return 'bot';
    }

    final userId = otherUser['id'];
    if (userId == null) return null;
    final userIdStr = userId.toString();

    if (_peerPublicKeys.containsKey(userIdStr)) {
      return _peerPublicKeys[userIdStr];
    }

    // The web client uses userId in the URL: /xsec2/keys/{userId}/
    final res = await _apiService.getUserPublicKey(userIdStr);
    if (res.success && res.data != null) {
      if (res.data!['is_bot'] == true) {
        _peerPublicKeys[userIdStr] = 'bot';
        return 'bot';
      }
      final key = res.data!['x25519_public_key'] as String?;
      if (key != null) {
        _peerPublicKeys[userIdStr] = key;
        return key;
      }
    }
    return null;
  }

  /// Get the server-managed symmetric key for group/channel chats
  Future<String?> _getGroupChatKey(String chatId) async {
    if (_chatSymmetricKeys.containsKey(chatId)) {
      return _chatSymmetricKeys[chatId];
    }

    final res = await _apiService.getChatKey(chatId);
    if (res.success && res.data != null) {
      final key = res.data!['key'] as String?;
      if (key != null) {
        _chatSymmetricKeys[chatId] = key;
        return key;
      }
    }
    return null;
  }

  bool _isBase64(String str) {
    try {
      final trimmed = str.trim();
      if (trimmed.isEmpty) return false;
      final decoded = base64Decode(trimmed);
      return decoded.length >= 28;
    } catch (_) {
      return false;
    }
  }

  /// Decrypt a single message based on chat type
  Future<String> _decryptForChat(String encryptedText, String chatId, Map<String, dynamic>? otherUser) async {
    if (!_isBase64(encryptedText)) {
      return encryptedText;
    }

    final myUserId = _myId?.toString();

    if (chatId.startsWith('favorites_') || chatId == 'favorites') {
      if (myUserId == null) return (AppLocalizations.of(context)?.netUserid_634a ?? 'Fallback');
      return await _cryptoService.decryptFavoritesMessage(encryptedText, myUserId);
    }

    if (chatId.startsWith('personal_')) {
      final peerPubKey = await _getPeerPublicKey(otherUser);
      if (peerPubKey == null) return (AppLocalizations.of(context)?.netKlyucha_337b ?? 'Fallback');
      if (peerPubKey == 'bot') {
        final chatKeyHex = await _getGroupChatKey(chatId);
        if (chatKeyHex == null) return (AppLocalizations.of(context)?.netKlyucha_337b ?? 'Fallback');
        return await _cryptoService.decryptGroupMessage(encryptedText, chatKeyHex);
      }
      return await _cryptoService.decryptPersonalMessage(encryptedText, peerPubKey, chatId);
    }

    if (chatId.startsWith('group_') || chatId.startsWith('channel_')) {
      final chatKeyHex = await _getGroupChatKey(chatId);
      if (chatKeyHex == null) return (AppLocalizations.of(context)?.netKlyucha_337b ?? 'Fallback');
      return await _cryptoService.decryptGroupMessage(encryptedText, chatKeyHex);
    }

    return (AppLocalizations.of(context)?.neizvestnyyTipChata_2617 ?? 'Fallback');
  }

  Future<void> _decryptSingleMessage(dynamic msg, String chatId, Map<String, dynamic>? otherUser) async {
    final dynamic rawId = msg['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) return;
    final existing = _decryptedMessages[id];
    final isCall = (msg['type'] == 'call' || msg['message_type'] == 'call');
    if (existing != null && (!isCall || existing.startsWith('{'))) return;

    final type = msg['type'] as String?;
    final messageType = msg['message_type'] as String?;
    
    if (type == 'voice_message' || messageType == 'voice') {
      if (mounted) {
        setState(() {
          _decryptedMessages[id] = jsonEncode({
            'type': 'voice',
            'file_id': msg['file_id'],
            'duration': msg['duration'],
            'mime_type': msg['mime_type'] ?? 'audio/wav',
          });
        });
      }
      return;
    } else if (type == 'video_message' || messageType == 'video' || messageType == 'video_message') {
      if (mounted) {
        setState(() {
          _decryptedMessages[id] = jsonEncode({
            'type': 'video_message',
            'file_id': msg['file_id'] ?? msg['attached_file_id'],
            'file_url': msg['file_url'] ?? msg['attached_file_url'],
            'duration': msg['duration'] ?? msg['attached_file_duration'],
            'mime_type': msg['mime_type'] ?? msg['attached_file_type'] ?? 'video/mp4',
          });
        });
      }
      return;
    } else if (type == 'call' || messageType == 'call') {
      if (mounted) {
        setState(() {
          _decryptedMessages[id] = jsonEncode({
            'type': 'call',
            'status': msg['message_data']?['status'] ?? msg['status'] ?? 'connected',
            'duration': msg['message_data']?['duration'] ?? msg['duration'] ?? 0,
            'call_type': msg['message_data']?['call_type'] ?? msg['call_type'] ?? 'audio',
            'caller_id': msg['message_data']?['caller_id'] ?? msg['caller_id'],
            'callee_id': msg['message_data']?['callee_id'] ?? msg['callee_id'],
          });
        });
      }
      return;
    }

    final systemTypes = const [
      'system',
      'user_joined',
      'user_joined_group',
      'user_left',
      'user_left_group',
      'user_invited_group',
      'user_invited_channel',
      'user_subscribed_channel',
      'user_unsubscribed_channel'
    ];
    if (systemTypes.contains(messageType) || msg['is_system'] == true) {
      if (mounted) {
        setState(() {
          _decryptedMessages[id] = msg['encrypted_text'] as String? ?? '';
        });
      }
      return;
    }

    final encryptedText = msg['encrypted_text'] as String?;
    if (encryptedText == null || encryptedText.isEmpty) {
      _decryptedMessages[id] = "";
      return;
    }

    String decrypted;
    try {
      decrypted = await _decryptForChat(encryptedText, chatId, otherUser);
    } catch (_) {
      decrypted = (AppLocalizations.of(context)?.oshibkaDeshifrovaniya_4146 ?? 'Fallback');
    }

    final replyTextRaw = msg['reply_text'] as String?;
    if (replyTextRaw != null && replyTextRaw.isNotEmpty && _isBase64(replyTextRaw)) {
      try {
        final decryptedReply = await _decryptForChat(replyTextRaw, chatId, otherUser);
        if (decryptedReply != replyTextRaw && !decryptedReply.startsWith('[')) {
          msg['reply_text'] = decryptedReply;
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _decryptedMessages[id] = decrypted;
      });
    }
  }

  Future<void> _decryptAllMessages(List<dynamic> messages, String chatId, Map<String, dynamic>? otherUser) async {
    for (var msg in messages) {
      final dynamic rawId = msg['id'];
      final id = rawId is int ? rawId : int.tryParse(rawId.toString());
      if (id == null) continue;
      final existing = _decryptedMessages[id];
      final isCall = (msg['type'] == 'call' || msg['message_type'] == 'call');
      if (existing != null && (!isCall || existing.startsWith('{'))) continue;

      final type = msg['type'] as String?;
      final messageType = msg['message_type'] as String?;

      if (type == 'voice_message' || messageType == 'voice') {
        if (mounted) {
          setState(() {
            _decryptedMessages[id] = jsonEncode({
              'type': 'voice',
              'file_id': msg['file_id'],
              'duration': msg['duration'],
              'mime_type': msg['mime_type'] ?? 'audio/wav',
            });
          });
        }
        continue;
      } else if (type == 'video_message' || messageType == 'video' || messageType == 'video_message') {
        if (mounted) {
          setState(() {
            _decryptedMessages[id] = jsonEncode({
              'type': 'video_message',
              'file_id': msg['file_id'] ?? msg['attached_file_id'],
              'file_url': msg['file_url'] ?? msg['attached_file_url'],
              'duration': msg['duration'] ?? msg['attached_file_duration'],
              'mime_type': msg['mime_type'] ?? msg['attached_file_type'] ?? 'video/mp4',
            });
          });
        }
        continue;
      } else if (type == 'call' || messageType == 'call') {
        if (mounted) {
          setState(() {
            _decryptedMessages[id] = jsonEncode({
              'type': 'call',
              'status': msg['message_data']?['status'] ?? msg['status'] ?? 'connected',
              'duration': msg['message_data']?['duration'] ?? msg['duration'] ?? 0,
              'call_type': msg['message_data']?['call_type'] ?? msg['call_type'] ?? 'audio',
              'caller_id': msg['message_data']?['caller_id'] ?? msg['caller_id'],
              'callee_id': msg['message_data']?['callee_id'] ?? msg['callee_id'],
            });
          });
        }
        continue;
      }

      final encryptedText = msg['encrypted_text'] as String?;
      if (encryptedText == null || encryptedText.isEmpty) {
        _decryptedMessages[id] = "";
        continue;
      }

      String decrypted;
      try {
        decrypted = await _decryptForChat(encryptedText, chatId, otherUser);
      } catch (_) {
        decrypted = (AppLocalizations.of(context)?.oshibkaDeshifrovaniya_4146 ?? 'Fallback');
      }

      final replyTextRaw = msg['reply_text'] as String?;
      if (replyTextRaw != null && replyTextRaw.isNotEmpty && _isBase64(replyTextRaw)) {
        try {
          final decryptedReply = await _decryptForChat(replyTextRaw, chatId, otherUser);
          if (decryptedReply != replyTextRaw && !decryptedReply.startsWith('[')) {
            msg['reply_text'] = decryptedReply;
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _decryptedMessages[id] = decrypted;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if ((text.isEmpty && _attachedFile == null) || _selectedChat == null) return;

    if (_isMeTyping) {
      _sendTypingStatus(false, 'typing');
    }
    _typingTimer?.cancel();

    final chatId = _selectedChat!['chat_id'] as String;
    final myUserId = _myId?.toString();
    final otherUser = _selectedChat!['other_user'] as Map<String, dynamic>?;

    _messageController.clear();

    String plaintextToEncrypt = text;
    String? fileIdToSend;

    if (_attachedFile != null) {
      fileIdToSend = _attachedFile!['file_id'] as String;
      if (text.isEmpty) {
        plaintextToEncrypt = '';
      }
      
      setState(() {
        _attachedFile = null;
        _showSendButton = false;
      });
    }

    String encryptedText = "";
    try {
      if (chatId.startsWith('favorites_') || chatId == 'favorites') {
        if (myUserId == null) {
          print("Cannot encrypt: myUserId is null");
          return;
        }
        encryptedText = await _cryptoService.encryptFavoritesMessage(plaintextToEncrypt, myUserId);
      } else if (chatId.startsWith('personal_')) {
        final peerPubKey = await _getPeerPublicKey(otherUser);
        if (peerPubKey == null) {
          CustomToast.show(
            context,
            (AppLocalizations.of(context)?.neUdalosPoluchitKlyuchShifrovaniya_b953 ?? 'Fallback'),
            type: ToastType.error,
          );
          return;
        }
        if (peerPubKey == 'bot') {
          final chatKeyHex = await _getGroupChatKey(chatId);
          if (chatKeyHex == null) {
            CustomToast.show(
              context,
              (AppLocalizations.of(context)?.neUdalosPoluchitKlyuchShifrovaniya_b953 ?? 'Fallback'),
              type: ToastType.error,
            );
            return;
          }
          encryptedText = await _cryptoService.encryptGroupMessage(plaintextToEncrypt, chatKeyHex);
        } else {
          encryptedText = await _cryptoService.encryptPersonalMessage(plaintextToEncrypt, peerPubKey, chatId);
        }
      } else if (chatId.startsWith('group_') || chatId.startsWith('channel_')) {
        final chatKeyHex = await _getGroupChatKey(chatId);
        if (chatKeyHex == null) {
          CustomToast.show(
            context,
            (AppLocalizations.of(context)?.neUdalosPoluchitKlyuchShifrovaniya_b953 ?? 'Fallback'),
            type: ToastType.error,
          );
          return;
        }
        encryptedText = await _cryptoService.encryptGroupMessage(plaintextToEncrypt, chatKeyHex);
      }
    } catch (e) {
      print("Encryption failed: $e");
      return;
    }

    _sentPlaintexts[encryptedText] = plaintextToEncrypt;

    final dynamic rawReplyId = _replyingToMessage?['id'];
    final replyToId = rawReplyId?.toString();
    if (_replyingToMessage != null) {
      setState(() {
        _replyingToMessage = null;
      });
    }

    bool sentViaWs = false;
    if (_webSocketService != null && _webSocketService!.isConnected) {
      sentViaWs = _webSocketService!.sendMessage({
        'type': 'encrypted_message',
        'encrypted_text': encryptedText,
        if (fileIdToSend != null) 'file_id': fileIdToSend,
        if (replyToId != null) 'reply_to_id': replyToId,
      });
    }

    if (sentViaWs) {
      final int tempId = -DateTime.now().millisecondsSinceEpoch;
      final tempMsg = {
        'id': tempId,
        'is_pending': true,
        'author_id': _myId,
        'sender_id': _myId,
        'author_username': _myUsername ?? (AppLocalizations.of(context)?.vy_0101 ?? 'Fallback'),
        'encrypted_text': encryptedText,
        'created_at': DateTime.now().toIso8601String(),
        'reply_to_id': replyToId,
        'reply_text': _replyingToMessage?['reply_text'],
        'is_read': false,
        'chat_id': chatId,
      };

      _decryptedMessages[tempId] = plaintextToEncrypt;
      if (mounted) {
        setState(() {
          _messages.insert(0, tempMsg);
          _messagesToAnimate.add(tempId);
        });
        _scrollToBottom();
      }
    }

    if (!sentViaWs) {
      _sentPlaintexts.remove(encryptedText);
      final res = await _apiService.sendMessage(chatId, encryptedText);
      if (res.success && res.data != null) {
        final newMsg = res.data!;
        final dynamic rawId = newMsg['id'];
        final id = rawId is int ? rawId : (int.tryParse(rawId.toString()) ?? 0);
        _decryptedMessages[id] = text;

        if (mounted) {
          setState(() {
            _messages.insert(0, newMsg);
            _messagesToAnimate.add(id);
          });
          _scrollToBottom();
        }
        _loadChats(silent: true);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _markChatAsRead(String chatId) async {
    final res = await _apiService.markMessagesAsRead(chatId);
    if (res.success) {
      if (mounted) {
        setState(() {
          for (var i = 0; i < _chats.length; i++) {
            if (_chats[i]['chat_id'] == chatId) {
              final updated = Map<String, dynamic>.from(_chats[i]);
              updated['unread_count'] = 0;
              _chats[i] = updated;
              break;
            }
          }
          for (var i = 0; i < _archivedChats.length; i++) {
            if (_archivedChats[i]['chat_id'] == chatId) {
              final updated = Map<String, dynamic>.from(_archivedChats[i]);
              updated['unread_count'] = 0;
              _archivedChats[i] = updated;
              break;
            }
          }
        });
      }
    }
  }

  void _selectChat(Map<String, dynamic> chat) {
    if (_selectedChat != null && _selectedChat!['chat_id'] == chat['chat_id']) {
      return;
    }
    
    _typingTimer?.cancel();
    _isMeTyping = false;
    _activeTypingUsers.clear();
    
    setState(() {
      _selectedChat = chat;
      _messages = [];
      _messagesToAnimate.clear();
      _isMessagesLoading = true;
    });
    final chatId = (chat['chat_id'] ?? chat['id'])?.toString();
    if (chatId == null || chatId.isEmpty) return;
    _loadMessages(chatId);
    _connectWebSocket(chatId);
    _markChatAsRead(chatId);
    _scrollToBottom();
    _prefetchUserProfile(chat);
  }

  /// Заранее подгружает профиль собеседника (для личных чатов), чтобы модалка
  /// открывалась мгновенно без спиннера. Результат кладём в [_userProfileCache].
  Future<void> _prefetchUserProfile(Map<String, dynamic> chat) async {
    if (chat['chat_type'] != 'personal') return;
    final otherUser = chat['other_user'] as Map<String, dynamic>?;
    if (otherUser == null) return;
    final dynamic rawId = otherUser['id'];
    final int? userId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    if (userId == null) return;

    final res = await _apiService.getUserById(userId);
    if (res.success && res.data != null) {
      _userProfileCache[userId] = {...otherUser, ...res.data!};
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearchLoading = true);
    final res = await _apiService.searchUsers(query);
    if (res.success && res.data != null) {
      setState(() {
        _searchResults = res.data!['users'] as List? ?? [];
        _isSearchLoading = false;
      });
    } else {
      setState(() => _isSearchLoading = false);
    }
  }

  void _startChatWithUser(Map<String, dynamic> user) {
    final rawTargetId = user['user_id'] ?? user['id'];
    final targetId = rawTargetId is int ? rawTargetId : (int.tryParse(rawTargetId?.toString() ?? '') ?? 0);
    final targetUsername = user['username']?.toString() ?? 'user';
    if (_myId == null || targetId == 0) return;

    // Сначала ищем, существует ли уже чат с этим пользователем в списке чатов
    final existingChat = [..._chats, ..._archivedChats].cast<Map<String, dynamic>?>().firstWhere(
      (c) {
        if (c == null) return false;
        final otherUser = c['other_user'] as Map<String, dynamic>?;
        final otherId = otherUser?['id'] ?? c['user_id'];
        final otherIdInt = otherId is int ? otherId : int.tryParse(otherId?.toString() ?? '');
        return (otherIdInt != null && otherIdInt == targetId) ||
            _areSameChat(c['chat_id']?.toString(), "personal_${_myId}_$targetId");
      },
      orElse: () => null,
    );

    if (existingChat != null) {
      final customName = user['custom_name'] ?? user['display_name'];
      if (customName != null && customName.toString().isNotEmpty) {
        existingChat['chat_display_name'] = customName.toString();
        if (existingChat['other_user'] is Map) {
          (existingChat['other_user'] as Map<String, dynamic>)['first_name'] = customName.toString();
        }
      }
      _selectChat(existingChat);
      return;
    }

    final rawFirstName = user['first_name']?.toString() ?? '';
    final rawLastName = user['last_name']?.toString() ?? '';
    var displayName = '$rawFirstName $rawLastName'.trim();
    if (displayName.isEmpty) {
      displayName = user['display_name']?.toString() ?? '';
    }
    if (displayName.isEmpty) {
      displayName = targetUsername;
    }

    _typingTimer?.cancel();
    _isMeTyping = false;
    _activeTypingUsers.clear();

    // Create unique personal chat ID
    final sorted = [_myId!, targetId]..sort();
    final chatId = "personal_${sorted[0]}_${sorted[1]}";
    
    final newChat = {
      'chat_id': chatId,
      'chat_type': 'personal',
      'chat_display_name': displayName,
      'other_user': {
        'id': targetId,
        'username': targetUsername,
        'first_name': displayName,
        'avatar_url': user['avatar_url'] ?? user['avatar'],
        'avatar_gradient': user['avatar_gradient'] ?? '',
      }
    };

    setState(() {
      _selectedChat = newChat;
      _isSearching = false;
      _searchResults = [];
      _searchController.clear();
      
      final existingIndex = _chats.indexWhere((c) => c['chat_id'] == chatId);
      if (existingIndex == -1) {
        _chats.insert(0, newChat);
      } else {
        _chats.removeAt(existingIndex);
        _chats.insert(0, newChat);
      }
      _messages = [];
      _messagesToAnimate.clear();
      _isMessagesLoading = true;
    });
    
    _loadMessages(chatId);
    _connectWebSocket(chatId);
    _markChatAsRead(chatId);
    _prefetchUserProfile(newChat);
  }

  String _formatPluralCount(int count, String one, String few, String many) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod100 >= 11 && mod100 <= 19) {
      return '$count $many';
    }
    if (mod10 == 1) {
      return '$count $one';
    }
    if (mod10 >= 2 && mod10 <= 4) {
      return '$count $few';
    }
    return '$count $many';
  }

  String _getGroupStatusText(Map<String, dynamic> chat) {
    final rawCount = chat['members_count'] ?? chat['members']?.length ?? chat['participants_count'] ?? 0;
    final count = rawCount is int ? rawCount : int.tryParse(rawCount.toString()) ?? 0;
    final l10n = AppLocalizations.of(context);
    if (count <= 0) return l10n?.group ?? 'Группа';
    return l10n?.membersCount(count) ?? '$count участников';
  }

  String _getChannelStatusText(Map<String, dynamic> chat) {
    final rawCount = chat['subscribers_count'] ?? chat['subscribers']?.length ?? 0;
    final count = rawCount is int ? rawCount : int.tryParse(rawCount.toString()) ?? 0;
    final l10n = AppLocalizations.of(context);
    if (count <= 0) return l10n?.channel ?? 'Канал';
    return l10n?.subscribersCount(count) ?? '$count подписчиков';
  }

  DateTime? _parseMsgDate(dynamic createdAt) {
    if (createdAt == null) return null;
    try {
      return DateTime.parse(createdAt.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateDivider(DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == todayDate) {
      return l10n?.today ?? 'Сегодня';
    } else if (msgDate == yesterdayDate) {
      return l10n?.yesterday ?? 'Вчера';
    } else {
      final months = [
        l10n?.monthJan ?? 'января',
        l10n?.monthFeb ?? 'февраля',
        l10n?.monthMar ?? 'марта',
        l10n?.monthApr ?? 'апреля',
        l10n?.monthMay ?? 'мая',
        l10n?.monthJun ?? 'июня',
        l10n?.monthJul ?? 'июля',
        l10n?.monthAug ?? 'августа',
        l10n?.monthSep ?? 'сентября',
        l10n?.monthOct ?? 'октября',
        l10n?.monthNov ?? 'ноября',
        l10n?.monthDec ?? 'декабря',
      ];
      final monthStr = months[date.month - 1];
      if (date.year == now.year) {
        return '${date.day} $monthStr';
      } else {
        return '${date.day} $monthStr ${date.year}';
      }
    }
  }

  Widget _buildDateDivider(String text, bool isDark, double scale) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 12 * scale),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 4 * scale),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
            width: 0.8,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11.5 * scale,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  bool _isUserSubscribedOrJoined(Map<String, dynamic>? chat) {
    if (chat == null) return false;
    final chatType = chat['chat_type'] as String?;
    if (chatType == 'personal' || chatType == 'favorites') {
      return true;
    }
    final chatId = chat['chat_id'] as String?;
    if (chatId == null) return false;

    if (chat['is_subscribed'] == true || chat['is_member'] == true || chat['is_joined'] == true) {
      return true;
    }
    if (chat['is_subscribed'] == false || chat['is_member'] == false || chat['is_joined'] == false) {
      return false;
    }

    return _joinedChatIds.contains(chatId);
  }

  Future<void> _handleJoinChat(Map<String, dynamic> chat) async {
    final chatId = chat['chat_id'] as String?;
    if (chatId == null || _isJoiningOrLeavingChat) return;

    setState(() {
      _isJoiningOrLeavingChat = true;
    });

    final res = await _apiService.joinChat(chatId);

    if (mounted) {
      setState(() {
        _isJoiningOrLeavingChat = false;
      });

      if (res.success) {
        chat['is_subscribed'] = true;
        chat['is_member'] = true;
        chat['is_joined'] = true;

        if (chat['chat_type'] == 'channel') {
          final count = (chat['subscribers_count'] is int ? chat['subscribers_count'] as int : int.tryParse(chat['subscribers_count']?.toString() ?? '0') ?? 0);
          chat['subscribers_count'] = count + 1;
        } else if (chat['chat_type'] == 'group') {
          final count = (chat['members_count'] is int ? chat['members_count'] as int : int.tryParse(chat['members_count']?.toString() ?? '0') ?? 0);
          chat['members_count'] = count + 1;
        }

        setState(() {
          _joinedChatIds.add(chatId);
          final existingIndex = _chats.indexWhere((c) => c['chat_id'] == chatId);
          if (existingIndex < 0) {
            _chats.insert(0, chat);
          }
        });

        final isChannel = chat['chat_type'] == 'channel';
        CustomToast.show(
          context,
          isChannel ? (AppLocalizations.of(context)?.vyPodpisalisNaKanal_b2b3 ?? 'Fallback') : (AppLocalizations.of(context)?.vyPrisoedinilisKGruppe_07bd ?? 'Fallback'),
          type: ToastType.success,
        );

        _loadMessages(chatId);
        _connectWebSocket(chatId);
      } else {
        CustomToast.show(
          context,
          res.error ?? (AppLocalizations.of(context)?.neUdalosPrisoedinitsya_31e6 ?? 'Fallback'),
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _handleLeaveChat(Map<String, dynamic> chat) async {
    final chatId = chat['chat_id'] as String?;
    if (chatId == null || _isJoiningOrLeavingChat) return;

    setState(() {
      _isJoiningOrLeavingChat = true;
    });

    final res = await _apiService.leaveChat(chatId);

    if (mounted) {
      setState(() {
        _isJoiningOrLeavingChat = false;
      });

      if (res.success) {
        chat['is_subscribed'] = false;
        chat['is_member'] = false;
        chat['is_joined'] = false;

        if (chat['chat_type'] == 'channel') {
          final count = (chat['subscribers_count'] is int ? chat['subscribers_count'] as int : int.tryParse(chat['subscribers_count']?.toString() ?? '0') ?? 0);
          chat['subscribers_count'] = count > 0 ? count - 1 : 0;
        } else if (chat['chat_type'] == 'group') {
          final count = (chat['members_count'] is int ? chat['members_count'] as int : int.tryParse(chat['members_count']?.toString() ?? '0') ?? 0);
          chat['members_count'] = count > 0 ? count - 1 : 0;
        }

        setState(() {
          _joinedChatIds.remove(chatId);
          _chats.removeWhere((c) => c['chat_id'] == chatId);
          _archivedChats.removeWhere((c) => c['chat_id'] == chatId);
        });

        final isChannel = chat['chat_type'] == 'channel';
        CustomToast.show(
          context,
          isChannel ? (AppLocalizations.of(context)?.vyOtpisalisOtKanala_7698 ?? 'Fallback') : (AppLocalizations.of(context)?.vyPokinuliGruppu_5a52 ?? 'Fallback'),
          type: ToastType.info,
        );
      } else {
        CustomToast.show(
          context,
          res.error ?? (AppLocalizations.of(context)?.neUdalosVypolnitDeystvie_3cfd ?? 'Fallback'),
          type: ToastType.error,
        );
      }
    }
  }

  void _handleSearchResultSelected(Map<String, dynamic> item, String type) {
    if (type == 'favorites') {
      if (_myId == null) return;
      final chatId = 'favorites_user_$_myId';
      final favChat = {
        'chat_id': chatId,
        'chat_type': 'favorites',
        'chat_display_name': (AppLocalizations.of(context)?.izbrannoe_2fc4 ?? 'Fallback'),
      };
      setState(() {
        _selectedChat = favChat;
        final existingIndex = _chats.indexWhere((c) => c['chat_id'] == chatId);
        if (existingIndex < 0) {
          _chats.insert(0, favChat);
        }
      });
      _loadMessages(chatId);
      _connectWebSocket(chatId);
      _markChatAsRead(chatId);
    } else if (type == 'group') {
      final groupId = item['id'];
      final chatId = 'group_$groupId';
      final isMember = item['is_member'] == true || _joinedChatIds.contains(chatId);
      final groupChat = {
        'chat_id': chatId,
        'chat_type': 'group',
        'chat_display_name': item['name'] ?? (AppLocalizations.of(context)?.gruppa_99d9 ?? 'Fallback'),
        'group_id': groupId,
        'members_count': item['members_count'] ?? 0,
        'avatar_url': item['avatar'] ?? item['avatar_url'],
        'avatar_gradient': item['avatar_gradient'] ?? '',
        'is_member': isMember,
        'is_joined': isMember,
      };
      setState(() {
        _selectedChat = groupChat;
        if (isMember) {
          final existingIndex = _chats.indexWhere((c) => c['chat_id'] == chatId);
          if (existingIndex < 0) {
            _chats.insert(0, groupChat);
          }
        }
      });
      _loadMessages(chatId);
      _connectWebSocket(chatId);
      _markChatAsRead(chatId);
    } else if (type == 'channel') {
      final channelId = item['id'];
      final chatId = 'channel_$channelId';
      final isSubscribed = item['is_subscribed'] == true || _joinedChatIds.contains(chatId);
      final channelChat = {
        'chat_id': chatId,
        'chat_type': 'channel',
        'chat_display_name': item['name'] ?? (AppLocalizations.of(context)?.kanal_2710 ?? 'Fallback'),
        'channel_id': channelId,
        'subscribers_count': item['subscribers_count'] ?? 0,
        'avatar_url': item['avatar'] ?? item['avatar_url'],
        'avatar_gradient': item['avatar_gradient'] ?? '',
        'is_subscribed': isSubscribed,
        'is_joined': isSubscribed,
      };
      setState(() {
        _selectedChat = channelChat;
        if (isSubscribed) {
          final existingIndex = _chats.indexWhere((c) => c['chat_id'] == chatId);
          if (existingIndex < 0) {
            _chats.insert(0, channelChat);
          }
        }
      });
      _loadMessages(chatId);
      _connectWebSocket(chatId);
      _markChatAsRead(chatId);
    } else {
      _startChatWithUser(item);
    }
  }

  Future<void> _logout() async {
    await _webSocketService?.disconnect();
    
    // Find the account to remove by the current token, because _myId might be out of sync
    // during an account switch if the new account's token is invalid.
    int? accountToRemove;
    final prefs = await SharedPreferences.getInstance();
    final currentToken = prefs.getString('xaneo_access_token');
    if (currentToken != null) {
      final accounts = await AccountService().getAccounts();
      try {
        final match = accounts.firstWhere((a) => a.accessToken == currentToken);
        accountToRemove = match.userId;
      } catch (_) {}
    }
    accountToRemove ??= _myId;

    await _apiService.logout();
    await _cryptoService.clearKeys();
    
    if (accountToRemove != null) {
      await AccountService().removeAccount(accountToRemove);
    }
    
    _myId = null;
    
    final remainingAccounts = await AccountService().getAccounts();
    if (remainingAccounts.isNotEmpty) {
      await _switchAccount(remainingAccounts.first.userId);
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _switchAccount(int userId) async {
    if (mounted) {
      setState(() {
        _isChatsLoading = true;
        _isMessagesLoading = true;
      });
    }
    
    _pollingTimer?.cancel();
    await _webSocketService?.disconnect();
    
    final success = await AccountService().switchAccount(userId);
    if (success) {
      _selectedChat = null;
      _messages = [];
      _decryptedMessages.clear();
      await _initMessenger();
    } else {
      if (mounted) {
        CustomToast.show(
          context,
          (AppLocalizations.of(context)?.neUdalosPereklyuchitAkkaunt_968b ?? 'Fallback'),
          type: ToastType.error,
        );
      }
      if (mounted) {
        setState(() {
          _isChatsLoading = false;
          _isMessagesLoading = false;
        });
      }
    }
  }

  String _formatBirthday(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final l10n = AppLocalizations.of(context);
      final d = DateTime.parse(iso);
      final months = [
        l10n?.monthJan ?? 'января',
        l10n?.monthFeb ?? 'февраля',
        l10n?.monthMar ?? 'марта',
        l10n?.monthApr ?? 'апреля',
        l10n?.monthMay ?? 'мая',
        l10n?.monthJun ?? 'июня',
        l10n?.monthJul ?? 'июля',
        l10n?.monthAug ?? 'августа',
        l10n?.monthSep ?? 'сентября',
        l10n?.monthOct ?? 'октября',
        l10n?.monthNov ?? 'ноября',
        l10n?.monthDec ?? 'декабря',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '';
    }
  }

  /// Модалка с информацией о пользователе. Данные подгружаются с сервера,
  /// который уже применяет настройки приватности (скрытые поля приходят null).
  void _showUserProfileDialog(
    BuildContext context,
    Map<String, dynamic> otherUser,
    String fallbackName,
  ) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaleProvider = Provider.of<ScaleProvider>(context, listen: false);
    final scale = scaleProvider.scale;

    final dynamic rawId = otherUser['id'];
    final int? userId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    final mockTabs = <Map<String, dynamic>>[
      {'title': l10n?.media ?? 'Медиа', 'icon': Icons.image_rounded},
      {'title': l10n?.files ?? 'Файлы', 'icon': Icons.description_rounded},
      {'title': l10n?.voice ?? 'Голосовые', 'icon': Icons.mic_rounded},
      {'title': l10n?.links ?? 'Ссылки', 'icon': Icons.link_rounded},
    ];

    showGeneralDialog(
      context: context,
      barrierLabel: 'UserProfile',
      barrierDismissible: true,
      barrierColor: isDark ? Colors.black.withOpacity(0.85) : Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        final screenSize = MediaQuery.of(context).size;
        final bgColor = isDark ? const Color(0xFF0C0C0C) : Colors.white;
        final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB);

        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: 360 * scale,
              constraints: BoxConstraints(
                maxHeight: screenSize.height * 0.85,
              ),
              margin: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.6 : 0.06),
                    blurRadius: 24 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 4 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.profile ?? 'Профиль',
                          style: TextStyle(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5 * scale,
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontFamily: 'Inter',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Icon(
                              Icons.close_rounded,
                              size: 16 * scale,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20 * scale, 8 * scale, 20 * scale, 20 * scale),
                      child: Builder(
                        builder: (context) {
                          // Профиль предзагружен при открытии чата → берём из кэша,
                          // иначе фолбэк на то, что уже есть в чате.
                          final Map<String, dynamic> data = {
                            ...otherUser,
                            if (userId != null && _userProfileCache.containsKey(userId))
                              ..._userProfileCache[userId]!,
                          };

                          final name = (data['first_name']?.toString().trim().isNotEmpty ?? false)
                              ? data['first_name'].toString()
                              : ((data['username']?.toString().trim().isNotEmpty ?? false)
                                  ? data['username'].toString()
                                  : fallbackName);
                          final username = data['username']?.toString() ?? '';
                          final avatarUrl = (data['avatar_url'] ?? data['avatar'])?.toString();
                          final gradient = data['avatar_gradient']?.toString();
                          final bio = data['bio']?.toString() ?? '';
                          final birthday = _formatBirthday(data['birth_date']?.toString());
                          final age = data['age'];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Avatar + name + username
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildAvatar(
                                      avatarUrl,
                                      name,
                                      40 * scale,
                                      scale,
                                      isDark,
                                      avatarGradient: gradient,
                                    ),
                                    SizedBox(height: 14 * scale),
                                    Text(
                                      name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 19 * scale,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    if (username.isNotEmpty) ...[
                                      SizedBox(height: 3 * scale),
                                      Text(
                                        '@$username',
                                        style: TextStyle(
                                          fontSize: 12.5 * scale,
                                          color: isDark ? Colors.white38 : Colors.black45,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: 20 * scale),

                              // Details
                              _buildProfileDetails(
                                isDark,
                                scale,
                                bio: bio,
                                username: username,
                                birthday: birthday,
                                age: age is int ? age : (age is num ? age.toInt() : null),
                              ),

                              SizedBox(height: 20 * scale),

                              // Shared-media tabs (parsed from chat messages)
                              _buildProfileSharedMediaSection(isDark, scale),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showGroupProfileDialog(BuildContext context, Map<String, dynamic> chat) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaleProvider = Provider.of<ScaleProvider>(context, listen: false);
    final scale = scaleProvider.scale;

    final name = chat['chat_display_name'] ?? chat['name'] ?? (l10n?.group ?? 'Группа');
    final membersCount = chat['members_count'] is int ? chat['members_count'] as int : (int.tryParse(chat['members_count']?.toString() ?? '') ?? 0);
    final avatarUrl = (chat['avatar_url'] ?? chat['avatar'])?.toString();
    final gradient = chat['avatar_gradient']?.toString();

    showGeneralDialog(
      context: context,
      barrierLabel: 'GroupProfile',
      barrierDismissible: true,
      barrierColor: isDark ? Colors.black.withOpacity(0.85) : Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        final screenSize = MediaQuery.of(context).size;
        final bgColor = isDark ? const Color(0xFF0C0C0C) : Colors.white;
        final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB);

        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: 360 * scale,
              constraints: BoxConstraints(maxHeight: screenSize.height * 0.85),
              margin: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.6 : 0.06),
                    blurRadius: 24 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 4 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.group.toUpperCase() ?? 'ГРУППА',
                          style: TextStyle(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5 * scale,
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontFamily: 'Inter',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Icon(
                              Icons.close_rounded,
                              size: 16 * scale,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20 * scale, 8 * scale, 20 * scale, 20 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildAvatar(
                                  avatarUrl,
                                  name,
                                  40 * scale,
                                  scale,
                                  isDark,
                                  avatarGradient: gradient,
                                ),
                                SizedBox(height: 14 * scale),
                                Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 19 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                SizedBox(height: 3 * scale),
                                Text(
                                  l10n?.membersCount(membersCount) ?? '$membersCount участников',
                                  style: TextStyle(
                                    fontSize: 12.5 * scale,
                                    color: isDark ? Colors.white38 : Colors.black45,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20 * scale),
                          _buildProfileSharedMediaSection(isDark, scale),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showChannelProfileDialog(BuildContext context, Map<String, dynamic> chat) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaleProvider = Provider.of<ScaleProvider>(context, listen: false);
    final scale = scaleProvider.scale;

    final name = chat['chat_display_name'] ?? chat['name'] ?? (l10n?.channel ?? 'Канал');
    final subsCount = chat['subscribers_count'] is int ? chat['subscribers_count'] as int : (int.tryParse(chat['subscribers_count']?.toString() ?? '') ?? 0);
    final avatarUrl = (chat['avatar_url'] ?? chat['avatar'])?.toString();
    final gradient = chat['avatar_gradient']?.toString();

    showGeneralDialog(
      context: context,
      barrierLabel: 'ChannelProfile',
      barrierDismissible: true,
      barrierColor: isDark ? Colors.black.withOpacity(0.85) : Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        final screenSize = MediaQuery.of(context).size;
        final bgColor = isDark ? const Color(0xFF0C0C0C) : Colors.white;
        final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB);

        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: 360 * scale,
              constraints: BoxConstraints(maxHeight: screenSize.height * 0.85),
              margin: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.6 : 0.06),
                    blurRadius: 24 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 4 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.channel.toUpperCase() ?? 'КАНАЛ',
                          style: TextStyle(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5 * scale,
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontFamily: 'Inter',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Icon(
                              Icons.close_rounded,
                              size: 16 * scale,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20 * scale, 8 * scale, 20 * scale, 20 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildAvatar(
                                  avatarUrl,
                                  name,
                                  40 * scale,
                                  scale,
                                  isDark,
                                  avatarGradient: gradient,
                                ),
                                SizedBox(height: 14 * scale),
                                Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 19 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                SizedBox(height: 3 * scale),
                                Text(
                                  l10n?.subscribersCount(subsCount) ?? '$subsCount подписчиков',
                                  style: TextStyle(
                                    fontSize: 12.5 * scale,
                                    color: isDark ? Colors.white38 : Colors.black45,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20 * scale),
                          _buildProfileSharedMediaSection(isDark, scale),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFavoritesProfileDialog(BuildContext context, Map<String, dynamic> chat) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaleProvider = Provider.of<ScaleProvider>(context, listen: false);
    final scale = scaleProvider.scale;

    final name = l10n?.savedMessages ?? 'Избранное';

    showGeneralDialog(
      context: context,
      barrierLabel: 'FavoritesProfile',
      barrierDismissible: true,
      barrierColor: isDark ? Colors.black.withOpacity(0.85) : Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        final screenSize = MediaQuery.of(context).size;
        final bgColor = isDark ? const Color(0xFF0C0C0C) : Colors.white;
        final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB);

        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: 360 * scale,
              constraints: BoxConstraints(maxHeight: screenSize.height * 0.85),
              margin: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.6 : 0.06),
                    blurRadius: 24 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 4 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.savedMessages.toUpperCase() ?? 'ИЗБРАННОЕ',
                          style: TextStyle(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5 * scale,
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontFamily: 'Inter',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Icon(
                              Icons.close_rounded,
                              size: 16 * scale,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20 * scale, 8 * scale, 20 * scale, 20 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80 * scale,
                                  height: 80 * scale,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.bookmark_rounded,
                                    size: 40 * scale,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 14 * scale),
                                Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 19 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                SizedBox(height: 4 * scale),
                                Text(
                                  l10n?.savedMessagesDesc ?? 'Ваше личное хранилище для заметок, файлов и сообщений',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12 * scale,
                                    color: isDark ? Colors.white38 : Colors.black45,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20 * scale),
                          _buildProfileSharedMediaSection(isDark, scale),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileDetails(
    bool isDark,
    double scale, {
    required String bio,
    required String username,
    required String birthday,
    required int? age,
  }) {
    final tiles = <Widget>[];
    final l10n = AppLocalizations.of(context);

    void addTile(IconData icon, String value, String label, {bool copyable = true}) {
      if (tiles.isNotEmpty) {
        tiles.add(Divider(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          height: 1,
          indent: 48 * scale,
        ));
      }
      tiles.add(_buildProfileInfoTile(isDark, scale, icon, value, label, copyable: copyable));
    }

    if (bio.isNotEmpty) addTile(Icons.info_outline_rounded, bio, l10n?.bio ?? 'О себе', copyable: false);
    if (username.isNotEmpty) {
      addTile(Icons.alternate_email_rounded, '@$username', l10n?.username ?? 'Имя пользователя');
    }
    if (birthday.isNotEmpty) {
      final ageStr = age != null ? ' • $age ${_pluralizeYears(age)}' : '';
      addTile(Icons.cake_outlined, '$birthday$ageStr', l10n?.birthday ?? 'День рождения', copyable: false);
    }

    if (tiles.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8 * scale),
        child: Center(
          child: Text(
            l10n?.userHidInfo ?? 'Пользователь скрыл информацию о себе',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * scale,
              color: isDark ? Colors.white38 : Colors.black38,
              fontFamily: 'Inter',
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
        ),
      ),
      padding: EdgeInsets.all(4 * scale),
      child: Column(children: tiles),
    );
  }

  String _pluralizeYears(int n) {
    if (n % 10 == 1 && n % 100 != 11) return (AppLocalizations.of(context)?.god_6270 ?? 'Fallback');
    if ([2, 3, 4].contains(n % 10) && ![12, 13, 14].contains(n % 100)) return (AppLocalizations.of(context)?.goda_7443 ?? 'Fallback');
    return (AppLocalizations.of(context)?.let_257a ?? 'Fallback');
  }

  Widget _buildProfileInfoTile(
    bool isDark,
    double scale,
    IconData icon,
    String value,
    String label, {
    bool copyable = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: copyable
            ? () {
                final l10n = AppLocalizations.of(context);
                Clipboard.setData(ClipboardData(text: value));
                CustomToast.show(context, l10n?.copied ?? 'Скопировано', type: ToastType.success);
              }
            : null,
        borderRadius: BorderRadius.circular(8 * scale),
        hoverColor: copyable
            ? (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03))
            : Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 10 * scale),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16 * scale,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.5 * scale,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10.5 * scale,
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              if (copyable)
                Padding(
                  padding: EdgeInsets.only(top: 6 * scale),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 14 * scale,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSharedMediaSection(bool isDark, double scale) {
    final l10n = AppLocalizations.of(context);

    final mediaList = <Map<String, dynamic>>[];
    final filesList = <Map<String, dynamic>>[];
    final musicList = <Map<String, dynamic>>[];
    final voiceList = <Map<String, dynamic>>[];
    final linksList = <Map<String, dynamic>>[];

    final urlRegExp = RegExp(r'https?://[^\s]+', caseSensitive: false);

    for (final msg in _messages) {
      final customPayload = _getCustomPayload(msg);
      final attachedFileId = msg['attached_file_id']?.toString() ?? msg['file_id']?.toString();
      
      final payload = customPayload ?? (attachedFileId != null ? {
        'type': msg['attached_file_type'] ?? msg['file_type'] ?? 'file',
        'file_id': attachedFileId,
        'file_name': msg['attached_file_name'] ?? msg['file_name'] ?? (l10n?.file ?? 'Файл'),
        'file_url': msg['attached_file_url'] ?? msg['file_url'],
        'mime_type': msg['attached_file_type'] ?? msg['mime_type'] ?? '',
      } : null);

      final msgType = (payload?['type'] ?? payload?['message_type'] ?? msg['message_type'] ?? msg['type'])?.toString().toLowerCase() ?? '';
      
      String fileUrl = (payload?['file_url'] ?? payload?['media_url'] ?? payload?['url'] ?? msg['file_url'] ?? msg['media_url'] ?? msg['url'])?.toString() ?? '';
      if (fileUrl.isEmpty && payload?['file_id'] != null) {
        final fileId = payload!['file_id'].toString();
        final uri = Uri.parse(ApiService.baseUrl);
        final port = uri.hasPort ? ':${uri.port}' : '';
        final host = '${uri.scheme}://${uri.host}$port';
        fileUrl = '$host/api/files/download/$fileId/';
      }

      final fileName = (payload?['file_name'] ?? payload?['name'] ?? msg['file_name'] ?? msg['name'])?.toString() ?? '';
      final rawText = (msg['content'] ?? msg['text'] ?? msg['decrypted_text'])?.toString() ?? '';
      final decryptedText = _decryptedMessages[msg['id']] ?? rawText;
      final text = decryptedText.trim().startsWith('{') ? '' : decryptedText;

      final lowerUrl = fileUrl.toLowerCase();
      final lowerName = fileName.toLowerCase();
      final mimeType = (payload?['mime_type'] ?? msg['mime_type'])?.toString().toLowerCase() ?? '';

      final isMediaExt = lowerUrl.endsWith('.jpg') || lowerUrl.endsWith('.jpeg') || lowerUrl.endsWith('.png') || lowerUrl.endsWith('.webp') || lowerUrl.endsWith('.gif') || lowerUrl.endsWith('.mp4') || lowerUrl.endsWith('.mov') ||
                         lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg') || lowerName.endsWith('.png') || lowerName.endsWith('.webp') || lowerName.endsWith('.gif') || lowerName.endsWith('.mp4') || lowerName.endsWith('.mov');
      
      final isVoiceMsg = msgType == 'voice' || msgType == 'recording_voice' || msgType == 'recording_video' || mimeType.contains('opus');
      
      final isMusicMsg = msgType == 'audio' || (payload != null && _isAudioFile(payload)) || _isAudioFile(msg) ||
                         lowerUrl.endsWith('.mp3') || lowerUrl.endsWith('.m4a') || lowerUrl.endsWith('.flac') || lowerUrl.endsWith('.aac') || lowerUrl.endsWith('.ogg') || lowerUrl.endsWith('.wav') ||
                         lowerName.endsWith('.mp3') || lowerName.endsWith('.m4a') || lowerName.endsWith('.flac') || lowerName.endsWith('.aac') || lowerName.endsWith('.ogg') || lowerName.endsWith('.wav');

      if (fileUrl.isNotEmpty || payload != null) {
        if (isVoiceMsg) {
          voiceList.add({'url': fileUrl, 'name': fileName.isNotEmpty ? fileName : (l10n?.voiceMessage ?? 'Голосовое сообщение'), 'msg': msg});
        } else if (isMusicMsg) {
          musicList.add({'url': fileUrl, 'name': fileName.isNotEmpty ? fileName : (l10n?.music ?? 'Аудиозапись'), 'msg': msg});
        } else if (isMediaExt || msgType == 'image' || msgType == 'video' || msgType == 'photo') {
          mediaList.add({'url': fileUrl, 'name': fileName.isNotEmpty ? fileName : (l10n?.media ?? 'Медиафайлы'), 'msg': msg});
        } else {
          filesList.add({'url': fileUrl, 'name': fileName.isNotEmpty ? fileName : (l10n?.file ?? 'Файл'), 'msg': msg});
        }
      }

      if (text.isNotEmpty) {
        final matches = urlRegExp.allMatches(text);
        for (final match in matches) {
          linksList.add({'url': match.group(0)!, 'msg': msg});
        }
      }
    }

    final tabs = [
      {'title': l10n?.media ?? 'Медиа', 'icon': Icons.image_rounded, 'count': mediaList.length, 'items': mediaList},
      {'title': l10n?.files ?? 'Файлы', 'icon': Icons.description_rounded, 'count': filesList.length, 'items': filesList},
      {'title': l10n?.music ?? 'Музыка', 'icon': Icons.music_note_rounded, 'count': musicList.length, 'items': musicList},
      {'title': l10n?.voice ?? 'Голосовые', 'icon': Icons.mic_rounded, 'count': voiceList.length, 'items': voiceList},
      {'title': l10n?.links ?? 'Ссылки', 'icon': Icons.link_rounded, 'count': linksList.length, 'items': linksList},
    ];

    int activeTabIndex = 0;

    return StatefulBuilder(
      builder: (context, setTabState) {
        final activeTab = tabs[activeTabIndex];
        final items = activeTab['items'] as List<Map<String, dynamic>>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: List.generate(tabs.length, (i) {
                final tab = tabs[i];
                final isSelected = i == activeTabIndex;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.0 * scale),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setTabState(() {
                            activeTabIndex = i;
                          });
                        },
                        borderRadius: BorderRadius.circular(10 * scale),
                        child: Container(
                          height: 44 * scale,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06))
                                : (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01)),
                            borderRadius: BorderRadius.circular(10 * scale),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04)),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    tab['icon'] as IconData,
                                    size: 12 * scale,
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : (isDark ? Colors.white38 : Colors.black38),
                                  ),
                                  SizedBox(width: 3 * scale),
                                  Flexible(
                                    child: Text(
                                      '${tab['title']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9.0 * scale,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected
                                            ? (isDark ? Colors.white : Colors.black87)
                                            : (isDark ? Colors.white38 : Colors.black38),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if ((tab['count'] as int) > 0) ...[
                                SizedBox(height: 2 * scale),
                                Text(
                                  '${tab['count']}',
                                  style: TextStyle(
                                    fontSize: 8.0 * scale,
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : (isDark ? Colors.white24 : Colors.black26),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 12 * scale),
            Container(
              constraints: BoxConstraints(minHeight: 80 * scale, maxHeight: 200 * scale),
              width: double.infinity,
              padding: EdgeInsets.all(8 * scale),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.015),
                borderRadius: BorderRadius.circular(10 * scale),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                ),
              ),
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            activeTab['icon'] as IconData,
                            size: 24 * scale,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                          SizedBox(height: 6 * scale),
                          Text(
                            activeTabIndex == 0
                                ? (l10n?.noSharedMedia ?? 'Нет медиафайлов')
                                : activeTabIndex == 1
                                    ? (l10n?.noSharedFiles ?? 'Нет файлов')
                                    : activeTabIndex == 2
                                        ? (l10n?.noSharedMusic ?? 'Нет музыкальных треков')
                                        : activeTabIndex == 3
                                            ? (l10n?.noSharedVoice ?? 'Нет голосовых сообщений')
                                            : (l10n?.noSharedLinks ?? 'Нет ссылок'),
                            style: TextStyle(
                              fontSize: 11 * scale,
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: items.map((item) {
                          final url = item['url']?.toString() ?? '';
                          final name = item['name']?.toString() ?? url;

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4 * scale),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: url));
                                  CustomToast.show(
                                    context,
                                    l10n?.copied ?? 'Скопировано',
                                    type: ToastType.success,
                                  );
                                },
                                borderRadius: BorderRadius.circular(6 * scale),
                                child: Padding(
                                  padding: EdgeInsets.all(6 * scale),
                                  child: Row(
                                    children: [
                                      Icon(
                                        activeTab['icon'] as IconData,
                                        size: 16 * scale,
                                        color: const Color(0xFF2563EB),
                                      ),
                                      SizedBox(width: 8 * scale),
                                      Expanded(
                                        child: Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12 * scale,
                                            color: isDark ? Colors.white70 : Colors.black87,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.copy_rounded,
                                        size: 13 * scale,
                                        color: isDark ? Colors.white24 : Colors.black26,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAccountSwitcherDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaleProvider = Provider.of<ScaleProvider>(context, listen: false);
    final scale = scaleProvider.scale;
    
    showGeneralDialog(
      context: context,
      barrierLabel: "AccountSwitcher",
      barrierDismissible: true,
      barrierColor: isDark ? Colors.black.withOpacity(0.85) : Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final screenSize = MediaQuery.of(context).size;
            final bgColor = isDark ? const Color(0xFF0C0C0C) : Colors.white;
            final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB);
            
            return Material(
              type: MaterialType.transparency,
              child: Center(
                child: Container(
                  width: 340 * scale,
                  constraints: BoxConstraints(
                    maxHeight: screenSize.height * 0.75,
                  ),
                  margin: EdgeInsets.all(20 * scale),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.6 : 0.06),
                        blurRadius: 24 * scale,
                        offset: Offset(0, 8 * scale),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 12 * scale),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n?.accountsTitle ?? 'АККАУНТЫ',
                              style: TextStyle(
                                fontSize: 10 * scale,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5 * scale,
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontFamily: 'Inter',
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16 * scale,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Accounts List
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                          child: FutureBuilder<List<AccountInfo>>(
                            future: AccountService().getAccounts(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20 * scale),
                                  child: Center(
                                    child: SizedBox(
                                      width: 16 * scale,
                                      height: 16 * scale,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              
                              final accounts = snapshot.data!;
                              
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...accounts.map((acc) {
                                    final isActive = acc.userId == _myId;
                                    
                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2 * scale),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03))
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8 * scale),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: isActive
                                                ? null
                                                : () {
                                                    Navigator.of(context).pop();
                                                    _switchAccount(acc.userId);
                                                  },
                                            hoverColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                                            splashColor: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                                            highlightColor: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                                            borderRadius: BorderRadius.circular(8 * scale),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 8 * scale),
                                              child: Row(
                                                children: [
                                                  _buildAvatar(
                                                    acc.avatarUrl,
                                                    (acc.firstName != null && acc.firstName!.isNotEmpty) ? acc.firstName! : acc.username,
                                                    16 * scale,
                                                    1.0,
                                                    isDark,
                                                    avatarGradient: acc.avatarGradient,
                                                  ),
                                                  SizedBox(width: 10 * scale),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          (acc.firstName != null && acc.firstName!.isNotEmpty) ? acc.firstName! : acc.username,
                                                          style: TextStyle(
                                                            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                                                            fontSize: 13 * scale,
                                                            color: isDark ? Colors.white70 : Colors.black87,
                                                            fontFamily: 'Inter',
                                                          ),
                                                        ),
                                                        if (acc.firstName != null && acc.firstName!.isNotEmpty) ...[
                                                          SizedBox(height: 1 * scale),
                                                          Text(
                                                            '@${acc.username}',
                                                            style: TextStyle(
                                                              fontSize: 10.5 * scale,
                                                              color: isDark ? Colors.white38 : Colors.black38,
                                                              fontFamily: 'Inter',
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 8 * scale),
                                                  if (isActive)
                                                    Icon(
                                                      Icons.check_rounded,
                                                      color: isDark ? Colors.white70 : Colors.black87,
                                                      size: 14 * scale,
                                                    )
                                                  else
                                                    GestureDetector(
                                                      onTap: () async {
                                                        await AccountService().removeAccount(acc.userId);
                                                        setModalState(() {});
                                                        final updated = await AccountService().getAccounts();
                                                        setState(() {
                                                          _accounts = updated;
                                                        });
                                                      },
                                                      child: MouseRegion(
                                                        cursor: SystemMouseCursors.click,
                                                        child: Padding(
                                                          padding: EdgeInsets.all(4 * scale),
                                                          child: Icon(
                                                            Icons.close_rounded,
                                                            size: 14 * scale,
                                                            color: isDark ? Colors.white38 : Colors.black38,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  
                                  SizedBox(height: 12 * scale),
                                  
                                  if (accounts.length < 5)
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 8 * scale),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 36 * scale,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDark ? Colors.white : Colors.black,
                                            foregroundColor: isDark ? Colors.black : Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6 * scale),
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pushNamed('/login');
                                          },
                                          child: Text(
                                            l10n?.addAccount ?? 'Добавить аккаунт',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12 * scale,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12 * scale),
                                      child: Center(
                                        child: Text(
                                          l10n?.accountLimitNotice ?? 'Лимит 5 аккаунтов',
                                          style: TextStyle(
                                            color: isDark ? Colors.white38 : Colors.black38,
                                            fontSize: 11 * scale,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final scaleProvider = Provider.of<ScaleProvider>(context);
    final l10n = AppLocalizations.of(context);
    final isDark = themeProvider.isDarkMode;
    final scale = scaleProvider.scale;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Background decoration
          Positioned.fill(
            child: AdvancedBackground(
              isDark: isDark,
              enableGrid: false,
              enableParticles: false,
              enableGeometricShapes: false,
            ),
          ),
          
          // Main layout
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: SafeArea(
              child: Row(
                children: [
                  // 1. Chat List Panel (resizable with Liquid Glass effect)
                  Container(
                    width: _chatListWidth * scale,
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.black.withOpacity(0.15) 
                          : Colors.white.withOpacity(0.15),
                      border: Border(
                        right: BorderSide(
                          color: isDark 
                              ? Colors.white.withOpacity(0.08) 
                              : Colors.black.withOpacity(0.04),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: _buildChatListPanel(isDark, scale),
                      ),
                    ),
                  ),

                  // Resizable Divider (overlapping transparent zone for dragging)
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _chatListWidth = (_chatListWidth + details.delta.dx / scale).clamp(240.0, 600.0);
                        });
                      },
                      onHorizontalDragEnd: (details) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('chat_list_width', _chatListWidth);
                      },
                      child: const SizedBox(
                        width: 8,
                      ),
                    ),
                  ),

                  // 2. Main Chat Panel (takes the rest)
                  Expanded(
                    child: _buildChatPanel(isDark, scale),
                  ),
                ],
              ),
            ),
          ),

          // Settings Modal Overlay — деактивирован, используем XaneoSettingsModal
          // Positioned.fill(
          //   child: SettingsButton(
          //     key: _settingsKey,
          //     showFloatingButton: false,
          //   ),
          // ),

          // Search Overlay
          if (_isSearching) _buildSearchOverlay(isDark, scale),
        ],
      ),
    );
  }

  Widget _buildChatListPanel(bool isDark, double scale) {
    return Column(
      children: [
        // Header
        Container(
          height: 46 + 18 * scale,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_viewingArchive)
                IconButton(
                  icon: Icon(Icons.arrow_back_rounded, size: 20 * scale),
                  tooltip: (AppLocalizations.of(context)?.nazadKChatam_7edb ?? 'Fallback'),
                  onPressed: () {
                    setState(() {
                      _viewingArchive = false;
                    });
                  },
                  color: isDark ? Colors.white70 : Colors.black54,
                )
              else
                IconButton(
                  icon: Icon(Icons.menu_rounded, size: 20 * scale),
                  tooltip: (AppLocalizations.of(context)?.nastroyki_c919 ?? 'Fallback'),
                  onPressed: () {
                    XaneoSettingsModal.open(
                      context,
                      currentUser: _myProfile,
                      onLogout: () {
                        // вызываем логаут через AccountService как раньше
                        _logout();
                      },
                      onUpdateFound: (update) {
                        if (mounted) {
                          setState(() {
                            _availableUpdate = update;
                          });
                        }
                      },
                      onSelectChat: (contact) {
                        final userId = contact['contact_user_id'];
                        final username = contact['contact_user_username'] ?? '';
                        final firstName = contact['contact_user_first_name'] ?? '';
                        final customName = contact['custom_name'];
                        final displayName = (customName != null && customName.toString().isNotEmpty)
                            ? customName.toString()
                            : (firstName.toString().isNotEmpty ? firstName.toString() : username.toString());

                        _startChatWithUser({
                          'id': userId,
                          'user_id': userId,
                          'username': username,
                          'first_name': displayName,
                          'display_name': displayName,
                          'avatar': contact['custom_avatar'] ?? contact['contact_user_avatar'],
                          'avatar_gradient': contact['contact_user_avatar_gradient'],
                        });
                      },
                      onStartCall: (contact) {
                        final userId = contact['contact_user_id'];
                        final username = contact['contact_user_username'] ?? '';
                        final firstName = contact['contact_user_first_name'] ?? '';
                        final customName = contact['custom_name'];
                        final displayName = (customName != null && customName.toString().isNotEmpty)
                            ? customName.toString()
                            : (firstName.toString().isNotEmpty ? firstName.toString() : username.toString());

                        _startChatWithUser({
                          'id': userId,
                          'user_id': userId,
                          'username': username,
                          'first_name': displayName,
                          'display_name': displayName,
                          'avatar': contact['custom_avatar'] ?? contact['contact_user_avatar'],
                          'avatar_gradient': contact['contact_user_avatar_gradient'],
                        });
                        _startCall('audio');
                      },
                    ).then((_) => _loadContactsCache());
                  },
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              SizedBox(width: 8),
              Text(
                _viewingArchive
                    ? (AppLocalizations.of(context)?.archive ?? (AppLocalizations.of(context)?.arhiv_56aa ?? 'Fallback'))
                    : (AppLocalizations.of(context)?.chats ?? (AppLocalizations.of(context)?.chaty_19ad ?? 'Fallback')),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18 * scale,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              if (!_viewingArchive)
                IconButton(
                  icon: Icon(Icons.search_rounded, size: 20 * scale),
                  tooltip: (AppLocalizations.of(context)?.globalnyyPoisk_7ff2 ?? 'Fallback'),
                  onPressed: () {
                    GlobalSearchModal.show(
                      context: context,
                      apiService: _apiService,
                      onResultSelected: (item, type) => _handleSearchResultSelected(item, type),
                    );
                  },
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
            ],
          ),
        ),
        
        // Chats List
        Expanded(
          child: _isChatsLoading
              ? Center(child: CircularProgressIndicator(strokeWidth: 2))
              : _viewingArchive
                  ? (_archivedChats.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)?.archiveEmpty ?? (AppLocalizations.of(context)?.arhivPust_3e22 ?? 'Fallback'),
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 13 * scale,
                              fontFamily: 'Inter',
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _archivedChats.length,
                          itemBuilder: (context, index) {
                            final chat = _archivedChats[index];
                            final isSelected = _selectedChat != null && _selectedChat!['chat_id'] == chat['chat_id'];
                            return _buildChatItem(chat, isSelected, isDark, scale);
                          },
                        ))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _archivedChats.isNotEmpty ? _chats.length + 1 : _chats.length,
                      itemBuilder: (context, index) {
                        if (_archivedChats.isNotEmpty) {
                          if (index == 0) {
                            return _buildArchiveFolderItem(context, isDark, scale);
                          }
                          final chat = _chats[index - 1];
                          final isSelected = _selectedChat != null && _selectedChat!['chat_id'] == chat['chat_id'];
                          return _buildChatItem(chat, isSelected, isDark, scale);
                        } else {
                          final chat = _chats[index];
                          final isSelected = _selectedChat != null && _selectedChat!['chat_id'] == chat['chat_id'];
                          return _buildChatItem(chat, isSelected, isDark, scale);
                        }
                      },
                    ),
        ),

        // Update Banner (if new version available)
        if (_availableUpdate != null)
          UpdateBannerWidget(
            updateInfo: _availableUpdate!,
            isDark: isDark,
            scale: scale,
            onDismiss: () {
              setState(() {
                _availableUpdate = null;
              });
            },
          ),

        // Bottom Account Info
        _buildBottomAccountInfo(isDark, scale),
      ],
    );
  }

  Widget _buildBottomAccountInfo(bool isDark, double scale) {
    String realName = 'Xaneo';
    if (_myProfile != null) {
      final firstName = _myProfile!['first_name'] as String?;
      final profileRealName = _myProfile!['realname'] as String?;
      final username = _myProfile!['username'] as String?;

      if (firstName != null && firstName.trim().isNotEmpty) {
        realName = firstName;
      } else if (profileRealName != null && profileRealName.trim().isNotEmpty) {
        realName = profileRealName;
      } else if (username != null && username.trim().isNotEmpty) {
        realName = username;
      }
    }

    final radius = BorderRadius.circular(16 * scale);
    bool isPressed = false;
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setCardState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setCardState(() => isHovered = true),
          onExit: (_) => setCardState(() => isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setCardState(() => isPressed = true),
            onTapUp: (_) => setCardState(() => isPressed = false),
            onTapCancel: () => setCardState(() => isPressed = false),
            onTap: () => _showAccountSwitcherDialog(context),
            child: AnimatedScale(
              scale: isPressed ? 0.97 : (isHovered ? 1.02 : 1.0),
              duration: Duration(milliseconds: 100),
              child: AnimatedOpacity(
                opacity: isPressed ? 0.85 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 4),
                  height: 52 * scale,
                  child: Stack(
                    children: [
                      // 1. Subtle shadow for 3D depth
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 2. Blurred glass layer
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: radius,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: radius,
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06),
                                  width: 1,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          Colors.white.withOpacity(0.08),
                                          Colors.white.withOpacity(0.02),
                                        ]
                                      : [
                                          Colors.white.withOpacity(0.4),
                                          Colors.white.withOpacity(0.15),
                                        ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 3. Specular shine highlight (RadialGradient shader layer)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: radius,
                              gradient: RadialGradient(
                                center: const Alignment(-0.6, -0.5),
                                radius: 0.8,
                                colors: [
                                  Colors.white.withOpacity(isDark ? 0.12 : 0.35),
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: const [0.0, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 4. Content layer
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 14 * scale,
                            right: 14 * scale,
                            top: 6 * scale,
                            bottom: 6 * scale,
                          ),
                          child: Row(
                            children: [
                              // Avatar (smaller, e.g.loc_30 * scale width/height)
                              _buildAvatar(
                                _myProfile != null ? (_myProfile!['avatar'] as String? ?? _myProfile!['avatar_url'] as String?) : null,
                                realName,
                                15 * scale,
                                1.0,
                                isDark,
                                avatarGradient: _myProfile != null ? _myProfile!['avatar_gradient'] as String? : null,
                              ),
                              const SizedBox(width: 10),
                              // User Real Name (smaller text)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      realName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13 * scale,
                                        color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _myUsername != null ? '@$_myUsername' : '',
                                      style: TextStyle(
                                        fontSize: 10 * scale,
                                        color: isDark ? Colors.white38 : Colors.black45,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Logout action icon
                              IconButton(
                                icon: Icon(Icons.logout_rounded, size: 16 * scale),
                                tooltip: (AppLocalizations.of(context)?.vyytiIzAkkaunta_6d41 ?? 'Fallback'),
                                onPressed: _logout,
                                color: isDark ? Colors.white54 : Colors.black54,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat, bool isSelected, bool isDark, double scale) {
    final chatType = chat['chat_type'] as String?;
    final displayName = _getChatName(chat);
    final dynamic rawUnread = chat['unread_count'];
    final unreadCount = rawUnread is int ? rawUnread : int.tryParse(rawUnread.toString()) ?? 0;
    final lastMsg = chat['last_message'];
    
    String lastMsgText = (AppLocalizations.of(context)?.netSoobscheniy_29d4 ?? 'Fallback');
    if (chatType == 'group') {
      lastMsgText = _getGroupStatusText(chat);
    } else if (chatType == 'channel') {
      lastMsgText = _getChannelStatusText(chat);
    }
    String lastMsgTime = "";
    if (lastMsg != null) {
      final dynamic rawMsgId = lastMsg['id'];
      final msgId = rawMsgId is int ? rawMsgId : int.tryParse(rawMsgId.toString());
      final msgType = lastMsg['message_type'] as String?;

      if (msgType == 'user_joined_group' || msgType == 'user_joined') {
        final authorName = lastMsg['author_first_name'] ?? lastMsg['author_username'] ?? (AppLocalizations.of(context)?.polzovatel_f154 ?? 'Fallback');
        lastMsgText = "$authorName присоединился к чату";
      } else if (msgType == 'user_left_group' || msgType == 'user_left') {
        final authorName = lastMsg['author_first_name'] ?? lastMsg['author_username'] ?? (AppLocalizations.of(context)?.polzovatel_f154 ?? 'Fallback');
        lastMsgText = "$authorName покинул чат";
      } else if (msgType == 'user_subscribed_channel') {
        final authorName = lastMsg['author_first_name'] ?? lastMsg['author_username'] ?? (AppLocalizations.of(context)?.polzovatel_f154 ?? 'Fallback');
        lastMsgText = "$authorName подписался на канал";
      } else if (msgType == 'user_unsubscribed_channel') {
        final authorName = lastMsg['author_first_name'] ?? lastMsg['author_username'] ?? (AppLocalizations.of(context)?.polzovatel_f154 ?? 'Fallback');
        lastMsgText = "$authorName отписался от канала";
      } else if (msgType == 'todo_list') {
        lastMsgText = (AppLocalizations.of(context)?.toDoList_27e1 ?? 'Fallback');
      } else if (msgType == 'poll') {
        lastMsgText = (AppLocalizations.of(context)?.opros_6ff1 ?? 'Fallback');
      } else if (msgType == 'call') {
        lastMsgText = (AppLocalizations.of(context)?.zvonok_e8d5 ?? 'Fallback');
      } else if (msgId != null) {
        lastMsgText = _decryptedMessages[msgId] ?? (AppLocalizations.of(context)?.zashifrovannoeSoobschenie_ca35 ?? 'Fallback');
        if (lastMsgText.isEmpty) {
          lastMsgText = (AppLocalizations.of(context)?.fayl_826d ?? 'Fallback');
        }
      } else if (lastMsg['files'] != null && (lastMsg['files'] as List).isNotEmpty) {
        final List files = lastMsg['files'] as List;
        final firstFile = files.first;
        final fileType = firstFile['file_type'] as String? ?? '';
        if (fileType == 'image') {
          lastMsgText = (AppLocalizations.of(context)?.fotografiya_5709 ?? 'Fallback');
        } else {
          lastMsgText = (AppLocalizations.of(context)?.fayl_826d ?? 'Fallback');
        }
      }

      if (lastMsgText.startsWith('{')) {
        try {
          final Map<String, dynamic> parsed = jsonDecode(lastMsgText);
          final hasFiles = (lastMsg['attached_file_id'] != null) ||
                           (lastMsg['file_id'] != null) ||
                           (lastMsg['files'] != null && (lastMsg['files'] as List).isNotEmpty) ||
                           (lastMsg['images'] != null && (lastMsg['images'] as List).isNotEmpty);
          
          if (hasFiles) {
            if (parsed['type'] == 'voice') {
              lastMsgText = (AppLocalizations.of(context)?.golosovoeSoobschenie_4a85 ?? 'Fallback');
            } else if (parsed['type'] == 'video_message') {
              lastMsgText = (AppLocalizations.of(context)?.videosoobschenie_d687 ?? 'Fallback');
            } else if (parsed['type'] == 'file') {
              lastMsgText = (AppLocalizations.of(context)?.fayl_826d ?? 'Fallback');
            }
          }
          if (parsed['type'] == 'todo_list' && (lastMsg['message_type'] == 'todo_list' || lastMsg['message_type'] == 'todo_list_message')) {
            lastMsgText = (AppLocalizations.of(context)?.toDoList_27e1 ?? 'Fallback');
          } else if (parsed['type'] == 'poll' && lastMsg['message_type'] == 'poll') {
            lastMsgText = (AppLocalizations.of(context)?.opros_6ff1 ?? 'Fallback');
          } else if (parsed['type'] == 'call') {
            lastMsgText = (AppLocalizations.of(context)?.zvonok_e8d5 ?? 'Fallback');
          }
        } catch (_) {}
      }

      lastMsgTime = _formatMessageTime(lastMsg['created_at'] as String?);
    }
    
    final otherUser = chat['other_user'] as Map<String, dynamic>?;
    final isOnline = otherUser != null && (otherUser['is_online'] as bool? ?? false);
    
    final typingText = _getTypingStatusText(chat: chat);
    String? typingAction;
    if (typingText != null && _activeTypingUsers.isNotEmpty) {
      typingAction = _activeTypingUsers.values.first.action;
    }

    Widget avatarWithStatus = Stack(
      children: [
        if (chatType == 'favorites')
          _buildFavoritesAvatar(22, scale)
        else ...[
          Builder(builder: (context) {
            final avatarUrl = otherUser?['avatar_url'] as String? ?? chat['avatar_url'] as String? ?? chat['avatar'] as String?;
            final gradientStr = otherUser?['avatar_gradient'] as String? ?? chat['avatar_gradient'] as String?;
            return _buildAvatar(
              avatarUrl,
              displayName,
              22 * scale,
              1.0,
              isDark,
              avatarGradient: gradientStr,
            );
          }),
        ],
        if (chatType == 'personal' && isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 10 * scale,
              height: 10 * scale,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.black : Colors.white,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );

    const activeBrandColor = Color(0xFF2563EB);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _selectChat(chat),
        onSecondaryTapDown: (details) {
          final isArchived = chat['is_archived'] as bool? ?? false;
          CustomContextMenu.show(
            context: context,
            position: details.globalPosition,
            items: [
              CustomContextMenuItem(
                icon: FaIcon(
                  isArchived ? FontAwesomeIcons.boxOpen : FontAwesomeIcons.boxArchive,
                  size: 16 * scale,
                ),
                label: isArchived
                    ? (AppLocalizations.of(context)?.unarchive ?? (AppLocalizations.of(context)?.razarhivirovat_416b ?? 'Fallback'))
                    : (AppLocalizations.of(context)?.toArchive ?? (AppLocalizations.of(context)?.vArhiv_ce22 ?? 'Fallback')),
                onTap: () => _toggleArchive(chat),
              ),
            ],
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? activeBrandColor.withOpacity(0.15) : activeBrandColor.withOpacity(0.08))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04))
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              avatarWithStatus,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14 * scale,
                              color: isSelected
                                  ? (isDark ? Colors.white : activeBrandColor)
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMsgTime.isNotEmpty)
                          Text(
                            lastMsgTime,
                            style: TextStyle(
                              fontSize: 11 * scale,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: typingText != null && typingAction != null
                              ? Row(
                                  children: [
                                    Lottie.asset(
                                      typingAction == 'recording_voice' 
                                          ? 'assets/animations/recording-voice.json'
                                          : 'assets/animations/loading.json',
                                      width: 16 * scale,
                                      height: 16 * scale,
                                      delegates: LottieDelegates(
                                        values: [
                                          ValueDelegate.colorFilter(
                                            const ['**'],
                                            value: const ColorFilter.mode(Color(0xFF2563EB), BlendMode.srcATop),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        typingText,
                                        style: TextStyle(
                                          fontSize: 13 * scale,
                                          color: const Color(0xFF2563EB),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  lastMsgText,
                                  style: TextStyle(
                                    fontSize: 13 * scale,
                                    color: isDark ? Colors.white38 : Colors.black45,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: activeBrandColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
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

  Widget _buildAvatar(
    String? avatarUrl,
    String displayName,
    double radius,
    double scale,
    bool isDark, {
    String? avatarGradient,
    BorderRadius? borderRadius,
  }) {
    final initials = displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : "?";
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(radius);
    
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return _buildInitialsAvatar(initials, radius, scale, isDark, avatarGradient: avatarGradient, borderRadius: borderRadius);
    }
    
    if (avatarUrl.startsWith('data:image/svg+xml')) {
      try {
        String svgString;
        if (avatarUrl.startsWith('data:image/svg+xml;base64,')) {
          final base64String = avatarUrl.substring('data:image/svg+xml;base64,'.length);
          svgString = utf8.decode(base64.decode(base64String));
        } else {
          final commaIndex = avatarUrl.indexOf(',');
          if (commaIndex != -1) {
            svgString = Uri.decodeComponent(avatarUrl.substring(commaIndex + 1));
          } else {
            svgString = '';
          }
        }
        
        if (svgString.isNotEmpty) {
          if (svgString.contains('<text') && svgString.contains('</text>')) {
            // It's an initials avatar generated by the backend!
            // SvgPicture has major issues centering text baselines.
            String? gradientToUse;
            final stopColors = <String>[];
            final matches = RegExp(r'stop-color:(#[A-Fa-f0-9]{6})|stop-color="(#[A-Fa-f0-9]{6})"').allMatches(svgString);
            for (var m in matches) {
              final c = m.group(1) ?? m.group(2);
              if (c != null && !stopColors.contains(c)) {
                stopColors.add(c);
              }
            }

            if (stopColors.length >= 2) {
              gradientToUse = '${stopColors[0]}|${stopColors[1]}';
            } else if (stopColors.length == 1) {
              gradientToUse = '${stopColors[0]}|${stopColors[0]}';
            } else {
              String? extractedColor;
              final rectMatch = RegExp(r'fill="(#[A-Fa-f0-9]{6})"').firstMatch(svgString);
              if (rectMatch != null) {
                extractedColor = rectMatch.group(1);
              }
              if (extractedColor != null) {
                gradientToUse = '$extractedColor|$extractedColor';
              } else {
                gradientToUse = avatarGradient;
              }
            }
            
            return _buildInitialsAvatar(initials, radius, scale, isDark, avatarGradient: gradientToUse, borderRadius: borderRadius);
          }

          // Real vector avatars (without text) can safely use SvgPicture
          return ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: SizedBox(
              width: radius * 2,
              height: radius * 2,
              child: SvgPicture.string(
                svgString,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      } catch (e) {
        print("Error parsing SVG avatar: $e");
        return _buildInitialsAvatar(initials, radius, scale, isDark, avatarGradient: avatarGradient, borderRadius: borderRadius);
      }
    }
    
    String fullUrl = avatarUrl;
    if (!avatarUrl.startsWith('http://') && !avatarUrl.startsWith('https://')) {
      final uri = Uri.parse(ApiService.baseUrl);
      final origin = "${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}";
      fullUrl = "$origin$avatarUrl";
    }
    
    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: Image.network(
        fullUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading avatar from network: $error");
          return _buildInitialsAvatar(initials, radius, scale, isDark, avatarGradient: avatarGradient, borderRadius: borderRadius);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: radius * 2,
            height: radius * 2,
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials, double radius, double scale, bool isDark, {String? avatarGradient, BorderRadius? borderRadius}) {
    final diameter = radius * 2;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(radius);
    
    Gradient? gradient;
    if (avatarGradient != null && avatarGradient.contains('|')) {
      try {
        final colors = avatarGradient.split('|');
        if (colors.length == 2) {
          final color1 = Color(int.parse(colors[0].trim().replaceFirst('#', ''), radix: 16) + 0xFF000000);
          final color2 = Color(int.parse(colors[1].trim().replaceFirst('#', ''), radix: 16) + 0xFF000000);
          gradient = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2],
          );
        }
      } catch (e) {
        print("Error parsing avatar gradient: $e");
      }
    }

    final color = isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.87);
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        color: gradient == null
            ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
            : null,
        gradient: gradient,
      ),
      child: CustomPaint(
        painter: _InitialsPainter(
          initial: initials,
          color: gradient != null ? Colors.white : color,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }

  Widget _buildFavoritesAvatar(double radius, double scale) {
    return Container(
      width: radius * 2 * scale,
      height: radius * 2 * scale,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.bookmark_rounded,
          color: Colors.white,
          size: radius * 1.1 * scale,
        ),
      ),
    );
  }

  String _getChatName(Map<String, dynamic> chat) {
    final chatType = chat['chat_type'] as String?;
    if (chatType == 'favorites') {
      return AppLocalizations.of(context)?.savedMessages ?? (AppLocalizations.of(context)?.izbrannoe_2fc4 ?? 'Fallback');
    }
    
    if (chatType == 'personal') {
      final otherUser = chat['other_user'] as Map<String, dynamic>?;
      final dynamic rawId = otherUser?['id'] ?? chat['user_id'];
      final int? userId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

      // 1. Проверяем наличие кастомного имени в карте контактов
      if (userId != null && _contactsMap.containsKey(userId)) {
        final contact = _contactsMap[userId]!;
        final customName = contact['custom_name']?.toString();
        if (customName != null && customName.trim().isNotEmpty) {
          return customName.trim();
        }
      }

      // 2. Проверяем кастомное имя в свойствах объекта
      final customName = otherUser?['custom_name']?.toString() ?? chat['custom_name']?.toString();
      if (customName != null && customName.trim().isNotEmpty) {
        return customName.trim();
      }

      // 3. Fallback: имя из аккаунта
      if (otherUser != null) {
        final firstName = otherUser['first_name'] as String?;
        final realName = otherUser['realname'] as String?;
        if (firstName != null && firstName.trim().isNotEmpty) return firstName;
        if (realName != null && realName.trim().isNotEmpty) return realName;
        return otherUser['username'] as String? ?? (AppLocalizations.of(context)?.polzovatel_f154 ?? 'Fallback');
      }
    }
    
    return chat['chat_display_name'] as String? ?? (AppLocalizations.of(context)?.chat_c52b ?? 'Fallback');
  }

  String _formatMessageTime(String? createdAtStr) {
    if (createdAtStr == null || createdAtStr.isEmpty) return "";
    try {
      final dateTime = DateTime.parse(createdAtStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays == 0 && dateTime.day == now.day) {
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        return "$hour:$minute";
      } else {
        final day = dateTime.day.toString().padLeft(2, '0');
        final month = dateTime.month.toString().padLeft(2, '0');
        return "$day.$month";
      }
    } catch (_) {
      return "";
    }
  }

  Widget _buildChatPanel(bool isDark, double scale) {
    if (_selectedChat == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 64 * scale, color: isDark ? Colors.white24 : Colors.black26),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.selectChatToStart ?? (AppLocalizations.of(context)?.vyberiteChatDlyaNachalaObscheniya_36a5 ?? 'Fallback'),
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final displayName = _getChatName(_selectedChat!);
    final chatType = _selectedChat!['chat_type'] as String?;
    final otherUser = _selectedChat!['other_user'] as Map<String, dynamic>?;
    final isOnline = otherUser != null && (otherUser['is_online'] as bool? ?? false);
    final isBot = otherUser != null && (otherUser['is_bot'] == true || otherUser['bot'] == true || (otherUser['username']?.toString().toLowerCase().endsWith('bot') ?? false));
    final l10n = AppLocalizations.of(context);

    String statusText = "";
    if (chatType == 'favorites') {
      statusText = l10n?.savedMessages ?? (AppLocalizations.of(context)?.izbrannoe_2fc4 ?? 'Fallback');
    } else if (chatType == 'personal') {
      statusText = isBot ? (AppLocalizations.of(context)?.bot_2712 ?? 'Fallback') : (isOnline ? (l10n?.online ?? (AppLocalizations.of(context)?.vSeti_d902 ?? 'Fallback')) : (l10n?.offline ?? (AppLocalizations.of(context)?.neVSeti_ee01 ?? 'Fallback')));
    } else if (chatType == 'group') {
      statusText = _getGroupStatusText(_selectedChat!);
    } else if (chatType == 'channel') {
      statusText = _getChannelStatusText(_selectedChat!);
    }

    String? typingAction;
    if (_activeTypingUsers.isNotEmpty) {
      typingAction = _activeTypingUsers.values.first.action;
    }

    return Column(
      children: [
        // Chat Header
        Container(
          height: 46 + 18 * scale,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Chat Title & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (chatType == 'personal' && otherUser != null) {
                            _showUserProfileDialog(context, otherUser, displayName);
                          } else if (chatType == 'group') {
                            _showGroupProfileDialog(context, _selectedChat!);
                          } else if (chatType == 'channel') {
                            _showChannelProfileDialog(context, _selectedChat!);
                          } else if (chatType == 'favorites') {
                            _showFavoritesProfileDialog(context, _selectedChat!);
                          }
                        },
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    if (typingAction != null)
                      Row(
                        children: [
                          Lottie.asset(
                            typingAction == 'recording_voice' 
                                ? 'assets/animations/recording-voice.json'
                                : 'assets/animations/loading.json',
                            width: 14 * scale,
                            height: 14 * scale,
                            delegates: LottieDelegates(
                              values: [
                                ValueDelegate.colorFilter(
                                  const ['**'],
                                  value: const ColorFilter.mode(Color(0xFF2563EB), BlendMode.srcATop),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTypingStatusText() ?? (AppLocalizations.of(context)?.pechataet_812c ?? 'Fallback'),
                            style: TextStyle(
                              fontSize: 11 * scale,
                              color: const Color(0xFF2563EB),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11 * scale,
                          color: chatType == 'personal' && isOnline && !isBot
                              ? Colors.green
                              : (isDark ? Colors.white38 : Colors.black38),
                          fontFamily: 'Inter',
                        ),
                      ),
                  ],
                ),
              ),

              // Action buttons: Call, Settings
              if (_canMakeCallInCurrentChat())
                IconButton(
                  icon: Icon(Icons.phone_rounded, size: 20 * scale),
                  tooltip: l10n?.call ?? 'Позвонить',
                  onPressed: () {
                    _showCallChoiceModal(context, scale, isDark);
                  },
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              IconButton(
                key: _headerSettingsKey,
                icon: Icon(Icons.settings_rounded, size: 20 * scale),
                tooltip: l10n?.chatSettings ?? 'Настройки чата',
                onPressed: () {
                  final renderBox = _headerSettingsKey.currentContext?.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    final position = renderBox.localToGlobal(Offset.zero);
                    final size = renderBox.size;
                    final menuLeft = position.dx - (160.0 * scale);
                    final menuTop = position.dy + size.height + 4;

                    final isSubscribed = _isUserSubscribedOrJoined(_selectedChat);
                    final isChannel = chatType == 'channel';
                    final isGroup = chatType == 'group';

                    final items = <CustomContextMenuItem>[];

                    if (isGroup) {
                      if (isSubscribed) {
                        items.add(
                          CustomContextMenuItem(
                            icon: FaIcon(FontAwesomeIcons.rightFromBracket, size: 14 * scale, color: Colors.redAccent),
                            label: l10n?.leaveGroup ?? 'Покинуть группу',
                            onTap: () => _handleLeaveChat(_selectedChat!),
                          ),
                        );
                      } else {
                        items.add(
                          CustomContextMenuItem(
                            icon: FaIcon(FontAwesomeIcons.userPlus, size: 14 * scale, color: const Color(0xFF2563EB)),
                            label: l10n?.joinGroup ?? 'Присоединиться к группе',
                            onTap: () => _handleJoinChat(_selectedChat!),
                          ),
                        );
                      }
                    } else if (isChannel) {
                      if (isSubscribed) {
                        items.add(
                          CustomContextMenuItem(
                            icon: FaIcon(FontAwesomeIcons.bellSlash, size: 14 * scale, color: Colors.redAccent),
                            label: l10n?.unsubscribeChannel ?? 'Отписаться от канала',
                            onTap: () => _handleLeaveChat(_selectedChat!),
                          ),
                        );
                      } else {
                        items.add(
                          CustomContextMenuItem(
                            icon: FaIcon(FontAwesomeIcons.bullhorn, size: 14 * scale, color: const Color(0xFF2563EB)),
                            label: l10n?.subscribeChannel ?? 'Подписаться на канал',
                            onTap: () => _handleJoinChat(_selectedChat!),
                          ),
                        );
                      }
                    }

                    items.add(
                      CustomContextMenuItem(
                        icon: FaIcon(FontAwesomeIcons.boxArchive, size: 14 * scale),
                        label: (_selectedChat!['is_archived'] == true)
                            ? (l10n?.unarchive ?? 'Разать')
                            : (l10n?.toArchive ?? 'В архив'),
                        onTap: () => _toggleArchive(_selectedChat!),
                      ),
                    );

                    CustomContextMenu.show(
                      context: context,
                      position: Offset(menuLeft, menuTop),
                      items: items,
                    );
                  }
                },
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),

        // Message List
        Expanded(
          child: Stack(
            children: [
              _isMessagesLoading
                  ? Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? _buildEmptyMessagesPlaceholder(isDark, scale)
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
                          findChildIndexCallback: (Key key) {
                            if (key is ValueKey<String> && key.value.startsWith('anim_')) {
                              final idStr = key.value.substring(5); // remove 'anim_'
                              final index = _messages.indexWhere((m) => m['id']?.toString() == idStr);
                              return index >= 0 ? index : null;
                            }
                            return null;
                          },
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }

                            final msg = _messages[index];
                            final isMe = msg['author_id']?.toString() == _myId?.toString();
                            final rawId = msg['id'];
                            final msgId = rawId is int ? rawId : int.tryParse(rawId.toString());
                            final isNewMessage = msgId != null && _messagesToAnimate.contains(msgId);

                            bool showDateDivider = false;
                            String? dateDividerText;
                            final currentDate = _parseMsgDate(msg['created_at']);
                            if (currentDate != null) {
                              if (index == _messages.length - 1) {
                                showDateDivider = true;
                              } else {
                                final olderDate = _parseMsgDate(_messages[index + 1]['created_at']);
                                if (olderDate != null && !_isSameDay(currentDate, olderDate)) {
                                  showDateDivider = true;
                                }
                              }
                              if (showDateDivider) {
                                dateDividerText = _formatDateDivider(currentDate);
                              }
                            }

                            final bubbleWidget = NewMessageAnimator(
                              key: ValueKey('anim_${msgId ?? index}'),
                              animate: isNewMessage,
                              onStartAnimating: isNewMessage
                                  ? () {
                                      if (msgId != null) {
                                        _messagesToAnimate.remove(msgId);
                                      }
                                    }
                                  : null,
                              child: _buildMessageBubble(msg, isMe, isDark, scale),
                            );

                            if (showDateDivider && dateDividerText != null) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildDateDivider(dateDividerText, isDark, scale),
                                  bubbleWidget,
                                ],
                              );
                            }

                            return bubbleWidget;
                          },
                        ),
              
              if (_isRecording && !_isVoiceMode)
                _VideoRecordingPreview(scale: scale, cameraController: _cameraController),

              // Floating voice-playback bar (только в пределах контента чата)
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: _buildVoicePlaybackBar(isDark, scale),
              ),
            ],
          ),
        ),

        // Bottom Panel (Message Input or Join / Subscribe / Unsubscribe Button)
        _buildBottomPanel(isDark, scale),
      ],
    );
  }

  Widget _buildEmptyMessagesPlaceholder(bool isDark, double scale) {
    final l10n = AppLocalizations.of(context);
    final title = l10n?.noMessagesTitle ?? 'Нет сообщений';
    final subtitle = l10n?.noMessagesSubtitle ?? 'Напишите первыми, чтобы начать общение в Xaneo Connect!';

    final cardBg = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
    final borderColor = isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5);
    final iconBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F5);
    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black54;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24 * scale),
        child: Container(
          constraints: BoxConstraints(maxWidth: 360 * scale),
          padding: EdgeInsets.symmetric(horizontal: 28 * scale, vertical: 36 * scale),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.04),
                blurRadius: 16 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clean Minimal Icon Container
              Container(
                width: 64 * scale,
                height: 64 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBg,
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 28 * scale,
                  color: primaryTextColor,
                ),
              ),
              SizedBox(height: 18 * scale),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 17 * scale,
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                  fontFamily: 'Inter',
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * scale),

              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13 * scale,
                  height: 1.4,
                  color: secondaryTextColor,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20 * scale),

              // Clean Neutral Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(20 * scale),
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 15 * scale,
                      color: primaryTextColor,
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      '👋 Xaneo Connect',
                      style: TextStyle(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                        fontFamily: 'Inter',
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

  Widget _buildVoicePlaybackBar(bool isDark, double scale) {
    return Consumer<PlaybackProvider>(
      builder: (context, playback, child) {
        final isVisible = playback.currentAudioUrl != null;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (widget, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.6),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: widget,
              ),
            );
          },
          child: !isVisible
              ? const SizedBox.shrink(key: ValueKey('voice_bar_hidden'))
              : Align(
                  key: const ValueKey('voice_bar_visible'),
                  alignment: Alignment.topCenter,
                  child: _TopAudioPlaybackBar(
                    playback: playback,
                    isDark: isDark,
                    scale: scale,
                    onTapTitle: () => _showMusicPlaylistModal(context, isDark, scale),
                  ),
                ),
        );
      },
    );
  }

  Map<String, dynamic>? _getCustomPayload(Map<String, dynamic> msg) {
    final dynamic rawId = msg['id'];
    final id = rawId is int ? rawId : (int.tryParse(rawId.toString()) ?? 0);
    final decryptedText = _decryptedMessages[id] ?? msg['encrypted_text'] ?? "";
    if (decryptedText.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(decryptedText);
        if (parsed is Map<String, dynamic>) {
          return parsed;
        }
      } catch (_) {}
    }
    return null;
  }

  List<PlaybackItem> _getMusicPlaylistFromChat() {
    final playlist = <PlaybackItem>[];
    if (_selectedChat == null) return playlist;
    
    for (final msg in _messages) {
      final customPayload = _getCustomPayload(msg);
      final attachedFileId = msg['attached_file_id']?.toString() ?? msg['file_id']?.toString();
      
      final payload = customPayload ?? (attachedFileId != null ? {
        'type': msg['attached_file_type'] == 'audio' || msg['file_type'] == 'audio' ? 'audio' : 'file',
        'file_id': attachedFileId,
        'file_name': msg['attached_file_name'] ?? msg['file_name'] ?? (AppLocalizations.of(context)?.audiozapis_867d ?? 'Fallback'),
        'file_size': msg['attached_file_size'] ?? msg['file_size'] ?? 0,
        'mime_type': msg['attached_file_type'] ?? 'audio/mp3',
      } : null);

      if (payload == null) continue;

      final type = payload['type']?.toString().toLowerCase() ?? '';
      if (type == 'voice' || type == 'video_message') continue;

      if (type == 'audio' || _isAudioFile(payload)) {
        final fileName = payload['file_name']?.toString() ?? payload['name']?.toString() ?? (AppLocalizations.of(context)?.muzykalnyyTrek_b15d ?? 'Fallback');
        final fileSize = payload['file_size'] as int? ?? 0;
        final mimeType = payload['mime_type']?.toString() ?? 'audio/mp3';
        
        final fileId = payload['file_id']?.toString() ?? '';
        final uri = Uri.parse(ApiService.baseUrl);
        final port = uri.hasPort ? ':${uri.port}' : '';
        final host = '${uri.scheme}://${uri.host}$port';
        String? fileUrl = payload['file_url']?.toString();
        if (fileUrl != null && fileUrl.trim().isEmpty) fileUrl = null;
        final suffix = fileUrl ?? '/api/files/download/$fileId/';
        String audioUrl = suffix.startsWith('http') ? suffix : '$host${suffix.startsWith('/') ? '' : '/'}$suffix';
        final lowerName = fileName.toLowerCase();
        if (lowerName.endsWith('.mp3')) audioUrl += audioUrl.contains('?') ? '&ext=.mp3' : '?ext=.mp3';
        else if (lowerName.endsWith('.flac')) audioUrl += audioUrl.contains('?') ? '&ext=.flac' : '?ext=.flac';
        else if (lowerName.endsWith('.wav')) audioUrl += audioUrl.contains('?') ? '&ext=.wav' : '?ext=.wav';
        else if (lowerName.endsWith('.m4a') || lowerName.endsWith('.aac')) audioUrl += audioUrl.contains('?') ? '&ext=.m4a' : '?ext=.m4a';

        playlist.add(PlaybackItem(
          url: audioUrl,
          title: fileName,
          subtitle: _formatBytes(fileSize),
          mimeType: mimeType,
          payload: payload,
        ));
      }
    }
    return playlist;
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return (AppLocalizations.of(context)?.loc_0B_5a4d ?? 'Fallback');
    var suffixes = [(AppLocalizations.of(context)?.b_3b67 ?? 'Fallback'), (AppLocalizations.of(context)?.kb_419d ?? 'Fallback'), (AppLocalizations.of(context)?.mb_b808 ?? 'Fallback'), (AppLocalizations.of(context)?.gb_e572 ?? 'Fallback')];
    var i = (log(bytes) / log(1024)).floor();
    if (i >= suffixes.length) i = suffixes.length - 1;
    return ((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
  }

  void _showMusicPlaylistModal(BuildContext context, bool isDark, double scale) {
    final playlist = _getMusicPlaylistFromChat();
    final playbackProvider = context.read<PlaybackProvider>();
    if (playlist.isNotEmpty && playbackProvider.playlist.isEmpty) {
      playbackProvider.setPlaylist(playlist, initialUrl: playbackProvider.currentAudioUrl);
    }
    MusicPlaylistModal.show(context, _messages);
  }

  Widget _buildSystemMessageBubble(Map<String, dynamic> msg, String text, bool isDark, double scale) {
    final messageType = msg['message_type'] as String? ?? 'system';
    final author = msg['author'] as Map<String, dynamic>? ?? {};
    final authorName = msg['author_first_name'] ??
        author['first_name'] ??
        author['username'] ??
        msg['author_username'] ??
        '';
    final messageData = msg['message_data'] as Map<String, dynamic>? ?? {};

    final l10n = AppLocalizations.of(context);
    final userLabel = (AppLocalizations.of(context)?.polzovatel_f154 ?? 'Fallback');
    String displayText = '';

    if (messageType == 'user_joined_group' || messageType == 'user_joined') {
      final name = authorName.isNotEmpty ? authorName : userLabel;
      displayText = '$name ${l10n?.joinedChat ?? (AppLocalizations.of(context)?.prisoedinilsyaKChatu_f623 ?? 'Fallback')}';
    } else if (messageType == 'user_left_group' || messageType == 'user_left') {
      final name = authorName.isNotEmpty ? authorName : userLabel;
      displayText = '$name ${l10n?.leftChat ?? (AppLocalizations.of(context)?.pokinulChat_d567 ?? 'Fallback')}';
    } else if (messageType == 'user_subscribed_channel') {
      final name = authorName.isNotEmpty ? authorName : userLabel;
      displayText = '$name ${l10n?.subscribedChannel ?? (AppLocalizations.of(context)?.podpisalsyaNaKanal_0673 ?? 'Fallback')}';
    } else if (messageType == 'user_unsubscribed_channel') {
      final name = authorName.isNotEmpty ? authorName : userLabel;
      displayText = '$name ${l10n?.unsubscribedChannel ?? (AppLocalizations.of(context)?.otpisalsyaOtKanala_fa13 ?? 'Fallback')}';
    } else if (messageType == 'user_invited_group' || messageType == 'user_invited_channel') {
      final inviter = authorName.isNotEmpty ? authorName : userLabel;
      final invited = messageData['invited_name'] ?? messageData['subject_user_name'] ?? (AppLocalizations.of(context)?.polzovatelya_1083 ?? 'Fallback');
      displayText = '$inviter ${l10n?.invited ?? (AppLocalizations.of(context)?.priglasil_47ae ?? 'Fallback')} $invited';
    } else {
      if (text.isNotEmpty && !text.startsWith('{') && text != (AppLocalizations.of(context)?.rasshifrovka_e47f ?? 'Fallback')) {
        displayText = text;
      } else {
        displayText = l10n?.systemMessage ?? (AppLocalizations.of(context)?.sistemnoeSoobschenie_d2bd ?? 'Fallback');
      }
    }

    final timeStr = msg['created_at'] != null
        ? DateTime.parse(msg['created_at'] as String).toLocal().toString().substring(11, 16)
        : "";

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 6 * scale),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xCC232326) : const Color(0xE6F0F0F2),
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 13 * scale,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            SizedBox(width: 6 * scale),
            Text(
              displayText,
              style: TextStyle(
                fontSize: 12.5 * scale,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToReplyMessage(String replyId) {
    final targetInt = int.tryParse(replyId);
    final idx = _messages.indexWhere((m) {
      final rawId = m['id'];
      if (rawId == null) return false;
      return rawId.toString() == replyId || (targetInt != null && rawId == targetInt);
    });

    if (idx != -1 && _scrollController.hasClients) {
      final targetMsgId = _messages[idx]['id'];
      final id = targetMsgId is int ? targetMsgId : (int.tryParse(targetMsgId.toString()) ?? 0);
      setState(() {
        _messagesToAnimate.add(id);
      });
      _scrollController.animateTo(
        idx * 65.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _buildReplyQuote(Map<String, dynamic> msg, bool isMe, bool isDark, double scale) {
    final replyAuthor = (msg['reply_author_name'] ?? msg['reply_author'] ?? (AppLocalizations.of(context)?.soobschenie_3715 ?? 'Fallback')).toString();
    final replyIdStr = msg['reply_to_id']?.toString() ?? msg['reply_to_ref']?.toString() ?? msg['reply_to']?.toString();
    final replyInt = int.tryParse(replyIdStr ?? '');

    String replyText = (msg['reply_text'] ?? '').toString();
    if (replyInt != null && _decryptedMessages.containsKey(replyInt) && _decryptedMessages[replyInt]!.isNotEmpty) {
      replyText = _decryptedMessages[replyInt]!;
    }

    if (replyText.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(replyText);
        if (parsed is Map) {
          if (parsed['type'] == 'voice') replyText = (AppLocalizations.of(context)?.golosovoeSoobschenie_4a85 ?? 'Fallback');
          else if (parsed['type'] == 'video_message') replyText = (AppLocalizations.of(context)?.videosoobschenie_57f1 ?? 'Fallback');
          else if (parsed['type'] == 'file') replyText = '📁 Файл: ${parsed['file_name'] ?? ''}';
          else if (parsed['type'] == 'todo_list') replyText = (AppLocalizations.of(context)?.spisokZadach_cfa4 ?? 'Fallback');
          else if (parsed['type'] == 'poll') replyText = (AppLocalizations.of(context)?.opros_5902 ?? 'Fallback');
        }
      } catch (_) {}
    }
    if (replyText.isEmpty) replyText = (AppLocalizations.of(context)?.vlozhenie_ef44 ?? 'Fallback');

    final replyId = msg['reply_to_id']?.toString() ?? msg['reply_to']?.toString();

    return GestureDetector(
      onTap: () {
        if (replyId != null && replyId.isNotEmpty) {
          _scrollToReplyMessage(replyId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.15) : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isMe ? Colors.white70 : const Color(0xFF2563EB),
              width: 3 * scale,
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
                fontSize: 11.5 * scale,
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : const Color(0xFF2563EB),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              replyText,
              style: TextStyle(
                fontSize: 11.5 * scale,
                color: isMe ? Colors.white70 : (isDark ? Colors.white60 : Colors.black54),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe, bool isDark, double scale) {
    final messageType = msg['message_type'] as String?;
    final isSystemMsg = msg['is_system'] == true ||
        messageType == 'system' ||
        messageType == 'user_joined' ||
        messageType == 'user_joined_group' ||
        messageType == 'user_left' ||
        messageType == 'user_left_group' ||
        messageType == 'user_invited_group' ||
        messageType == 'user_invited_channel' ||
        messageType == 'user_subscribed_channel' ||
        messageType == 'user_unsubscribed_channel';

    final dynamic rawId = msg['id'];
    final id = rawId is int ? rawId : (int.tryParse(rawId.toString()) ?? 0);
    final decryptedText = _decryptedMessages[id] ?? msg['encrypted_text'] ?? "";

    if (isSystemMsg) {
      return _buildSystemMessageBubble(msg, decryptedText, isDark, scale);
    }
    Map<String, dynamic>? customPayload;
    if (decryptedText.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(decryptedText);
        if (parsed is Map<String, dynamic>) {
          customPayload = parsed;
        }
      } catch (_) {}
    }
    final hasFiles = (msg['attached_file_id'] != null) ||
                     (msg['file_id'] != null) ||
                     (msg['files'] != null && (msg['files'] as List).isNotEmpty) ||
                     (msg['images'] != null && (msg['images'] as List).isNotEmpty);

    if (customPayload != null) {
      final type = customPayload['type'];
      if ((type == 'voice' || type == 'video_message' || type == 'file') && !hasFiles) {
        customPayload = null;
      } else if ((type == 'todo_list' || type == 'todo_list_message') &&
                 msg['message_type'] != 'todo_list' &&
                 msg['message_type'] != 'todo_list_message') {
        customPayload = null;
      } else if (type == 'poll' && msg['message_type'] != 'poll') {
        customPayload = null;
      }
    }
    final attachedFileId = msg['attached_file_id']?.toString() ?? msg['file_id']?.toString();
    if (customPayload == null && attachedFileId != null) {
      if (msg['attached_file_name'] != null) {
        customPayload = {
          'type': 'file',
          'file_id': attachedFileId,
          'file_name': msg['attached_file_name'],
          'file_size': msg['attached_file_size'] ?? 0,
          'mime_type': msg['attached_file_type'] ?? 'application/octet-stream',
        };
      } else if (_fileMetadataCache.containsKey(attachedFileId)) {
        final cache = _fileMetadataCache[attachedFileId]!;
        customPayload = {
          'type': 'file',
          'file_id': attachedFileId,
          'file_name': cache['original_filename'] ?? cache['file_name'] ?? (AppLocalizations.of(context)?.fayl_2d46 ?? 'Fallback'),
          'file_size': cache['file_size'] ?? 0,
          'mime_type': cache['mime_type'] ?? cache['file_type'] ?? 'application/octet-stream',
        };
      } else {
        customPayload = {
          'type': 'file_loading',
          'file_id': attachedFileId,
        };
        _triggerFileMetadataFetch(attachedFileId);
      }
    }
    final authorKey = msg['author_username']?.toString() ?? msg['author_id']?.toString() ?? '';
    final authorProfile = _msgAuthorProfiles[authorKey];
    final authorFirstName = authorProfile?['first_name']?.toString()
        ?? msg['author_first_name']?.toString()
        ?? msg['author_username']?.toString()
        ?? (AppLocalizations.of(context)?.polzovatel_f154 ?? 'Fallback');
    final authorAvatar = authorProfile?['avatar']?.toString() ?? msg['author_avatar']?.toString();
    final authorGradient = authorProfile?['avatar_gradient']?.toString() ?? msg['author_avatar_gradient']?.toString();
    final isGroup = _selectedChat!['chat_type'] == 'group' || _selectedChat!['chat_type'] == 'channel';

    if (customPayload != null && customPayload['type'] == 'video_message') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && isGroup)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  authorFirstName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            _VideoMessageMockBubble(
              key: ValueKey(customPayload['file_id'] ?? id),
              payload: customPayload,
              isMe: isMe,
              isDark: isDark,
              scale: scale,
            ),
          ],
        ),
      );
    }
    final timeStr = msg['created_at'] != null 
        ? DateTime.parse(msg['created_at'] as String).toLocal().toString().substring(11, 16)
        : "";

    bool isReplyFieldValid(dynamic val) {
      if (val == null) return false;
      final str = val.toString().trim();
      return str.isNotEmpty && str != 'null' && str != 'None' && str != '0';
    }

    final hasReply = isReplyFieldValid(msg['reply_to_id']) || isReplyFieldValid(msg['reply_to_ref']) || isReplyFieldValid(msg['reply_to']) || isReplyFieldValid(msg['reply_text']);

    final bubbleContent = GestureDetector(
        onTap: () {
          setState(() {
            _replyingToMessage = msg;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          decoration: BoxDecoration(
            gradient: isMe
                ? LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: isDark
                        ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.12)]
                        : [Colors.black.withOpacity(0.03), Colors.black.withOpacity(0.06)],
                  ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 2),
              bottomRight: Radius.circular(isMe ? 2 : 16),
            ),
            border: Border.all(
              color: isMe 
                  ? Colors.transparent 
                  : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender name (for group chats if not me)
              if (!isMe && isGroup)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    authorFirstName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),

              if (hasReply)
                _buildReplyQuote(msg, isMe, isDark, scale),

            // Decrypted Plaintext
            if (customPayload != null && customPayload['type'] == 'voice')
              _VoiceMessageBubblePlayer(
                payload: customPayload,
                isMe: isMe,
                isDark: isDark,
                scale: scale,
                senderName: isMe
                    ? (AppLocalizations.of(context)?.vy_0101 ?? 'Fallback')
                    : (_selectedChat?['chat_type'] == 'personal'
                        ? _getChatName(_selectedChat!)
                        : authorFirstName),
              )
            else if (customPayload != null && customPayload['type'] == 'video_message')
              _VideoMessageMockBubble(
                key: ValueKey(customPayload['file_id'] ?? id),
                payload: customPayload,
                isMe: isMe,
                isDark: isDark,
                scale: scale,
              )
            else if (customPayload != null && (customPayload['type'] == 'audio' || _isAudioFile(customPayload))) ...[
              _MusicMessageBubblePlayer(
                payload: customPayload,
                isMe: isMe,
                isDark: isDark,
                scale: scale,
                onDownload: () {
                  final fileId = customPayload!['file_id']?.toString() ?? '';
                  final fileName = customPayload!['file_name']?.toString() ?? 'audio.mp3';
                  _downloadFile(fileId, fileName);
                },
              ),
              if (decryptedText.trim().isNotEmpty && !decryptedText.trim().startsWith('{')) ...[
                SizedBox(height: 8),
                Text(
                  decryptedText,
                  style: TextStyle(
                    color: isMe ? Colors.white : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87),
                    fontSize: 15 * scale,
                  ),
                ),
              ],
            ]
            else if (customPayload != null && customPayload['type'] == 'file') ...[
              _buildFileAttachmentWidget(customPayload, isMe, isDark, scale),
              if (decryptedText.trim().isNotEmpty && !decryptedText.trim().startsWith('{')) ...[
                const SizedBox(height: 8),
                Text(
                  decryptedText,
                  style: TextStyle(
                    color: isMe ? Colors.white : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87),
                    fontSize: 15 * scale,
                  ),
                ),
              ],
            ]
            else if (customPayload != null && customPayload['type'] == 'file_loading') ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14 * scale,
                      height: 14 * scale,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isMe ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      (AppLocalizations.of(context)?.zagruzkaFayla_f817 ?? 'Fallback'),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54),
                        fontSize: 12.5 * scale,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              if (decryptedText.trim().isNotEmpty && !decryptedText.trim().startsWith('{')) ...[
                const SizedBox(height: 8),
                Text(
                  decryptedText,
                  style: TextStyle(
                    color: isMe ? Colors.white : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87),
                    fontSize: 15 * scale,
                  ),
                ),
              ],
            ]
            else if (customPayload != null && 
                     (msg['message_type'] == 'todo_list' || msg['message_type'] == 'todo_list_message' || customPayload['is_native'] == true) &&
                     (customPayload['type'] == 'todo_list' || (customPayload['items'] != null && customPayload['title'] != null)))
              _buildTodoWidget(msg, customPayload, isMe, isDark, scale)
            else if (customPayload != null && 
                     (msg['message_type'] == 'poll' || msg['message_type'] == 'poll_message' || customPayload['is_native'] == true) &&
                     (customPayload['type'] == 'poll' || (customPayload['options'] != null && customPayload['question'] != null)))
              _buildPollWidget(msg, customPayload, isMe, isDark, scale)
            else if (customPayload != null && customPayload['type'] == 'call')
              _buildCallWidget(customPayload, isMe, isDark, scale)
            else
              Text(
                decryptedText,
                style: TextStyle(
                  color: isMe ? Colors.white : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87),
                  fontSize: 15 * scale,
                ),
              ),
            
            const SizedBox(height: 4),
            const SizedBox(height: 4),
            // Timestamp and Status / Lock icon
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    color: isMe ? Colors.white60 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
                if (isMe && customPayload?['type'] != 'call') ...[
                  const SizedBox(width: 4),
                  Builder(
                    builder: (context) {
                      final isPending = msg['is_pending'] == true || msg['id'].toString().startsWith('temp_');
                      final isRead = msg['is_read'] == true || msg['is_read_by_recipient'] == true;
                      return FaIcon(
                        isPending
                            ? FontAwesomeIcons.clock
                            : (isRead ? FontAwesomeIcons.checkDouble : FontAwesomeIcons.check),
                        size: 10 * scale,
                        color: isPending
                            ? (isDark ? Colors.white38 : Colors.black38)
                            : (isRead
                                ? const Color(0xFF4ADE80)
                                : (isDark ? Colors.white60 : Colors.black54)),
                      );
                    },
                  ),
                ] else if (customPayload?['type'] != 'call') ...[
                  const SizedBox(width: 4),
                  FaIcon(
                    FontAwesomeIcons.lock, 
                    size: 9 * scale, 
                    color: isMe ? Colors.white60 : Colors.grey
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (!isMe && isGroup) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 2, right: 8, top: 2, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGroupAvatar(authorAvatar, authorGradient, authorFirstName, 40),
              const SizedBox(width: 6),
              bubbleContent,
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: bubbleContent,
      ),
    );
  }

  Widget _buildCallWidget(Map<String, dynamic> fileData, bool isMe, bool isDark, double scale) {
    final status = fileData['status']?.toString();
    final duration = fileData['duration'] as int? ?? 0;
    final callType = fileData['call_type']?.toString() ?? 'audio';

    final isVideo = callType == 'video';
    FaIconData callIcon = isVideo ? FontAwesomeIcons.video : FontAwesomeIcons.phone;
    Color iconColor = Colors.grey;
    Color iconBg = Colors.grey.withOpacity(0.15);
    String callTitle = '';
    String callSubtext = '';

    if (isMe) {
      // Outgoing
      callTitle = (AppLocalizations.of(context)?.ishodyaschiyZvonok_8381 ?? 'Fallback');
      if (status == 'connected') {
        iconColor = const Color(0xFF10B981);
        iconBg = const Color(0xFF10B981).withOpacity(0.15);
        final mins = duration ~/ 60;
        final secs = duration % 60;
        if (mins > 0) {
          callSubtext = '$mins мин $secs сек';
        } else {
          callSubtext = '$secs сек';
        }
      } else {
        iconColor = const Color(0xFF9CA3AF);
        iconBg = const Color(0xFF9CA3AF).withOpacity(0.15);
        callSubtext = (AppLocalizations.of(context)?.razgovorNeSostoyalsya_67fb ?? 'Fallback');
      }
    } else {
      // Incoming
      if (status == 'connected') {
        callTitle = (AppLocalizations.of(context)?.vhodyaschiyZvonok_5ce9 ?? 'Fallback');
        iconColor = const Color(0xFF10B981);
        iconBg = const Color(0xFF10B981).withOpacity(0.15);
        final mins = duration ~/ 60;
        final secs = duration % 60;
        if (mins > 0) {
          callSubtext = '$mins мин $secs сек';
        } else {
          callSubtext = '$secs сек';
        }
      } else if (status == 'rejected') {
        callTitle = (AppLocalizations.of(context)?.otklonennyyZvonok_d499 ?? 'Fallback');
        iconColor = const Color(0xFFEF4444);
        iconBg = const Color(0xFFEF4444).withOpacity(0.15);
        callIcon = isVideo ? FontAwesomeIcons.videoSlash : FontAwesomeIcons.phoneSlash;
        callSubtext = (AppLocalizations.of(context)?.vyOtkloniliVyzov_8d1d ?? 'Fallback');
      } else {
        callTitle = (AppLocalizations.of(context)?.propuschennyyZvonok_e98d ?? 'Fallback');
        iconColor = const Color(0xFFEF4444);
        iconBg = const Color(0xFFEF4444).withOpacity(0.15);
        callIcon = isVideo ? FontAwesomeIcons.videoSlash : FontAwesomeIcons.phoneSlash;
        callSubtext = (AppLocalizations.of(context)?.vyPropustiliVyzov_f17a ?? 'Fallback');
      }
    }

    final textColor = isMe ? Colors.white : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87);
    final subtextColor = isMe ? Colors.white70 : (isDark ? Colors.white60 : Colors.black54);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                callIcon,
                color: iconColor,
                size: 14 * scale,
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                callTitle,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * scale,
                ),
              ),
              SizedBox(height: 3 * scale),
              Text(
                callSubtext,
                style: TextStyle(
                  color: subtextColor,
                  fontSize: 11 * scale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(bool isDark, double scale) {
    if (_selectedChat == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final chatType = _selectedChat!['chat_type'] as String?;
    final isSubscribedOrJoined = _isUserSubscribedOrJoined(_selectedChat);

    if (chatType == 'group') {
      if (!isSubscribedOrJoined) {
        return _buildJoinSubscribeBar(
          isDark: isDark,
          scale: scale,
          label: l10n?.joinGroup ?? 'Присоединиться к группе',
          icon: Icons.group_add_rounded,
          color: const Color(0xFF2563EB),
          onPressed: () => _handleJoinChat(_selectedChat!),
        );
      } else {
        return _buildMessageInput(isDark, scale);
      }
    } else if (chatType == 'channel') {
      if (!isSubscribedOrJoined) {
        return _buildJoinSubscribeBar(
          isDark: isDark,
          scale: scale,
          label: l10n?.subscribeChannel ?? 'Подписаться на канал',
          icon: Icons.campaign_rounded,
          color: const Color(0xFF2563EB),
          onPressed: () => _handleJoinChat(_selectedChat!),
        );
      } else {
        final canPost = _selectedChat!['can_post'] == true || _selectedChat!['is_admin'] == true;
        if (canPost) {
          return _buildMessageInput(isDark, scale);
        } else {
          return _buildJoinSubscribeBar(
            isDark: isDark,
            scale: scale,
            label: l10n?.unsubscribeChannel ?? 'Отписаться от канала',
            icon: Icons.notifications_off_rounded,
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF),
            textColor: isDark ? Colors.redAccent : const Color(0xFFDC2626),
            isDanger: true,
            onPressed: () => _handleLeaveChat(_selectedChat!),
          );
        }
      }
    }

    return _buildMessageInput(isDark, scale);
  }

  Widget _buildJoinSubscribeBar({
    required bool isDark,
    required double scale,
    required String label,
    required IconData icon,
    required Color color,
    Color? textColor,
    bool isDanger = false,
    required VoidCallback onPressed,
  }) {
    final bgColor = isDanger
        ? (isDark ? const Color(0xFF2A1C1C) : const Color(0xFFFEE2E2))
        : color;
    final fgColor = textColor ?? (isDanger ? const Color(0xFFDC2626) : Colors.white);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600 * scale),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 46 * scale,
          child: ElevatedButton(
            onPressed: _isJoiningOrLeavingChat ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              elevation: isDanger ? 0 : 2,
              shadowColor: color.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24 * scale),
                side: isDanger
                    ? BorderSide(
                        color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5),
                        width: 1,
                      )
                    : BorderSide.none,
              ),
              padding: EdgeInsets.symmetric(horizontal: 24 * scale),
            ),
            child: _isJoiningOrLeavingChat
                ? SizedBox(
                    width: 20 * scale,
                    height: 20 * scale,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 19 * scale, color: fgColor),
                      SizedBox(width: 8 * scale),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          color: fgColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyPreviewWidget(bool isDark, double scale) {
    if (_replyingToMessage == null) return const SizedBox.shrink();

    final dynamic rawAuthor = _replyingToMessage!['author_username'] ?? _replyingToMessage!['author'] ?? (AppLocalizations.of(context)?.polzovatel_f154 ?? 'Fallback');
    final authorName = rawAuthor.toString();
    final dynamic rawId = _replyingToMessage!['id'];
    final id = rawId is int ? rawId : (int.tryParse(rawId?.toString() ?? '') ?? 0);
    String textPreview = _decryptedMessages[id] ?? _replyingToMessage!['encrypted_text'] ?? _replyingToMessage!['text'] ?? '';

    if (textPreview.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(textPreview);
        if (parsed is Map) {
          if (parsed['type'] == 'voice') textPreview = (AppLocalizations.of(context)?.golosovoeSoobschenie_4a85 ?? 'Fallback');
          else if (parsed['type'] == 'video_message') textPreview = (AppLocalizations.of(context)?.videosoobschenie_57f1 ?? 'Fallback');
          else if (parsed['type'] == 'file') textPreview = '📁 Файл: ${parsed['file_name'] ?? ''}';
          else if (parsed['type'] == 'todo_list') textPreview = (AppLocalizations.of(context)?.spisokZadach_cfa4 ?? 'Fallback');
          else if (parsed['type'] == 'poll') textPreview = (AppLocalizations.of(context)?.opros_5902 ?? 'Fallback');
        }
      } catch (_) {}
    }
    if (textPreview.isEmpty && _replyingToMessage!['file_id'] != null) textPreview = (AppLocalizations.of(context)?.vlozhenie_2474 ?? 'Fallback');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF2563EB),
            width: 3.5 * scale,
          ),
        ),
      ),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.reply,
            color: const Color(0xFF2563EB),
            size: 13 * scale,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ответ для $authorName',
                  style: TextStyle(
                    color: const Color(0xFF2563EB),
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  textPreview,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12 * scale,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _replyingToMessage = null;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(
                Icons.close,
                color: isDark ? Colors.white54 : Colors.black45,
                size: 16 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark, double scale) {
    final l10n = AppLocalizations.of(context);
    final showRecordTooltip = _isHoveringRecordButton && !_showSendButton && !_isRecording;

    Widget? previewWidget;
    if (_attachedFile != null) {
      final fileName = _attachedFile!['file_name'] as String;
      final fileSize = _attachedFile!['file_size'] as int;
      
      String formatBytes(int bytes, int decimals) {
        if (bytes <= 0) return '0 B';
        var suffixes = [(AppLocalizations.of(context)?.b_3b67 ?? 'Fallback'), (AppLocalizations.of(context)?.kb_419d ?? 'Fallback'), (AppLocalizations.of(context)?.mb_b808 ?? 'Fallback'), (AppLocalizations.of(context)?.gb_e572 ?? 'Fallback'), (AppLocalizations.of(context)?.tb_0e05 ?? 'Fallback')];
        var i = (log(bytes) / log(1024)).floor();
        return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
      }

      previewWidget = Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.fileLines,
              color: isDark ? Colors.white70 : Colors.black54,
              size: 16 * scale,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                fileName,
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                  fontSize: 12.5 * scale,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${formatBytes(fileSize, 1)})',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black45,
                fontSize: 11 * scale,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _attachedFile = null;
                  if (_messageController.text.trim().isEmpty) {
                    _showSendButton = false;
                  }
                });
              },
              child: FaIcon(
                FontAwesomeIcons.xmark,
                color: isDark ? Colors.white54 : Colors.black54,
                size: 14 * scale,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600 * scale),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_replyingToMessage != null) _buildReplyPreviewWidget(isDark, scale),
            if (previewWidget != null) previewWidget,
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        spreadRadius: -2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_isRecording) ...[
                        const SizedBox(width: 8),
                        const _BlinkingRedDot(),
                        const SizedBox(width: 10),
                        Text(
                          _isVoiceMode ? (l10n?.recordingVoice ?? 'Запись голосового...') : (l10n?.recordingVideo ?? 'Запись видео...'),
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 13.5 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '0:${_recordingDuration.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13.5 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n?.releaseToSend ?? 'Отпустите для отправки',
                          style: TextStyle(
                            color: isDark ? Colors.white30 : Colors.black38,
                            fontSize: 12 * scale,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else ...[
                        // Emoji button on the left
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.faceSmile,
                            color: isDark ? Colors.white70 : Colors.black54,
                            size: 20,
                          ),
                          tooltip: l10n?.emoji ?? 'Эмодзи',
                          onPressed: () {
                            CustomToast.show(
                              context,
                              l10n?.emojiPanelInDev ?? 'Панель эмодзи в разработке',
                              type: ToastType.info,
                            );
                          },
                        ),
                        // Text Field
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _messageFocusNode,
                            minLines: 1,
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: l10n?.typeMessage ?? 'Написать сообщение...',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white.withOpacity(0.35) : Colors.black.withOpacity(0.35),
                                fontSize: 13.5 * scale,
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 4, right: 8, top: 12, bottom: 12),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 13.5 * scale,
                            ),
                            onSubmitted: (_) {
                              if (_messageController.text.trim().isNotEmpty) {
                                _sendMessage();
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 4),
                        // Attach button with dropdown menu (TODO and POLL options), positioned next to send button
                        Tooltip(
                          message: l10n?.addAttachment ?? 'Добавить вложение',
                          child: GestureDetector(
                            key: _attachmentKey,
                            onTap: () {
                              final renderBox = _attachmentKey.currentContext?.findRenderObject() as RenderBox?;
                              if (renderBox != null) {
                                final position = renderBox.localToGlobal(Offset.zero);
                                final size = renderBox.size;
                                final menuLeft = position.dx + (size.width / 2) - (100.0 * scale);
                                final menuTop = position.dy - (132.0 * scale) - 8;

                                CustomContextMenu.show(
                                  context: context,
                                  position: Offset(menuLeft, menuTop),
                                  items: [
                                    CustomContextMenuItem(
                                      icon: FaIcon(FontAwesomeIcons.fileLines, size: 14 * scale),
                                      label: l10n?.file ?? 'Файл',
                                      onTap: _pickAndStageFile,
                                    ),
                                    CustomContextMenuItem(
                                      icon: FaIcon(FontAwesomeIcons.listCheck, size: 14 * scale),
                                      label: l10n?.todoList ?? 'Список задач',
                                      onTap: _showTodoSendDialog,
                                    ),
                                    CustomContextMenuItem(
                                      icon: FaIcon(FontAwesomeIcons.squarePollVertical, size: 14 * scale),
                                      label: l10n?.poll ?? 'Опрос',
                                      onTap: _showPollSendDialog,
                                    ),
                                  ],
                                );
                              }
                            },
                            child: Container(
                              width: 30 * scale,
                              height: 30 * scale,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.paperclip,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  size: 14 * scale,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      // Integrated Send / Voice button (pure white styled, using FA icons)
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            _isHoveringRecordButton = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _isHoveringRecordButton = false;
                          });
                        },
                        child: GestureDetector(
                          onTap: () {
                            if (_showSendButton) {
                              _sendMessage();
                            } else {
                              setState(() {
                                _isVoiceMode = !_isVoiceMode;
                                if (!_isVoiceMode) {
                                  _startCameraPreview();
                                } else {
                                  _stopCameraPreview();
                                }
                              });
                            }
                          },
                          onLongPressStart: _showSendButton ? null : (_) => _startRecording(),
                          onLongPressEnd: _showSendButton ? null : (_) => _stopAndSendRecording(),
                          onLongPressCancel: _showSendButton ? null : () => _cancelRecording(),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: (_isRecording ? 34 : 30) * scale,
                            height: (_isRecording ? 34 : 30) * scale,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording
                                  ? Colors.red
                                  : (isDark ? Colors.white.withOpacity(0.9) : Colors.white),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                child: FaIcon(
                                  _showSendButton
                                      ? FontAwesomeIcons.solidPaperPlane
                                      : (_isVoiceMode ? FontAwesomeIcons.microphone : FontAwesomeIcons.video),
                                  key: ValueKey<String>(
                                    _showSendButton
                                        ? 'send'
                                        : (_isVoiceMode ? 'mic' : 'video'),
                                  ),
                                  color: _isRecording
                                      ? Colors.white
                                      : (_showSendButton
                                          ? const Color(0xFF2563EB)
                                          : (_isVoiceMode ? const Color(0xFF10B981) : const Color(0xFF38BDF8))),
                                  size: 13 * scale,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // The floating hover info badge with smooth transition animations
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              bottom: showRecordTooltip ? (52 * scale) : (36 * scale),
              right: 4 * scale,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                opacity: showRecordTooltip ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !showRecordTooltip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: BoxConstraints(maxWidth: 240 * scale),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isVoiceMode
                              ? (l10n?.voiceRecordTitle ?? 'Запись голосового (ГС)')
                              : (l10n?.videoRecordTitle ?? 'Запись видео (ВC)'),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 11.5 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n?.holdToRecordHint ?? 'Удерживайте кнопку для записи\nНажмите для смены режима',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 10.5 * scale,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
  }

  Widget _buildSearchOverlay(bool isDark, double scale) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            width: 400 * scale,
            height: 500 * scale,
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (AppLocalizations.of(context)?.novyyChat_f775 ?? 'Fallback'),
                      style: TextStyle(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchResults = [];
                          _searchController.clear();
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Search Input
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: (AppLocalizations.of(context)?.imyaPolzovatelyaMin5Simvolov_1232 ?? 'Fallback'),
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  onChanged: (val) {
                    if (val.trim().length >= 5) {
                      _handleSearch(val);
                    } else {
                      setState(() => _searchResults = []);
                    }
                  },
                ),
                SizedBox(height: 16),
                
                // Results List
                Expanded(
                  child: _isSearchLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _searchResults.isEmpty
                          ? Center(
                              child: Text(
                                _searchController.text.length < 5
                                    ? (AppLocalizations.of(context)?.vvedite5IliBoleeSimvolov_f983 ?? 'Fallback')
                                    : (AppLocalizations.of(context)?.polzovateliNeNaydeny_c01a ?? 'Fallback'),
                                style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final user = _searchResults[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.2),
                                    child: Text(
                                      (user['first_name'] as String? ?? user['username'] as String)[0].toUpperCase(),
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                    ),
                                  ),
                                  title: Text(
                                    user['first_name'] ?? user['username'],
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                  ),
                                  subtitle: Text(
                                    '@${user['username']}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  trailing: const Icon(Icons.message_rounded, color: Color(0xFF2563EB)),
                                  onTap: () => _startChatWithUser(user),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateTodoLocalCompletion(String todoMsgId, int itemIndex, bool isCompleted) {
    setState(() {
      for (var m in _messages) {
        if (m['message_id']?.toString() == todoMsgId) {
          final currentStatus = Map<String, dynamic>.from(m['completion_status'] ?? {});
          currentStatus[itemIndex.toString()] = isCompleted;
          m['completion_status'] = currentStatus;
          break;
        }
      }
    });
  }

  void _updatePollLocalVote(String pollMsgId, String optionId, bool removeVote, String userId) {
    setState(() {
      for (var m in _messages) {
        if (m['message_id']?.toString() == pollMsgId) {
          final List<String> userVotes = List<String>.from(m['user_votes'] ?? []);
          final isCurrentUser = userId == _myId?.toString();

          if (isCurrentUser) {
            if (removeVote) {
              if (!userVotes.contains(optionId)) {
                // Vote already removed locally, skip duplicate increment/decrement
                break;
              }
              userVotes.remove(optionId);
            } else {
              if (userVotes.contains(optionId)) {
                // Vote already added locally, skip duplicate increment/decrement
                break;
              }
              userVotes.add(optionId);
            }
            m['user_votes'] = userVotes;
          }

          // Update votes_by_option
          final votesByOption = Map<String, dynamic>.from(m['votes_by_option'] ?? {});
          final currentVotes = votesByOption[optionId] is num 
              ? (votesByOption[optionId] as num).toInt() 
              : (int.tryParse(votesByOption[optionId]?.toString() ?? '') ?? 0);
          
          if (removeVote) {
            votesByOption[optionId] = (currentVotes - 1).clamp(0, 999999);
          } else {
            votesByOption[optionId] = currentVotes + 1;
          }
          m['votes_by_option'] = votesByOption;
          break;
        }
      }
    });
  }

  Widget _buildTodoWidget(Map<String, dynamic> msg, Map<String, dynamic> payload, bool isMe, bool isDark, double scale) {
    final title = payload['title']?.toString() ?? (AppLocalizations.of(context)?.spisokZadach_1852 ?? 'Fallback');
    final items = payload['items'] as List? ?? [];
    final todoMsgId = msg['message_id']?.toString() ?? '';

    // Handle completion status map
    final completionStatus = msg['completion_status'] is Map 
        ? msg['completion_status'] as Map 
        : (msg['completion_status'] is String && (msg['completion_status'] as String).isNotEmpty 
            ? jsonDecode(msg['completion_status'] as String) as Map 
            : {});

    return Container(
      width: 260 * scale,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_turned_in_rounded,
                size: 18 * scale,
                color: isMe ? Colors.white : (isDark ? Colors.blue.shade400 : Colors.blue.shade600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final itemText = (item is Map ? item['text'] : item.toString()) ?? '';
            final isCompleted = completionStatus[index.toString()] == true;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: GestureDetector(
                onTap: () {
                  final nextVal = !isCompleted;
                  _updateTodoLocalCompletion(todoMsgId, index, nextVal);
                  // Send WebSocket update
                  _webSocketService?.sendMessage({
                    'type': 'todo_completion_update',
                    'todo_message_id': todoMsgId,
                    'item_index': index,
                    'is_completed': nextVal,
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 18 * scale,
                      height: 18 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted 
                            ? (isMe ? Colors.white : Colors.blue) 
                            : Colors.transparent,
                        border: Border.all(
                          color: isCompleted 
                              ? (isMe ? Colors.white : Colors.blue) 
                              : (isMe ? Colors.white60 : (isDark ? Colors.white38 : Colors.black38)),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: isCompleted 
                              ? (isMe ? Colors.blue.shade700 : Colors.white) 
                              : Colors.transparent,
                          size: 12 * scale,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        itemText,
                        style: TextStyle(
                          color: isCompleted 
                              ? (isMe ? Colors.white60 : (isDark ? Colors.white38 : Colors.black38)) 
                              : (isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                          fontSize: 13.5 * scale,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPollWidget(Map<String, dynamic> msg, Map<String, dynamic> payload, bool isMe, bool isDark, double scale) {
    final l10n = AppLocalizations.of(context);
    final question = payload['question']?.toString() ?? (l10n?.poll ?? 'Опрос');
    final options = payload['options'] as List? ?? [];
    final isMultipleChoice = payload['is_multiple_choice'] == true;
    final pollMsgId = msg['message_id']?.toString() ?? '';

    // Handle votes map
    final votesByOption = msg['votes_by_option'] is Map
        ? msg['votes_by_option'] as Map
        : (msg['votes_by_option'] is String && (msg['votes_by_option'] as String).isNotEmpty
            ? jsonDecode(msg['votes_by_option'] as String) as Map
            : {});

    // Handle user votes
    final List<String> userVotes = msg['user_votes'] is List
        ? List<String>.from(msg['user_votes'] as List)
        : (msg['user_votes'] is String && (msg['user_votes'] as String).isNotEmpty
            ? List<String>.from(jsonDecode(msg['user_votes'] as String) as List)
            : []);

    // Calculate total votes
    int totalVotes = 0;
    votesByOption.values.forEach((v) {
      if (v is num) {
        totalVotes += v.toInt();
      } else {
        totalVotes += int.tryParse(v.toString()) ?? 0;
      }
    });

    final hasVoted = userVotes.isNotEmpty;

    return Container(
      width: 260 * scale,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question,
            style: TextStyle(
              color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
              fontSize: 15.5 * scale,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: 2),
          Text(
            isMultipleChoice ? (l10n?.allowMultipleAnswers ?? 'Выбор нескольких вариантов') : (l10n?.singleChoice ?? 'Одиночный выбор'),
            style: TextStyle(
              color: isMe ? Colors.white54 : (isDark ? Colors.white38 : Colors.black45),
              fontSize: 10.5 * scale,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            final option = options[index];
            final optionId = option['id']?.toString() ?? '';
            final optionText = option['text']?.toString() ?? '';

            final rawVotes = votesByOption[optionId];
            final optionVotes = rawVotes is num ? rawVotes.toInt() : (int.tryParse(rawVotes?.toString() ?? '') ?? 0);
            final double percent = totalVotes > 0 ? (optionVotes / totalVotes) : 0.0;
            final percentText = '${(percent * 100).round()}%';
            final isSelected = userVotes.contains(optionId);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: GestureDetector(
                onTap: () {
                  final nextSelected = !isSelected;
                  _updatePollLocalVote(pollMsgId, optionId, !nextSelected, _myId?.toString() ?? '');
                  // Send WebSocket update
                  _webSocketService?.sendMessage({
                    'type': 'poll_vote',
                    'poll_message_id': pollMsgId,
                    'option_id': optionId,
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      // Progress background
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            widthFactor: percent,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              color: isMe 
                                  ? Colors.white.withOpacity(isSelected ? 0.2 : 0.08)
                                  : (isDark 
                                      ? Colors.white.withOpacity(isSelected ? 0.16 : 0.06)
                                      : Colors.blue.withOpacity(isSelected ? 0.15 : 0.05)),
                            ),
                          ),
                        ),
                      ),
                      // Text & percentage row
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected 
                                ? (isMe ? Colors.white.withOpacity(0.4) : Colors.blue.withOpacity(0.5)) 
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: isMe ? Colors.white : (isDark ? Colors.blue.shade400 : Colors.blue.shade600),
                                      size: 14 * scale,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                ],
                              ),
                            ),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                style: TextStyle(
                                  color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                  fontSize: 13.5 * scale,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                  fontFamily: 'Inter',
                                ),
                                child: Text(optionText),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              style: TextStyle(
                                color: isMe ? Colors.white70 : (isDark ? Colors.white60 : Colors.black54),
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                              child: Text(percentText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: 8),
          Text(
            totalVotes == 0
                ? (AppLocalizations.of(context)?.netGolosov_17d0 ?? 'Fallback')
                : '$totalVotes ${_formatVotesCountText(totalVotes)}',
            style: TextStyle(
              color: isMe ? Colors.white54 : (isDark ? Colors.white38 : Colors.black45),
              fontSize: 11 * scale,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileAttachmentWidget(Map<String, dynamic> payload, bool isMe, bool isDark, double scale) {
    final fileName = payload['file_name']?.toString() ?? (AppLocalizations.of(context)?.fayl_2d46 ?? 'Fallback');
    final fileSize = payload['file_size'] as int? ?? 0;
    final fileId = payload['file_id']?.toString() ?? '';
    
    // Nice byte formatting
    String formatBytes(int bytes, int decimals) {
      if (bytes <= 0) return (AppLocalizations.of(context)?.loc_0B_5a4d ?? 'Fallback');
      var suffixes = [(AppLocalizations.of(context)?.b_3b67 ?? 'Fallback'), (AppLocalizations.of(context)?.kb_419d ?? 'Fallback'), (AppLocalizations.of(context)?.mb_b808 ?? 'Fallback'), (AppLocalizations.of(context)?.gb_e572 ?? 'Fallback'), (AppLocalizations.of(context)?.tb_0e05 ?? 'Fallback')];
      var i = (log(bytes) / log(1024)).floor();
      return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4, top: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withOpacity(0.12) : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? Colors.white.withOpacity(0.2) : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMe ? Colors.white.withOpacity(0.15) : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(
              FontAwesomeIcons.fileLines,
              color: isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              size: 20 * scale,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    color: isMe ? Colors.white : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87),
                    fontSize: 13.5 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formatBytes(fileSize, 1),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54),
                    fontSize: 11 * scale,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.download,
              color: isMe ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54),
              size: 14 * scale,
            ),
            onPressed: () => _downloadFile(fileId, fileName),
          ),
        ],
      ),
    );
  }

  bool _isAudioFile(Map<String, dynamic> payload) {
    final type = payload['type']?.toString().toLowerCase() ?? '';
    if (type == 'audio') return true;
    final fileName = (payload['file_name'] ?? payload['attached_file_name'] ?? payload['name'] ?? '').toString().toLowerCase();
    final mimeType = (payload['mime_type'] ?? payload['attached_file_type'] ?? '').toString().toLowerCase();
    const audioExtensions = ['.mp3', '.wav', '.ogg', '.m4a', '.flac', '.aac', '.opus', '.wma'];
    if (audioExtensions.any((ext) => fileName.endsWith(ext))) return true;
    if (mimeType.contains('audio/') || mimeType.contains('audio') || mimeType.contains('mp3') || mimeType.contains('mpeg')) return true;
    return false;
  }

  String _formatVotesCountText(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return (AppLocalizations.of(context)?.golos_6b94 ?? 'Fallback');
    } else if ((count % 10 >= 2 && count % 10 <= 4) && (count % 100 < 10 || count % 100 >= 20)) {
      return (AppLocalizations.of(context)?.golosa_bb8d ?? 'Fallback');
    } else {
      return (AppLocalizations.of(context)?.golosov_7f51 ?? 'Fallback');
    }
  }

  Future<void> _pickAndStageFile() async {
    if (_selectedChat == null) return;
    
    try {
      final result = await FilePicker.pickFiles(allowMultiple: false);
      if (result == null || result.files.single.path == null) return;
      
      final path = result.files.single.path!;
      final file = File(path);
      final fileName = result.files.single.name;
      final fileSize = result.files.single.size;
      
      // Determine file type based on extension
      String fileType = 'document';
      final lowerName = fileName.toLowerCase();
      if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg') || lowerName.endsWith('.png') || lowerName.endsWith('.gif') || lowerName.endsWith('.webp') || lowerName.endsWith('.bmp')) {
        fileType = 'image';
      } else if (lowerName.endsWith('.mp4') || lowerName.endsWith('.mov') || lowerName.endsWith('.avi') || lowerName.endsWith('.mkv') || lowerName.endsWith('.webm')) {
        fileType = 'video';
      } else if (lowerName.endsWith('.mp3') || lowerName.endsWith('.wav') || lowerName.endsWith('.ogg') || lowerName.endsWith('.m4a') || lowerName.endsWith('.flac')) {
        fileType = 'audio';
      }

      if (mounted) {
        CustomToast.show(context, 'Загрузка файла "$fileName"...', type: ToastType.info);
      }

      final chatId = _selectedChat!['id'].toString();
      final uploadRes = await _apiService.uploadFile(file, fileType, chatId);

      if (uploadRes.success && uploadRes.data != null) {
        final fileId = uploadRes.data!['file_id']?.toString() ?? uploadRes.data!['id']?.toString();
        if (fileId == null) throw Exception((AppLocalizations.of(context)?.nePoluchenIdFaylaOt_86c8 ?? 'Fallback'));

        setState(() {
          _attachedFile = {
            'file_id': fileId,
            'file_name': fileName,
            'file_size': fileSize,
            'file_type': fileType,
          };
          _showSendButton = true;
        });
        
        if (mounted) {
          CustomToast.show(context, (AppLocalizations.of(context)?.faylZagruzhenIPrikreplen_dc24 ?? 'Fallback'), type: ToastType.success);
        }
      } else {
        throw Exception(uploadRes.error ?? (AppLocalizations.of(context)?.neizvestnayaOshibkaZagruzki_68cb ?? 'Fallback'));
      }
    } catch (e) {
      Logger.error('MessengerScreen', (AppLocalizations.of(context)?.oshibkaZagruzkiFayla_86e5 ?? 'Fallback'), e);
      if (mounted) {
        CustomToast.show(context, 'Ошибка загрузки файла: $e', type: ToastType.error);
      }
    }
  }

  void _triggerFileMetadataFetch(String fileId) {
    if (_fetchingFileMetadata.contains(fileId)) return;
    _fetchingFileMetadata.add(fileId);
    
    _apiService.getFileMetadata(fileId).then((res) {
      if (mounted) {
        if (res.success && res.data != null) {
          setState(() {
            _fileMetadataCache[fileId] = res.data!;
          });
        }
        _fetchingFileMetadata.remove(fileId);
      }
    }).catchError((e) {
      if (mounted) {
        _fetchingFileMetadata.remove(fileId);
      }
    });
  }

  Future<void> _downloadFile(String fileId, String fileName) async {
    try {
      final dir = await getDownloadsDirectory();
      
      String? outputFilePath = await FilePicker.saveFile(
        dialogTitle: (AppLocalizations.of(context)?.sohranitFaylKak_0f93 ?? 'Fallback'),
        fileName: fileName,
        initialDirectory: dir?.path,
      );

      if (outputFilePath == null) return;

      if (mounted) {
        CustomToast.show(context, 'Скачивание файла "$fileName"...', type: ToastType.info);
      }

      final uri = Uri.parse(ApiService.baseUrl);
      final port = uri.hasPort ? ':${uri.port}' : '';
      final host = '${uri.scheme}://${uri.host}$port';
      final downloadUrl = '$host/api/files/download/$fileId/';

      final token = await _apiService.getAccessToken();
      final dio = Dio();
      
      final response = await dio.download(
        downloadUrl,
        outputFilePath,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          CustomToast.show(context, 'Файл сохранен: $outputFilePath', type: ToastType.success);
        }
      } else {
        throw Exception('Код сервера: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('MessengerScreen', (AppLocalizations.of(context)?.oshibkaSkachivaniyaFayla_34ac ?? 'Fallback'), e);
      if (mounted) {
        CustomToast.show(context, 'Ошибка при скачивании файла: $e', type: ToastType.error);
      }
    }
  }

  Future<void> _sendCustomMessage(String text) async {
    if (_selectedChat == null) return;

    final chatId = _selectedChat!['chat_id'] as String;
    final myUserId = _myId?.toString();
    final otherUser = _selectedChat!['other_user'] as Map<String, dynamic>?;

    String encryptedText = "";
    try {
      if (chatId.startsWith('favorites_') || chatId == 'favorites') {
        if (myUserId == null) return;
        encryptedText = await _cryptoService.encryptFavoritesMessage(text, myUserId);
      } else if (chatId.startsWith('personal_')) {
        final peerPubKey = await _getPeerPublicKey(otherUser);
        if (peerPubKey == null) return;
        if (peerPubKey == 'bot') {
          final chatKeyHex = await _getGroupChatKey(chatId);
          if (chatKeyHex == null) return;
          encryptedText = await _cryptoService.encryptGroupMessage(text, chatKeyHex);
        } else {
          encryptedText = await _cryptoService.encryptPersonalMessage(text, peerPubKey, chatId);
        }
      } else if (chatId.startsWith('group_') || chatId.startsWith('channel_')) {
        final chatKeyHex = await _getGroupChatKey(chatId);
        if (chatKeyHex == null) return;
        encryptedText = await _cryptoService.encryptGroupMessage(text, chatKeyHex);
      }
    } catch (e) {
      Logger.error('MessengerScreen', 'Encryption failed for custom message', e);
      return;
    }

    if (encryptedText.isEmpty) return;

    // Helper to encrypt additional plaintext (like titles or questions) using the same logic
    Future<String> encryptString(String plaintext) async {
      try {
        if (chatId.startsWith('favorites_') || chatId == 'favorites') {
          if (myUserId == null) return "";
          return await _cryptoService.encryptFavoritesMessage(plaintext, myUserId);
        } else if (chatId.startsWith('personal_')) {
          final peerPubKey = await _getPeerPublicKey(otherUser);
          if (peerPubKey == null) return "";
          if (peerPubKey == 'bot') {
            final chatKeyHex = await _getGroupChatKey(chatId);
            if (chatKeyHex == null) return "";
            return await _cryptoService.encryptGroupMessage(plaintext, chatKeyHex);
          } else {
            return await _cryptoService.encryptPersonalMessage(plaintext, peerPubKey, chatId);
          }
        } else if (chatId.startsWith('group_') || chatId.startsWith('channel_')) {
          final chatKeyHex = await _getGroupChatKey(chatId);
          if (chatKeyHex == null) return "";
          return await _cryptoService.encryptGroupMessage(plaintext, chatKeyHex);
        }
      } catch (_) {}
      return "";
    }

    // Save locally
    _sentPlaintexts[encryptedText] = text;

    bool sentViaWs = false;
    if (_webSocketService != null && _webSocketService!.isConnected) {
      Map<String, dynamic>? parsedJson;
      try {
        parsedJson = jsonDecode(text) as Map<String, dynamic>?;
      } catch (_) {}

      if (parsedJson != null && parsedJson['type'] == 'todo_list') {
        final title = parsedJson['title'] as String? ?? (AppLocalizations.of(context)?.bezNazvaniya_6584 ?? 'Fallback');
        final encryptedTitle = await encryptString(title);
        sentViaWs = _webSocketService!.sendMessage({
          'type': 'todo_list_message',
          'encrypted_content': encryptedText,
          'encrypted_title': encryptedTitle,
          'title': title,
          'chat_id': chatId,
        });
      } else if (parsedJson != null && parsedJson['type'] == 'poll') {
        final question = parsedJson['question'] as String? ?? (AppLocalizations.of(context)?.bezVoprosa_d390 ?? 'Fallback');
        final encryptedQuestion = await encryptString(question);
        sentViaWs = _webSocketService!.sendMessage({
          'type': 'poll_message',
          'encrypted_content': encryptedText,
          'encrypted_question': encryptedQuestion,
          'question': question,
          'chat_id': chatId,
        });
      } else if (parsedJson != null && parsedJson['type'] == 'voice') {
        sentViaWs = _webSocketService!.sendMessage({
          'type': 'voice_message',
          'file_id': parsedJson['file_id'],
          'duration': parsedJson['duration'],
          'chat_id': chatId,
          'encrypted_text': encryptedText,
        });
      } else if (parsedJson != null && parsedJson['type'] == 'video_message') {
        sentViaWs = _webSocketService!.sendMessage({
          'type': 'video_message',
          'file_id': parsedJson['file_id'],
          'duration': parsedJson['duration'],
          'chat_id': chatId,
          'encrypted_text': encryptedText,
        });
      } else if (parsedJson != null && parsedJson['type'] == 'file') {
        sentViaWs = _webSocketService!.sendMessage({
          'type': 'encrypted_message',
          'chat_id': chatId,
          'encrypted_text': encryptedText,
          'file_id': parsedJson['file_id'],
        });
      } else {
        sentViaWs = _webSocketService!.sendMessage({
          'type': 'encrypted_message',
          'encrypted_text': encryptedText,
        });
      }
    }

    if (!sentViaWs) {
      _sentPlaintexts.remove(encryptedText);
      final res = await _apiService.sendMessage(chatId, encryptedText);
      if (res.success && res.data != null) {
        final newMsg = res.data!;
        final dynamic rawId = newMsg['id'];
        final id = rawId is int ? rawId : (int.tryParse(rawId.toString()) ?? 0);
        _decryptedMessages[id] = text;

        if (mounted) {
          setState(() {
            _messages.insert(0, newMsg);
            _messagesToAnimate.add(id);
          });
          _scrollToBottom();
        }
        _loadChats(silent: true);
      }
    }
  }

  void _startRecording() async {
    if (_showSendButton) return;
    
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });

    _sendTypingStatus(true, _isVoiceMode ? 'recording_voice' : 'recording_video');

    if (_isVoiceMode) {
      final dir = await getTemporaryDirectory();
      _recordingPath = '${dir.path}/voice_record_${DateTime.now().millisecondsSinceEpoch}.wav';

      if (Platform.isLinux) {
        // Напрямую запускаем arecord — обходим сломанный record_linux
        try {
          print('🎙️ Запуск arecord напрямую: $_recordingPath');
          _arecordProcess = await Process.start('arecord', [
            '-f', 'S16_LE',   // PCM 16-bit little-endian
            '-r', '24000',    // 24 kHz (достаточно для голоса)
            '-c', '1',        // моно
            '-t', 'wav',      // формат WAV
            _recordingPath!,
          ]);
          print('🎙️ arecord запущен (pid: ${_arecordProcess!.pid})');
        } catch (e) {
          print('❌ Не удалось запустить arecord: $e');
          CustomToast.show(context, 'Не удалось запустить запись: $e', type: ToastType.error);
          setState(() { _isRecording = false; });
          return;
        }
      } else {
        // Другие платформы — используем пакет record
        _audioRecorder ??= AudioRecorder();
        if (await _audioRecorder!.hasPermission()) {
          try {
            await _audioRecorder!.start(
              const RecordConfig(encoder: AudioEncoder.wav),
              path: _recordingPath!,
            );
          } catch (e) {
            print('❌ AudioRecorder start error: $e');
          }
        } else {
          CustomToast.show(context, (AppLocalizations.of(context)?.netDostupaKMikrofonu_a4ef ?? 'Fallback'), type: ToastType.warning);
          setState(() { _isRecording = false; });
          return;
        }
      }
    } else {
      final dir = await getTemporaryDirectory();
      _recordingPath = '${dir.path}/video_record_${DateTime.now().millisecondsSinceEpoch}.mp4';

      if (Platform.isLinux) {
        try {
          print('📹 Запуск записи ffmpeg напрямую: $_recordingPath');
          _ffmpegProcess = await Process.start('ffmpeg', [
            '-y',
            '-use_wallclock_as_timestamps', '1',
            '-thread_queue_size', '1024',
            '-fflags', 'nobuffer',
            '-f', 'v4l2',
            '-framerate', '30',
            '-video_size', '640x480',
            '-i', '/dev/video0',
            '-use_wallclock_as_timestamps', '1',
            '-thread_queue_size', '1024',
            '-f', 'pulse',
            '-i', 'default',
            '-c:v', 'libx264',
            '-pix_fmt', 'yuv420p',
            '-preset', 'ultrafast',
            '-tune', 'zerolatency',
            '-c:a', 'aac',
            '-strict', '-2',
            '-fflags', 'nobuffer',
            '-flush_packets', '1',
            '-f', 'tee',
            '-map', '0:v',
            '-map', '1:a',
            '[f=mpegts]udp://127.0.loc_0.1:44444?pkt_size=1316|[f=mp4]${_recordingPath!}',
          ]);
          print('📹 Запись ffmpeg запущена (pid: ${_ffmpegProcess!.pid})');
        } catch (e) {
          print('❌ Не удалось запустить ffmpeg: $e');
          CustomToast.show(context, 'Не удалось запустить запись видео: $e', type: ToastType.error);
          setState(() { _isRecording = false; });
          return;
        }
      } else if (Platform.isWindows || Platform.isMacOS) {
        if (_cameraController != null && _cameraController!.value.isInitialized) {
          try {
            await _cameraController!.startVideoRecording();
            print((AppLocalizations.of(context)?.zapisVideoCherezPlaginCamera_b9dd ?? 'Fallback'));
          } catch (e) {
            print('Ошибка записи camera: $e');
            CustomToast.show(context, 'Не удалось запустить камеру: $e', type: ToastType.error);
            setState(() { _isRecording = false; });
            return;
          }
        } else {
          print((AppLocalizations.of(context)?.kameraNeInitsializirovanaNaEtoy_21e0 ?? 'Fallback'));
          CustomToast.show(context, (AppLocalizations.of(context)?.kameraNeGotova_9f09 ?? 'Fallback'), type: ToastType.error);
          setState(() { _isRecording = false; });
          return;
        }
      } else {
        print((AppLocalizations.of(context)?.zapisVideosoobscheniyaNaEtoyPlatforme_a561 ?? 'Fallback'));
      }
    }

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingDuration++;
        });
      }
    });
  }

  void _stopAndSendRecording() async {
    if (!_isRecording) return;
    
    _recordingTimer?.cancel();
    final duration = _recordingDuration;
    
    setState(() {
      _isRecording = false;
      _recordingDuration = 0;
    });

    _sendTypingStatus(false, _isVoiceMode ? 'recording_voice' : 'recording_video');

    String? path;
    if (_isVoiceMode) {
      if (Platform.isLinux) {
        // Просто убиваем процесс arecord — файл автоматически сохранится
        if (_arecordProcess != null) {
          _arecordProcess!.kill(ProcessSignal.sigint); // SIGINT для корректного завершения WAV
          await _arecordProcess!.exitCode; // Ждём завершения
          _arecordProcess = null;
          print((AppLocalizations.of(context)?.arecordOstanovlen_edf2 ?? 'Fallback'));
        }
        path = _recordingPath;
      } else {
        try {
          if (_audioRecorder != null && await _audioRecorder!.isRecording()) {
            path = await _audioRecorder!.stop();
          }
        } catch (e) {
          print('❌ AudioRecorder stop error: $e');
          path = _recordingPath;
        }
      }
    } else {
      if (Platform.isLinux) {
        if (_ffmpegProcess != null) {
          _ffmpegProcess!.kill(ProcessSignal.sigint); // SIGINT для корректного завершения MP4
          await _ffmpegProcess!.exitCode; // Ждём завершения
          _ffmpegProcess = null;
          print((AppLocalizations.of(context)?.ffmpegOstanovlen_63a0 ?? 'Fallback'));
        }
        path = _recordingPath;
      } else if (Platform.isWindows || Platform.isMacOS) {
        if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
          try {
            final file = await _cameraController!.stopVideoRecording();
            path = file.path;
            print('📹 Запись видео через плагин camera завершена: $path');
          } catch (e) {
            print('Ошибка остановки camera: $e');
            path = _recordingPath;
          }
        } else {
          path = _recordingPath;
        }
      } else {
        path = _recordingPath;
      }
    }

    if (duration < 1) {
      if (mounted) {
        CustomToast.show(
          context,
          (AppLocalizations.of(context)?.zapisSlishkomKorotkaya_5cda ?? 'Fallback'),
          type: ToastType.warning,
        );
      }
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
      return;
    }

    if (_isVoiceMode && path != null) {
      final file = File(path);
      if (await file.exists() && await file.length() > 0) {
        final uploadRes = await _apiService.uploadFile(file, 'audio', _selectedChat!['id'].toString());
        
        if (uploadRes.success && uploadRes.data != null) {
          final fileId = uploadRes.data!['file_id'] ?? uploadRes.data!['id']?.toString() ?? 'voice_${DateTime.now().millisecondsSinceEpoch}';
          final fileUrl = uploadRes.data!['file_url'] ?? '';
          
          final payload = jsonEncode({
            'type': 'voice',
            'file_id': fileId,
            'file_url': fileUrl,
            'file_name': 'voice_note.wav',
            'mime_type': 'audio/wav',
            'file_size': await file.length(),
            'duration': duration,
          });
          _sendCustomMessage(payload);
        } else {
          if (mounted) {
            CustomToast.show(context, 'Ошибка загрузки: ${uploadRes.error}', type: ToastType.error);
          }
        }
      } else {
        print('❌ Файл записи пуст или не существует: $path');
        if (mounted) {
          CustomToast.show(context, (AppLocalizations.of(context)?.oshibkaZapisiFaylPust_106b ?? 'Fallback'), type: ToastType.error);
        }
      }
    } else if (!_isVoiceMode) {
      if (path != null) {
        final file = File(path);
        if (await file.exists() && await file.length() > 0) {
          final uploadRes = await _apiService.uploadFile(file, 'video_message', _selectedChat!['id'].toString());
          
          if (uploadRes.success && uploadRes.data != null) {
            final fileId = uploadRes.data!['file_id'] ?? uploadRes.data!['id']?.toString() ?? 'video_${DateTime.now().millisecondsSinceEpoch}';
            final fileUrl = uploadRes.data!['file_url'] ?? '';
            
            _localVideoPaths[fileId] = path;

            final payload = jsonEncode({
              'type': 'video_message',
              'file_id': fileId,
              'file_url': fileUrl,
              'file_name': 'video_note.mp4',
              'mime_type': 'video/mp4',
              'file_size': await file.length(),
              'duration': duration,
              'local_path': path,
            });
            _sendCustomMessage(payload);
          } else {
            if (mounted) {
              CustomToast.show(context, 'Ошибка загрузки видео: ${uploadRes.error}', type: ToastType.error);
            }
          }
        } else {
          // Fallback, если файл не записался (например, на другой платформе или при отсутствии камеры)
          final fileId = 'video_${DateTime.now().millisecondsSinceEpoch}';
          _localVideoPaths[fileId] = path;

          final payload = jsonEncode({
            'type': 'video_message',
            'file_id': fileId,
            'file_name': 'video_note.mp4',
            'mime_type': 'video/mp4',
            'file_size': 8500 * duration,
            'duration': duration,
            'local_path': path,
          });
          _sendCustomMessage(payload);
          if (mounted) {
            CustomToast.show(
              context,
              (AppLocalizations.of(context)?.videosoobschenieOtpravlenoSimulyatsiya_fb29 ?? 'Fallback'),
              type: ToastType.success,
            );
          }
        }
      }
    }
  }

  void _cancelRecording() async {
    if (!_isRecording) return;
    
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordingDuration = 0;
    });

    _sendTypingStatus(false, _isVoiceMode ? 'recording_voice' : 'recording_video');
    
    if (_isVoiceMode) {
      if (Platform.isLinux) {
        _arecordProcess?.kill();
        _arecordProcess = null;
      } else {
        try {
          if (_audioRecorder != null && await _audioRecorder!.isRecording()) {
            await _audioRecorder!.stop();
          }
        } catch (_) {}
      }
    } else {
      if (Platform.isLinux) {
        _ffmpegProcess?.kill();
        _ffmpegProcess = null;
      } else if (Platform.isWindows || Platform.isMacOS) {
        if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
          try { await _cameraController!.stopVideoRecording(); } catch (_) {}
        }
      }
    }

    // Удаляем файл
    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (await file.exists()) await file.delete();
    }

    CustomToast.show(
      context,
      (AppLocalizations.of(context)?.zapisOtmenena_1609 ?? 'Fallback'),
      type: ToastType.info,
    );
  }

  void _startCameraPreview() async {
    if (!Platform.isWindows && !Platform.isMacOS) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      
      final frontCam = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCam,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print('Camera init error: $e');
    }
  }

  void _stopCameraPreview() {
    _cameraController?.dispose();
    _cameraController = null;
  }

  void _showVoiceSendDialog() {
    int duration = 5;
    _sendTypingStatus(true, 'recording_voice');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text((AppLocalizations.of(context)?.otpravitGolosovoeSoobschenie_2481 ?? 'Fallback')),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text((AppLocalizations.of(context)?.imitatsiyaZapisiGolosovogoSoobscheniya_81e7 ?? 'Fallback')),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic_rounded, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    '0:${duration.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: duration.toDouble(),
                min: 1,
                max: 60,
                onChanged: (val) {
                  setDialogState(() {
                    duration = val.toInt();
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text((AppLocalizations.of(context)?.otmena_987b ?? 'Fallback')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final payload = jsonEncode({
                'type': 'voice',
                'file_id': 'voice_${DateTime.now().millisecondsSinceEpoch}',
                'file_name': 'voice_note.m4a',
                'file_size': 1200 * duration,
                'duration': duration,
              });
              _sendCustomMessage(payload);
            },
            child: Text((AppLocalizations.of(context)?.otpravit_6da0 ?? 'Fallback')),
          ),
        ],
      ),
    ).then((_) {
      _sendTypingStatus(false, 'recording_voice');
    });
  }

  void _showTodoSendDialog() {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final List<TextEditingController> itemsControllers = [
      TextEditingController(),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaleProvider = Provider.of<ScaleProvider>(context, listen: false);
    final scale = scaleProvider.scale;
    final activeBrandColor = const Color(0xFF2563EB);

    showGeneralDialog(
      context: context,
      barrierLabel: "TodoDialog",
      barrierDismissible: true,
      barrierColor: isDark ? Colors.black.withOpacity(0.85) : Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final screenSize = MediaQuery.of(context).size;
            final bgColor = isDark ? const Color(0xFF0C0C0C) : Colors.white;
            final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB);

            return Material(
              type: MaterialType.transparency,
              child: Center(
                child: Container(
                  width: 380 * scale,
                  constraints: BoxConstraints(maxHeight: screenSize.height * 0.8),
                  margin: EdgeInsets.all(20 * scale),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(color: borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.6 : 0.06),
                        blurRadius: 24 * scale,
                        offset: Offset(0, 8 * scale),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 12 * scale),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n?.createTodo ?? 'СОЗДАТЬ TO-DO',
                              style: TextStyle(
                                fontSize: 10 * scale,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5 * scale,
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontFamily: 'Inter',
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16 * scale,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              TextField(
                                controller: titleController,
                                style: TextStyle(fontSize: 14 * scale),
                                decoration: InputDecoration(
                                  labelText: l10n?.listName ?? 'Название списка',
                                  labelStyle: TextStyle(fontSize: 12 * scale),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8 * scale),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8 * scale),
                                    borderSide: BorderSide(color: activeBrandColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n?.todoItems ?? 'Пункты',
                                style: TextStyle(
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...itemsControllers.asMap().entries.map((e) {
                                final i = e.key;
                                final controller = e.value;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8 * scale),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: controller,
                                          style: TextStyle(fontSize: 14 * scale),
                                          decoration: InputDecoration(
                                            hintText: '${l10n?.itemHintPrefix ?? "Пункт"} ${i + 1}',
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8 * scale),
                                              borderSide: BorderSide(color: borderColor),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8 * scale),
                                              borderSide: BorderSide(color: activeBrandColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (itemsControllers.length > 1) ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          iconSize: 18 * scale,
                                          color: isDark ? Colors.white38 : Colors.black38,
                                          onPressed: () {
                                            setModalState(() {
                                              itemsControllers.removeAt(i);
                                            });
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    itemsControllers.add(TextEditingController());
                                  });
                                },
                                icon: Icon(Icons.add, size: 18 * scale),
                                label: Text(l10n?.addTodoItem ?? '+ Добавить пункт', style: TextStyle(fontSize: 13 * scale)),
                                style: TextButton.styleFrom(
                                  foregroundColor: activeBrandColor,
                                  padding: EdgeInsets.symmetric(vertical: 8 * scale, horizontal: 12 * scale),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      // Footer Actions
                      Container(
                        padding: EdgeInsets.all(20 * scale),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: borderColor)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: isDark ? Colors.white70 : Colors.black87,
                                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                              ),
                              child: Text((AppLocalizations.of(context)?.otmena_987b ?? 'Fallback'), style: TextStyle(fontSize: 13 * scale)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final title = titleController.text.trim();
                                final lines = itemsControllers
                                    .map((c) => c.text.trim())
                                    .where((l) => l.isNotEmpty)
                                    .toList();
                                if (title.isEmpty || lines.isEmpty) return;

                                Navigator.pop(context);
                                final itemsList = lines.map((l) => {
                                  'text': l,
                                  'completed': false,
                                }).toList();
                                final payload = jsonEncode({
                                  'type': 'todo_list',
                                  'title': title,
                                  'items': itemsList,
                                  'is_native': true,
                                });
                                _sendCustomMessage(payload);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activeBrandColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 12 * scale),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8 * scale),
                                ),
                              ),
                              child: Text((AppLocalizations.of(context)?.sozdat_b059 ?? 'Fallback'), style: TextStyle(fontSize: 13 * scale, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPollSendDialog() {
    final l10n = AppLocalizations.of(context);
    final questionController = TextEditingController();
    final List<TextEditingController> optionsControllers = [
      TextEditingController(),
      TextEditingController(),
    ];
    bool isMultipleChoice = false;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaleProvider = Provider.of<ScaleProvider>(context, listen: false);
    final scale = scaleProvider.scale;
    final activeBrandColor = const Color(0xFF2563EB);

    showGeneralDialog(
      context: context,
      barrierLabel: "PollDialog",
      barrierDismissible: true,
      barrierColor: isDark ? Colors.black.withOpacity(0.85) : Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final screenSize = MediaQuery.of(context).size;
            final bgColor = isDark ? const Color(0xFF0C0C0C) : Colors.white;
            final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB);

            return Material(
              type: MaterialType.transparency,
              child: Center(
                child: Container(
                  width: 380 * scale,
                  constraints: BoxConstraints(maxHeight: screenSize.height * 0.8),
                  margin: EdgeInsets.all(20 * scale),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(color: borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.6 : 0.06),
                        blurRadius: 24 * scale,
                        offset: Offset(0, 8 * scale),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 12 * scale),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n?.createPoll ?? 'СОЗДАТЬ ОПРОС',
                              style: TextStyle(
                                fontSize: 10 * scale,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5 * scale,
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontFamily: 'Inter',
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16 * scale,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              TextField(
                                controller: questionController,
                                style: TextStyle(fontSize: 14 * scale),
                                decoration: InputDecoration(
                                  labelText: l10n?.pollQuestion ?? 'Вопрос',
                                  labelStyle: TextStyle(fontSize: 12 * scale),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8 * scale),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8 * scale),
                                    borderSide: BorderSide(color: activeBrandColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n?.pollOptions ?? 'Варианты ответа',
                                style: TextStyle(
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...optionsControllers.asMap().entries.map((e) {
                                final i = e.key;
                                final controller = e.value;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8 * scale),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: controller,
                                          style: TextStyle(fontSize: 14 * scale),
                                          decoration: InputDecoration(
                                            hintText: '${l10n?.optionHintPrefix ?? "Вариант"} ${i + 1}',
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8 * scale),
                                              borderSide: BorderSide(color: borderColor),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8 * scale),
                                              borderSide: BorderSide(color: activeBrandColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (optionsControllers.length > 1) ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          iconSize: 18 * scale,
                                          color: isDark ? Colors.white38 : Colors.black38,
                                          onPressed: () {
                                            setModalState(() {
                                              optionsControllers.removeAt(i);
                                            });
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    optionsControllers.add(TextEditingController());
                                  });
                                },
                                icon: Icon(Icons.add, size: 18 * scale),
                                label: Text(l10n?.addPollOption ?? '+ Добавить вариант', style: TextStyle(fontSize: 13 * scale)),
                                style: TextButton.styleFrom(
                                  foregroundColor: activeBrandColor,
                                  padding: EdgeInsets.symmetric(vertical: 8 * scale, horizontal: 12 * scale),
                                ),
                              ),
                              SizedBox(height: 12),
                              Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: isDark ? Colors.white54 : Colors.black54,
                                ),
                                child: CheckboxListTile(
                                  title: Text(l10n?.allowMultipleAnswers ?? 'Выбор нескольких вариантов', style: TextStyle(fontSize: 13 * scale)),
                                  value: isMultipleChoice,
                                  activeColor: activeBrandColor,
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  onChanged: (val) {
                                    setModalState(() {
                                      isMultipleChoice = val ?? false;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),

                      // Footer Actions
                      Container(
                        padding: EdgeInsets.all(20 * scale),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: borderColor)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: isDark ? Colors.white70 : Colors.black87,
                                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                              ),
                              child: Text((AppLocalizations.of(context)?.otmena_987b ?? 'Fallback'), style: TextStyle(fontSize: 13 * scale)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final question = questionController.text.trim();
                                final lines = optionsControllers
                                    .map((c) => c.text.trim())
                                    .where((l) => l.isNotEmpty)
                                    .toList();
                                if (question.isEmpty || lines.isEmpty) return;

                                Navigator.pop(context);
                                final List<Map<String, String>> optionsList = lines
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
                                _sendCustomMessage(payload);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activeBrandColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 12 * scale),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8 * scale),
                                ),
                              ),
                              child: Text((AppLocalizations.of(context)?.sozdat_b059 ?? 'Fallback'), style: TextStyle(fontSize: 13 * scale, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// CustomPainter для точного центрирования буквы инициала в аватарке.
/// Вычисляет позицию baseline и cap-height глифа, чтобы визуальный
/// центр заглавной буквы совпадал с центром круга.
class _InitialsPainter extends CustomPainter {
  final String initial;
  final Color color;
  final double fontSize;

  const _InitialsPainter({
    required this.initial,
    required this.color,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: initial,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Расстояние от верха textPainter до baseline
    final baseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    // Cap-height ≈ 0.72 * fontSize для Inter (высота заглавных букв от baseline вверх)
    final capHeight = fontSize * 0.72;
    // Верх глифа (от верха textPainter)
    final glyphTop = baseline - capHeight;
    // Визуальный центр буквы (от верха textPainter)
    final glyphVisualCenter = glyphTop + capHeight / 2;

    // Сдвигаем textPainter так, чтобы glyphVisualCenter попал в size.height / 2
    final dy = size.height / 2 - glyphVisualCenter;
    final dx = (size.width - textPainter.width) / 2;
    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_InitialsPainter old) =>
      old.initial != initial || old.color != color || old.fontSize != fontSize;
}

/// Снимок состояния плеера для конкретного ГС — чтобы Selector ребилдил
/// бабл только при значимых изменениях именно его трека.
class _VoicePlaybackState {
  final String? currentAudioUrl;
  final bool isPlaying;
  final bool isInitialized;
  final bool isLoading;
  final Duration position;
  final Duration duration;

  const _VoicePlaybackState({
    required this.currentAudioUrl,
    required this.isPlaying,
    required this.isInitialized,
    required this.isLoading,
    required this.position,
    required this.duration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _VoicePlaybackState &&
          currentAudioUrl == other.currentAudioUrl &&
          isPlaying == other.isPlaying &&
          isInitialized == other.isInitialized &&
          isLoading == other.isLoading &&
          position == other.position &&
          duration == other.duration;

  @override
  int get hashCode =>
      currentAudioUrl.hashCode ^
      isPlaying.hashCode ^
      isInitialized.hashCode ^
      isLoading.hashCode ^
      position.hashCode ^
      duration.hashCode;
}

class _VoiceMessageBubblePlayer extends StatelessWidget {
  final Map<String, dynamic> payload;
  final bool isMe;
  final bool isDark;
  final double scale;
  final String senderName;

  const _VoiceMessageBubblePlayer({
    required this.payload,
    required this.isMe,
    required this.isDark,
    required this.scale,
    required this.senderName,
  });

  /// Абсолютная ссылка на скачивание ГС: host из ApiService.baseUrl
  /// (без суффикса /api/v1) + /api/files/download/<file_id>/.
  String _buildAudioUrl() {
    final fileId = payload['file_id']?.toString() ?? '';
    final uri = Uri.parse(ApiService.baseUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    final host = '${uri.scheme}://${uri.host}$port';
    
    String? fileUrl = payload['file_url']?.toString();
    if (fileUrl != null && fileUrl.trim().isEmpty) fileUrl = null;
    
    final suffix = fileUrl ?? '/api/files/download/$fileId/';
    
    String finalUrl = suffix.startsWith('http') 
        ? suffix 
        : '$host${suffix.startsWith('/') ? '' : '/'}$suffix';
        
    // MPV на Linux не может определить формат файла, если URL не заканчивается на известное расширение.
    // Добавляем фиктивный query параметр с расширением.
    if (!finalUrl.toLowerCase().contains('.wav') && !finalUrl.toLowerCase().contains('.m4a') && !finalUrl.contains('ext=')) {
      final ext = payload['mime_type']?.toString().contains('mp4') == true ? '.m4a' : '.wav';
      finalUrl += finalUrl.contains('?') ? '&ext=$ext' : '?ext=$ext';
    }
    
    return finalUrl;
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final durationSeconds = payload['duration'] is num
        ? (payload['duration'] as num).toInt()
        : (int.tryParse(payload['duration']?.toString() ?? '') ?? 10);
    final fallbackDuration = Duration(seconds: durationSeconds);
    final mimeType = payload['mime_type']?.toString();
    final audioUrl = _buildAudioUrl();

    final activeWaveColor = isMe ? Colors.white : Colors.blue;
    final inactiveWaveColor =
        isMe ? Colors.white30 : (isDark ? Colors.white24 : Colors.black12);

    return Selector<PlaybackProvider, _VoicePlaybackState>(
      selector: (_, provider) => _VoicePlaybackState(
        currentAudioUrl: provider.currentAudioUrl,
        isPlaying: provider.isPlaying,
        isInitialized: provider.isInitialized,
        isLoading: provider.isLoading,
        position: provider.position,
        duration: provider.duration,
      ),
      shouldRebuild: (prev, next) {
        final isCurrent = next.currentAudioUrl == audioUrl;
        final wasCurrent = prev.currentAudioUrl == audioUrl;
        if (!isCurrent && !wasCurrent) return false;
        return prev != next;
      },
      builder: (context, state, child) {
        final isCurrent = state.currentAudioUrl == audioUrl;
        final isPlaying = isCurrent && state.isPlaying;
        final isInitialized = isCurrent && state.isInitialized;
        final isLoading = isCurrent && state.isLoading;

        final position = isCurrent ? state.position : Duration.zero;
        final duration =
            isCurrent && state.isInitialized && state.duration > Duration.zero
                ? state.duration
                : fallbackDuration;

        final displayDuration =
            isPlaying || (isCurrent && position > Duration.zero)
                ? position
                : duration;

        return Container(
          width: 240 * scale,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            children: [
              // Play/Pause button
              GestureDetector(
                onTap: () {
                  if (isLoading) return;
                  context.read<PlaybackProvider>().play(
                        audioUrl,
                        (AppLocalizations.of(context)?.golosovoeSoobschenie_33d5 ?? 'Fallback'),
                        senderName,
                        mimeType: mimeType,
                        duration: fallbackDuration,
                      );
                },
                child: Container(
                  width: 38 * scale,
                  height: 38 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMe
                        ? Colors.white.withOpacity(0.2)
                        : (isDark
                            ? Colors.white12
                            : Colors.black.withOpacity(0.06)),
                  ),
                  child: isLoading
                      ? Padding(
                          padding: EdgeInsets.all(10 * scale),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isMe
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: isMe
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                          size: 24 * scale,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Waveform & Duration Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VoiceWaveformSlider(
                      position: position,
                      duration: duration,
                      isActive: isCurrent && isInitialized,
                      barsCount: 18,
                      activeColor: activeWaveColor,
                      inactiveColor: inactiveWaveColor,
                      onSeek: isCurrent && isInitialized
                          ? (pos) => context.read<PlaybackProvider>().seek(pos)
                          : null,
                      onSeekPreview: isCurrent && isInitialized
                          ? (pos) =>
                              context.read<PlaybackProvider>().seekPreview(pos)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    // Duration text
                    Text(
                      isPlaying || (isCurrent && position > Duration.zero)
                          ? '${_formatDuration(displayDuration)} / ${_formatDuration(duration)}'
                          : 'Голосовое сообщение • ${_formatDuration(duration)}',
                      style: TextStyle(
                        color: isMe
                            ? Colors.white60
                            : (isDark ? Colors.white38 : Colors.black45),
                        fontSize: 11 * scale,
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

class _MusicMessageBubblePlayer extends StatefulWidget {
  final Map<String, dynamic> payload;
  final bool isMe;
  final bool isDark;
  final double scale;
  final VoidCallback? onDownload;

  const _MusicMessageBubblePlayer({
    super.key,
    required this.payload,
    required this.isMe,
    required this.isDark,
    required this.scale,
    this.onDownload,
  });

  @override
  State<_MusicMessageBubblePlayer> createState() => _MusicMessageBubblePlayerState();
}

class _MusicMessageBubblePlayerState extends State<_MusicMessageBubblePlayer> {
  double? _dragValue;

  String _buildAudioUrl() {
    final fileId = widget.payload['file_id']?.toString() ?? '';
    final uri = Uri.parse(ApiService.baseUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    final host = '${uri.scheme}://${uri.host}$port';
    
    String? fileUrl = widget.payload['file_url']?.toString();
    if (fileUrl != null && fileUrl.trim().isEmpty) fileUrl = null;
    
    final suffix = fileUrl ?? '/api/files/download/$fileId/';
    
    String finalUrl = suffix.startsWith('http') 
        ? suffix 
        : '$host${suffix.startsWith('/') ? '' : '/'}$suffix';

    final fileName = (widget.payload['file_name'] ?? widget.payload['name'] ?? '').toString().toLowerCase();
    if (fileName.endsWith('.mp3')) {
      finalUrl += finalUrl.contains('?') ? '&ext=.mp3' : '?ext=.mp3';
    } else if (fileName.endsWith('.flac')) {
      finalUrl += finalUrl.contains('?') ? '&ext=.flac' : '?ext=.flac';
    } else if (fileName.endsWith('.wav')) {
      finalUrl += finalUrl.contains('?') ? '&ext=.wav' : '?ext=.wav';
    } else if (fileName.endsWith('.m4a') || fileName.endsWith('.aac')) {
      finalUrl += finalUrl.contains('?') ? '&ext=.m4a' : '?ext=.m4a';
    }
    
    return finalUrl;
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return (AppLocalizations.of(context)?.loc_0B_5a4d ?? 'Fallback');
    var suffixes = [(AppLocalizations.of(context)?.b_3b67 ?? 'Fallback'), (AppLocalizations.of(context)?.kb_419d ?? 'Fallback'), (AppLocalizations.of(context)?.mb_b808 ?? 'Fallback'), (AppLocalizations.of(context)?.gb_e572 ?? 'Fallback')];
    var i = (log(bytes) / log(1024)).floor();
    if (i >= suffixes.length) i = suffixes.length - 1;
    return ((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.payload;
    final isMe = widget.isMe;
    final isDark = widget.isDark;
    final scale = widget.scale;

    final fileName = payload['file_name']?.toString() ?? payload['name']?.toString() ?? (AppLocalizations.of(context)?.audiozapis_867d ?? 'Fallback');
    final fileSize = payload['file_size'] as int? ?? 0;
    final mimeType = payload['mime_type']?.toString() ?? 'audio/mp3';
    final audioUrl = _buildAudioUrl();

    final rawDuration = payload['duration'];
    final fallbackSeconds = rawDuration is num
        ? rawDuration.toInt()
        : (int.tryParse(rawDuration?.toString() ?? '') ?? 0);
    final fallbackDuration = Duration(seconds: fallbackSeconds);

    return Selector<PlaybackProvider, _VoicePlaybackState>(
      selector: (_, provider) => _VoicePlaybackState(
        currentAudioUrl: provider.currentAudioUrl,
        isPlaying: provider.isPlaying,
        isInitialized: provider.isInitialized,
        isLoading: provider.isLoading,
        position: provider.position,
        duration: provider.duration,
      ),
      shouldRebuild: (prev, next) {
        final isCurrent = next.currentAudioUrl == audioUrl;
        final wasCurrent = prev.currentAudioUrl == audioUrl;
        if (!isCurrent && !wasCurrent) return false;
        return prev != next;
      },
      builder: (context, state, child) {
        final isCurrent = state.currentAudioUrl == audioUrl;
        final isPlaying = isCurrent && state.isPlaying;
        final isLoading = isCurrent && state.isLoading;
        final isInitialized = isCurrent && state.isInitialized;

        final position = isCurrent ? state.position : Duration.zero;
        final totalDuration = isCurrent && state.isInitialized && state.duration > Duration.zero
            ? state.duration
            : fallbackDuration;

        final currentSliderPos = _dragValue ?? (
          totalDuration > Duration.zero
              ? (position.inMilliseconds / totalDuration.inMilliseconds).clamp(0.0, 1.0)
              : 0.0
        );

        final displayPos = _dragValue != null && totalDuration > Duration.zero
            ? Duration(milliseconds: (_dragValue! * totalDuration.inMilliseconds).round())
            : position;

        return Container(
          width: 290 * scale,
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            color: isMe 
                ? Colors.white.withOpacity(0.12)
                : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(
              color: isMe 
                  ? Colors.white.withOpacity(0.2) 
                  : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Play button, Track info, Download button
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isLoading) return;
                      context.read<PlaybackProvider>().play(
                        audioUrl,
                        fileName,
                        _formatBytes(fileSize),
                        mimeType: mimeType,
                        duration: totalDuration > Duration.zero ? totalDuration : null,
                      );
                    },
                    child: Container(
                      width: 42 * scale,
                      height: 42 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isMe ? Colors.white : (isDark ? Colors.blue.shade600 : Colors.blue.shade500),
                        boxShadow: [
                          BoxShadow(
                            color: (isMe ? Colors.black : Colors.blue).withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                                width: 18 * scale,
                                height: 18 * scale,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isMe ? Colors.blue.shade700 : Colors.white,
                                  ),
                                ),
                              )
                            : FaIcon(
                                isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                                color: isMe ? Colors.blue.shade700 : Colors.white,
                                size: 16 * scale,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: TextStyle(
                            color: isMe ? Colors.white : (isDark ? Colors.white.withOpacity(0.95) : Colors.black87),
                            fontSize: 13.5 * scale,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2 * scale),
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.music,
                              size: 10 * scale,
                              color: isMe ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54),
                            ),
                            SizedBox(width: 4 * scale),
                            Text(
                              _formatBytes(fileSize),
                              style: TextStyle(
                                color: isMe ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54),
                                fontSize: 11 * scale,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.onDownload != null) ...[
                    SizedBox(width: 6 * scale),
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.download,
                        color: isMe ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54),
                        size: 14 * scale,
                      ),
                      onPressed: widget.onDownload,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(width: 28 * scale, height: 28 * scale),
                    ),
                  ],
                ],
              ),
              
              SizedBox(height: 8 * scale),

              // Bottom Row: Interactive Slider & Time Display
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4 * scale,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6 * scale),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 14 * scale),
                        activeTrackColor: isMe ? Colors.white : Colors.blue.shade500,
                        inactiveTrackColor: isMe ? Colors.white30 : (isDark ? Colors.white24 : Colors.black12),
                        thumbColor: isMe ? Colors.white : (isDark ? Colors.blue.shade400 : Colors.blue.shade600),
                      ),
                      child: Slider(
                        value: currentSliderPos.clamp(0.0, 1.0),
                        onChanged: (val) {
                          setState(() {
                            _dragValue = val;
                          });
                          if (isInitialized && totalDuration > Duration.zero) {
                            final targetMs = (val * totalDuration.inMilliseconds).round();
                            context.read<PlaybackProvider>().seekPreview(Duration(milliseconds: targetMs));
                          }
                        },
                        onChangeEnd: (val) async {
                          final targetVal = val;
                          setState(() {
                            _dragValue = null;
                          });
                          if (totalDuration > Duration.zero) {
                            final targetMs = (targetVal * totalDuration.inMilliseconds).round();
                            final targetDuration = Duration(milliseconds: targetMs);
                            if (!isInitialized || !isCurrent) {
                              await context.read<PlaybackProvider>().play(
                                audioUrl,
                                fileName,
                                _formatBytes(fileSize),
                                mimeType: mimeType,
                                duration: totalDuration,
                              );
                            }
                            context.read<PlaybackProvider>().seek(targetDuration);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Text(
                    totalDuration > Duration.zero 
                        ? '${_formatDuration(displayPos)} / ${_formatDuration(totalDuration)}'
                        : _formatDuration(displayPos),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54),
                      fontSize: 11 * scale,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
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

class _TypingState {
  final String username;
  final String firstName;
  final String action;
  final DateTime timestamp;

  _TypingState({
    required this.username,
    required this.firstName,
    required this.action,
    required this.timestamp,
  });
}

class NewMessageAnimator extends StatefulWidget {
  final Widget child;
  final bool animate;
  final VoidCallback? onStartAnimating;

  const NewMessageAnimator({
    super.key,
    required this.child,
    required this.animate,
    this.onStartAnimating,
  });

  @override
  State<NewMessageAnimator> createState() => _NewMessageAnimatorState();
}

class _NewMessageAnimatorState extends State<NewMessageAnimator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _sizeAnimation;
  late final Animation<Offset> _slideAnimation;

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

    if (widget.animate) {
      _controller.forward();
      if (widget.onStartAnimating != null) {
        // Run after current frame layout pass is finished to avoid triggering setState warnings
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onStartAnimating!();
        });
      }
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      axisAlignment: 1.0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

class _TopAudioPlaybackBar extends StatefulWidget {
  final PlaybackProvider playback;
  final bool isDark;
  final double scale;
  final VoidCallback? onTapTitle;

  const _TopAudioPlaybackBar({
    required this.playback,
    required this.isDark,
    required this.scale,
    this.onTapTitle,
  });

  @override
  State<_TopAudioPlaybackBar> createState() => _TopAudioPlaybackBarState();
}

class _TopAudioPlaybackBarState extends State<_TopAudioPlaybackBar> {
  double? _dragValue;

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final playback = widget.playback;
    final isDark = widget.isDark;
    final scale = widget.scale;

    final isPlaying = playback.isPlaying;
    final title = playback.title.isEmpty ? (AppLocalizations.of(context)?.golosovoeSoobschenie_33d5 ?? 'Fallback') : playback.title;
    final subtitle = playback.subtitle;
    final position = playback.position;
    final duration = playback.duration;

    final sliderValue = _dragValue ?? (
      duration > Duration.zero 
          ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
          : 0.0
    );

    final displayPos = _dragValue != null && duration > Duration.zero
        ? Duration(milliseconds: (_dragValue! * duration.inMilliseconds).round())
        : position;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 520 * scale),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 8 * scale),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xF01C1C20) : const Color(0xF5FFFFFF),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Controls (Prev, Play/Pause, Next), Title & Subtitle, Time Text, Close button
            Row(
              children: [
                // Previous button
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.backwardStep,
                    color: playback.hasPrevious
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white24 : Colors.black26),
                    size: 12 * scale,
                  ),
                  onPressed: playback.hasPrevious ? () => playback.playPrevious() : null,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(width: 24 * scale, height: 24 * scale),
                ),
                SizedBox(width: 2 * scale),
                // Play / Pause
                GestureDetector(
                  onTap: () {
                    if (isPlaying) {
                      playback.pause();
                    } else {
                      playback.resume();
                    }
                  },
                  child: Container(
                    width: 32 * scale,
                    height: 32 * scale,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.blue.shade600
                          : Colors.blue.shade500,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: FaIcon(
                        isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                        color: Colors.white,
                        size: 13 * scale,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2 * scale),
                // Next button
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.forwardStep,
                    color: playback.hasNext
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white24 : Colors.black26),
                    size: 12 * scale,
                  ),
                  onPressed: playback.hasNext ? () => playback.playNext() : null,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(width: 24 * scale, height: 24 * scale),
                ),
                SizedBox(width: 10 * scale),
                // Track Info - Tapping opens playlist modal
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTapTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          SizedBox(height: 1 * scale),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 11 * scale,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                Text(
                  duration > Duration.zero
                      ? '${_formatDuration(displayPos)} / ${_formatDuration(duration)}'
                      : _formatDuration(displayPos),
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(width: 4 * scale),
                GestureDetector(
                  onTap: () => playback.stop(),
                  child: Padding(
                    padding: EdgeInsets.all(4 * scale),
                    child: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white54 : Colors.black45,
                      size: 18 * scale,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 4 * scale),

            // Row 2: Interactive Slider Progress Bar
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3.5 * scale,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.5 * scale),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 12 * scale),
                activeTrackColor: Colors.blue.shade500,
                inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
                thumbColor: isDark ? Colors.blue.shade400 : Colors.blue.shade600,
              ),
              child: Slider(
                value: sliderValue.clamp(0.0, 1.0),
                onChanged: (val) {
                  setState(() {
                    _dragValue = val;
                  });
                  if (duration > Duration.zero) {
                    final targetMs = (val * duration.inMilliseconds).round();
                    playback.seekPreview(Duration(milliseconds: targetMs));
                  }
                },
                onChangeEnd: (val) {
                  setState(() {
                    _dragValue = null;
                  });
                  if (duration > Duration.zero) {
                    final targetMs = (val * duration.inMilliseconds).round();
                    playback.seek(Duration(milliseconds: targetMs));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlinkingRedDot extends StatefulWidget {
  const _BlinkingRedDot();

  @override
  State<_BlinkingRedDot> createState() => _BlinkingRedDotState();
}

class _BlinkingRedDotState extends State<_BlinkingRedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
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

class _VideoRecordingPreview extends StatefulWidget {
  final double scale;
  final CameraController? cameraController;
  const _VideoRecordingPreview({required this.scale, this.cameraController});

  @override
  State<_VideoRecordingPreview> createState() => _VideoRecordingPreviewState();
}

class _VideoRecordingPreviewState extends State<_VideoRecordingPreview> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Player? _player;
  VideoController? _videoController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    if (Platform.isLinux) {
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 1024 * 1024,
      ),
    );
    _videoController = VideoController(_player!);
    await (_player!.platform as dynamic).setProperty('profile', 'low-latency');
    await (_player!.platform as dynamic).setProperty('untimed', 'yes');
    await (_player!.platform as dynamic).setProperty('cache', 'no');
    await (_player!.platform as dynamic).setProperty('demuxer-lavf-o', 'fflags=nobuffer');
    await (_player!.platform as dynamic).setProperty('cache-pause', 'no');
    await (_player!.platform as dynamic).setProperty('stream-buffer-size', '4k');
    await (_player!.platform as dynamic).setProperty('vd-lavc-threads', '1');
    await (_player!.platform as dynamic).setProperty('load-unsafe-playlists', 'yes');
    await _player!.setVolume(0.0);
    
    _player!.stream.error.listen((e) {
      print('MEDIA_KIT_ERROR: $e');
    });

    try {
      await _player!.open(Media('udp://127.0.loc_0.1:44444'));
      print('MEDIA_KIT: Opened UDP stream');
    } catch (e) {
      print('MEDIA_KIT_OPEN_ERROR: $e');
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = 200 * widget.scale;
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: Container(
          color: Colors.black.withOpacity(0.55),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scaleValue = 1.0 + (_pulseController.value * 0.08);
              return Center(
                child: Container(
                  width: size * scaleValue,
                  height: size * scaleValue,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_videoController != null)
                          SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: 640,
                                height: 480,
                                child: Video(
                                  controller: _videoController!,
                                  controls: (state) => const SizedBox.shrink(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            color: const Color(0xFF1E293B),
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        // REC indicator
                        Positioned(
                          top: 24,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'REC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12 * widget.scale,
                                  shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
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
            },
          ),
        ),
      ),
    );
  }
}

class _VideoMessageMockBubble extends StatefulWidget {
  final Map<String, dynamic> payload;
  final bool isMe;
  final bool isDark;
  final double scale;

  const _VideoMessageMockBubble({
    super.key,
    required this.payload,
    required this.isMe,
    required this.isDark,
    required this.scale,
  });

  @override
  State<_VideoMessageMockBubble> createState() => _VideoMessageMockBubbleState();
}

class _VideoMessageMockBubbleState extends State<_VideoMessageMockBubble> {
  Player? _player;
  VideoController? _videoController;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isMuted = true;
  bool _showMuteIndicator = true;
  bool _isHovered = false;
  Timer? _muteIndicatorTimer;

  Duration _videoPosition = Duration.zero;
  Duration _videoDuration = Duration.zero;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _completedSub;

  String _buildVideoUrl() {
    final fileId = widget.payload['file_id']?.toString() ?? '';
    final uri = Uri.parse(ApiService.baseUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    final host = '${uri.scheme}://${uri.host}$port';
    
    String? fileUrl = widget.payload['file_url']?.toString();
    if (fileUrl != null && fileUrl.trim().isEmpty) fileUrl = null;
    
    final suffix = fileUrl ?? '/api/files/download/$fileId/';
    
    return suffix.startsWith('http') 
        ? suffix 
        : '$host${suffix.startsWith('/') ? '' : '/'}$suffix';
  }

  @override
  void initState() {
    super.initState();
    // Lazy initialize player with a short delay to prevent UI stutters when scrolling fast
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initPlayer();
      }
    });
  }

  Future<void> _initPlayer() async {
    if (_isLoading || _isInitialized) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final videoUrl = _buildVideoUrl();
      final localPath = widget.payload['local_path']?.toString();
      String playUrl;
      if (localPath != null && await File(localPath).exists()) {
        playUrl = localPath;
      } else {
        playUrl = LocalProxy.getProxyUrl(videoUrl, ext: '.mp4');
      }

      final player = Player();
      final controller = VideoController(player);

      if (!mounted) {
        player.dispose();
        return;
      }

      _player = player;
      _videoController = controller;

      // Start muted for autoplay
      await player.setVolume(0.0);
      // Disable infinite loop playback for video notes
      await player.setPlaylistMode(PlaylistMode.none);

      _posSub = player.stream.position.listen((pos) {
        if (mounted) {
          setState(() {
            _videoPosition = pos;
          });
        }
      });

      _durSub = player.stream.duration.listen((dur) {
        if (dur != Duration.zero && mounted) {
          setState(() {
            _videoDuration = dur;
          });
        }
      });

      _playingSub = player.stream.playing.listen((playing) {
        if (mounted) {
          setState(() {
            _isPlaying = playing;
          });
        }
      });

      _completedSub = player.stream.completed.listen((completed) {
        if (completed && mounted) {
          player.pause();
          player.seek(Duration.zero);
          final playback = Provider.of<PlaybackProvider>(context, listen: false);
          if (playback.currentAudioUrl == videoUrl && playback.isVideo) {
            playback.stop();
          }
          setState(() {
            _isPlaying = false;
            _videoPosition = Duration.zero;
          });
        }
      });

      await player.open(Media(playUrl), play: false);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error auto-initializing video message: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final playback = Provider.of<PlaybackProvider>(context);
    final videoUrl = _buildVideoUrl();
    final isCurrent = playback.currentAudioUrl == videoUrl && playback.isVideo;

    if (_isInitialized) {
      if (isCurrent) {
        // Toggle video player state to match playback provider actions from panel
        if (playback.isPlaying && !_isPlaying) {
          _player?.play();
          if (_isMuted) {
            _player?.setVolume(100.0);
            _updateMuteState(false);
          }
        } else if (!playback.isPlaying && _isPlaying) {
          _player?.pause();
        }
      } else {
        // We are not the current active playback.
        // Check if playback is completely stopped (panel closed) or if another media is playing:
        if (playback.currentAudioUrl == null) {
          // Panel closed/stopped -> stop video completely and reset to start
          _stopAndReset();
        } else if (!_isMuted) {
          // Another media is playing -> mute us back to autoplay
          _muteBackToAutoplay();
        }
      }
    }
  }

  Future<void> _stopAndReset() async {
    final player = _player;
    if (player != null && _isInitialized) {
      await player.pause();
      await player.seek(Duration.zero);
      await player.setVolume(0.0);
      _updateMuteState(true);
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _videoPosition = Duration.zero;
        });
      }
    }
  }

  Future<void> _muteBackToAutoplay() async {
    final player = _player;
    if (player != null && _isInitialized) {
      await player.setVolume(0.0);
      _updateMuteState(true);
    }
  }

  void _updateMuteState(bool muted) {
    if (muted) {
      _muteIndicatorTimer?.cancel();
      setState(() {
        _isMuted = true;
        _showMuteIndicator = true;
      });
    } else {
      setState(() {
        _isMuted = false;
        _showMuteIndicator = true;
      });
      _muteIndicatorTimer?.cancel();
      _muteIndicatorTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showMuteIndicator = false;
          });
        }
      });
    }
  }

  Future<void> _handleTap() async {
    final player = _player;
    if (player == null || !_isInitialized) return;

    final playbackProvider = Provider.of<PlaybackProvider>(context, listen: false);
    final videoUrl = _buildVideoUrl();

    if (_isPlaying) {
      if (_isMuted) {
        // Unmute and restart from 0 (Telegram style)
        await playbackProvider.stop(); // Stops any other active audible sounds/voice messages
        await player.setVolume(100.0);
        await player.seek(Duration.zero);
        _updateMuteState(false);

        await playbackProvider.playVideo(
          videoUrl,
          (AppLocalizations.of(context)?.videosoobschenie_2951 ?? 'Fallback'),
          (AppLocalizations.of(context)?.video_a095 ?? 'Fallback'),
          duration: _videoDuration,
        );
      } else {
        // Pause playback
        await player.pause();
        playbackProvider.pause();
      }
    } else {
      // Play unmuted
      await playbackProvider.stop();
      await player.setVolume(100.0);
      await player.play();
      _updateMuteState(false);

      await playbackProvider.playVideo(
        videoUrl,
        (AppLocalizations.of(context)?.videosoobschenie_2951 ?? 'Fallback'),
        (AppLocalizations.of(context)?.video_a095 ?? 'Fallback'),
        duration: _videoDuration,
      );
    }
  }

  @override
  void dispose() {
    _muteIndicatorTimer?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _playingSub?.cancel();
    _completedSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final durationSeconds = widget.payload['duration'] is num
        ? (widget.payload['duration'] as num).toInt()
        : (int.tryParse(widget.payload['duration']?.toString() ?? '') ?? 5);

    final size = 200.0 * widget.scale;

    final totalMs = _videoDuration.inMilliseconds > 0 
        ? _videoDuration.inMilliseconds 
        : (durationSeconds * 1000);
    final double progressVal = totalMs > 0 
        ? (_videoPosition.inMilliseconds / totalMs).clamp(0.0, 1.0) 
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: _handleTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Circular Video Element Container
                Container(
                  width: size,
                  height: size,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Video Player (BoxFit.cover)
                        if (_isInitialized && _videoController != null)
                          Positioned.fill(
                            child: Video(
                              controller: _videoController!,
                              fit: BoxFit.cover,
                              controls: (state) => const SizedBox.shrink(),
                            ),
                          )
                        else
                          // Black placeholder with a silent loader
                          const SizedBox.expand(),

                        // Loader when buffering / loading
                        if (_isLoading)
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),

                        // Play icon when paused (Telegram / Web client style)
                        if (!_isPlaying && !_isLoading)
                          Container(
                            width: 50 * widget.scale,
                            height: 50 * widget.scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.55),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 30 * widget.scale,
                            ),
                          ),

                        // Pause icon when playing and hovered (matching web/Telegram)
                        if (_isPlaying && _isHovered && !_isLoading)
                          Container(
                            width: 50 * widget.scale,
                            height: 50 * widget.scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.55),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.pause_rounded,
                              color: Colors.white,
                              size: 30 * widget.scale,
                            ),
                          ),

                        // Mute/Unmute Indicator Overlay
                        if (_isPlaying && _showMuteIndicator)
                          Positioned(
                            top: 12 * widget.scale,
                            right: 12 * widget.scale,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.4),
                              ),
                              child: Icon(
                                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 14 * widget.scale,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 2. Circular Progress Arc Overlay (painted outside ClipOval to prevent clipping)
                SizedBox(
                  width: size + 4.0,
                  height: size + 4.0,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CircleProgressPainter(
                        progress: progressVal,
                        color: const Color(0xFF3B82F6), // Accent Blue from xaneomain
                        backgroundColor: Colors.white.withOpacity(0.15), // Border ring
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Static duration label below the circle (matching web design)
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _formatDuration(durationSeconds),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background ring
    if (backgroundColor != Colors.transparent) {
      final bgPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, bgPaint);
    }

    if (progress > 0) {
      // Draw progress ring starting from top (-pi / 2)
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.141592653589793 / 2,
        2 * 3.141592653589793 * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}



