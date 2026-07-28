import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/playback_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/tfa_screen.dart';
import 'screens/main/main_screen.dart';
import 'services/api/api_client.dart';
import 'services/auth/token_storage.dart';
import 'services/auth/recent_accounts_service.dart';
import 'services/crypto/crypto_service.dart';
import 'services/crypto/xsec2_service.dart';
import 'styles/app_styles.dart';

import 'package:path_provider/path_provider.dart';
import 'services/database/database_key_service.dart';

import 'services/database/app_database.dart';
import 'services/chat/chat_local_repository.dart';
import 'services/chat/presence_service.dart';
import 'services/webrtc/webrtc_signaling_service.dart';
import 'services/grpc_service.dart';
import 'services/webrtc/call_manager.dart';
import 'services/notifications/notification_service.dart';
import 'utils/local_proxy.dart';

import 'dart:io';

import 'package:logging/logging.dart' as dart_logging;
import 'package:livekit_client/livekit_client.dart';

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Проверяем первый запуск приложения после установки/очистки данных
  final prefs = await SharedPreferences.getInstance();
  final hasRunBefore = prefs.getBool('has_run_before') ?? false;
  if (!hasRunBefore) {
    debugPrint('First run detected (or app data was cleared). Clearing secure storage...');
    final tokenStorage = TokenStorage();
    await tokenStorage.clearAll();
    
    // Сбрасываем ID устройства, чтобы сгенерировать новый fingerprint на сервере
    await prefs.remove('xaneo_device_id');
    
    final recentAccountsService = RecentAccountsService(
      apiClient: ApiClient(tokenStorage: tokenStorage, deviceId: ''),
    );
    await recentAccountsService.clearLocalAccounts();
    
    await prefs.setBool('has_run_before', true);
  }

  // Получаем или генерируем уникальный ID устройства
  String? deviceId = prefs.getString('xaneo_device_id');
  if (deviceId == null || deviceId.isEmpty) {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    deviceId = base64UrlEncode(values).replaceAll('=', '');
    await prefs.setString('xaneo_device_id', deviceId);
  }

  // Инициализируем пуш-уведомления
  await NotificationService().initialize();
  
  // Включаем подробное логирование для LiveKit в режиме отладки
  if (kDebugMode) {
    dart_logging.Logger.root.level = dart_logging.Level.ALL;
    dart_logging.Logger.root.onRecord.listen((record) {
      print('[LiveKit] ${record.level.name}: ${record.time}: ${record.message}');
    });
  }
  
  HttpOverrides.global = _DevHttpOverrides();
  LocalProxy.start();
  
  // Получаем путь к документам и ключ шифрования БД один раз при запуске
  final dbFolder = await getApplicationDocumentsDirectory();
  final dbKey = await DatabaseKeyService().getEncryptionKey();
  
  // Устанавливаем чёрный статус-бар
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(XaneoApp(dbFolder: dbFolder, dbKey: dbKey, deviceId: deviceId));
}

/// Точка входа в приложение Xaneo
class XaneoApp extends StatelessWidget {
  final Directory dbFolder;
  final String dbKey;
  final String deviceId;
  final LocalChatRepository? localChatRepoOverride;
  
  const XaneoApp({
    super.key,
    required this.dbFolder,
    required this.dbKey,
    required this.deviceId,
    this.localChatRepoOverride,
  });

  @override
  Widget build(BuildContext context) {
    // Создаём ApiClient один раз для всего приложения
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage: tokenStorage, deviceId: deviceId);

    // Создаём CryptoService для E2E шифрования (XSEC-2)
    final cryptoService = CryptoService(
      apiClient: apiClient,
    );
    
    // Создаём Xsec2Service для работы с ключами
    final xsec2Service = Xsec2Service(
      apiClient: apiClient,
      cryptoService: cryptoService,
    );

