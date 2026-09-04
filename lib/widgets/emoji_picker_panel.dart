import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _recentEmojiKey = 'xaneo_recent_message_emojis';
const _accentColor = Color(0xFF6366F1);

class _EmojiItem {
  const _EmojiItem({
    required this.emoji,
    required this.name,
    required this.keywords,
    required this.category,
  });

  final String emoji;
  final String name;
  final List<String> keywords;
  final String category;

  factory _EmojiItem.fromJson(Map<String, dynamic> json) => _EmojiItem(
        emoji: json['emoji']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        keywords: (json['keywords'] as List<dynamic>? ?? const [])
            .map((value) => value.toString())
            .toList(growable: false),
        category: json['category']?.toString() ?? 'Symbols',
      );

  bool matches(String query) {
    final normalized = query.toLowerCase();
    return emoji.contains(query) ||
        name.toLowerCase().contains(normalized) ||
        keywords.any((keyword) => keyword.toLowerCase().contains(normalized));
  }
}

class _EmojiCategory {
  const _EmojiCategory(this.id, this.icon, this.label);

  final String id;
  final String icon;
  final String label;
}

const _categories = <_EmojiCategory>[
  _EmojiCategory('recent', '🕐', 'Недавние'),
  _EmojiCategory('Smileys & Emotion', '😀', 'Смайлы'),
  _EmojiCategory('People & Body', '👋', 'Люди'),
  _EmojiCategory('Animals & Nature', '🐱', 'Животные'),
  _EmojiCategory('Food & Drink', '🍕', 'Еда'),
  _EmojiCategory('Activities', '⚽', 'Активности'),
  _EmojiCategory('Travel & Places', '🚗', 'Путешествия'),
  _EmojiCategory('Objects', '💡', 'Объекты'),
  _EmojiCategory('Symbols', '❤️', 'Символы'),
  _EmojiCategory('Flags', '🏳️', 'Флаги'),
];

class EmojiPickerPanel extends StatefulWidget {
  const EmojiPickerPanel({
    super.key,
    required this.isDark,
    required this.onEmojiSelected,
  });

  final bool isDark;
  final ValueChanged<String> onEmojiSelected;

  @override
  State<EmojiPickerPanel> createState() => _EmojiPickerPanelState();
}

class _EmojiPickerPanelState extends State<EmojiPickerPanel> {
  static Future<List<_EmojiItem>>? _cachedItems;

  final _searchController = TextEditingController();
  List<_EmojiItem> _items = const [];
  List<String> _recent = const [];
  String _category = 'recent';
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _cachedItems ??= _loadItems();
    final prefs = await SharedPreferences.getInstance();
    final results = await Future.wait<dynamic>([
      _cachedItems!,
      Future<List<String>>.value(
        prefs.getStringList(_recentEmojiKey) ?? const <String>[],
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _items = results[0] as List<_EmojiItem>;
      _recent = results[1] as List<String>;
      if (_recent.isEmpty && _category == 'recent') {
        _category = 'Smileys & Emotion';
      }
      _loading = false;
    });
  }

  static Future<List<_EmojiItem>> _loadItems() async {
    final source = await rootBundle.loadString('assets/emoji/emoji_data.json');
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_EmojiItem.fromJson)
        .where((item) => item.emoji.isNotEmpty)
        .toList(growable: false);
  }

  List<_EmojiItem> get _visibleItems {
    if (_query.isNotEmpty) {
      return _items
          .where((item) => item.matches(_query))
          .toList(growable: false);
    }
    if (_category == 'recent') {
      final byEmoji = {for (final item in _items) item.emoji: item};
      return _recent
          .map((emoji) => byEmoji[emoji])
          .whereType<_EmojiItem>()
          .toList(growable: false);
    }
    return _items
        .where((item) => item.category == _category)
        .toList(growable: false);
  }

  Future<void> _select(_EmojiItem item) async {
    widget.onEmojiSelected(item.emoji);
    final recent = <String>[
      item.emoji,
      ..._recent.where((emoji) => emoji != item.emoji),
    ].take(36).toList(growable: false);
    setState(() {
      _recent = recent;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentEmojiKey, recent);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final background =
        widget.isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFDFDFD);
    final muted = widget.isDark ? Colors.white54 : Colors.black54;
    final border = widget.isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.10);
    final surface = widget.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.045);
    final visibleItems = _visibleItems;

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border(top: BorderSide(color: border)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value.trim()),
                style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Поиск эмодзи...',
                  hintStyle: TextStyle(color: muted),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: muted, size: 19),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon:
                              Icon(Icons.close_rounded, color: muted, size: 17),
                        ),
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: _accentColor),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : visibleItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _category == 'recent' && _query.isEmpty
                                  ? 'Недавние эмодзи появятся здесь'
                                  : 'Ничего не найдено',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: muted, fontSize: 13),
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth < 350 ? 7 : 8;
                            return GridView.builder(
                              padding: const EdgeInsets.all(10),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 3,
                                crossAxisSpacing: 3,
                              ),
                              itemCount: visibleItems.length,
                              itemBuilder: (context, index) {
                                final item = visibleItems[index];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => _select(item),
                                  child: Center(
                                    child: Text(
                                      item.emoji,
                                      style: const TextStyle(fontSize: 25),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
            Divider(height: 1, color: border),
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final selected = _query.isEmpty && _category == category.id;
                  return Tooltip(
                    message: category.label,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _query = '';
                          _category = category.id;
                        });
                      },
                      child: Container(
                        width: 38,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: selected
                              ? _accentColor.withValues(alpha: 0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 19),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
