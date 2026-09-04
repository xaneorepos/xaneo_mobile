import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xaneo/l10n/app_localizations.dart';

import '../../providers/appearance_provider.dart';
import '../../styles/app_styles.dart';

/// Быстрое переключение темы на экранах до авторизации.
class AuthThemeToggleButton extends StatelessWidget {
  const AuthThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceProvider>();
    final isDark = appearance.isDarkMode;

    return IconButton(
      tooltip: AppLocalizations.of(context)?.darkThemeDescription ??
          'Switch between light and dark theme',
      icon: Icon(
        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: context.xaneoTextSecondary,
        size: 21,
      ),
      onPressed: () => appearance.setDarkMode(!isDark),
    );
  }
}
