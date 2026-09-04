import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../services/audio/audio_track_cache.dart';
import '../services/audio/media_artwork_service.dart';
import '../services/audio/xaneo_audio_handler.dart';
import '../services/auth/token_storage.dart';

class PlaybackItem {
  final String url;
  final String title;
  final String subtitle;
  final String? mimeType;
  final Duration? duration;
  final Uri? artUri;
  final Map<String, dynamic>? payload;

  PlaybackItem({
    required this.url,
    required this.title,
    required this.subtitle,
    this.mimeType,
    this.duration,
    this.artUri,
    this.payload,
  });
}

/// Глобальный провайдер воспроизведения музыки и голосовых сообщений.
class PlaybackProvider extends ChangeNotifier {
  PlaybackProvider(this._audioHandler) : _player = _audioHandler.player {
    _initializePlayerSubscriptions();
  }

  final XaneoAudioHandler _audioHandler;
  final AudioPlayer _player;
  AudioTrackCache? _trackCache;
  Object? _trackCacheDatabaseIdentity;
  StreamSubscription<Set<String>>? _cachedTracksSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _currentIndexSub;
  StreamSubscription? _playbackEventSub;
  StreamSubscription? _loopModeSub;
  StreamSubscription? _shuffleModeSub;

  String? _currentAudioUrl;
  String _title = '';
  String _subtitle = '';
  Uri? _currentArtUri;
  bool _isPlaying = false;
  bool _isInitialized = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;
  final Map<String, double> _downloadProgressByUrl = <String, double>{};
  bool _isSeeking = false;
  bool _isVideo = false;
  bool _playerControlsDismissed = false;

  LoopMode _loopMode = LoopMode.off;
  LoopMode get loopMode => _loopMode;

  bool _isShuffle = false;
  bool get isShuffle => _isShuffle;

  Duration? _seekTargetPosition;
  DateTime? _seekCompletedAt;
  static const _seekSettleWindow = Duration(milliseconds: 600);

  String? get currentAudioUrl => _currentAudioUrl;
  String get title => _title;
  String get subtitle => _subtitle;
  Uri? get currentArtUri => _currentArtUri;
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isInitialized;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isLoading => _isLoading;
  double downloadProgressFor(String url) =>
      (_downloadProgressByUrl[_stableCacheKey(url)] ?? 0.0)
          .clamp(0.0, 1.0)
          .toDouble();
  bool get isVideo => _isVideo;
  bool get showPlayerControls =>
      _currentAudioUrl != null && !_playerControlsDismissed;

