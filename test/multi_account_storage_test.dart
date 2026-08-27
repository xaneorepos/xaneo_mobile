import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/services/auth/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('sessions and grants remain isolated per account', () async {
    final storage = TokenStorage();
    await storage.saveAccountSession(
      userData: {'id': 11, 'username': 'north'},
      accessToken: 'access-11',
      refreshToken: 'refresh-11',
      deviceGrant: '11111111-1111-1111-1111-111111111111.secretA',
    );
    final firstKey = (await storage.getActiveAccountKey())!;

    await storage.saveAccountSession(
      userData: {'id': 22, 'username': 'south'},
      accessToken: 'access-22',
      refreshToken: 'refresh-22',
      deviceGrant: '22222222-2222-2222-2222-222222222222.secretB',
    );
    final secondKey = (await storage.getActiveAccountKey())!;

    expect(firstKey, isNot(secondKey));
    expect(await storage.getAccessToken(), 'access-22');
    expect(await storage.getDeviceGrant(firstKey), contains('secretA'));

    expect(await storage.activateAccount(firstKey), isTrue);
    expect(await storage.getAccessToken(), 'access-11');
    expect((await storage.getUserData())!['username'], 'north');
  });

  test('refresh result is rejected after account switch', () async {
    final storage = TokenStorage();
    await storage.saveAccountSession(
      userData: {'id': 31, 'username': 'first'},
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
      deviceGrant: '33333333-3333-3333-3333-333333333333.secretC',
    );
    final firstKey = (await storage.getActiveAccountKey())!;
    final snapshot = (await storage.captureRefreshSession())!;

    await storage.saveAccountSession(
      userData: {'id': 32, 'username': 'second'},
      accessToken: 'second-access',
      refreshToken: 'second-refresh',
      deviceGrant: '44444444-4444-4444-4444-444444444444.secretD',
    );

    expect(
      await storage.saveRefreshedTokensIfCurrent(snapshot, 'leaked-access'),
      isFalse,
    );
    expect(await storage.getAccessToken(), 'second-access');
    await storage.activateAccount(firstKey);
    expect(await storage.getAccessToken(), 'old-access');
  });

  test('logout clears JWT but preserves saved-login grant', () async {
    final storage = TokenStorage();
    await storage.saveAccountSession(
      userData: {'id': 41, 'username': 'saved'},
      accessToken: 'access',
      refreshToken: 'refresh',
      deviceGrant: '55555555-5555-5555-5555-555555555555.secretE',
    );
    final key = (await storage.getActiveAccountKey())!;

    await storage.clearActiveSession();

    expect(await storage.isAuthenticated(), isFalse);
    expect(await storage.getDeviceGrant(key), contains('secretE'));
    expect(await storage.getStoredAccounts(), hasLength(1));
  });
}
