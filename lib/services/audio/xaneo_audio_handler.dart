import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Owns the app-wide audio player and publishes its state to Android/iOS.
///
/// [PlaybackProvider] remains the Flutter UI facade, while this handler is the
/// single source of truth for the platform MediaSession.
class XaneoAudioHandler extends BaseAudioHandler {
  XaneoAudioHandler() {
    _playbackEventSubscription = player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object error, StackTrace stackTrace) {
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            errorCode: 1,
            errorMessage: error.toString(),
          ),
        );
      },
    );
    _currentIndexSubscription = player.currentIndexStream.listen(
      _publishCurrentMediaItem,
    );
    _durationSubscription = player.durationStream.listen(_publishDuration);
  }

  final AudioPlayer player = AudioPlayer();

  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  bool _showPlaylistControls = false;

  static const String toggleShuffleAction = 'toggleShuffle';
  static const String toggleRepeatAction = 'toggleRepeat';

  Future<void> loadSingle({
    required AudioSource source,
    required MediaItem item,
  }) async {
    _showPlaylistControls = false;
    queue.add([item]);
    mediaItem.add(item);
    await player.setAudioSource(source);
    _broadcastState(player.playbackEvent);
  }

  Future<void> loadPlaylist({
    required List<AudioSource> sources,
    required List<MediaItem> items,
    required int initialIndex,
  }) async {
    _showPlaylistControls = true;
    queue.add(List<MediaItem>.unmodifiable(items));
    mediaItem.add(items[initialIndex]);
    await player.setAudioSources(
      sources,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );
    _broadcastState(player.playbackEvent);
  }

  void _publishCurrentMediaItem(int? index) {
    final items = queue.value;
    if (index == null || index < 0 || index >= items.length) return;
    mediaItem.add(items[index]);
  }

  void _publishDuration(Duration? duration) {
    final current = mediaItem.value;
    if (current == null || duration == null || duration <= Duration.zero) {
      return;
    }
    if (current.duration == duration) return;

    final updated = current.copyWith(duration: duration);
    mediaItem.add(updated);

    final index = player.currentIndex;
    final items = List<MediaItem>.from(queue.value);
    if (index != null && index >= 0 && index < items.length) {
      items[index] = updated;
      queue.add(List<MediaItem>.unmodifiable(items));
    }
  }

  MediaControl get _shuffleControl => MediaControl.custom(
        androidIcon: player.shuffleModeEnabled
            ? 'drawable/ic_audio_shuffle_on'
            : 'drawable/ic_audio_shuffle',
        label: player.shuffleModeEnabled
            ? 'Отключить случайный порядок'
            : 'Случайный порядок',
        name: toggleShuffleAction,
      );

  MediaControl get _repeatControl => MediaControl.custom(
        androidIcon: switch (player.loopMode) {
          LoopMode.one => 'drawable/ic_audio_repeat_one',
          LoopMode.all => 'drawable/ic_audio_repeat_on',
          LoopMode.off => 'drawable/ic_audio_repeat',
        },
        label: switch (player.loopMode) {
          LoopMode.one => 'Повторять текущий трек',
          LoopMode.all => 'Повторять очередь',
          LoopMode.off => 'Повтор выключен',
        },
        name: toggleRepeatAction,
      );

  void _broadcastState(PlaybackEvent event) {
    final controls = <MediaControl>[
      if (_showPlaylistControls) MediaControl.skipToPrevious,
      if (player.playing) MediaControl.pause else MediaControl.play,
      if (_showPlaylistControls) MediaControl.skipToNext,
      if (_showPlaylistControls) _shuffleControl,
      if (_showPlaylistControls) _repeatControl,
    ];

    playbackState.add(
      PlaybackState(
        controls: controls,
        androidCompactActionIndices:
            _showPlaylistControls ? const [0, 1, 2] : const [0],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        processingState: switch (player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: player.playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: event.currentIndex,
        repeatMode: switch (player.loopMode) {
          LoopMode.off => AudioServiceRepeatMode.none,
          LoopMode.one => AudioServiceRepeatMode.one,
          LoopMode.all => AudioServiceRepeatMode.all,
        },
        shuffleMode: player.shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    await player.seek(Duration.zero, index: index);
    await player.play();
  }

  @override
  Future<void> skipToNext() async {
    if (player.hasNext) {
      await player.seekToNext();
      await player.play();
    } else if (player.loopMode == LoopMode.all && queue.value.length > 1) {
      await skipToQueueItem(0);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (player.position > const Duration(seconds: 3)) {
      await player.seek(Duration.zero);
      return;
    }
    if (player.hasPrevious) {
      await player.seekToPrevious();
      await player.play();
    } else if (player.loopMode == LoopMode.all && queue.value.length > 1) {
      await skipToQueueItem(queue.value.length - 1);
    } else {
      await player.seek(Duration.zero);
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await player.setShuffleModeEnabled(
      shuffleMode != AudioServiceShuffleMode.none,
    );
    _broadcastState(player.playbackEvent);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await player.setLoopMode(
      switch (repeatMode) {
        AudioServiceRepeatMode.none => LoopMode.off,
        AudioServiceRepeatMode.one => LoopMode.one,
        AudioServiceRepeatMode.all ||
        AudioServiceRepeatMode.group =>
          LoopMode.all,
      },
    );
    _broadcastState(player.playbackEvent);
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    switch (name) {
      case toggleShuffleAction:
        await setShuffleMode(
          player.shuffleModeEnabled
              ? AudioServiceShuffleMode.none
              : AudioServiceShuffleMode.all,
        );
        return null;
      case toggleRepeatAction:
        await setRepeatMode(
          switch (player.loopMode) {
            LoopMode.off => AudioServiceRepeatMode.all,
            LoopMode.all => AudioServiceRepeatMode.one,
            LoopMode.one => AudioServiceRepeatMode.none,
          },
        );
        return null;
      default:
        return super.customAction(name, extras);
    }
  }

  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }

  Future<void> disposeHandler() async {
    await _playbackEventSubscription?.cancel();
    await _currentIndexSubscription?.cancel();
    await _durationSubscription?.cancel();
    await player.dispose();
  }
}
