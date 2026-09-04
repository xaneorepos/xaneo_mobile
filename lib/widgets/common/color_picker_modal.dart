import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/message_color_presets.dart';
import '../../l10n/app_localizations.dart';
import '../../styles/app_styles.dart';
import 'base_custom_modal.dart';

class MobileColorPickerModal extends BaseCustomModal {
  final String title;
  final Color initialColor;

  const MobileColorPickerModal({
    super.key,
    required this.title,
    required this.initialColor,
  });

  static Future<Color?> pick({
    required BuildContext context,
    required Color initial,
    String? title,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return BaseCustomModal.show<Color>(
      context: context,
      child: MobileColorPickerModal(
        title: title ?? l10n.customColor,
        initialColor: initial,
      ),
    );
  }

  @override
  State<MobileColorPickerModal> createState() => _MobileColorPickerModalState();
}

class _MobileColorPickerModalState
    extends BaseCustomModalState<MobileColorPickerModal> {
  late Color _selected;
  late final ValueNotifier<HSVColor> _hsv;
  late final TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor.withValues(alpha: 1);
    _hsv = ValueNotifier(HSVColor.fromColor(_selected));
    _hexController = TextEditingController(text: _hexFor(_selected));
  }

  @override
  void dispose() {
    _hsv.dispose();
    _hexController.dispose();
    super.dispose();
  }

  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context)!;
    final pickerWidth = math.min(MediaQuery.sizeOf(context).width - 40, 320.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(context, widget.title),
        const SizedBox(height: 10),
        Center(
          child: SizedBox(
            width: pickerWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SaturationValueArea(
                  hsv: _hsv,
                  height: pickerWidth * 0.68,
                  onChanged: _selectHsv,
                  onChangeEnd: _syncHex,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ValueListenableBuilder<HSVColor>(
                      valueListenable: _hsv,
                      builder: (_, hsv, __) => Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: hsv.toColor(),
                          shape: BoxShape.circle,
                          border: Border.all(color: context.xaneoDivider),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HueSlider(
                        hsv: _hsv,
                        onChanged: _selectHsv,
                        onChangeEnd: _syncHex,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 170,
                  child: TextField(
                    controller: _hexController,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp('[0-9a-fA-F]'),
                      ),
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      isDense: true,
                      prefixText: '#',
                      labelText: 'HEX',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _applyHex,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_selected),
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _selectHsv(HSVColor hsv) {
    _hsv.value = hsv;
    _selected = hsv.toColor();
  }

  void _syncHex() {
    final hex = _hexFor(_selected);
    if (_hexController.text != hex) {
      _hexController.value = TextEditingValue(
        text: hex,
        selection: TextSelection.collapsed(offset: hex.length),
      );
    }
  }

  void _applyHex(String value) {
    if (value.length != 6) return;
    final raw = int.tryParse(value, radix: 16);
    if (raw == null) return;
    _selectHsv(HSVColor.fromColor(Color(0xFF000000 | raw)));
  }

  String _hexFor(Color color) => (color.toARGB32() & 0xFFFFFF)
      .toRadixString(16)
      .padLeft(6, '0')
      .toUpperCase();
}

class _SaturationValueArea extends StatelessWidget {
  const _SaturationValueArea({
    required this.hsv,
    required this.height,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final ValueNotifier<HSVColor> hsv;
  final double height;
  final ValueChanged<HSVColor> onChanged;
  final VoidCallback onChangeEnd;

  void _update(Offset position, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    onChanged(
      hsv.value
          .withSaturation((position.dx / size.width).clamp(0.0, 1.0))
          .withValue(1 - (position.dy / size.height).clamp(0.0, 1.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _update(details.localPosition, size),
            onTapUp: (_) => onChangeEnd(),
            onPanStart: (details) => _update(details.localPosition, size),
            onPanUpdate: (details) => _update(details.localPosition, size),
            onPanEnd: (_) => onChangeEnd(),
            onPanCancel: onChangeEnd,
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: _SaturationValuePainter(hsv),
                  size: size,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HueSlider extends StatelessWidget {
  const _HueSlider({
    required this.hsv,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final ValueNotifier<HSVColor> hsv;
  final ValueChanged<HSVColor> onChanged;
  final VoidCallback onChangeEnd;

  void _update(double dx, double width) {
    if (width <= 0) return;
    onChanged(hsv.value.withHue((dx / width).clamp(0.0, 1.0) * 359));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _update(details.localPosition.dx, width),
            onTapUp: (_) => onChangeEnd(),
            onPanStart: (details) => _update(details.localPosition.dx, width),
            onPanUpdate: (details) => _update(details.localPosition.dx, width),
            onPanEnd: (_) => onChangeEnd(),
            onPanCancel: onChangeEnd,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _HuePainter(hsv),
                size: Size(width, 34),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SaturationValuePainter extends CustomPainter {
  _SaturationValuePainter(this.hsv) : super(repaint: hsv);

  final ValueListenable<HSVColor> hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final value = hsv.value;
    final rect = Offset.zero & size;
    final hueColor = HSVColor.fromAHSV(1, value.hue, 1, 1).toColor();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, hueColor],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(rect),
    );

    final center = Offset(
      value.saturation * size.width,
      (1 - value.value) * size.height,
    );
    canvas.drawCircle(
      center,
      9,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(
      center,
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SaturationValuePainter oldDelegate) => false;
}

class _HuePainter extends CustomPainter {
  _HuePainter(this.hsv) : super(repaint: hsv);

  final ValueListenable<HSVColor> hsv;

  static final List<Color> _colors = List.generate(
    7,
    (index) => HSVColor.fromAHSV(1, index * 60, 1, 1).toColor(),
    growable: false,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 8, size.width, 18),
      const Radius.circular(9),
    );
    canvas.drawRRect(
      track,
      Paint()
        ..shader =
            LinearGradient(colors: _colors).createShader(track.outerRect),
    );

    final x = hsv.value.hue / 359 * size.width;
    final center = Offset(x.clamp(9.0, size.width - 9), size.height / 2);
    canvas.drawCircle(
      center,
      9,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      6,
      Paint()..color = hsv.value.toColor(),
    );
  }

  @override
  bool shouldRepaint(covariant _HuePainter oldDelegate) => false;
}

class MobileGradientPickerModal extends BaseCustomModal {
  final GradientSpec initial;

  const MobileGradientPickerModal({super.key, required this.initial});

  static Future<GradientSpec?> pick({
    required BuildContext context,
    required GradientSpec initial,
  }) {
    return BaseCustomModal.show<GradientSpec>(
      context: context,
      child: MobileGradientPickerModal(initial: initial),
    );
  }

  @override
  State<MobileGradientPickerModal> createState() =>
      _MobileGradientPickerModalState();
}

class _MobileGradientPickerModalState
    extends BaseCustomModalState<MobileGradientPickerModal> {
  late Color _first = widget.initial.color1;
  late Color _second = widget.initial.color2;
  late GradientDirection _direction = widget.initial.direction;

  @override
  bool get fitContent => true;

  Future<void> _pickColor(bool first) async {
    final l10n = AppLocalizations.of(context)!;
    final color = await MobileColorPickerModal.pick(
      context: context,
      initial: first ? _first : _second,
      title: first ? l10n.colorOne : l10n.colorTwo,
    );
    if (color == null || !mounted) return;
    setState(() {
      if (first) {
        _first = color;
      } else {
        _second = color;
      }
    });
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(context, l10n.customGradient),
        const SizedBox(height: 14),
        Container(
          height: 72,
          decoration: BoxDecoration(
            gradient: GradientSpec(
              color1: _first,
              color2: _second,
              direction: _direction,
            ).toLinearGradient(),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.xaneoDivider),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _colorButton(
                l10n.colorOne,
                _first,
                () => _pickColor(true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _colorButton(
                l10n.colorTwo,
                _second,
                () => _pickColor(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<GradientDirection>(
          initialValue: _direction,
          dropdownColor: context.xaneoSurfaceElevated,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.xaneoOverlay(0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: [
            DropdownMenuItem(
              value: GradientDirection.diagonal,
              child: Text(l10n.diagonal),
            ),
            DropdownMenuItem(
              value: GradientDirection.vertical,
              child: Text(l10n.vertical),
            ),
            DropdownMenuItem(
              value: GradientDirection.horizontal,
              child: Text(l10n.horizontal),
            ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _direction = value);
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  GradientSpec(
                    color1: _first,
                    color2: _second,
                    direction: _direction,
                  ),
                ),
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _colorButton(String label, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: context.xaneoDivider),
        ),
      ),
      label: Text(label),
    );
  }
}

Widget _header(BuildContext context, String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: context.xaneoTextSecondary,
          fontFamily: 'Inter',
        ),
      ),
      IconButton(
        icon: Icon(
          Icons.close_rounded,
          color: context.xaneoTextSecondary,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}