  void attachTrackCache(AudioTrackCache cache) {
    if (identical(_trackCacheDatabaseIdentity, cache.databaseIdentity)) return;
    _cachedTracksSub?.cancel();
    _trackCache = cache;
    _trackCacheDatabaseIdentity = cache.databaseIdentity;
    _downloadProgressByUrl.clear();
    _cachedTracksSub = cache.watchCachedSourceUrls().listen(
      (sourceUrls) {
        _downloadProgressByUrl.removeWhere(
          (url, progress) => progress >= 1.0 && !sourceUrls.contains(url),
        );
        for (final sourceUrl in sourceUrls) {
          _downloadProgressByUrl[sourceUrl] = 1.0;
        }
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          debugPrint('Audio cache state subscription failed: $error');
        }
      },
    );
  }

  List<PlaybackItem> _playlist = [];
  int _currentIndex = -1;

  List<String> _queue = [];
  int _queueIndex = -1;

  List<PlaybackItem> get playlist => List.unmodifiable(_playlist);
  int get currentIndex => _currentIndex;
  bool get hasNext =>
      _playlist.isNotEmpty &&
      (_loopMode == LoopMode.all ||
          (_currentIndex >= 0 && _currentIndex < _playlist.length - 1));
  bool get hasPrevious =>
      _playlist.isNotEmpty && (_loopMode == LoopMode.all || _currentIndex > 0);

  String _safeUrlForLog(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return '<local-file>';
    final port = uri.hasPort ? ':${uri.port}' : '';
    final queryMarker = uri.hasQuery ? '?<redacted>' : '';
    return '${uri.scheme}://${uri.host}$port${uri.path}$queryMarker';
  }

  void _initializePlayerSubscriptions() {
    _playbackEventSub = _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace stack) {
        debugPrint('❌ [PlaybackEventStream Error] $e');
        debugPrint('❌ [Error Type]: ${e.runtimeType}');
        if (e is PlayerException) {
          debugPrint(
              '❌ [PlayerException]: code=${e.code}, message="${e.message}"');
        }
        if (e is PlatformException) {
          debugPrint(
              '❌ [PlatformException]: code=${e.code}, message="${e.message}", details=${e.details}');
        }
        debugPrint('❌ [StackTrace]:\n$stack');
      },
    );

    _playerStateSub = _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.playing && _playerControlsDismissed) {
        _playerControlsDismissed = false;
      }

      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = Duration.zero;
        if (_loopMode == LoopMode.one) {
          _restartFrom(Duration.zero);
        } else if (_isShuffle && _playlist.length > 1) {
          final nextIndices = List<int>.generate(_playlist.length, (i) => i)
            ..remove(_currentIndex);
          nextIndices.shuffle();
          if (nextIndices.isNotEmpty) {
            playItemAtIndex(nextIndices.first);
          }
        } else if (hasNext) {
          playNext();
        } else if (_loopMode == LoopMode.all && _playlist.isNotEmpty) {
          playItemAtIndex(0);
        }
      }
      notifyListeners();
    });

    _currentIndexSub = _player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _playlist.length) {
        if (_currentIndex != index) {
          _currentIndex = index;
          final item = _playlist[index];
          _currentAudioUrl = item.url;
          _title = item.title;
          _subtitle = item.subtitle;
          _currentArtUri = item.artUri;
          if (item.duration != null && item.duration! > Duration.zero) {
            _duration = item.duration!;
          }
          notifyListeners();
        }
      }
    });

    _positionSub = _player.positionStream.listen((pos) {
      if (_isSeeking) return;

      if (_seekTargetPosition != null && _seekCompletedAt != null) {
        final elapsed = DateTime.now().difference(_seekCompletedAt!);
        if (elapsed < _seekSettleWindow) {
          final drift = _seekTargetPosition! - pos;
          if (drift > const Duration(milliseconds: 300)) {
            return;
          }
        } else {
          _seekTargetPosition = null;
          _seekCompletedAt = null;
        }
      }

      _position = pos;
      notifyListeners();
    });

    _durationSub = _player.durationStream.listen((dur) {
      if (dur != null && dur > Duration.zero && dur != _duration) {
        _duration = dur;
        notifyListeners();
      }
    });

    _loopModeSub = _player.loopModeStream.listen((mode) {
      if (_loopMode == mode) return;
      _loopMode = mode;
      notifyListeners();
    });

    _shuffleModeSub = _player.shuffleModeEnabledStream.listen((enabled) {
      if (_isShuffle == enabled) return;
      _isShuffle = enabled;
      notifyListeners();
    });
  }

  void setQueue(List<String> urls, int startIndex) {
    _queue = List<String>.from(urls);
    _queueIndex = startIndex;
  }

  Future<String> _ensureLocalFile(PlaybackItem item) async {
    final metadata = _cacheMetadata(item);
    await _saveMetadata(metadata);
    try {
      if (!item.url.startsWith('http')) {
        final localFile = File(item.url);
        if (await localFile.exists() &&
            !await (_trackCache?.hasAudio(metadata.sourceUrl) ??
                Future<bool>.value(false))) {
          await _trackCache?.storeFile(metadata, localFile);
        }
        _setDownloadProgress(item.url, 1.0);
        return item.url;
      }

      final tempDir = await getTemporaryDirectory();
      String ext = '.mp3';
      if (item.mimeType != null) {
        final mime = item.mimeType!.toLowerCase();
        if (mime.contains('webm')) {
          ext = '.webm';
        } else if (mime.contains('ogg') || mime.contains('opus')) {
          ext = '.ogg';
        } else if (mime.contains('mp3')) {
          ext = '.mp3';
        } else if (mime.contains('wav')) {
          ext = '.wav';
        } else if (mime.contains('m4a') || mime.contains('aac')) {
          ext = '.m4a';
        } else if (mime.contains('flac')) {
          ext = '.flac';
        }
      }

      final restored = await _trackCache?.restoreFile(
        metadata.sourceUrl,
        tempDir,
        extension: ext,
      );
      if (restored != null && await restored.exists()) {
        _setDownloadProgress(item.url, 1.0);
        return restored.path;
      }

      final baseUrl = item.url.split('?').first;
      final safeName = baseUrl.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final shortName = safeName.length > 50
          ? safeName.substring(safeName.length - 50)
          : safeName;
      final localFilePath =
          '${tempDir.path}/audio_${baseUrl.hashCode}_$shortName$ext';
      final file = File(localFilePath);

      if (await file.exists() && await file.length() > 0) {
        _setDownloadProgress(item.url, 1.0);
        await _trackCache?.storeFile(metadata, file);
        debugPrint(
            '📁 [Audio Cache] Found file (${await file.length()} bytes): $localFilePath');
        return localFilePath;
      }

      final freshToken = await TokenStorage().getAccessToken();
      Uri targetUri = Uri.parse(item.url);
      if (freshToken != null && freshToken.isNotEmpty) {
        final newParams = Map<String, String>.from(targetUri.queryParameters);
        newParams['token'] = freshToken;
        targetUri = targetUri.replace(queryParameters: newParams);
      }
      final downloadUrl = targetUri.toString();

      if (kDebugMode) {
        debugPrint(
          '⬇️ [Audio Download] ${_safeUrlForLog(downloadUrl)}',
        );
      }

      _setDownloadProgress(item.url, 0.0);

      final dio = Dio();
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

      final response = await dio.download(
        downloadUrl,
        localFilePath,
        options: Options(
          headers: freshToken != null && freshToken.isNotEmpty
              ? {'Authorization': 'Bearer $freshToken'}
              : {},
        ),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            _setDownloadProgress(
              item.url,
              received >= total ? 1.0 : received / total,
            );
          }
        },
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300 && await file.exists()) {
        _setDownloadProgress(item.url, 1.0);
        await _trackCache?.storeFile(metadata, file);
        debugPrint(
            '✅ [Audio Download] Completed (${await file.length()} bytes): $localFilePath');
        return localFilePath;
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [Audio Download Error] ${_safeUrlForLog(item.url)}: '
          '$e\n$stack',
        );
      }
    }

    return item.url;
  }

  void _setDownloadProgress(String url, double progress) {
    final cacheKey = _stableCacheKey(url);
    final normalized = progress.clamp(0.0, 1.0).toDouble();
    final previous = _downloadProgressByUrl[cacheKey];
    if (previous != null &&
        normalized < 1.0 &&
        (normalized - previous).abs() < 0.005) {
      return;
    }
    _downloadProgressByUrl[cacheKey] = normalized;
    notifyListeners();
  }

  AudioTrackMetadata _cacheMetadata(PlaybackItem item) => AudioTrackMetadata(
        sourceUrl: _stableCacheKey(item.url),
        title: item.title,
        artist: item.subtitle,
        album: item.payload?['album']?.toString() ?? '',
        mimeType: item.mimeType,
        duration: item.duration,
        artworkUri: item.artUri,
      );

  String _stableCacheKey(String sourceUrl) {
    final uri = Uri.tryParse(sourceUrl);
    if (uri == null || !uri.hasScheme) return sourceUrl;
    final query = Map<String, String>.from(uri.queryParameters)
      ..remove('token');
    return uri
        .replace(queryParameters: query.isEmpty ? null : query)
        .toString();
  }

  Future<void> _saveMetadata(AudioTrackMetadata metadata) async {
    try {
      await _trackCache?.saveMetadata(metadata);
    } catch (error, stack) {
      debugPrint('⚠️ [Audio Cache] Failed to save metadata: $error\n$stack');
    }
  }

  Future<MediaItem> _createMediaItem(PlaybackItem item) async => MediaItem(
        id: item.url,
        album: item.subtitle.isNotEmpty ? item.subtitle : 'Xaneo Music',
        title: item.title.isNotEmpty ? item.title : 'Аудиозапись',
        artist: item.subtitle.isNotEmpty ? item.subtitle : 'Xaneo',
        duration: item.duration != null && item.duration! > Duration.zero
            ? item.duration
            : null,
        artUri: await MediaArtworkService.instance.artworkFor(
          trackId: item.url,
          title: item.title,
          source: item.artUri,
        ),
      );

  Future<AudioSource> _createAudioSource(PlaybackItem item) async {
    final mediaItem = await _createMediaItem(item);

    final localPath = await _ensureLocalFile(item);
    if (!localPath.startsWith('http')) {
      final file = File(localPath);
      if (await file.exists()) {
        return AudioSource.file(localPath, tag: mediaItem);
      }
    }

    return AudioSource.uri(Uri.parse(item.url), tag: mediaItem);
  }

  Future<void> play(
    String url,
    String title,
    String subtitle, {
    String? mimeType,
    Duration? duration,
    Uri? artUri,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '▶️ [Playback.play] url=${_safeUrlForLog(url)}, '
        'mimeType=$mimeType, duration=$duration',
      );
    }

    if (_currentAudioUrl == url) {
      _playerControlsDismissed = false;
      _togglePlay();
      return;
    }

    if (_playlist.isNotEmpty) {
      final playlistIndex = _playlist.indexWhere((item) => item.url == url);
      if (playlistIndex != -1) {
        await playItemAtIndex(playlistIndex);
        return;
      }
    }

    await stop();

    _currentAudioUrl = url;
    _playerControlsDismissed = false;
    _title = title;
    _subtitle = subtitle;
    _currentArtUri = artUri;
    _isLoading = true;
    _duration = duration ?? Duration.zero;
    notifyListeners();

    try {
      final item = PlaybackItem(
        url: url,
        title: title,
        subtitle: subtitle,
        mimeType: mimeType,
        duration: duration,
        artUri: artUri,
      );

      final audioSource = await _createAudioSource(item);
      final mediaItem = await _createMediaItem(item);
      _currentArtUri = mediaItem.artUri;
      if (kDebugMode) debugPrint('🎵 [Playback.play] Audio source ready');
      await _audioHandler.loadSingle(source: audioSource, item: mediaItem);
      await _audioHandler.setRepeatMode(_toAudioServiceRepeatMode(_loopMode));
      await _audioHandler.setShuffleMode(
        _isShuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
      );

      _isInitialized = true;
      _isLoading = false;

      final playerDuration = _player.duration;
      if (playerDuration != null && playerDuration > Duration.zero) {
        _duration = playerDuration;
      } else if (duration != null) {
        _duration = duration;
      }

      if (!_playerControlsDismissed) {
        await _player.play();
      }
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [Playback Error on play] url=${_safeUrlForLog(url)}: $e',
      );
      debugPrint('❌ [Error Type]: ${e.runtimeType}');
      if (e is PlayerException) {
        debugPrint(
            '❌ [PlayerException]: code=${e.code}, message="${e.message}"');
      }
      if (e is PlatformException) {
        debugPrint(
            '❌ [PlatformException]: code=${e.code}, message="${e.message}", details=${e.details}');
      }
      debugPrint('❌ [StackTrace]:\n$stackTrace');
      _isLoading = false;
      _isInitialized = false;
      _currentAudioUrl = null;
      _currentArtUri = null;
      notifyListeners();
    }
  }

  void _togglePlay() {
    if (_isVideo) {
      _isPlaying = !_isPlaying;
      notifyListeners();
      return;
    }
    if (!_isInitialized || _isSeeking) return;

    if (_isPlaying) {
      _player.pause();
    } else {
      if (_position >= _duration && _duration > Duration.zero) {
        _restartFrom(Duration.zero);
      } else {
        _player.play();
      }
    }
  }

  void pause() {
    if (_isVideo) {
      _isPlaying = false;
      notifyListeners();
    } else {
      if (_isPlaying) {
        _player.pause();
      }
    }
  }

  void resume() {
    if (_isVideo) {
      _isPlaying = true;
      notifyListeners();
    } else {
      if (!_isPlaying && _isInitialized && !_isSeeking) {
        if (_position >= _duration && _duration > Duration.zero) {
          _restartFrom(Duration.zero);
        } else {
          _player.play();
        }
      }
    }
  }

  Future<void> playVideo(String url, String title, String subtitle,
      {Duration? duration}) async {
    if (_currentAudioUrl == url && _isVideo) {
      _togglePlay();
      return;
    }

    await stop();

    _isVideo = true;
    _currentAudioUrl = url;
    _playerControlsDismissed = false;
    _title = title;
    _subtitle = subtitle;
    _currentArtUri = null;
    _isPlaying = true;
    _isInitialized = true;
    _duration = duration ?? Duration.zero;
    notifyListeners();
  }

  void setPlaying(bool playing) {
    if (_isPlaying != playing) {
      _isPlaying = playing;
      notifyListeners();
    }
  }

  void seekPreview(Duration pos) {
    if (!_isInitialized) return;
    if (_duration == Duration.zero) return;
    if (pos > _duration) pos = _duration;
    if (pos < Duration.zero) pos = Duration.zero;

    _position = pos;
    notifyListeners();
  }

  Future<void> seek(Duration pos) async {
    if (!_isInitialized || _isSeeking) return;
    if (_duration == Duration.zero) return;
    if (pos > _duration) pos = _duration;
    if (pos < Duration.zero) pos = Duration.zero;

    _isSeeking = true;
    _position = pos;
    notifyListeners();

    try {
      await _player.seek(pos);
    } catch (_) {
      await _restartFrom(pos);
    }

    _seekTargetPosition = pos;
    _seekCompletedAt = DateTime.now();
    _isSeeking = false;
  }

  Future<void> _restartFrom(Duration pos) async {
    try {
      await _player.seek(pos);
      await _player.play();
    } catch (e) {
      debugPrint('❌ _restartFrom error: $e');
    }
  }

  void toggleLoopMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    _audioHandler.setRepeatMode(_toAudioServiceRepeatMode(_loopMode));
    notifyListeners();
  }

  void setLoopMode(LoopMode mode) {
    _loopMode = mode;
    _audioHandler.setRepeatMode(_toAudioServiceRepeatMode(mode));
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _audioHandler.setShuffleMode(
      _isShuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
    notifyListeners();
  }

  void setShuffle(bool enabled) {
    _isShuffle = enabled;
    _audioHandler.setShuffleMode(
      enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
    notifyListeners();
  }

  void setPlaylist(List<PlaybackItem> items, {String? initialUrl}) {
    _playlist = List.from(items);
    for (final item in _playlist) {
      unawaited(_saveMetadata(_cacheMetadata(item)));
    }
    if (initialUrl != null) {
      _currentIndex = _playlist.indexWhere((item) => item.url == initialUrl);
    } else if (_playlist.isNotEmpty) {
      _currentIndex = 0;
    } else {
      _currentIndex = -1;
    }
    notifyListeners();
  }

  Future<void> playFromPlaylist(
    List<PlaybackItem> items, {
    required String selectedUrl,
  }) async {
    if (items.isEmpty) return;
    final index = items.indexWhere((item) => item.url == selectedUrl);
    if (index < 0) return;

    final queueAlreadyLoaded = _playlist.length == items.length &&
        _playlist.asMap().entries.every(
              (entry) => entry.value.url == items[entry.key].url,
            ) &&
        _player.sequence.length == items.length;

    setPlaylist(items, initialUrl: selectedUrl);
    if (queueAlreadyLoaded && _currentAudioUrl == selectedUrl) {
      _togglePlay();
      return;
    }
    await playItemAtIndex(index);
  }

  Future<void> playItemAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    _currentIndex = index;
    final item = _playlist[index];
    _currentAudioUrl = item.url;
    _playerControlsDismissed = false;
    _title = item.title;
    _subtitle = item.subtitle;
    _currentArtUri = item.artUri;
    _isLoading = true;
    _duration = item.duration ?? Duration.zero;
    notifyListeners();

    if (kDebugMode) {
      debugPrint(
        '▶️ [playItemAtIndex] index=$index, '
        'url=${_safeUrlForLog(item.url)}, totalTracks=${_playlist.length}',
      );
    }

    try {
      final sources = await Future.wait(
        _playlist.map((it) => _createAudioSource(it)),
      );
      final mediaItems = sources
          .map((source) => (source as IndexedAudioSource).tag as MediaItem)
          .toList(growable: false);
      _currentArtUri = mediaItems[index].artUri;

      await _audioHandler.loadPlaylist(
        sources: sources,
        items: mediaItems,
        initialIndex: index,
      );
      await _audioHandler.setRepeatMode(_toAudioServiceRepeatMode(_loopMode));
      await _audioHandler.setShuffleMode(
        _isShuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
      );

      _isInitialized = true;
      _isLoading = false;
      if (!_playerControlsDismissed) {
        await _player.play();
      }
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [Playback Error on playItemAtIndex] index=$index, '
        'url=${_safeUrlForLog(item.url)}: $e',
      );
      debugPrint('❌ [Error Type]: ${e.runtimeType}');
      if (e is PlayerException) {
        debugPrint(
            '❌ [PlayerException]: code=${e.code}, message="${e.message}"');
      }
      if (e is PlatformException) {
        debugPrint(
            '❌ [PlatformException]: code=${e.code}, message="${e.message}", details=${e.details}');
      }
      debugPrint('❌ [StackTrace]:\n$stackTrace');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playNext() async {
    if (_player.hasNext || _loopMode == LoopMode.all) {
      await _audioHandler.skipToNext();
    } else if (_playlist.length > 1) {
      if (_isShuffle) {
        final nextIndices = List<int>.generate(_playlist.length, (i) => i)
          ..remove(_currentIndex);
        nextIndices.shuffle();
        if (nextIndices.isNotEmpty) {
          await playItemAtIndex(nextIndices.first);
          return;
        }
      }
      if (_currentIndex < _playlist.length - 1) {
        await playItemAtIndex(_currentIndex + 1);
      } else if (_loopMode == LoopMode.all) {
        await playItemAtIndex(0);
      }
    }
  }

  Future<void> playPrevious() async {
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    if (_player.hasPrevious || _loopMode == LoopMode.all) {
      await _audioHandler.skipToPrevious();
    } else if (_playlist.length > 1) {
      if (_currentIndex > 0) {
        await playItemAtIndex(_currentIndex - 1);
      } else if (_loopMode == LoopMode.all) {
        await playItemAtIndex(_playlist.length - 1);
      } else {
        await seek(Duration.zero);
      }
    } else {
      await seek(Duration.zero);
    }
  }

  Future<void> stop() async {
    await _audioHandler.stop();

    _currentAudioUrl = null;
    _title = '';
    _subtitle = '';
    _currentArtUri = null;
    _isPlaying = false;
    _isInitialized = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _isLoading = false;
    _isSeeking = false;
    _isVideo = false;
    _playerControlsDismissed = false;
    _seekTargetPosition = null;
    _seekCompletedAt = null;
    notifyListeners();
  }

  /// Скрывает встроенные панели, сохраняя текущий трек в media session.
  /// Если пользователь снова запустит его из системного уведомления или
  /// экрана блокировки, playerStateStream автоматически покажет панели.
  Future<void> dismissPlayerControls() async {
    if (_currentAudioUrl == null) return;
    if (_isVideo) {
      await stop();
      return;
    }

    _playerControlsDismissed = true;
    _isPlaying = false;
    _isLoading = false;
    _isSeeking = false;
    notifyListeners();
    await _audioHandler.pause();
  }

  void next() {
    if (_queue.isNotEmpty && _queueIndex < _queue.length - 1) {
      _queueIndex++;
      final nextUrl = _queue[_queueIndex];
      play(nextUrl, 'Голосовое #${_queueIndex + 1}', _subtitle);
    }
  }

  void previous() {
    if (_queue.isNotEmpty && _queueIndex > 0) {
      _queueIndex--;
      final prevUrl = _queue[_queueIndex];
      play(prevUrl, 'Голосовое #${_queueIndex + 1}', _subtitle);
    }
  }

  @override
  void dispose() {
    _cachedTracksSub?.cancel();
    _playbackEventSub?.cancel();
    _playerStateSub?.cancel();
    _currentIndexSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _loopModeSub?.cancel();
    _shuffleModeSub?.cancel();
    _audioHandler.disposeHandler();
    super.dispose();
  }

  AudioServiceRepeatMode _toAudioServiceRepeatMode(LoopMode mode) =>
      switch (mode) {
        LoopMode.off => AudioServiceRepeatMode.none,
        LoopMode.one => AudioServiceRepeatMode.one,
        LoopMode.all => AudioServiceRepeatMode.all,
      };
}
