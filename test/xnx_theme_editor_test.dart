import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/models/xnx_theme.dart';
import 'package:xaneo/widgets/common/xnx_theme_editor.dart';

void main() {
  testWidgets('editor shows controls and applies a preset', (tester) async {
    String? applied;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: XnxThemeEditor(
            theme: null,
            isDark: true,
            onApply: (source) async {
              applied = source;
            },
            onModeChanged: (_) {},
            onClear: () async {},
            pickColor: (_, initial, __) async => initial,
          ),
        ),
      ),
    ));

    expect(find.text('Готовые палитры'), findsOneWidget);
    expect(find.text('Экспортировать XNX'), findsOneWidget);
    await tester.tap(find.text('Paper'));
    await tester.pump();
    expect(XnxTheme.parse(applied!).name, 'Paper');
  });

  testWidgets('imported theme shows effective message colors', (tester) async {
    final imported = XnxTheme.parse('''
{
  colors = {
    surface = "#2d1c20"; text = "#eaded3";
    btn-primary-bg = "#a6403d"; btn-primary-text = "#fff1e6";
  };
}
''');
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: SingleChildScrollView(
        child: XnxThemeEditor(
          theme: imported,
          isDark: true,
          onApply: (_) async {},
          onModeChanged: (_) {},
          onClear: () async {},
          pickColor: (_, initial, __) async => initial,
        ),
      )),
    ));

    String shownHex(String label) {
      final row =
          find.ancestor(of: find.text(label), matching: find.byType(ListTile));
      final field =
          find.descendant(of: row, matching: find.byType(TextFormField));
      return tester.widget<TextFormField>(field).initialValue!;
    }

    expect(shownHex('Входящее сообщение'), '#2D1C20');
    expect(shownHex('Текст входящего'), '#EADED3');
    expect(shownHex('Исходящее сообщение'), '#A6403D');
    expect(shownHex('Текст исходящего'), '#FFF1E6');
  });
}
