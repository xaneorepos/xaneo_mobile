import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class BlurHashPlaceholder extends StatefulWidget {
  final String? hash;
  final Color fallbackColor;
  final Color iconColor;
  final double iconSize;

  const BlurHashPlaceholder({
    super.key,
    required this.hash,
    required this.fallbackColor,
    required this.iconColor,
    this.iconSize = 30,
  });

  @override
  State<BlurHashPlaceholder> createState() => _BlurHashPlaceholderState();
}

class _BlurHashPlaceholderState extends State<BlurHashPlaceholder> {
  ui.Image? _image;
  int _decodeGeneration = 0;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(covariant BlurHashPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hash != widget.hash) _decode();
  }

  Future<void> _decode() async {
    final generation = ++_decodeGeneration;
    final hash = widget.hash?.trim() ?? '';
    if (hash.isEmpty) {
      _replaceImage(null);
      return;
    }
    try {
      final pixels = decodeBlurHash(hash, width: 32, height: 32);
      final image = await _imageFromPixels(pixels, 32, 32);
      if (!mounted || generation != _decodeGeneration) {
        image.dispose();
        return;
      }
      _replaceImage(image);
    } catch (_) {
      if (mounted && generation == _decodeGeneration) _replaceImage(null);
    }
  }

  void _replaceImage(ui.Image? next) {
    if (!mounted) return;
    final previous = _image;
    setState(() => _image = next);
    if (!identical(previous, next)) previous?.dispose();
  }

  @override
  void dispose() {
    _decodeGeneration++;
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.fallbackColor,
      child: _image == null
          ? Center(
              child: Icon(
                Icons.image_outlined,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
            )
          : RawImage(image: _image, fit: BoxFit.fill),
    );
  }
}

Future<ui.Image> _imageFromPixels(
    Uint8List pixels, int width, int height) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
  final descriptor = ui.ImageDescriptor.raw(
    buffer,
    width: width,
    height: height,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final codec = await descriptor.instantiateCodec();
  final frame = await codec.getNextFrame();
  codec.dispose();
  descriptor.dispose();
  buffer.dispose();
  return frame.image;
}

Uint8List decodeBlurHash(
  String hash, {
  required int width,
  required int height,
  double punch = 1,
}) {
  if (hash.length < 6 || width < 1 || height < 1) {
    throw const FormatException('Invalid blurhash');
  }
  final sizeFlag = _decode83(hash, 0, 1);
  final componentsX = sizeFlag % 9 + 1;
  final componentsY = sizeFlag ~/ 9 + 1;
  if (hash.length != 4 + 2 * componentsX * componentsY) {
    throw const FormatException('Invalid blurhash length');
  }
  final maximumValue = (_decode83(hash, 1, 2) + 1) / 166 * punch;
  final colors = <List<double>>[_decodeDc(_decode83(hash, 2, 6))];
  for (var i = 1; i < componentsX * componentsY; i++) {
    colors.add(_decodeAc(_decode83(hash, 4 + i * 2, 6 + i * 2), maximumValue));
  }

  final pixels = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      var r = 0.0;
      var g = 0.0;
      var b = 0.0;
      for (var j = 0; j < componentsY; j++) {
        for (var i = 0; i < componentsX; i++) {
          final basis = math.cos(math.pi * x * i / width) *
              math.cos(math.pi * y * j / height);
          final color = colors[i + j * componentsX];
          r += color[0] * basis;
          g += color[1] * basis;
          b += color[2] * basis;
        }
      }
      final offset = 4 * (x + y * width);
      pixels[offset] = _linearToSrgb(r);
      pixels[offset + 1] = _linearToSrgb(g);
      pixels[offset + 2] = _linearToSrgb(b);
      pixels[offset + 3] = 255;
    }
  }
  return pixels;
}

const _base83 =
    r'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~';

int _decode83(String value, int start, int end) {
  var result = 0;
  for (var i = start; i < end; i++) {
    final digit = _base83.indexOf(value[i]);
    if (digit < 0) throw const FormatException('Invalid blurhash character');
    result = result * 83 + digit;
  }
  return result;
}

List<double> _decodeDc(int value) => [
      _srgbToLinear(value >> 16),
      _srgbToLinear((value >> 8) & 255),
      _srgbToLinear(value & 255),
    ];

List<double> _decodeAc(int value, double maximumValue) => [
      value ~/ (19 * 19),
      value ~/ 19 % 19,
      value % 19,
    ]
        .map((component) => _signPow((component - 9) / 9, 2) * maximumValue)
        .toList(growable: false);

double _signPow(double value, double exponent) =>
    math.pow(value.abs(), exponent).toDouble() * (value < 0 ? -1 : 1);

double _srgbToLinear(int value) {
  final normalized = value / 255;
  return normalized <= 0.04045
      ? normalized / 12.92
      : math.pow((normalized + 0.055) / 1.055, 2.4).toDouble();
}

int _linearToSrgb(double value) {
  final clamped = value.clamp(0.0, 1.0);
  final result = clamped <= 0.0031308
      ? clamped * 12.92
      : 1.055 * math.pow(clamped, 1 / 2.4) - 0.055;
  return (result * 255 + 0.5).floor().clamp(0, 255).toInt();
}
