import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/xnx_theme.dart';

/// Downloads a font referenced by XNX and registers its files with Flutter.
class XnxFontLoader {
  static final Map<String, Future<String>> _pending = {};
  static const _maxFontBytes = 5 * 1024 * 1024;

  static Future<String?> load(XnxTheme theme) async {
    final source = theme.fontUrl;
    if (source == null) return null;
    // The editor's Onest URL is already included in the application bundle.
    if (theme.fontFamily == 'Onest' &&
        source.startsWith('https://fonts.googleapis.com/css2?family=Onest:')) {
      return null;
    }
    final uri = _secureUri(source);
    final key = '${theme.fontFamily}|$uri';
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(key)) {
      hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
    }
    final alias = 'XnxFont_${hash.toRadixString(16)}';
    return _pending.putIfAbsent(alias, () async {
      try {
        return await _load(alias, uri);
      } catch (_) {
        _pending.remove(alias);
        rethrow;
      }
    });
  }

  static Uri _secureUri(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.host == 'localhost' ||
        uri.host.endsWith('.local') ||
        InternetAddress.tryParse(uri.host) != null) {
      throw const FormatException('Адрес шрифта должен быть публичным HTTPS URL');
    }
    return uri;
  }

  static Future<String> _load(String alias, Uri uri) async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/xnx_fonts/$alias');
    final manifest = File('${directory.path}/count');
    List<Uint8List> fonts = [];
    if (await manifest.exists()) {
      final count = int.tryParse(await manifest.readAsString());
      if (count != null && count > 0 && count <= 8) {
        try {
          for (var i = 0; i < count; i++) {
            fonts.add(await File('${directory.path}/$i.ttf').readAsBytes());
          }
        } on FileSystemException {
          fonts = [];
        }
      }
    }
    if (fonts.isEmpty) {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      try {
        final first = await _fetch(
          client,
          uri,
          RegExp(r'\.(ttf|otf)$', caseSensitive: false).hasMatch(uri.path)
              ? _maxFontBytes
              : 256 * 1024,
        );
        final urls = <Uri>[];
        if (_isFont(first)) {
          fonts = [first];
        } else {
          final css = utf8.decode(first);
          final matches = RegExp(r'''url\(\s*['"]?([^'"\)]+)['"]?\s*\)''')
              .allMatches(css);
          for (final match in matches) {
            final fontUri = _secureUri(uri.resolve(match.group(1)!).toString());
            if (RegExp(r'\.(ttf|otf)$', caseSensitive: false)
                .hasMatch(fontUri.path)) {
              if (!urls.contains(fontUri)) urls.add(fontUri);
            }
          }
          if (urls.isEmpty) {
            throw const FormatException(
                'CSS шрифта не содержит TTF/OTF. WOFF2 не поддерживается Flutter.');
          }
          if (urls.length > 8) {
            throw const FormatException('Слишком много файлов шрифта в CSS');
          }
          for (final fontUri in urls) {
            final bytes = await _fetch(client, fontUri, _maxFontBytes);
            if (!_isFont(bytes)) {
              throw const FormatException('Загружен не TTF/OTF шрифт');
            }
            fonts.add(bytes);
          }
        }
      } finally {
        client.close();
      }
      await directory.create(recursive: true);
      for (var i = 0; i < fonts.length; i++) {
        await File('${directory.path}/$i.ttf').writeAsBytes(fonts[i], flush: true);
      }
      await manifest.writeAsString('${fonts.length}', flush: true);
    }
    final loader = FontLoader(alias);
    for (final bytes in fonts) {
      if (!_isFont(bytes) || bytes.length > _maxFontBytes) {
        throw const FormatException('Повреждённый файл шрифта');
      }
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
    return alias;
  }

  static bool _isFont(Uint8List bytes) =>
      bytes.length > 4 &&
      ((bytes[0] == 0 && bytes[1] == 1 && bytes[2] == 0 && bytes[3] == 0) ||
          ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'OTTO');

  static Future<Uint8List> _fetch(HttpClient client, Uri uri, int limit) async {
    final request = await client.getUrl(uri).timeout(const Duration(seconds: 15));
    request.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/4.0');
    final response = await request.close().timeout(const Duration(seconds: 15));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('Не удалось загрузить шрифт: HTTP ${response.statusCode}');
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response.timeout(const Duration(seconds: 15))) {
      builder.add(chunk);
      if (builder.length > limit) {
        throw const FormatException('Файл шрифта слишком большой');
      }
    }
    return builder.takeBytes();
  }
}
