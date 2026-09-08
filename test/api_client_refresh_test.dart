import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/services/api/api_client.dart';
import 'package:xaneo/services/auth/token_storage.dart';

class _StatusAdapter implements HttpClientAdapter {
  final int statusCode;
  final String body;
  int calls = 0;

  _StatusAdapter(this.statusCode, {this.body = '{}'});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<ApiClient> _clientUsing(_StatusAdapter adapter) async {
  final storage = TokenStorage();
  await storage.saveAccountSession(
    userData: {'id': 7, 'username': 'tester'},
    accessToken: 'expired-access',
    refreshToken: 'valid-refresh',
  );
  final client = ApiClient(tokenStorage: storage);
  client.dio.httpClientAdapter = adapter;
  return client;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('transient refresh failure does not expire the local session', () async {
    final client = await _clientUsing(_StatusAdapter(503));
    var expirationNotifications = 0;
    client.onSessionExpired = () => expirationNotifications++;

    expect(await client.refreshToken(), isNull);
    expect(expirationNotifications, 0);
  });

  test('rejected refresh token expires the session once', () async {
    final client = await _clientUsing(_StatusAdapter(401));
    var expirationNotifications = 0;
    client.onSessionExpired = () => expirationNotifications++;

    final results = await Future.wait([
      client.refreshToken(),
      client.refreshToken(),
      client.refreshToken(),
    ]);

    expect(results, everyElement(isNull));
    expect(expirationNotifications, 1);
  });

  test('concurrent callers wait for one successful token rotation', () async {
    final adapter = _StatusAdapter(
      200,
      body: '{"access":"rotated-access","refresh":"rotated-refresh"}',
    );
    final client = await _clientUsing(adapter);

    final results = await Future.wait([
      client.refreshToken(),
      client.refreshToken(),
      client.refreshToken(),
    ]);

    expect(results, everyElement('rotated-access'));
    expect(adapter.calls, 1);
  });
}
