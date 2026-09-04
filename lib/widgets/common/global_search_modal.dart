import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'base_custom_modal.dart';
import 'avatar_widget.dart';
import 'premium_page_route.dart';
import '../../models/chat/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../screens/chat/chat_screen.dart';
import '../../services/chat/chat_local_repository.dart';
import '../../services/chat/chat_service.dart';
import '../../styles/app_styles.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Модалка глобального поиска
class GlobalSearchModal extends BaseCustomModal {
  final ChatService chatService;
  final LocalChatRepository localChatRepo;
  final AuthProvider authProvider;

  const GlobalSearchModal({
    super.key,
    required this.chatService,
    required this.localChatRepo,
    required this.authProvider,
  });

  static void show({
    required BuildContext context,
    required ChatService chatService,
    required LocalChatRepository localChatRepo,
    required AuthProvider authProvider,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (context) => GlobalSearchModal(
        chatService: chatService,
        localChatRepo: localChatRepo,
        authProvider: authProvider,
      ),
    );
  }

  @override
  State<GlobalSearchModal> createState() => _GlobalSearchModalState();
}

class _GlobalSearchModalState extends BaseCustomModalState<GlobalSearchModal> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  String _query = '';
  Timer? _debounceTimer;

  // Видимость крестика очистки вынесена в ValueNotifier: раньше каждый
  // введённый символ дёргал setState и пересобирал всю модалку вместе со
  // списком результатов. Теперь на ввод перерисовывается только сам крестик.
  final ValueNotifier<bool> _hasText = ValueNotifier<bool>(false);

  // Результаты поиска
  List<dynamic> _favorites = [];
  List<dynamic> _bots = [];
  List<dynamic> _users = [];
  List<dynamic> _groups = [];
  List<dynamic> _channels = [];

  @override
  double get initialExtent => 0.65;

  @override
  double get maxExtent => 0.90;

  @override
  void initState() {
    super.initState();
    // Фокусируемся на вводе только после завершения анимации открытия модалки
    Future.delayed(const Duration(milliseconds: 260), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _hasText.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    final wasEmpty = _query.isEmpty;
    _query = text.trim();
    _hasText.value = _query.isNotEmpty;

    _debounceTimer?.cancel();
    if (_query.isEmpty) {
      setState(() {
        _favorites = [];
        _bots = [];
        _users = [];
        _groups = [];
        _channels = [];
        _isLoading = false;
      });
      return;
    }

    // Полный ребилд нужен только на переходе «пусто → есть текст»,
    // чтобы сменить пустое состояние на список результатов.
    if (wasEmpty) {
      setState(() {});
    }

    _debounceTimer = Timer(const Duration(milliseconds: 450), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    if (_query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await widget.chatService.globalSearch(_query);

      if (mounted) {
        setState(() {
          if (results != null) {
            // Парсим Избранное
            final favData = results['favorites'];
            _favorites = favData != null ? [favData] : [];

            _bots = results['bots'] as List? ?? [];
            _users = results['users'] as List? ?? [];
            _groups = results['groups'] as List? ?? [];
            _channels = results['channels'] as List? ?? [];
          } else {
            _favorites = [];
            _bots = [];
            _users = [];
            _groups = [];
            _channels = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error performing global search inside modal: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onResultSelected(
    BuildContext context,
    String type,
    Map<String, dynamic> item,
  ) async {
    final myUser = widget.authProvider.user;
    if (myUser == null) return;

    final myId = myUser.id;
    String serverChatId = '';
    ChatModel? chatModel;
    bool isNewChat = false;

    if (type == 'favorites') {
      serverChatId = 'favorites_user_$myId';
      chatModel = ChatModel(
        id: serverChatId,
        name: (AppLocalizations.of(context)?.izbrannoe_2fc4 ?? 'Fallback'),
        isFavorites: true,
        isEncrypted: true,
        avatarGradient: '8B5CF6,6366F1',
      );
    } else if (type == 'user' || type == 'bot') {
      final targetId = (type == 'bot' && item['user_id'] != null)
          ? item['user_id'] as int
          : item['id'] as int;

      if (type == 'user' && targetId == myId) {
        // Если пользователь выбрал самого себя, перенаправляем в Избранное
        serverChatId = 'favorites_user_$myId';
        chatModel = ChatModel(
          id: serverChatId,
          name: (AppLocalizations.of(context)?.izbrannoe_2fc4 ?? 'Fallback'),
          isFavorites: true,
          isEncrypted: true,
          avatarGradient: '8B5CF6,6366F1',
        );
      } else {
        // Ищем существующий личный чат с этим пользователем в локальной базе напрямую
        final sortedIds = [myId, targetId]..sort();
        final standardId = 'personal_${sortedIds[0]}_${sortedIds[1]}';

        ChatModel? existingPersonalChat =
            await widget.localChatRepo.getChatByServerId(standardId);
        if (existingPersonalChat == null && sortedIds[0] != sortedIds[1]) {
          existingPersonalChat = await widget.localChatRepo
              .getChatByServerId('personal_${sortedIds[1]}_${sortedIds[0]}');
        }
        if (existingPersonalChat == null) {
          existingPersonalChat = await widget.localChatRepo
              .getChatByServerId('personal_$targetId');
        }

        if (existingPersonalChat != null) {
          serverChatId = existingPersonalChat.id;
          chatModel = existingPersonalChat;
        } else {
          serverChatId = standardId;
          isNewChat = true;

          final firstName = item['first_name']?.toString() ?? '';
          final username = item['username']?.toString() ?? '';
          final customName = item['custom_name']?.toString() ?? '';

          final otherUser = {
            'id': targetId,
            'username': username,
            'first_name': firstName,
            'custom_name': customName,
            'avatar_url': item['avatar_url']?.toString(),
            'avatar_gradient': item['avatar_gradient']?.toString() ?? '',
            'bio': item['bio']?.toString() ?? '',
          };

          chatModel = ChatModel(
            id: serverChatId,
            name: customName.isNotEmpty
                ? customName
                : (firstName.isNotEmpty ? firstName : '@$username'),
            avatar: otherUser['avatar_url'] as String?,
            avatarGradient: otherUser['avatar_gradient'] as String?,
            isPersonal: true,
            isEncrypted: true,
            otherUser: otherUser,
          );
        }
      }
    } else if (type == 'group') {
      final groupId = item['id'] as int;
      serverChatId = 'group_$groupId';
      final isMember = item['is_member'] == true || item['is_joined'] == true;
      chatModel = ChatModel(
        id: serverChatId,
        name: item['name']?.toString() ?? 'Group',
        avatar: item['avatar_url']?.toString(),
        avatarGradient: item['avatar_gradient']?.toString(),
        isGroup: true,
        otherUser: {
          'is_member': isMember,
        },
      );
    } else if (type == 'channel') {
      final channelId = item['id'] as int;
      serverChatId = 'channel_$channelId';
      final isMember =
          item['is_member'] == true || item['is_subscribed'] == true;
      chatModel = ChatModel(
        id: serverChatId,
        name: item['name']?.toString() ?? 'Channel',
        avatar: item['avatar_url']?.toString(),
        avatarGradient: item['avatar_gradient']?.toString(),
        isChannel: true,
        otherUser: {
          'is_member': isMember,
        },
      );
    }

    if (serverChatId.isEmpty || chatModel == null) return;

    // Скрываем модалку перед переходом
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // Проверяем, существует ли чат локально
    final existingChat =
        await widget.localChatRepo.getChatByServerId(serverChatId);
    final ChatModel finalChat = existingChat ?? chatModel;

    // Переходим в чат
    if (context.mounted) {
      Navigator.of(context).push(
        PremiumPageRoute(
          page: ChatScreen(chat: finalChat),
          transitionType: PremiumTransitionType.chatReveal,
          settings: RouteSettings(name: 'chat_$serverChatId'),
        ),
      );
    }
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    return Column(
      children: [
        // Поле ввода поиска
        SizedBox(
          height: 44,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 1,
            style: AppStyles.bodyMedium.copyWith(
              color: context.xaneoTextPrimary,
              fontSize: 14,
              height: 1.0,
            ),
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: context.xaneoOverlay(0.05),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  Icons.search_rounded,
                  color: context.xaneoTextMuted,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 44,
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 44,
              ),
              suffixIcon: ValueListenableBuilder<bool>(
                valueListenable: _hasText,
                builder: (context, hasText, _) {
                  if (!hasText) {
                    return const SizedBox(width: 36, height: 44);
                  }
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 44,
                    ),
                    onPressed: () {
                      _controller.clear();
                      _onSearchChanged('');
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.xaneoTextMuted,
                      size: 20,
                    ),
                  );
                },
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              hintText:
                  (AppLocalizations.of(context)?.poiskLyudeyBotovGrupp_e84e ??
                      'Fallback'),
              hintStyle: AppStyles.bodyMuted.copyWith(
                color: context.xaneoTextMuted,
                fontSize: 14,
                height: 1.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: context.xaneoDivider,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: context.xaneoOverlay(0.15),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),

        // Результаты поиска
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.xaneoTextPrimary,
                    ),
                  ),
                )
              : _query.isEmpty
                  ? _buildEmptyState((AppLocalizations.of(context)
                          ?.vveditePoiskovyyZapros_0b8c ??
                      'Fallback'))
                  : _hasNoResults()
                      ? _buildEmptyState((AppLocalizations.of(context)
                              ?.nichegoNeNaydeno_8767 ??
                          'Fallback'))
                      : ListView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            if (_favorites.isNotEmpty)
                              _buildSection(
                                (AppLocalizations.of(context)?.izbrannoe_2fc4 ??
                                    'Fallback'),
                                _favorites,
                                'favorites',
                              ),
                            if (_bots.isNotEmpty)
                              _buildSection(
                                  (AppLocalizations.of(context)?.boty_d6e4 ??
                                      'Fallback'),
                                  _bots,
                                  'bot'),
                            if (_users.isNotEmpty)
                              _buildSection(
                                  (AppLocalizations.of(context)
                                          ?.polzovateli_b8c4 ??
                                      'Fallback'),
                                  _users,
                                  'user'),
                            if (_groups.isNotEmpty)
                              _buildSection(
                                  (AppLocalizations.of(context)?.gruppy_ebc4 ??
                                      'Fallback'),
                                  _groups,
                                  'group'),
                            if (_channels.isNotEmpty)
                              _buildSection(
                                  (AppLocalizations.of(context)?.kanaly_0c11 ??
                                      'Fallback'),
                                  _channels,
                                  'channel'),
                          ],
                        ),
        ),
      ],
    );
  }

  bool _hasNoResults() {
    return _favorites.isEmpty &&
        _bots.isEmpty &&
        _users.isEmpty &&
        _groups.isEmpty &&
        _channels.isEmpty;
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: context.xaneoOverlay(0.15),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: AppStyles.bodyMuted.copyWith(
              color: context.xaneoTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<dynamic> items,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: context.xaneoTextMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card(
          color: context.xaneoOverlay(0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: context.xaneoDivider,
              width: 1,
            ),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              color: context.xaneoDivider,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final item = items[index] as Map<String, dynamic>;
              return _buildSearchResultItem(item, type);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> item, String type) {
    final String displayName;
    final String subtitle;
    final String? avatarUrl = item['avatar_url'] as String?;
    final String? avatarGradient = item['avatar_gradient'] as String?;

    if (type == 'favorites') {
      displayName =
          (AppLocalizations.of(context)?.izbrannoe_2fc4 ?? 'Fallback');
      subtitle = (AppLocalizations.of(context)?.moiLichnyeSoobscheniya_7d3b ??
          'Fallback');
    } else if (type == 'user' || type == 'bot') {
      final customName = item['custom_name']?.toString() ?? '';
      final firstName = item['first_name']?.toString() ?? '';
      final username = item['username']?.toString() ?? '';
      if (customName.isNotEmpty) {
        displayName = customName;
        subtitle =
            firstName.isNotEmpty ? '$firstName (@$username)' : '@$username';
      } else {
        displayName = firstName.isNotEmpty ? firstName : '@$username';
        subtitle = firstName.isNotEmpty ? '@$username' : '';
      }
    } else if (type == 'group') {
      displayName = item['name']?.toString() ??
          (AppLocalizations.of(context)?.gruppa_99d9 ?? 'Fallback');
      final rawCount = item['members_count'];
      final count = rawCount is int
          ? rawCount
          : (rawCount is num
              ? rawCount.toInt()
              : int.tryParse(rawCount?.toString() ?? '') ?? 0);
      subtitle =
          AppLocalizations.of(context)?.membersCount(count) ?? '$count members';
    } else if (type == 'channel') {
      displayName = item['name']?.toString() ??
          (AppLocalizations.of(context)?.kanal_2710 ?? 'Fallback');
      final rawCount = item['subscribers_count'];
      final count = rawCount is int
          ? rawCount
          : (rawCount is num
              ? rawCount.toInt()
              : int.tryParse(rawCount?.toString() ?? '') ?? 0);
      subtitle = AppLocalizations.of(context)?.subscribersCount(count) ??
          '$count subscribers';
    } else {
      displayName = '';
      subtitle = '';
    }

    return ListTile(
      onTap: () => _onResultSelected(context, type, item),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: AvatarWidget(
        avatar: avatarUrl,
        avatarGradient: avatarGradient,
        hasAvatar: avatarUrl != null,
        username: displayName,
        icon: type == 'favorites' ? FontAwesomeIcons.star : null,
      ),
      title: Text(
        displayName,
        style: AppStyles.bodyMedium.copyWith(
          color: context.xaneoTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: AppStyles.bodyMuted.copyWith(
                fontSize: 13,
                color: context.xaneoTextMuted,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.xaneoTextMuted,
      ),
    );
  }
}
