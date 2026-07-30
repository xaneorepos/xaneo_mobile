import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import 'base_custom_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Модальное окно глобального поиска для Xaneo PC.
/// Построено на кастомной базовой модалке BaseCustomModal (в точности повторяющей модалку смены аккаунтов).
class GlobalSearchModal extends BaseCustomModal {
  final ApiService apiService;
  final Function(Map<String, dynamic> item, String type) onResultSelected;

  GlobalSearchModal({
    super.key,
    super.modalTag = 'Fallback',
    required this.apiService,
    required this.onResultSelected,
  });

  /// Вызов модалки через системный метод BaseCustomModal.show
  static void show({
    required BuildContext context,
    required ApiService apiService,
    required Function(Map<String, dynamic> item, String type) onResultSelected,
  }) {
    BaseCustomModal.show(
      context: context,
      barrierLabel: 'GlobalSearchModal',
      modal: GlobalSearchModal(
        apiService: apiService,
        onResultSelected: onResultSelected,
      ),
    );
  }

  @override
  State<GlobalSearchModal> createState() => _GlobalSearchModalState();
}

class _GlobalSearchModalState extends BaseCustomModalState<GlobalSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  String _query = '';
  bool _isLoading = false;
  String _selectedCategory = 'all'; // 'all', 'users', 'groups', 'channels', 'bots', 'favorites'

  List<dynamic> _users = [];
  List<dynamic> _groups = [];
  List<dynamic> _channels = [];
  List<dynamic> _bots = [];
  List<dynamic> _favorites = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _query = text.trim();
    if (_query.startsWith('@')) {
      _query = _query.substring(1).trim();
    }
    _debounceTimer?.cancel();

    if (_query.isEmpty) {
      setState(() {
        _users = [];
        _groups = [];
        _channels = [];
        _bots = [];
        _favorites = [];
        _isLoading = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    if (_query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await widget.apiService.searchUsers(_query);
      debugPrint('🔍 GlobalSearch API response success: ${res.success}, data: ${res.data}');

      if (mounted) {
        setState(() {
          if (res.success && res.data != null) {
            final data = res.data!;
            
            final favData = data['favorites'];
            _favorites = favData != null ? [favData] : [];

            _bots = data['bots'] as List? ?? [];
            _users = data['users'] as List? ?? [];
            _groups = data['groups'] as List? ?? [];
            _channels = data['channels'] as List? ?? [];
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
      debugPrint('❌ Exception in GlobalSearch _performSearch: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController, bool isDark, double scale) {
    final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Поле ввода поиска
        Container(
          height: 42 * scale,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF141414) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8 * scale),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14 * scale,
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              hintText: (AppLocalizations.of(context)?.poiskKontaktovChatovKanalovBotov_db66 ?? 'Fallback'),
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 13 * scale,
                fontFamily: 'Inter',
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? Colors.white54 : Colors.black54,
                size: 18 * scale,
              ),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.cancel_rounded,
                        color: isDark ? Colors.white54 : Colors.black54,
                        size: 16 * scale,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8 * scale),
            ),
          ),
        ),
        SizedBox(height: 12 * scale),

        // Категории
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', (AppLocalizations.of(context)?.vse_984b ?? 'Fallback'), isDark, scale),
              _buildFilterChip('users', (AppLocalizations.of(context)?.lyudi_c7ae ?? 'Fallback'), isDark, scale),
              _buildFilterChip('groups', (AppLocalizations.of(context)?.gruppy_ebc4 ?? 'Fallback'), isDark, scale),
              _buildFilterChip('channels', (AppLocalizations.of(context)?.kanaly_0c11 ?? 'Fallback'), isDark, scale),
              _buildFilterChip('bots', (AppLocalizations.of(context)?.boty_d6e4 ?? 'Fallback'), isDark, scale),
              _buildFilterChip('favorites', (AppLocalizations.of(context)?.izbrannoe_2fc4 ?? 'Fallback'), isDark, scale),
            ],
          ),
        ),
        SizedBox(height: 12 * scale),

        // Список результатов
        Expanded(
          child: _isLoading
              ? Center(
                  child: SizedBox(
                    width: 24 * scale,
                    height: 24 * scale,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.white54 : const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                )
              : _buildResultsList(scrollController, isDark, scale),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String categoryId, String label, bool isDark, double scale) {
    final isSelected = _selectedCategory == categoryId;
    final activeBg = isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFF2563EB);
    final activeText = Colors.white;

    return Padding(
      padding: EdgeInsets.only(right: 6 * scale),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = categoryId;
          });
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 5 * scale),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeBg
                  : (isDark ? const Color(0xFF141414) : const Color(0xFFF5F5F5)),
              borderRadius: BorderRadius.circular(6 * scale),
              border: Border.all(
                color: isSelected
                    ? activeBg
                    : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB)),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? activeText
                    : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 12 * scale,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(ScrollController scrollController, bool isDark, double scale) {
    if (_query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 44 * scale,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            SizedBox(height: 10 * scale),
            Text(
              (AppLocalizations.of(context)?.vvediteZaprosDlyaPoiskaPo_9955 ?? 'Fallback'),
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 13 * scale,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    final hasFavorites = _favorites.isNotEmpty && (_selectedCategory == 'all' || _selectedCategory == 'favorites');
    final hasBots = _bots.isNotEmpty && (_selectedCategory == 'all' || _selectedCategory == 'bots');
    final hasGroups = _groups.isNotEmpty && (_selectedCategory == 'all' || _selectedCategory == 'groups');
    final hasChannels = _channels.isNotEmpty && (_selectedCategory == 'all' || _selectedCategory == 'channels');
    final hasUsers = _users.isNotEmpty && (_selectedCategory == 'all' || _selectedCategory == 'users');

    if (!hasFavorites && !hasBots && !hasGroups && !hasChannels && !hasUsers) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40 * scale,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            SizedBox(height: 10 * scale),
            Text(
              (AppLocalizations.of(context)?.nichegoNeNaydeno_8767 ?? 'Fallback'),
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 13 * scale,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      controller: scrollController,
      physics: BouncingScrollPhysics(),
      children: [
        if (hasFavorites) ...[
          _buildSectionHeader((AppLocalizations.of(context)?.izbrannoe_b637 ?? 'Fallback'), isDark, scale),
          ..._favorites.map((item) => _buildResultItem(item, 'favorites', isDark, scale)),
        ],
        if (hasBots) ...[
          _buildSectionHeader((AppLocalizations.of(context)?.boty_800d ?? 'Fallback'), isDark, scale),
          ..._bots.map((item) => _buildResultItem(item, 'bot', isDark, scale)),
        ],
        if (hasChannels) ...[
          _buildSectionHeader((AppLocalizations.of(context)?.kanaly_ccec ?? 'Fallback'), isDark, scale),
          ..._channels.map((item) => _buildResultItem(item, 'channel', isDark, scale)),
        ],
        if (hasGroups) ...[
          _buildSectionHeader((AppLocalizations.of(context)?.gruppy_cfd6 ?? 'Fallback'), isDark, scale),
          ..._groups.map((item) => _buildResultItem(item, 'group', isDark, scale)),
        ],
        if (hasUsers) ...[
          _buildSectionHeader((AppLocalizations.of(context)?.polzovateli_e0ec ?? 'Fallback'), isDark, scale),
          ..._users.map((item) => _buildResultItem(item, 'user', isDark, scale)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, double scale) {
    return Padding(
      padding: EdgeInsets.only(top: 10 * scale, bottom: 6 * scale, left: 4 * scale),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 10 * scale,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2 * scale,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildResultItem(Map<String, dynamic> item, String type, bool isDark, double scale) {
    String name = '';
    String subtitle = '';
    IconData iconData = Icons.person_rounded;
    Color iconColor = const Color(0xFF2563EB);

    if (type == 'favorites') {
      name = (AppLocalizations.of(context)?.izbrannoe_2fc4 ?? 'Fallback');
      subtitle = (AppLocalizations.of(context)?.sohranennyeSoobscheniya_6b62 ?? 'Fallback');
      iconData = Icons.bookmark_rounded;
      iconColor = const Color(0xFF8B5CF6);
    } else if (type == 'user') {
      final username = item['username']?.toString() ?? '';
      final firstName = item['first_name']?.toString() ?? '';
      final lastName = item['last_name']?.toString() ?? '';
      name = '$firstName $lastName'.trim();
      if (name.isEmpty) name = username;
      subtitle = '@$username';
      iconData = Icons.person_rounded;
      iconColor = const Color(0xFF2563EB);
    } else if (type == 'bot') {
      name = item['first_name']?.toString() ?? item['username']?.toString() ?? (AppLocalizations.of(context)?.bot_0ae1 ?? 'Bot');
      subtitle = '@${item['username'] ?? (AppLocalizations.of(context)?.bot_0f46 ?? 'bot')}';
      iconData = Icons.smart_toy_rounded;
      iconColor = const Color(0xFF10B981);
    } else if (type == 'group') {
      name = item['name']?.toString() ?? (AppLocalizations.of(context)?.gruppa_99d9 ?? 'Group');
      final count = item['members_count'] is int ? item['members_count'] as int : int.tryParse(item['members_count']?.toString() ?? '0') ?? 0;
      subtitle = AppLocalizations.of(context)?.membersCount(count) ?? '$count members';
      iconData = Icons.groups_rounded;
      iconColor = const Color(0xFFA855F7);
    } else if (type == 'channel') {
      name = item['name']?.toString() ?? (AppLocalizations.of(context)?.kanal_2710 ?? 'Channel');
      final count = item['subscribers_count'] is int ? item['subscribers_count'] as int : int.tryParse(item['subscribers_count']?.toString() ?? '0') ?? 0;
      subtitle = AppLocalizations.of(context)?.subscribersCount(count) ?? '$count subscribers';
      iconData = Icons.campaign_rounded;
      iconColor = const Color(0xFFF59E0B);
    }

    final avatarUrl = item['avatar']?.toString() ?? item['avatar_url']?.toString();
    final avatarGradient = item['avatar_gradient']?.toString();

    return Container(
      margin: EdgeInsets.only(bottom: 6 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            widget.onResultSelected(item, type);
          },
          borderRadius: BorderRadius.circular(8 * scale),
          hoverColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
            child: Row(
              children: [
                // Аватар (SVG / PNG / Инициалы)
                _buildAvatarWidget(avatarUrl, name, iconData, iconColor, scale, isDark, avatarGradient: avatarGradient),
                SizedBox(width: 12 * scale),

                // Текст
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 11 * scale,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14 * scale,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWidget(
    String? avatarUrl,
    String displayName,
    IconData fallbackIcon,
    Color iconColor,
    double scale,
    bool isDark, {
    String? avatarGradient,
  }) {
    final size = 36.0 * scale;
    final initials = displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : "?";

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('data:image/svg+xml')) {
        try {
          String svgString = '';
          if (avatarUrl.startsWith('data:image/svg+xml;base64,')) {
            final base64String = avatarUrl.substring('data:image/svg+xml;base64,'.length);
            svgString = utf8.decode(base64.decode(base64String));
          } else {
            final commaIndex = avatarUrl.indexOf(',');
            if (commaIndex != -1) {
              svgString = Uri.decodeComponent(avatarUrl.substring(commaIndex + 1));
            }
          }

          if (svgString.isNotEmpty) {
            if (svgString.contains('<text') && svgString.contains('</text>')) {
              Gradient? gradient;
              final stopColors = <String>[];
              final matches = RegExp(r'stop-color:(#[A-Fa-f0-9]{6})|stop-color="(#[A-Fa-f0-9]{6})"').allMatches(svgString);
              for (var m in matches) {
                final c = m.group(1) ?? m.group(2);
                if (c != null && !stopColors.contains(c)) {
                  stopColors.add(c);
                }
              }

              String? gradStr;
              if (stopColors.length >= 2) {
                gradStr = '${stopColors[0]}|${stopColors[1]}';
              } else if (stopColors.length == 1) {
                gradStr = '${stopColors[0]}|${stopColors[0]}';
              } else {
                final rectMatch = RegExp(r'fill="(#[A-Fa-f0-9]{6})"').firstMatch(svgString);
                if (rectMatch != null) {
                  final col = rectMatch.group(1);
                  if (col != null) gradStr = '$col|$col';
                }
              }
              gradStr ??= avatarGradient;

              if (gradStr != null && gradStr.contains('|')) {
                try {
                  final colors = gradStr.split('|');
                  if (colors.length == 2) {
                    final color1 = Color(int.parse(colors[0].trim().replaceFirst('#', ''), radix: 16) + 0xFF000000);
                    final color2 = Color(int.parse(colors[1].trim().replaceFirst('#', ''), radix: 16) + 0xFF000000);
                    gradient = LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color1, color2],
                    );
                  }
                } catch (_) {}
              }

              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gradient == null ? iconColor.withValues(alpha: 0.15) : null,
                  gradient: gradient,
                ),
                child: CustomPaint(
                  painter: _InitialsPainter(
                    initial: initials,
                    color: Colors.white,
                    fontSize: size * 0.45,
                  ),
                ),
              );
            }

            return ClipOval(
              child: SizedBox(
                width: size,
                height: size,
                child: SvgPicture.string(
                  svgString,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error parsing SVG avatar in search: $e');
        }
      } else {
        // PNG / JPEG / Network image
        return ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: Image.network(
              avatarUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildFallbackAvatar(initials, iconColor, size, scale, avatarGradient: avatarGradient),
            ),
          ),
        );
      }
    }

    return _buildFallbackAvatar(initials, iconColor, size, scale, avatarGradient: avatarGradient);
  }

  Widget _buildFallbackAvatar(String initials, Color iconColor, double size, double scale, {String? avatarGradient}) {
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
      } catch (_) {}
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gradient == null ? iconColor.withValues(alpha: 0.15) : null,
        gradient: gradient,
        shape: BoxShape.circle,
        border: gradient == null
            ? Border.all(
                color: iconColor.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: CustomPaint(
        painter: _InitialsPainter(
          initial: initials,
          color: gradient != null ? Colors.white : iconColor,
          fontSize: size * 0.45,
        ),
      ),
    );
  }
}

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

    final baseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    final capHeight = fontSize * 0.72;
    final glyphTop = baseline - capHeight;
    final glyphVisualCenter = glyphTop + capHeight / 2;

    final dy = size.height / 2 - glyphVisualCenter;
    final dx = (size.width - textPainter.width) / 2;
    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_InitialsPainter old) =>
      old.initial != initial || old.color != color || old.fontSize != fontSize;
}
