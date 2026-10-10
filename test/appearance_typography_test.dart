import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/styles/app_styles.dart';
import 'package:xaneo/styles/appearance_typography.dart';

void main() {
  test('buttons and component labels use the selected bundled font', () {
    for (final family in ['Inter', 'Onest', 'Geist']) {
      final theme = applyAppearanceFont(
        ThemeData(
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(fontSize: 20),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: AppStyles.primaryButton,
          ),
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12),
            ),
          ),
        ),
        family,
      );

      expect(theme.textTheme.bodyMedium?.fontFamily, family);
      expect(theme.appBarTheme.titleTextStyle?.fontFamily, family);
      expect(
        theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.fontFamily,
        family,
      );
      expect(
        theme.filledButtonTheme.style?.textStyle?.resolve({})?.fontFamily,
        family,
      );
      expect(
        theme.navigationBarTheme.labelTextStyle?.resolve({})?.fontFamily,
        family,
      );
      expect(
        theme.cupertinoOverrideTheme?.textTheme?.actionTextStyle.fontFamily,
        family,
      );
      expect(
        theme
            .cupertinoOverrideTheme
            ?.textTheme
            ?.dateTimePickerTextStyle
            .fontFamily,
        family,
      );
    }
  });
}
