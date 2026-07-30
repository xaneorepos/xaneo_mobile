import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_form_field.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/scale_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/advanced_background.dart';
import '../services/api_service.dart';
import '../services/crypto_service.dart';
import '../services/account_service.dart';
import '../widgets/custom_toast.dart';
import '../services/notification_service.dart';

/// Экран регистрации с 7 шагами (как в xaneo_mobile)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Контроллеры полей
  final _firstNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  
  // Focus nodes
  final _firstNameFocus = FocusNode();
  final _birthDateFocus = FocusNode();
  final _nicknameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _verificationCodeFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _passwordConfirmFocus = FocusNode();
  
  // Состояние
  bool _isLoading = false;
  bool _hasAccounts = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isCheckingNickname = false;
  bool _isNicknameAvailable = false;
  bool _isNicknameTaken = false;
  bool _isCheckingEmail = false;
  bool _isEmailAvailable = false;
  bool _isEmailTaken = false;
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  bool _acceptTerms = false;
  bool _acceptDataProcessing = false;
  
  // Ошибки и дебаунсы
  String? _nicknameError;
  String? _emailError;
  String? _verificationError;
  int _nicknameDebounce = 0;
  int _emailDebounce = 0;
  
  // Переменные настроек
  bool _notificationsEnabled = true;
  bool _useCustomNotifications = true;
  double _fontSize = 16.0;
  int _selectedLanguageIndex = 1; // Индекс русского языка в списке
  bool _showSettings = false; // Показывать модальное окно настроек
  
  // Список доступных языков
  final List<Map<String, String>> _availableLanguages = LocaleProvider.availableLanguages;
  
  // Аватар
  File? _avatarFile;
  final ImagePicker _imagePicker = ImagePicker();
  DateTime? _selectedBirthDate;

  
  // Этапы регистрации (0-8, всего 9 шагов)
  int _currentStep = 0;
  
  // Анимации
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _settingsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  void _onFieldChanged() {
    setState(() {});
  }

  Future<void> _checkAccounts() async {
    final accounts = await AccountService().getAccounts();
    if (mounted) {
      setState(() {
        _hasAccounts = accounts.isNotEmpty;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAccounts();
    _nicknameController.addListener(_onNicknameChanged);
    _emailController.addListener(_onEmailChanged);
    _firstNameController.addListener(_onFieldChanged);
    _birthDateController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _passwordConfirmController.addListener(_onFieldChanged);
    _verificationCodeController.addListener(_onFieldChanged);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _settingsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
    _firstNameController.dispose();
    _birthDateController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _verificationCodeController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    
    _firstNameFocus.dispose();
    _birthDateFocus.dispose();
    _nicknameFocus.dispose();
    _emailFocus.dispose();
    _verificationCodeFocus.dispose();
    _passwordFocus.dispose();
    _passwordConfirmFocus.dispose();
    
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _settingsAnimationController.dispose();
    
    super.dispose();
  }
  
  void _onNicknameChanged() {
    _nicknameDebounce++;
    final currentDebounce = _nicknameDebounce;
    
    setState(() {
      _isNicknameAvailable = false;
      _isNicknameTaken = false;
      _nicknameError = null;
      if (_nicknameController.text.trim().length >= 3) {
        _isCheckingNickname = true;
      } else {
        _isCheckingNickname = false;
      }
    });
    
    if (_nicknameController.text.trim().length < 3) return;
    
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (currentDebounce == _nicknameDebounce && mounted) {
        await _validateNickname();
      }
    });
  }
  
  Future<void> _validateNickname() async {
    final username = _nicknameController.text.trim();
    if (username.length < 3) return;
    
    final apiService = ApiService();
    final result = await apiService.checkUsername(username);
    
    if (mounted) {
      setState(() {
        _isCheckingNickname = false;
        if (result.success && result.data != null) {
          final isAvailable = result.data!['available'] == true;
          _isNicknameAvailable = isAvailable;
          _isNicknameTaken = !isAvailable;
          _nicknameError = isAvailable ? null : (AppLocalizations.of(context)?.nikneymUzheZanyat_59aa ?? result.data!['message'] ?? 'Username taken');
        } else {
          _isNicknameAvailable = false;
          _isNicknameTaken = true;
          print('Ошибка проверки никнейма: ${result.error}');
          _nicknameError = result.error ?? (AppLocalizations.of(context)?.oshibkaProverki_2ab0 ?? 'Fallback');
        }
      });
    }
  }
  
  void _onEmailChanged() {
    _emailDebounce++;
    final currentDebounce = _emailDebounce;
    
    final email = _emailController.text.trim();
    final isValidFormat = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    
    setState(() {
      _isEmailAvailable = false;
      _isEmailTaken = false;
      _emailError = null;
      if (isValidFormat) {
        _isCheckingEmail = true;
      } else {
        _isCheckingEmail = false;
      }
    });
    
    if (!isValidFormat) return;
    
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (currentDebounce == _emailDebounce && mounted) {
        await _validateEmail();
      }
    });
  }
  
  Future<void> _validateEmail() async {
    final email = _emailController.text.trim();
    final isValidFormat = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (!isValidFormat) return;
    
    final apiService = ApiService();
    final result = await apiService.checkEmail(email);
    
    if (mounted) {
      setState(() {
        _isCheckingEmail = false;
        if (result.success && result.data != null) {
          final isAvailable = result.data!['available'] == true;
          _isEmailAvailable = isAvailable;
          _isEmailTaken = !isAvailable;
          _emailError = isAvailable ? null : (AppLocalizations.of(context)?.emailUzheZanyat_17e1 ?? result.data!['message'] ?? 'Email taken');
        } else {
          _isEmailAvailable = false;
          _isEmailTaken = true;
          _emailError = result.error ?? (AppLocalizations.of(context)?.oshibkaProverki_2ab0 ?? 'Fallback');
        }
      });
    }
  }

  /// Отправить код верификации на email
  Future<void> _sendVerificationCode() async {
    setState(() {
      _isLoading = true;
      _verificationError = null;
    });
    
    final email = _emailController.text.trim();
    final nickname = _nicknameController.text.trim();
    print('DEBUG UI: Starting _sendVerificationCode with email: $email, nickname: $nickname');

    final apiService = ApiService();
    final result = await apiService.sendVerificationCode(
      email: email,
      username: nickname,
    );
    
    print('DEBUG UI: _sendVerificationCode result: success=${result.success}, error=${result.error}');

    setState(() {
      _isLoading = false;
    });
    
    if (result.success) {
      setState(() {
        _currentStep = 4; // Переходим к шагу подтверждения
      });
    } else {
      setState(() {
        _verificationError = result.error ?? (AppLocalizations.of(context)?.oshibkaOtpravkiKoda_a42a ?? 'Fallback');
      });
      _showErrorMessage(_verificationError!);
    }
  }
  
  /// Подтвердить код
  Future<void> _verifyEmailCode() async {
    setState(() {
      _isLoading = true;
      _verificationError = null;
    });
    
    final email = _emailController.text.trim();
    final code = _verificationCodeController.text.trim();
    print('DEBUG UI: Starting _verifyEmailCode with email: $email, code: $code');

    final apiService = ApiService();
    final result = await apiService.verifyEmailCode(
      email: email,
      code: code,
    );

    print('DEBUG UI: _verifyEmailCode result: success=${result.success}, error=${result.error}');
    
    setState(() {
      _isLoading = false;
    });
    
    if (result.success) {
      setState(() {
        _currentStep = 5; // Переходим к шагу ввода пароля
      });
    } else {
      setState(() {
        _verificationError = result.error ?? (AppLocalizations.of(context)?.nevernyyKodPodtverzhdeniya_7762 ?? 'Fallback');
      });
      _showErrorMessage(_verificationError!);
    }
  }
  
  /// Выбрать аватар
  Future<void> _pickAvatar() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() => _avatarFile = File(image.path));
    }
  }
  
  /// Удалить аватар
  void _removeAvatar() {
    setState(() => _avatarFile = null);
  }
  
  /// Выбрать дату рождения — кастомный сеточный календарь
  Future<void> _selectBirthDate() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    if (_birthDateController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_birthDateController.text);
      } catch (_) {}
    } else if (_selectedBirthDate != null) {
      initialDate = _selectedBirthDate!;
    }

    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CustomDatePickerSheet(
        initialDate: initialDate,
        minDate: DateTime(1900),
        maxDate: DateTime.now().subtract(const Duration(days: 365 * 14)),
        isDark: isDark,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

    /// Перейти к следующему шагу
  void _nextStep() {
    if (_currentStep < 8) {
      if (_currentStep == 3) {
        _sendVerificationCode();
      } else if (_currentStep == 4) {
        _verifyEmailCode();
      } else {
        setState(() => _currentStep++);
      }
    }
  }
  
  /// Вернуться к предыдущему шагу
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }
  
  /// Завершить регистрацию
  Future<void> _completeRegistration() async {
    if (!_acceptTerms || !_acceptDataProcessing) {
      _showErrorMessage((AppLocalizations.of(context)?.neobhodimoPrinyatUsloviyaISoglasie_e31e ?? 'Fallback'));
      return;
    }
    
    setState(() => _isLoading = true);
    
    final apiService = ApiService();
    final result = await apiService.register(
      username: _nicknameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirm: _passwordConfirmController.text,
      birthDate: _birthDateController.text,
      firstName: _firstNameController.text.trim().isEmpty 
          ? null 
          : _firstNameController.text.trim(),
    );
    
    if (result.success) {
      // Генерируем и сохраняем E2EE ключи
      try {
        final newBlob = await CryptoService().generateAndStoreKeys(_passwordController.text);
        final uploadResponse = await apiService.uploadKeys(
          x25519PublicKey: newBlob['pub']['x25519'] as String,
          ed25519PublicKey: newBlob['pub']['ed25519'] as String,
          encryptedBlob: newBlob,
        );
        if (!uploadResponse.success) {
          print("Error uploading keys during registration: ${uploadResponse.error}");
        }
      } catch (e) {
        print("Error generating keys during registration: $e");
      }

      setState(() => _isLoading = false);
      _showSuccessMessage((AppLocalizations.of(context)?.registratsiyaUspeshna_9d5c ?? 'Fallback'));
      
      // Возвращаемся на экран входа
      if (mounted) {
        Navigator.of(context).pop(true); // true означает успешную регистрацию
      }
    } else {
      setState(() => _isLoading = false);
      _showErrorMessage(result.error ?? (AppLocalizations.of(context)?.oshibkaRegistratsii_b9f2 ?? 'Fallback'));
    }
  }
  
  /// Показать сообщение об ошибке
  void _showErrorMessage(String message) {
    CustomToast.show(context, message, type: ToastType.error);
  }
  
  /// Показать сообщение об успехе
  void _showSuccessMessage(String message) {
    CustomToast.show(context, message, type: ToastType.success);
  }
  
  /// Проверить валидность текущего шага
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Имя
        return _firstNameController.text.trim().isNotEmpty;
      case 1: // Дата рождения
        return _birthDateController.text.trim().isNotEmpty;
      case 2: // Никнейм
        return _nicknameController.text.trim().length >= 3 && _isNicknameAvailable;
      case 3: // Email
        return _emailController.text.trim().isNotEmpty && 
               RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim()) &&
               _isEmailAvailable;
      case 4: // Код подтверждения
        return _verificationCodeController.text.trim().length == 6;
      case 5: // Пароль
        return _passwordController.text.length >= 8;
      case 6: // Подтверждение пароля
        return _passwordConfirmController.text.isNotEmpty &&
               _passwordController.text == _passwordConfirmController.text;
      case 7: // Аватар (опционально)
        return true;
      case 8: // Условия
        return _acceptTerms && _acceptDataProcessing;
      default:
        return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final scaleProvider = Provider.of<ScaleProvider>(context);
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
              // Left Column: Sequential Registration Form
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
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Form(
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
                                      const SizedBox(height: 32),
                                    ],
                                    
                                    // Step Header
                                    _buildHeader(scaleProvider, isDark),
                                    const SizedBox(height: 24),
                                    
                                    // Progress Bar
                                    _buildProgressIndicator(scaleProvider, isDark),
                                    const SizedBox(height: 32),
                                    
                                    // Current Step form fields with fade transition
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      transitionBuilder: (Widget child, Animation<double> animation) {
                                        return FadeTransition(opacity: animation, child: child);
                                      },
                                      child: KeyedSubtree(
                                        key: ValueKey<int>(_currentStep),
                                        child: _buildCurrentStep(scaleProvider, isDark),
                                      ),
                                    ),
                                    
                                    SizedBox(height: (_currentStep == 8 ? 16 : 32) * scaleProvider.scale),
                                    
                                    // Navigation Buttons
                                    _buildNavigationButtons(scaleProvider, isDark),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Right Column: Minimal Branding Panel (identical to login)
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
                            (AppLocalizations.of(context)?.secureDesktopCommunicator ?? 'secure desktop communicator'),
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
          
          // Back button trigger
          if (canGoBack)
            Positioned(
              top: 50,
              left: 20,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (_currentStep > 0) {
                      _previousStep();
                    } else {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else if (_hasAccounts) {
                        Navigator.of(context).pushReplacementNamed('/messenger');
                      }
                    }
                  },
                  child: Tooltip(
                    message: (AppLocalizations.of(context)?.nazad_2b0b ?? 'Fallback'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark 
                            ? Colors.white.withOpacity(0.02)
                            : Colors.black.withOpacity(0.02),
                        border: Border.all(
                          color: isDark 
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : Colors.black,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Settings button trigger
          Positioned(
            top: 50,
            right: 20,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() => _showSettings = true);
                  _settingsAnimationController.forward();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark 
                        ? Colors.white.withOpacity(0.02)
                        : Colors.black.withOpacity(0.02),
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: isDark ? Colors.white : Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          
          // Settings Modal overlay
          if (_showSettings) _buildSettingsModal(context, isDark),
        ],
      ),
    );
  }
  
  Widget _buildHeader(ScaleProvider scaleProvider, bool isDark) {
    final titles = [
      (AppLocalizations.of(context)?.kakVasZovut_68b7 ?? 'Fallback'),
      (AppLocalizations.of(context)?.kogdaVyRodilis_26f2 ?? 'Fallback'),
      (AppLocalizations.of(context)?.pridumayteNikneym_221b ?? 'Fallback'),
      (AppLocalizations.of(context)?.vashEmail_8bbd ?? 'Fallback'),
      (AppLocalizations.of(context)?.podtverzhdenieEmail_281f ?? 'Fallback'),
      (AppLocalizations.of(context)?.sozdayteParol_5f4c ?? 'Fallback'),
      (AppLocalizations.of(context)?.podtverzhdenieParolya_ebc2 ?? 'Fallback'),
      (AppLocalizations.of(context)?.dobavteFoto_25eb ?? 'Fallback'),
      (AppLocalizations.of(context)?.posledniyShag_e0c5 ?? 'Fallback'),
    ];
    
    final subtitles = [
      (AppLocalizations.of(context)?.vvediteVasheNastoyascheeImya_e656 ?? 'Fallback'),
      (AppLocalizations.of(context)?.vamDolzhnoBytNeMenee_1111 ?? 'Fallback'),
      (AppLocalizations.of(context)?.nikneymDolzhenBytUnikalnym_952d ?? 'Fallback'),
      (AppLocalizations.of(context)?.myOtpravimKodPodtverzhdeniya_fc71 ?? 'Fallback'),
      (AppLocalizations.of(context)?.vvedite6ZnachnyyKodIz_f22f ?? 'Fallback'),
      (AppLocalizations.of(context)?.pridumayteNadezhnyyParol_2312 ?? 'Fallback'),
      (AppLocalizations.of(context)?.povtoriteParolEscheRaz_6723 ?? 'Fallback'),
      (AppLocalizations.of(context)?.etoNeobyazatelnoNoPriyatno_b6a3 ?? 'Fallback'),
      (AppLocalizations.of(context)?.proverteVashiDannyeIPrimite_3121 ?? 'Fallback'),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (AppLocalizations.of(context)?.registratsiya_0b93 ?? 'Fallback'),
          style: TextStyle(
            fontSize: 12 * scaleProvider.scale,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            letterSpacing: 1,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          titles[_currentStep],
          style: TextStyle(
            fontSize: 28 * scaleProvider.scale,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 8),
        Text(
          subtitles[_currentStep],
          style: TextStyle(
            fontSize: 13 * scaleProvider.scale,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
  
  Widget _buildProgressIndicator(ScaleProvider scaleProvider, bool isDark) {
    final progress = (_currentStep + 1) / 9.0;
    return Container(
      height: 2,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(1),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCurrentStep(ScaleProvider scaleProvider, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStep0(scaleProvider, isDark);
      case 1:
        return _buildStep1(scaleProvider, isDark);
      case 2:
        return _buildStep2(scaleProvider, isDark);
      case 3:
        return _buildStep3(scaleProvider, isDark);
      case 4:
        return _buildStep4(scaleProvider, isDark);
      case 5:
        return _buildStep5(scaleProvider, isDark);
      case 6:
        return _buildStep6(scaleProvider, isDark);
      case 7:
        return _buildStep7(scaleProvider, isDark);
      case 8:
        return _buildStep8(scaleProvider, isDark);
      default:
        return const SizedBox.shrink();
    }
  }
  
  // Шаг 0: Имя
  Widget _buildStep0(ScaleProvider scaleProvider, bool isDark) {
    return _buildTextField(
      controller: _firstNameController,
      focusNode: _firstNameFocus,
      label: (AppLocalizations.of(context)?.vasheImya_51eb ?? 'Fallback'),
      icon: FontAwesomeIcons.user,
      textCapitalization: TextCapitalization.words,
      scaleProvider: scaleProvider,
      isDark: isDark,
    );
  }
  
  // Шаг 1: Дата рождения
  Widget _buildStep1(ScaleProvider scaleProvider, bool isDark) {
    return _buildDateField(scaleProvider, isDark);
  }
  
  // Шаг 2: Никнейм
  Widget _buildStep2(ScaleProvider scaleProvider, bool isDark) {
    return Column(
      children: [
        _buildTextField(
          controller: _nicknameController,
          focusNode: _nicknameFocus,
          label: (AppLocalizations.of(context)?.nikneym_3fea ?? 'Fallback'),
          icon: FontAwesomeIcons.at,
          scaleProvider: scaleProvider,
          isDark: isDark,
        ),
        SizedBox(height: 16 * scaleProvider.scale),
        
        // Статус доступности никнейма
        if (_isCheckingNickname)
          Row(
            children: [
              SizedBox(
                width: 16 * scaleProvider.scale,
                height: 16 * scaleProvider.scale,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 8 * scaleProvider.scale),
              Text(
                (AppLocalizations.of(context)?.proverkaDostupnosti_da13 ?? 'Fallback'),
                style: TextStyle(
                  fontSize: 14 * scaleProvider.scale,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          )
        else if (_isNicknameAvailable)
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16 * scaleProvider.scale,
              ),
              SizedBox(width: 8 * scaleProvider.scale),
              Text(
                (AppLocalizations.of(context)?.nikneymDostupen_3fc9 ?? 'Fallback'),
                style: TextStyle(
                  fontSize: 14 * scaleProvider.scale,
                  color: Colors.green,
                ),
              ),
            ],
          )
        else if (_isNicknameTaken)
          Row(
            children: [
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 16 * scaleProvider.scale,
              ),
              SizedBox(width: 8 * scaleProvider.scale),
              Text(
                _nicknameError ?? (AppLocalizations.of(context)?.nikneymZanyat_8a5f ?? 'Fallback'),
                style: TextStyle(
                  fontSize: 14 * scaleProvider.scale,
                  color: Colors.red,
                ),
              ),
            ],
          ),
      ],
    );
  }
  
  // Шаг 3: Email
  Widget _buildStep3(ScaleProvider scaleProvider, bool isDark) {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          focusNode: _emailFocus,
          label: (AppLocalizations.of(context)?.email ?? 'Email'),
          icon: FontAwesomeIcons.envelope,
          keyboardType: TextInputType.emailAddress,
          scaleProvider: scaleProvider,
          isDark: isDark,
        ),
        SizedBox(height: 16 * scaleProvider.scale),
        
        // Статус доступности email
        if (_isCheckingEmail)
          Row(
            children: [
              SizedBox(
                width: 16 * scaleProvider.scale,
                height: 16 * scaleProvider.scale,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 8 * scaleProvider.scale),
              Text(
                (AppLocalizations.of(context)?.proverkaDostupnosti_da13 ?? 'Fallback'),
                style: TextStyle(
                  fontSize: 14 * scaleProvider.scale,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          )
        else if (_isEmailAvailable)
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16 * scaleProvider.scale,
              ),
              SizedBox(width: 8 * scaleProvider.scale),
              Text(
                (AppLocalizations.of(context)?.emailDostupen_e903 ?? 'Fallback'),
                style: TextStyle(
                  fontSize: 14 * scaleProvider.scale,
                  color: Colors.green,
                ),
              ),
            ],
          )
        else if (_isEmailTaken)
          Row(
            children: [
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 16 * scaleProvider.scale,
              ),
              SizedBox(width: 8 * scaleProvider.scale),
              Text(
                _emailError ?? (AppLocalizations.of(context)?.emailZanyat_fb40 ?? 'Fallback'),
                style: TextStyle(
                  fontSize: 14 * scaleProvider.scale,
                  color: Colors.red,
                ),
              ),
            ],
          ),
      ],
    );
  }
  
  // Шаг 4: Подтверждение Email
  Widget _buildStep4(ScaleProvider scaleProvider, bool isDark) {
    return Column(
      children: [
        Text(
          (AppLocalizations.of(context)?.codeSentToEmail(_emailController.text) ?? 'Код отправлен на ${_emailController.text}'),
          style: TextStyle(
            fontSize: 14 * scaleProvider.scale,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24 * scaleProvider.scale),
        _buildTextField(
          controller: _verificationCodeController,
          focusNode: _verificationCodeFocus,
          label: (AppLocalizations.of(context)?.kodPodtverzhdeniya_1c9d ?? 'Fallback'),
          icon: FontAwesomeIcons.shield,
          keyboardType: TextInputType.number,
          scaleProvider: scaleProvider,
          isDark: isDark,
          onChanged: (val) {
            if (val.trim().length == 6) {
              _verifyEmailCode();
            }
          },
        ),
        if (_verificationError != null) ...[
          SizedBox(height: 12 * scaleProvider.scale),
          Text(
            _verificationError!,
            style: TextStyle(color: Colors.red, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: 16 * scaleProvider.scale),
        TextButton(
          onPressed: _isLoading ? null : _sendVerificationCode,
          child: Text(
            (AppLocalizations.of(context)?.otpravitKodPovtorno_7703 ?? 'Fallback'),
            style: TextStyle(
              fontSize: 14 * scaleProvider.scale,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  // Шаг 5: Пароль
  Widget _buildStep5(ScaleProvider scaleProvider, bool isDark) {
    return _buildPasswordField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      label: (AppLocalizations.of(context)?.parol_5ebe ?? 'Fallback'),
      obscureText: _obscurePassword,
      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
      scaleProvider: scaleProvider,
      isDark: isDark,
    );
  }
  
  // Шаг 6: Подтверждение пароля
  Widget _buildStep6(ScaleProvider scaleProvider, bool isDark) {
    return _buildPasswordField(
      controller: _passwordConfirmController,
      focusNode: _passwordConfirmFocus,
      label: (AppLocalizations.of(context)?.podtverditeParol_e3e3 ?? 'Fallback'),
      obscureText: _obscureConfirmPassword,
      onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
      scaleProvider: scaleProvider,
      isDark: isDark,
    );
  }
  
  // Шаг 7: Аватар
  Widget _buildStep7(ScaleProvider scaleProvider, bool isDark) {
    return Column(
      children: [
        // Превью аватара
        GestureDetector(
          onTap: _pickAvatar,
          child: Container(
            width: 120 * scaleProvider.scale,
            height: 120 * scaleProvider.scale,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(60 * scaleProvider.scale),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: _avatarFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(60 * scaleProvider.scale),
                    child: Image.file(
                      _avatarFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.add_a_photo,
                    size: 40 * scaleProvider.scale,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
          ),
        ),
        SizedBox(height: 16 * scaleProvider.scale),
        
        Text(
          (AppLocalizations.of(context)?.nazhmiteChtobyDobavitFoto_d6e8 ?? 'Fallback'),
          style: TextStyle(
            fontSize: 14 * scaleProvider.scale,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        
        if (_avatarFile != null) ...[
          SizedBox(height: 16 * scaleProvider.scale),
          TextButton.icon(
            onPressed: _removeAvatar,
            icon: Icon(
              Icons.delete_outline,
              size: 16 * scaleProvider.scale,
            ),
            label: Text(
              (AppLocalizations.of(context)?.udalitFoto_3426 ?? 'Fallback'),
              style: TextStyle(
                fontSize: 14 * scaleProvider.scale,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Шаг 8: Превью и условия
  Widget _buildStep8(ScaleProvider scaleProvider, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Превью профиля
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 8 * scaleProvider.scale,
            horizontal: 16 * scaleProvider.scale,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16 * scaleProvider.scale),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              // Аватар
              CircleAvatar(
                radius: 24 * scaleProvider.scale,
                backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
                child: _avatarFile == null
                    ? Icon(
                        Icons.person,
                        size: 24 * scaleProvider.scale,
                        color: isDark ? Colors.white60 : Colors.black54,
                      )
                    : null,
              ),
              SizedBox(width: 16 * scaleProvider.scale),
              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _firstNameController.text.trim(),
                      style: TextStyle(
                        fontSize: 16 * scaleProvider.scale,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '@${_nicknameController.text.trim()}',
                      style: TextStyle(
                        fontSize: 13 * scaleProvider.scale,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12 * scaleProvider.scale),
        
        // Принятие условий
        CheckboxListTile(
          value: _acceptTerms,
          onChanged: (value) => setState(() => _acceptTerms = value ?? false),
          title: Text(
            (AppLocalizations.of(context)?.yaPrinimayuUsloviyaIspolzovaniya_391a ?? 'Fallback'),
            style: TextStyle(
              fontSize: 13 * scaleProvider.scale,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          dense: true,
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: isDark ? Colors.white : Colors.black,
        ),
        
        // Согласие на обработку данных
        CheckboxListTile(
          value: _acceptDataProcessing,
          onChanged: (value) => setState(() => _acceptDataProcessing = value ?? false),
          title: Text(
            (AppLocalizations.of(context)?.yaSoglasenNaObrabotkuPersonalnyh_f2a8 ?? 'Fallback'),
            style: TextStyle(
              fontSize: 13 * scaleProvider.scale,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          dense: true,
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: isDark ? Colors.white : Colors.black,
        ),
      ],
    );
  }
  
  Widget _buildNavigationButtons(ScaleProvider scaleProvider, bool isDark) {
    final canGoBack = Navigator.of(context).canPop() || _hasAccounts;
    final showBackButton = _currentStep > 0 || canGoBack;

    return Row(
      children: [
        // Кнопка "Назад"
        if (showBackButton)
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_currentStep > 0) {
                        _previousStep();
                      } else {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else if (_hasAccounts) {
                          Navigator.of(context).pushReplacementNamed('/messenger');
                        }
                      }
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : Colors.black,
                side: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                ),
                padding: EdgeInsets.symmetric(vertical: 14 * scaleProvider.scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * scaleProvider.scale),
                ),
              ),
              child: Text(
                (AppLocalizations.of(context)?.nazad_2b0b ?? 'Fallback'),
                style: TextStyle(
                  fontSize: 14 * scaleProvider.scale,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        
        if (showBackButton) SizedBox(width: 16 * scaleProvider.scale),
        
        // Кнопка "Далее" или "Завершить"
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading || !_validateCurrentStep() 
                ? null 
                : (_currentStep == 8 ? _completeRegistration : _nextStep),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14 * scaleProvider.scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8 * scaleProvider.scale),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20 * scaleProvider.scale,
                    height: 20 * scaleProvider.scale,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.black : Colors.white),
                    ),
                  )
                : Text(
                    _currentStep == 8 ? (AppLocalizations.of(context)?.zavershit_b0e3 ?? 'Fallback') : (AppLocalizations.of(context)?.dalee_c453 ?? 'Fallback'),
                    style: TextStyle(
                      fontSize: 14 * scaleProvider.scale,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required FaIconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    void Function(String)? onChanged,
    required ScaleProvider scaleProvider,
    required bool isDark,
  }) {
    return CustomTextFormField(
      controller: controller,
      focusNode: focusNode,
      labelText: label,
      icon: icon,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      onChanged: onChanged,
    );
  }
  
  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool obscureText,
    required VoidCallback onTap,
    String? Function(String?)? validator,
    required ScaleProvider scaleProvider,
    required bool isDark,
  }) {
    return CustomTextFormField(
      controller: controller,
      focusNode: focusNode,
      labelText: label,
      icon: FontAwesomeIcons.lock,
      isPasswordField: true,
      validator: validator,
    );
  }
  
  Widget _buildDateField(ScaleProvider scaleProvider, bool isDark) {
    return CustomTextFormField(
      controller: _birthDateController,
      focusNode: _birthDateFocus,
      labelText: (AppLocalizations.of(context)?.dataRozhdeniya_505e ?? 'Fallback'),
      icon: FontAwesomeIcons.calendarDays,
      readOnly: true,
      onTap: _selectBirthDate,
    );
  }
  
  /// Закрывает модальное окно с анимацией
  void _closeSettings() async {
    await _settingsAnimationController.reverse();
    setState(() => _showSettings = false);
  }

  /// Строит модальное окно настроек как часть Stack
  Widget _buildSettingsModal(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return AnimatedBuilder(
          animation: _settingsAnimationController,
          builder: (context, child) {
            return Stack(
              children: [
                // Затемнение только для области под title bar (ниже 40 пикселей)
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _closeSettings,
                    child: Container(
                      color: isDark 
                          ? Colors.black.withOpacity(0.5 * _settingsAnimationController.value)
                          : Colors.black.withOpacity(0.3 * _settingsAnimationController.value),
                    ),
                  ),
                ),
                
                // Контент модального окна с анимацией
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _settingsAnimationController,
                      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.95,
                        end: 1.0,
                      ).animate(CurvedAnimation(
                        parent: _settingsAnimationController,
                        curve: Curves.easeOut,
                      )),
                      child: Center(
                        child: Container(
                          width: screenSize.width * 0.85,
                          constraints: BoxConstraints(
                            maxWidth: 480,
                            maxHeight: screenSize.height * 0.85,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF141414) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Заголовок с кнопкой закрытия
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.08)
                                              : Colors.black.withOpacity(0.05),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Анимированная иконка
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(milliseconds: 800),
                                          tween: Tween<double>(begin: 0.0, end: 1.0),
                                          curve: Curves.elasticOut,
                                          builder: (context, iconAnim, child) {
                                            return Transform.rotate(
                                              angle: iconAnim * 2 * math.pi * 0.3,
                                              child: Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: isDark
                                                        ? [
                                                            Colors.white.withOpacity(0.2),
                                                            Colors.white.withOpacity(0.05),
                                                          ]
                                                        : [
                                                            Colors.black.withOpacity(0.1),
                                                            Colors.black.withOpacity(0.02),
                                                          ],
                                                  ),
                                                  border: Border.all(
                                                    color: isDark
                                                        ? Colors.white.withOpacity(0.25)
                                                        : Colors.black.withOpacity(0.1),
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: isDark
                                                          ? Colors.white.withOpacity(0.1)
                                                          : Colors.black.withOpacity(0.05),
                                                      blurRadius: 15,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.settings_rounded,
                                                  color: isDark ? Colors.white : Colors.black,
                                                  size: 24,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        l10n?.settings ?? (AppLocalizations.of(context)?.nastroyki_c919 ?? 'Fallback'),
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    // Кнопка закрытия
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: _closeSettings,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isDark
                                                ? Colors.white.withOpacity(0.08)
                                                : Colors.black.withOpacity(0.05),
                                            border: Border.all(
                                              color: isDark
                                                  ? Colors.white.withOpacity(0.15)
                                                  : Colors.black.withOpacity(0.08),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            color: isDark ? Colors.white : Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Содержимое настроек
                              Flexible(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // === СЕКЦИЯ: ВНЕШНИЙ ВИД ===
                                      _buildSectionHeader(l10n?.darkTheme ?? (AppLocalizations.of(context)?.temnayaTema_cb48 ?? 'Fallback'), isDark, Icons.palette_outlined),
                                      const SizedBox(height: 10),
                                      
                                      // Тёмная тема
                                      _buildAnimatedSettingsTile(
                                        icon: Icons.dark_mode_rounded,
                                        title: l10n?.darkTheme ?? (AppLocalizations.of(context)?.temnayaTema_cb48 ?? 'Fallback'),
                                        subtitle: l10n?.darkThemeDescription ?? (AppLocalizations.of(context)?.vklyuchitTemnuyuTemuOformleniya_86c4 ?? 'Fallback'),
                                        isDark: isDark,
                                        trailing: _buildAnimatedSwitch(
                                          value: themeProvider.isDarkMode,
                                          isDark: isDark,
                                          onChanged: (value) {
                                            themeProvider.setDarkMode(value);
                                          },
                                        ),
                                      ),
                                      
                                      SizedBox(height: 24),
                                      
                                      // === СЕКЦИЯ: ЯЗЫК ===
                                      _buildSectionHeader(l10n?.language ?? (AppLocalizations.of(context)?.yazyk_0577 ?? 'Fallback'), isDark, Icons.translate_rounded),
                                      const SizedBox(height: 10),
                                      
                                      // Выбор языка
                                      _buildLanguageSelector(localeProvider, isDark, l10n),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // === СЕКЦИЯ: УВЕДОМЛЕНИЯ ===
                                      _buildSectionHeader(l10n?.notifications ?? (AppLocalizations.of(context)?.uvedomleniya_d2ed ?? 'Fallback'), isDark, Icons.notifications_outlined),
                                      const SizedBox(height: 10),
                                      
                                      // Уведомления
                                      _buildAnimatedSettingsTile(
                                        icon: Icons.notifications_active_rounded,
                                        title: l10n?.notifications ?? (AppLocalizations.of(context)?.uvedomleniya_d2ed ?? 'Fallback'),
                                        subtitle: l10n?.notificationsDescription ?? (AppLocalizations.of(context)?.vklyuchitUvedomleniya_d311 ?? 'Fallback'),
                                        isDark: isDark,
                                        trailing: _buildAnimatedSwitch(
                                          value: _notificationsEnabled,
                                          isDark: isDark,
                                          onChanged: (value) {
                                            setState(() {
                                              _notificationsEnabled = value;
                                            });
                                          },
                                        ),
                                      ),
                                      if (_notificationsEnabled && NotificationService.isCustomOverlaySupported()) ...[
                                        SizedBox(height: 10),
                                        _buildAnimatedSettingsTile(
                                          icon: Icons.dashboard_customize_rounded,
                                          title: (AppLocalizations.of(context)?.kastomnyyOverleyXaneo_7d39 ?? 'Fallback'),
                                          subtitle: (AppLocalizations.of(context)?.animirovannyeUvedomleniyaSBystrymOtvetom_a25d ?? 'Fallback'),
                                          isDark: isDark,
                                          trailing: _buildAnimatedSwitch(
                                            value: _useCustomNotifications,
                                            isDark: isDark,
                                            onChanged: (value) {
                                              setState(() {
                                                _useCustomNotifications = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                      
                                      const SizedBox(height: 24),
                                      
                                      // === СЕКЦИЯ: ШРИФТ ===
                                      _buildSectionHeader(l10n?.fontSize(_fontSize.round()) ?? 'Font size: ${_fontSize.round()}', isDark, Icons.text_fields_rounded),
                                      const SizedBox(height: 10),
                                      
                                      // Размер шрифта
                                      _buildFontSizeSliderInline(isDark),
                                      
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ))],
            );
          },
        );
      },
    );
  }
  
  /// Создаёт слайдер размера шрифта (inline версия без StateSetter)
  Widget _buildFontSizeSliderInline(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ]
              : [
                  Colors.black.withOpacity(0.02),
                  Colors.black.withOpacity(0.01),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Превью текста
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 150),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: _fontSize,
              fontWeight: FontWeight.w500,
            ),
            child: Text((AppLocalizations.of(context)?.aaBbVv_1c6b ?? 'Fallback')),
          ),
          const SizedBox(height: 20),
          // Слайдер
          Material(
            color: Colors.transparent,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                activeTrackColor: isDark ? Colors.white : Colors.black,
                inactiveTrackColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade300,
                thumbColor: isDark ? Colors.white : Colors.black,
                overlayColor: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.1),
              ),
              child: Slider(
                value: _fontSize,
                min: 12.0,
                max: 24.0,
                divisions: 12,
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
            ),
          ),
          // Метки
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '12',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
              Text(
                '24',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Создаёт заголовок секции с иконкой
  Widget _buildSectionHeader(String title, bool isDark, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Создаёт анимированную плитку настройки
  Widget _buildAnimatedSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required Widget trailing,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ]
                : [
                    Colors.black.withOpacity(0.02),
                    Colors.black.withOpacity(0.01),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Иконка
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Текст
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Переключатель
            trailing,
          ],
        ),
      ),
    );
  }

  /// Создаёт анимированный переключатель
  Widget _buildAnimatedSwitch({
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: value
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Colors.white, Colors.grey.shade300]
                      : [Colors.black, Colors.grey.shade800],
                )
              : null,
          color: value
              ? null
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          border: Border.all(
            color: value
                ? Colors.transparent
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Создаёт селектор языка
  Widget _buildLanguageSelector(LocaleProvider localeProvider, bool isDark, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ]
              : [
                  Colors.black.withOpacity(0.02),
                  Colors.black.withOpacity(0.01),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: _availableLanguages.map((lang) {
          final isSelected = localeProvider.locale?.languageCode == lang['code'];
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                localeProvider.setLocale(Locale(lang['code']!));
                setState(() {
                  _selectedLanguageIndex = _availableLanguages.indexWhere((l) => l['code'] == lang['code']);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1))
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      lang['name']!,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Кастомный пикер даты (сеточный календарь)
// ─────────────────────────────────────────────────────────────────────────────

class _CustomDatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;
  final bool isDark;

  const _CustomDatePickerSheet({
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
    required this.isDark,
  });

  @override
  State<_CustomDatePickerSheet> createState() => _CustomDatePickerSheetState();
}

class _CustomDatePickerSheetState extends State<_CustomDatePickerSheet>
    with SingleTickerProviderStateMixin {
  late int _displayYear;
  late int _displayMonth;
  late DateTime _selected;
  bool _showYearPicker = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  List<String> get _monthNames => [
    (AppLocalizations.of(context)?.yanvar_ee86 ?? 'Январь'), (AppLocalizations.of(context)?.fevral_28ff ?? 'Февраль'), (AppLocalizations.of(context)?.mart_d766 ?? 'Март'), (AppLocalizations.of(context)?.aprel_03e9 ?? 'Апрель'), (AppLocalizations.of(context)?.may_2e53 ?? 'Май'), (AppLocalizations.of(context)?.iyun_cfcb ?? 'Июнь'),
    (AppLocalizations.of(context)?.iyul_89fb ?? 'Июль'), (AppLocalizations.of(context)?.avgust_de5a ?? 'Август'), (AppLocalizations.of(context)?.sentyabr_ebfb ?? 'Сентябрь'), (AppLocalizations.of(context)?.oktyabr_1720 ?? 'Октябрь'), (AppLocalizations.of(context)?.noyabr_66fb ?? 'Ноябрь'), (AppLocalizations.of(context)?.dekabr_39b3 ?? 'Декабрь'),
  ];
  List<String> get _weekDays => [(AppLocalizations.of(context)?.pn_2c1e ?? 'Fallback'), (AppLocalizations.of(context)?.vt_7145 ?? 'Fallback'), (AppLocalizations.of(context)?.sr_c6e4 ?? 'Fallback'), (AppLocalizations.of(context)?.cht_a51f ?? 'Fallback'), (AppLocalizations.of(context)?.pt_0123 ?? 'Fallback'), (AppLocalizations.of(context)?.sb_3a4b ?? 'Fallback'), (AppLocalizations.of(context)?.vs_4ad9 ?? 'Fallback')];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _displayYear = widget.initialDate.year;
    _displayMonth = widget.initialDate.month;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Color get _accent => const Color(0xFF6C63FF);
  Color get _bg => widget.isDark ? const Color(0xFF1C1C1E) : Colors.white;
  Color get _surface => widget.isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
  Color get _textPrimary => widget.isDark ? Colors.white : Colors.black;
  Color get _textSecondary => widget.isDark ? Colors.white54 : Colors.black45;
  Color get _divider => widget.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.07);

  void _prevMonth() {
    setState(() {
      if (_displayMonth == 1) {
        _displayMonth = 12;
        _displayYear--;
      } else {
        _displayMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_displayMonth == 12) {
        _displayMonth = 1;
        _displayYear++;
      } else {
        _displayMonth++;
      }
    });
  }

  bool _canGoPrev() {
    return DateTime(_displayYear, _displayMonth).isAfter(
      DateTime(widget.minDate.year, widget.minDate.month),
    );
  }

  bool _canGoNext() {
    return DateTime(_displayYear, _displayMonth).isBefore(
      DateTime(widget.maxDate.year, widget.maxDate.month),
    );
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_displayYear, _displayMonth, 1);
    // Monday = 1 … Sunday = 7
    int startWeekday = firstDay.weekday; // 1-7
    final daysInMonth = DateUtils.getDaysInMonth(_displayYear, _displayMonth);
    final cells = <DateTime?>[];
    for (int i = 1; i < startWeekday; i++) cells.add(null);
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_displayYear, _displayMonth, d));
    }
    return cells;
  }

  bool _isSelectable(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final min = DateTime(widget.minDate.year, widget.minDate.month, widget.minDate.day);
    final max = DateTime(widget.maxDate.year, widget.maxDate.month, widget.maxDate.day);
    return !d.isBefore(min) && !d.isAfter(max);
  }

  bool _isSelected(DateTime day) =>
      day.year == _selected.year &&
      day.month == _selected.month &&
      day.day == _selected.day;

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  Widget _buildYearPicker() {
    final years = List.generate(
      widget.maxDate.year - widget.minDate.year + 1,
      (i) => widget.minDate.year + i,
    ).reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: years.length,
      itemBuilder: (_, i) {
        final y = years[i];
        final isActive = y == _displayYear;
        return InkWell(
          onTap: () {
            setState(() {
              _displayYear = y;
              _showYearPicker = false;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: isActive
                ? BoxDecoration(
                    color: _accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  )
                : null,
            child: Center(
              child: Text(
                '$y',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                  color: isActive ? _accent : _textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendar() {
    final days = _buildCalendarDays();
    return Column(
      children: [
        // Weekday headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: _weekDays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Day grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1.1,
            ),
            itemCount: days.length,
            itemBuilder: (_, i) {
              final day = days[i];
              if (day == null) return const SizedBox.shrink();

              final selectable = _isSelectable(day);
              final selected = _isSelected(day);
              final today = _isToday(day);

              return GestureDetector(
                onTap: selectable ? () => setState(() => _selected = day) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: selected
                        ? _accent
                        : today
                            ? _accent.withOpacity(0.12)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected || today ? FontWeight.w700 : FontWeight.normal,
                        color: selected
                            ? Colors.white
                            : selectable
                                ? _textPrimary
                                : _textSecondary.withOpacity(0.35),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 460),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: _divider, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: _textSecondary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(48, 36),
                          ),
                          child: Text((AppLocalizations.of(context)?.otmena_987b ?? 'Fallback'), style: TextStyle(fontSize: 15)),
                        ),
                        Text(
                          (AppLocalizations.of(context)?.dataRozhdeniya_505e ?? 'Fallback'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(_selected),
                          style: TextButton.styleFrom(
                            foregroundColor: _accent,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(48, 36),
                          ),
                          child: Text(
                            (AppLocalizations.of(context)?.gotovo_34e1 ?? 'Fallback'),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Month / Year navigation ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Row(
                      children: [
                        // Prev month
                        _NavButton(
                          icon: Icons.chevron_left_rounded,
                          enabled: _canGoPrev(),
                          isDark: widget.isDark,
                          onTap: _prevMonth,
                        ),
                        const SizedBox(width: 8),
                        // Month label
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showYearPicker = !_showYearPicker),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: _surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${_monthNames[_displayMonth - 1]} $_displayYear',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  AnimatedRotation(
                                    turns: _showYearPicker ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Next month
                        _NavButton(
                          icon: Icons.chevron_right_rounded,
                          enabled: _canGoNext(),
                          isDark: widget.isDark,
                          onTap: _nextMonth,
                        ),
                      ],
                    ),
                  ),

                  // ── Calendar grid or year picker ─────────────────────────
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _showYearPicker
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCalendar(),
                    ),
                    secondChild: SizedBox(
                      height: 220,
                      child: _buildYearPicker(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isDark;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white : Colors.black;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? color : color.withOpacity(0.25),
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
