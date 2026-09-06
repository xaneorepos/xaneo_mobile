import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/auth/user_model.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/api_error.dart';
import '../models/auth/recent_account.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/recent_accounts_service.dart';
import '../services/auth/token_storage.dart';
import '../services/api/api_client.dart';
import '../services/crypto/crypto_service.dart';
import '../services/crypto/xsec2_service.dart';
import '../services/notifications/notification_service.dart';
import '../services/avatar_cache_service.dart';

/// Состояние авторизации
enum AuthStatus {
  initial,
  checking,
  unauthenticated,
  tfaRequired,
  authenticated,
}

/// Provider для управления состоянием авторизации
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final RecentAccountsService _recentAccountsService;
  final Xsec2Service? _xsec2Service;
  CryptoService? _cryptoService;

  AuthStatus _status = AuthStatus.checking;
  UserModel? _user;
  String? _tfaToken;
  String? _pendingUsername;
  String? _pendingPassword;
  String? _pendingQuickAccountKey;
  String? _quickLoginChallengeId;
  AuthStatus? _statusBeforePendingAuth;
  UserModel? _userBeforePendingAuth;
  ApiError? _error;
  bool _isLoading = false;

  AuthProvider({
    required AuthService authService,
    required RecentAccountsService recentAccountsService,
    Xsec2Service? xsec2Service,
    CryptoService? cryptoService,
  })  : _authService = authService,
        _recentAccountsService = recentAccountsService,
        _xsec2Service = xsec2Service,
        _cryptoService = cryptoService;

  AuthService get authService => _authService;

  void setCryptoService(CryptoService cryptoService) {
    _cryptoService = cryptoService;
  }

  void _syncCryptoServiceFromXsec2() {
    if (_cryptoService == null && _xsec2Service != null) {
      _cryptoService = _xsec2Service!.cryptoService;
    }
  }

  Future<void> _syncCryptoUserId() async {
    final crypto = _cryptoService;
    final user = _user;
    if (crypto == null || user == null || user.id <= 0) return;

    await crypto.activateAccountScope(user.id.toString());
    debugPrint('XSEC-2: synced current user id=${user.id} to CryptoService');
  }

  Future<void> _ensureCryptoKeysReady(
      {String? password, String? username, dynamic xsec2Payload}) async {
    if (_cryptoService == null) return;
    try {
      await _cryptoService!.init();
      await _cryptoService!.ensureLocalKeyMatchesServer();
      if (!_cryptoService!.hasKeys) {
        final restoredFromMobile =
            await _cryptoService!.tryRestoreKeysFromServerPayload(
          xsec2Payload,
          password: password,
          username: username,
        );

        final restored = restoredFromMobile ||
            await _cryptoService!.restoreKeysFromServerIfPossible(
              password: password,
              username: username,
            );

        if (restored) {
          debugPrint('XSEC-2: Restored keys from server payload');
        } else if (_cryptoService!.serverKeysPresentWithoutRecovery) {
          debugPrint(
              'XSEC-2: Server keys detected, skip regeneration to avoid key rotation');
        } else {
          debugPrint(
              'XSEC-2: No keys found anywhere, generating user keys and uploading to server...');
          final keys = await _cryptoService!.generateUserKeys();
          await _cryptoService!.saveUserKeys(keys);
          await _cryptoService!.uploadKeysToServer(password: password);
        }
      } else {
        debugPrint('XSEC-2: Keys already exist locally');
      }
    } catch (e) {
      debugPrint('XSEC-2: Error in _ensureCryptoKeysReady: $e');
    }
  }

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get tfaToken => _tfaToken;
  ApiError? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get requiresTfa => _status == AuthStatus.tfaRequired;
  bool get hasPendingQuickLoginTfa =>
      _pendingQuickAccountKey != null && _quickLoginChallengeId != null;

  Future<void> checkAuthStatus({CryptoService? cryptoService}) async {
    if (cryptoService != null) {
      _cryptoService = cryptoService;
    }

    _syncCryptoServiceFromXsec2();

    _status = AuthStatus.checking;
    notifyListeners();

    try {
      await _authService.tokenStorage.migrateLegacySessionIfNeeded();
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _user = await _authService.getCurrentUser();
        if (_user != null &&
            (_user!.firstName == null || _user!.firstName!.isEmpty)) {
          final locals = await _recentAccountsService.getLocalRecentAccounts();
          for (final acc in locals) {
            if ((acc.username == _user!.username || acc.id == _user!.id) &&
                acc.firstName != null &&
                acc.firstName!.isNotEmpty) {
              _user = _user!.copyWith(firstName: acc.firstName);
              await _authService.tokenStorage.saveUserData(_user!.toJson());
              break;
            }
          }
        }
        await _syncCryptoUserId();
        _status = _user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;

        if (_status == AuthStatus.authenticated) {
          await _ensureCryptoKeysReady();
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
    _registerDeviceTokenIfAuthenticated();
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    debugPrint('=== AuthProvider.login() ===');
    _syncCryptoServiceFromXsec2();
    _setLoading(true);
    _clearError();
    final previousStatus = _status;
    final previousUser = _user;

    try {
      final result = await _authService.mobileLogin(
        username: username,
        password: password,
      );
      if (result.requiresTfa) {
        _tfaToken = result.tempToken;
        _pendingUsername = username;
        _pendingPassword = password;
        _statusBeforePendingAuth = previousStatus;
        _userBeforePendingAuth = previousUser;
        _user = previousStatus == AuthStatus.authenticated
            ? previousUser
            : result.userInfo;

        if (_tfaToken == null || _tfaToken!.isEmpty) {
          _error = const ApiError(message: 'Сервер не вернул токен 2FA');
          _setLoading(false);
          cancelTfa();
          return false;
        }

        final sendResult = await _authService.sendTfaCode(token: _tfaToken!);
        if (!sendResult.success) {
          _error = ApiError(
            message: sendResult.message ?? 'Не удалось отправить код 2FA',
          );
          _setLoading(false);
          cancelTfa();
          return false;
        }

        _status = AuthStatus.tfaRequired;
        _setLoading(false);
        notifyListeners();
        return false;
      }

      if (result.isSuccess) {
        _user = result.userInfo;
        await _syncCryptoUserId();
        _status = AuthStatus.authenticated;

        // Init/Ensure XSEC-2 keys after successful login
        await _ensureCryptoKeysReady(
          password: password,
          username: username,
          xsec2Payload: result.response?.xsec2,
        );

        _setLoading(false);
        notifyListeners();
        _registerDeviceTokenIfAuthenticated();
        return true;
      }

      _error = ApiError(message: result.message ?? 'Login failed');
      _status = previousStatus;
      _user = previousUser;
      _setLoading(false);
      notifyListeners();
      return false;
    } on ApiError catch (e) {
      _error = e;
      _status = previousStatus;
      _user = previousUser;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyTfaCode(String code) async {
    if (_tfaToken == null ||
        _pendingUsername == null ||
        _pendingPassword == null) {
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final username = _pendingUsername!;
      final password = _pendingPassword!;
      final verifiedResponse = await _authService.verifyTfaCode(
        token: _tfaToken!,
        code: code,
      );
      if (verifiedResponse == null) {
        throw const ApiError(
          message: 'Сервер не вернул сессию после подтверждения 2FA',
        );
      }
      final tokenResponse = verifiedResponse;

      _user = tokenResponse.user;
      await _syncCryptoUserId();
      await _ensureCryptoKeysReady(
        password: password,
        username: username,
        xsec2Payload: tokenResponse.xsec2,
      );
      _status = AuthStatus.authenticated;
      _tfaToken = null;
      _pendingUsername = null;
      _pendingPassword = null;
      _statusBeforePendingAuth = null;
      _userBeforePendingAuth = null;
      _setLoading(false);
      notifyListeners();
      _registerDeviceTokenIfAuthenticated();
      return true;
    } on ApiError catch (e) {
      _error = e;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendTfaCode() async {
    final token = _tfaToken;
    if (token == null || token.isEmpty) return false;

    _setLoading(true);
    _clearError();
    notifyListeners();
    try {
      final response = await _authService.sendTfaCode(token: token);
      if (!response.success) {
        _error = ApiError(
          message: response.message ?? 'Не удалось отправить код повторно',
        );
      }
      _setLoading(false);
      notifyListeners();
      return response.success;
    } on ApiError catch (e) {
      _error = e;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void cancelTfa() {
    _tfaToken = null;
    _pendingUsername = null;
    _pendingPassword = null;
    _user = _userBeforePendingAuth;
    _status = _statusBeforePendingAuth ?? AuthStatus.unauthenticated;
    _statusBeforePendingAuth = null;
    _userBeforePendingAuth = null;
    notifyListeners();
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? birthDate,
    String? realname,
    File? avatarFile,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final registerResponse = await _authService.register(
        username: username,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        birthDate: birthDate,
        realname: realname,
        avatarFile: avatarFile,
      );

      if (registerResponse.success) {
        // Current mobile-register responses contain a complete JWT session and
        // AuthService persists it. Older deployments only returned user data,
        // so fall back to a regular mobile login instead of showing the login
        // screen again after a successful registration.
        var registeredUser = await _authService.getCurrentUser();
        if (registeredUser == null) {
          final loginResult = await _authService.mobileLogin(
            username: username,
            password: password,
          );
          if (!loginResult.isSuccess || loginResult.userInfo == null) {
            _error = ApiError(
              message: loginResult.message ??
                  'Регистрация завершена, но не удалось войти в аккаунт',
            );
            _status = AuthStatus.unauthenticated;
            _setLoading(false);
            notifyListeners();
            return false;
          }
          registeredUser = loginResult.userInfo;
        }

        _user = registeredUser;

        await _syncCryptoUserId();
        await _ensureCryptoKeysReady(password: password, username: username);
        _status = AuthStatus.authenticated;
        _setLoading(false);
        notifyListeners();
        _registerDeviceTokenIfAuthenticated();
        return true;
      } else {
        _error = ApiError(
            message: registerResponse.message ?? 'Registration failed');
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } on ApiError catch (e) {
      _error = e;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    if (_cryptoService != null) {
      await _cryptoService!.deactivateAccountScope();
    }
    _user = null;
    _status = AuthStatus.unauthenticated;
    _tfaToken = null;
    _pendingUsername = null;
    _pendingPassword = null;
    _pendingQuickAccountKey = null;
    _quickLoginChallengeId = null;
    _statusBeforePendingAuth = null;
    _userBeforePendingAuth = null;
    _error = null;
    notifyListeners();
  }

  /// Applies profile fields returned by authenticated profile endpoints and
  /// persists them in the active account bundle. This keeps the settings
  /// screen, account switcher and the rest of the app in sync immediately.
  Future<void> updateCurrentUser(Map<String, dynamic> changes) async {
    final current = _user;
    if (current == null) return;

    final merged = <String, dynamic>{...current.toJson(), ...changes};
    final avatarWasUpdated = changes.containsKey('avatar_url') ||
        changes.containsKey('custom_avatar') ||
        changes.containsKey('avatar');
    final avatar =
        changes['avatar_url'] ?? changes['custom_avatar'] ?? changes['avatar'];
    if (avatarWasUpdated) {
      merged['avatar'] = avatar;
      await AvatarCacheService.instance.invalidate(current.avatar);
      if (avatar?.toString() != current.avatar) {
        await AvatarCacheService.instance.invalidate(avatar?.toString());
      }
    }

    _user = UserModel.fromJson(merged);
    await _authService.tokenStorage.saveUserData(_user!.toJson());
    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void resetTfaState() {
    if (_pendingQuickAccountKey != null) {
      _pendingQuickAccountKey = null;
      _quickLoginChallengeId = null;
      if (_status != AuthStatus.authenticated) {
        _status = AuthStatus.unauthenticated;
        _user = null;
      }
      notifyListeners();
      return;
    }
    cancelTfa();
  }

  Future<AvailabilityResponse> checkUsername(String username) async {
    try {
      return await _authService.checkUsername(username);
    } on ApiError catch (e) {
      _error = e;
      notifyListeners();
      rethrow;
    }
  }

  Future<AvailabilityResponse> checkEmail(String email) async {
    try {
      return await _authService.checkEmail(email);
    } on ApiError catch (e) {
      _error = e;
      notifyListeners();
      rethrow;
    }
  }

  Future<VerificationCodeResponse> sendVerificationCode(String email,
      {String? username}) async {
    try {
      return await _authService.sendVerificationCode(email, username: username);
    } on ApiError catch (e) {
      _error = e;
      notifyListeners();
      rethrow;
    }
  }

  Future<VerifyCodeResponse> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      return await _authService.verifyEmailCode(email: email, code: code);
    } on ApiError catch (e) {
      _error = e;
      notifyListeners();
      rethrow;
    }
  }

  Future<RecentAccountsResponse> getRecentAccounts() async {
    return _recentAccountsService.getRecentAccounts();
  }

  Future<bool> quickLogin({
    required String accountKey,
    String? tfaCode,
  }) async {
    if (_isLoading) return false;
    final previousStatus = _status;
    final previousUser = _user;
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.quickLogin(
        accountKey: accountKey,
        tfaCode: tfaCode,
        challengeId: tfaCode == null ? null : _quickLoginChallengeId,
      );

      if (response.requiresTfa) {
        _pendingQuickAccountKey = accountKey;
        _quickLoginChallengeId = response.challengeId;
        _status = previousStatus == AuthStatus.authenticated
            ? previousStatus
            : AuthStatus.tfaRequired;
        _setLoading(false);
        notifyListeners();
        return false;
      }

      if (response.success) {
        if (response.userInfo != null) {
          _user = UserModel(
            id: response.userInfo!.id ?? 0,
            username: response.userInfo!.username ?? '',
            email: response.userInfo!.email ?? '',
            firstName: response.userInfo!.firstName,
            emailVerified: response.userInfo!.isVerified ?? false,
            tfaEnabled: response.userInfo!.tfaEnabled ?? false,
            avatar: response.userInfo!.avatarUrl,
            createdAt: DateTime.now(),
          );
          await _syncCryptoUserId();
          await _ensureCryptoKeysReady(xsec2Payload: response.xsec2);
        }
        _pendingQuickAccountKey = null;
        _quickLoginChallengeId = null;
        _status = AuthStatus.authenticated;
        _setLoading(false);
        notifyListeners();
        _registerDeviceTokenIfAuthenticated();
        return true;
      }

      _error = ApiError(message: response.errorMessage ?? 'Quick login failed');
      _status = previousStatus;
      _user = previousUser;
      _setLoading(false);
      notifyListeners();
      return false;
    } on ApiError catch (e) {
      _error = e;
      _status = previousStatus;
      _user = previousUser;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyQuickLoginTfa(String code) async {
    final accountKey = _pendingQuickAccountKey;
    if (accountKey == null || _quickLoginChallengeId == null) return false;
    return quickLogin(accountKey: accountKey, tfaCode: code);
  }

  Future<void> removeSavedAccount(String accountKey) async {
    final activeKey = await _authService.tokenStorage.getActiveAccountKey();
    await _authService.removeSavedAccount(accountKey);
    if (activeKey == accountKey) {
      await logout();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _clearError() {
    _error = null;
  }

  /// Вспомогательный метод для регистрации токена устройства при успешном входе
  Future<void> _registerDeviceTokenIfAuthenticated() async {
    if (_status == AuthStatus.authenticated) {
      try {
        final token = await NotificationService().getDeviceToken();
        if (token != null) {
          await _authService.registerFcmToken(token);
        }
      } catch (e) {
        debugPrint(
            'FCM: Failed to fetch/register device token: ${e.runtimeType}');
      }
    }
  }
}

class AuthProviderFactory {
  static AuthProvider create() {
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage: tokenStorage);
    final authService = AuthService(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );
    final recentAccountsService = RecentAccountsService(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    return AuthProvider(
      authService: authService,
      recentAccountsService: recentAccountsService,
    );
  }

  static AuthProvider createWithCryptoService(
    ApiClient apiClient,
    CryptoService cryptoService,
    TokenStorage tokenStorage,
  ) {
    final authService = AuthService(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );
    final recentAccountsService = RecentAccountsService(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    return AuthProvider(
      authService: authService,
      recentAccountsService: recentAccountsService,
      cryptoService: cryptoService,
    );
  }
}
