import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xaneo/widgets/scheduled_modal_shell.dart';
import 'package:xaneo/providers/appearance_provider.dart';

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/services/scheduled_messages.dart';
import 'package:xaneo/widgets/scheduled_messages_dialog.dart';

const fileA = '11111111-1111-4111-8111-111111111111';
const fileB = '22222222-2222-4222-8222-222222222222';
Map<String, dynamic> row(
        {String encrypted = 'cipher', List<String> files = const []}) =>
    {
      'id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      'chat_id': 'personal_1_2',
      'send_at': DateTime.now()
          .add(const Duration(hours: 1))
          .toUtc()
          .toIso8601String(),
      'status': 'pending',
      'last_error': '',
      'payload': {
        'encrypted_text': encrypted,
        'signature': '',
        'images': files.map((id) => {'file_id': id}).toList(),
        'reply_to_id': 7
      },
      'files': files
          .map((id) => {
                'file_id': id,
                'name': '$id.pdf',
                'file_type': 'document',
                'mime_type': 'application/pdf'
              })
          .toList(),
    };
Response<dynamic> response(dynamic data, [int status = 200]) => Response(
    data: data,
    statusCode: status,
    requestOptions: RequestOptions(path: 'test'));
ScheduledMessagesApi apiWith(ScheduleRequest request) => ScheduledMessagesApi(
    request: request, baseUrl: Uri.parse('https://example.com/api/v1'));

