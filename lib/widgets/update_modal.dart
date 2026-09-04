import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'common/base_custom_modal.dart';
import '../models/update/app_version_info.dart';
import '../services/update/update_service.dart';
import '../styles/app_styles.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Мобильное модальное окно деталей и скачивания обновления Xaneo на базе BaseCustomModal
class XaneoUpdateModal extends BaseCustomModal {
  final AppVersionInfo updateInfo;

  const XaneoUpdateModal({
    super.key,
    required this.updateInfo,
  });

  static Future<void> open(BuildContext context, AppVersionInfo updateInfo) {
    return BaseCustomModal.show<void>(
      context: context,
      enableDrag: true,
      child: XaneoUpdateModal(updateInfo: updateInfo),
    );
  }

  @override
  State<XaneoUpdateModal> createState() => _XaneoUpdateModalState();
}

enum UpdateSource {
  directDownload,
  githubRelease,
}

class _XaneoUpdateModalState extends BaseCustomModalState<XaneoUpdateModal> {
  late UpdateSource _selectedSource;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _bytesInfo = '';
  String? _downloadError;

  @override
  bool get fitContent => true;

  @override
  void initState() {
    super.initState();
    _selectedSource = widget.updateInfo.downloadUrl != null
        ? UpdateSource.directDownload
        : UpdateSource.githubRelease;
  }

  Future<void> _handleUpdateAction() async {
    final downloadUrl = widget.updateInfo.downloadUrl ??
        'https://github.com/xaneorepos/xaneo_mobile/releases/latest/download/xaneo.apk';

    if (_selectedSource == UpdateSource.directDownload) {
      await _startInAppDownload(downloadUrl);
    } else {
      await _launchSelectedSource();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _startInAppDownload(String url) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.02;
      _bytesInfo = '';
      _downloadError = null;
    });

    try {
      await UpdateService().downloadAndInstall(
        url: url,
        onProgress: (progress, bytesInfo) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
              _bytesInfo = bytesInfo;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _downloadProgress = 1.0;
        });
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final errText =
            l10n?.oshibkaZagruzkiFayla_86e5 ?? 'Ошибка скачивания файла';
        setState(() {
          _isDownloading = false;
          _downloadError = '$errText: $e';
        });
      }
    }
  }

  Future<void> _launchSelectedSource() async {
    String targetUrl = widget.updateInfo.htmlUrl;
    if (_selectedSource == UpdateSource.directDownload &&
        widget.updateInfo.downloadUrl != null) {
      targetUrl = widget.updateInfo.downloadUrl!;
    }

    final uri = Uri.parse(targetUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatProgressStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final downloadingStr = l10n?.downloadVersion ?? 'Скачивание';
    final preparingStr = l10n?.preparingDownload ?? 'Подготовка к загрузке...';
    final installingStr = l10n?.ustanovka_516d ?? 'Установка...';

    if (_downloadProgress <= 0.05) {
      return preparingStr;
    } else if (_downloadProgress >= 1.0) {
      return installingStr;
    } else {
      final percent = (_downloadProgress * 100).toInt();
      if (_bytesInfo.isNotEmpty) {
        return '$downloadingStr... $_bytesInfo ($percent%)';
      }
      return '$downloadingStr... $percent%';
    }
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final info = widget.updateInfo;
    final l10n = AppLocalizations.of(context);

    final titleStr = l10n?.newVersionAvailableTitle ?? 'Новая версия доступна';
    final subtitleStr = l10n?.updateAvailable ?? 'Доступно обновление';
    final sourceHeaderStr = l10n?.downloadSource ?? 'Источник загрузки';
    final directTitleStr = l10n?.downloadVersion != null
        ? '${l10n!.downloadVersion} APK'
        : 'Прямая загрузка APK';
    final directSubtitleStr =
        l10n?.autoDownloadAndRun ?? 'Автоматическое скачивание и запуск';
    final githubTitleStr = 'GitHub Releases';
    final githubSubtitleStr =
        l10n?.githubReleasePage ?? 'Страница релиза на GitHub';

    String actionButtonStr;
    if (_isDownloading) {
      actionButtonStr = l10n?.preparingDownload ?? 'Загрузка...';
    } else if (_selectedSource == UpdateSource.directDownload) {
      actionButtonStr =
          l10n?.downloadVersion ?? l10n?.obnovit_dbe5 ?? 'Скачать и установить';
    } else {
      actionButtonStr = '${l10n?.downloadVersion ?? "Скачать"} (GitHub)';
    }

    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.xaneoOverlay(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    color: context.xaneoTextPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$titleStr v${info.version}',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: context.xaneoTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitleStr,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.xaneoTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: context.xaneoTextMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: context.xaneoDivider, height: 1),
            const SizedBox(height: 14),

            // Source section title
            Text(
              sourceHeaderStr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.xaneoTextSecondary,
              ),
            ),
            const SizedBox(height: 10),

            if (info.downloadUrl != null)
              _buildSourceOption(
                title: directTitleStr,
                subtitle: directSubtitleStr,
                iconWidget: const FaIcon(FontAwesomeIcons.download, size: 18),
                source: UpdateSource.directDownload,
              ),

            _buildSourceOption(
              title: githubTitleStr,
              subtitle: githubSubtitleStr,
              iconWidget: const FaIcon(FontAwesomeIcons.github, size: 18),
              source: UpdateSource.githubRelease,
            ),

            const SizedBox(height: 14),

            // Download error message if present
            if (_downloadError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _downloadError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Download progress indicator
            if (_isDownloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _downloadProgress > 0 ? _downloadProgress : null,
                  backgroundColor: context.xaneoOverlay(0.08),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatProgressStatus(context),
                style: TextStyle(
                  color: context.xaneoTextSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Download action button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isDownloading ? null : _handleUpdateAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    actionButtonStr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required String title,
    required String subtitle,
    required Widget iconWidget,
    required UpdateSource source,
  }) {
    final isSelected = _selectedSource == source;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: _isDownloading
            ? null
            : () {
                setState(() {
                  _selectedSource = source;
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB).withValues(alpha: 0.15)
                : context.xaneoOverlay(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFF2563EB) : context.xaneoDivider,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              IconTheme(
                data: IconThemeData(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : context.xaneoTextSecondary,
                ),
                child: iconWidget,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.xaneoTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: context.xaneoTextMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Radio<UpdateSource>(
                value: source,
                groupValue: _selectedSource,
                onChanged: _isDownloading
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSource = val;
                          });
                        }
                      },
                activeColor: const Color(0xFF2563EB),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
