import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../providers/playback_provider.dart';
import 'base_custom_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';

enum MusicPlaybackMode {
  floatingBar,
  topBar,
  card,
}

/// Виджет играющей музыки с возможностью паузы/воспроизведения,
/// плавной перемотки (seek bar), переключения треков (prev/next) и открытия полного плеера.
class MusicPlaybackWidget extends StatefulWidget {
  final MusicPlaybackMode mode;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const MusicPlaybackWidget({
    super.key,
    this.mode = MusicPlaybackMode.floatingBar,
    this.onTap,
    this.onClose,
  });

  @override
  State<MusicPlaybackWidget> createState() => _MusicPlaybackWidgetState();
}

class _MusicPlaybackWidgetState extends State<MusicPlaybackWidget>
    with SingleTickerProviderStateMixin {
  double? _dragValue;
  late AnimationController _equalizerController;

  @override
  void initState() {
    super.initState();
    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _equalizerController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackProvider>();
    if (playback.currentAudioUrl == null) {
      return const SizedBox.shrink();
    }

    final isPlaying = playback.isPlaying;
    final title = playback.title.isEmpty
        ? (AppLocalizations.of(context)?.audiozapis_867d ?? 'Аудиозапись')
        : playback.title;
    final subtitle = playback.subtitle;
    final position = playback.position;
    final duration = playback.duration;

    final double progress = _dragValue ??
        (duration > Duration.zero
            ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
            : 0.0);

    final displayPos = _dragValue != null && duration > Duration.zero
        ? Duration(milliseconds: (_dragValue! * duration.inMilliseconds).round())
        : position;

    switch (widget.mode) {
      case MusicPlaybackMode.topBar:
        return _buildTopBar(
          context,
          playback,
          isPlaying,
          title,
          subtitle,
          displayPos,
          duration,
          progress,
        );
      case MusicPlaybackMode.card:
        return _buildCard(
          context,
          playback,
          isPlaying,
          title,
          subtitle,
          displayPos,
          duration,
          progress,
        );
      case MusicPlaybackMode.floatingBar:
        return _buildFloatingBar(
          context,
          playback,
          isPlaying,
          title,
          subtitle,
          displayPos,
          duration,
          progress,
        );
    }
  }

  /// 1. Плавающий медиа-бар (для MainScreen / нижней панели)
  Widget _buildFloatingBar(
    BuildContext context,
    PlaybackProvider playback,
    bool isPlaying,
    String title,
    String subtitle,
    Duration displayPos,
    Duration duration,
    double progress,
  ) {
    return GestureDetector(
      onTap: widget.onTap ?? () => MusicFullPlayerModal.show(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xEE161B26), // Frosted slate glass
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 6),
                child: Row(
                  children: [
                    // Обложка / иконка с анимированным эквалайзером
                    _buildAlbumArtBadge(isPlaying, size: 40),
                    const SizedBox(width: 12),

                    // Название трека и исполнитель
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (subtitle.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.55),
                                      fontSize: 11.5,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              Text(
                                duration > Duration.zero
                                    ? '${_formatDuration(displayPos)} / ${_formatDuration(duration)}'
                                    : _formatDuration(displayPos),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Кнопки управления (Назад, Play/Pause, Вперед, Закрыть)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Предыдущий трек
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.backwardStep,
                            color: (playback.hasPrevious || playback.position.inSeconds > 3)
                                ? Colors.white
                                : Colors.white24,
                            size: 14,
                          ),
                          onPressed: () => playback.playPrevious(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                          tooltip: 'Предыдущий трек',
                        ),

                        const SizedBox(width: 2),

                        // Play / Pause
                        GestureDetector(
                          onTap: () {
                            if (isPlaying) {
                              playback.pause();
                            } else {
                              playback.resume();
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: FaIcon(
                                isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 2),

                        // Следующий трек
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.forwardStep,
                            color: playback.hasNext ? Colors.white : Colors.white24,
                            size: 14,
                          ),
                          onPressed: playback.hasNext ? () => playback.playNext() : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                          tooltip: 'Следующий трек',
                        ),

                        const SizedBox(width: 2),

                        // Закрыть / остановить
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.white.withValues(alpha: 0.45),
                            size: 20,
                          ),
                          onPressed: widget.onClose ?? () => playback.stop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Полоса перемотки (Интерактивный слайдер)
              _buildProgressBar(playback, duration, progress),
            ],
          ),
        ),
      ),
    );
  }

  /// 2. Верхний компактный бар (для экрана чата)
  Widget _buildTopBar(
    BuildContext context,
    PlaybackProvider playback,
    bool isPlaying,
    String title,
    String subtitle,
    Duration displayPos,
    Duration duration,
    double progress,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF018181B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  // Кнопка назад
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.backwardStep,
                      color: (playback.hasPrevious || playback.position.inSeconds > 3)
                          ? Colors.white
                          : Colors.white24,
                      size: 13,
                    ),
                    onPressed: () => playback.playPrevious(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                  ),

                  // Play / Pause
                  GestureDetector(
                    onTap: () {
                      if (isPlaying) {
                        playback.pause();
                      } else {
                        playback.resume();
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: FaIcon(
                          isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                  ),

                  // Кнопка вперед
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.forwardStep,
                      color: playback.hasNext ? Colors.white : Colors.white24,
                      size: 13,
                    ),
                    onPressed: playback.hasNext ? () => playback.playNext() : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                  ),

                  const SizedBox(width: 6),

                  // Инфо о треке
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onTap ?? () => MusicFullPlayerModal.show(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          if (subtitle.isNotEmpty)
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11,
                                fontFamily: 'Inter',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Время
                  Text(
                    duration > Duration.zero
                        ? '${_formatDuration(displayPos)} / ${_formatDuration(duration)}'
                        : _formatDuration(displayPos),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontFamily: 'Inter',
                    ),
                  ),

                  // Закрыть
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.45),
                      size: 18,
                    ),
                    onPressed: widget.onClose ?? () => playback.stop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                  ),
                ],
              ),
            ),

            // Полоса перемотки
            _buildProgressBar(playback, duration, progress),
          ],
        ),
      ),
    );
  }

  /// 3. Карточка плеера (например, в профиле или модалке)
  Widget _buildCard(
    BuildContext context,
    PlaybackProvider playback,
    bool isPlaying,
    String title,
    String subtitle,
    Duration displayPos,
    Duration duration,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildAlbumArtBadge(isPlaying, size: 50),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle.isNotEmpty ? subtitle : 'Xaneo Music',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressBar(playback, duration, progress),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(displayPos),
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.backwardStep, color: Colors.white, size: 18),
                onPressed: () => playback.playPrevious(),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => isPlaying ? playback.pause() : playback.resume(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FaIcon(
                      isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.forwardStep,
                  color: playback.hasNext ? Colors.white : Colors.white24,
                  size: 18,
                ),
                onPressed: playback.hasNext ? () => playback.playNext() : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Интерактивный прогресс-бар перемотки
  Widget _buildProgressBar(PlaybackProvider playback, Duration duration, double progress) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        activeTrackColor: const Color(0xFF3B82F6),
        inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
        thumbColor: const Color(0xFF60A5FA),
        trackShape: const RectangularSliderTrackShape(),
      ),
      child: SizedBox(
        height: 12,
        child: Slider(
          value: progress.clamp(0.0, 1.0),
          onChanged: (val) {
            setState(() {
              _dragValue = val;
            });
            if (duration > Duration.zero) {
              final targetMs = (val * duration.inMilliseconds).round();
              playback.seekPreview(Duration(milliseconds: targetMs));
            }
          },
          onChangeEnd: (val) {
            setState(() {
              _dragValue = null;
            });
            if (duration > Duration.zero) {
              final targetMs = (val * duration.inMilliseconds).round();
              playback.seek(Duration(milliseconds: targetMs));
            }
          },
        ),
      ),
    );
  }

  /// Значок трека с анимацией эквалайзера
  Widget _buildAlbumArtBadge(bool isPlaying, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: isPlaying
            ? AnimatedBuilder(
                animation: _equalizerController,
                builder: (context, child) {
                  final v = _equalizerController.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildEqBar(size * 0.35 * (0.4 + 0.6 * v)),
                      const SizedBox(width: 2),
                      _buildEqBar(size * 0.35 * (0.9 - 0.5 * v)),
                      const SizedBox(width: 2),
                      _buildEqBar(size * 0.35 * (0.5 + 0.5 * ((v + 0.5) % 1.0))),
                    ],
                  );
                },
              )
            : const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildEqBar(double height) {
    return Container(
      width: 2.5,
      height: height.clamp(3.0, 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Полноэкранное/модальное окно воспроизведения текущей музыки (Full Player Sheet)
class MusicFullPlayerModal extends BaseCustomModal {
  const MusicFullPlayerModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const MusicFullPlayerModal(),
    );
  }

  @override
  State<MusicFullPlayerModal> createState() => _MusicFullPlayerModalState();
}

class _MusicFullPlayerModalState
    extends BaseCustomModalState<MusicFullPlayerModal> {
  @override
  double get initialExtent => 0.78;

  @override
  double get minExtent => 0.45;

  @override
  double get maxExtent => 0.95;

  double? _dragValue;

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final playback = context.watch<PlaybackProvider>();

    if (playback.currentAudioUrl == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox.shrink();
    }

    final isPlaying = playback.isPlaying;
    final title = playback.title.isEmpty ? 'Аудиозапись' : playback.title;
    final subtitle = playback.subtitle;
    final position = playback.position;
    final duration = playback.duration;

    final double progress = _dragValue ??
        (duration > Duration.zero
            ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
            : 0.0);

    final displayPos = _dragValue != null && duration > Duration.zero
        ? Duration(milliseconds: (_dragValue! * duration.inMilliseconds).round())
        : position;

    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Верхняя шапка модалки
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (AppLocalizations.of(context)?.music ?? 'Музыка'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Большая обложка трека
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 70,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Название трека
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),

            const SizedBox(height: 6),

            // Исполнитель
            Text(
              subtitle.isNotEmpty ? subtitle : 'Xaneo Player',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),

            const SizedBox(height: 24),

            // Слайдер перемотки
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: const Color(0xFF3B82F6),
                inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                thumbColor: const Color(0xFF60A5FA),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (val) {
                  setState(() {
                    _dragValue = val;
                  });
                  if (duration > Duration.zero) {
                    final targetMs = (val * duration.inMilliseconds).round();
                    playback.seekPreview(Duration(milliseconds: targetMs));
                  }
                },
                onChangeEnd: (val) {
                  setState(() {
                    _dragValue = null;
                  });
                  if (duration > Duration.zero) {
                    final targetMs = (val * duration.inMilliseconds).round();
                    playback.seek(Duration(milliseconds: targetMs));
                  }
                },
              ),
            ),

            // Таймеры
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(displayPos),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Кнопки управления воспроизведением
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Перемотка на -10 сек
                IconButton(
                  icon: const Icon(Icons.replay_10_rounded, color: Colors.white70, size: 28),
                  onPressed: () {
                    final newPos = position - const Duration(seconds: 10);
                    playback.seek(newPos < Duration.zero ? Duration.zero : newPos);
                  },
                  tooltip: '-10 сек',
                ),

                // Предыдущий трек
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.backwardStep,
                    color: (playback.hasPrevious || position.inSeconds > 3)
                        ? Colors.white
                        : Colors.white24,
                    size: 22,
                  ),
                  onPressed: () => playback.playPrevious(),
                  tooltip: 'Предыдущий трек',
                ),

                // Play / Pause
                GestureDetector(
                  onTap: () {
                    if (isPlaying) {
                      playback.pause();
                    } else {
                      playback.resume();
                    }
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: FaIcon(
                        isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Следующий трек
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.forwardStep,
                    color: playback.hasNext ? Colors.white : Colors.white24,
                    size: 22,
                  ),
                  onPressed: playback.hasNext ? () => playback.playNext() : null,
                  tooltip: 'Следующий трек',
                ),

                // Перемотка на +10 сек
                IconButton(
                  icon: const Icon(Icons.forward_10_rounded, color: Colors.white70, size: 28),
                  onPressed: () {
                    final newPos = position + const Duration(seconds: 10);
                    playback.seek(newPos > duration ? duration : newPos);
                  },
                  tooltip: '+10 сек',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Дополнительные кнопки (Случайный порядок / Повтор)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shuffle (Случайный порядок)
                IconButton(
                  icon: Icon(
                    Icons.shuffle_rounded,
                    color: playback.isShuffle ? const Color(0xFF3B82F6) : Colors.white38,
                    size: 22,
                  ),
                  onPressed: () => playback.toggleShuffle(),
                  tooltip: playback.isShuffle ? 'Случайный порядок включен' : 'Случайный порядок выключен',
                ),
                const SizedBox(width: 48),
                // Repeat Mode (Повтор всех / одного / выкл)
                IconButton(
                  icon: Icon(
                    playback.loopMode == LoopMode.one
                        ? Icons.repeat_one_rounded
                        : Icons.repeat_rounded,
                    color: playback.loopMode != LoopMode.off
                        ? const Color(0xFF3B82F6)
                        : Colors.white38,
                    size: 22,
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

            const SizedBox(height: 16),

            // Список треков / плейлист
            if (playback.playlist.isNotEmpty) ...[
              Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppLocalizations.of(context)?.spisokMuzyki_57d0 ?? 'Плейлист'} (${playback.playlist.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: playback.playlist.length,
                itemBuilder: (context, index) {
                  final item = playback.playlist[index];
                  final isCurrent = playback.currentAudioUrl == item.url;
                  final isItemPlaying = isCurrent && playback.isPlaying;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        isCurrent
                            ? (isItemPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded)
                            : Icons.music_note_rounded,
                        color: isCurrent ? const Color(0xFF60A5FA) : Colors.white54,
                        size: 20,
                      ),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isCurrent ? const Color(0xFF60A5FA) : Colors.white,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                      onTap: () {
                        playback.playItemAtIndex(index);
                      },
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
