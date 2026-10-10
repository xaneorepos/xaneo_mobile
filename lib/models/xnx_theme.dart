import 'dart:convert';
import 'package:flutter/material.dart';

/// The portable subset of the web client's XNX format used for native colors.
class XnxTheme {
  XnxTheme(this.source, this.data);

  final String source;
  final Map<String, Object> data;

  String get name => _section(data, 'meta')['name']?.toString() ?? 'XNX';
  String get author => _section(data, 'meta')['author']?.toString() ?? '';
  String get defaultMode => data['default-mode'] == 'light' ? 'light' : 'dark';
  String get fontFamily =>
      _section(data, 'typography')['font-family']?.toString() ?? 'Inter';
  String? get fontUrl {
    final value = _section(data, 'typography')['font-url']?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }
  int get radius =>
      int.tryParse((_section(data, 'geometry')['radius']?.toString() ?? '')
              .replaceAll('px', ''))
          ?.clamp(8, 24) ??
      14;

  /// 100% in the editor corresponds to the web client's 24 px maximum.
  int get blurPercent {
    final raw = _section(data, 'geometry')['blur']?.toString().trim() ?? 'none';
    if (raw == 'none') return 0;
    final match = RegExp(r'^(\d+(?:\.\d+)?)(px|%)$').firstMatch(raw);
    if (match == null) return 0;
    final value = double.tryParse(match.group(1)!) ?? 0;
    return (match.group(2) == '%' ? value : value * 100 / 24)
        .round()
        .clamp(0, 100);
  }

  Map<String, Object> section(String key, bool dark) {
    final schemes = _section(data, 'schemes');
    final scheme = _section(schemes, dark ? 'dark' : 'light');
    final scoped = _section(scheme, key);
    return {..._section(data, key), ...scoped};
  }

  static XnxTheme preset(String name) {
    final palettes = <String, List<String>>{
      'Default': [
        '#000000',
        '#0c0c0c',
        '#141416',
        '#ffffff',
        '#b0b0b0',
        '#707070',
        '#2563eb',
      ],
      'Graphite': [
        '#151719',
        '#25292d',
        '#343a40',
        '#f3f4f5',
        '#b5bcc4',
        '#8f99a3',
        '#94a3b8'
      ],
      'Gruvbox': [
        '#282828',
        '#3c3836',
        '#504945',
        '#ebdbb2',
        '#d5c4a1',
        '#a89984',
        '#d79921'
      ],
      'Paper': [
        '#f4f4f2',
        '#e8e8e4',
        '#ffffff',
        '#1c2520',
        '#4f6657',
        '#7b8a7f',
        '#4f6657'
      ],
    };
    final dark = palettes[name] ?? palettes['Graphite']!;
    final light = name == 'Paper'
        ? dark
        : name == 'Default'
            ? [
                '#f7f7f8',
                '#f1f1f4',
                '#ffffff',
                '#18181b',
                '#52525b',
                '#71717a',
                '#2563eb'
              ]
            : [
                '#f5f5f3',
                '#e8e9e7',
                '#ffffff',
                '#1b2024',
                '#4d565e',
                '#7b848b',
                dark[6]
              ];
    Map<String, Object> colors(List<String> p, bool dark) => {
          'bg': p[0],
          'bg-secondary': p[1],
          'surface': p[2],
          'surface-hover': p[1],
          'border': p[5],
          'text': p[3],
          'text-secondary': p[4],
          'text-muted': p[5],
          'accent': p[6],
          'btn-primary-bg':
              name == 'Default' ? (dark ? '#ffffff' : '#18181b') : p[6],
          'btn-primary-text': name == 'Default'
              ? (dark ? '#000000' : '#ffffff')
              : (dark ? '#151719' : '#ffffff'),
          'progress-bg': p[1],
          'progress-fill': p[6],
          'message-incoming-bg': p[2],
          'message-incoming-text': p[3],
          'message-outgoing-bg': p[6],
          'message-outgoing-text':
              name == 'Default' ? '#ffffff' : (dark ? '#151719' : '#ffffff'),
        };
    final data = <String, Object>{
      'meta': <String, Object>{
        'name': name,
        'format-version': '1',
        'generator': 'Xaneo native'
      },
      'default-mode': name == 'Paper' ? 'light' : 'dark',
      'schemes': <String, Object>{
        'dark': <String, Object>{'colors': colors(dark, true)},
        'light': <String, Object>{'colors': colors(light, false)},
      },
      'typography': <String, Object>{'font-family': 'Inter'},
      'geometry': <String, Object>{'radius': '14px', 'radius-sm': '10px'},
    };
    return XnxTheme.parse(serialize(data));
  }