Widget _testApp({required Widget home}) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppearanceProvider()),
      ],
      child: MaterialApp(home: home),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('request IDs are unique UUID v4 values', () {
    final ids = List.generate(100, (_) => scheduleRequestId());
    expect(ids.toSet(), hasLength(100));
    for (final id in ids) {
      expect(
          RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
              .hasMatch(id),
          isTrue);
    }
  });
  test('uncertain create retry preserves ciphertext, UTC time and request ID',
      () async {
    final bodies = <Map<String, dynamic>>[];
    var prepares = 0;
    final api = apiWith((method, path, body, query) async {
      bodies.add(Map<String, dynamic>.from(jsonDecode(jsonEncode(body))));
      return bodies.length == 1
          ? response({'detail': 'Unavailable'}, 503)
          : response(row(), 201);
    });
    final submission = ScheduledSubmission(
        api: api,
        prepare: () async {
          prepares++;
          return {
            'chat_id': 'personal_1_2',
            'encrypted_text': 'cipher-$prepares',
            'images': [],
            'plaintext': 'never send this'
          };
        });
    final first = DateTime.now().add(const Duration(hours: 1));
    await expectLater(
        submission.send(first), throwsA(isA<ScheduleException>()));
    expect(submission.timeLocked, isTrue);
    await submission.send(first.add(const Duration(hours: 1)));
    expect(bodies[0], bodies[1]);
    expect(prepares, 1);
    expect(bodies[0]['send_at'], first.toUtc().toIso8601String());
    expect(bodies[0].containsKey('plaintext'), isFalse);
  });
  test('definitive rejection permits a new time and fresh encryption',
      () async {
    final bodies = <Map<String, dynamic>>[];
    var prepares = 0;
    final api = apiWith((method, path, body, query) async {
      bodies.add(Map<String, dynamic>.from(body));
      return bodies.length == 1
          ? response({
              'send_at': ['Invalid time']
            }, 400)
          : response(row(), 201);
    });
    final submission = ScheduledSubmission(
        api: api,
        prepare: () async => {
              'chat_id': 'personal_1_2',
              'encrypted_text': 'cipher-${++prepares}'
            });
    final first = DateTime.now().add(const Duration(hours: 1));
    await expectLater(
        submission.send(first), throwsA(isA<ScheduleException>()));
    expect(submission.timeLocked, isFalse);
    await submission.send(first.add(const Duration(hours: 1)));
    expect(prepares, 2);
    expect(bodies[0]['client_request_id'], bodies[1]['client_request_id']);
    expect(bodies[0]['send_at'], isNot(bodies[1]['send_at']));
  });
  test('past dates do not encrypt or submit', () async {
    var called = false;
    final submission = ScheduledSubmission(api: apiWith((a, b, c, d) async {
      called = true;
      return response(row());
    }), prepare: () async {
      called = true;
      return {};
    });
    await expectLater(
        submission.send(DateTime.now().subtract(const Duration(minutes: 1))),
        throwsA(isA<ScheduleException>()));
    expect(called, isFalse);
  });
  test('list, reschedule, edit and cancel follow the shared web API', () async {
    final calls = <Map<String, dynamic>>[];
    final api = apiWith((method, path, body, query) async {
      calls.add({'method': method, 'path': path, 'body': body, 'query': query});
      return method == 'GET'
          ? response({
              'results': [
                row(files: [fileA, fileB])
              ],
              'next': 'next-page'
            })
          : response(null, 204);
    });
    final page = await api.list('personal_1_2', offset: 50);
    expect(page.hasMore, isTrue);
    expect(calls[0]['query']['offset'], 50);
    final job = page.jobs.single;
    final moved = DateTime.now().add(const Duration(hours: 3));
    await api.move(job, moved);
    expect(calls[1]['body'], {'send_at': moved.toUtc().toIso8601String()});
    await api.edit(job, {
      'encrypted_text': 'new-cipher',
      'signature': 'a' * 128,
      'epoch_id': 503
    }, [
      const ScheduledAttachment(id: fileB, name: 'song.mp3')
    ]);
    final patch = calls[2]['body'] as Map;
    expect(patch['expected_encrypted_text'], 'cipher');
    expect(patch['expected_file_ids'], [fileA, fileB]);
    expect(patch['images'], [
      {'file_id': fileB}
    ]);
    expect(patch['epoch_id'], 503);
    expect(patch.containsKey('reply_to_id'), isFalse);
    expect(patch.containsKey('send_at'), isFalse);
    await api.cancel(job);
    expect(calls.last['method'], 'DELETE');
  });
  test('media sources stay on the authenticated download endpoint', () {
    final api = apiWith((a, b, c, d) async => response(null));
    expect(api.mediaUrl('/api/files/download/$fileA/?token=abc'),
        'https://example.com/api/files/download/$fileA/?token=abc');
    for (final url in [
      'javascript:alert(1)',
      'https://other.test/file.png',
      '/other-page/',
      ''
    ]) {
      expect(api.mediaUrl(url), isNull);
    }
    expect(const ScheduledAttachment(name: 'PHOTO.PNG').kind, 'image');
    expect(const ScheduledAttachment(name: 'movie.webm').kind, 'video');
    expect(const ScheduledAttachment(name: 'song.mp3').kind, 'audio');
    expect(const ScheduledAttachment(name: 'document.pdf').kind, 'document');
  });
  test('replacement files use the existing upload contract', () async {
    final dir = await Directory.systemTemp.createTemp('scheduled-upload-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/photo.png');
    await file.writeAsBytes([1, 2, 3]);
    final api = apiWith((method, path, body, query) async {
      expect(path, '/files/upload/');
      expect(method, 'POST');
      expect(Map.fromEntries((body as FormData).fields)['file_type'], 'image');
      return response(
          {'file_id': fileA, 'file_type': 'image', 'mime_type': 'image/png'},
          201);
    });
    expect((await api.upload(file, 'personal_1_2')).id, fileA);
  });
  testWidgets('closing the scheduling dialog does not create anything',
      (tester) async {
    var requests = 0;
    bool? saved;
    final submission = ScheduledSubmission(
        api: apiWith((a, b, c, d) async {
          requests++;
          return response(row(), 201);
        }),
        prepare: () async => {'encrypted_text': 'cipher'});
    await tester.pumpWidget(_testApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () async {
                      saved = await showScheduleCreate(context,
                          submission: submission,
                          preview: 'draft',
                          foreground: Colors.black,
                          background: Colors.white);
                    },
                    child: const Text('open'))))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(ScheduledModalShell), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(saved, isFalse);
    expect(requests, 0);
  });
  testWidgets(
      'schedule dialog retries the same request and fits a short desktop',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bodies = <dynamic>[];
    bool? saved;
    final submission = ScheduledSubmission(
        api: apiWith((a, b, c, d) async {
          bodies.add(jsonDecode(jsonEncode(c)));
          return bodies.length == 1
              ? response({'detail': 'Retry'}, 503)
              : response(row(), 201);
        }),
        prepare: () async => {
              'chat_id': 'personal_1_2',
              'encrypted_text': 'opaque',
              'images': []
            });
    await tester.pumpWidget(_testApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () async {
                      saved = await showScheduleCreate(context,
                          submission: submission,
                          preview: 'Draft',
                          foreground: Colors.black,
                          background: Colors.white);
                    },
                    child: const Text('open'))))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(saved, isNull);
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(saved, isTrue);
    expect(bodies, hasLength(2));
    expect(bodies[0], bodies[1]);
  });
  testWidgets('custom modal cannot close while the server is saving',
      (tester) async {
    final pending = Completer<Response<dynamic>>();
    bool? saved;
    final submission = ScheduledSubmission(
      api: apiWith((method, path, body, query) => pending.future),
      prepare: () async =>
          {'chat_id': 'personal_1_2', 'encrypted_text': 'cipher'},
    );
    await tester.pumpWidget(_testApp(
        home: Builder(
            builder: (context) => Scaffold(
                  body: TextButton(
                      onPressed: () async {
                        saved = await showScheduleCreate(context,
                            submission: submission,
                            preview: 'Draft',
                            foreground: Colors.black,
                            background: Colors.white);
                      },
                      child: const Text('open')),
                ))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schedule'));
    await tester.pump();
    await tester.tap(find.byTooltip('Close'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(ScheduledModalShell), findsOneWidget);
    expect(saved, isNull);
    pending.complete(response(row(), 201));
    await tester.pumpAndSettle();
    expect(saved, isTrue);
    expect(find.byType(ScheduledModalShell), findsNothing);
  });
  testWidgets('scheduled message text and attachments are edited together',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    Map? patch;
    final api = apiWith((method, path, body, query) async {
      if (method == 'PATCH') {
        patch = body as Map;
        return response(row());
      }
      return response({
        'results': [
          row(files: [fileA, fileB])
        ],
        'next': null
      });
    });
    await tester.pumpWidget(_testApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () {
                      showScheduledMessages(context,
                          api: api,
                          chatId: 'personal_1_2',
                          seal: (text) async =>
                              {'encrypted_text': 'ENC:$text', 'signature': ''},
                          decrypt: (_) async => 'old text',
                          foreground: Colors.black,
                          background: Colors.white);
                    },
                    child: const Text('open'))))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(find.text('Save')).dy, lessThan(544));
    await tester.enterText(find.byType(TextField), 'new text');
    await tester.tap(find.text('Remove').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(patch?['encrypted_text'], 'ENC:new text');
    expect(patch?['images'], [
      {'file_id': fileB}
    ]);
    expect(patch?['expected_file_ids'], [fileA, fileB]);
    expect(patch?.containsKey('send_at'), isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
