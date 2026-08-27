import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

/// Service holding and resolving runtime custom language strings in mobile
class RuntimeTranslations {
  static final RuntimeTranslations instance = RuntimeTranslations._();
  RuntimeTranslations._();

  Map<String, String> _customStrings = {};
  String? _activeLocale;
  String _fallbackLocale = 'ru';
  String _direction = 'ltr';

  Map<String, dynamic>? _manifest;
  final Map<String, List<String>> _manifestRuIndex = {};

  bool get hasActiveCustomPack => _customStrings.isNotEmpty;
  bool containsKey(String key) =>
      _customStrings[key] != null && _customStrings[key]!.isNotEmpty;
  String? get activeLocale => _activeLocale;
  String get fallbackLocale => _fallbackLocale;
  String get direction => _direction;

  static String _normalize(String t) {
    if (t.isEmpty) return "";
    return t
        .replaceAll(RegExp(r'[^\w\s]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), '')
        .toLowerCase();
  }

  void _buildManifestIndex() {
    _manifestRuIndex.clear();
    final keys = _manifest?['keys'];
    if (keys is! Map) return;

    keys.forEach((k, v) {
      if (v is Map) {
        final ru = (v['fallback_ru'] ?? v['ru'])?.toString();
        if (ru != null && ru.isNotEmpty) {
          _manifestRuIndex.putIfAbsent(ru, () => []).add(k.toString());
          final norm = _normalize(ru);
          if (norm.isNotEmpty) {
            _manifestRuIndex.putIfAbsent(norm, () => []).add(k.toString());
          }
        }
      }
    });
  }

  /// Load canonical manifest if not yet loaded
  Future<Map<String, dynamic>> getManifest() async {
    if (_manifest != null &&
        _manifest!['keys'] is Map &&
        (_manifest!['keys'] as Map).isNotEmpty) {
      return _manifest!;
    }
    try {
      final jsonString = await rootBundle.loadString('assets/manifest.v1.json');
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      if (decoded['keys'] is Map && (decoded['keys'] as Map).isNotEmpty) {
        _manifest = decoded;
        _buildManifestIndex();
        return _manifest!;
      }
    } catch (_) {}

    try {
      // Fallback for tests or running from project root
      final file = File('assets/manifest.v1.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        if (decoded['keys'] is Map && (decoded['keys'] as Map).isNotEmpty) {
          _manifest = decoded;
          _buildManifestIndex();
          return _manifest!;
        }
      }
    } catch (_) {}

    try {
      final mainManifest =
          File('/home/xaneodev/xaneomain/localization/schema/manifest.v1.json');
      if (await mainManifest.exists()) {
        final jsonString = await mainManifest.readAsString();
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        if (decoded['keys'] is Map && (decoded['keys'] as Map).isNotEmpty) {
          _manifest = decoded;
          _buildManifestIndex();
          return _manifest!;
        }
      }
    } catch (_) {}

    return {'schema_version': 1, 'keys': {}};
  }

  /// Clear active language pack
  void clearActivePack() => setActivePack(null);

  /// Activate a custom language pack's parsed map
  void setActivePack(Map<String, dynamic>? packData) {
    if (packData == null) {
      _customStrings = {};
      _activeLocale = null;
      _fallbackLocale = 'ru';
      _direction = 'ltr';
      return;
    }

    _activeLocale = packData['locale'] as String?;
    _fallbackLocale = (packData['fallback_locale'] as String?) ?? 'ru';
    _direction = (packData['direction'] as String?) ?? 'ltr';

    final rawStrings = packData['strings'];
    if (rawStrings is Map) {
      _customStrings =
          rawStrings.map((k, v) => MapEntry(k.toString(), v.toString()));
    } else {
      _customStrings = {};
    }

    // Ensure index is ready if manifest is loaded
    if (_manifestRuIndex.isEmpty && _manifest != null) {
      _buildManifestIndex();
    }
  }

  /// Resolve a Russian fallback text through the reverse manifest index
  String resolveByText(String fallback) {
    if (_customStrings.isEmpty) return fallback;

    // 1. Exact match
    final keys = _manifestRuIndex[fallback];
    if (keys != null) {
      for (final k in keys) {
        final val = _customStrings[k];
        if (val != null && val.isNotEmpty) return val;
      }
    }

    // 2. Normalized match
    final norm = _normalize(fallback);
    if (norm.isNotEmpty) {
      final normKeys = _manifestRuIndex[norm];
      if (normKeys != null) {
        for (final k in normKeys) {
          final val = _customStrings[k];
          if (val != null && val.isNotEmpty) return val;
        }
      }
    }

    return fallback;
  }

  /// Resolve one canonical key only while a custom pack is active.
  /// This is useful where one Flutter getter is reused for different UI
  /// contexts (for example group and channel descriptions).
  String resolve(
    String key,
    String fallback, {
    Map<String, dynamic>? params,
  }) {
    if (_customStrings.isEmpty) return fallback;
    return get(key, params: params, fallback: fallback);
  }

  /// Get translation string for a key with parameter interpolation
  String get(String key, {Map<String, dynamic>? params, String? fallback}) {
    String? text = _customStrings[key];

    if (text == null && _manifest != null) {
      final keys = _manifest!['keys'] as Map<String, dynamic>?;
      final keyMeta = keys?[key] as Map<String, dynamic>?;
      if (keyMeta != null && keyMeta['ru'] != null) {
        text = keyMeta['ru'].toString();
      }
    }

    text ??= fallback ?? key;

    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, paramVal) {
        text = text!.replaceAll('{$paramKey}', paramVal.toString());
      });
    }

    return text!;
  }
}
