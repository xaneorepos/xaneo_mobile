import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import '../../styles/app_styles.dart';
import 'package:xaneo/l10n/app_localizations.dart';

class AvatarCropper extends StatefulWidget {
  final File? imageFile;

  const AvatarCropper({super.key, this.imageFile});

  static Future<File?> show(BuildContext context, File imageFile) async {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AvatarCropper(imageFile: imageFile),
      ),
    );
  }

  @override
  State<AvatarCropper> createState() => _AvatarCropperState();
}

class _AvatarCropperState extends State<AvatarCropper> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;

  double _rotation = 0.0;
  bool _flipHorizontal = false;
  bool _flipVertical = false;

  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSaving = false;

  double? _imageAspectRatio;
  int _lastPointerCount = 1;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  void _loadImageDimensions() {
    final ImageProvider provider = widget.imageFile != null
        ? FileImage(widget.imageFile!)
        : const AssetImage('assets/images/medved.png') as ImageProvider;

    provider.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (ImageInfo info, bool _) {
              if (mounted) {
                setState(() {
                  _imageAspectRatio = info.image.width / info.image.height;
                });
              }
            },
            onError: (dynamic exception, StackTrace? stackTrace) {
              if (mounted) {
                setState(() {
                  _imageAspectRatio = 1.0;
                });
              }
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_imageAspectRatio == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
              (AppLocalizations.of(context)?.redaktirovanie_1167 ?? 'Fallback'),
              style: AppStyles.titleLarge),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
            (AppLocalizations.of(context)?.redaktirovanie_1167 ?? 'Fallback'),
            style: AppStyles.titleLarge),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const FaIcon(FontAwesomeIcons.check,
                    color: Colors.white, size: 18),
            onPressed: _isSaving ? null : _saveCroppedImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double cropSize =
                    math.min(constraints.maxWidth, constraints.maxHeight) * 0.9;
                final double baseWidth;
                final double baseHeight;

                if (_imageAspectRatio! > 1.0) {
                  baseWidth = cropSize * _imageAspectRatio!;
                  baseHeight = cropSize;
                } else {
                  baseWidth = cropSize;
                  baseHeight = cropSize / _imageAspectRatio!;
                }

                final bool isRotatedOdd =
                    ((_rotation / (math.pi / 2)).round() % 2) != 0;
                final double currentW =
                    (isRotatedOdd ? baseHeight : baseWidth) * _scale;
                final double currentH =
                    (isRotatedOdd ? baseWidth : baseHeight) * _scale;

                final double maxOffsetX =
                    math.max(0.0, (currentW - cropSize) / 2);
                final double maxOffsetY =
                    math.max(0.0, (currentH - cropSize) / 2);

                final clampedOffset = Offset(
                  _offset.dx.clamp(-maxOffsetX, maxOffsetX),
                  _offset.dy.clamp(-maxOffsetY, maxOffsetY),
                );

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base background
                    Container(color: Colors.black),

                    // The capture area
                    RepaintBoundary(
                      key: _repaintBoundaryKey,
                      child: Container(
                        width: cropSize,
                        height: cropSize,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            OverflowBox(
                              minWidth: 0.0,
                              maxWidth: double.infinity,
                              minHeight: 0.0,
                              maxHeight: double.infinity,
                              child: Transform.translate(
                                offset: clampedOffset,
                                child: Transform.scale(
                                  scale: _scale,
                                  child: SizedBox(
                                    width: baseWidth,
                                    height: baseHeight,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.diagonal3Values(
                                        _flipHorizontal ? -1.0 : 1.0,
                                        _flipVertical ? -1.0 : 1.0,
                                        1.0,
                                      )..rotateZ(_rotation),
                                      child: widget.imageFile != null
                                          ? Image.file(widget.imageFile!,
                                              fit: BoxFit.fill)
                                          : Image.asset(
                                              'assets/images/medved.png',
                                              fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Overlay with dark mask and white circle border
                    IgnorePointer(
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: CircleOverlayPainter(cropSize: cropSize),
                      ),
                    ),

                    // Full-screen gesture detector so dragging is smooth anywhere
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: (details) {
                          _previousScale = _scale;
                          _offset = clampedOffset;
                          _previousOffset = details.focalPoint;
                          _lastPointerCount = details.pointerCount;
                        },
                        onScaleUpdate: (details) {
                          if (details.pointerCount != _lastPointerCount) {
                            _lastPointerCount = details.pointerCount;
                            _previousOffset = details.focalPoint;
                            return;
                          }
                          setState(() {
                            _scale =
                                math.max(1.0, _previousScale * details.scale);

                            Offset newOffset = _offset +
                                (details.focalPoint - _previousOffset);
                            _offset = newOffset;
                            _previousOffset = details.focalPoint;
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Liquid Glass Toolbar
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 16, top: 8),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      color: Colors.white.withOpacity(0.08),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildGlassToolButton(
                            icon: FontAwesomeIcons.rotateLeft,
                            label: (AppLocalizations.of(context)?.vlevo_1af1 ??
                                'Fallback'),
                            onTap: () =>
                                setState(() => _rotation -= math.pi / 2),
                          ),
                          _buildGlassToolButton(
                            icon: FontAwesomeIcons.rotateRight,
                            label: (AppLocalizations.of(context)?.vpravo_c316 ??
                                'Fallback'),
                            onTap: () =>
                                setState(() => _rotation += math.pi / 2),
                          ),
                          _buildGlassToolButton(
                            icon: FontAwesomeIcons.rightLeft,
                            label: (AppLocalizations.of(context)?.poGor_ff50 ??
                                'Fallback'),
                            isActive: _flipHorizontal,
                            onTap: () => setState(
                                () => _flipHorizontal = !_flipHorizontal),
                          ),
                          _buildGlassToolButton(
                            icon: FontAwesomeIcons.upDown,
                            label: (AppLocalizations.of(context)?.poVert_b4a9 ??
                                'Fallback'),
                            isActive: _flipVertical,
                            onTap: () =>
                                setState(() => _flipVertical = !_flipVertical),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCroppedImage() async {
    if (widget.imageFile == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Capture the exact visible area in the screen boundary Box
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Boundary not found');

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to get byte data');

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/cropped_avatar_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(pngBytes);

      if (mounted) {
        Navigator.of(context).pop(tempFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)?.oshibkaSohraneniya_0387 ?? 'Save error'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildGlassToolButton({
    required FaIconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.white.withOpacity(0.15),
          highlightColor: Colors.white.withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color:
                  isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: isActive
                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  icon,
                  color:
                      isActive ? Colors.white : Colors.white.withOpacity(0.85),
                  size: 16,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color:
                        isActive ? Colors.white : Colors.white.withOpacity(0.7),
                    fontFamily: AppStyles.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CircleOverlayPainter extends CustomPainter {
  final double cropSize;

  CircleOverlayPainter({required this.cropSize});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = cropSize / 2;

    final path = Path()
      ..addRect(rect)
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    final paintMask = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paintMask);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CircleOverlayPainter oldDelegate) {
    return oldDelegate.cropSize != cropSize;
  }
}
