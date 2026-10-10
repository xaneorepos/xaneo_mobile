import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/config/app_config.dart';
import 'package:xaneo/services/api/api_client.dart';
import 'package:xaneo/services/auth/token_storage.dart';
import 'package:xaneo/services/crypto/crypto_service.dart';

class _KeyApiClient extends ApiClient {
  _KeyApiClient(this.keys) : super(tokenStorage: TokenStorage());

  final Map<String, List<int>> keys;

  @override
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    if (path == '/xsec2/keys/6/') {
      return Response(requestOptions: RequestOptions(path: path), statusCode: 404);
    }
    final chatId = path.contains('/group/')
        ? path.split('/group/').last.split('/').first
        : path.split('/keys/chat/').last.split('/').first;
    final key = keys[chatId];
    if (key == null) {
      return Response(requestOptions: RequestOptions(path: path), statusCode: 404);
    }
    final hex = key.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: path.contains('/group/')
          ? {'success': true, 'server_epoch_key': hex, 'epoch_number': 0}
          : {'success': true, 'key': hex},
    );
  }
}

Future<String> _seal(String text, List<int> key, {bool group = true}) async {
  final algorithm = group
      ? crypto.Xchacha20.poly1305Aead()
      : crypto.AesGcm.with256bits();
  final box = await algorithm.encrypt(
    utf8.encode(text), secretKey: crypto.SecretKey(key));
  return base64Encode(Uint8List.fromList([
    ...box.nonce, ...box.cipherText, ...box.mac.bytes,
  ]));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({
        AppConfig.userDataKey: jsonEncode({'id': 3}),
      }));

  test('group history uses the channel key for a mirrored post', () async {
    final groupKey = List<int>.filled(32, 1);
    final channelKey = List<int>.filled(32, 2);
    final service = CryptoService(apiClient: _KeyApiClient({
      'group_1': groupKey, 'channel_1': channelKey,
    }));
    final mirror = await _seal('Пост канала', channelKey);
    final regular = await _seal('Сообщение группы', groupKey);
    expect(await service.decryptChatMessage(mirror, 'group_1', message: {
      'message_type': 'channel_post_mirror',
      'message_data': {'channel_id': 1},
    }), 'Пост канала');
    expect(await service.decryptChatMessage(regular, 'group_1', message: {
      'message_type': 'regular',
    }), 'Сообщение группы');
  });

  test('deleted bot history uses its existing server chat key', () async {
    final botKey = List<int>.filled(32, 3);
    final service = CryptoService(apiClient: _KeyApiClient({
      'personal_3_6': botKey,
    }));
    final text = await _seal('Ответ удалённого бота', botKey, group: false);
    expect(await service.decryptChatMessage(text, 'personal_3_6'),
        'Ответ удалённого бота');
  });

  test('open system message stays readable without fetching a key', () async {
    final service = CryptoService(apiClient: _KeyApiClient({}));
    expect(await service.decryptChatMessage('Пользователь вошёл', 'group_1'),
        'Пользователь вошёл');
  });
}
