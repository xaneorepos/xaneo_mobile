import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../config/app_config.dart';
import '../../models/update/app_version_info.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  static const MethodChannel _installerChannel =
      MethodChannel('net.xaneo/app_installer');

  static const String _repoUrl =
      'https://api.github.com/repos/xaneorepos/xaneo_mobile/releases/latest';
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

  /// Сравнение версий SemVer (например 2.0.0 < 2.1.0)
  static bool isVersionNewer(String current, String remote) {
    try {
      final currentParts = current
          .split('+')[0]
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final remoteParts = remote
          .split('+')[0]
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

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

  /// Скачать файл обновления прямо в приложении с числовыми байтами для локализации
  Future<void> downloadAndInstall({
    required String url,
    required void Function(double progress, String bytesInfo) onProgress,
  }) async {
    final client = http.Client();
    try {
      onProgress(0.02, '');
      final request = http.Request('GET', Uri.parse(url));
      request.headers['User-Agent'] = AppConfig.userAgent;

      final response = await client.send(request);

      // Перенаправления (301, 302, 307, 308)
      if (response.statusCode >= 300 &&
          response.statusCode < 400 &&
          response.headers.containsKey('location')) {
        final redirectUrl = response.headers['location']!;
        return downloadAndInstall(url: redirectUrl, onProgress: onProgress);
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      Directory saveDir;
      if (Platform.isAndroid) {
        try {
          saveDir = Directory('/storage/emulated/0/Download/Xaneo');
          if (!await saveDir.exists()) {
            await saveDir.create(recursive: true);
          }
        } catch (_) {
          saveDir = await getTemporaryDirectory();
        }
      } else {
        saveDir = await getTemporaryDirectory();
      }

      final apkFile = File('${saveDir.path}/xaneo_update.apk');
      if (await apkFile.exists()) {
        await apkFile.delete();
      }

      final sink = apkFile.openWrite();

      await for (final chunk in response.stream) {
        receivedBytes += chunk.length;
        sink.add(chunk);

        if (totalBytes > 0) {
          final progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
          final downloadedMb =
              (receivedBytes / (1024 * 1024)).toStringAsFixed(1);
          final totalMb = (totalBytes / (1024 * 1024)).toStringAsFixed(1);
          onProgress(progress, '$downloadedMb MB / $totalMb MB');
        } else {
          final downloadedMb =
              (receivedBytes / (1024 * 1024)).toStringAsFixed(1);
          onProgress(0.5, '$downloadedMb MB');
        }
      }

      await sink.flush();
      await sink.close();

      final fileSize = await apkFile.length();
      print(
          'UpdateService: APK downloaded successfully to path="${apkFile.path}", size=$fileSize bytes');

      onProgress(1.0, '');

      if (Platform.isAndroid) {
        try {
          print(
              'UpdateService: Invoking native app_installer MethodChannel for path="${apkFile.path}"');
          final bool? success = await _installerChannel
              .invokeMethod<bool>('installApk', {'filePath': apkFile.path});
          print('UpdateService: Native installApk result = $success');
          if (success == true) return;
        } catch (e, stack) {
          print('UpdateService: Native installApk exception: $e\n$stack');
        }
      }

      print(
          'UpdateService: Launching installer via FileProvider content URI...');

      // На Android 7.0+ (API 24+) использование file:// вызывает FileUriExposedException.
      // Используем валидный Content URI через зарегистрированный FileProvider (net.xaneo.fileprovider).
      final contentUri = Uri.parse(
          'content://net.xaneo.fileprovider/external/Download/Xaneo/xaneo_update.apk');

      try {
        final launched =
            await launchUrl(contentUri, mode: LaunchMode.externalApplication);
        print('UpdateService: launchUrl(contentUri) result = $launched');
        if (launched) return;
      } catch (e) {
        print('UpdateService: contentUri launch exception: $e');
      }

      // Запасная попытка через URI кэша
      try {
        final cacheContentUri = Uri.parse(
            'content://net.xaneo.fileprovider/cache/xaneo_update.apk');
        final launchedCache = await launchUrl(cacheContentUri,
            mode: LaunchMode.externalApplication);
        print(
            'UpdateService: launchUrl(cacheContentUri) result = $launchedCache');
      } catch (e) {
        print('UpdateService: cacheContentUri launch exception: $e');
      }

      print(
          'UpdateService: APK file is downloaded and saved at "${apkFile.path}"');
    } finally {
      client.close();
    }
  }
}
