import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/custom_text_form_field.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/scale_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/geometry_3d.dart';
import '../widgets/advanced_background.dart';
import '../services/api_service.dart';
import '../services/crypto_service.dart';
import '../services/account_service.dart';
import '../services/logger_service.dart';
import '../widgets/settings_modal.dart';
import '../widgets/custom_toast.dart';
import 'register_screen.dart';

/// Экран входа в систему с продвинутыми 3D эффектами
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
  with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasAccounts = false;
  int _currentStep = 0; // 0: login/username, 1: password

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FocusNode _loginFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkAccounts();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _loginFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // API сервис
  final _apiService = ApiService();

  Future<void> _checkAccounts() async {
    final accounts = await AccountService().getAccounts();
    if (mounted) {
      setState(() {
        _hasAccounts = accounts.isNotEmpty;
      });
    }
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep = 1;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _passwordFocus.requestFocus();
      });
    }
  }

  Future<void> _handleLogin() async {
    final username = _loginController.text.trim();
    Logger.info('LoginScreen', 'Login attempt started for user: $username');
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final password = _passwordController.text;
        
        // Получаем JWT токен
        Logger.info('LoginScreen', 'Requesting JWT token for user: $username');
        final tokenResponse = await _apiService.obtainToken(username, password);

        if (tokenResponse.success) {
          Logger.info('LoginScreen', 'Token obtained successfully. Fetching E2EE keys from server.');
          // Токен получен успешно, теперь настраиваем крипто-ключи (E2EE)
          final keysResponse = await _apiService.getMyKeys();
          bool cryptoSetupSuccess = false;

          if (keysResponse.success && keysResponse.data != null && keysResponse.data!['xsec2'] != null) {
            // Ключи есть на сервере, расшифровываем их
            Logger.info('LoginScreen', 'Keys found on server. Attempting to unlock/decrypt key bundle.');
            final xsec2 = keysResponse.data!['xsec2'] as Map<String, dynamic>;
            final encryptedBlob = xsec2['encrypted_blob'] as Map<String, dynamic>;
            
            cryptoSetupSuccess = await CryptoService().unlockFromBlob(encryptedBlob, password);
            Logger.info('LoginScreen', 'Key bundle decryption result: $cryptoSetupSuccess');

            if (!cryptoSetupSuccess) {
              // В случае неудачи (например, старый Argon2id blob с веб-клиента),
              // генерируем новые ключи в поддерживаемом формате pbkdf2-aes-gcm и загружаем их.
              Logger.warning('LoginScreen', 'Failed to decrypt server keys. Regenerating new keys under pbkdf2-aes-gcm...');
              try {
                final newBlob = await CryptoService().generateAndStoreKeys(password);
                final uploadResponse = await _apiService.uploadKeys(
                  x25519PublicKey: newBlob['pub']['x25519'] as String,
                  ed25519PublicKey: newBlob['pub']['ed25519'] as String,
                  encryptedBlob: newBlob,
                );
                cryptoSetupSuccess = uploadResponse.success;
                Logger.info('LoginScreen', 'Fallback key regeneration and upload success status: $cryptoSetupSuccess');
                if (!cryptoSetupSuccess) {
                  Logger.error('LoginScreen', 'Failed to upload regenerated keys: ${uploadResponse.error}');
                  if (mounted) {
                    CustomToast.show(
                      context,
                      uploadResponse.error ?? (AppLocalizations.of(context)?.oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b ?? 'Fallback'),
                      type: ToastType.error,
                    );
                  }
                }
              } catch (e) {
                Logger.error('LoginScreen', 'Error during fallback key generation', e);
                if (mounted) {
                  CustomToast.show(
                    context,
                    (AppLocalizations.of(context)?.kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7 ?? 'Fallback'),
                    type: ToastType.error,
                  );
                }
              }
            }
          } else if (keysResponse.statusCode == 404 || (keysResponse.data != null && keysResponse.data!['code'] == 'KEYS_NOT_FOUND')) {
            // Ключей нет на сервере, генерируем новые
            Logger.info('LoginScreen', 'Keys not found on server (404/KEYS_NOT_FOUND). Generating new keys.');
            try {
              final newBlob = await CryptoService().generateAndStoreKeys(password);
              final uploadResponse = await _apiService.uploadKeys(
                x25519PublicKey: newBlob['pub']['x25519'] as String,
                ed25519PublicKey: newBlob['pub']['ed25519'] as String,
                encryptedBlob: newBlob,
              );
              
              cryptoSetupSuccess = uploadResponse.success;
              Logger.info('LoginScreen', 'New key generation and upload success status: $cryptoSetupSuccess');
              if (!cryptoSetupSuccess) {
                Logger.error('LoginScreen', 'Failed to upload new keys: ${uploadResponse.error}');
                if (mounted) {
                  CustomToast.show(
                    context,
                    uploadResponse.error ?? (AppLocalizations.of(context)?.oshibkaZagruzkiKlyucheyNaServer_ff9b ?? 'Fallback'),
                    type: ToastType.error,
                  );
                }
              }
            } catch (e) {
              Logger.error('LoginScreen', 'Error generating and uploading new keys', e);
            }
          } else {
            // Другая ошибка при получении ключей
            Logger.error('LoginScreen', 'Failed to fetch keys from server: ${keysResponse.error} (status ${keysResponse.statusCode})');
            if (mounted) {
              CustomToast.show(
                context,
                keysResponse.error ?? (AppLocalizations.of(context)?.oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4 ?? 'Fallback'),
                type: ToastType.error,
              );
            }
          }

          setState(() {
            _isLoading = false;
          });

          if (cryptoSetupSuccess) {
            Logger.info('LoginScreen', 'Crypto keys successfully configured. Fetching user profile...');
            final profileRes = await _apiService.getProfile();
            bool savedSuccess = false;
            if (profileRes.success && profileRes.data != null) {
              Logger.info('LoginScreen', 'Profile fetched successfully. Saving current account: ${profileRes.data!['username']}');
              savedSuccess = await AccountService().saveCurrentAccount(profileRes.data!);
            } else {
              Logger.error('LoginScreen', 'Failed to fetch user profile: ${profileRes.error}');
            }
            
            if (!savedSuccess) {
              Logger.error('LoginScreen', 'Failed to save account locally. Exceeded account limit or save error.');
              await _apiService.logout();
              await CryptoService().clearKeys();
              if (mounted) {
                CustomToast.show(
                  context,
                  (AppLocalizations.of(context)?.prevyshenLimitV5Akkauntov_a6a9 ?? 'Fallback'),
                  type: ToastType.error,
                );
              }
              setState(() {
                _isLoading = false;
              });
              return;
            }

            if (mounted) {
              Logger.info('LoginScreen', 'Login flow completed successfully. Navigating to messenger.');
              final l10n = AppLocalizations.of(context);
              if (l10n != null) {
                CustomToast.show(
                  context,
                  l10n.welcomeUser(_loginController.text),
                  type: ToastType.success,
                );
              }
              // Навигация в мессенджер
              Navigator.of(context).pushReplacementNamed('/messenger');
            }
          }
        } else {
          Logger.warning('LoginScreen', 'Token obtain failed: ${tokenResponse.error} (status ${tokenResponse.statusCode})');
          setState(() {
            _isLoading = false;
          });
          // Ошибка авторизации
          if (mounted) {
            CustomToast.show(
              context,
              tokenResponse.error ?? (AppLocalizations.of(context)?.oshibkaAvtorizatsii_9f5c ?? 'Fallback'),
              type: ToastType.error,
            );
          }
        }
      } catch (e, stack) {
        Logger.error('LoginScreen', 'Unexpected error during login process', e, stack);
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          CustomToast.show(
            context,
            (AppLocalizations.of(context)?.oshibkaPodklyucheniyaKServeru_8b96 ?? 'Fallback'),
            type: ToastType.error,
          );
        }
      }
    } else {
      Logger.warning('LoginScreen', 'Form validation failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final showRightPanel = screenWidth > 750;
    final canGoBack = Navigator.of(context).canPop() || _hasAccounts;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070707) : const Color(0xFFFAF9FB),
      body: Stack(
        children: [
          // Main Split Screen Layout
          Row(
            children: [
              // Left Column: The Form
              Expanded(
                flex: showRightPanel ? 5 : 10,
                child: Container(
                  color: isDark ? const Color(0xFF0C0C0C) : const Color(0xFFFFFFFF),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                        child: _ScaledContent(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: _buildLoginForm(l10n!, isDark, showRightPanel),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Right Column: Minimal Branding Panel (only shown on wider screens)
              if (showRightPanel)
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF050505) : const Color(0xFFF1F0F3),
                      border: Border(
                        left: BorderSide(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            width: 120,
                            height: 120,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'XANEO',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black,
                              letterSpacing: 4,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n?.secureDesktopCommunicator ?? 'secure desktop communicator',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                              letterSpacing: 2,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Settings button trigger
          const Positioned.fill(
            child: SettingsButton(),
          ),

          // Back button to return to messenger
          if (canGoBack)
            Positioned(
              top: 50,
              left: 20,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep = 0;
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _loginFocus.requestFocus();
                      });
                    } else {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else if (_hasAccounts) {
                        Navigator.of(context).pushReplacementNamed('/messenger');
                      }
                    }
                  },
                  child: Tooltip(
                    message: (AppLocalizations.of(context)?.nazadKMessendzheru_de29 ?? 'Fallback'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.03),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AppLocalizations l10n, bool isDark, bool showRightPanel) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo (if right panel is hidden)
          if (!showRightPanel) ...[
            Image.asset(
              'assets/logo.png',
              width: 44,
              height: 44,
              color: isDark ? Colors.white : Colors.black,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 32),
          ],
          
          // Header / Welcome Title (Step-dependent)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey<int>(_currentStep),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentStep == 0 ? (AppLocalizations.of(context)?.voytiVAkkaunt_c439 ?? 'Fallback') : (AppLocalizations.of(context)?.vvediteParol_1370 ?? 'Fallback'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _currentStep == 0
                      ? Text(
                          (AppLocalizations.of(context)?.vvediteSvoiDannyeDlyaDostupa_319e ?? 'Fallback'),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                            fontFamily: 'Inter',
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              _loginController.text,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(width: 8),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentStep = 0;
                                  });
                                  Future.delayed(const Duration(milliseconds: 100), () {
                                    _loginFocus.requestFocus();
                                  });
                                },
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 14,
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Sequential Fields Container with Fade Animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey<int>(_currentStep),
              child: _currentStep == 0
                  ? _buildLoginField(l10n, isDark)
                  : _buildPasswordField(l10n, isDark),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Login Button
          _buildLoginButton(l10n, isDark),
          
          const SizedBox(height: 24),
          
          // Register Link / Back Link
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _currentStep == 0
                ? _buildRegisterLink(l10n, isDark)
                : Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentStep = 0;
                          });
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _loginFocus.requestFocus();
                          });
                        },
                        child: Text(
                          (AppLocalizations.of(context)?.nazad_2b0b ?? 'Fallback'),
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginField(AppLocalizations? l10n, bool isDark) {
    return CustomTextFormField(
      controller: _loginController,
      focusNode: _loginFocus,
      labelText: l10n!.loginFieldHint,
      icon: FontAwesomeIcons.user,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.fillAllFields;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations? l10n, bool isDark) {
    return CustomTextFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      labelText: l10n!.passwordFieldHint,
      icon: FontAwesomeIcons.lock,
      isPasswordField: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.fillAllFields;
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(AppLocalizations? l10n, bool isDark) {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    }

    final isNextStep = _currentStep == 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isNextStep ? _nextStep : _handleLogin,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isNextStep ? (AppLocalizations.of(context)?.dalee_c453 ?? 'Fallback') : (l10n?.loginButton ?? (AppLocalizations.of(context)?.voyti_63a7 ?? 'Fallback')),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.black : Colors.white,
                    letterSpacing: 0.5,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(AppLocalizations? l10n, bool isDark) {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
          child: Text(
            l10n!.noAccount,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 12,
              decoration: TextDecoration.underline,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}

/// Виджет для применения масштаба к контенту
class _ScaledContent extends StatelessWidget {
  final Widget child;

  const _ScaledContent({required this.child});

  @override
  Widget build(BuildContext context) {
    final scaleProvider = context.watch<ScaleProvider?>();
    final scale = scaleProvider?.scale ?? 1.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      alignment: Alignment.center,
      child: child,
    );
  }
}
