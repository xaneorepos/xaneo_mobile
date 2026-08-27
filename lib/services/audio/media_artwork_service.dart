import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/ssl_helper.dart';

/// Produces notification artwork with a small Xaneo badge in the bottom-right.
/// The app logo is never used as the full-size track cover.
class MediaArtworkService {
  MediaArtworkService._();

  static final MediaArtworkService instance = MediaArtworkService._();

  static const int _canvasSize = 512;
  final Map<String, Future<Uri>> _pendingArtwork = {};
  ui.Image? _logo;

  Future<Uri> artworkFor({
    required String trackId,
    required String title,
    Uri? source,
  }) {
    final key = '${source ?? 'fallback'}|$trackId|$title';
    return _pendingArtwork.putIfAbsent(
      key,
      () => _createArtwork(key: key, title: title, source: source),
    );
  }

  Future<Uri> _createArtwork({
    required String key,
    required String title,
    required Uri? source,
  }) async {
    final tempDirectory = await getTemporaryDirectory();
    final output = File(
      '${tempDirectory.path}/xaneo_media_art_${key.hashCode}.png',
    );
    if (await output.exists() && await output.length() > 0) {
      return output.uri;
    }

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const size = ui.Size(512, 512);
    final cover = await _loadSourceImage(source);

    if (cover != null) {
      _drawCover(canvas, size, cover);
    } else {
      _drawFallback(canvas, size, title);
    }
    await _drawXaneoBadge(canvas, size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(_canvasSize, _canvasSize);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    cover?.dispose();

    if (data == null) {
      throw StateError('Failed to encode media artwork');
    }
    await output.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return output.uri;
  }

  Future<ui.Image?> _loadSourceImage(Uri? source) async {
    if (source == null) return null;
    try {
      Uint8List bytes;
      if (source.scheme == 'file' || source.scheme.isEmpty) {
        final file = File(
          source.scheme == 'file' ? source.toFilePath() : source.path,
        );
        bytes = await file.readAsBytes();
      } else if (source.scheme == 'http' || source.scheme == 'https') {
        final dio = Dio();
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback = allowConfiguredDevelopmentCertificate;
          return client;
        };
        final response = await dio.get<List<int>>(
          source.toString(),
          options: Options(responseType: ResponseType.bytes),
        );
        bytes = Uint8List.fromList(response.data ?? const <int>[]);
      } else {
        return null;
      }
      if (bytes.isEmpty) return null;
      return _decodeImage(bytes);
    } catch (_) {
      return null;
    }
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  void _drawCover(ui.Canvas canvas, ui.Size size, ui.Image cover) {
    final sourceAspect = cover.width / cover.height;
    final targetAspect = size.width / size.height;
    late ui.Rect sourceRect;
    if (sourceAspect > targetAspect) {
      final width = cover.height * targetAspect;
      sourceRect = ui.Rect.fromLTWH(
        (cover.width - width) / 2,
        0,
        width,
        cover.height.toDouble(),
      );
    } else {
      final height = cover.width / targetAspect;
      sourceRect = ui.Rect.fromLTWH(
        0,
        (cover.height - height) / 2,
        cover.width.toDouble(),
        height,
      );
    }
    canvas.drawImageRect(
      cover,
      sourceRect,
      ui.Offset.zero & size,
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );
  }

  void _drawFallback(ui.Canvas canvas, ui.Size size, String title) {
    final hueSeed = title.codeUnits.fold<int>(0, (sum, code) => sum + code);
    final accent = ui.Color.fromARGB(
      255,
      44 + (hueSeed % 52),
      48 + ((hueSeed ~/ 3) % 48),
      68 + ((hueSeed ~/ 7) % 64),
    );
    canvas.drawRect(
      ui.Offset.zero & size,
      ui.Paint()
        ..shader = ui.Gradient.linear(
          ui.Offset.zero,
          ui.Offset(size.width, size.height),
          [const ui.Color(0xFF111318), accent],
        ),
    );

    final notePaint = ui.Paint()
      ..color = const ui.Color(0xD9FFFFFF)
      ..style = ui.PaintingStyle.fill;
    canvas.drawCircle(const ui.Offset(205, 334), 42, notePaint);
    canvas.drawCircle(const ui.Offset(338, 302), 42, notePaint);
    canvas.drawRect(const ui.Rect.fromLTWH(238, 150, 24, 184), notePaint);
    canvas.drawRect(const ui.Rect.fromLTWH(371, 118, 24, 184), notePaint);
    final beam = ui.Path()
      ..moveTo(250, 150)
      ..lineTo(383, 118)
      ..lineTo(383, 171)
      ..lineTo(250, 203)
      ..close();
    canvas.drawPath(beam, notePaint);
  }

  Future<void> _drawXaneoBadge(ui.Canvas canvas, ui.Size size) async {
    const radius = 58.0;
    final center = ui.Offset(size.width - 70, size.height - 70);
    canvas.drawCircle(
      center + const ui.Offset(0, 4),
      radius + 3,
      ui.Paint()
        ..color = const ui.Color(0x66000000)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8),
    );
    canvas.drawCircle(
        center, radius, ui.Paint()..color = const ui.Color(0xEE090909));
    canvas.drawCircle(
      center,
      radius,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const ui.Color(0x55FFFFFF),
    );

    final logo = await _loadLogo();
    final destination = ui.Rect.fromCenter(
      center: center,
      width: radius * 1.65,
      height: radius * 1.65,
    );
    canvas.drawImageRect(
      logo,
      ui.Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      destination,
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );
  }

  Future<ui.Image> _loadLogo() async {
    final cached = _logo;
    if (cached != null) return cached;
    final data = await rootBundle.load('assets/images/logo.png');
    return _logo = await _decodeImage(data.buffer.asUint8List());
  }
}
