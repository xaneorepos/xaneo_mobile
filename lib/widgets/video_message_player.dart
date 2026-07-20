import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../providers/playback_provider.dart';
import '../utils/local_proxy.dart';
import '../services/chat/chat_local_repository.dart';
import '../services/database/app_database.dart';
import '../services/auth/token_storage.dart';

class VideoMessagePlayer extends StatefulWidget {
  final String videoUrl;
  final String? jwtToken;
  final double duration;
  final String? localPath;
  final String? senderName;
  final String? messageId;

  const VideoMessagePlayer({
    super.key,
    required this.videoUrl,
    this.jwtToken,
    required this.duration,
    this.localPath,
    this.senderName,
    this.messageId,
  });

  @override
  State<VideoMessagePlayer> createState() => _VideoMessagePlayerState();
}

class _VideoMessagePlayerState extends State<VideoMessagePlayer> with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  PlaybackProvider? _playbackProvider;
  static final Set<String> _downloadingUrls = {};

  Uint8List? _thumbnailData;
  static final Map<String, Uint8List> _thumbnailCache = {};

  static final Map<String, VideoPlayerController> _controllerCache = {};
  static final List<String> _controllerCacheOrder = [];
  static const int _maxCachedControllers = 3;
  static final Set<VideoPlayerController> _activeControllers = {};

  static void _cacheController(String url, VideoPlayerController controller) {
    if (_controllerCache.containsKey(url)) {
      _controllerCacheOrder.remove(url);
    }
    _controllerCache[url] = controller;
    _controllerCacheOrder.add(url);

    if (_controllerCacheOrder.length > _maxCachedControllers) {
      final oldestUrl = _controllerCacheOrder.removeAt(0);
      final oldestController = _controllerCache.remove(oldestUrl);
      if (oldestController != null) {
        if (!_activeControllers.contains(oldestController)) {
          oldestController.dispose();
        }
      }
    }
  }

  static void _clearControllerCache() {
    for (final controller in _controllerCache.values) {
      if (!_activeControllers.contains(controller)) {
        controller.dispose();
      }
    }
    _controllerCache.clear();
    _controllerCacheOrder.clear();
  }

  static VideoPlayerController? _getOrCreateController(String url) {
    if (_controllerCache.containsKey(url)) {
      _controllerCacheOrder.remove(url);
      _controllerCacheOrder.add(url);
      return _controllerCache[url];
    }
    return null;
  }

  @override
  bool get wantKeepAlive {
    if (_playbackProvider == null) return false;
    return _playbackProvider!.currentAudioUrl == widget.videoUrl && _playbackProvider!.isVideo;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newProvider = Provider.of<PlaybackProvider>(context);
    if (_playbackProvider != newProvider) {
      _playbackProvider?.removeListener(_onPlaybackProviderChanged);
      _playbackProvider = newProvider;
      _playbackProvider?.addListener(_onPlaybackProviderChanged);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
    _initController();
  }

  Future<void> _loadThumbnail() async {
    final videoUrl = widget.videoUrl;
    if (_thumbnailCache.containsKey(videoUrl)) {
      if (mounted) {
        setState(() {
          _thumbnailData = _thumbnailCache[videoUrl];
        });
      }
      return;
    }

    try {
      final proxyUrl = LocalProxy.getProxyUrl(videoUrl, jwtToken: widget.jwtToken);
      final source = (widget.localPath != null && widget.localPath!.isNotEmpty && await File(widget.localPath!).exists())
          ? widget.localPath!
          : proxyUrl;

      final uint8list = await VideoThumbnail.thumbnailData(
        video: source,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 240,
        quality: 40,
      );

      if (uint8list != null) {
        _thumbnailCache[videoUrl] = uint8list;
        if (mounted) {
          setState(() {
            _thumbnailData = uint8list;
          });
        }
      }
    } catch (e) {
      debugPrint('Error generating video message thumbnail: $e');
    }
  }

  Future<void> _downloadAndCacheVideo() async {
    final messageId = widget.messageId;
    final videoUrl = widget.videoUrl;
    if (messageId == null) return;

    if (_downloadingUrls.contains(videoUrl)) return;
    _downloadingUrls.add(videoUrl);

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${appDir.path}/video_messages');
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      final urlWithoutParams = videoUrl.split('?').first;
      const ext = '.mp4';
      final fileName = 'video_${messageId}_${urlWithoutParams.hashCode}$ext';
      final localFilePath = '${mediaDir.path}/$fileName';
      final file = File(localFilePath);

      bool fileExists = await file.exists();
      if (!fileExists) {
        final freshToken = widget.jwtToken ?? await TokenStorage().getAccessToken();
        Uri targetUri = Uri.parse(videoUrl);
        if (freshToken != null && freshToken.isNotEmpty) {
          final newParams = Map<String, String>.from(targetUri.queryParameters);
          newParams['token'] = freshToken;
          targetUri = targetUri.replace(queryParameters: newParams);
        }
        final downloadUrl = targetUri.toString();

        final dio = Dio();
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
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
        );
        if (response.statusCode == 200) {
          fileExists = true;
        }
      }

      if (fileExists) {
        if (mounted) {
          final localChatRepo = Provider.of<LocalChatRepository>(context, listen: false);
          final messages = await localChatRepo.getMessagesByServerIds([messageId]);
          if (messages.isNotEmpty) {
            final message = messages.first;

            Map<String, dynamic> fileData = {};
            if (message.fileUrl != null && message.fileUrl!.isNotEmpty) {
              try {
                fileData = jsonDecode(message.fileUrl!);
              } catch (_) {}
            } else if (message.textContent.trim().startsWith('{')) {
              try {
                fileData = jsonDecode(message.textContent);
              } catch (_) {}
            }

            fileData['local_path'] = localFilePath;
            final updatedJson = jsonEncode(fileData);

            await localChatRepo.updateMessageCompanion(
              MessagesCompanion(
                serverMessageId: Value(message.serverMessageId),
                fileUrl: Value(updatedJson),
                textContent: Value(updatedJson),
              ),
            );
            debugPrint('Cached video message successfully saved to local DB: $localFilePath');
          }
        }
      }
    } catch (e) {
      debugPrint('Error caching video message $messageId: $e');
    } finally {
      _downloadingUrls.remove(videoUrl);
    }
  }

  Future<void> _initController() async {
    try {
      final cached = _getOrCreateController(widget.videoUrl);
      if (cached != null) {
        _controller = cached;
        _activeControllers.add(_controller!);
        _controller!.addListener(_videoListener);
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
        return;
      }

      if (widget.localPath != null && widget.localPath!.isNotEmpty) {
        final file = File(widget.localPath!);
        if (await file.exists()) {
          _controller = VideoPlayerController.file(file);
        }
      }

      if (_controller == null) {
        final proxyUrl = LocalProxy.getProxyUrl(widget.videoUrl, jwtToken: widget.jwtToken, ext: '.mp4');
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(proxyUrl),
        );
        if (widget.messageId != null) {
          _downloadAndCacheVideo();
        }
      }

      _activeControllers.add(_controller!);

      try {
        await _controller!.initialize();
      } catch (e) {
        if (_controllerCache.isNotEmpty) {
          _clearControllerCache();

          _activeControllers.remove(_controller!);
          _controller!.dispose();
          _controller = null;

          if (widget.localPath != null && widget.localPath!.isNotEmpty && await File(widget.localPath!).exists()) {
            _controller = VideoPlayerController.file(File(widget.localPath!));
          } else {
            final proxyUrl = LocalProxy.getProxyUrl(widget.videoUrl, jwtToken: widget.jwtToken, ext: '.mp4');
            _controller = VideoPlayerController.networkUrl(Uri.parse(proxyUrl));
          }

          _activeControllers.add(_controller!);
          await _controller!.initialize();
        } else {
          rethrow;
        }
      }

      _controller!.setLooping(false);
      _controller!.addListener(_videoListener);

      _cacheController(widget.videoUrl, _controller!);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video message player: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    if (_controller == null) return;
    final isPlaying = _controller!.value.isPlaying;
    final isCompleted = _controller!.value.position >= _controller!.value.duration;

    if (isPlaying != _isPlaying) {
      if (mounted) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    }

    if (_playbackProvider != null) {
      final isCurrent = _playbackProvider!.currentAudioUrl == widget.videoUrl && _playbackProvider!.isVideo;
      if (isCurrent) {
        if (isCompleted && _playbackProvider!.isPlaying) {
          _playbackProvider!.setPlaying(false);
        } else if (isPlaying != _playbackProvider!.isPlaying && !isCompleted) {
          _playbackProvider!.setPlaying(isPlaying);
        }
      }
    }
  }

  void _onPlaybackProviderChanged() {
    if (_playbackProvider == null || _controller == null || !_isInitialized) return;

    final isCurrent = _playbackProvider!.currentAudioUrl == widget.videoUrl && _playbackProvider!.isVideo;
    if (isCurrent) {
      final shouldBePlaying = _playbackProvider!.isPlaying;
      if (shouldBePlaying && !_controller!.value.isPlaying) {
        if (_controller!.value.position >= _controller!.value.duration) {
          _controller!.seekTo(Duration.zero);
        }
        _controller!.play();
      } else if (!shouldBePlaying && _controller!.value.isPlaying) {
        _controller!.pause();
      }
    } else {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      }
    }
    updateKeepAlive();
  }

  @override
  void dispose() {
    _playbackProvider?.removeListener(_onPlaybackProviderChanged);
    _controller?.removeListener(_videoListener);
    if (_controller != null) {
      _activeControllers.remove(_controller!);
      if (!_controllerCache.containsValue(_controller)) {
        _controller!.dispose();
      }
    }
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    final playbackProvider = Provider.of<PlaybackProvider>(context, listen: false);
    playbackProvider.playVideo(
      widget.videoUrl,
      'Видеосообщение',
      widget.senderName ?? 'Видеосообщение',
      duration: Duration(milliseconds: (widget.duration * 1000).toInt()),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_hasError) {
      return Container(
        width: 180,
        height: 180,
        decoration: const BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 36),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        width: 180,
        height: 180,
        decoration: const BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_thumbnailData != null)
                Image.memory(
                  _thumbnailData!,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                )
              else
                const SizedBox.expand(
                  child: ColoredBox(color: Colors.black26),
                ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            ),
            child: ClipOval(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),
          ),
          if (!_isPlaying)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}

