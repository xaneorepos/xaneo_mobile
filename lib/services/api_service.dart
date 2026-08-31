import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_service.dart';
import 'logger_service.dart';
import '../config/app_config.dart';
import '../utils/ssl_helper.dart';

/// API сервис для Xaneo с поддержкой автоматического сохранения сессионных кук (через Dio)
class ApiService {
  // Базовый URL сервера (из AppConfig)
  static String _baseUrl = AppConfig.apiBaseUrl;

  // User-Agent для идентификации приложения
  static String get _userAgent => AppConfig.userAgent;

  // Ключи для хранения токенов
  static const String _accessTokenKey = 'xaneo_access_token';
  static const String _refreshTokenKey = 'xaneo_refresh_token';

  // Future для предотвращения одновременных запросов на обновление токена
  Future<ApiResponse>? _refreshFuture;

  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // Dio instance
  late final Dio _dio;

  // CookieJar instance
  final CookieJar _cookieJar = CookieJar();

  // Геттер для базового URL
  static String get baseUrl => _baseUrl;

  /// Публичный доступ к Dio для использования в виджетах
  Dio get dio => _dio;

  /// Установить базовый URL (для настройки)
  static void setBaseUrl(String url) {
    _baseUrl = url.replaceAll(RegExp(r'/$'), '');
    _instance._dio.options.baseUrl = _baseUrl;
  }

  /// Получить WebSocket URL для чата
  static String getWebSocketUrl(String chatId, String? token) {
    final uri = Uri.parse(_baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final host = uri.host;
    final port = uri.hasPort ? ':${uri.port}' : '';

    var wsUrl = '$scheme://$host$port/ws/chat/$chatId/';
    if (token != null) {
      wsUrl += '?token=${Uri.encodeComponent(token)}';
    }
    return wsUrl;
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      validateStatus: (status) => status != null && status < 600,
    ));

    _dio.interceptors.add(CookieManager(_cookieJar));

