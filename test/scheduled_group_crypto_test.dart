import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/services/api/api_client.dart';
import 'package:xaneo/services/auth/token_storage.dart';
import 'package:xaneo/services/crypto/crypto_service.dart';

class EpochApi extends ApiClient {
  EpochApi() : super(tokenStorage: TokenStorage());
  int current = 503;
  final keys = {503: '11' * 32, 504: '22' * 32};
  final paths = <String>[];
  @override
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    paths.add(path);
    final id = path.endsWith('/current/')
        ? current
        : int.parse(RegExp(r'/epoch/(\d+)/').firstMatch(path)!.group(1)!);
    return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {
          'success': true,
          'epoch_id': id,
          'epoch_number': 1,
          'server_epoch_key': keys[id]
        });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test(
      'schedule binds fresh key and DB epoch ID, historical jobs stay readable',
      () async {
    final api = EpochApi();
    final service = CryptoService(apiClient: api);
    final first = await service.encryptScheduledMessage('first', 'group_7');
    expect(first['epoch_id'], 503);
    api.current = 504;
    final second = await service.encryptScheduledMessage('second', 'group_7');
    expect(second['epoch_id'], 504);
    expect(await service.decryptScheduledMessage(first, 'group_7'), 'first');
    expect(await service.decryptScheduledMessage(second, 'group_7'), 'second');
    expect(api.paths.where((path) => path.endsWith('/current/')), hasLength(2));
  });
  test('attachment-only group messages and desktop AES ciphertext decrypt',
      () async {
    final service = CryptoService(apiClient: EpochApi());
    final payload = await service.encryptScheduledMessage('', 'group_7');
    expect(base64Decode(payload['encrypted_text'] as String), hasLength(40));
    expect(await service.decryptScheduledMessage(payload, 'group_7'), '');
    final box = await crypto.AesGcm.with256bits().encrypt([],
        secretKey: crypto.SecretKey(Uint8List.fromList(List.filled(32, 0x11))));
    expect(
        await service.decryptScheduledMessage({
          'encrypted_text':
              base64Encode([...box.nonce, ...box.cipherText, ...box.mac.bytes]),
          'epoch_id': 503
        }, 'group_7'),
        '');
  });
}
