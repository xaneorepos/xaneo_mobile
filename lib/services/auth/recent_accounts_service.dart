import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../../models/auth/recent_account.dart';
import '../api/api_client.dart';
import 'token_storage.dart';

/// Reconciles display-only account metadata with server-validated grants.
/// Authentication remains impossible without the secret kept by TokenStorage.
class RecentAccountsService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  RecentAccountsService({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<List<RecentAccount>> getLocalRecentAccounts() async {
    final accounts = await _tokenStorage.getStoredAccounts();
    return Future.wait(accounts.map((account) async {
      final user = account.userData;
      return RecentAccount(
        accountKey: account.accountKey,
        grantId: await _tokenStorage.getGrantId(account.accountKey),
        id: account.userId!,
        username: account.username,
        email: account.email,
        firstName: user['first_name']?.toString(),
        avatar: (user['avatar'] ?? user['avatar_url'])?.toString(),
        avatarGradient: user['avatar_gradient']?.toString(),
        hasAvatar: user['has_avatar'] == true ||
            (user['avatar']?.toString().isNotEmpty ?? false),
        lastLogin: account.lastUsedAt,
        firstLogin: account.lastUsedAt,
      );
    }));
  }

  Future<RecentAccountsResponse> getRecentAccounts() async {
    final grantsByAccount = await _tokenStorage.getAccountGrants();
    if (grantsByAccount.isEmpty) {
      return const RecentAccountsResponse(success: true);
    }

    try {
      final response = await _apiClient.get(
        AppConfig.authRecentAccounts,
        options: Options(headers: {
          'X-Device-Grants': grantsByAccount.values.join(','),
        }),
      );
      final parsed = RecentAccountsResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      final accountByGrantId = <String, String>{};
      for (final entry in grantsByAccount.entries) {
        final separator = entry.value.indexOf('.');
        if (separator > 0) {
          accountByGrantId[entry.value.substring(0, separator)] = entry.key;
        }
      }
      final validated = parsed.recentAccounts
          .map((item) => item.copyWith(
                accountKey: accountByGrantId[item.grantId] ?? item.accountKey,
                isAvailable: true,
              ))
          .where((item) => item.accountKey.isNotEmpty)
          .toList();
      final validatedKeys = validated.map((item) => item.accountKey).toSet();
      final localOnly = (await getLocalRecentAccounts())
          .where((item) => !validatedKeys.contains(item.accountKey))
          .map((item) => item.copyWith(isAvailable: false));
      final reconciled = [...validated, ...localOnly]
        ..sort((a, b) => b.lastLogin.compareTo(a.lastLogin));
      return RecentAccountsResponse(
        success: parsed.success,
        recentAccounts: reconciled,
        count: reconciled.length,
        error: parsed.error,
      );
    } catch (error) {
      debugPrint('Recent accounts validation failed: $error');
      final local = await getLocalRecentAccounts();
      return RecentAccountsResponse(
        success: false,
        recentAccounts:
            local.map((item) => item.copyWith(isAvailable: false)).toList(),
        count: local.length,
        error: error.toString(),
      );
    }
  }

  Future<List<RecentAccount>> syncWithServer() async {
    final response = await getRecentAccounts();
    return response.recentAccounts;
  }

  Future<void> removeAccountLocally(String accountKey) {
    return _tokenStorage.removeAccount(accountKey);
  }

  Future<void> clearLocalAccounts() => _tokenStorage.clearAll();

  // Compatibility: account metadata is committed together with tokens.
  Future<void> saveAccountLocally(RecentAccount account) async {}

  Future<bool> needsSync() async => true;
  Future<DateTime?> getLastSyncTime() async => null;
}
