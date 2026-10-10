import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../l10n/appearance_strings.dart';

/// Import and reset controls shared by the native appearance settings.
class XnxImportTile extends StatelessWidget {
  const XnxImportTile({
    super.key,
    required this.themeName,
    required this.onImport,
    required this.onClear,
    this.showReset = true,
  });

  final String? themeName;
  final Future<void> Function(String) onImport;
  final Future<void> Function() onClear;
  final bool showReset;

  Future<void> _pick(BuildContext context) async {
    final strings = AppearanceStrings.of(context);
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xnx'],
        withData: false,
      );
      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.single;
      if (!file.name.toLowerCase().endsWith('.xnx')) {
        throw FormatException(strings.get('expectedXnx'));
      }
      if (file.size > 65536) throw FormatException(strings.get('tooLarge'));
      final bytes = file.bytes ??
          (file.path == null ? null : await File(file.path!).readAsBytes());
      if (bytes == null) {
        throw FormatException(strings.get('readError'));
      }
      if (bytes.length > 65536) {
        throw FormatException(strings.get('tooLarge'));
      }
      await onImport(utf8.decode(bytes));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.get('importSuccess'))),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.get('importError', error))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppearanceStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.palette_outlined, color: colors.primary),
          title: Text(strings.get('import')),
          subtitle: Text(themeName == null
              ? strings.get('importDesc')
              : strings.get('activeTheme', themeName)),
          trailing: const Icon(Icons.file_upload_outlined),
          onTap: () => _pick(context),
        ),
        if (themeName != null && showReset)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => onClear(),
              icon: const Icon(Icons.restore),
              label: Text(strings.get('reset')),
            ),
          ),
      ],
    );
  }
}
