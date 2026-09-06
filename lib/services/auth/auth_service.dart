import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../models/auth/api_error.dart';
import '../../models/auth/auth_response.dart';
import '../../models/auth/user_model.dart';
import 'token_storage.dart';
import '../api/api_client.dart';

/// Сервис авторизации
///
/// Отвечает за:
/// - Вход в систему (с поддержкой 2FA)
/// - Регистрацию
/// - Проверку доступности username/email
/// - Отправку и проверку кодов верификации
/// - Обновление токенов
/// - Выход из системы
class AuthService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthService({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  TokenStorage get tokenStorage => _tokenStorage;

  /// Вход в систему через mobile-login API
  ///
  /// Возвращает MobileLoginResult:
  /// - Если у пользователя включен 2FA: requiresTfa = true, tempToken для верификации
  /// - Если вход успешен: isSuccess = true, userInfo содержит данные пользователя
  ///
  Future<MobileLoginResult> mobileLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authMobileLogin,
        data: {
          'username': username,
          'password': password,
        },
      );

      final mobileResponse = MobileLoginResponse.fromJson(response.data);
      // Если требуется 2FA
      if (mobileResponse.requiresTfa) {
        return MobileLoginResult.fromTfaRequired(mobileResponse);
      }

      // Если вход успешен (без 2FA)
      if (mobileResponse.isSuccess) {
        final user = mobileResponse.userInfo;
        final access = mobileResponse.accessToken;
        final refresh = mobileResponse.refreshToken;
        if (user == null || access == null || refresh == null) {
          throw const ApiError(
            message: 'Сервер не вернул полную сессию авторизации',
          );
        }
        await _tokenStorage.saveAccountSession(
          userData: user.toJson(),
          accessToken: access,
          refreshToken: refresh,
          deviceGrant: mobileResponse.deviceGrant,
        );
        return MobileLoginResult.fromSuccess(mobileResponse);
      }

      // Ошибка авторизации
      debugPrint('=> Login Error: ${mobileResponse.message}');
      return MobileLoginResult.fromError(
        mobileResponse.message ?? 'Ошибка авторизации',
      );
    } on DioException catch (e) {
      debugPrint('=== Mobile Login DioException ===');
      debugPrint('Type: ${e.type}');
      debugPrint('Status: ${e.response?.statusCode}');
      throw _handleDioError(e);
    }
  }

  /// Вход в систему через обычный login endpoint (возвращает JWT токены)
  ///
  /// Использовать только если mobile-login успешен и не требуется 2FA
  Future<AuthResponse> loginWithTokens({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authLogin,
        data: {
          'username': username,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveAuthData(authResponse);
      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Вход в систему (старый метод для совместимости)
  ///
  /// Возвращает LoginResult:
  /// - Если у пользователя включен 2FA: requiresTfa = true
  /// - Если вход успешен: isSuccess = true, authResponse содержит токены
  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authMobileLogin,
        data: {
          'username': username,
          'password': password,
        },
      );

      // Проверяем, требуется ли 2FA
      if (response.data['tfa_required'] == true) {
        return LoginResult.fromTfaRequired(
          TfaRequiredResponse.fromJson(response.data),
        );
      }

      // Успешный вход
      final authResponse = AuthResponse.fromJson(response.data);
      await _saveAuthData(authResponse);
      return LoginResult.fromAuthResponse(authResponse);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Отправка 2FA кода на email для временного токена mobile-login.
  Future<VerificationCodeResponse> sendTfaCode({
    required String token,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authSendTfaCode,
        data: {'token': token},
      );

      return VerificationCodeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Подтверждение 2FA кода для временного токена mobile-login.
  Future<AuthResponse?> verifyTfaCode({
    required String token,
    required String code,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authVerifyTfaCode,
        data: {
          'token': token,
          'code': code,
        },
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      final tokenData = data['tokens'] is Map
          ? Map<String, dynamic>.from(data['tokens'] as Map)
          : data;
      final access = tokenData['access'];
      final refresh = tokenData['refresh'];

      // Новый API сразу возвращает JWT после успешной проверки 2FA.
      // Старый API возвращал только success/user_info; null позволяет
      // провайдеру завершить вход через legacy login endpoint.
      if (access is! String || refresh is! String) {
        if (data['success'] == true) return null;
        throw const ApiError(
          message: 'Сервер не подтвердил двухфакторную аутентификацию',
        );
      }

      final userData = data['user'];
      final userInfoData = data['user_info'];
      final user = userData is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(userData))
          : userInfoData is Map
              ? UserModel.fromUserInfoJson(
                  Map<String, dynamic>.from(userInfoData),
                )
              : null;
      if (user == null) {
        throw const ApiError(
          message: 'Сервер не вернул данные пользователя после проверки 2FA',
        );
      }

      final authResponse = AuthResponse(
        accessToken: access,
        refreshToken: refresh,
        user: user,
        deviceGrant: data['device_grant'] as String?,
        xsec2: data['xsec2'] is Map
            ? Map<String, dynamic>.from(data['xsec2'] as Map)
            : null,
      );
      await _saveAuthData(authResponse);
      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Регистрация нового пользователя (мобильный эндпоинт)
  ///
  /// Требует предварительной верификации email:
  /// 1. sendVerificationCode(email)
  /// 2. verifyEmailCode(email, code) - устанавливает флаг в сессии
  /// 3. register(...) - проверяет флаг в сессии
  ///
  /// Возвращает MobileRegisterResponse (без JWT токенов!)
  /// Для получения токенов нужно использовать loginWithTokens после регистрации.
  Future<MobileRegisterResponse> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? birthDate,
    String? realname,
    bool dataProcessingConsent = true,
    File? avatarFile,
  }) async {
    try {
      final Map<String, dynamic> mapData = {
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'birth_date': birthDate,
        'data_processing_consent': dataProcessingConsent,
        if (realname != null) 'first_name': realname,
      };

      dynamic dataToSend;
      if (avatarFile != null) {
        dataToSend = FormData.fromMap({
          ...mapData,
          'avatar': await MultipartFile.fromFile(
            avatarFile.path,
            filename: avatarFile.path.split(Platform.pathSeparator).last,
          ),
        });
      } else {
        dataToSend = mapData;
      }

      final response = await _apiClient.post(
        AppConfig.authMobileRegister,
        data: dataToSend,
      );

      final registerResponse = MobileRegisterResponse.fromJson(response.data);

      // Сохраняем токены авторизации и данные пользователя
      if (registerResponse.success) {
        if (registerResponse.userId != null &&
            registerResponse.accessToken != null &&
            registerResponse.refreshToken != null) {
          await _tokenStorage.saveAccountSession(
            userData: {
              'id': registerResponse.userId,
              'username': registerResponse.username,
              'email': registerResponse.email,
              'first_name': registerResponse.firstName,
              'has_avatar': registerResponse.hasAvatar ?? (avatarFile != null),
              if (registerResponse.avatarUrl != null)
                'avatar': registerResponse.avatarUrl,
            },
            accessToken: registerResponse.accessToken!,
            refreshToken: registerResponse.refreshToken!,
            deviceGrant: registerResponse.deviceGrant,
          );
        }
      }

      return registerResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Обновить или удалить аватар текущего пользователя
  Future<Map<String, dynamic>?> updateUserAvatar({
    File? avatarFile,
    bool removeAvatar = false,
  }) async {
    try {
      dynamic dataToSend;
      if (removeAvatar) {
        dataToSend = {'remove_avatar': true};
      } else if (avatarFile != null) {
        dataToSend = FormData.fromMap({
          'avatar': await MultipartFile.fromFile(
            avatarFile.path,
            filename: avatarFile.path.split(Platform.pathSeparator).last,
          ),
        });
      } else {
        return null;
      }

      final response = await _apiClient.post(
        '/auth/avatar/',
        data: dataToSend,
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating user avatar: $e');
      return null;
    }
  }

  /// Проверка доступности username
  Future<AvailabilityResponse> checkUsername(String username) async {
    try {
      final response = await _apiClient.get(
        AppConfig.authCheckUsername,
        queryParameters: {'username': username},
      );
      return AvailabilityResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Проверка доступности email
  Future<AvailabilityResponse> checkEmail(String email) async {
    try {
      final response = await _apiClient.get(
        AppConfig.authCheckEmail,
        queryParameters: {'email': email},
      );
      return AvailabilityResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Отправка кода верификации на email
  Future<VerificationCodeResponse> sendVerificationCode(String email,
      {String? username}) async {
    try {
      final data = <String, dynamic>{'email': email};
      if (username != null) {
        data['username'] = username;
      }
      final response = await _apiClient.post(
        AppConfig.authSendVerificationCode,
        data: data,
      );
      return VerificationCodeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Проверка кода верификации email
  ///
  /// После успешной проверки устанавливается флаг в сессии
  Future<VerifyCodeResponse> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authVerifyEmailCode,
        data: {
          'email': email,
          'code': code,
        },
      );
      return VerifyCodeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Обновление токена
  Future<bool> refreshToken() async {
    try {
      final newToken = await _apiClient.refreshToken();
      return newToken != null;
    } catch (_) {
      return false;
    }
  }

  /// Проверка авторизации
  Future<bool> isAuthenticated() async {
    return await _tokenStorage.isAuthenticated();
  }

  /// Получение текущего пользователя
  Future<UserModel?> getCurrentUser() async {
    final userData = await _tokenStorage.getUserData();
    if (userData == null) return null;

    try {
      return UserModel.fromJson(userData);
    } catch (_) {
      return null;
    }
  }

  /// Выход из системы
  Future<void> logout() async {
    await _tokenStorage.clearActiveSession();
    _apiClient.clearAuth();
  }

  /// Сохранение данных авторизации
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _tokenStorage.saveAccountSession(
      userData: authResponse.user.toJson(),
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      deviceGrant: authResponse.deviceGrant,
    );
  }

  /// Обработка ошибок Dio
  ApiError _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutError();

      case DioExceptionType.connectionError:
        return const NetworkError();

      case DioExceptionType.cancel:
        return const CancelError();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        // Rate limit
        if (statusCode == 429) {
          final retryAfter = e.response?.headers.value('Retry-After');
          return RateLimitError(
            retryAfter: retryAfter != null
                ? Duration(seconds: int.parse(retryAfter))
                : null,
          );
        }

        // Парсим ошибку из ответа
        if (data is Map<String, dynamic>) {
          return ApiError.fromJson(data, statusCode: statusCode);
        }

        return ApiError(
          message: 'Ошибка сервера',
          statusCode: statusCode,
        );

      default:
        return ApiError(message: e.message ?? 'Неизвестная ошибка');
    }
  }

  // ==================== Недавние аккаунты ====================

  /// Быстрый вход в аккаунт
  ///
  /// Проверяет, входил ли пользователь с этого устройства ранее.
  /// Если да - позволяет войти без пароля.
  ///
  /// Параметры:
  /// - userId: ID пользователя для быстрого входа
  /// - tfaCode: код 2FA (если включен)
  ///
  /// Возвращает QuickLoginResponse:
  /// - success: true если вход успешен
  /// - requiresTfa: true если требуется код 2FA
  /// - userInfo: данные пользователя
  Future<QuickLoginResponse> quickLogin({
    required String accountKey,
    String? tfaCode,
    String? challengeId,
  }) async {
    try {
      final deviceGrant = await _tokenStorage.getDeviceGrant(accountKey);
      if (deviceGrant == null || deviceGrant.isEmpty) {
        throw const ApiError(
          message: 'Сохранённый вход недействителен или истёк',
          code: 'INVALID_DEVICE_GRANT',
        );
      }
      final data = <String, dynamic>{
        'device_grant': deviceGrant,
        if (tfaCode != null) 'tfa_code': tfaCode,
        if (challengeId != null) 'challenge_id': challengeId,
      };

      final response = await _apiClient.post(
        AppConfig.authQuickLogin,
        data: data,
      );

      final quickLoginResponse = QuickLoginResponse.fromJson(response.data);

      if (quickLoginResponse.success) {
        final user = quickLoginResponse.userInfo;
        final access = quickLoginResponse.accessToken;
        final refresh = quickLoginResponse.refreshToken;
        final replacementGrant = quickLoginResponse.deviceGrant;
        if (user?.id == null ||
            access == null ||
            refresh == null ||
            replacementGrant == null) {
          throw const ApiError(
            message: 'Сервер не вернул полную сессию быстрого входа',
          );
        }
        await _tokenStorage.saveAccountSession(
          userData: {
            'id': quickLoginResponse.userInfo!.id,
            'username': quickLoginResponse.userInfo!.username,
            'email': quickLoginResponse.userInfo!.email,
            'first_name': quickLoginResponse.userInfo!.firstName,
            'is_verified': quickLoginResponse.userInfo!.isVerified,
            'tfa_enabled': quickLoginResponse.userInfo!.tfaEnabled,
            'has_avatar': quickLoginResponse.userInfo!.hasAvatar,
            if (quickLoginResponse.userInfo!.avatarUrl != null)
              'avatar': quickLoginResponse.userInfo!.avatarUrl,
          },
          accessToken: access,
          refreshToken: refresh,
          deviceGrant: replacementGrant,
        );
      }

      return quickLoginResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> removeSavedAccount(String accountKey) async {
    final grant = await _tokenStorage.getDeviceGrant(accountKey);
    if (grant != null && grant.isNotEmpty) {
      try {
        await _apiClient.post(
          AppConfig.authRevokeDeviceGrant,
          data: {'device_grant': grant},
        );
      } catch (error) {
        debugPrint('Could not revoke saved account grant: $error');
        rethrow;
      }
    }
    await _tokenStorage.removeAccount(accountKey);
  }

  /// Регистрация FCM пуш-токена на бэкенде
  Future<void> registerFcmToken(String token) async {
    try {
      await _apiClient.post(
        '/api/notifications/register-token/',
        data: {
          'token': token,
          'device_id': _apiClient.deviceId,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
        },
      );
      debugPrint('FCM: Token registered with backend successfully.');
    } on DioException catch (e) {
      debugPrint('FCM: Error registering token with backend: ${e.type}');
    } catch (e) {
      debugPrint('FCM: Unexpected token registration error: ${e.runtimeType}');
    }
  }

  /// Обновляет видимое создающему клиенту состояние сканирования QR-кода.
  Future<bool> updateQrScanState({
    required String token,
    required String action,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authQrScan,
        data: {'token': token, 'action': action},
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      debugPrint('QR scan state error: ${e.error ?? e.message}');
      return false;
    }
  }

  /// Подтверждение входа по QR-коду
  Future<bool> approveQrLogin({
    required String token,
    required bool confirmed,
    Map<String, dynamic>? transferPayload,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authQrApprove,
        data: {
          'token': token,
          'confirmed': confirmed,
          'transfer_payload': transferPayload,
        },
      );
      return response.data['status'] == 'ok';
    } on DioException catch (e) {
      debugPrint('QR Approve DioException: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('QR Approve unexpected error: $e');
      return false;
    }
  }
}
