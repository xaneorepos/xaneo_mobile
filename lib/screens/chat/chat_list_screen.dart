import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat/chat_model.dart';
import '../../services/api/api_client.dart';
import '../../services/chat/chat_service.dart';
import '../../services/chat/chat_local_repository.dart';
import '../../services/chat/presence_service.dart';
import '../../services/crypto/crypto_service.dart';
import '../../services/chat/group_channel_service.dart';
import '../../styles/app_styles.dart';
import '../../utils/chat_name_localizer.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../widgets/common/create_options_modal.dart';
import 'chat_screen.dart';
import 'archived_chats_screen.dart';
import '../../widgets/common/premium_page_route.dart';
import '../../widgets/common/global_search_modal.dart';
import '../../widgets/common/chat_context_menu.dart';
import 'package:xaneo/l10n/app_localizations.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late final ChatService _chatService;
  late final GroupChannelService _groupChannelService;
  late final LocalChatRepository _localChatRepo;
  bool _isLoadingSync = true;
  bool _isSyncInProgress = false;
  String? _error;
  Timer? _relativeTimeTimer;
  StreamSubscription<Map<String, dynamic>>? _wsEventsSub;
  bool _wasConnected = false;

  late final PresenceService _presenceService;

  // Поиск и Фильтрация
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedCategory =
      'all'; // 'all', 'personal', 'groups', 'channels', 'favorites'
  bool _isSearching = false;

  late final ScrollController _scrollController;
  bool _isArchiveRowVisible = false;
  final ValueNotifier<double> _pullDistanceNotifier =
      ValueNotifier<double>(0.0);
  final Set<String> _animatedChatIds = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Инициализируем сервисы синхронно для работы StreamBuilder в первом кадре
    _localChatRepo = context.read<LocalChatRepository>();
    final apiClient = context.read<ApiClient>();
    _chatService = ChatService(apiClient: apiClient);
    _groupChannelService = GroupChannelService(apiClient: apiClient);
    _presenceService = context.read<PresenceService>();
    _wasConnected = _presenceService.isConnected.value;
    _presenceService.isConnected.addListener(_onWsConnectionChanged);
    _wsEventsSub = _presenceService.events.listen(_handleWsEvent);

    // Запускаем синхронизацию сети после сборки первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncChats();
      _startRelativeTimeTicker();
    });
  }

  void _onScroll() {
    if (!mounted) return;
    final offset = _scrollController.offset;

    // Мгновенно фиксируем появление архива, если оттянули полностью (до упора в -78px)
    if (offset <= -77.5 && !_isArchiveRowVisible) {
      _pullDistanceNotifier.value = 0.0;
      setState(() {
        _isArchiveRowVisible = true;
      });
      _scrollController.jumpTo(0.0);
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
      return;
    }

    // Обновляем расстояние оттягивания БЕЗ вызова setState (0 перерендеров списка!)
    if (offset < 0) {
      _pullDistanceNotifier.value = -offset;
    } else {
      if (_pullDistanceNotifier.value != 0.0) {
        _pullDistanceNotifier.value = 0.0;
      }
    }
  }

  void _onWsConnectionChanged() {
    final isConnected = _presenceService.isConnected.value;
    if (isConnected && !_wasConnected) {
      // Синхронизация при восстановлении соединения (reconnect)
      _syncChats(silent: true);
    }
    _wasConnected = isConnected;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pullDistanceNotifier.dispose();
    _presenceService.isConnected.removeListener(_onWsConnectionChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _wsEventsSub?.cancel();
    _relativeTimeTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncChats(silent: true);
      _startRelativeTimeTicker();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _relativeTimeTimer?.cancel();
    }
  }

  void _startRelativeTimeTicker() {
    _relativeTimeTimer?.cancel();
    _relativeTimeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  /// Фоновая/первичная синхронизация чатов с API -> БД
  Future<void> _syncChats({bool silent = false}) async {
    if (_isSyncInProgress) return;

    if (mounted) {
      setState(() {
        _isSyncInProgress = true;
        if (!silent) {
          _isLoadingSync = true;
          _error = null;
        }
      });
    } else {
      _isSyncInProgress = true;
    }

    try {
      final chats = await _chatService.getChats();
      if (!mounted) return;

      final cryptoService = context.read<CryptoService>();

      final decryptedChats = await Future.wait(
        chats.map((chat) async {
          if (chat.lastMessage != null &&
              (chat.isEncrypted || _looksLikeJsonPayload(chat.lastMessage))) {
            final decrypted = await cryptoService.decryptChatMessage(
              chat.lastMessage!,
              chat.id,
            );
            if (decrypted != null) {
              String? inferredType = chat.lastMessageType;
              if (decrypted.trim().startsWith('{')) {
                try {
                  final parsed = jsonDecode(decrypted);
                  if (parsed is Map) {
                    final pType = parsed['type']?.toString();
                    if (pType == 'todo_list' || pType == 'poll') {
                      inferredType = pType;
                    } else if (pType == 'file' ||
                        pType == 'voice' ||
                        pType == 'video_message') {
                      if (chat.lastMessageType == 'file' ||
                          chat.lastMessageType == 'voice' ||
                          chat.lastMessageType == 'video_message') {
                        inferredType = pType;
                      } else {
                        inferredType = null;
                      }
                    } else {
                      inferredType = pType ?? chat.lastMessageType;
                    }
                  }
                } catch (_) {}
              }
              return ChatModel(
                id: chat.id,
                name: chat.name,
                avatar: chat.avatar,
                avatarGradient: chat.avatarGradient,
                lastMessage: decrypted,
                lastMessageTime: chat.lastMessageTime,
                unreadCount: chat.unreadCount,
                isGroup: chat.isGroup,
                isChannel: chat.isChannel,
                isPersonal: chat.isPersonal,
                isFavorites: chat.isFavorites,
                otherUser: chat.otherUser,
                isEncrypted: false,
                isArchived: chat.isArchived,
                archivedAt: chat.archivedAt,
                lastMessageType: inferredType,
                groupCallsEnabled: chat.groupCallsEnabled,
                raw: chat.raw,
              );
            }
          }
          return chat;
        }),
      );

      // Сохраняем расшифрованные чаты в локальную БД
      await _localChatRepo.syncChatsSnapshot(decryptedChats);

      if (mounted && _isLoadingSync) {
        setState(() {
          _isLoadingSync = false;
        });
      }
    } catch (e) {
      if (!silent && mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingSync = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncInProgress = false;
        });
      } else {
        _isSyncInProgress = false;
      }
    }
  }

  Future<void> _wsQueue = Future.value();

  void _handleWsEvent(Map<String, dynamic> event) {
    _wsQueue = _wsQueue.then((_) => _processWsEvent(event)).catchError((e) {
      debugPrint('💥 [ChatListWS] Error processing queued WS event: $e');
    });
  }

  Future<void> _processWsEvent(Map<String, dynamic> event) async {
    final type = event['type']?.toString();
    if (type == null || type.isEmpty) return;

    switch (type) {
      case 'chat_created':
      case 'new_chat':
      case 'chat_added':
      case 'chat_list_update':
      case 'invited_to_chat':
      case 'user_joined_group':
      case 'user_subscribed_channel':
      case 'group_join_success':
        if (event['encrypted_text'] != null &&
            event['encrypted_text'].toString().isNotEmpty) {
          await _applyEncryptedMessageEvent(event);
        }
        final chatPayload = event['chat'] ??
            event['chat_data'] ??
            (event['id'] != null || event['chat_id'] != null ? event : null);
        if (chatPayload is Map) {
          await _applyChatPreviewUpdate(chatPayload.cast<String, dynamic>());
        } else {
          _syncChats(silent: true);
        }
        break;

      case 'new_message':
      case 'encrypted_message':
      case 'file_message':
      case 'voice_message':
      case 'video_message':
        await _applyEncryptedMessageEvent(event);
        break;

      case 'messages_read':
      case 'read_receipt':
      case 'chat_unread_sync':
      case 'message_read':
        await _applyMessagesReadEvent(event);
        break;

      case 'chat_deleted':
      case 'delete_chat':
      case 'chat_removed':
      case 'user_left_group':
      case 'user_left_channel':
      case 'user_unsubscribed_channel':
      case 'force_disconnect_from_group':
      case 'force_disconnect_from_channel':
        final chatId = event['chat_id']?.toString() ?? event['id']?.toString();
        if (chatId != null && chatId.isNotEmpty) {
          await _localChatRepo.deleteChatByServerId(chatId);
        } else {
          _syncChats(silent: true);
        }
        break;

      case 'chats_reorder_required':
      case 'history_cleared':
      case 'message_deleted':
      case 'message_edited':
        _syncChats(silent: true);
        break;
      default:
        break;
    }
  }

  Future<void> _applyMessagesReadEvent(Map<String, dynamic> event) async {
    final chatId = event['chat_id']?.toString() ?? event['id']?.toString();
    final newUnreadCount = (event['unread_count'] as num?)?.toInt() ?? 0;

    if (chatId != null && chatId.isNotEmpty) {
      final existing = await _localChatRepo.getChatByServerId(chatId);
      if (existing != null) {
        final updated = ChatModel(
          id: existing.id,
          name: existing.name,
          avatar: existing.avatar,
          avatarGradient: existing.avatarGradient,
          lastMessage: existing.lastMessage,
          lastMessageTime: existing.lastMessageTime,
          unreadCount: newUnreadCount,
          isGroup: existing.isGroup,
          isChannel: existing.isChannel,
          isPersonal: existing.isPersonal,
          isFavorites: existing.isFavorites,
          otherUser: existing.otherUser,
          isEncrypted: existing.isEncrypted,
          isArchived: existing.isArchived,
          archivedAt: existing.archivedAt,
          lastMessageType: existing.lastMessageType,
        );
        await _localChatRepo.saveChat(updated);
        return;
      }
    }

    _syncChats(silent: true);
  }

  Future<void> _applyChatPreviewUpdate(Map<String, dynamic> payload) async {
    final chatJson = <String, dynamic>{
      'id': payload['id'] ?? payload['chat_id'],
      'chat_id': payload['chat_id'] ?? payload['id'],
      'title': payload['title'] ??
          payload['name'] ??
          payload['chat_display_name'] ??
          payload['group_name'] ??
          payload['channel_name'],
      'chat_display_name': payload['chat_display_name'] ??
          payload['title'] ??
          payload['name'] ??
          payload['group_name'] ??
          payload['channel_name'],
      'avatar_url': payload['avatar_url'] ?? payload['avatar'],
      'last_message': payload['last_message'],
      'last_message_type':
          payload['last_message_type'] ?? payload['message_type'],
      'last_message_time': payload['last_message_time'],
      'unread_count': payload['unread_count'] ?? 0,
      'is_group': payload['is_group'] ?? payload['is_group_chat'] ?? false,
      'is_channel': payload['is_channel'] ?? false,
      'is_personal': payload['is_personal'] ?? payload['is_direct'] ?? false,
    };

    var incoming = ChatModel.fromJson(chatJson);
    incoming = await _decryptPreviewIfNeeded(incoming);

    final existing = await _localChatRepo.getChatByServerId(incoming.id);
    if (existing != null) {
      final cryptoService = context.read<CryptoService>();
      String? bestLastMessage = incoming.lastMessage;
      String? bestLastMessageType = incoming.lastMessageType;
      final existingMsg = existing.lastMessage;

      final existingIsHumanReadable = existingMsg != null &&
          existingMsg.isNotEmpty &&
          existingMsg !=
              (AppLocalizations.of(context)?.novoeSoobschenie_1d49 ??
                  'Fallback') &&
          existingMsg !=
              (AppLocalizations.of(context)
                      ?.novoeZashifrovannoeSoobschenie_4d30 ??
                  'Fallback') &&
          !_looksLikeJsonPayload(existingMsg) &&
          !cryptoService.isEncryptedMessage(existingMsg);

      if (existingIsHumanReadable &&
          (bestLastMessage == null ||
              bestLastMessage.isEmpty ||
              bestLastMessage ==
                  (AppLocalizations.of(context)?.novoeSoobschenie_1d49 ??
                      'Fallback') ||
              bestLastMessage ==
                  (AppLocalizations.of(context)
                          ?.novoeZashifrovannoeSoobschenie_4d30 ??
                      'Fallback') ||
              cryptoService.isEncryptedMessage(bestLastMessage) ||
              _looksLikeJsonPayload(bestLastMessage))) {
        bestLastMessage = existingMsg;
        bestLastMessageType = existing.lastMessageType;
      }

      int unread = existing.unreadCount;
      if (payload.containsKey('unread_count') &&
          payload['unread_count'] != null) {
        final parsed = (payload['unread_count'] as num).toInt();
        if (parsed > 0) {
          unread = parsed;
        }
      }

      incoming = ChatModel(
        id: incoming.id,
        name: incoming.name.isNotEmpty && incoming.name != 'Unknown'
            ? incoming.name
            : existing.name,
        avatar: incoming.avatar ?? existing.avatar,
        avatarGradient: incoming.avatarGradient ?? existing.avatarGradient,
        lastMessage: bestLastMessage,
        lastMessageTime: incoming.lastMessageTime ?? existing.lastMessageTime,
        unreadCount: unread,
        isGroup: incoming.isGroup || existing.isGroup,
        isChannel: incoming.isChannel || existing.isChannel,
        isPersonal: incoming.isPersonal || existing.isPersonal,
        isFavorites: incoming.isFavorites || existing.isFavorites,
        otherUser: incoming.otherUser ?? existing.otherUser,
        isEncrypted: bestLastMessage != null &&
            cryptoService.isEncryptedMessage(bestLastMessage),
        isArchived: existing.isArchived,
        archivedAt: existing.archivedAt,
        lastMessageType: bestLastMessageType,
      );
    }

    await _localChatRepo.saveChat(incoming);
  }

  final Map<String, String> _lastProcessedMsgIdForChat = {};
  final Map<String, String> _lastProcessedEncryptedTextForChat = {};

  Future<void> _applyEncryptedMessageEvent(Map<String, dynamic> event) async {
    final chatId = event['chat_id']?.toString() ?? event['id']?.toString();
    final encryptedText = event['encrypted_text']?.toString() ??
        event['last_message']?.toString();

    if (chatId == null ||
        chatId.isEmpty ||
        encryptedText == null ||
        encryptedText.isEmpty) {
      return;
    }

    final cryptoService = context.read<CryptoService>();
    var decrypted =
        await cryptoService.decryptChatMessage(encryptedText, chatId);

    // If decryption returned null, attempt a forced key reload and retry decryption
    if (decrypted == null) {
      await cryptoService.ensureKeyForChat(chatId);
      decrypted = await cryptoService.decryptChatMessage(encryptedText, chatId);
    }

    final existing = await _localChatRepo.getChatByServerId(chatId);

    final createdAt = _parseApiDateTime(event['created_at']);
    String? inferredType = inferChatMessageType(
      event,
      fallback: event['message_type']?.toString() ??
          event['last_message_type']?.toString(),
    );
    if (decrypted != null && decrypted.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(decrypted);
        if (parsed is Map) {
          inferredType = inferChatMessageType(
                Map<String, dynamic>.from(parsed),
                fallback: parsed['type']?.toString() ?? inferredType,
              ) ??
              inferredType;
        }
      } catch (_) {}
    }

    final myUserId = context.read<AuthProvider>().user?.id.toString();
    final senderId =
        event['sender_id']?.toString() ?? event['author_id']?.toString();
    final isFromMe =
        senderId != null && myUserId != null && senderId == myUserId;

    final rawId = event['message_id']?.toString() ?? event['id']?.toString();
    final msgId = (rawId != null && rawId != chatId) ? rawId : null;

    final isDuplicateMessage =
        (msgId != null && _lastProcessedMsgIdForChat[chatId] == msgId) ||
            (_lastProcessedEncryptedTextForChat[chatId] == encryptedText);

    if (msgId != null) {
      _lastProcessedMsgIdForChat[chatId] = msgId;
    }
    _lastProcessedEncryptedTextForChat[chatId] = encryptedText;

    int newUnreadCount = 0;
    if (isFromMe) {
      newUnreadCount = 0;
    } else if (isDuplicateMessage) {
      // ИДЕОПОТЕНТНОСТЬ: Не увеличиваем счетчик дважды для одного и того же ID сообщения!
      if (event['unread_count'] != null) {
        final parsedUnread = (event['unread_count'] as num).toInt();
        newUnreadCount =
            parsedUnread > 0 ? parsedUnread : (existing?.unreadCount ?? 1);
      } else {
        newUnreadCount = existing?.unreadCount ?? 1;
      }
    } else if (event['unread_count'] != null) {
      final parsedUnread = (event['unread_count'] as num).toInt();
      newUnreadCount =
          parsedUnread > 0 ? parsedUnread : ((existing?.unreadCount ?? 0) + 1);
    } else {
      newUnreadCount = (existing?.unreadCount ?? 0) + 1;
    }

    String? finalLastMessage = decrypted;
    bool finalIsEncrypted =
        decrypted == null && cryptoService.isEncryptedMessage(encryptedText);

    // Protect existing human-readable text if decryption still failed
    if (decrypted == null &&
        existing != null &&
        existing.lastMessage != null &&
        existing.lastMessage!.isNotEmpty) {
      final existingMsg = existing.lastMessage!;
      if (existingMsg !=
              (AppLocalizations.of(context)?.novoeSoobschenie_1d49 ??
                  'Fallback') &&
          existingMsg !=
              (AppLocalizations.of(context)
                      ?.novoeZashifrovannoeSoobschenie_4d30 ??
                  'Fallback') &&
          !_looksLikeJsonPayload(existingMsg) &&
          !cryptoService.isEncryptedMessage(existingMsg)) {
        finalLastMessage = existingMsg;
        finalIsEncrypted = false;
      }
    }

    if (existing == null) {
      final isPersonal = chatId.startsWith('personal_');
      final isGroup = chatId.startsWith('group_');
      final isChannel = chatId.startsWith('channel_');
      final isFav = chatId.startsWith('favorites_user_');
      final name = event['sender_name']?.toString() ??
          event['chat_name']?.toString() ??
          (AppLocalizations.of(context)?.chat_c52b ?? 'Fallback');

      final newChat = ChatModel(
        id: chatId,
        name: name,
        avatar: event['sender_avatar']?.toString() ??
            event['avatar_url']?.toString(),
        lastMessage: finalLastMessage ?? encryptedText,
        lastMessageTime: createdAt ?? DateTime.now(),
        unreadCount: newUnreadCount,
        isGroup: isGroup,
        isChannel: isChannel,
        isPersonal: isPersonal,
        isFavorites: isFav,
        isEncrypted: finalIsEncrypted,
        lastMessageType: inferredType,
      );

      await _localChatRepo.saveChat(newChat);
      _syncChats(silent: true);
      return;
    }

    final updated = ChatModel(
      id: existing.id,
      name: existing.name,
      avatar: existing.avatar,
      avatarGradient: existing.avatarGradient,
      lastMessage: finalLastMessage ?? encryptedText,
      lastMessageTime: createdAt ?? existing.lastMessageTime,
      unreadCount: newUnreadCount,
      isGroup: existing.isGroup,
      isChannel: existing.isChannel,
      isPersonal: existing.isPersonal,
      isFavorites: existing.isFavorites,
      otherUser: existing.otherUser,
      isEncrypted: finalIsEncrypted,
      isArchived: existing.isArchived,
      archivedAt: existing.archivedAt,
      lastMessageType: inferredType,
    );

    await _localChatRepo.saveChat(updated);
  }

  Future<ChatModel> _decryptPreviewIfNeeded(ChatModel chat) async {
    final message = chat.lastMessage;
    if (message == null || message.isEmpty) return chat;

    final cryptoService = context.read<CryptoService>();
    final shouldDecrypt = chat.isEncrypted ||
        _looksLikeJsonPayload(message) ||
        cryptoService.isEncryptedMessage(message);

    if (!shouldDecrypt) return chat;

    final decrypted = await cryptoService.decryptChatMessage(message, chat.id);
    if (decrypted == null) return chat;

    String? inferredType = chat.lastMessageType;
    if (decrypted.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(decrypted);
        if (parsed is Map) {
          inferredType = parsed['type']?.toString() ?? inferredType;
        }
      } catch (_) {}
    }

    return ChatModel(
      id: chat.id,
      name: chat.name,
      avatar: chat.avatar,
      avatarGradient: chat.avatarGradient,
      lastMessage: decrypted,
      lastMessageTime: chat.lastMessageTime,
      unreadCount: chat.unreadCount,
      isGroup: chat.isGroup,
      isChannel: chat.isChannel,
      isPersonal: chat.isPersonal,
      isFavorites: chat.isFavorites,
      otherUser: chat.otherUser,
      isEncrypted: false,
      isArchived: chat.isArchived,
      archivedAt: chat.archivedAt,
      lastMessageType: inferredType,
    );
  }

  DateTime? _parseApiDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value.isUtc ? value.toLocal() : value;
    }

    if (value is int) {
      final isMilliseconds = value > 100000000000;
      return isMilliseconds
          ? DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal()
          : DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true)
              .toLocal();
    }

    if (value is double) {
      return _parseApiDateTime(value.toInt());
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;

      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return parsed.isUtc ? parsed.toLocal() : parsed;
      }

      final asInt = int.tryParse(trimmed);
      if (asInt != null) {
        return _parseApiDateTime(asInt);
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<ChatModel>>(
      stream: _localChatRepo.watchArchivedChats(),
      builder: (context, archivedSnapshot) {
        final archivedChats = archivedSnapshot.data ?? [];
        final showArchiveRow = archivedChats.isNotEmpty &&
            _searchQuery.isEmpty &&
            _selectedCategory == 'all';
        final topOffset = MediaQuery.of(context).padding.top + 122.0;

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
            children: [
              // 1. Список чатов (в фоне, скроллится под хедер)
              Positioned.fill(
                child: _buildContent(archivedChats, showArchiveRow, topOffset),
              ),

              // 2. Floating Archive Row when pulling (изолированный перерендер только для анимации оттягивания)
              ValueListenableBuilder<double>(
                valueListenable: _pullDistanceNotifier,
                builder: (context, pullDistance, _) {
                  if (!showArchiveRow ||
                      _isArchiveRowVisible ||
                      pullDistance <= 0.0) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    top: topOffset + pullDistance - 78.0,
                    left: 0,
                    right: 0,
                    height: 78.0,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 77.0,
                            child: _buildArchiveRow(archivedChats),
                          ),
                          Divider(
                            color: context.xaneoOverlay(0.04),
                            height: 1,
                            indent: 84,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 3. Pinned Glass Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildPinnedGlassHeader(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinnedGlassHeader() {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: context.isDarkTheme
              ? const Color(0xF2121218)
              : const Color(0xF2F7F7F8),
          border: Border(
            bottom: BorderSide(
              color: context.xaneoDivider,
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.only(
          top: statusBarHeight + 14,
          bottom: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Строка заголовка и поиска
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 44,
                child: _buildHeaderContent(),
              ),
            ),
            const SizedBox(height: 14),
            // Фильтры категорий
            _buildCategoryFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Обычный заголовок
        AnimatedOpacity(
          opacity: _isSearching ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: IgnorePointer(
            ignoring: _isSearching,
            child: Row(
              children: [
                _buildTitleText(),
                const Spacer(),
                _buildHeaderButton(
                  child: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: context.xaneoTextPrimary,
                    size: 14,
                  ),
                  onTap: () {
                    GlobalSearchModal.show(
                      context: context,
                      chatService: _chatService,
                      localChatRepo: _localChatRepo,
                      authProvider: context.read<AuthProvider>(),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  child: FaIcon(
                    FontAwesomeIcons.plus,
                    color: context.xaneoTextPrimary,
                    size: 15,
                  ),
                  onTap: () {
                    CreateOptionsModal.show(
                      context: context,
                      chatService: _chatService,
                      groupChannelService: _groupChannelService,
                      localChatRepo: _localChatRepo,
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Поисковая строка, выдвигающаяся справа
        AnimatedPositioned(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          left: _isSearching ? 0 : MediaQuery.of(context).size.width - 40,
          right: 0,
          top: 0,
          bottom: 0,
          child: AnimatedOpacity(
            opacity: _isSearching ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: IgnorePointer(
              ignoring: !_isSearching,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.xaneoOverlay(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: context.xaneoDivider,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: FaIcon(
                              FontAwesomeIcons.magnifyingGlass,
                              color: context.xaneoTextMuted,
                              size: 14,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: TextStyle(
                                color: context.xaneoTextPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              cursorColor: context.xaneoTextPrimary,
                              decoration: InputDecoration(
                                hintText: (AppLocalizations.of(context)
                                        ?.poiskChatov_779c ??
                                    'Fallback'),
                                hintStyle: TextStyle(
                                  color: context.xaneoTextMuted,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 11),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.clear_rounded,
                                  color: context.xaneoTextMuted, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderButton(
                    child: Icon(Icons.close_rounded,
                        color: context.xaneoTextPrimary, size: 20),
                    onTap: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                      setState(() {
                        _searchQuery = '';
                        _isSearching = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.xaneoOverlay(0.05),
        border: Border.all(
          color: context.xaneoDivider,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          splashColor: context.xaneoOverlay(0.08),
          highlightColor: context.xaneoOverlay(0.04),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildTitleText() {
    String title = (AppLocalizations.of(context)?.chaty_19ad ?? 'Fallback');
    Color textColor = context.xaneoTextPrimary;

    if (_isSyncInProgress) {
      title = (AppLocalizations.of(context)?.obnovlenie_53e2 ?? 'Fallback');
      textColor = context.xaneoTextSecondary;
    } else if (!_presenceService.isConnected.value) {
      title = (AppLocalizations.of(context)?.soedinenie_5a58 ?? 'Fallback');
      textColor = context.xaneoTextSecondary;
    }

    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: Text(
        title,
        key: ValueKey<String>(title),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: AppStyles.fontFamily,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      {
        'id': 'all',
        'label': (AppLocalizations.of(context)?.vse_984b ?? 'Fallback')
      },
      {
        'id': 'personal',
        'label': (AppLocalizations.of(context)?.lichnye_4cb3 ?? 'Fallback')
      },
      {
        'id': 'groups',
        'label': (AppLocalizations.of(context)?.gruppy_ebc4 ?? 'Fallback')
      },
      {
        'id': 'channels',
        'label': (AppLocalizations.of(context)?.kanaly_0c11 ?? 'Fallback')
      },
      {
        'id': 'favorites',
        'label': (AppLocalizations.of(context)?.izbrannoe_2fc4 ?? 'Fallback')
      },
    ];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['id'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat['id']!;
              });
            },
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.xaneoTextPrimary
                    : context.xaneoOverlay(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? context.xaneoTextPrimary
                      : context.xaneoDivider,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).scaffoldBackgroundColor
                        : context.xaneoTextSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _archiveChat(ChatModel chat) async {
    // 1. Оптимистичное локальное обновление UI
    await _localChatRepo.updateArchiveStatus(chat.id, true);
    await _localChatRepo.updateChatSettings(
      chat.id,
      isPinned: false,
      isMuted: true,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppLocalizations.of(context)?.toArchive ?? 'Archive'}: "${chat.name}"'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.xaneoSurfaceElevated,
          action: SnackBarAction(
            label: (AppLocalizations.of(context)?.otmena_987b ?? 'Fallback'),
            textColor: context.xaneoTextPrimary,
            onPressed: () async {
              await _localChatRepo.updateArchiveStatus(chat.id, false);
              await _chatService.archiveChat(chat.id, false);
            },
          ),
        ),
      );
    }

    // 2. Отправка запроса на сервер
    final success = await _chatService.archiveChat(chat.id, true);
    if (!success) {
      await _localChatRepo.updateArchiveStatus(chat.id, false);
      await _localChatRepo.updateChatSettings(
        chat.id,
        isPinned: chat.isPinned,
        isMuted: chat.isMuted,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                (AppLocalizations.of(context)?.neUdalosArhivirovatChatNa_36aa ??
                    'Fallback')),
            backgroundColor: AppStyles.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _showChatContextMenu(ChatModel chat) async {
    HapticFeedback.selectionClick();
    final action = await ChatContextMenu.show(
      context: context,
      isPinned: chat.isPinned,
      isArchived: chat.isArchived,
      isMuted: chat.isMuted,
      canDelete: !chat.isFavorites,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case ChatContextAction.pin:
        await _setPinned(chat, !chat.isPinned);
      case ChatContextAction.archive:
        await _archiveChat(chat);
      case ChatContextAction.mute:
        await _setMuted(chat, !chat.isMuted);
      case ChatContextAction.clearHistory:
        await _confirmClearHistory(chat);
      case ChatContextAction.delete:
        await _confirmDeleteChat(chat);
    }
  }

  Future<void> _setPinned(ChatModel chat, bool isPinned) async {
    final success = await _chatService.pinChat(chat.id, isPinned);
    if (success) {
      await _localChatRepo.updateChatSettings(chat.id, isPinned: isPinned);
      return;
    }
    _showChatActionError();
  }

  Future<void> _setMuted(ChatModel chat, bool isMuted) async {
    final success = await _chatService.muteChat(chat.id, isMuted);
    if (success) {
      await _localChatRepo.updateChatSettings(chat.id, isMuted: isMuted);
      return;
    }
    _showChatActionError();
  }

  String _chatType(ChatModel chat) {
    if (chat.isFavorites) return 'favorites';
    if (chat.isChannel) return 'channel';
    if (chat.isGroup) return 'group';
    return 'personal';
  }

  String _chatIdForDestructiveApi(ChatModel chat) {
    if (chat.id != 'favorites') return chat.id;
    final userId = context.read<AuthProvider>().user?.id;
    return userId == null ? chat.id : 'favorites_user_$userId';
  }

  Future<void> _confirmClearHistory(ChatModel chat) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ChatActionConfirmationModal.confirm(
      context: context,
      title: l10n.clearHistory,
      message: '${l10n.clearHistory}: "${localizedChatName(context, chat)}"?',
      confirmLabel: l10n.clearHistory,
    );
    if (!confirmed || !mounted) return;

    final success = await _chatService.clearChatHistory(
      _chatIdForDestructiveApi(chat),
      _chatType(chat),
    );
    if (!success) {
      _showChatActionError();
      return;
    }
    await _localChatRepo.clearHistoryByServerChatId(chat.id);
  }

  Future<void> _confirmDeleteChat(ChatModel chat) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ChatActionConfirmationModal.confirm(
      context: context,
      title: l10n.deleteChat,
      message: '${l10n.deleteChat}: "${localizedChatName(context, chat)}". '
          '${l10n.irreversibleAction}.',
      confirmLabel: l10n.delete,
    );
    if (!confirmed || !mounted) return;

    final success = await _chatService.deleteChat(chat.id);
    if (!success) {
      _showChatActionError();
      return;
    }
    await _localChatRepo.deleteChatByServerId(chat.id);
    await _syncChats(silent: true);
  }

  void _showChatActionError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.serverError),
        backgroundColor: AppStyles.errorColor,
      ),
    );
  }

  Widget _buildArchiveRow(List<ChatModel> archivedChats) {
    final totalUnread =
        archivedChats.fold<int>(0, (sum, chat) => sum + chat.unreadCount);

    // Формируем красивое превью имен чатов в архиве
    final names = archivedChats.take(3).map((c) => c.name).join(', ');
    final previewText = archivedChats.length > 3
        ? '$names • +${archivedChats.length - 3}'
        : names;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PremiumPageRoute(
              page: const ArchivedChatsScreen(),
              transitionType: PremiumTransitionType.archivedReveal,
            ),
          );
        },
        splashColor: context.xaneoOverlay(0.03),
        highlightColor: context.xaneoOverlay(0.01),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: IgnorePointer(
            child: Row(
              children: [
                // Аватар архива с градиентом и иконкой
                AvatarWidget(
                  avatar: null,
                  avatarGradient: '6366F1,4F46E5', // Indigo-Violet gradient
                  hasAvatar: false,
                  username:
                      (AppLocalizations.of(context)?.arhiv_56aa ?? 'Fallback'),
                  size: 50,
                  icon: FontAwesomeIcons.boxArchive,
                ),
                SizedBox(width: 14),

                // Информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (AppLocalizations.of(context)
                                ?.arhivirovannyeChaty_d990 ??
                            'Fallback'),
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: context.xaneoTextPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        previewText.isNotEmpty
                            ? previewText
                            : (AppLocalizations.of(context)?.arhiv_56aa ??
                                'Fallback'),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: context.xaneoTextMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Счётчик непрочитанных в архиве
                if (totalUnread > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFF6366F1), // Indigo color for archive badge
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      totalUnread > 99 ? '99+' : totalUnread.toString(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: context.xaneoTextMuted,
                    size: 14,
                  ),
              ],
            ),
          ), // Close IgnorePointer
        ),
      ),
    );
  }

  Widget _buildContent(
      List<ChatModel> archivedChats, bool showArchiveRow, double topOffset) {
    return RepaintBoundary(
      child: StreamBuilder<List<ChatModel>>(
        stream: _localChatRepo.watchAllChats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData && _isLoadingSync) {
            return Padding(
              padding: EdgeInsets.only(top: topOffset),
              child: Center(
                child: CircularProgressIndicator(
                  color: context.xaneoTextPrimary,
                ),
              ),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty && _error != null) {
            return Padding(
              padding: EdgeInsets.only(top: topOffset),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.circleExclamation,
                      size: 50,
                      color: AppStyles.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      (AppLocalizations.of(context)
                              ?.oshibkaZagruzkiChatov_902f ??
                          'Fallback'),
                      style: AppStyles.titleLarge.copyWith(
                        color: context.xaneoTextMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _syncChats,
                      child: Text(
                          (AppLocalizations.of(context)?.povtorit_b914 ??
                              'Fallback')),
                    ),
                  ],
                ),
              ),
            );
          }

          final List<ChatModel> filteredChats = [];
          final String query = _searchQuery.trim().toLowerCase();
          final bool hasQuery = query.isNotEmpty;

          for (final c in chats) {
            // 1. Фильтрация по категории
            if (_selectedCategory == 'personal') {
              if (!c.isPersonal || c.isFavorites) continue;
            } else if (_selectedCategory == 'groups') {
              if (!c.isGroup) continue;
            } else if (_selectedCategory == 'channels') {
              if (!c.isChannel) continue;
            } else if (_selectedCategory == 'favorites') {
              if (!c.isFavorites &&
                  c.id != 'favorites' &&
                  c.name !=
                      (AppLocalizations.of(context)?.izbrannoe_2fc4 ??
                          'Fallback')) continue;
            }

            // 2. Фильтрация по поиску
            if (hasQuery) {
              final nameMatch = c.name.toLowerCase().contains(query);
              final msgMatch =
                  c.lastMessage?.toLowerCase().contains(query) ?? false;
              if (!nameMatch && !msgMatch) continue;
            }

            filteredChats.add(c);
          }

          if (filteredChats.isEmpty && !showArchiveRow) {
            return Padding(
              padding: EdgeInsets.only(top: topOffset),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.message,
                      size: 50,
                      color: context.xaneoTextMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? (AppLocalizations.of(context)
                                  ?.nichegoNeNaydeno_8767 ??
                              'Fallback')
                          : (AppLocalizations.of(context)?.netChatov_85e3 ??
                              'Fallback'),
                      style: AppStyles.titleLarge.copyWith(
                        color: context.xaneoTextMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty
                          ? (AppLocalizations.of(context)
                                  ?.poprobuyteIzmenitZapros_52ea ??
                              'Fallback')
                          : (AppLocalizations.of(context)
                                  ?.nachniteNovyyRazgovor_8290 ??
                              'Fallback'),
                      style: AppStyles.bodyMedium.copyWith(
                        color: context.xaneoTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Избранное подтягиваем наверх, сохраняя порядок SQL (сортировка по времени последнего сообщения)
          final List<ChatModel> sortedChats = [];
          final List<ChatModel> pinnedChats = [];
          final List<ChatModel> regularChats = [];
          for (final c in filteredChats) {
            if (c.isFavorites ||
                c.id == 'favorites' ||
                c.name ==
                    (AppLocalizations.of(context)?.izbrannoe_2fc4 ??
                        'Fallback')) {
              sortedChats.add(c);
            } else if (c.isPinned) {
              pinnedChats.add(c);
            } else {
              regularChats.add(c);
            }
          }
          sortedChats.addAll(pinnedChats);
          sortedChats.addAll(regularChats);

          final listLength = sortedChats.length +
              (showArchiveRow && _isArchiveRowVisible ? 1 : 0);

          return RefreshIndicator(
            onRefresh: _syncChats,
            edgeOffset: topOffset - 24.0,
            color: context.xaneoTextPrimary,
            backgroundColor: AppStyles.inputBackgroundColor,
            notificationPredicate: (notification) {
              final hasArchivedChats = archivedChats.isNotEmpty;
              if (hasArchivedChats && !_isArchiveRowVisible) {
                return false;
              }
              return notification.depth == 0;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification) {
                  final offset = _scrollController.offset;
                  if (offset < -70.0 && !_isArchiveRowVisible) {
                    setState(() {
                      _isArchiveRowVisible = true;
                    });
                    _scrollController.jumpTo(0.0);
                  }
                }
                return false;
              },
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  physics: ArchiveRevealScrollPhysics(
                    isArchiveVisible: _isArchiveRowVisible,
                    parent: const AlwaysScrollableScrollPhysics(),
                  ),
                  itemExtent: 79.0, // Fixed height for O(1) layout
                  padding: EdgeInsets.only(
                    top: topOffset,
                    bottom: 100, // Отступ под нижнюю панель навигации
                  ),
                  itemCount: listLength,
                  itemBuilder: (context, index) {
                    if (showArchiveRow && _isArchiveRowVisible) {
                      if (index == 0) {
                        return SizedBox(
                          height: 78.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 77.0,
                                child: _buildArchiveRow(archivedChats),
                              ),
                              Divider(
                                color: context.xaneoOverlay(0.04),
                                height: 1,
                                indent: 84,
                              ),
                            ],
                          ),
                        );
                      }
                      return _buildChatItem(sortedChats[index - 1]);
                    }
                    return _buildChatItem(sortedChats[index]);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatItem(ChatModel chat) {
    final alreadyAnimated = _animatedChatIds.contains(chat.id);
    if (!alreadyAnimated) {
      _animatedChatIds.add(chat.id);
    }

    final itemContent = Column(
      children: [
        _buildChatItemContent(chat),
        Divider(
          color: context.xaneoOverlay(0.04),
          height: 1,
          indent: 84,
        ),
      ],
    );

    final skipAnimation = alreadyAnimated || _isArchiveRowVisible;

    return Dismissible(
      key: ValueKey('active_${chat.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _archiveChat(chat),
      background: Container(
        color: Color(0xFF6366F1), // Indigo/Premium violet-blue
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              (AppLocalizations.of(context)?.vArhiv_ce22 ?? 'Fallback'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            FaIcon(
              FontAwesomeIcons.boxArchive,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
      child: skipAnimation
          ? itemContent
          : TweenAnimationBuilder<double>(
              key: ValueKey(chat.id),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1.0 - value)),
                    child: child,
                  ),
                );
              },
              child: itemContent,
            ),
    );
  }

  Widget _buildChatItemContent(ChatModel chat) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            PremiumPageRoute(
              page: ChatScreen(chat: chat),
              transitionType: PremiumTransitionType.chatReveal,
              settings: RouteSettings(name: 'chat_${chat.id}'),
            ),
          );
          if (mounted) {
            _syncChats(silent: true);
          }
        },
        onLongPress: () => _showChatContextMenu(chat),
        splashColor: context.xaneoOverlay(0.03),
        highlightColor: context.xaneoOverlay(0.01),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: IgnorePointer(
            child: Row(
              children: [
                // Аватар со статусом присутствия
                _buildAvatarWithPresence(chat),
                const SizedBox(width: 14),

                // Информация о чате
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Иконка для группы/канала/избранного
                          if (chat.isFavorites) ...[
                            FaIcon(
                              FontAwesomeIcons.solidBookmark,
                              size: 11,
                              color: context.xaneoTextMuted,
                            ),
                            const SizedBox(width: 5),
                          ] else if (chat.isGroup) ...[
                            FaIcon(
                              FontAwesomeIcons.users,
                              size: 11,
                              color: context.xaneoTextMuted,
                            ),
                            const SizedBox(width: 5),
                          ] else if (chat.isChannel) ...[
                            FaIcon(
                              FontAwesomeIcons.bullhorn,
                              size: 11,
                              color: context.xaneoTextMuted,
                            ),
                            const SizedBox(width: 5),
                          ] else if (chat.isPersonal) ...[
                            FaIcon(
                              FontAwesomeIcons.shieldHalved,
                              size: 11,
                              color: context.xaneoTextMuted,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Expanded(
                            child: Text(
                              localizedChatName(context, chat),
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: chat.unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: context.xaneoTextPrimary,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat.isPinned) ...[
                            const SizedBox(width: 6),
                            FaIcon(
                              FontAwesomeIcons.thumbtack,
                              size: 10,
                              color: context.xaneoTextMuted,
                            ),
                          ],
                          if (chat.isMuted) ...[
                            const SizedBox(width: 6),
                            FaIcon(
                              FontAwesomeIcons.bellSlash,
                              size: 10,
                              color: context.xaneoTextMuted,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildMessageText(chat),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Время и счётчик непрочитанных
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (chat.lastMessageTime != null)
                      Text(
                        chat.formattedTime,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: chat.unreadCount > 0
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: chat.unreadCount > 0
                              ? context.xaneoTextPrimary
                              : context.xaneoTextMuted,
                        ),
                      ),
                    if (chat.unreadCount > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        decoration: BoxDecoration(
                          color: context.xaneoTextPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          chat.unreadCount > 99
                              ? '99+'
                              : chat.unreadCount.toString(),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 28),
                    ],
                  ],
                ),
              ],
            ),
          ), // Close IgnorePointer
        ),
      ),
    );
  }

  Widget _buildAvatarWithPresence(ChatModel chat) {
    final isOnline = chat.isPersonal &&
        chat.otherUser != null &&
        (chat.otherUser!['is_online'] == true ||
            chat.otherUser!['online'] == true);

    return Stack(
      children: [
        _buildAvatar(chat),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF4ADE80), // Премиальный зеленый цвет
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors
                      .black, // Рамка под цвет фона, чтобы индикатор выделялся
                  width: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(ChatModel chat) {
    // Определяем - есть ли реальный аватар
    final hasRealAvatar = chat.avatar != null && chat.avatar!.isNotEmpty;

    // Для Избранного показываем иконку закладки (bookmark)
    final icon = chat.isFavorites ? FontAwesomeIcons.solidBookmark : null;

    // Используем AvatarWidget
    return AvatarWidget(
      avatar: chat.avatar,
      avatarGradient: chat.avatarGradient,
      hasAvatar: hasRealAvatar,
      username: localizedChatName(context, chat),
      size: 50,
      icon: icon,
    );
  }

  Widget _buildMessageText(ChatModel chat) {
    final preview = _localizedChatPreview(chat);
    // Сообщение считается зашифрованным для отображения замка, если:
    // 1. Оно помечено как зашифрованное
    // 2. И отображаемый текст это действительно "Зашифрованное сообщение"
    //    (а не конкретный тип вроде "📊 Опрос" или "✅ Список задач")
    final isEncrypted = chat.isEncryptedMessage &&
        preview ==
            (AppLocalizations.of(context)?.zashifrovannoeSoobschenie_c9ab ??
                'Fallback');

    return Row(
      children: [
        if (isEncrypted) ...[
          FaIcon(
            FontAwesomeIcons.lock,
            size: 10,
            color: context.xaneoTextMuted,
          ),
          const SizedBox(width: 5),
        ],
        Expanded(
          child: Text(
            preview,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight:
                  chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
              color: chat.unreadCount > 0
                  ? context.xaneoTextSecondary
                  : context.xaneoTextMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _localizedChatPreview(ChatModel chat) {
    final l10n = AppLocalizations.of(context);
    final raw = chat.lastMessage?.trim() ?? '';
    var type = chat.lastMessageType?.trim().toLowerCase();
    Map<dynamic, dynamic>? payload;

    if (raw.startsWith('{') && raw.endsWith('}')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          payload = decoded;
          type = decoded['message_type']?.toString().toLowerCase() ??
              decoded['type']?.toString().toLowerCase() ??
              type;
        }
      } catch (_) {}
    }

    final payloadType = payload?['type']?.toString().toLowerCase();
    final effectiveType = payloadType ?? type;
    final mimeType = (payload?['mime_type'] ?? payload?['file_type'] ?? '')
        .toString()
        .toLowerCase();
    final fileName = (payload?['file_name'] ?? payload?['name'] ?? '')
        .toString()
        .toLowerCase();

    bool hasExtension(Iterable<String> extensions) =>
        extensions.any(fileName.endsWith);

    final isImage = effectiveType == 'image' ||
        effectiveType == 'photo' ||
        effectiveType == 'collage' ||
        mimeType.startsWith('image/') ||
        hasExtension(const [
          '.jpg',
          '.jpeg',
          '.png',
          '.gif',
          '.webp',
          '.bmp',
          '.svg',
        ]);
    final isVideoFile = effectiveType == 'video' ||
        mimeType.startsWith('video/') ||
        hasExtension(const [
          '.mp4',
          '.mov',
          '.avi',
          '.mkv',
          '.webm',
          '.m4v',
          '.3gp',
        ]);

    final isAudioMusic = effectiveType == 'audio' ||
        effectiveType == 'music' ||
        mimeType.startsWith('audio/') ||
        hasExtension(const [
          '.mp3',
          '.wav',
          '.ogg',
          '.m4a',
          '.flac',
          '.aac',
          '.wma',
          '.opus',
          '.aiff',
          '.alac',
        ]);

    switch (effectiveType) {
      case 'voice':
      case 'voice_message':
        return l10n?.golosovoeSoobschenie_4a85 ?? '🎤 Голосовое сообщение';
      case 'video_message':
        return l10n?.videosoobschenie_d687 ?? '🎬 Видеосообщение';
      case 'todo_list':
        return l10n?.spisokZadach_cfa4 ?? '📋 Список задач';
      case 'poll':
        return l10n?.opros_5902 ?? '📊 Опрос';
      case 'call':
        return l10n?.zvonok_e8d5 ?? '📞 Звонок';
      case 'image':
      case 'photo':
      case 'collage':
        return l10n?.fotografiya_5709 ?? '📷 Фотография';
      case 'video':
        return l10n?.videosoobschenie_57f1 ?? '📹 Видеосообщение';
      case 'audio':
      case 'music':
        return '🎵 ${l10n?.muzyka_0660 ?? 'Музыка'}';
      case 'file':
      case 'document':
      case 'attachment':
        if (isImage) {
          return l10n?.fotografiya_5709 ?? '📷 Фотография';
        }
        if (isVideoFile) {
          return l10n?.videosoobschenie_57f1 ?? '📹 Видеосообщение';
        }
        if (isAudioMusic) {
          return '🎵 ${l10n?.muzyka_0660 ?? 'Музыка'}';
        }
        return l10n?.fayl_826d ?? '📎 Файл';
    }

    // Сервер иногда отдаёт file без type, но с MIME/именем.
    if (isImage) {
      return l10n?.fotografiya_5709 ?? '📷 Фотография';
    }
    if (isVideoFile) {
      return l10n?.videosoobschenie_57f1 ?? '📹 Видеосообщение';
    }
    if (isAudioMusic) {
      return '🎵 ${l10n?.muzyka_0660 ?? 'Музыка'}';
    }

    return _stripPreviewFormatting(chat.displayMessage);
  }

  String _stripPreviewFormatting(String text) {
    var result = text.replaceAll(RegExp(r'[\r\n]+'), ' ');

    // Markdown-ссылки и HTML-теги в однострочном preview не нужны.
    result = result.replaceAllMapped(
      RegExp(r'!?\[([^\]]+)\]\([^\)]+\)'),
      (match) => match.group(1) ?? '',
    );
    result = result.replaceAll(RegExp(r'<[^>]+>'), '');

    for (final marker in <RegExp>[
      RegExp(r'\*\*([^\n]*?)\*\*'),
      RegExp(r'__([^\n]*?)__'),
      RegExp(r'~~([^\n]*?)~~'),
      RegExp(r'`{1,3}([^\n]*?)`{1,3}'),
      RegExp(r'\*([^\n*]+?)\*'),
      RegExp(r'_([^\n_]+?)_'),
    ]) {
      result = result.replaceAllMapped(marker, (match) => match.group(1) ?? '');
    }

    // Поддержка старого варианта /italic/; URL и пути не затрагиваются.
    result = result.replaceAllMapped(
      RegExp(r'(^|\s)/([^/\n]+?)/(\s|$)'),
      (match) =>
          '${match.group(1) ?? ''}${match.group(2) ?? ''}${match.group(3) ?? ''}',
    );

    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _looksLikeJsonPayload(String? message) {
    if (message == null || message.isEmpty) return false;
    final trimmed = message.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) return true;
    final hasNonce = RegExp(r'nonce\s*[:=]').hasMatch(trimmed);
    final hasCipher =
        RegExp(r'ciphertext\s*[:=]|encrypted_data\s*[:=]').hasMatch(trimmed);
    return hasNonce && hasCipher;
  }
}

class ArchiveRevealScrollPhysics extends BouncingScrollPhysics {
  final bool isArchiveVisible;
  const ArchiveRevealScrollPhysics({
    required this.isArchiveVisible,
    super.parent,
  });

  @override
  ArchiveRevealScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ArchiveRevealScrollPhysics(
      isArchiveVisible: isArchiveVisible,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (!isArchiveVisible && value < -78.0) {
      if (position.pixels >= -78.0) {
        return value - (-78.0);
      }
      return value - position.pixels;
    }
    return super.applyBoundaryConditions(position, value);
  }
}
