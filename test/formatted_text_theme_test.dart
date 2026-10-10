import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/screens/chat/chat_screen.dart';

void main() {
  testWidgets('formatted message updates its font and color with the theme',
      (tester) async {
    const content = 'Same message';

    Future<TextStyle?> render(TextStyle style) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormattedText(content: content, baseStyle: style),
        ),
      ));
      final richText = tester.widget<RichText>(find.descendant(
        of: find.byType(FormattedText),
        matching: find.byType(RichText),
      ));
      return (richText.text as TextSpan).style;
    }

    final first = await render(const TextStyle(
      fontFamily: 'Inter',
      color: Colors.white,
    ));
    expect(first?.fontFamily, 'Inter');

    final second = await render(const TextStyle(
      fontFamily: 'Onest',
      color: Colors.amber,
    ));
    expect(second?.fontFamily, 'Onest');
    expect(second?.color, Colors.amber);
  });
}
