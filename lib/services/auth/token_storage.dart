import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../config/app_config.dart';

class StoredAccount {
  final String accountKey;
  final Map<String, dynamic> userData;
  final DateTime lastUsedAt;

  const StoredAccount({
    required this.accountKey,
    required this.userData,
    required this.lastUsedAt,
  });

  int? get userId => (userData['id'] as num?)?.toInt();
  String get username => userData['username']?.toString() ?? '';
  String get email => userData['email']?.toString() ?? '';

  Map<String, dynamic> toJson() => {
        'account_key': accountKey,
        'user': userData,
        'last_used_at': lastUsedAt.toIso8601String(),
      };

  factory StoredAccount.fromJson(Map<String, dynamic> json) {
    return StoredAccount(
      accountKey: json['account_key'] as String,
      userData: Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
      lastUsedAt: DateTime.tryParse(json['last_used_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class ActiveSessionSnapshot {
  final String accountKey;
  final int generation;
  final String refreshToken;

  const ActiveSessionSnapshot({
    required this.accountKey,
    required this.generation,
    required this.refreshToken,
  });
}

/// Secure, account-scoped storage for authentication material.
///
/// Display metadata and all secrets live in Keychain/EncryptedSharedPreferences.
/// The active-account pointer is switched only after a complete token bundle has
/// been persisted, so a failed switch cannot overwrite the current session.
class TokenStorage {
  static const _accountsIndexKey = 'xaneo_accounts_v1';
  static const _activeAccountKey = 'xaneo_active_account_v1';
  static const _maxAccounts = 5;

  final FlutterSecureStorage _storage;
  int _generation = 0;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  String _field(String accountKey, String name) =>
      'xaneo_account::$accountKey::$name';

  String accountKeyForUser(int userId) {
    final scope = Uri.parse(AppConfig.apiBaseUrl)
        .replace(query: null, fragment: null)
        .toString()
        .replaceFirst(RegExp(r'/+$'), '');
    return base64UrlEncode(utf8.encode('$scope::$userId')).replaceAll('=', '');
  }

  Future<List<StoredAccount>> getStoredAccounts() async {
    final raw = await _storage.read(key: _accountsIndexKey);
    if (raw == null || raw.isEmpty) return <StoredAccount>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <StoredAccount>[];
      final accounts = decoded
          .whereType<Map>()
          .map(
              (item) => StoredAccount.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.userId != null && item.username.isNotEmpty)
          .toList()
        ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
      return accounts;
    } catch (_) {
      return <StoredAccount>[];
    }
  }

  /// Preserves the currently signed-in user when upgrading from singleton
  /// token storage. A legacy session has no grant and therefore cannot be used
  /// for passwordless switching until the next full login.
  Future<void> migrateLegacySessionIfNeeded() async {
    if ((await getStoredAccounts()).isNotEmpty ||
        await getActiveAccountKey() != null) {
      return;
    }
    final access = await _storage.read(key: AppConfig.accessTokenKey);
    final refresh = await _storage.read(key: AppConfig.refreshTokenKey);
    final rawUser = await _storage.read(key: AppConfig.userDataKey);
    if (access == null || refresh == null || rawUser == null) return;
    try {
      final user = Map<String, dynamic>.from(jsonDecode(rawUser) as Map);
      await saveAccountSession(
        userData: user,
        accessToken: access,
        refreshToken: refresh,
      );
    } catch (_) {
      // Leave legacy values untouched; the old session remains recoverable.
    }
  }

  Future<String?> getActiveAccountKey() async {
    return _storage.read(key: _activeAccountKey);
  }

  Future<StoredAccount?> getActiveAccount() async {
    final key = await getActiveAccountKey();
    if (key == null) return null;
    for (final account in await getStoredAccounts()) {
      if (account.accountKey == key) return account;
    }
    return null;
  }

  Future<void> saveAccountSession({
    required Map<String, dynamic> userData,
    required String accessToken,
    required String refreshToken,
    String? deviceGrant,
  }) async {
    final userId = (userData['id'] as num?)?.toInt();
    if (userId == null || userId <= 0) {
      throw StateError('Cannot store an account without a valid user id');
    }
    final accountKey = accountKeyForUser(userId);
    final now = DateTime.now();

    // Write a complete bundle before publishing the active pointer.
    await _storage.write(key: _field(accountKey, 'access'), value: accessToken);
    await _storage.write(
        key: _field(accountKey, 'refresh'), value: refreshToken);
    await _storage.write(
        key: _field(accountKey, 'user'), value: jsonEncode(userData));
    if (deviceGrant != null && deviceGrant.isNotEmpty) {
      await _storage.write(
          key: _field(accountKey, 'device_grant'), value: deviceGrant);
    }

    final accounts = await getStoredAccounts();
    accounts.removeWhere((item) => item.accountKey == accountKey);
    accounts.insert(
      0,
      StoredAccount(
        accountKey: accountKey,
        userData: userData,
        lastUsedAt: now,
      ),
    );

    final evicted = accounts.skip(_maxAccounts).toList();
    final kept = accounts.take(_maxAccounts).toList();
    await _storage.write(
      key: _accountsIndexKey,
      value: jsonEncode(kept.map((item) => item.toJson()).toList()),
    );
    await _storage.write(key: _activeAccountKey, value: accountKey);
    _generation++;

    for (final account in evicted) {
      await _deleteAccountSecrets(account.accountKey);
    }

    // Remove legacy singleton values after the scoped bundle is durable.
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
    await _storage.delete(key: AppConfig.userDataKey);
  }

  Future<bool> activateAccount(String accountKey) async {
    final accounts = await getStoredAccounts();
    if (!accounts.any((item) => item.accountKey == accountKey)) return false;
    final access = await _storage.read(key: _field(accountKey, 'access'));
    final refresh = await _storage.read(key: _field(accountKey, 'refresh'));
    if ((access == null || access.isEmpty) &&
        (refresh == null || refresh.isEmpty)) {
      return false;
    }
    await _storage.write(key: _activeAccountKey, value: accountKey);
    _generation++;
    return true;
  }

  Future<String?> getDeviceGrant(String accountKey) {
    return _storage.read(key: _field(accountKey, 'device_grant'));
  }

  Future<String?> getGrantId(String accountKey) async {
    final grant = await getDeviceGrant(accountKey);
    if (grant == null || !grant.contains('.')) return null;
    return grant.substring(0, grant.indexOf('.'));
  }

  Future<Map<String, String>> getAccountGrants() async {
    final result = <String, String>{};
    for (final account in await getStoredAccounts()) {
      final grant = await getDeviceGrant(account.accountKey);
      if (grant != null && grant.isNotEmpty) {
        result[account.accountKey] = grant;
      }
    }
    return result;
  }

  Future<String?> getAccessToken() async {
    final key = await getActiveAccountKey();
    if (key != null) {
      final token = await _storage.read(key: _field(key, 'access'));
      if (token != null) return token;
    }
    return _storage.read(key: AppConfig.accessTokenKey);
  }

  Future<void> saveAccessToken(String token) async {
    final key = await getActiveAccountKey();
    await _storage.write(
      key: key == null ? AppConfig.accessTokenKey : _field(key, 'access'),
      value: token,
    );
  }

  Future<String?> getRefreshToken() async {
    final key = await getActiveAccountKey();
    if (key != null) {
      final token = await _storage.read(key: _field(key, 'refresh'));
      if (token != null) return token;
    }
    return _storage.read(key: AppConfig.refreshTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    final key = await getActiveAccountKey();
    await _storage.write(
      key: key == null ? AppConfig.refreshTokenKey : _field(key, 'refresh'),
      value: token,
    );
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final active = await getActiveAccount();
    if (active != null) return Map<String, dynamic>.from(active.userData);
    final raw = await _storage.read(key: AppConfig.userDataKey);
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final key = await getActiveAccountKey();
    if (key == null) {
      await _storage.write(
          key: AppConfig.userDataKey, value: jsonEncode(userData));
      return;
    }
    await _storage.write(key: _field(key, 'user'), value: jsonEncode(userData));
    final accounts = await getStoredAccounts();
    final updated = accounts
        .map((item) => item.accountKey == key
            ? StoredAccount(
                accountKey: key,
                userData: userData,
                lastUsedAt: item.lastUsedAt,
              )
            : item)
        .toList();
    await _storage.write(
      key: _accountsIndexKey,
      value: jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
  }

  Future<bool> hasAccessToken() async =>
      (await getAccessToken())?.isNotEmpty == true;
  Future<bool> hasRefreshToken() async =>
      (await getRefreshToken())?.isNotEmpty == true;
  Future<bool> isAuthenticated() async =>
      await hasAccessToken() || await hasRefreshToken();

  Future<ActiveSessionSnapshot?> captureRefreshSession() async {
    final accountKey = await getActiveAccountKey();
    final refresh = await getRefreshToken();
    if (accountKey == null || refresh == null || refresh.isEmpty) return null;
    return ActiveSessionSnapshot(
      accountKey: accountKey,
      generation: _generation,
      refreshToken: refresh,
    );
  }

  Future<bool> saveRefreshedTokensIfCurrent(
    ActiveSessionSnapshot snapshot,
    String accessToken, {
    String? refreshToken,
  }) async {
    if (snapshot.generation != _generation ||
        await getActiveAccountKey() != snapshot.accountKey) {
      return false;
    }
    await _storage.write(
        key: _field(snapshot.accountKey, 'access'), value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(
          key: _field(snapshot.accountKey, 'refresh'), value: refreshToken);
    }
    return true;
  }

  /// Ends the active JWT session but deliberately keeps its saved-login grant.
  Future<void> clearActiveSession() async {
    final key = await getActiveAccountKey();
    if (key != null) {
      await _storage.delete(key: _field(key, 'access'));
      await _storage.delete(key: _field(key, 'refresh'));
    }
    await _storage.delete(key: _activeAccountKey);
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
    await _storage.delete(key: AppConfig.userDataKey);
    _generation++;
  }

  Future<void> removeAccount(String accountKey) async {
    final accounts = await getStoredAccounts()
      ..removeWhere((item) => item.accountKey == accountKey);
    await _storage.write(
      key: _accountsIndexKey,
      value: jsonEncode(accounts.map((item) => item.toJson()).toList()),
    );
    if (await getActiveAccountKey() == accountKey) {
      await _storage.delete(key: _activeAccountKey);
      _generation++;
    }
    await _deleteAccountSecrets(accountKey);
  }

  Future<void> _deleteAccountSecrets(String accountKey) async {
    for (final field in ['access', 'refresh', 'user', 'device_grant']) {
      await _storage.delete(key: _field(accountKey, field));
    }
  }

  /// Full application-data reset. Normal logout must use clearActiveSession().
  Future<void> clearAll() async {
    for (final account in await getStoredAccounts()) {
      await _deleteAccountSecrets(account.accountKey);
    }
    await _storage.delete(key: _accountsIndexKey);
    await _storage.delete(key: _activeAccountKey);
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
    await _storage.delete(key: AppConfig.userDataKey);
    _generation++;
  }

  Future<void> clearAccessToken() async {
    final key = await getActiveAccountKey();
    await _storage.delete(
        key: key == null ? AppConfig.accessTokenKey : _field(key, 'access'));
  }

  Future<void> clearRefreshToken() async {
    final key = await getActiveAccountKey();
    await _storage.delete(
        key: key == null ? AppConfig.refreshTokenKey : _field(key, 'refresh'));
  }
}
