import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Metadata of an installed custom language pack
class InstalledLanguagePack {
  final String id;
  final String locale;
  final String name;
  final String nativeName;
  final String direction;
  final String fallbackLocale;
  final int stringCount;
  final DateTime installedAt;
  final String relativeFilePath;

  const InstalledLanguagePack({
    required this.id,
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.direction,
    required this.fallbackLocale,
    required this.stringCount,
    required this.installedAt,
    required this.relativeFilePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'locale': locale,
        'name': name,
        'native_name': nativeName,
        'direction': direction,
        'fallback_locale': fallbackLocale,
        'string_count': stringCount,
        'installed_at': installedAt.toIso8601String(),
        'relative_file_path': relativeFilePath,
      };

  factory InstalledLanguagePack.fromJson(Map<String, dynamic> json) {
    return InstalledLanguagePack(
      id: json['id'] as String,
      locale: json['locale'] as String,
      name: json['name'] as String,
      nativeName: json['native_name'] as String,
      direction: (json['direction'] as String?) ?? 'ltr',
      fallbackLocale: json['fallback_locale'] as String,
      stringCount: (json['string_count'] as num?)?.toInt() ?? 0,
      installedAt: DateTime.tryParse(json['installed_at'] as String? ?? '') ?? DateTime.now(),
      relativeFilePath: json['relative_file_path'] as String,
    );
  }
}

/// Local repository for managing stored custom language pack files in mobile
class LocalLanguagePackRepository {
  static const String _registryPrefKey = 'xaneo_custom_language_packs_registry';
  static const String _activePackPrefKey = 'xaneo_active_custom_pack_id';
  static const String _packsDirName = 'custom_language_packs';

  static String _generateUuid() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // version 4
    values[8] = (values[8] & 0x3f) | 0x80; // variant RFC4122
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  Future<Directory> _getPacksDirectory() async {
    final appSupportDir = await getApplicationSupportDirectory();
    final packsDir = Directory(p.join(appSupportDir.path, _packsDirName));
    if (!await packsDir.exists()) {
      await packsDir.create(recursive: true);
    }
    return packsDir;
  }

  /// Get all installed custom language packs metadata
  Future<List<InstalledLanguagePack>> getInstalledPacks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_registryPrefKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw);
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(InstalledLanguagePack.fromJson)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Get the active custom pack ID, if any
  Future<String?> getActivePackId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activePackPrefKey);
  }

  /// Set or clear the active custom pack ID
  Future<void> setActivePackId(String? packId) async {
    final prefs = await SharedPreferences.getInstance();
    if (packId != null && packId.isNotEmpty) {
      await prefs.setString(_activePackPrefKey, packId);
    } else {
      await prefs.remove(_activePackPrefKey);
    }
  }

  /// Save a validated normalized pack to local storage
  Future<InstalledLanguagePack> installPack(Map<String, dynamic> normalizedPack) async {
    final id = _generateUuid();
    final packsDir = await _getPacksDirectory();
    final fileName = '$id.json';
    final targetFile = File(p.join(packsDir.path, fileName));

    // Atomic write via temp file
    final tempFile = File(p.join(packsDir.path, '$id.tmp'));
    final jsonContent = jsonEncode(normalizedPack);
    await tempFile.writeAsString(jsonContent, flush: true);
    await tempFile.rename(targetFile.path);

    final strings = normalizedPack['strings'] as Map<String, dynamic>? ?? {};

    final installedPack = InstalledLanguagePack(
      id: id,
      locale: normalizedPack['locale'] as String,
      name: normalizedPack['name'] as String,
      nativeName: normalizedPack['native_name'] as String,
      direction: (normalizedPack['direction'] as String?) ?? 'ltr',
      fallbackLocale: normalizedPack['fallback_locale'] as String,
      stringCount: strings.length,
      installedAt: DateTime.now(),
      relativeFilePath: fileName,
    );

    final packs = await getInstalledPacks();
    // Remove if same locale existed
    packs.removeWhere((p) => p.locale == installedPack.locale);
    packs.add(installedPack);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _registryPrefKey,
      jsonEncode(packs.map((p) => p.toJson()).toList()),
    );

    return installedPack;
  }

  /// Load full pack JSON content for an installed pack
  Future<Map<String, dynamic>?> loadPackContent(String packId) async {
    final packs = await getInstalledPacks();
    final pack = packs.where((p) => p.id == packId).firstOrNull;
    if (pack == null) return null;

    final packsDir = await _getPacksDirectory();
    final file = File(p.join(packsDir.path, pack.relativeFilePath));
    if (!await file.exists()) return null;

    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  /// Delete an installed pack
  Future<void> deletePack(String packId) async {
    final activeId = await getActivePackId();
    if (activeId == packId) {
      await setActivePackId(null);
    }

    final packs = await getInstalledPacks();
    final pack = packs.where((p) => p.id == packId).firstOrNull;

    if (pack != null) {
      final packsDir = await _getPacksDirectory();
      final file = File(p.join(packsDir.path, pack.relativeFilePath));
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      packs.removeWhere((p) => p.id == packId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _registryPrefKey,
        jsonEncode(packs.map((p) => p.toJson()).toList()),
      );
    }
  }
}