    // Автоматическое добавление авторизации и обновление токенов при получении 401
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;
        if (!options.headers.containsKey('Authorization') &&
            !path.contains('/auth/token/refresh/') &&
            !path.contains('/auth/login/') &&
            !path.contains('/auth/register/')) {
          final token = await getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        if (response.statusCode == 401) {
          final path = response.requestOptions.path;
          // Избегаем бесконечных циклов на эндпоинтах авторизации и обновления токена
          if (path.contains('/auth/token/refresh/') ||
              path.contains('/auth/login/') ||
              path.contains('/auth/token/')) {
            return handler.next(response);
          }

          // Если запрос уже был ретраем — не повторяем, чтобы не зациклиться
          if (response.requestOptions.extra['_retried'] == true) {
            return handler.next(response);
          }

          final authHeader =
              response.requestOptions.headers['Authorization'] as String?;
          if (authHeader != null && authHeader.startsWith('Bearer ')) {
            final requestToken = authHeader.substring(7);
            final currentToken = await getAccessToken();

            if (currentToken != null && requestToken != currentToken) {
              // Токен запроса отличается от текущего — просто повторяем с новым токеном
              final options = response.requestOptions;
              options.headers['Authorization'] = 'Bearer $currentToken';
              options.extra['_retried'] = true;
              try {
                final retryResponse = await _dio.fetch(options);
                return handler.resolve(retryResponse);
              } catch (e) {
                Logger.warning(
                    'ApiService', 'Error retrying with refreshed token: $e');
              }
              return handler.next(response);
            }
          }

          // Рефреш токена
          final refreshRes = await refreshToken();
          if (!refreshRes.success) {
            // Рефреш упал (429, сеть и т.д.) — прекращаем, не повторяем запрос
            Logger.warning('ApiService',
                'Token refresh failed, aborting retry: ${refreshRes.error}');
            return handler.next(response);
          }

          final newToken = await getAccessToken();
          if (newToken != null) {
            final options = response.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            options.extra['_retried'] = true;
            try {
              final retryResponse = await _dio.fetch(options);
              return handler.resolve(retryResponse);
            } catch (e) {
              Logger.warning('ApiService',
                  'Error retrying request after token refresh: $e');
            }
          }
        }
        return handler.next(response);
      },
    ));

    // TEMPORARY: allow the configured private development backend in release
    // builds too. The callback still rejects every public host.
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        if (AppConfig.allowInsecurePrivateCertificates) {
          client.badCertificateCallback = allowConfiguredDevelopmentCertificate;
        }
        return client;
      },
    );
  }

  /// Получить Options с базовыми заголовками
  Options _getOptions(
      {String? contentType, Map<String, dynamic>? extraHeaders}) {
    final headers = <String, dynamic>{
      'User-Agent': _userAgent,
      'X-Platform':
          Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown'),
      'X-App-Version': AppConfig.appVersion,
      'Accept': 'application/json',
      ...?extraHeaders,
    };
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    return Options(headers: headers);
  }

  /// Получить Options с авторизацией
  Future<Options> _getAuthOptions() async {
    final token = await getAccessToken();
    final extraHeaders = <String, dynamic>{};
    if (token != null) {
      extraHeaders['Authorization'] = 'Bearer $token';
    }
    return _getOptions(
      contentType: 'application/json',
      extraHeaders: extraHeaders,
    );
  }

  // ==================== АВТОРИЗАЦИЯ ====================

  /// Вход в систему
  /// Возвращает Map с данными пользователя или ошибкой
  Future<ApiResponse> login(String username, String password) async {
    Logger.info('ApiService', 'Attempting login for user: $username');
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login/',
        options: _getOptions(contentType: 'application/json'),
        data: {
          'username': username,
          'password': password,
        },
      );

      final result = _handleDioResponse(response, isAuthRequest: true);
      Logger.info('ApiService',
          'Login result for $username: success=${result.success}');
      return result;
    } catch (e) {
      Logger.error(
          'ApiService', 'Login connection error for user: $username', e);
      return ApiResponse(
        success: false,
        error: 'Ошибка подключения к серверу: $e',
      );
    }
  }

  // ==================== РЕГИСТРАЦИЯ С ПОДТВЕРЖДЕНИЕМ EMAIL ====================

  /// Проверить доступность имени пользователя (username)
  Future<ApiResponse> checkUsername(String username) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/auth/check-username/',
        queryParameters: {'username': username},
        options: _getOptions(),
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка проверки имени пользователя: $e',
      );
    }
  }

  /// Проверить доступность email
  Future<ApiResponse> checkEmail(String email) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/auth/check-email/',
        queryParameters: {'email': email},
        options: _getOptions(),
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка проверки email: $e',
      );
    }
  }

  /// Отправить код подтверждения на email
  /// Возвращает ApiResponse с success: true если код отправлен
  Future<ApiResponse> sendVerificationCode({
    required String email,
    required String username,
  }) async {
    try {
      final urlStr = '$_baseUrl/auth/send-verification-code/';
      final data = {
        'email': email,
        'username': username,
      };
      final options = _getOptions(contentType: 'application/json');

      print('DEBUG API: POST to $urlStr');
      print('DEBUG API: Request Body: $data');
      print('DEBUG API: Request Headers: ${options.headers}');
      final cookiesBefore = await _cookieJar.loadForRequest(Uri.parse(urlStr));
      print('DEBUG API: Cookies before request: $cookiesBefore');

      final response = await _dio.post(
        urlStr,
        options: options,
        data: data,
      );

      print('DEBUG API: Response Code: ${response.statusCode}');
      print('DEBUG API: Response Headers: ${response.headers}');
      print('DEBUG API: Response Body: ${response.data}');
      final cookiesAfter = await _cookieJar.loadForRequest(Uri.parse(urlStr));
      print('DEBUG API: Cookies after request: $cookiesAfter');

      return _handleDioResponse(response);
    } catch (e) {
      print('DEBUG API: Error in sendVerificationCode: $e');
      return ApiResponse(
        success: false,
        error: 'Ошибка отправки кода: $e',
      );
    }
  }

  /// Проверить код подтверждения email
  /// Возвращает ApiResponse с success: true если код верный
  Future<ApiResponse> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final urlStr = '$_baseUrl/auth/verify-email-code/';
      final data = {
        'email': email,
        'code': code,
      };
      final options = _getOptions(contentType: 'application/json');

      print('DEBUG API: POST to $urlStr');
      print('DEBUG API: Request Body: $data');
      print('DEBUG API: Request Headers: ${options.headers}');
      final cookiesBefore = await _cookieJar.loadForRequest(Uri.parse(urlStr));
      print('DEBUG API: Cookies before request: $cookiesBefore');

      final response = await _dio.post(
        urlStr,
        options: options,
        data: data,
      );

      print('DEBUG API: Response Code: ${response.statusCode}');
      print('DEBUG API: Response Headers: ${response.headers}');
      print('DEBUG API: Response Body: ${response.data}');
      final cookiesAfter = await _cookieJar.loadForRequest(Uri.parse(urlStr));
      print('DEBUG API: Cookies after request: $cookiesAfter');

      return _handleDioResponse(response);
    } catch (e) {
      print('DEBUG API: Error in verifyEmailCode: $e');
      return ApiResponse(
        success: false,
        error: 'Ошибка проверки кода: $e',
      );
    }
  }

  /// Регистрация нового пользователя (после подтверждения email)
  /// Требует, что email был подтверждён через verifyEmailCode
  Future<ApiResponse> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String birthDate,
    String? firstName,
  }) async {
    try {
      final urlStr = '$_baseUrl/auth/register/';
      final data = {
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'birth_date': birthDate,
        'email_verified': true, // Обязательно true после подтверждения кода
        if (firstName != null) 'realname': firstName,
      };
      final options = _getOptions(contentType: 'application/json');

      print('DEBUG API: POST to $urlStr');
      print('DEBUG API: Request Body: $data');
      print('DEBUG API: Request Headers: ${options.headers}');
      final cookiesBefore = await _cookieJar.loadForRequest(Uri.parse(urlStr));
      print('DEBUG API: Cookies before request: $cookiesBefore');

      final response = await _dio.post(
        urlStr,
        options: options,
        data: data,
      );

      print('DEBUG API: Response Code: ${response.statusCode}');
      print('DEBUG API: Response Headers: ${response.headers}');
      print('DEBUG API: Response Body: ${response.data}');
      final cookiesAfter = await _cookieJar.loadForRequest(Uri.parse(urlStr));
      print('DEBUG API: Cookies after request: $cookiesAfter');

      final result = _handleDioResponse(response, isAuthRequest: true);

      // Сохраняем токены при успешной регистрации
      if (result.success && result.data != null) {
        if (result.data!['access'] != null) {
          await saveAccessToken(result.data!['access'] as String);
        }
        if (result.data!['refresh'] != null) {
          await saveRefreshToken(result.data!['refresh'] as String);
        }
      }

      return result;
    } catch (e) {
      print('DEBUG API: Error in register: $e');
      return ApiResponse(
        success: false,
        error: 'Ошибка регистрации: $e',
      );
    }
  }

  /// Получение JWT токена
  Future<ApiResponse> obtainToken(String username, String password) async {
    Logger.info('ApiService', 'obtainToken called for user: $username');
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/token/',
        options: _getOptions(contentType: 'application/json'),
        data: {
          'username': username,
          'password': password,
        },
      );

      final result = _handleDioResponse(response);

      // Сохраняем токены
      if (result.success && result.data != null) {
        Logger.info('ApiService', 'obtainToken succeeded. Saving tokens.');
        if (result.data!['access'] != null) {
          await saveAccessToken(result.data!['access'] as String);
        }
        if (result.data!['refresh'] != null) {
          await saveRefreshToken(result.data!['refresh'] as String);
        }
      } else {
        Logger.warning('ApiService', 'obtainToken failed: ${result.error}');
      }

      return result;
    } catch (e) {
      Logger.error(
          'ApiService', 'obtainToken connection error for user: $username', e);
      return ApiResponse(
        success: false,
        error: 'Ошибка получения токена: $e',
      );
    }
  }

  /// Обновление access токена
  Future<ApiResponse> refreshToken() async {
    Logger.info('ApiService', 'Starting token refresh process...');
    if (_refreshFuture != null) {
      Logger.info(
          'ApiService', 'Token refresh already in progress, sharing future.');
      return _refreshFuture!;
    }

    final completer = Completer<ApiResponse>();
    _refreshFuture = completer.future;

    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        Logger.warning(
            'ApiService', 'Refresh token not found in local storage.');
        final res = ApiResponse(
          success: false,
          error: 'Refresh токен не найден',
        );
        completer.complete(res);
        return res;
      }

      final response = await _dio.post(
        '$_baseUrl/auth/token/refresh/',
        options: _getOptions(contentType: 'application/json'),
        data: {
          'refresh': refreshToken,
        },
      );

      final result = _handleDioResponse(response);

      if (result.success && result.data != null) {
        final newAccess = result.data!['access'] as String?;
        final newRefresh = result.data!['refresh'] as String?;

        Logger.info('ApiService',
            'Token refreshed successfully. Updating tokens locally.');
        if (newAccess != null) {
          await saveAccessToken(newAccess);
          if (newRefresh != null) {
            await saveRefreshToken(newRefresh);
          }
          // Синхронизируем новые токены в списке сохраненных аккаунтов
          await AccountService()
              .updateAccessToken(refreshToken, newAccess, newRefresh);
        }
      } else {
        Logger.error(
            'ApiService', 'Token refresh failed on server: ${result.error}');
      }

      completer.complete(result);
      return result;
    } catch (e) {
      Logger.error('ApiService', 'Exception during token refresh', e);
      final res = ApiResponse(
        success: false,
        error: 'Ошибка обновления токена: $e',
      );
      completer.complete(res);
      return res;
    } finally {
      _refreshFuture = null;
    }
  }

  /// Проверка валидности токена
  Future<ApiResponse> verifyToken() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          error: 'Токен не найден',
        );
      }

      final response = await _dio.post(
        '$_baseUrl/auth/token/verify/',
        options: _getOptions(contentType: 'application/json'),
        data: {'token': token},
      );

      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка проверки токена: $e',
      );
    }
  }

  // ==================== XSEC-2 CRYPTO ENDPOINTS ====================

  /// Загрузить публичные ключи и зашифрованный blob на сервер
  Future<ApiResponse> uploadKeys({
    required String x25519PublicKey,
    required String ed25519PublicKey,
    required Map<String, dynamic> encryptedBlob,
    Map<String, dynamic>? recoveryBlob,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '$_baseUrl/xsec2/upload-keys/',
        options: options,
        data: {
          'x25519_public_key': x25519PublicKey,
          'ed25519_public_key': ed25519PublicKey,
          'encrypted_blob': encryptedBlob,
          if (recoveryBlob != null) 'recovery_blob': recoveryBlob,
        },
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка отправки ключей на сервер: $e',
      );
    }
  }

  /// Получить свои зашифрованные ключи с сервера
  Future<ApiResponse> getMyKeys() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_baseUrl/xsec2/my-keys/',
        options: options,
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка получения ключей с сервера: $e',
      );
    }
  }

  /// Получить публичные ключи собеседника по имени пользователя
  Future<ApiResponse> getUserPublicKey(String username) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_baseUrl/xsec2/keys/$username/',
        options: options,
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка получения публичного ключа пользователя: $e',
      );
    }
  }

  /// Получить симметричный ключ чата для групповых чатов / каналов
  Future<ApiResponse> getChatKey(String chatId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_baseUrl/xsec2/keys/chat/$chatId/',
        options: options,
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка получения ключа чата: $e',
      );
    }
  }

  /// Получить токен доступа к LiveKit комнате для WebRTC звонков
  Future<ApiResponse> getLiveKitToken(String roomName) async {
    try {
      final options = await _getAuthOptions();
      final baseUrlWithoutV1 = _baseUrl.replaceAll('/v1', '');
      final response = await _dio.get(
        '$baseUrlWithoutV1/webrtc/livekit-token/',
        queryParameters: {'room': roomName},
        options: options,
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка получения LiveKit токена: $e',
      );
    }
  }

  // ==================== MESSAGING ENDPOINTS ====================

  /// Получить список чатов
  Future<ApiResponse> getChats() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_baseUrl/chats/',
        options: options,
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка получения списка чатов: $e',
      );
    }
  }

  /// Архивировать/разархивировать чат
  Future<ApiResponse> archiveChat(String chatId, bool isArchived) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '$_baseUrl/chats/archive/',
        options: options,
        data: {
          'chat_id': chatId,
          'is_archived': isArchived,
        },
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка архивации чата: $e',
      );
    }
  }

  /// Получить список сообщений в чате
  Future<ApiResponse> getMessages(String chatId,
      {int? limit, int? offset}) async {
    try {
      final options = await _getAuthOptions();
      final queryParams = {
        'chat_id': chatId,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };
      final response = await _dio.get(
        '$_baseUrl/encrypted-messages/',
        options: options,
        queryParameters: queryParams,
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка получения сообщений: $e',
      );
    }
  }

  /// Отправить зашифрованное сообщение
  Future<ApiResponse> sendMessage(String chatId, String encryptedText) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '$_baseUrl/encrypted-messages/',
        options: options,
        data: {
          'chat_id': chatId,
          'encrypted_text': encryptedText,
        },
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка отправки сообщения: $e',
      );
    }
  }

  /// Получить метаданные файла
  Future<ApiResponse> getFileMetadata(String fileId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_baseUrl/files/metadata/$fileId/',
        options: options,
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка получения метаданных файла: $e',
      );
    }
  }

  /// Загрузить файл на сервер
  Future<ApiResponse> uploadFile(File file, String fileType, String chatId,
      {String? description}) async {
    try {
      final options = await _getAuthOptions();
      options.contentType = 'multipart/form-data';

      String fileName = file.path.split('/').last;
      if (Platform.isWindows) {
        fileName = file.path.split('\\').last;
      }

      FormData formData = FormData.fromMap({
        'file_type': fileType,
        'chat_id': chatId,
        if (description != null) 'description': description,
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        '$_baseUrl/files/upload/',
        options: options,
        data: formData,
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка загрузки файла: $e',
      );
    }
  }

  /// Поиск пользователей, групп, каналов
  Future<ApiResponse> searchUsers(String query) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_baseUrl/user/search/',
        options: options,
        queryParameters: {'q': query},
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка поиска: $e',
      );
    }
  }

  /// Очистить все куки сессии
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  /// Выход из системы
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await clearCookies();
  }

  // ==================== ПРОФИЛЬ ====================

  /// Получить профиль пользователя
  Future<ApiResponse> getProfile() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_baseUrl/user/profile/',
        options: options,
      );

      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка получения профиля: $e',
      );
    }
  }

  /// Получить публичный профиль пользователя по ID.
  /// Сервер применяет настройки приватности: birth_date/age приходят null,
  /// если день рождения скрыт; bio может быть пустым.
  Future<ApiResponse> getUserById(int userId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_baseUrl/user/$userId/',
        options: options,
      );

      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка получения профиля пользователя: $e',
      );
    }
  }

  // ==================== ХРАНЕНИЕ ТОКЕНОВ ====================

  /// Сохранить access токен
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  /// Получить access токен
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Сохранить refresh токен
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  /// Получить refresh токен
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Проверить, авторизован ли пользователь
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// Обработка ответа сервера
  ApiResponse _handleDioResponse(Response response,
      {bool isAuthRequest = false}) {
    final statusCode = response.statusCode ?? 500;

    // Пытаемся получить данные
    Map<String, dynamic>? data;
    if (response.data != null) {
      if (response.data is Map) {
        data = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String &&
          (response.data as String).isNotEmpty) {
        try {
          data = jsonDecode(response.data as String) as Map<String, dynamic>;
        } catch (_) {
          // Игнорируем, если не JSON
        }
      }
    }

    // Успешные статусы
    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse(
        success: true,
        data: data,
        statusCode: statusCode,
      );
    }

    // Обработка ошибок
    String errorMessage = 'Неизвестная ошибка';

    if (data != null) {
      // Стандартные ошибки Django REST Framework
      if (data['detail'] != null) {
        errorMessage = data['detail'].toString();
      } else if (data['error'] != null) {
        errorMessage = data['error'].toString();
      } else if (data['message'] != null) {
        errorMessage = data['message'].toString();
      } else if (data['non_field_errors'] != null) {
        errorMessage = (data['non_field_errors'] as List).join(', ');
      } else {
        // Ошибки по полям
        final errors = <String>[];
        data.forEach((key, value) {
          if (value is List) {
            errors.add('$key: ${value.join(', ')}');
          } else {
            errors.add('$key: $value');
          }
        });
        if (errors.isNotEmpty) {
          errorMessage = errors.join('\n');
        }
      }
    }

    // Специфичные ошибки по статусам
    switch (statusCode) {
      case 401:
        if (isAuthRequest) {
          errorMessage = 'Неверные учетные данные';
        } else if (errorMessage == 'Неизвестная ошибка') {
          errorMessage = 'Требуется авторизация (401)';
        }
        break;
      case 403:
        errorMessage = 'Доступ запрещён';
        break;
      case 404:
        errorMessage = 'Ресурс не найден';
        break;
      case 500:
        errorMessage = 'Ошибка сервера';
        break;
    }

    Logger.warning('ApiService',
        'API request failed: ${response.requestOptions.method} ${response.requestOptions.path} -> status $statusCode, error: $errorMessage');

    return ApiResponse(
      success: false,
      error: errorMessage,
      data: data,
      statusCode: statusCode,
    );
  }

  /// Проверка доступности сервера
  Future<bool> checkServerAvailability() async {
    try {
      final response = await _dio
          .get(
            '$_baseUrl/system/info/',
            options: _getOptions(),
          )
          .timeout(const Duration(seconds: 5));

      final available = response.statusCode == 200;
      Logger.info('ApiService', 'Server availability check result: $available');
      return available;
    } catch (e) {
      Logger.warning('ApiService', 'Server availability check failed: $e');
      return false;
    }
  }

  /// Отметить сообщения в чате как прочитанные
  Future<ApiResponse> markMessagesAsRead(String chatId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '$_baseUrl/messages/mark-read/',
        options: options,
        data: {
          'chat_id': chatId,
        },
      );
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка отметки сообщений как прочитанных: $e',
      );
    }
  }

  /// Присоединиться к группе или подписаться на канал
  Future<ApiResponse> joinChat(String chatId) async {
    try {
      final options = await _getAuthOptions();
      Response response;
      if (chatId.startsWith('channel_')) {
        final channelIdStr = chatId.replaceFirst('channel_', '');
        final channelId = int.tryParse(channelIdStr) ?? channelIdStr;
        response = await _dio.post(
          '$_baseUrl/channels/subscribe/',
          options: options,
          data: {
            'channel_id': channelId,
            'action': 'subscribe',
          },
        );
      } else if (chatId.startsWith('group_')) {
        final groupId = chatId.replaceFirst('group_', '');
        response = await _dio.post(
          '$_baseUrl/groups/$groupId/join/',
          options: options,
        );
      } else {
        response = await _dio.post(
          '$_baseUrl/chats/join/',
          options: options,
          data: {'chat_id': chatId},
        );
      }
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка при вступлении/подписке: $e',
      );
    }
  }

  /// Покинуть группу или отписаться от канала
  Future<ApiResponse> leaveChat(String chatId) async {
    try {
      final options = await _getAuthOptions();
      Response response;
      if (chatId.startsWith('channel_')) {
        final channelIdStr = chatId.replaceFirst('channel_', '');
        final channelId = int.tryParse(channelIdStr) ?? channelIdStr;
        response = await _dio.post(
          '$_baseUrl/channels/subscribe/',
          options: options,
          data: {
            'channel_id': channelId,
            'action': 'unsubscribe',
          },
        );
      } else if (chatId.startsWith('group_')) {
        final groupId = chatId.replaceFirst('group_', '');
        response = await _dio.post(
          '$_baseUrl/groups/$groupId/leave/',
          options: options,
        );
      } else {
        response = await _dio.post(
          '$_baseUrl/chats/leave/',
          options: options,
          data: {'chat_id': chatId},
        );
      }
      return _handleDioResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Ошибка при выходе/отписке: $e',
      );
    }
  }
}

/// Результат API запроса
class ApiResponse {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  @override
  String toString() {
    if (success) {
      return 'ApiResponse(success: true, data: $data)';
    }
    return 'ApiResponse(success: false, error: $error, statusCode: $statusCode)';
  }
}
