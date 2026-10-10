import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../l10n/appearance_strings.dart';
import '../../models/xnx_theme.dart';
import 'xnx_import_tile.dart';

typedef XnxColorPicker = Future<Color?> Function(
    BuildContext context, Color initial, String title);

class XnxThemeEditor extends StatelessWidget {
  const XnxThemeEditor({
    super.key,
    required this.theme,
    required this.isDark,
    required this.onApply,
    required this.onModeChanged,
    required this.onClear,
    required this.pickColor,
  });

  final XnxTheme? theme;
  final bool isDark;
  final Future<void> Function(String) onApply;
  final void Function(bool) onModeChanged;
  final Future<void> Function() onClear;
  final XnxColorPicker pickColor;

  static const groups = <String, List<String>>{
    'interface': [
      'bg', 'bg-secondary', 'surface', 'surface-hover', 'border', 'accent',
    ],
    'messageGroup': [
      'text', 'text-secondary', 'text-muted', 'message-incoming-bg',
      'message-incoming-text', 'message-outgoing-bg', 'message-outgoing-text',
    ],
    'controls': [
      'btn-primary-bg', 'btn-primary-text', 'progress-bg', 'progress-fill',
    ],
  };

  XnxTheme get current => theme ?? XnxTheme.preset('Default').withMode(isDark);

