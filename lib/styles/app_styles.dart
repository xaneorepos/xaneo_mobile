import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appearance_provider.dart';

extension XaneoThemeColors on BuildContext {
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
  AppearanceProvider? get _appearance => read<AppearanceProvider?>();
  bool get _hasXnx => _appearance?.xnxTheme != null;

  Color get xaneoSurface => _hasXnx
      ? Theme.of(this).cardColor
      : (isDarkTheme ? const Color(0xFF141416) : Colors.white);
  Color get xaneoSurfaceElevated => _hasXnx
      ? Theme.of(this).colorScheme.surfaceContainerHigh
      : (isDarkTheme ? const Color(0xFF1B1B1F) : const Color(0xFFF1F1F4));
  Color get xaneoTextPrimary => _hasXnx
      ? Theme.of(this).colorScheme.onSurface
      : (isDarkTheme ? Colors.white : const Color(0xFF18181B));
  Color get xaneoTextSecondary => _hasXnx
      ? Theme.of(this).colorScheme.secondary
      : (isDarkTheme ? Colors.white70 : const Color(0xFF52525B));
  Color get xaneoTextMuted => _hasXnx
      ? (_appearance?.xnxColor('text-muted', dark: isDarkTheme) ??
          Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.48))
      : (isDarkTheme ? Colors.white38 : const Color(0xFF71717A));
  Color get xaneoDivider => _hasXnx
      ? Theme.of(this).dividerColor
      : (isDarkTheme
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.08));
  Color get xaneoAccent => Theme.of(this).colorScheme.primary;
  Color get xaneoButtonBackground =>
      _appearance?.xnxColor('btn-primary-bg', dark: isDarkTheme) ??
      Theme.of(this).colorScheme.primary;
  Color get xaneoButtonForeground =>
      _appearance?.xnxColor('btn-primary-text', dark: isDarkTheme) ??
      Theme.of(this).colorScheme.onPrimary;
  double xaneoRadius(double fallback) =>
      _appearance?.xnxTheme?.radius.toDouble() ?? fallback;
  Color xaneoOverlay(double opacity) => (_hasXnx
          ? Theme.of(this).colorScheme.onSurface
          : (isDarkTheme ? Colors.white : Colors.black))
      .withValues(alpha: opacity);
}

class AppStyles {
  AppStyles._();

  static const Color backgroundColor = Colors.black;
  static const Color textPrimaryColor = Colors.white;
  static const Color textSecondaryColor = Color(0xFFB0B0B0);
  static const Color textMutedColor = Color(0xFF707070);
  static const Color buttonBackgroundColor = Colors.white;
  static const Color buttonTextColor = Colors.black;
  static const Color inputBackgroundColor = Colors.transparent;
  static const Color borderColor = Color(0xFF333333);
  static const Color borderActiveColor = Colors.white;
  static const Color errorColor = Color(0xFFFF4444);
  static const Color successColor = Color(0xFF44FF44);

  static const String fontFamily = 'Inter';

  static const double fontSizeGiant = 32.0;
  static const double fontSizeTitle = 28.0;
  static const double fontSizeLarge = 24.0;
  static const double fontSizeMedium = 18.0;
  static const double fontSizeNormal = 16.0;
  static const double fontSizeSmall = 14.0;

  static const TextStyle titleGiant = TextStyle(
    fontSize: fontSizeGiant,
    fontWeight: FontWeight.w700,
    fontFamily: null,
    height: 1.2,
    letterSpacing: -1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: fontSizeTitle,
    fontWeight: FontWeight.w600,
    fontFamily: null,
    height: 1.2,
    letterSpacing: -0.8,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w400,
    fontFamily: null,
    height: 1.35,
    letterSpacing: -0.3,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w400,
    fontFamily: null,
    letterSpacing: -0.3,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: fontSizeNormal,
    fontWeight: FontWeight.w600,
    color: buttonTextColor,
    fontFamily: null,
    letterSpacing: -0.3,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w500,
    fontFamily: null,
    letterSpacing: -0.6,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w400,
    fontFamily: null,
    letterSpacing: -0.6,
  );

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 600);

  static const Curve curveEaseInOut = Curves.easeInOutCubic;
  static const Curve curveEaseOut = Curves.easeOutCubic;
  static const Curve curveEaseIn = Curves.easeInCubic;

  // Added styles to fix dependencies
  static const EdgeInsets screenPadding = EdgeInsets.all(24.0);

  static const TextStyle errorText = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.w400,
    color: errorColor,
    fontFamily: null,
  );

  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: buttonBackgroundColor,
    foregroundColor: buttonTextColor,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 0,
    textStyle: buttonText,
  );

  /// FilledButton uses a StadiumBorder by default in Material 3. Keep it
  /// geometrically identical to the primary/secondary buttons so action rows
  /// do not mix pill-shaped and rounded-rectangle controls.
  static final ButtonStyle filledButton = FilledButton.styleFrom(
    backgroundColor: buttonBackgroundColor,
    foregroundColor: buttonTextColor,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 0,
    textStyle: buttonText,
  );

  static final ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: textPrimaryColor,
    side: const BorderSide(color: borderColor, width: 1),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: buttonText.copyWith(color: textPrimaryColor),
  );

  static final ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: textPrimaryColor,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: buttonText.copyWith(color: textPrimaryColor),
  );
}
