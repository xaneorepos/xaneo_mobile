import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/controllers/draft_link_preview_controller.dart';
import 'package:xaneo/widgets/draft_link_preview_composer.dart';

void main() {
  testWidgets('typing debounces, reuses the same address and excludes email',
      (tester) async {
    final requests = <Uri>[];
    final preview = DraftLinkPreviewController(fetch: (uri) async {
      requests.add(uri);
      return {'title': 'Parsed site', 'description': 'Details'};
    });
    preview.update('x.com', scope: 'chat-a');
    expect(preview.loading, isTrue);
    await tester.pump(const Duration(milliseconds: 300));
    preview.update('Look at x.com', scope: 'chat-a');
    expect(requests, isEmpty);
    await tester.pump(const Duration(milliseconds: 150));
    expect(requests, hasLength(1));
    expect(preview.data?['title'], 'Parsed site');
    preview.update('https://x.com/', scope: 'chat-a');
    await tester.pump(const Duration(milliseconds: 500));
    expect(requests, hasLength(1));
    preview.update('me@x.com', scope: 'chat-a');
    expect(preview.visible, isFalse);
    await tester.pump(const Duration(milliseconds: 500));
    expect(requests, hasLength(1));
    preview.dispose();
  });

  testWidgets('late results cannot overwrite a newer address or chat',
      (tester) async {
    final requests = <Completer<dynamic>>[];
    final preview = DraftLinkPreviewController(fetch: (_) {
      final result = Completer<dynamic>();
      requests.add(result);
      return result.future;
    });
    preview.update('x.com', scope: 'chat-a');
    await tester.pump(const Duration(milliseconds: 450));
    preview.update('example.com', scope: 'chat-a');
    await tester.pump(const Duration(milliseconds: 450));
    requests[0].complete({'title': 'Old site'});
    await tester.pump();
    expect(preview.data, isNull);
    expect(preview.url?.host, 'example.com');
    preview.update('example.com', scope: 'chat-b');
    await tester.pump(const Duration(milliseconds: 450));
    requests[1].complete({'title': 'Old chat'});
    await tester.pump();
    expect(preview.data, isNull);
    requests[2].complete({'title': 'New chat'});
    await tester.pump();
    expect(preview.scope, 'chat-b');
    expect(preview.data?['title'], 'New chat');
    preview.dispose();
  });

  testWidgets('dismissal hides late results and suppresses preview on send',
      (tester) async {
    final result = Completer<dynamic>();
    var count = 0;
    final preview = DraftLinkPreviewController(fetch: (_) {
      count++;
      return result.future;
    });
    preview.update('x.com', scope: 'chat');
    await tester.pump(const Duration(milliseconds: 450));
    preview.dismiss();
    result.complete({'title': 'Hidden'});
    await tester.pump();
    preview.update('More text x.com', scope: 'chat');
    expect(preview.visible, isFalse);
    expect(await preview.snapshotForSend('x.com', scope: 'chat'), isNull);
    expect(count, 1);
    preview.update('example.com', scope: 'chat');
    expect(preview.visible, isTrue);
    preview.dispose();
  });

  testWidgets('sending captures and reuses a request before clearing input',
      (tester) async {
    final result = Completer<dynamic>();
    var count = 0;
    final preview = DraftLinkPreviewController(fetch: (_) {
      count++;
      return result.future;
    });
    preview.update('x.com', scope: 'chat');
    final send = preview.snapshotForSend('x.com', scope: 'chat');
    expect(count, 1);
    preview.update('', scope: 'chat');
    result.complete({'title': 'Send this'});
    await tester.pump();
    expect((await send)?['title'], 'Send this');
    expect(preview.visible, isFalse);
    expect(preview.data, isNull);
    await tester.pump(const Duration(milliseconds: 500));
    expect(count, 1);
    preview.dispose();
  });

  testWidgets('failed parser and disposal leave no stale panel',
      (tester) async {
    final preview = DraftLinkPreviewController(
        fetch: (_) async => throw StateError('offline'));
    preview.update('x.com', scope: 'chat');
    await tester.pump(const Duration(milliseconds: 450));
    expect(preview.visible, isFalse);
    expect(await preview.snapshotForSend('x.com', scope: 'chat'), isNull);
    preview.dispose();
    final result = Completer<dynamic>();
    final disposed = DraftLinkPreviewController(fetch: (_) => result.future);
    disposed.update('x.com', scope: 'chat');
    await tester.pump(const Duration(milliseconds: 450));
    disposed.dispose();
    result.complete({'title': 'Too late'});
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'composer displays parsed data while typing, uses theme and closes',
      (tester) async {
    var count = 0;
    final preview = DraftLinkPreviewController(fetch: (_) async {
      count++;
      return {'title': 'Parsed site', 'description': 'Details'};
    });
    final input = TextEditingController();
    Widget render(Color color, String scope) => MaterialApp(
            home: Scaffold(
                body: Center(
                    child: SizedBox(
          width: 280,
          child: DraftLinkPreviewComposer(
              preview: preview,
              textController: input,
              scope: scope,
              foreground: color,
              background: Colors.white,
              child: TextField(controller: input)),
        ))));
    await tester.pumpWidget(render(Colors.black, 'chat-a'));
    await tester.enterText(find.byType(TextField), 'x.com');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    expect(find.text('Parsed site'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Parsed site')).style?.color,
        Colors.black);
    await tester.pumpWidget(render(Colors.deepPurple, 'chat-a'));
    expect(tester.widget<Text>(find.text('Parsed site')).style?.color,
        Colors.deepPurple);
    expect(count, 1);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Parsed site'), findsNothing);
    expect(await preview.snapshotForSend(input.text, scope: 'chat-a'), isNull);
    expect(input.text, 'x.com');
    await tester.pumpWidget(render(Colors.black, 'chat-b'));
    await tester.pumpAndSettle();
    expect(find.text('Parsed site'), findsOneWidget);
    expect(count, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    input.dispose();
    preview.dispose();
  });
  testWidgets('desktop preview matches the centered input width',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final preview = DraftLinkPreviewController(
        fetch: (_) async => {'title': 'Parsed site'});
    final input = TextEditingController();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: DraftLinkPreviewComposer(
      preview: preview,
      textController: input,
      scope: 'chat',
      foreground: Colors.black,
      background: Colors.white,
      maxPreviewWidth: 600,
      previewHorizontalPadding: 16,
      child: Center(
          child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(controller: input))),
    ))));
    await tester.enterText(find.byType(TextField), 'x.com');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    final card =
        tester.getRect(find.byKey(const ValueKey('draft-link-preview')));
    final field = tester.getRect(find.byType(TextField));
    expect(card.width, field.width);
    expect(card.left, field.left);
    expect(card.right, field.right);
    expect(card.width, 568);
    await tester.pumpWidget(const SizedBox.shrink());
    input.dispose();
    preview.dispose();
  });
}
