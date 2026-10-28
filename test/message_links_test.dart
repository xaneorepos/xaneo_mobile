import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/utils/message_links.dart';
import 'package:xaneo/widgets/linked_message_text.dart';

void main() {
  test('domains, Unicode, explicit URLs, query strings and punctuation', () {
    for (final text in [
      'x.com',
      'www.x.com',
      'пример.рф',
      'example.dev/a_b?q=1&b=2'
    ]) {
      final links = findMessageLinks(text);
      expect(links, hasLength(1), reason: text);
      expect(links.single.text, text);
      expect(links.single.uri.scheme, 'https');
    }
    expect(
        findMessageLinks('https://x.com http://x.com')
            .map((link) => link.uri.scheme),
        ['https', 'http']);
    final links = findMessageLinks('Сайт: (x.com), https://example.com/a(b).');
    expect(
        links.map((link) => link.text), ['x.com', 'https://example.com/a(b)']);
  });
  test('mail, mentions, files, versions, code and unsafe schemes stay text',
      () {
    for (final text in [
      'me@x.com',
      '@x.com',
      'photo.png',
      'report.pdf',
      '1.2.3',
      '`x.com`',
      'javascript:alert(1)',
      'data:text/html,x.com',
      'file:///x.com',
      'https://user:pass@x.com'
    ]) {
      expect(findMessageLinks(text), isEmpty, reason: text);
    }
    for (final url in [
      'javascript:alert(1)',
      'data:text/html,x',
      'file:///etc/passwd',
      'https://x.com\nonerror=x'
    ]) {
      expect(safeMessageLinkUri(url), isNull, reason: url);
    }
  });
  test('Markdown links preserve labels and normalize their destination', () {
    final link = findMessageLinks('[Сайт](x.com/path)').single;
    expect(link.text, 'Сайт');
    expect(link.uri.toString(), 'https://x.com/path');
    expect(findMessageLinks('`[Сайт](x.com)`'), isEmpty);
  });
  test('previews are optional and always use the original safe URL', () async {
    var requests = 0;
    final data = await loadMessageLinkPreview('x.com', (uri) async {
      requests++;
      return {
        'url': 'javascript:alert(1)',
        'title': 'Title',
        'description': 'Description'
      };
    });
    expect(data?['url'], 'https://x.com');
    expect(data?['domain'], 'x.com');
    expect(
        await loadMessageLinkPreview('ordinary text', (_) async {
          requests++;
        }),
        isNull);
    expect(requests, 1);
    expect(
        await loadMessageLinkPreview(
            'x.com', (_) async => throw Exception('offline')),
        isNull);
    expect(await loadMessageLinkPreview('x.com', (_) async => {'title': ''}),
        isNull);
  });
  test('edited text cannot retain the preview of an old URL', () {
    final data = {'url': 'https://x.com/', 'title': 'X'};
    expect(matchingMessageLinkPreview(data, 'x.com'), isNotNull);
    expect(matchingMessageLinkPreview(data, 'example.com'), isNull);
    expect(matchingMessageLinkPreview(data, '`x.com`'), isNull);
  });
  test('formatting delimiters do not become part of the URL', () {
    for (final value in [
      '**x.com/a_b**',
      '*x.com/a_b*',
      '_x.com/a_b_',
      '__x.com/a_b__',
      '~~x.com/a_b~~'
    ]) {
      expect(findMessageLinks(value).single.text, 'x.com/a_b', reason: value);
    }
    expect(findMessageLinks('prefix_x.com'), isEmpty);
  });
  testWidgets('desktop selection and link activation work together',
      (tester) async {
    Uri? opened;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LinkedMessageText(
      content: 'Visit x.com',
      baseStyle: const TextStyle(color: Colors.black),
      selectable: true,
      onOpenLink: (uri) => opened = uri,
      format: (text, style) => [TextSpan(text: text, style: style)],
    ))));
    final editable = tester
        .state<EditableTextState>(find.byType(EditableText))
        .renderEditable;
    final box = editable
        .getBoxesForSelection(
            const TextSelection(baseOffset: 6, extentOffset: 11))
        .first;
    await tester.tapAt(editable.localToGlobal(box.toRect().center));
    await tester.pump();
    expect(opened.toString(), 'https://x.com');
    expect(find.byType(SelectableText), findsOneWidget);
  });
  testWidgets(
      'links can be opened, recolored and removed without stale recognizers',
      (tester) async {
    Uri? opened;
    Widget render(String text, Color color) => MaterialApp(
            home: Scaffold(
                body: LinkedMessageText(
          content: text,
          baseStyle: TextStyle(color: color),
          onOpenLink: (uri) => opened = uri,
          format: (text, style) => [TextSpan(text: text, style: style)],
        )));
    await tester.pumpWidget(render('Visit x.com', Colors.black));
    final rich = tester.widget<RichText>(find.descendant(
        of: find.byType(LinkedMessageText), matching: find.byType(RichText)));
    final root = rich.text as TextSpan;
    final span = ((root.children!.single as TextSpan).children![1] as TextSpan);
    expect(span.text, 'x.com');
    final finder = find.descendant(
        of: find.byType(LinkedMessageText), matching: find.byType(RichText));
    final paragraph = tester.renderObject<RenderParagraph>(finder);
    final box = paragraph
        .getBoxesForSelection(
            const TextSelection(baseOffset: 6, extentOffset: 11))
        .first;
    await tester.tapAt(paragraph.localToGlobal(box.toRect().center));
    expect(opened.toString(), 'https://x.com');
    await tester.pumpWidget(render('x.com', Colors.amber));
    final updated = tester.widget<RichText>(find.descendant(
        of: find.byType(LinkedMessageText), matching: find.byType(RichText)));
    expect((updated.text as TextSpan).style?.color, Colors.amber);
    await tester.pumpWidget(render('plain', Colors.white));
    expect(tester.takeException(), isNull);
  });
  testWidgets('preview uses bubble colors and ignores unsafe destinations',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: MessageLinkPreview(
      data: {'url': 'x.com', 'title': 'A title', 'description': 'Details'},
      foreground: Colors.black,
    ))));
    expect(
        tester.widget<Text>(find.text('A title')).style?.color, Colors.black);
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: MessageLinkPreview(
      data: {'url': 'javascript:alert(1)', 'title': 'Hidden'},
      foreground: Colors.white,
    ))));
    expect(find.text('Hidden'), findsNothing);
  });
}
