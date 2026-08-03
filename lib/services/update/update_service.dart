import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../../models/update/app_version_info.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  static const String _repoUrl = 'https://api.github.com/repos/xaneorepos/xaneo_mobile/releases/latest';
  static const String _ignoredVersionKey = 'xaneo_mobile_ignored_version';
  static const String _lastCheckedKey = 'xaneo_mobile_last_update_check';

  /// Запросить информацию о последнем мобильном релизе с GitHub
  Future<AppVersionInfo?> fetchLatestRelease() async {
    try {
      final response = await http.get(
        Uri.parse(_repoUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': AppConfig.userAgent,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AppVersionInfo.fromGitHubJson(data);
      }
    } catch (_) {
      // Игнорируем сетевые сбои
    }
    return null;
  }

  /// Получить текущую версию приложения
  Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version.isNotEmpty && packageInfo.version != '0.0.0') {
        return packageInfo.version;
      }
      return AppConfig.appVersion;
    } catch (_) {
      return AppConfig.appVersion;
    }
  }

  /// Проверить наличие доступных обновлений
  Future<AppVersionInfo?> checkForUpdates({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!force) {
      final lastCheckMs = prefs.getInt(_lastCheckedKey) ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (nowMs - lastCheckMs < 12 * 3600 * 1000) {
        return null;
      }
    }

    final latestRelease = await fetchLatestRelease();
    if (latestRelease == null) return null;

    final currentVersion = await getCurrentVersion();
    await prefs.setInt(_lastCheckedKey, DateTime.now().millisecondsSinceEpoch);

    if (isVersionNewer(currentVersion, latestRelease.version)) {
      return latestRelease;
    }


    return null;
  }

  /// Сохранить пропущенную версию
  Future<void> ignoreVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ignoredVersionKey, version);
  }

  /// Сравнение версий SemVer (например 2.0.loc_0 < 2.1.loc_0)
  static bool isVersionNewer(String current, String remote) {
    try {
      final currentParts = current.split('+')[0].split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final remoteParts = remote.split('+')[0].split('.').map((e) => int.tryParse(e) ?? 0).toList();

      while (currentParts.length < 3) {
        currentParts.add(0);
      }
      while (remoteParts.length < 3) {
        remoteParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (remoteParts[i] > currentParts[i]) return true;
        if (remoteParts[i] < currentParts[i]) return false;
      }
    } catch (_) {}
    return false;
  }
}
