import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../services/database/app_database.dart';
import '../../providers/playback_provider.dart';

import 'base_custom_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Модальное окно списка музыки для мобильного приложения на базе BaseCustomModal.
class MusicPlaylistModal extends BaseCustomModal {
  final List<Message> messages;
  final String? jwtToken;

  const MusicPlaylistModal({
    super.key,
    required this.messages,
    this.jwtToken,
  });

  static Future<void> show(
      BuildContext context, List<Message> messages, String? jwtToken) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          MusicPlaylistModal(messages: messages, jwtToken: jwtToken),
    );
  }

  @override
  State<MusicPlaylistModal> createState() => _MusicPlaylistModalState();
}

class _MusicPlaylistModalState
    extends BaseCustomModalState<MusicPlaylistModal> {
  @override
  double get initialExtent => 0.65;

  @override
  double get minExtent => 0.35;

  @override
  double get maxExtent => 0.95;

  String _formatBytes(int bytes) {
    if (bytes <= 0)
      return (AppLocalizations.of(context)?.loc_0B_5a4d ?? 'Fallback');
    var suffixes = [
      (AppLocalizations.of(context)?.b_3b67 ?? 'Fallback'),
      (AppLocalizations.of(context)?.kb_419d ?? 'Fallback'),
      (AppLocalizations.of(context)?.mb_b808 ?? 'Fallback'),
      (AppLocalizations.of(context)?.gb_e572 ?? 'Fallback')
    ];
    var i = (log(bytes) / log(1024)).floor();
    if (i >= suffixes.length) i = suffixes.length - 1;
    return ((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
  }

  Map<String, dynamic>? _getAttachmentData(Message msg) {
    if (msg.fileUrl != null && msg.fileUrl!.isNotEmpty) {
      try {
        final decoded = jsonDecode(msg.fileUrl!);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {}
    }
    return null;
  }

  List<PlaybackItem> _getMusicPlaylistFromMessages() {
    final playlist = <PlaybackItem>[];
    final uri = Uri.parse(AppConfig.apiBaseUrl);
    final hostUrl =
        '${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}';
    final tokenToUse = widget.jwtToken;

    for (final msg in widget.messages) {
      final fileData = _getAttachmentData(msg);
      if (fileData == null) continue;
      final type = fileData['type']?.toString().toLowerCase() ?? '';
      if (type == 'voice' || type == 'video_message') continue;

      final fileName = fileData['file_name']?.toString() ??
          fileData['name']?.toString() ??
          (AppLocalizations.of(context)?.audiozapis_867d ?? 'Fallback');
      final lowerName = fileName.toLowerCase();
      final mime = fileData['mime_type']?.toString().toLowerCase() ??
          fileData['type']?.toString().toLowerCase() ??
          '';

      final isAudioMusic = type == 'audio' ||
          (mime.startsWith('audio/') &&
              !lowerName.contains('voice') &&
              !lowerName.endsWith('.ogg') &&
              !lowerName.endsWith('.opus')) ||
          lowerName.endsWith('.mp3') ||
          lowerName.endsWith('.wav') ||
          lowerName.endsWith('.m4a') ||
          lowerName.endsWith('.flac') ||
          lowerName.endsWith('.aac') ||
          lowerName.endsWith('.wma');

      if (isAudioMusic) {
        final fileUrlSuffix = fileData['file_url']?.toString() ??
            fileData['url']?.toString() ??
            '';
        String absoluteUrl = '';
        if (fileUrlSuffix.startsWith('http')) {
          absoluteUrl =
              '$fileUrlSuffix${tokenToUse != null ? (fileUrlSuffix.contains('?') ? "&token=$tokenToUse" : "?token=$tokenToUse") : ""}';
        } else {
          final prefix = fileUrlSuffix.startsWith('/') ? '' : '/';
          absoluteUrl =
              '$hostUrl$prefix$fileUrlSuffix${tokenToUse != null ? "?token=$tokenToUse" : ""}';
        }

        playlist.add(PlaybackItem(
          url: absoluteUrl,
          title: fileName,
          subtitle: _formatBytes(
              fileData['file_size'] as int? ?? fileData['size'] as int? ?? 0),
          mimeType: mime,
        ));
      }
    }
    return playlist;
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final playlist = _getMusicPlaylistFromMessages();

    return Consumer<PlaybackProvider>(
      builder: (context, playback, child) {
        final items =
            playback.playlist.isNotEmpty ? playback.playlist : playlist;

        return Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF4ADE80).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.queue_music_rounded,
                    color: Color(0xFF4ADE80),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (AppLocalizations.of(context)?.spisokMuzyki_57d0 ??
                            'Fallback'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${AppLocalizations.of(context)?.music ?? 'Music'} • ${items.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        (AppLocalizations.of(context)
                                ?.muzykalnyeTrekiOtsutstvuyut_3301 ??
                            'Fallback'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isCurrent = playback.currentAudioUrl == item.url;
                        final isPlaying = isCurrent && playback.isPlaying;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFF4ADE80).withOpacity(0.15)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isCurrent
                                  ? const Color(0xFF4ADE80).withOpacity(0.4)
                                  : Colors.transparent,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrent
                                    ? const Color(0xFF4ADE80)
                                    : Colors.white.withOpacity(0.1),
                              ),
                              child: Center(
                                child: Icon(
                                  isCurrent
                                      ? (isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded)
                                      : Icons.music_note_rounded,
                                  color:
                                      isCurrent ? Colors.black : Colors.white70,
                                  size: 18,
                                ),
                              ),
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isCurrent
                                    ? const Color(0xFF4ADE80)
                                    : Colors.white,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              item.subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                            onTap: () {
                              if (playback.playlist.isEmpty) {
                                playback.setPlaylist(items,
                                    initialUrl: item.url);
                              }
                              playback.playItemAtIndex(index);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