  Future<void> _apply(BuildContext context, XnxTheme updated) async {
    try {
      await onApply(updated.toSource());
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppearanceStrings.of(context).get('applyError', error))),
        );
      }
    }
  }

  Future<void> _export(BuildContext context) async {
    try {
      final source = current.toSource();
      final safeName = current.name
          .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '-')
          .replaceAll(RegExp(r'\s+'), '-');
      final name = safeName.isEmpty
          ? 'xaneo-theme'
          : (safeName.length > 72 ? safeName.substring(0, 72) : safeName);
      final path = await FilePicker.saveFile(
        dialogTitle: AppearanceStrings.of(context).get('exportDialog'),
        fileName: '$name.xnx',
        type: FileType.custom,
        allowedExtensions: ['xnx'],
        bytes: Uint8List.fromList(utf8.encode(source)),
      );
      if (path != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppearanceStrings.of(context).get('exportSuccess'))),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppearanceStrings.of(context).get('exportError', error))),
        );
      }
    }
  }

  Color _color(String key) {
    final active = current;
    final fallback = XnxTheme.preset('Default');
    if (key.startsWith('message-')) {
      final outgoing = key.contains('outgoing');
      final text = key.endsWith('-text');
      return active.messageColor(
              outgoing: outgoing, text: text, dark: isDark) ??
          fallback.messageColor(outgoing: outgoing, text: text, dark: isDark) ??
          Colors.grey;
    }
    return active.color(key, isDark) ??
        fallback.color(key, isDark) ??
        Colors.grey;
  }

  String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  Future<void> _editColor(
      BuildContext context, String key, String label) async {
    final chosen = await pickColor(context, _color(key), label);
    if (chosen != null && context.mounted) {
      await _apply(context, current.withColor(key, chosen, isDark));
    }
  }

  void _editHex(BuildContext context, String key, String raw) {
    final value = raw.trim();
    final digits = value.startsWith('#') ? value.substring(1) : value;
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(digits)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppearanceStrings.of(context).get('invalidHex'))),
      );
      return;
    }
    final color = Color(int.parse('FF$digits', radix: 16));
    _apply(context, current.withColor(key, color, isDark));
  }

  Widget _bubble(Color bg, Color fg, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
      );

  Widget _preview(BuildContext context) {
    final strings = AppearanceStrings.of(context);
    final bg = _color('bg');
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(current.radius.toDouble()),
        border: Border.all(color: _color('border')),
      ),
      child: Row(children: [
        Container(
          width: 62,
          decoration: BoxDecoration(
            color: _color('bg-secondary'),
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(current.radius.toDouble() - 1),
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 30,
                height: 8,
                margin: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: i == 0 ? _color('accent') : _color('surface'),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ]),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(strings.get('preview'), style: TextStyle(color: _color('text'))),
            const Spacer(),
            Align(
                alignment: Alignment.centerLeft,
                child: _bubble(_color('message-incoming-bg'),
                    _color('message-incoming-text'), strings.get('previewIncoming'))),
            const SizedBox(height: 8),
            Align(
                alignment: Alignment.centerRight,
                child: _bubble(_color('message-outgoing-bg'),
                    _color('message-outgoing-text'), strings.get('previewOutgoing'))),
            const Spacer(),
            Container(
                height: 12,
                decoration: BoxDecoration(
                    color: _color('surface'),
                    borderRadius: BorderRadius.circular(8))),
          ]),
        )),
      ]),
    );
  }

  Widget _colorRow(BuildContext context, String key, String label) {
    final color = _color(key);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: SizedBox(
        width: 110,
        child: TextFormField(
          key: ValueKey('$key-${_hex(color)}-$isDark'),
          initialValue: _hex(color),
          maxLength: 7,
          decoration: const InputDecoration(
              isDense: true, counterText: '', hintText: '#RRGGBB'),
          onFieldSubmitted: (value) => _editHex(context, key, value),
        ),
      ),
      trailing: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(9),
              border:
                  Border.all(color: Theme.of(context).colorScheme.outline))),
      onTap: () => _editColor(context, key, label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppearanceStrings.of(context);
    final active = current;
    var previewBlur = active.blurPercent.toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(strings.get('createTheme'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 4),
      Text(strings.get('autosave')),
      const SizedBox(height: 18),
      Text(strings.get('presets'), style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        for (final name in ['Graphite', 'Gruvbox', 'Paper'])
          ActionChip(
              label: Text(name),
              onPressed: () =>
                  _apply(context, XnxTheme.preset(name).withMode(isDark))),
      ]),
      const SizedBox(height: 16),
      _preview(context),
      const SizedBox(height: 16),
      SegmentedButton<bool>(
        segments: [
          ButtonSegment(value: false, label: Text(strings.get('light'))),
          ButtonSegment(value: true, label: Text(strings.get('dark'))),
        ],
        selected: {isDark},
        onSelectionChanged: (selection) {
          final dark = selection.first;
          if (theme == null) {
            onModeChanged(dark);
          } else {
            _apply(context, theme!.withMode(dark));
          }
        },
      ),
      const SizedBox(height: 14),
      TextFormField(
        key: ValueKey(active.name),
        initialValue: active.name,
        maxLength: 72,
        decoration: InputDecoration(labelText: strings.get('themeName')),
        onFieldSubmitted: (value) => _apply(context, active.withName(value)),
      ),
      for (final group in groups.entries) ...[
        const SizedBox(height: 14),
        Text(strings.get(group.key), style: Theme.of(context).textTheme.titleMedium),
        for (final key in group.value)
          _colorRow(context, key, strings.get(key)),
      ],
      const SizedBox(height: 12),
      Text(strings.get('radius', active.radius)),
      Slider(
          value: active.radius.toDouble(),
          min: 8,
          max: 24,
          divisions: 16,
          onChanged: (_) {},
          onChangeEnd: (value) =>
              _apply(context, active.withRadius(value.round()))),
      StatefulBuilder(
          builder: (context, setSliderState) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.get('blur', previewBlur.round())),
                  Slider(
                    value: previewBlur,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '${previewBlur.round()}%',
                    onChanged: (value) =>
                        setSliderState(() => previewBlur = value),
                    onChangeEnd: (value) =>
                        _apply(context, active.withBlurPercent(value.round())),
                  ),
                ],
              )),
      DropdownButtonFormField<String>(
        initialValue:
            ['Inter', 'Onest', 'Geist', 'Segoe UI'].contains(active.fontFamily)
                ? active.fontFamily
                : null,
        hint: Text(active.fontFamily),
        decoration: InputDecoration(labelText: strings.get('font')),
        items: [
          const DropdownMenuItem(value: 'Inter', child: Text('Inter')),
          const DropdownMenuItem(value: 'Onest', child: Text('Onest')),
          const DropdownMenuItem(value: 'Geist', child: Text('Geist')),
          DropdownMenuItem(value: 'Segoe UI', child: Text(strings.get('systemFont'))),
        ],
        onChanged: (value) {
          if (value != null) _apply(context, current.withFontFamily(value));
        },
      ),
      const SizedBox(height: 12),
      XnxImportTile(
          themeName: theme?.name,
          onImport: onApply,
          onClear: onClear,
          showReset: false),
      const SizedBox(height: 14),
      FilledButton.icon(
          onPressed: () => _export(context),
          icon: const Icon(Icons.file_download_outlined),
          label: Text(strings.get('export'))),
      const SizedBox(height: 8),
      if (theme != null)
        OutlinedButton.icon(
            onPressed: () => onClear(),
            icon: const Icon(Icons.restore),
            label: Text(strings.get('restore'))),
    ]);
  }
}
