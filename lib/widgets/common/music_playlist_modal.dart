import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../services/database/app_database.dart';
import '../../services/chat/chat_local_repository.dart';
import '../../providers/playback_provider.dart';
import 'track_artwork.dart';
import '../../utils/audio_metadata.dart';
import '../../styles/app_styles.dart';
import 'base_custom_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Модальное окно списка музыки для мобильного приложения в черно-белых тонах
/// с полной панелью управления воспроизведением (перемотка, prev/next, shuffle, repeat, play/pause)
/// и реактивным обновлением при добавлении треков в чат.
class MusicPlaylistModal extends BaseCustomModal {
  final String? chatServerId;
  final List<dynamic>? initialMessages;
  final List<PlaybackItem>? initialPlaylist;
  final String? jwtToken;

  const MusicPlaylistModal({
    super.key,
    this.chatServerId,
    this.initialMessages,
    this.initialPlaylist,
    this.jwtToken,
  });

  static Future<void> show(
    BuildContext context, {
    String? chatServerId,
    List<dynamic>? initialMessages,
    List<PlaybackItem>? initialPlaylist,
    String? jwtToken,
  }) {
    return BaseCustomModal.show<void>(
      context: context,
      child: MusicPlaylistModal(
        chatServerId: chatServerId,
        initialMessages: initialMessages,
        initialPlaylist: initialPlaylist,
        jwtToken: jwtToken,
      ),
    );
  }

  @override
  State<MusicPlaylistModal> createState() => _MusicPlaylistModalState();
}