    // Инициализируем gRPC сервис
    XaneoGrpcService().init(
      host: AppConfig.grpcHost,
      chatPort: AppConfig.grpcChatPort,
      presencePort: AppConfig.grpcPresencePort,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlaybackProvider>(create: (_) => PlaybackProvider()),
        // ApiClient для всех экранов
        Provider<ApiClient>.value(value: apiClient),
        // CryptoService для расшифровки сообщений
        Provider<CryptoService>.value(value: cryptoService),
        // Xsec2Service для работы с ключами
        Provider<Xsec2Service>.value(value: xsec2Service),
        // AuthProvider для авторизации
        ChangeNotifierProvider<AuthProvider>(
          create: (context) {
            final apiClient = context.read<ApiClient>();
            final cryptoService = context.read<CryptoService>();
            final authProvider = AuthProviderFactory.createWithCryptoService(apiClient, cryptoService);
            
            // Register callback to log out the user on session expiry
            apiClient.onSessionExpired = () {
              authProvider.logout();
            };

            // Инициализируем авторизацию с CryptoService для XSEC-2
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authProvider.checkAuthStatus(cryptoService: cryptoService);
            });
            return authProvider;
          },
        ),
        // Локальная зашифрованная БД чатов с разделением по пользователям (поддержка override для тестов)
        localChatRepoOverride != null
            ? Provider<LocalChatRepository>.value(value: localChatRepoOverride!)
            : ProxyProvider<AuthProvider, LocalChatRepository>(
                update: (context, auth, previousRepo) {
                  final currentUserId = auth.user?.id.toString();
                  if (previousRepo != null && previousRepo.userId == currentUserId) {
                    return previousRepo;
                  }
                  
                  final db = AppDatabase.createForUser(
                    dbFolder: dbFolder,
                    dbKey: dbKey,
                    userId: currentUserId,
                  );
                  return LocalChatRepository(db, userId: currentUserId);
                },
                dispose: (context, repo) {
                  repo.dispose();
                },
              ),
        // PresenceService для фонового и глобального отслеживания активности (в сети / не в сети)
        Provider<PresenceService>(
          lazy: false,
          create: (context) {
            final authProvider = context.read<AuthProvider>();
            final apiClient = context.read<ApiClient>();
            final presenceService = PresenceService(
              authProvider: authProvider,
              apiClient: apiClient,
            );
            presenceService.init();
            return presenceService;
          },
          dispose: (context, service) => service.dispose(),
        ),
        Provider<WebRTCSignalingService>(
          create: (context) {
            final apiClient = context.read<ApiClient>();
            return WebRTCSignalingService(apiClient: apiClient);
          },
          dispose: (context, service) => service.dispose(),
        ),
        ChangeNotifierProvider<CallManager>(
          lazy: false,
          create: (context) {
            final apiClient = context.read<ApiClient>();
            final signalingService = context.read<WebRTCSignalingService>();
            final authProvider = context.read<AuthProvider>();
            final manager = CallManager(
              apiClient: apiClient,
              signalingService: signalingService,
            );
            authProvider.addListener(() {
              if (authProvider.isAuthenticated && authProvider.user != null) {
                signalingService.connect(authProvider.user!.id.toString());
              } else {
                signalingService.disconnect();
              }
            });
            if (authProvider.isAuthenticated && authProvider.user != null) {
              signalingService.connect(authProvider.user!.id.toString());
            }
            return manager;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Xaneo',
        navigatorKey: NotificationService.navigatorKey,
        debugShowCheckedModeBanner: false,
        
        // Чёрно-белая тема
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppStyles.backgroundColor,
          fontFamily: AppStyles.fontFamily,
          
          textTheme: const TextTheme(
            displayLarge: TextStyle(letterSpacing: -0.8),
            displayMedium: TextStyle(letterSpacing: -0.6),
            displaySmall: TextStyle(letterSpacing: -0.5),
            headlineLarge: TextStyle(letterSpacing: -0.6),
            headlineMedium: TextStyle(letterSpacing: -0.5),
            headlineSmall: TextStyle(letterSpacing: -0.4),
            titleLarge: TextStyle(letterSpacing: -0.5),
            titleMedium: TextStyle(letterSpacing: -0.4),
            titleSmall: TextStyle(letterSpacing: -0.3),
            bodyLarge: TextStyle(letterSpacing: -0.3),
            bodyMedium: TextStyle(letterSpacing: -0.3),
            bodySmall: TextStyle(letterSpacing: -0.3),
            labelLarge: TextStyle(letterSpacing: -0.3),
            labelMedium: TextStyle(letterSpacing: -0.3),
            labelSmall: TextStyle(letterSpacing: -0.3),
          ),

          colorScheme: const ColorScheme.dark(
            primary: AppStyles.textPrimaryColor,
            secondary: AppStyles.textSecondaryColor,
            surface: AppStyles.backgroundColor,
            error: AppStyles.errorColor,
          ),
          
          appBarTheme: const AppBarTheme(
            backgroundColor: AppStyles.backgroundColor,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: AppStyles.textPrimaryColor),
            titleTextStyle: TextStyle(
              color: AppStyles.textPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
          
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppStyles.inputBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppStyles.borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppStyles.borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppStyles.borderActiveColor, width: 1),
            ),
            hintStyle: AppStyles.inputHint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: AppStyles.primaryButton,
          ),
          
          textButtonTheme: TextButtonThemeData(
            style: AppStyles.textButton,
          ),
          
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: AppStyles.secondaryButton,
          ),
          
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: AppStyles.backgroundColor,
            indicatorColor: AppStyles.inputBackgroundColor,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppStyles.inputText.copyWith(
                  color: AppStyles.textPrimaryColor,
                  fontSize: 12,
                );
              }
              return AppStyles.inputText.copyWith(
                color: AppStyles.textMutedColor,
                fontSize: 12,
              );
            }),
          ),
          
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        
        // Начальный экран
        home: const AuthWrapper(),
        
        // Роуты
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/tfa': (_) => const TfaScreen(),
          '/main': (_) => const MainScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenOnboarding == null) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.status == AuthStatus.checking) {
          return const SplashScreen();
        }
        
        if (auth.status == AuthStatus.authenticated) {
          return const MainScreen();
        }
        
        if (auth.status == AuthStatus.tfaRequired) {
          return const TfaScreen();
        }
        
        if (_hasSeenOnboarding == false) {
          return const OnboardingScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}

/// Загрузочный экран
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Логотип
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppStyles.textPrimaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.solidComment,
                  size: 44,
                  color: AppStyles.backgroundColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Название
            const Text(
              'Xaneo',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppStyles.textPrimaryColor,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 48),
            
            // Индикатор загрузки
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppStyles.textPrimaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
