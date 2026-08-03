/// Модель информации об обновлении мобильного приложения Xaneo
class AppVersionInfo {
  final String version;
  final String releaseNotes;
  final String htmlUrl;
  final DateTime? publishedAt;
  final String? downloadUrl;

  AppVersionInfo({
    required this.version,
    required this.releaseNotes,
    required this.htmlUrl,
    this.publishedAt,
    this.downloadUrl,
  });

  factory AppVersionInfo.fromGitHubJson(Map<String, dynamic> json) {
    final tagName = json['tag_name'] as String? ?? '';
    final versionClean = tagName.startsWith('v') || tagName.startsWith('V')
        ? tagName.substring(1)
        : tagName;
    if (versionClean.isEmpty) {
      throw const FormatException('GitHub release does not contain a tag name');
    }

    String? download;
    final assets = json['assets'] as List<dynamic>?;
    if (assets != null && assets.isNotEmpty) {
      for (final asset in assets) {
        if (asset is Map<String, dynamic>) {
          final browserDownloadUrl = asset['browser_download_url'] as String?;
          if (browserDownloadUrl != null && browserDownloadUrl.isNotEmpty) {
            download = browserDownloadUrl;
            break;
          }
        }
      }
    }

    DateTime? pubDate;
    final pubStr = json['published_at'] as String?;
    if (pubStr != null) {
      pubDate = DateTime.tryParse(pubStr);
    }

    return AppVersionInfo(
      version: versionClean,
      releaseNotes: json['body'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? 'https://github.com/xaneorepos/xaneo_mobile/releases/latest',
      publishedAt: pubDate,
      downloadUrl: download,
    );
  }
}
