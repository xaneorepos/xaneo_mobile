import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/appearance_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/appearance_strings.dart';
import 'base_custom_modal.dart';
import 'color_picker_modal.dart';
import 'xnx_theme_editor.dart';

class MobileXnxThemeModal extends BaseCustomModal {
  const MobileXnxThemeModal({super.key});

  static Future<void> show(BuildContext context) => BaseCustomModal.show(
        context: context,
        child: const MobileXnxThemeModal(),
      );

  @override
  State<MobileXnxThemeModal> createState() => _MobileXnxThemeModalState();
}

class _MobileXnxThemeModalState
    extends BaseCustomModalState<MobileXnxThemeModal> {
  @override
  bool get isResizable => false;

  @override
  double get initialExtent => 0.94;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final appearance = context.watch<AppearanceProvider>();
    final strings = AppearanceStrings.of(context);
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Row(
          children: [
            Expanded(
                child: Text(strings.get('themeSection'),
                    style: Theme.of(context).textTheme.titleLarge)),
            IconButton(
              tooltip: AppLocalizations.of(context)?.close ?? 'Close',
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        XnxThemeEditor(
          theme: appearance.xnxTheme,
          isDark: appearance.isDarkMode,
          onApply: appearance.importXnx,
          onModeChanged: appearance.setDarkMode,
          onClear: appearance.clearXnx,
          pickColor: (context, initial, title) => MobileColorPickerModal.pick(
            context: context,
            initial: initial,
            title: title,
          ),
        ),
      ],
    );
  }
}
