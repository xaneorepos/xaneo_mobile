import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'base_custom_modal.dart';
import '../models/update/app_version_info.dart';
import '../services/update/update_service.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Модальное окно деталей обновления Xaneo PC на базе BaseCustomModal
class XaneoUpdateModal extends BaseCustomModal {
  final AppVersionInfo updateInfo;

  XaneoUpdateModal({
    super.key,
    required this.updateInfo,
  }) : super(modalTag: '', title: '');

  static Future<void> open(BuildContext context, AppVersionInfo updateInfo) {
    return BaseCustomModal.show(
      context: context,
      modal: XaneoUpdateModal(updateInfo: updateInfo),
    );
  }

  @override
  State<XaneoUpdateModal> createState() => _XaneoUpdateModalState();
}

enum UpdateSource {
  githubRelease,
  directDownload,
}

class _XaneoUpdateModalState extends BaseCustomModalState<XaneoUpdateModal> {
  @override
  double get modalWidth => 440.0;
  @override
  double get modalHeightFactor => 0.75;

  @override
  String getModalTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return (l10n?.newVersionAvailableTitle ?? 'ОБНОВЛЕНИЕ').toUpperCase();
  }

  late UpdateSource _selectedSource;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _statusText = '';
  String? _downloadError;

  @override
  void initState() {
    super.initState();
    _selectedSource = widget.updateInfo.downloadUrl != null
        ? UpdateSource.directDownload
        : UpdateSource.githubRelease;
  }

  Future<void> _handleUpdateAction() async {
    final downloadUrl = widget.updateInfo.downloadUrl;
    if (_selectedSource == UpdateSource.directDownload && downloadUrl != null) {
      await _startInAppDownload(downloadUrl);
    } else if (downloadUrl != null && _selectedSource != UpdateSource.githubRelease) {
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
      _downloadProgress = 0.0;
      _statusText = l10n?.preparingDownload ?? 'Подготовка к загрузке...';
      _downloadError = null;
    });

    try {
      await UpdateService().downloadAndInstall(
        url: url,
        onProgress: (progress, status) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
              _statusText = status;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _statusText = l10n?.installationStarted ?? 'Установка запущена...';
        });
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadError = 'Ошибка загрузки: $e';
        });
      }
    }
  }

  Future<void> _launchSelectedSource() async {
    String targetUrl = widget.updateInfo.htmlUrl;
    if (_selectedSource == UpdateSource.directDownload && widget.updateInfo.downloadUrl != null) {
      targetUrl = widget.updateInfo.downloadUrl!;
    }

    final uri = Uri.parse(targetUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget buildContent(
      BuildContext context, ScrollController scrollController, bool isDark, double scale) {
    final info = widget.updateInfo;
    final l10n = AppLocalizations.of(context);

    final cardBg = isDark ? const Color(0xFF161820) : const Color(0xFFF3F4F6);
    final borderColor = isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15);
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black54;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Иконка и Версия
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(20) : const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 22 * scale,
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xaneo PC v${info.version}',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    l10n?.newVersionAvailable ?? 'Доступна новая версия приложения',
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: secondaryTextColor,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 14 * scale),

        // Заголовок списка изменений
        Text(
          l10n?.whatsNew ?? 'Что нового',
          style: TextStyle(
            fontSize: 10 * scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2 * scale,
            color: isDark ? Colors.white38 : Colors.black38,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 6 * scale),

        // Поле со списком изменений (Changelog) - адаптивная высота
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 140 * scale,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: borderColor),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Text(
                info.releaseNotes.isNotEmpty
                    ? info.releaseNotes
                    : (l10n?.officialReleaseNotes ?? 'Официальное описание релиза доступно на GitHub'),
                style: TextStyle(
                  fontSize: 12 * scale,
                  height: 1.4,
                  color: isDark ? Colors.white : Colors.black87,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 14 * scale),

        // Прогресс скачивания ИЛИ выбор источника
        if (_isDownloading) ...[
          Container(
            padding: EdgeInsets.all(14 * scale),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _statusText,
                        style: TextStyle(
                          fontSize: 12.5 * scale,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                          fontFamily: 'Inter',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * scale),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6 * scale),
                  child: LinearProgressIndicator(
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    minHeight: 6 * scale,
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),
        ] else ...[
          if (_downloadError != null) ...[
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(30),
                borderRadius: BorderRadius.circular(8 * scale),
                border: Border.all(color: Colors.redAccent.withAlpha(80)),
              ),
              child: Text(
                _downloadError!,
                style: TextStyle(fontSize: 11.5 * scale, color: Colors.redAccent, fontFamily: 'Inter'),
              ),
            ),
            SizedBox(height: 10 * scale),
          ],

          Text(
            l10n?.downloadSource ?? 'Источник загрузки',
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2 * scale,
              color: isDark ? Colors.white38 : Colors.black38,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: 6 * scale),

          Column(
            children: [
              if (info.downloadUrl != null)
                _buildSourceOption(
                  source: UpdateSource.directDownload,
                  title: l10n?.directInAppInstall ?? 'Прямая установка в приложении',
                  subtitle: l10n?.autoDownloadAndRun ?? 'Автоматическое скачивание и запуск',
                  icon: Icons.system_update_rounded,
                  isDark: isDark,
                  scale: scale,
                ),
              if (info.downloadUrl != null) SizedBox(height: 6 * scale),
              _buildSourceOption(
                source: UpdateSource.githubRelease,
                title: l10n?.githubReleasePage ?? 'Страница релиза на GitHub',
                subtitle: info.htmlUrl,
                icon: Icons.open_in_new_rounded,
                isDark: isDark,
                scale: scale,
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
        ],

        // Кнопки управления
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isDownloading
                    ? null
                    : () {
                        UpdateService().ignoreVersion(info.version);
                        Navigator.of(context).pop();
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white60 : Colors.black54,
                  side: BorderSide(color: borderColor),
                  padding: EdgeInsets.symmetric(vertical: 10 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                ),
                child: Text(
                  l10n?.skip ?? 'Пропустить',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _handleUpdateAction,
                icon: _isDownloading
                    ? SizedBox(
                        width: 14 * scale,
                        height: 14 * scale,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.system_update_rounded, size: 16 * scale),
                label: Text(
                  _isDownloading
                      ? (l10n?.installAction ?? 'Установка...')
                      : (l10n?.updateAction ?? 'Обновить'),
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10 * scale),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSourceOption({
    required UpdateSource source,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required double scale,
  }) {
    final isSelected = _selectedSource == source;
    final borderColor = isSelected
        ? const Color(0xFF2563EB)
        : (isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15));
    final bgColor = isSelected
        ? (isDark ? const Color(0xFF2563EB).withAlpha(35) : const Color(0xFF2563EB).withAlpha(15))
        : (isDark ? const Color(0xFF161820) : const Color(0xFFF9FAFB));

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSource = source;
        });
      },
      borderRadius: BorderRadius.circular(12 * scale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white38 : Colors.black38),
              size: 18 * scale,
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11 * scale,
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 16 * scale, color: isDark ? Colors.white54 : Colors.black54),
          ],
        ),
      ),
    );
  }
}
