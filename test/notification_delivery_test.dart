import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xaneo/config/app_config.dart';
import 'package:xaneo/services/notifications/notification_service.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final shown = <Map<dynamic, dynamic>>[];
  var failNext = false;

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    FlutterSecureStorage.setMockInitialValues({AppConfig.accessTokenKey: 'session'});
    SharedPreferences.setMockInitialValues({});
    shown.clear();
    failNext = false;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'initialize') return true;
      if (call.method == 'show') {
        if (failNext) {
          failNext = false;
          throw PlatformException(code: 'SIMULATED_NOTIFICATION_FAILURE');
        }
        shown.add(call.arguments as Map);
      }
      return null;
    });
    await FlutterLocalNotificationsPlugin().initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  String event(int index) => jsonEncode({
        'type': 'message',
        'message_id': index,
        'chat_id': 'personal_1_${index % 3 + 2}',
        // An empty body exercises the private fallback without network access.
        'encrypted_text': '',
      });

  test('a burst across chats produces ten distinct background notifications', () async {
    await Future.wait(List.generate(10, (i) =>
        NotificationService().handleNotificationFrame(event(i), 'session')));
    expect(shown, hasLength(10));
    expect(shown.map((n) => n['id']).toSet(), hasLength(10));
    expect(shown.every((n) => n['body'] == 'Новое зашифрованное сообщение'), isTrue);
  });

  test('one plugin failure does not prevent the next message', () async {
    failNext = true;
    await NotificationService().handleNotificationFrame(event(1), 'session');
    await NotificationService().handleNotificationFrame(event(2), 'session');
    expect(shown, hasLength(1));
    expect(jsonDecode(shown.single['payload'] as String)['message_id'], 2);
  });

  test('malformed frames and a previous session never produce notifications', () async {
    await NotificationService().handleNotificationFrame('{invalid', 'session');
    await NotificationService().handleNotificationFrame(event(1), 'old-session');
    expect(shown, isEmpty);
  });

  test('JWT refresh keeps delivery but account switching discards old events', () async {
    FlutterSecureStorage.setMockInitialValues({
      'xaneo_active_account_v1': 'account-a',
      'xaneo_account::account-a::access': 'refreshed-token',
    });
    await NotificationService().handleNotificationFrame(event(1), 'old-token', accountKey: 'account-a');
    await NotificationService().handleNotificationFrame(event(2), 'old-token', accountKey: 'account-b');
    expect(shown, hasLength(1));
  });
}
