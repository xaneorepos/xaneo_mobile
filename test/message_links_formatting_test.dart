import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/screens/chat/chat_screen.dart';

void main() {
  testWidgets('real message formatter preserves URL underscores and code',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: FormattedText(
      content: '**x.com/a_b** and `x.com` and [Site](example.com)',
      baseStyle: TextStyle(color: Colors.black),
    ))));
    final rich = tester.widget<RichText>(find.descendant(
        of: find.byType(FormattedText), matching: find.byType(RichText)));
    final root = rich.text as TextSpan;
    expect(root.toPlainText(), 'x.com/a_b and x.com and Site');
    var links = 0;
    void visit(InlineSpan span) {
      if (span is TextSpan) {
        if (span.recognizer != null) links++;
        for (final child in span.children ?? <InlineSpan>[]) {
          visit(child);
        }
      }
    }

    visit(root);
    expect(links, 2);
  });
}