  XnxTheme withColor(String key, Color value, bool dark) {
    final copy = _copyMap(data);
    final colors = _ensure(
        _ensure(_ensure(copy, 'schemes'), dark ? 'dark' : 'light'), 'colors');
    colors[key] =
        '#${value.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    return XnxTheme.parse(serialize(copy));
  }

  XnxTheme withName(String value) {
    final copy = _copyMap(data);
    _ensure(copy, 'meta')['name'] =
        value.trim().isEmpty ? 'Xaneo custom theme' : value.trim();
    return XnxTheme.parse(serialize(copy));
  }

  XnxTheme withMode(bool dark) {
    final copy = _copyMap(data);
    copy['default-mode'] = dark ? 'dark' : 'light';
    return XnxTheme.parse(serialize(copy));
  }

  XnxTheme withRadius(int value) {
    final copy = _copyMap(data);
    final geometry = _ensure(copy, 'geometry');
    geometry['radius'] = '${value.clamp(8, 24)}px';
    geometry['radius-sm'] = '${(value - 4).clamp(4, 20)}px';
    return XnxTheme.parse(serialize(copy));
  }

  XnxTheme withBlurPercent(int value) {
    final copy = _copyMap(data);
    _ensure(copy, 'geometry')['blur'] = value <= 0
        ? 'none'
        : '${(value.clamp(0, 100) * 0.24).toStringAsFixed(1)}px';
    return XnxTheme.parse(serialize(copy));
  }

  XnxTheme withFontFamily(String value) {
    final copy = _copyMap(data);
    final typography = _ensure(copy, 'typography');
    typography['font-family'] = value;
    typography.remove('font-url');
    if (value == 'Onest') {
      typography['font-url'] =
          'https://fonts.googleapis.com/css2?family=Onest:wght@400;500;600;700&display=swap';
    }
    return XnxTheme.parse(serialize(copy));
  }

  static Map<String, Object> _copyMap(Map<String, Object> value) => value.map(
        (key, item) =>
            MapEntry(key, item is Map<String, Object> ? _copyMap(item) : item),
      );

  static Map<String, Object> _ensure(Map<String, Object> map, String key) {
    final existing = map[key];
    if (existing is Map<String, Object>) return existing;
    final created = <String, Object>{};
    map[key] = created;
    return created;
  }

  String toSource() => serialize(data);