class _MusicPlaylistModalState
    extends BaseCustomModalState<MusicPlaylistModal> {
  double? _dragValue;
  late List<PlaybackItem> _cachedPlaylist;
  int _playlistBuildGeneration = 0;
  int? _scheduledMessagesSignature;

  @override
  double get initialExtent => 0.82;

  @override
  double get minExtent => 0.40;

  @override
  double get maxExtent => 0.95;

  @override
  void initState() {
    super.initState();
    _cachedPlaylist = List<PlaybackItem>.from(
      widget.initialPlaylist ?? const <PlaybackItem>[],
    );
  }

  @override
  void dispose() {
    _playlistBuildGeneration++;
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic>? _getAttachmentData(dynamic msg) {
    if (msg is Message) {
      if (msg.fileUrl != null && msg.fileUrl!.isNotEmpty) {
        try {
          final decoded = jsonDecode(msg.fileUrl!);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        } catch (_) {}
      }
    } else if (msg is Map) {
      final fileData = msg['file'] ?? msg['file_data'] ?? msg['attachment'];
      if (fileData is Map<String, dynamic>) return fileData;
      if (fileData is String && fileData.isNotEmpty) {
        try {
          final decoded = jsonDecode(fileData);
          if (decoded is Map<String, dynamic>) return decoded;
        } catch (_) {}
      }
      final fileUrl = msg['file_url']?.toString();
      if (fileUrl != null && fileUrl.isNotEmpty) {
        try {
          final decoded = jsonDecode(fileUrl);
          if (decoded is Map<String, dynamic>) return decoded;
        } catch (_) {
          return Map<String, dynamic>.from(msg);
        }
      }
    }
    return null;
  }

  List<PlaybackItem> _getMusicPlaylistFromMessages(List<dynamic> rawMessages) {
    final playlist = <PlaybackItem>[];
    final uri = Uri.parse(AppConfig.apiBaseUrl);
    final hostUrl =
        '${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}';
    final tokenToUse = widget.jwtToken;

    for (final msg in rawMessages) {
      final rawFileData = _getAttachmentData(msg);
      if (rawFileData == null) continue;
      final fileData = msg is Map
          ? audioPayloadWithMetadata(
              rawFileData,
              Map<String, dynamic>.from(msg),
            )
          : rawFileData;
      final type = fileData['type']?.toString().toLowerCase() ?? '';
      if (type == 'voice' || type == 'video_message') continue;

      final fileName = fileData['file_name']?.toString() ??
          fileData['name']?.toString() ??
          'Аудиозапись';
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

        final coverUriStr = audioTrackCoverUri(fileData);
        final artUri = coverUriStr != null && coverUriStr.isNotEmpty
            ? Uri.tryParse(coverUriStr.startsWith('http')
                ? coverUriStr
                : '$hostUrl${coverUriStr.startsWith('/') ? '' : '/'}$coverUriStr')
            : null;

        final trackDurationSec = audioTrackDuration(fileData);
        final localPath = fileData['local_path']?.toString();
        playlist.add(PlaybackItem(
          url: localPath != null && localPath.isNotEmpty
              ? localPath
              : absoluteUrl,
          title: audioTrackTitle(fileData, fileName),
          subtitle: audioTrackArtist(fileData, fileName),
          mimeType: mime,
          duration:
              trackDurationSec > 0 ? Duration(seconds: trackDurationSec) : null,
          artUri: artUri,
          payload: fileData,
        ));
      }
    }
    return playlist;
  }

  int _messagesSignature(List<dynamic> messages) {
    Object? messageId(dynamic message) {
      if (message is Message) return message.id;
      if (message is Map) return message['id'] ?? message['file_id'];
      return message.hashCode;
    }

    return Object.hash(
      messages.length,
      messages.isEmpty ? null : messageId(messages.first),
      messages.isEmpty ? null : messageId(messages.last),
    );
  }

  void _schedulePlaylistRefresh(List<dynamic> rawMessages) {
    final signature = _messagesSignature(rawMessages);
    if (_scheduledMessagesSignature == signature) return;
    _scheduledMessagesSignature = signature;
    final generation = ++_playlistBuildGeneration;
    final messages = List<dynamic>.from(rawMessages, growable: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final playlist = <PlaybackItem>[];
      const batchSize = 12;
      for (var start = 0; start < messages.length; start += batchSize) {
        if (!mounted || generation != _playlistBuildGeneration) return;
        final end = (start + batchSize).clamp(0, messages.length);
        playlist.addAll(
          _getMusicPlaylistFromMessages(messages.sublist(start, end)),
        );
        await WidgetsBinding.instance.endOfFrame;
      }

      if (!mounted || generation != _playlistBuildGeneration) return;
      setState(() {
        _cachedPlaylist = playlist;
      });
    });
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    if (widget.chatServerId != null && widget.chatServerId!.isNotEmpty) {
      final localChatRepo = context.read<LocalChatRepository>();
      return StreamBuilder<List<Message>>(
        stream: localChatRepo.watchMessagesForServerChat(widget.chatServerId!),
        initialData: widget.initialMessages?.whereType<Message>().toList(),
        builder: (context, snapshot) {
          final rawMessages = snapshot.data ?? widget.initialMessages ?? [];
          _schedulePlaylistRefresh(rawMessages);
          return _buildPlaylistUI(
            context,
            scrollController,
            _cachedPlaylist,
          );
        },
      );
    }

    final rawMessages = widget.initialMessages ?? [];
    _schedulePlaylistRefresh(rawMessages);
    return _buildPlaylistUI(context, scrollController, _cachedPlaylist);
  }

  Widget _buildPlaylistUI(
    BuildContext context,
    ScrollController scrollController,
    List<PlaybackItem> playlist,
  ) {
    final providerPlaylist = context.read<PlaybackProvider>().playlist;
    final items = playlist.isNotEmpty ? playlist : providerPlaylist;
    return Consumer<PlaybackProvider>(
      builder: (context, playback, child) {
        final hasActiveTrack = playback.currentAudioUrl != null;
        final isPlaying = playback.isPlaying;
        final position = playback.position;
        final duration = playback.duration;

        final double progress = _dragValue ??
            (duration > Duration.zero
                ? (position.inMilliseconds / duration.inMilliseconds)
                    .clamp(0.0, 1.0)
                : 0.0);

        final displayPos = _dragValue != null && duration > Duration.zero
            ? Duration(
                milliseconds: (_dragValue! * duration.inMilliseconds).round())
            : position;

        return Column(
          children: [
            // Шапка модального окна
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.xaneoOverlay(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.xaneoOverlay(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.queue_music_rounded,
                      color: context.xaneoTextPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (AppLocalizations.of(context)?.spisokMuzyki_57d0 ??
                            'Список музыки'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.xaneoTextPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${AppLocalizations.of(context)?.music ?? 'Треков'}: ${items.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.xaneoTextMuted,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: context.xaneoTextSecondary,
                    size: 28,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Закрыть',
                ),
              ],
            ),

            const SizedBox(height: 8),
            Divider(
              color: context.xaneoOverlay(0.1),
              height: 1,
            ),
            const SizedBox(height: 8),

            // Position updates rebuild only the controls below. The playlist
            // child is cached by Consumer and listens only to track changes.
            Expanded(child: child!),

            // Компактная нижняя панель управления плеером во всю ширину модалки
            if (hasActiveTrack) ...[
              Container(
                margin: const EdgeInsets.only(left: -20, right: -20, top: 4),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: context.xaneoSurfaceElevated,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                    top: BorderSide(
                      color: context.xaneoOverlay(0.15),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Информация о текущем треке
                    Row(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: ClipOval(
                            child: TrackArtwork(
                              uri: playback.currentArtUri,
                              fallback: ColoredBox(
                                color: context.xaneoOverlay(0.1),
                                child: Icon(
                                  Icons.music_note_rounded,
                                  color: context.xaneoTextPrimary,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                playback.title.isNotEmpty
                                    ? playback.title
                                    : 'Аудиозапись',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.xaneoTextPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              if (playback.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 1),
                                Text(
                                  playback.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.xaneoTextSecondary,
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isPlaying) ...[
                          const SizedBox(width: 8),
                          _buildAnimatedWaveform(),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Слайдер перемотки и таймеры
                    Row(
                      children: [
                        Text(
                          _formatDuration(displayPos),
                          style: TextStyle(
                            color: context.xaneoTextMuted,
                            fontSize: 10.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 2.5,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 10),
                              activeTrackColor: context.xaneoTextPrimary,
                              inactiveTrackColor: context.xaneoOverlay(0.18),
                              thumbColor: context.xaneoTextPrimary,
                            ),
                            child: Slider(
                              value: progress.clamp(0.0, 1.0),
                              onChanged: (val) {
                                setState(() {
                                  _dragValue = val;
                                });
                                if (duration > Duration.zero) {
                                  final targetMs =
                                      (val * duration.inMilliseconds).round();
                                  playback.seekPreview(
                                      Duration(milliseconds: targetMs));
                                }
                              },
                              onChangeEnd: (val) {
                                setState(() {
                                  _dragValue = null;
                                });
                                if (duration > Duration.zero) {
                                  final targetMs =
                                      (val * duration.inMilliseconds).round();
                                  playback
                                      .seek(Duration(milliseconds: targetMs));
                                }
                              },
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            color: context.xaneoTextMuted,
                            fontSize: 10.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),

                    // Кнопки управления: Shuffle, Prev, Play/Pause, Next, Repeat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                              width: 36, height: 36),
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: playback.isShuffle
                                ? context.xaneoTextPrimary
                                : context.xaneoTextMuted,
                            size: 20,
                          ),
                          onPressed: () => playback.toggleShuffle(),
                          tooltip: playback.isShuffle
                              ? 'Случайный порядок включен'
                              : 'Случайный порядок выключен',
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                              width: 38, height: 38),
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            color:
                                (playback.hasPrevious || position.inSeconds > 3)
                                    ? context.xaneoTextPrimary
                                    : context.xaneoTextMuted,
                            size: 26,
                          ),
                          onPressed: () => playback.playPrevious(),
                          tooltip: 'Предыдущий трек',
                        ),
                        GestureDetector(
                          onTap: () {
                            if (isPlaying) {
                              playback.pause();
                            } else {
                              playback.resume();
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.xaneoTextPrimary,
                            ),
                            child: Center(
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                              width: 38, height: 38),
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: playback.hasNext
                                ? context.xaneoTextPrimary
                                : context.xaneoTextMuted,
                            size: 26,
                          ),
                          onPressed: playback.hasNext
                              ? () => playback.playNext()
                              : null,
                          tooltip: 'Следующий трек',
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                              width: 36, height: 36),
                          icon: Icon(
                            playback.loopMode == LoopMode.one
                                ? Icons.repeat_one_rounded
                                : Icons.repeat_rounded,
                            color: playback.loopMode != LoopMode.off
                                ? context.xaneoTextPrimary
                                : context.xaneoTextMuted,
                            size: 20,
                          ),
                          onPressed: () => playback.toggleLoopMode(),
                          tooltip: playback.loopMode == LoopMode.one
                              ? 'Повтор одного трека'
                              : playback.loopMode == LoopMode.all
                                  ? 'Повтор всех треков'
                                  : 'Без повтора',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
      child: _buildTrackList(context, scrollController, items),
    );
  }

  Widget _buildTrackList(
    BuildContext context,
    ScrollController scrollController,
    List<PlaybackItem> items,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.music_off_rounded,
              size: 44,
              color: context.xaneoOverlay(0.25),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)?.muzykalnyeTrekiOtsutstvuyut_3301 ??
                  'Музыкальные треки отсутствуют',
              style: TextStyle(
                color: context.xaneoTextMuted,
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    return Selector<PlaybackProvider, ({String? url, bool playing})>(
      selector: (_, playback) => (
        url: playback.currentAudioUrl,
        playing: playback.isPlaying,
      ),
      builder: (context, playbackState, _) => ListView.builder(
        controller: scrollController,
        itemCount: items.length,
        padding: const EdgeInsets.only(bottom: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isCurrent = playbackState.url == item.url;
          final isItemPlaying = isCurrent && playbackState.playing;
          final artistText = item.subtitle.isNotEmpty
              ? item.subtitle
              : (AppLocalizations.of(context)?.audiozapis_867d ??
                  'Аудиозапись');

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: isCurrent
                  ? context.xaneoOverlay(0.12)
                  : context.xaneoOverlay(0.035),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent
                    ? context.xaneoOverlay(0.4)
                    : context.xaneoDivider,
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.read<PlaybackProvider>().playFromPlaylist(
                      items,
                      selectedUrl: item.url,
                    ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent
                              ? context.xaneoTextPrimary
                              : context.xaneoOverlay(0.08),
                        ),
                        child: Center(
                          child: Icon(
                            isCurrent
                                ? (isItemPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded)
                                : Icons.music_note_rounded,
                            color: isCurrent
                                ? context.xaneoSurface
                                : context.xaneoTextSecondary,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.xaneoTextPrimary,
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              artistText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.xaneoTextMuted,
                                fontSize: 11,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.duration != null &&
                          item.duration! > Duration.zero)
                        Text(
                          _formatDuration(item.duration!),
                          style: TextStyle(
                            color: context.xaneoTextMuted,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                      if (isItemPlaying) ...[
                        const SizedBox(width: 8),
                        _buildAnimatedWaveform(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedWaveform() {
    return Icon(
      Icons.graphic_eq_rounded,
      color: context.xaneoTextPrimary,
      size: 18,
    );
  }
}
