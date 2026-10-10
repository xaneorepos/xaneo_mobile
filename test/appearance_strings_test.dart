import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/l10n/app_localizations.dart';
import 'package:xaneo/l10n/appearance_strings.dart';
import 'package:xaneo/widgets/common/xnx_theme_editor.dart';

void main() {
  for (final (locale, sectionTitle, colorLabel) in [
    (const Locale('ru'), 'Оформление чата', 'Основной фон'),
    (const Locale('en'), 'Chat appearance', 'Main background'),
    (const Locale('fr'), 'Apparence du chat', 'Fond principal'),
    (const Locale('es'), 'Apariencia del chat', 'Fondo principal'),
    (const Locale('zh'), '聊天外观', '主背景'),
    (const Locale('ja'), 'チャットの外観', 'メイン背景'),
    (const Locale('ko'), '채팅 모양', '기본 배경'),
    (const Locale('ar'), 'مظهر الدردشة', 'الخلفية الرئيسية'),
  ]) {
    testWidgets('appearance strings follow ${locale.languageCode}', (
      tester,
    ) async {
      late AppearanceStrings strings;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              strings = AppearanceStrings.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(strings.get('chatSection'), sectionTitle);
      expect(strings.get('bg'), colorLabel);
      expect(strings.get('radius', 12), contains('12'));
    });
  }

  testWidgets('XNX editor renders English labels in English locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: XnxThemeEditor(
              theme: null,
              isDark: false,
              onApply: (_) async {},
              onModeChanged: (_) {},
              onClear: () async {},
              pickColor: (_, initial, __) async => initial,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Preset palettes'), findsOneWidget);
    expect(find.text('Chat preview'), findsOneWidget);
    expect(find.text('Import .xnx theme'), findsOneWidget);
  });
}
