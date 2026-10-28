import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ScheduledVideoPreview extends StatefulWidget {
  final File? file;
  final String? url;
  const ScheduledVideoPreview({super.key, this.file, this.url});
  @override
  State<ScheduledVideoPreview> createState() => _ScheduledVideoPreviewState();
}

class _ScheduledVideoPreviewState extends State<ScheduledVideoPreview> {
  VideoPlayerController? _video;
  bool _loading = false;
  bool _failed = false;
  Future<void> _play() async {
    if (_loading) return;
    try {
      if (_video == null) {
        setState(() => _loading = true);
        final controller = widget.file != null
            ? VideoPlayerController.file(widget.file!)
            : VideoPlayerController.networkUrl(Uri.parse(widget.url!));
        _video = controller;
        await controller.initialize();
      }
      if (!mounted) return;
      setState(() => _loading = false);
      if (_video!.value.isPlaying) {
        await _video!.pause();
      } else {
        await _video!.play();
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
      height: 180,
      child: ColoredBox(
          color: Colors.black,
          child: _failed
              ? const Icon(Icons.broken_image_outlined, color: Colors.white)
              : Stack(alignment: Alignment.center, children: [
                  if (_video?.value.isInitialized ?? false)
                    AspectRatio(
                        aspectRatio: _video!.value.aspectRatio,
                        child: VideoPlayer(_video!)),
                  if (_loading)
                    const CircularProgressIndicator()
                  else
                    IconButton(
                        onPressed: _play,
                        color: Colors.white,
                        iconSize: 40,
                        icon: Icon((_video?.value.isPlaying ?? false)
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline)),
                ])));
}
