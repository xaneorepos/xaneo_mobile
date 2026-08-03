import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/chat/chat_model.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../utils/chat_name_localizer.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Экран подробной информации о чате (собеседник, группа, канал, бот, избранное).
/// Открывается из модалки ChatInfoModal с использованием Hero-анимации.
class ChatInfoScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatInfoScreen({
    super.key,
    required this.chat,
  });

  @override
  State<ChatInfoScreen> createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  int _selectedTabIndex = 0;

  late final List<Map<String, dynamic>> _tabs = [
    {
      'title': (AppLocalizations.of(context)?.media_c247 ?? 'Fallback'),
      'count': '14',
      'icon': Icons.image_rounded
    },
    {
      'title': (AppLocalizations.of(context)?.fayly_200c ?? 'Fallback'),
      'count': '3',
      'icon': Icons.description_rounded
    },
    {
      'title': (AppLocalizations.of(context)?.golos_2d89 ?? 'Fallback'),
      'count': '8',
      'icon': Icons.mic_rounded
    },
    {
      'title': (AppLocalizations.of(context)?.ssylki_9f58 ?? 'Fallback'),
      'count': '11',
      'icon': Icons.link_rounded
    },
  ];

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final otherUser = chat.otherUser;

    // Свойства пользователя/чата
    final String? username =
        chat.isFavorites ? null : otherUser?['username']?.toString();
    final String? phone =
        chat.isFavorites ? null : otherUser?['phone']?.toString();

    // Получение описания
    String? bio;
    if (chat.isFavorites) {
      bio = null;
    } else {
      bio = otherUser?['bio']?.toString() ??
          otherUser?['description']?.toString() ??
          otherUser?['about']?.toString();
    }

    final colors = _parseGradientColors(chat.avatarGradient);
    final primaryColor = colors.first;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E), // Ultra dark background
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Сворачиваемая шапка с аватаркой и градиентным размытием
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF141416),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Задний градиентный фон с размытием
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.15),
                          const Color(0xFF0D0D0E),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Центрированное содержимое
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Аватар (крупный с Hero-анимацией)
                        Hero(
                          tag: 'chat_avatar_${chat.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 40,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                            child: AvatarWidget(
                              avatar: chat.avatar,
                              avatarGradient: chat.avatarGradient,
                              hasAvatar: chat.avatar != null &&
                                  chat.avatar!.isNotEmpty,
                              username: localizedChatName(context, chat),
                              size: 120, // Больший размер для экрана
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Имя (Hero-анимация)
                        Hero(
                          tag: 'chat_name_${chat.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              localizedChatName(context, chat),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Статус
                        _buildStatusWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Контентная часть
          SliverPadding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Блок детальной информации
                Hero(
                  tag: 'chat_details_${chat.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: _buildDetailsSection(username, phone, bio),
                  ),
                ),
                const SizedBox(height: 28),

                // 2. Вкладки общих материалов
                Hero(
                  tag: 'chat_tabs_${chat.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: _buildSharedMediaTabs(),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Парсит градиент из строки
  List<Color> _parseGradientColors(String? gradient) {
    if (gradient == null || gradient.isEmpty) {
      return [const Color(0xFF3A3A3A), const Color(0xFF1A1A1A)];
    }
    try {
      final parts = gradient.split(RegExp(r'[,|]'));
      return parts.map((part) {
        var colorStr = part.trim();
        if (colorStr.startsWith('#')) {
          colorStr = colorStr.substring(1);
        }
        return Color(int.parse('FF$colorStr', radix: 16));
      }).toList();
    } catch (_) {
      return [const Color(0xFF3A3A3A), const Color(0xFF1A1A1A)];
    }
  }

  /// Возвращает статус
  Widget _buildStatusWidget() {
    final chat = widget.chat;
    String text = '';
    Color textColor = Colors.white70;
    IconData? icon;

    if (chat.isFavorites) {
      // Статус для "Избранного" не отображается
    } else if (_isDeleted()) {
      text =
          (AppLocalizations.of(context)?.udalennyyAkkaunt_ce47 ?? 'Fallback');
      textColor = Colors.white38;
    } else if (chat.isPersonal) {
      if (_isBot()) {
        text = (AppLocalizations.of(context)?.bot_2712 ?? 'Fallback');
        textColor = const Color(0xFF60A5FA);
        icon = Icons.android_rounded;
      } else {
        text = _formatUserStatus(chat.otherUser);
        if (text == (AppLocalizations.of(context)?.vSeti_d902 ?? 'Fallback')) {
          textColor = const Color(0xFF4ADE80);
        }
      }
    } else if (chat.isGroup) {
      final rawMem = chat.otherUser?['members_count'];
      final membersCount = rawMem is int
          ? rawMem
          : (rawMem is num
              ? rawMem.toInt()
              : int.tryParse(rawMem?.toString() ?? '') ?? 0);
      final rawOnline = chat.otherUser?['online_count'];
      final onlineCount = rawOnline is int
          ? rawOnline
          : (rawOnline is num
              ? rawOnline.toInt()
              : int.tryParse(rawOnline?.toString() ?? '') ?? 0);
      text = _pluralizeParticipants(membersCount);
      if (onlineCount > 0) {
        text +=
            ' • $onlineCount ${AppLocalizations.of(context)?.online ?? 'online'}';
      }
      textColor = Colors.white54;
      icon = Icons.people_alt_rounded;
    } else if (chat.isChannel) {
      final rawSub = chat.otherUser?['subscribers_count'];
      final subscribersCount = rawSub is int
          ? rawSub
          : (rawSub is num
              ? rawSub.toInt()
              : int.tryParse(rawSub?.toString() ?? '') ?? 0);
      text = _formatSubscribers(subscribersCount);
      textColor = Colors.white54;
      icon = Icons.campaign_rounded;
    }

    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            SizedBox(width: 6),
          ] else if (text ==
              (AppLocalizations.of(context)?.vSeti_d902 ?? 'Fallback')) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: textColor.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Блок детальной информации
  Widget _buildDetailsSection(String? username, String? phone, String? bio) {
    final hasBio = bio != null && bio.isNotEmpty;
    final hasPhone = phone != null && phone.isNotEmpty;
    final hasUsername = username != null && username.isNotEmpty;

    if (!hasBio && !hasPhone && !hasUsername) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.03),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          if (hasBio) ...[
            _buildInfoTile(
              icon: Icons.info_outline_rounded,
              value: bio,
              label: widget.chat.isGroup || widget.chat.isChannel
                  ? (AppLocalizations.of(context)?.opisanie_38ca ?? 'Fallback')
                  : (AppLocalizations.of(context)?.oSebe_0b3b ?? 'Fallback'),
            ),
            if (hasPhone || hasUsername) _buildDivider(),
          ],
          if (hasPhone) ...[
            _buildInfoTile(
              icon: Icons.phone_outlined,
              value: phone,
              label:
                  (AppLocalizations.of(context)?.mobilnyy_5ac7 ?? 'Fallback'),
            ),
            if (hasUsername) _buildDivider(),
          ],
          if (hasUsername) ...[
            _buildInfoTile(
              icon: Icons.alternate_email_rounded,
              value: username.startsWith('@') ? username : '@$username',
              label: (AppLocalizations.of(context)?.imyaPolzovatelya_6fd4 ??
                  'Fallback'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.04),
      height: 1,
      indent: 52,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.copied ?? 'Copied'}: "$value"'),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF1E1E22),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white70, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.copy_rounded,
                  color: Colors.white.withOpacity(0.2),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Раздел "Общие материалы" в виде табов
  Widget _buildSharedMediaTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            (AppLocalizations.of(context)?.obschieMaterialy_11e4 ?? 'Fallback'),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
              width: 1,
            ),
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isSelected = _selectedTabIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.06)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tab['title'].toString(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.12)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tab['count'].toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.white.withOpacity(0.3),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _buildTabContent(_selectedTabIndex),
        ),
      ],
    );
  }

  Widget _buildTabContent(int index) {
    final tab = _tabs[index];
    return Container(
      key: ValueKey<int>(index),
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.02),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tab['icon'] as IconData,
              color: Colors.white.withOpacity(0.18),
              size: 24,
            ),
          ),
          SizedBox(height: 12),
          Text(
            (AppLocalizations.of(context)?.netObschihFaylov_bf77 ?? 'Fallback'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            AppLocalizations.of(context)?.noSharedMedia ?? 'No shared media',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- Вспомогательные методы ---
  bool _isBot() {
    final otherUser = widget.chat.otherUser;
    if (otherUser == null) return false;
    final isBotVal = otherUser['is_bot'];
    if (isBotVal is bool) return isBotVal;
    if (isBotVal is String) return isBotVal.toLowerCase() == 'true';
    final username = otherUser['username']?.toString() ?? '';
    return username.toLowerCase().endsWith('bot');
  }

  bool _isDeleted() {
    final otherUser = widget.chat.otherUser;
    if (otherUser == null) return false;
    final isDeletedVal = otherUser['is_deleted'];
    if (isDeletedVal is bool) return isDeletedVal;
    if (isDeletedVal is String) return isDeletedVal.toLowerCase() == 'true';
    return false;
  }

  String _formatUserStatus(Map<String, dynamic>? otherUser) {
    if (otherUser == null)
      return (AppLocalizations.of(context)?.bylANedavno_168d ?? 'Fallback');

    final isOnlineVal = otherUser['is_online'] ?? otherUser['online'];
    if (isOnlineVal == true ||
        isOnlineVal?.toString().toLowerCase() == 'true') {
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

    if (difference.inMinutes < 5) {
      return (AppLocalizations.of(context)?.vSeti_d902 ?? 'Fallback');
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

  String _pluralizeParticipants(int count) {
    return AppLocalizations.of(context)?.membersCount(count) ??
        '$count members';
  }

  String _formatSubscribers(int count) {
    return AppLocalizations.of(context)?.subscribersCount(count) ??
        '$count subscribers';
  }
}