  static String serialize(Map<String, Object> data) {
    String write(Map<String, Object> map, int depth) {
      if (depth > 8 || map.length > 256)
        throw const FormatException('Слишком сложная тема XNX');
      final indent = '  ' * depth;
      final lines = <String>[];
      for (final entry in map.entries) {
        if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_-]*$').hasMatch(entry.key)) {
          throw const FormatException('Недопустимый ключ XNX');
        }
        final value = entry.value is Map<String, Object>
            ? write(entry.value as Map<String, Object>, depth + 1)
            : jsonEncode(entry.value.toString());
        lines.add("${'  ' * (depth + 1)}${entry.key} = $value;");
      }
      return '{\n${lines.join('\n')}\n$indent}';
    }

    final source =
        '# Portable XNX theme exported by Xaneo\n${write(data, 0)}\n';
    if (utf8.encode(source).length > 65536)
      throw const FormatException('Файл .xnx больше 64 КБ');
    return source;
  }

  Color? color(String key, bool dark) {
    final raw = section('colors', dark)[key];
    if (raw is! String) return null;
    if (raw == 'transparent') return Colors.transparent;
    final rgb = RegExp(
            r'^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})(?:\s*,\s*(0(?:\.\d+)?|1(?:\.0+)?))?\s*\)$')
        .firstMatch(raw);
    if (rgb != null) {
      final channels = [1, 2, 3].map((i) => int.parse(rgb.group(i)!)).toList();
      if (channels.any((value) => value > 255)) return null;
      final alpha = rgb.group(4) == null
          ? 255
          : (double.parse(rgb.group(4)!) * 255).round();
      return Color.fromARGB(alpha, channels[0], channels[1], channels[2]);
    }
    final hex = RegExp(r'^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
    if (!hex.hasMatch(raw)) return null;
    var digits = raw.substring(1);
    if (digits.length == 3) {
      digits = digits.split('').map((c) => '$c$c').join();
    }
    if (digits.length == 6) digits = 'FF$digits';
    return Color(int.parse(digits, radix: 16));
  }

  /// Matches the XC v3 CSS fallback chain for message bubbles.
  Color? messageColor(
      {required bool outgoing, required bool text, required bool dark}) {
    final explicit = color(
      outgoing
          ? (text ? 'message-outgoing-text' : 'message-outgoing-bg')
          : (text ? 'message-incoming-text' : 'message-incoming-bg'),
      dark,
    );
    if (explicit != null) return explicit;
    return color(
      outgoing
          ? (text ? 'btn-primary-text' : 'btn-primary-bg')
          : (text ? 'text' : 'surface'),
      dark,
    );
  }

  static Map<String, Object> _section(Map<String, Object> map, String key) {
    final value = map[key];
    return value is Map<String, Object> ? value : <String, Object>{};
  }

  static XnxTheme parse(String source) {
    if (utf8.encode(source).length > 65536) {
      throw const FormatException('Файл .xnx больше 64 КБ');
    }
    final reader = _XnxReader(source);
    final data = reader.parse();
    final theme = XnxTheme(source, data);
    if (theme.section('colors', true).isEmpty &&
        theme.section('colors', false).isEmpty) {
      throw const FormatException('В .xnx нет раздела colors');
    }
    return theme;
  }
}

class _XnxReader {
  _XnxReader(this.source);
  final String source;
  int pos = 0;
  int keys = 0;

  FormatException error(String message) {
    final line = '\n'.allMatches(source.substring(0, pos)).length + 1;
    return FormatException('XNX, строка $line: $message');
  }

  void skip() {
    while (pos < source.length) {
      if (RegExp(r'\s').hasMatch(source[pos])) {
        pos++;
      } else if (source[pos] == '#') {
        while (pos < source.length && source[pos] != '\n') {
          pos++;
        }
      } else {
        break;
      }
    }
  }

  String identifier() {
    final match =
        RegExp(r'^[a-zA-Z_][a-zA-Z0-9_-]*').firstMatch(source.substring(pos));
    if (match == null) throw error('ожидался ключ');
    pos += match.group(0)!.length;
    return match.group(0)!;
  }

  String quoted() {
    final start = pos++;
    var escaped = false;
    while (pos < source.length) {
      final c = source[pos++];
      if (c == '"' && !escaped) {
        try {
          return jsonDecode(source.substring(start, pos)) as String;
        } catch (_) {
          throw error('неверная строка');
        }
      }
      if (c == '\n') throw error('незавершённая строка');
      if (c.codeUnitAt(0) == 92) {
        escaped = !escaped;
      } else {
        escaped = false;
      }
    }
    throw error('незавершённая строка');
  }

  Object value(int depth) {
    skip();
    if (pos >= source.length) throw error('ожидалось значение');
    if (source[pos] == '{') return set(depth + 1);
    if (source[pos] == '"') return quoted();
    return identifier();
  }

  Map<String, Object> set(int depth) {
    if (depth > 8) throw error('превышена глубина вложенности');
    if (pos >= source.length || source[pos++] != '{') {
      throw error('ожидалась {');
    }
    final result = <String, Object>{};
    while (true) {
      skip();
      if (pos >= source.length) throw error('ожидалась }');
      if (source[pos] == '}') {
        pos++;
        return result;
      }
      if (++keys > 256) throw error('слишком много ключей');
      final key = identifier();
      if (result.containsKey(key)) throw error('повторный ключ $key');
      skip();
      if (pos >= source.length || source[pos++] != '=') {
        throw error('ожидалось =');
      }
      result[key] = value(depth);
      skip();
      if (pos >= source.length || source[pos++] != ';') {
        throw error('ожидалась ;');
      }
    }
  }

  Map<String, Object> parse() {
    skip();
    final result = set(0);
    skip();
    if (pos != source.length) throw error('лишние данные после }');
    return result;
  }
}
