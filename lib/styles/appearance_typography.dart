import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_styles.dart';

/// Applies the selected interface font to Material component typography.
ThemeData applyAppearanceFont(ThemeData theme, String family) {
  const fallback = ['Inter'];
  final textTheme = theme.textTheme.apply(
    fontFamily: family,
    fontFamilyFallback: fallback,
  );

  ButtonStyle withFont(ButtonStyle? style) =>
      (style ?? const ButtonStyle()).copyWith(
        textStyle: WidgetStateProperty.resolveWith((states) {
          final original =
              style?.textStyle?.resolve(states) ?? AppStyles.buttonText;
          return original.copyWith(
            fontFamily: family,
            fontFamilyFallback: fallback,
          );
        }),
      );

  final appBar = theme.appBarTheme;
  final navigationBar = theme.navigationBarTheme;
  final navigationLabels = navigationBar.labelTextStyle;
  final popupMenu = theme.popupMenuTheme;
  final inputDecoration = theme.inputDecorationTheme;
  final cupertino = theme.cupertinoOverrideTheme;
  final cupertinoText = cupertino?.textTheme ?? const CupertinoTextThemeData();
  TextStyle cupertinoFont(TextStyle style) =>
      style.copyWith(fontFamily: family, fontFamilyFallback: fallback);
  return theme.copyWith(
    textTheme: textTheme,
    primaryTextTheme: theme.primaryTextTheme.apply(
      fontFamily: family,
      fontFamilyFallback: fallback,
    ),
    appBarTheme: appBar.copyWith(
      titleTextStyle: (appBar.titleTextStyle ?? textTheme.titleLarge)?.copyWith(
        fontFamily: family,
        fontFamilyFallback: fallback,
      ),
      toolbarTextStyle: (appBar.toolbarTextStyle ?? textTheme.bodyMedium)
          ?.copyWith(fontFamily: family, fontFamilyFallback: fallback),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: withFont(theme.elevatedButtonTheme.style),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: withFont(theme.filledButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: withFont(theme.outlinedButtonTheme.style),
    ),
    textButtonTheme: TextButtonThemeData(
      style: withFont(theme.textButtonTheme.style),
    ),
    navigationBarTheme: navigationBar.copyWith(
      labelTextStyle: navigationLabels == null
          ? null
          : WidgetStateProperty.resolveWith(
              (states) =>
                  (navigationLabels.resolve(states) ?? textTheme.labelMedium)
                      ?.copyWith(
                        fontFamily: family,
                        fontFamilyFallback: fallback,
                      ),
            ),
    ),
    popupMenuTheme: popupMenu.copyWith(
      textStyle: popupMenu.textStyle?.copyWith(
        fontFamily: family,
        fontFamilyFallback: fallback,
      ),
    ),
    inputDecorationTheme: inputDecoration.copyWith(
      hintStyle: inputDecoration.hintStyle?.copyWith(
        fontFamily: family,
        fontFamilyFallback: fallback,
      ),
    ),
    cupertinoOverrideTheme: (cupertino ?? const NoDefaultCupertinoThemeData())
        .copyWith(
          textTheme: cupertinoText.copyWith(
            textStyle: cupertinoFont(cupertinoText.textStyle),
            actionTextStyle: cupertinoFont(cupertinoText.actionTextStyle),
            actionSmallTextStyle: cupertinoFont(
              cupertinoText.actionSmallTextStyle,
            ),
            tabLabelTextStyle: cupertinoFont(cupertinoText.tabLabelTextStyle),
            navTitleTextStyle: cupertinoFont(cupertinoText.navTitleTextStyle),
            navLargeTitleTextStyle: cupertinoFont(
              cupertinoText.navLargeTitleTextStyle,
            ),
            navActionTextStyle: cupertinoFont(cupertinoText.navActionTextStyle),
            pickerTextStyle: cupertinoFont(cupertinoText.pickerTextStyle),
            dateTimePickerTextStyle: cupertinoFont(
              cupertinoText.dateTimePickerTextStyle,
            ),
          ),
        ),
  );
}
