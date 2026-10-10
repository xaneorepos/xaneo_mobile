import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../models/auth/api_error.dart';
import '../../models/auth/auth_response.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/themed_cupertino_date_picker.dart';
import '../../styles/app_styles.dart';
import '../../widgets/common/auth_settings_modal.dart';
import '../../widgets/common/auth_theme_toggle_button.dart';
import '../../widgets/common/avatar_cropper.dart';
import '../../widgets/common/six_digit_code_input.dart';
import 'package:xaneo/l10n/app_localizations.dart';
import '../../l10n/phone_auth_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  static final Uri _userAgreementUri =
      Uri.parse('https://xaneo.ru/support/#user-agreement');
  static final Uri _personalDataPolicyUri =
      Uri.parse('https://xaneo.ru/support/#personal-data-policy');

  // Steps:
  // 0: Name (Как вас зовут)
  // 1: Birthdate (Дата рождения)
  // 2: Nickname (Никнейм)
  // 3: Phone (Номер телефона)
  // 4: Phone Verification (Подтверждение номера: 8-800 звонок для +7 / Flash Call)
  // 5: Email (Email)
  // 6: Email Verification (Подтверждение email)
  // 7: Password (Пароль)
  // 8: Password Confirm (Подтверждение пароля)
  // 9: Avatar (Аватар)
  // 10: Preview (Превью)
  int _currentStep = 0;

  final _nameController = TextEditingController();
  DateTime? _selectedBirthdate;
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+7');
  final _phoneCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _phoneCodeFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();
  final _verificationCodeFocusNode = FocusNode();

  bool _isNameValid = false;
  bool _isBirthdateValid = false;
  bool _isUsernameValid = false;
  bool _isPhoneValid = false;
  bool _isPhoneVerified = false;
  bool _isSendingPhoneVerification = false;
  bool _isCheckingPhoneStatus = false;
  String? _phoneError;
  int _inboundPollingGeneration = 0;
  PhoneVerificationInitResponse? _phoneVerificationData;
  Timer? _inboundPollTimer;

  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isPasswordConfirmValid = false;
  bool _isVerificationCodeValid = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _agreedToTerms = false;
  bool _agreedToDataStorage = false;

  // Avatar
  File? _selectedAvatarImage;

  // Validation states
  bool _isCheckingUsername = false;
  String? _usernameError;
  bool _isUsernameAvailable = false;

  bool _isCheckingEmail = false;
  String? _emailError;
  bool _isEmailAvailable = false;

  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  String? _verificationError;

  // Debounce timers
  int _usernameDebounce = 0;
  int _emailDebounce = 0;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateFields);
    _usernameController.addListener(_onUsernameChanged);
    _phoneController.addListener(_onPhoneChanged);
    _phoneCodeController.addListener(_validateFields);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_validateFields);
    _passwordConfirmController.addListener(_validateFields);
    _verificationCodeController.addListener(_validateFields);
    _onPhoneChanged();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(AppStyles.animationFast, () {
          _nameFocusNode.requestFocus();
        });
      }
    });
  }

  @override
  void dispose() {
    _inboundPollingGeneration++;
    _inboundPollTimer?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _phoneCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _verificationCodeController.dispose();
    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _phoneCodeFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmFocusNode.dispose();
    _verificationCodeFocusNode.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      _isNameValid = _nameController.text.trim().isNotEmpty;
      _isBirthdateValid = _selectedBirthdate != null;
      _isPasswordValid =
          _passwordController.text.length >= AppConfig.minPasswordLength;
      _isPasswordConfirmValid =
          _passwordController.text == _passwordConfirmController.text &&
              _passwordConfirmController.text.isNotEmpty;
      _isVerificationCodeValid = _verificationCodeController.text.length ==
          AppConfig.verificationCodeLength;
    });
  }

  void _onUsernameChanged() {
    _validateFields();
    _usernameDebounce++;
    final currentDebounce = _usernameDebounce;

    // Reset availability status when text changes
    setState(() {
      _isUsernameValid =
          _usernameController.text.trim().length >= AppConfig.minUsernameLength;
      _usernameError = null;
      _isUsernameAvailable = false;
    });

    // Debounce validation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (currentDebounce == _usernameDebounce && mounted) {
        _validateUsername();
      }
    });
  }

  Future<void> _validateUsername() async {
    final username = _usernameController.text.trim();
    if (username.length < AppConfig.minUsernameLength) {
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final result = await auth.checkUsername(username);

      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          if (result.available) {
            _isUsernameAvailable = true;
            _usernameError = null;
          } else {
            _isUsernameAvailable = false;
            _usernameError = result.message ??
                (AppLocalizations.of(context)?.nikneymUzheZanyat_59aa ??
                    'Fallback');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          _usernameError =
              (AppLocalizations.of(context)?.oshibkaProverki_2ab0 ??
                  'Fallback');
        });
      }
    }
  }

  void _onEmailChanged() {
    _validateFields();
    _emailDebounce++;
    final currentDebounce = _emailDebounce;

    // Reset availability status when text changes
    setState(() {
      _isEmailValid = _emailController.text.trim().contains('@') &&
          _emailController.text.trim().contains('.');
      _emailError = null;
      _isEmailAvailable = false;
    });

    // Debounce validation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (currentDebounce == _emailDebounce && mounted) {
        _validateEmail();
      }
    });
  }

  void _onPhoneChanged() {
    var text = _phoneController.text.trim();
    if (text.startsWith('8') && text.length == 11) {
      text = '+7${text.substring(1)}';
      _phoneController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else if (text.isNotEmpty && !text.startsWith('+')) {
      text = '+$text';
      _phoneController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    final digits = text.replaceAll(RegExp(r'\D'), '');
    setState(() {
      _isPhoneValid = text.startsWith('+') && digits.length >= 10;
      _phoneError = null;
    });
  }

  Future<void> _sendPhoneVerification() async {
    final phone = _phoneController.text.trim();
    setState(() {
      _isSendingPhoneVerification = true;
      _phoneError = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final result = await auth.sendPhoneVerification(phone);

      if (mounted) {
        setState(() {
          _isSendingPhoneVerification = false;
        });

        if (result.success) {
          _phoneVerificationData = result;
          _isPhoneVerified = false;
          if (_currentStep == 3) _goToNextStepInternal();
          if (result.isInbound) {
            _startInboundPolling();
          } else {
            _focusPhoneCodeInput();
          }
        } else {
          setState(() {
            _phoneError = result.message ??
                PhoneAuthLocalizations.of(context)
                    .text('phoneVerificationInitError');
          });
        }
      }
    } catch (e, stack) {
      debugPrint('[RegisterScreen] sendPhoneVerification error: $e\n$stack');
      if (mounted) {
        setState(() {
          _isSendingPhoneVerification = false;
          if (e is ApiError) {
            _phoneError = e.message;
          } else {
            _phoneError = PhoneAuthLocalizations.of(context)
                .text('phoneVerificationInitError');
          }
        });
      }
    }
  }

  void _startInboundPolling() {
    _inboundPollTimer?.cancel();
    final generation = ++_inboundPollingGeneration;
    final verification = _phoneVerificationData;
    final deadline = DateTime.now().add(const Duration(minutes: 10));
    var failures = 0;

    Future<void> poll() async {
      if (!mounted || _currentStep != 4 || _isPhoneVerified ||
          !identical(verification, _phoneVerificationData) || generation != _inboundPollingGeneration) {
        return;
      }
      if (DateTime.now().isAfter(deadline)) {
        setState(() => _phoneError = 'Время ожидания истекло. Запросите звонок повторно.');
        return;
      }
      var delay = const Duration(seconds: 3);
      try {
        final statusRes = await context.read<AuthProvider>().checkInboundPhoneStatus(
          uid: verification?.uid,
          phone: _phoneController.text.trim(),
        );
        if (!mounted || _currentStep != 4 ||
            !identical(verification, _phoneVerificationData) || generation != _inboundPollingGeneration) {
          return;
        }
        failures = 0;
        if (statusRes.verified) {
          setState(() { _isPhoneVerified = true; _phoneError = null; });
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 900));
          if (mounted && _currentStep == 4 && identical(verification, _phoneVerificationData) && generation == _inboundPollingGeneration) {
            _goToNextStepInternal();
          }
          return;
        }
        if (statusRes.expired || !statusRes.success) {
          setState(() => _phoneError = statusRes.message ?? 'Запросите звонок повторно.');
          return;
        }
        setState(() => _phoneError = null);
      } catch (e) {
        if (!mounted || _currentStep != 4 ||
            !identical(verification, _phoneVerificationData) || generation != _inboundPollingGeneration) {
          return;
        }
        setState(() => _phoneError = e is ApiError ? e.message : 'Не удалось проверить звонок.');
        if (e is ApiError && e.statusCode != null &&
            e.statusCode! < 500 && e.statusCode != 429) {
          return;
        }
        failures++;
        if (failures >= 5) return;
        delay = e is RateLimitError
            ? (e.retryAfter ?? const Duration(seconds: 60))
            : Duration(seconds: failures * 5);
      }
      if (mounted && _currentStep == 4 && !_isPhoneVerified &&
          identical(verification, _phoneVerificationData) && generation == _inboundPollingGeneration) {
        _inboundPollTimer = Timer(delay, poll);
      }
    }
    _inboundPollTimer = Timer(const Duration(seconds: 3), poll);
  }

  Future<void> _callInboundNumber() async {
    final rawNumber = _phoneVerificationData?.rawNumber ??
        _phoneVerificationData?.confirmationNumber
            ?.replaceAll(RegExp(r'\D'), '') ??
        '';
    if (rawNumber.isEmpty) return;
    final uri = Uri.parse('tel:$rawNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[RegisterScreen] Failed to launch dialer: $e');
      if (mounted) {
        setState(() => _phoneError = 'Не удалось открыть звонок. Наберите указанный номер вручную.');
      }
    }
  }

  Future<void> _verifyFlashCallCode() async {
    final phone = _phoneController.text.trim();
    final code = _phoneCodeController.text.trim();
    if (code.length != 4 || _isCheckingPhoneStatus || _isPhoneVerified) return;

    setState(() {
      _isCheckingPhoneStatus = true;
      _phoneError = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final res = await auth.verifyPhoneCode(phone: phone, code: code);
      if (!mounted) return;
      if (res.success) {
        setState(() {
          _isCheckingPhoneStatus = false;
          _isPhoneVerified = true;
        });
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted && _currentStep == 4) {
          _goToNextStepInternal();
        }
      } else {
        setState(() {
          _isCheckingPhoneStatus = false;
          _phoneError = res.message ??
              PhoneAuthLocalizations.of(context).text('invalidCode');
        });
      }
    } catch (e, stack) {
      debugPrint('[RegisterScreen] verifyPhoneCode error: $e\n$stack');
      if (mounted) {
        setState(() {
          _isCheckingPhoneStatus = false;
          if (e is ApiError) {
            _phoneError = e.message;
          } else {
            _phoneError = PhoneAuthLocalizations.of(context)
                .text('codeVerificationError');
          }
        });
      }
    }
  }

  void _focusPhoneCodeInput() {
    FocusScope.of(context).requestFocus(_phoneCodeFocusNode);
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  Future<void> _validateEmail() async {
    final email = _emailController.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return;
    }

    setState(() {
      _isCheckingEmail = true;
      _emailError = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final result = await auth.checkEmail(email);

      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
          if (result.available) {
            _isEmailAvailable = true;
            _emailError = null;
          } else {
            _isEmailAvailable = false;
            _emailError = result.message ??
                (AppLocalizations.of(context)?.emailNedostupen_fc3e ??
                    'Fallback');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
          _emailError = (AppLocalizations.of(context)?.oshibkaProverki_2ab0 ??
              'Fallback');
        });
      }
    }
  }

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();

    setState(() {
      _isSendingCode = true;
      _verificationError = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      await auth.sendVerificationCode(email, username: username);

      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
        // Move to verification step
        _goToNextStepInternal();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
          _verificationError =
              (AppLocalizations.of(context)?.oshibkaOtpravkiKoda_a42a ??
                  'Fallback');
        });
      }
    }
  }

  Future<void> _verifyEmailCode() async {
    final email = _emailController.text.trim();
    final code = _verificationCodeController.text.trim();

    setState(() {
      _isVerifyingCode = true;
      _verificationError = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final result = await auth.verifyEmailCode(email: email, code: code);

      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
          if (result.success) {
            // Move to password step
            _goToNextStepInternal();
          } else {
            _verificationError = result.message ??
                (AppLocalizations.of(context)?.nevernyyKod_50f9 ?? 'Fallback');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
          _verificationError =
              (AppLocalizations.of(context)?.oshibkaProverkiKoda_9018 ??
                  'Fallback');
        });
      }
    }
  }

  void _focusVerificationCodeInput() {
    FocusScope.of(context).requestFocus(_verificationCodeFocusNode);
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  void _goToNextStepInternal() {
    setState(() {
      _currentStep++;
      if (_currentStep == 0) _nameFocusNode.requestFocus();
      if (_currentStep == 1) FocusScope.of(context).unfocus();
      if (_currentStep == 2) _usernameFocusNode.requestFocus();
      if (_currentStep == 3) _phoneFocusNode.requestFocus();
      if (_currentStep == 4) {
        if (_phoneVerificationData?.isFlashCall == true) {
          _focusPhoneCodeInput();
        } else {
          FocusScope.of(context).unfocus();
        }
      }
      if (_currentStep == 5) _emailFocusNode.requestFocus();
      if (_currentStep == 6) _focusVerificationCodeInput();
      if (_currentStep == 7) _passwordFocusNode.requestFocus();
      if (_currentStep == 8) _passwordConfirmFocusNode.requestFocus();
      if (_currentStep == 9) FocusScope.of(context).unfocus();
      if (_currentStep == 10) FocusScope.of(context).unfocus();
    });
  }

  void _goToNextStep() {
    if (_currentStep == 3 && _isPhoneValid) {
      _sendPhoneVerification();
    } else if (_currentStep == 4) {
      if (_phoneVerificationData?.isFlashCall == true &&
          _phoneCodeController.text.length == 4) {
        _verifyFlashCallCode();
      } else if (_isPhoneVerified) {
        _goToNextStepInternal();
      }
    } else if (_currentStep == 5 && _isEmailValid && _isEmailAvailable) {
      // Send verification code and move to verification step
      _sendVerificationCode();
    } else if (_currentStep == 6 && _isVerificationCodeValid) {
      _verifyEmailCode();
    } else if (_currentStep == 10 && _isStepValid()) {
      // Final step - register the user
      _handleRegister();
    } else if (_isStepValid()) {
      _goToNextStepInternal();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      if (_currentStep == 4) {
        _inboundPollingGeneration++;
        _inboundPollTimer?.cancel();
      }
      setState(() {
        _currentStep--;
        if (_currentStep == 0) _nameFocusNode.requestFocus();
        if (_currentStep == 1) FocusScope.of(context).unfocus();
        if (_currentStep == 2) _usernameFocusNode.requestFocus();
        if (_currentStep == 3) _phoneFocusNode.requestFocus();
        if (_currentStep == 4) FocusScope.of(context).unfocus();
        if (_currentStep == 5) _emailFocusNode.requestFocus();
        if (_currentStep == 6) _focusVerificationCodeInput();
        if (_currentStep == 7) _passwordFocusNode.requestFocus();
        if (_currentStep == 8) _passwordConfirmFocusNode.requestFocus();
        if (_currentStep == 9) FocusScope.of(context).unfocus();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleRegister() async {
    final auth = context.read<AuthProvider>();

    String? birthDateStr;
    if (_selectedBirthdate != null) {
      birthDateStr =
          "${_selectedBirthdate!.year}-${_selectedBirthdate!.month.toString().padLeft(2, '0')}-${_selectedBirthdate!.day.toString().padLeft(2, '0')}";
    }

    final success = await auth.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirm: _passwordConfirmController.text,
      birthDate: birthDateStr,
      realname: _nameController.text.trim(),
      avatarFile: _selectedAvatarImage,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!.message,
              style: AppStyles.bodyMedium
                  .copyWith(color: context.xaneoTextPrimary)),
          backgroundColor: AppStyles.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0:
        return _isNameValid;
      case 1:
        return _isBirthdateValid;
      case 2:
        return _isUsernameValid && _isUsernameAvailable && !_isCheckingUsername;
      case 3:
        return _isPhoneValid && !_isSendingPhoneVerification;
      case 4:
        return _isPhoneVerified ||
            (_phoneVerificationData?.isFlashCall == true &&
                _phoneCodeController.text.length == 4 &&
                !_isCheckingPhoneStatus);
      case 5:
        return _isEmailValid && _isEmailAvailable && !_isCheckingEmail;
      case 6:
        return _isVerificationCodeValid && !_isVerifyingCode;
      case 7:
        return _isPasswordValid;
      case 8:
        return _isPasswordConfirmValid;
      case 9:
        return true;
      case 10:
        return _agreedToTerms && _agreedToDataStorage;
      default:
        return false;
    }
  }

  Future<void> _pickAvatarImage() async {
    // Request permission first
    PermissionStatus permissionStatus;

    // On iOS, we use photos permission, on Android storage/photos
    if (Platform.isIOS) {
      permissionStatus = await Permission.photos.request();
    } else {
      // Android 13+ uses photos, older versions use storage
      permissionStatus = await Permission.photos.request();
      if (!permissionStatus.isGranted) {
        permissionStatus = await Permission.storage.request();
      }
    }

    if (!permissionStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((AppLocalizations.of(context)
                    ?.neobhodimoRazreshenieNaDostupK_5f5c ??
                'Fallback')),
            backgroundColor: AppStyles.errorColor,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label:
                  (AppLocalizations.of(context)?.nastroyki_c919 ?? 'Fallback'),
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      final imageFile = File(pickedFile.path);
      final result = await AvatarCropper.show(context, imageFile);
      if (result != null) {
        setState(() {
          _selectedAvatarImage = result;
        });
      }
    }
  }

  void _showEmailInfoModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.xaneoSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.xaneoDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                  (AppLocalizations.of(context)?.oVyboreEmail_2609 ??
                      'Fallback'),
                  style: AppStyles.titleLarge
                      .copyWith(color: context.xaneoTextPrimary)),
              const SizedBox(height: 24),

              // Simple text with clickable link
              RichText(
                text: TextSpan(
                  style: AppStyles.bodyMedium.copyWith(
                    fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                    color: context.xaneoTextSecondary,
                  ),
                  children: [
                    TextSpan(
                        text: (AppLocalizations.of(context)
                                ?.podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0 ??
                            'Fallback')),
                    TextSpan(
                      text: (AppLocalizations.of(context)?.zapreschennyh_1f49 ??
                          'Fallback'),
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final uri = Uri.parse(
                              'https://github.com/disposable-email-domains/disposable-email-domains');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordInfoModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.xaneoSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.xaneoDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                  (AppLocalizations.of(context)?.obIspolzovaniiParolya_9739 ??
                      'Fallback'),
                  style: AppStyles.titleLarge
                      .copyWith(color: context.xaneoTextPrimary)),
              const SizedBox(height: 24),
              Text(
                (AppLocalizations.of(context)
                        ?.parolTolkoDlyaAvariynogoVhoda_b142 ??
                    'Fallback'),
                style: AppStyles.bodyMedium
                    .copyWith(color: context.xaneoTextSecondary),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.chevronLeft,
              color: context.xaneoTextPrimary, size: 18),
          onPressed: isLoading ? null : _goBack,
        ),
        actions: [
          const AuthThemeToggleButton(),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.gear,
                color: context.xaneoTextSecondary, size: 18),
            onPressed: () => AuthSettingsModal.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 48,
                  width: 48,
                  color: context.xaneoTextPrimary,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (context, error, stackTrace) => Center(
                      child: FaIcon(FontAwesomeIcons.comments,
                          color: context.xaneoTextPrimary, size: 40)),
                ),
              ),
              const Spacer(flex: 1),
              AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : AppStyles.animationMedium,
                switchInCurve: AppStyles.curveEaseOut,
                switchOutCurve: AppStyles.curveEaseIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildCurrentStep(key: ValueKey('step$_currentStep')),
              ),
              const SizedBox(height: 32),
              _buildProgressIndicator(),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      isLoading || !_isStepValid() ? null : _goToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.xaneoTextPrimary,
                    disabledBackgroundColor: context.xaneoOverlay(0.24),
                    foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: isLoading ||
                          _isCheckingUsername ||
                          _isCheckingEmail ||
                          _isSendingCode ||
                          _isVerifyingCode ||
                          _isSendingPhoneVerification ||
                          _isCheckingPhoneStatus
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              strokeWidth: 2))
                      : Text(
                          _currentStep < 10
                              ? (AppLocalizations.of(context)?.dalee_c453 ??
                                  'Далее')
                              : (AppLocalizations.of(context)
                                      ?.sozdatAkkaunt_19ed ??
                                  'Создать аккаунт'),
                          style: AppStyles.buttonText.copyWith(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          )),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep({Key? key}) {
    switch (_currentStep) {
      case 0:
        return _buildInputStep(
            key,
            (AppLocalizations.of(context)?.kakVasZovut_68b7 ?? 'Fallback'),
            (AppLocalizations.of(context)?.imya_d38d ?? 'Fallback'),
            (AppLocalizations.of(context)?.naprimerIvan_d7cb ?? 'Fallback'),
            _nameController,
            _nameFocusNode);
      case 1:
        return _buildBirthdateStep(key);
      case 2:
        return _buildUsernameStep(key);
      case 3:
        return _buildPhoneStep(key);
      case 4:
        return _buildPhoneVerificationStep(key);
      case 5:
        return _buildEmailStep(key);
      case 6:
        return _buildVerificationStep(key);
      case 7:
        return _buildInputStep(
            key,
            (AppLocalizations.of(context)?.zadayteParol_53d2 ?? 'Fallback'),
            (AppLocalizations.of(context)?.parol_5ebe ?? 'Fallback'),
            (AppLocalizations.of(context)?.minimum8Simvolov_4ccd ?? 'Fallback'),
            _passwordController,
            _passwordFocusNode,
            obscureText: true);
      case 8:
        return _buildPasswordConfirmStep(key);
      case 9:
        return _buildAvatarStep(key);
      case 10:
        return _buildProfilePreviewStep(key);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhoneStep(Key? key) {
    final phoneLoc = PhoneAuthLocalizations.of(context);
    final hasText = _phoneController.text.trim().isNotEmpty;
    final isRussian = RegExp(r'^\+7[93458]').hasMatch(_phoneController.text.trim());

    Widget? suffix;
    if (_isSendingPhoneVerification) {
      suffix = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.xaneoTextMuted,
        ),
      );
    } else if (hasText && _isPhoneValid) {
      suffix = const FaIcon(
        FontAwesomeIcons.circleCheck,
        color: Color(0xFF22C55E),
        size: 16,
      );
    }

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          phoneLoc.text('phoneStepTitle'),
          style: AppStyles.titleGiant.copyWith(color: context.xaneoTextPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          isRussian
              ? phoneLoc.text('phoneStepRuSubtitle')
              : phoneLoc.text('phoneStepIntlSubtitle'),
          style: AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          style: AppStyles.inputText.copyWith(color: context.xaneoTextPrimary),
          cursorColor: context.xaneoTextPrimary,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]')),
          ],
          decoration: InputDecoration(
            filled: false,
            hintText: '+7 900 123-45-67',
            hintStyle:
                AppStyles.inputHint.copyWith(color: context.xaneoTextMuted),
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoTextPrimary)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 24, minHeight: 24),
            suffixIcon: suffix,
          ),
          onSubmitted: (_) => _isStepValid() ? _goToNextStep() : null,
        ),
        if (_phoneError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _phoneError!,
              style: AppStyles.bodyMuted.copyWith(
                color: const Color(0xFFEF4444),
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneVerificationStep(Key? key) {
    final phoneLoc = PhoneAuthLocalizations.of(context);
    final isInbound = _phoneVerificationData?.isInbound ?? true;
    final confNumber =
        _phoneVerificationData?.confirmationNumber ?? '8 (800) ...';
    final phone = _phoneController.text.trim();

    if (isInbound) {
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            phoneLoc.text('phoneConfirmation'),
            style:
                AppStyles.titleGiant.copyWith(color: context.xaneoTextPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            phoneLoc.text('inboundCallSubtitle', params: {'phone': phone}),
            style: AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            decoration: BoxDecoration(
              color: context.xaneoOverlay(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isPhoneVerified
                    ? const Color(0x8022C55E)
                    : context.xaneoDivider,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  confNumber,
                  style: AppStyles.titleGiant.copyWith(
                    color: context.xaneoTextPrimary,
                    fontSize: 26,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _callInboundNumber,
                    icon: const FaIcon(FontAwesomeIcons.phoneFlip, size: 15),
                    label: Text(
                      phoneLoc.text('callFree'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.xaneoTextPrimary,
                      foregroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isPhoneVerified) ...[
                const FaIcon(
                  FontAwesomeIcons.circleCheck,
                  color: Color(0xFF22C55E),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  phoneLoc.text('phoneVerifiedSuccess'),
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.xaneoTextMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  phoneLoc.text('waitingForCall'),
                  style: AppStyles.bodyMuted.copyWith(
                    color: context.xaneoTextMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          if (_phoneError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _phoneError!,
                style: AppStyles.bodyMuted.copyWith(
                  color: const Color(0xFFEF4444),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isSendingPhoneVerification ? null : _sendPhoneVerification,
            child: Text(phoneLoc.text('requestCallAgain')),
          ),
          Text(
            phoneLoc.text('inboundCallHint'),
            style: AppStyles.bodyMuted.copyWith(
              color: context.xaneoTextMuted,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _inboundPollTimer?.cancel();
              setState(() {
                _currentStep = 3;
                _phoneFocusNode.requestFocus();
              });
            },
            child: Text(
              phoneLoc.text('changePhone'),
              style: TextStyle(
                color: context.xaneoTextMuted,
              ),
            ),
          ),
        ],
      );
    } else {
      // Flash Call mode (4 digits)
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            phoneLoc.text('phoneConfirmation'),
            style:
                AppStyles.titleGiant.copyWith(color: context.xaneoTextPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            phoneLoc.text(_phoneVerificationData?.isVoiceCall == true ? 'voiceCallSubtitle' : 'flashCallSubtitle', params: {'phone': phone}),
            style: AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SixDigitCodeInput(
            controller: _phoneCodeController,
            focusNode: _phoneCodeFocusNode,
            length: 4,
            onChanged: (val) {
              setState(() {});
              if (val.length == 4) {
                _verifyFlashCallCode();
              }
            },
          ),
          if (_phoneError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _phoneError!,
                style: AppStyles.bodyMuted.copyWith(
                  color: const Color(0xFFEF4444),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed:
                _isSendingPhoneVerification ? null : _sendPhoneVerification,
            child: Text(
              phoneLoc.text('requestCallAgain'),
              style: TextStyle(
                color: _isSendingPhoneVerification
                    ? context.xaneoTextMuted
                    : context.xaneoTextPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentStep = 3;
                _phoneFocusNode.requestFocus();
              });
            },
            child: Text(
              phoneLoc.text('changePhone'),
              style: TextStyle(
                color: context.xaneoTextMuted,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildInputStep(Key? key, String title, String label, String hint,
      TextEditingController controller, FocusNode focusNode,
      {bool obscureText = false, TextInputType? keyboardType}) {
    final isPassword = controller == _passwordController;
    final isName = controller == _nameController;
    final hasText = controller.text.trim().isNotEmpty;
    final l10n = AppLocalizations.of(context);

    Widget? suffix;
    if (isPassword) {
      suffix = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: FaIcon(
              _obscurePassword
                  ? FontAwesomeIcons.eyeSlash
                  : FontAwesomeIcons.eye,
              color: context.xaneoTextSecondary,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          if (hasText) ...[
            const SizedBox(width: 8),
            FaIcon(
              _isPasswordValid
                  ? FontAwesomeIcons.circleCheck
                  : FontAwesomeIcons.circleXmark,
              color: _isPasswordValid
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
              size: 16,
            ),
          ],
        ],
      );
    } else if (isName && hasText) {
      suffix = const FaIcon(
        FontAwesomeIcons.circleCheck,
        color: Color(0xFF22C55E),
        size: 16,
      );
    }

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isPassword)
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      style: AppStyles.titleGiant.copyWith(
                        color: context.xaneoTextPrimary,
                      ))),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.circleInfo,
                    color: context.xaneoTextMuted, size: 18),
                onPressed: _showPasswordInfoModal,
              ),
            ],
          )
        else
          Text(title,
              style: AppStyles.titleGiant.copyWith(
                color: context.xaneoTextPrimary,
              )),
        const SizedBox(height: 8),
        Text(hint,
            style: AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted)),
        const SizedBox(height: 32),
        TextField(
          controller: controller,
          focusNode: focusNode,
          style: AppStyles.inputText.copyWith(color: context.xaneoTextPrimary),
          cursorColor: context.xaneoTextPrimary,
          obscureText: isPassword ? _obscurePassword : obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: false,
            hintText: label,
            hintStyle:
                AppStyles.inputHint.copyWith(color: context.xaneoTextMuted),
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoTextPrimary)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 24, minHeight: 24),
            suffixIcon: suffix,
          ),
          onSubmitted: (_) => _isStepValid() ? _goToNextStep() : null,
        ),
        if (isPassword && hasText && !_isPasswordValid)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n?.minimum8Simvolov_4ccd ?? 'At least 8 characters',
              style: AppStyles.bodyMuted.copyWith(
                color: const Color(0xFFEF4444),
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUsernameStep(Key? key) {
    final l10n = AppLocalizations.of(context);
    final hasText = _usernameController.text.trim().isNotEmpty;
    final isMinLength =
        _usernameController.text.trim().length >= AppConfig.minUsernameLength;

    Widget? suffix;
    if (_isCheckingUsername) {
      suffix = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.xaneoTextMuted,
        ),
      );
    } else if (hasText) {
      if (_isUsernameAvailable && isMinLength) {
        suffix = const FaIcon(
          FontAwesomeIcons.circleCheck,
          color: Color(0xFF22C55E),
          size: 16,
        );
      } else if (_usernameError != null || !isMinLength) {
        suffix = const FaIcon(
          FontAwesomeIcons.circleXmark,
          color: Color(0xFFEF4444),
          size: 16,
        );
      }
    }

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.pridumayteNikneym_221b ?? 'Choose a nickname',
          style: AppStyles.titleGiant.copyWith(color: context.xaneoTextPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.unikalnoeImyaDlyaVashegoProfilya_a0ea ??
              'A unique name for your profile',
          style: AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _usernameController,
          focusNode: _usernameFocusNode,
          style: AppStyles.inputText.copyWith(color: context.xaneoTextPrimary),
          cursorColor: context.xaneoTextPrimary,
          decoration: InputDecoration(
            filled: false,
            hintText: l10n?.nikneym_3fea ?? 'Nickname',
            hintStyle:
                AppStyles.inputHint.copyWith(color: context.xaneoTextMuted),
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoTextPrimary)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 24, minHeight: 24),
            suffixIcon: suffix,
          ),
          onSubmitted: (_) => _isStepValid() ? _goToNextStep() : null,
        ),
        if (hasText && _usernameError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _usernameError!,
              style: AppStyles.bodyMuted.copyWith(
                color: const Color(0xFFEF4444),
                fontSize: 13,
              ),
            ),
          )
        else if (_isUsernameAvailable && isMinLength)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n?.nikneymDostupen_3fc9 ?? 'Nickname available',
              style: AppStyles.bodyMuted.copyWith(
                color: const Color(0xFF22C55E),
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmailStep(Key? key) {
    final l10n = AppLocalizations.of(context);
    final hasText = _emailController.text.trim().isNotEmpty;
    final hasAt = _emailController.text.trim().contains('@') &&
        _emailController.text.trim().contains('.');

    Widget? suffix;
    if (_isCheckingEmail) {
      suffix = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.xaneoTextMuted,
        ),
      );
    } else if (hasText) {
      if (_isEmailAvailable && hasAt) {
        suffix = const FaIcon(
          FontAwesomeIcons.circleCheck,
          color: Color(0xFF22C55E),
          size: 16,
        );
      } else if (_emailError != null || !hasAt) {
        suffix = const FaIcon(
          FontAwesomeIcons.circleXmark,
          color: Color(0xFFEF4444),
          size: 16,
        );
      }
    }

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n?.vashEmail_879d ?? 'Your email',
                style: AppStyles.titleGiant
                    .copyWith(color: context.xaneoTextPrimary),
              ),
            ),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.circleInfo,
                  color: context.xaneoTextMuted, size: 18),
              onPressed: _showEmailInfoModal,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.dlyaSvyaziIVosstanovleniyaDostupa_c770 ??
              'For contact and account recovery',
          style: AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          style: AppStyles.inputText.copyWith(color: context.xaneoTextPrimary),
          cursorColor: context.xaneoTextPrimary,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: false,
            hintText: l10n?.emailAdres_9130 ?? 'Email address',
            hintStyle:
                AppStyles.inputHint.copyWith(color: context.xaneoTextMuted),
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoTextPrimary)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 24, minHeight: 24),
            suffixIcon: suffix,
          ),
          onSubmitted: (_) => _isStepValid() ? _goToNextStep() : null,
        ),
        if (hasText && _emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _emailError!,
              style: AppStyles.bodyMuted.copyWith(
                color: const Color(0xFFEF4444),
                fontSize: 13,
              ),
            ),
          )
        else if (_isEmailAvailable && hasAt)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n?.emailDostupen_e903 ?? 'Email available',
              style: AppStyles.bodyMuted.copyWith(
                color: const Color(0xFF22C55E),
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerificationStep(Key? key) {
    final l10n = AppLocalizations.of(context);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n?.podtverzhdenieEmail_281f ?? 'Email confirmation',
          style: AppStyles.titleGiant.copyWith(color: context.xaneoTextPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.codeSentToEmail(_emailController.text) ??
              'Code sent to ${_emailController.text}',
          style: AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SixDigitCodeInput(
          controller: _verificationCodeController,
          focusNode: _verificationCodeFocusNode,
          onChanged: (_) => setState(() {}),
        ),
        if (_verificationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _verificationError!,
              style: AppStyles.bodyMuted.copyWith(
                color: const Color(0xFFEF4444),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isSendingCode ? null : () => _sendVerificationCode(),
          child: Text(
            l10n?.otpravitKodPovtorno_7703 ?? 'Resend code',
            style: TextStyle(
              color: _isSendingCode
                  ? context.xaneoTextMuted
                  : context.xaneoTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordConfirmStep(Key? key) {
    final l10n = AppLocalizations.of(context);
    final hasText = _passwordConfirmController.text.isNotEmpty;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.podtverditeParol_e3e3 ?? 'Confirm password',
          style: AppStyles.titleGiant.copyWith(color: context.xaneoTextPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.vvediteParolEscheRaz_7383 ?? 'Enter the password again',
          style: AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _passwordConfirmController,
          focusNode: _passwordConfirmFocusNode,
          style: AppStyles.inputText.copyWith(color: context.xaneoTextPrimary),
          cursorColor: context.xaneoTextPrimary,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            filled: false,
            hintText: l10n?.parolEscheRaz_6daf ?? 'Password again',
            hintStyle:
                AppStyles.inputHint.copyWith(color: context.xaneoTextMuted),
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoTextPrimary)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 24, minHeight: 24),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: FaIcon(
                    _obscureConfirmPassword
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    color: context.xaneoTextSecondary,
                    size: 16,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                if (hasText) ...[
                  const SizedBox(width: 8),
                  FaIcon(
                    _isPasswordConfirmValid
                        ? FontAwesomeIcons.circleCheck
                        : FontAwesomeIcons.circleXmark,
                    color: _isPasswordConfirmValid
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
          onSubmitted: (_) => _isStepValid() ? _goToNextStep() : null,
        ),
        if (hasText && !_isPasswordConfirmValid)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n?.paroliNeSovpadayut_d82f ?? 'Passwords do not match',
              style: AppStyles.bodyMuted.copyWith(
                color: const Color(0xFFEF4444),
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  void _showCupertinoDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (sheetContext) => Container(
        height: 250,
        decoration: BoxDecoration(
          color: sheetContext.xaneoSurface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(sheetContext.xaneoRadius(24)),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(
                        (AppLocalizations.of(context)?.otmena_987b ?? 'Cancel'),
                        style: TextStyle(color: sheetContext.xaneoTextMuted)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: Text(
                        (AppLocalizations.of(context)?.gotovo_34e1 ?? 'Done'),
                        style: TextStyle(color: sheetContext.xaneoTextPrimary)),
                    onPressed: () {
                      setState(() {
                        _selectedBirthdate ??= DateTime(2000, 1, 1);
                        _validateFields();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ThemedCupertinoDatePicker(
                initialDateTime: _selectedBirthdate ?? DateTime(2000, 1, 1),
                minimumDate: DateTime(1900),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (val) {
                  setState(() {
                    _selectedBirthdate = val;
                    _validateFields();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdateStep(Key? key) {
    final l10n = AppLocalizations.of(context);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.dataRozhdeniya_505e ?? 'Date of birth',
          style: AppStyles.titleGiant.copyWith(color: context.xaneoTextPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed ??
              'Enter your real date of birth',
          style: AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _showCupertinoDatePicker();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.xaneoDivider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedBirthdate != null
                      ? "${_selectedBirthdate!.day.toString().padLeft(2, '0')}.${_selectedBirthdate!.month.toString().padLeft(2, '0')}.${_selectedBirthdate!.year}"
                      : (l10n?.ddmmgggg_3524 ?? 'DD.MM.YYYY'),
                  style: _selectedBirthdate != null
                      ? AppStyles.inputText
                          .copyWith(color: context.xaneoTextPrimary)
                      : AppStyles.inputHint
                          .copyWith(color: context.xaneoTextMuted),
                ),
                Icon(CupertinoIcons.calendar,
                    color: context.xaneoTextMuted, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStep(Key? key) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n?.dobavteFoto_25eb ?? 'Add a photo',
            style:
                AppStyles.titleGiant.copyWith(color: context.xaneoTextPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.sdelayteProfilUznavaemym_f2c5 ??
                'Make your profile recognizable',
            style: AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: _pickAvatarImage,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: _selectedAvatarImage != null
                    ? Colors.transparent
                    : context.xaneoOverlay(0.10),
                shape: BoxShape.circle,
                border: Border.all(color: context.xaneoDivider, width: 2),
                image: _selectedAvatarImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedAvatarImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedAvatarImage == null
                  ? Center(
                      child: FaIcon(
                        FontAwesomeIcons.camera,
                        color: context.xaneoTextSecondary,
                        size: 34,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePreviewStep(Key? key) {
    final l10n = AppLocalizations.of(context);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n?.profilGotov_b57d ?? 'Profile ready',
          style: AppStyles.titleGiant.copyWith(color: context.xaneoTextPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.ostalosVsegoParaShagov_37e3 ?? 'Just a couple of steps left',
          style: AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.xaneoOverlay(0.10),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _selectedAvatarImage != null
                      ? Colors.transparent
                      : context.xaneoDivider,
                  shape: BoxShape.circle,
                  image: _selectedAvatarImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedAvatarImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedAvatarImage == null
                    ? Center(
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          color: context.xaneoTextPrimary,
                          size: 34,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                _nameController.text,
                style: AppStyles.titleLarge.copyWith(
                  color: context.xaneoTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '@${_usernameController.text}',
                style:
                    AppStyles.bodyMuted.copyWith(color: context.xaneoTextMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCheckbox(
          title: (l10n?.yaPrinimayuPolzovatelskoeSoglashenie_c431 ??
              'I accept the User Agreement'),
          documentUri: _userAgreementUri,
          value: _agreedToTerms,
          onChanged: (val) {
            setState(() {
              _agreedToTerms = val ?? false;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildCheckbox(
          title: (l10n?.yaDayuSoglasieNaObrabotku_0d03 ??
              'I agree to the processing of personal data'),
          documentUri: _personalDataPolicyUri,
          value: _agreedToDataStorage,
          onChanged: (val) {
            setState(() {
              _agreedToDataStorage = val ?? false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCheckbox(
      {required String title,
      required bool value,
      required ValueChanged<bool?> onChanged,
      Uri? documentUri}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return context.xaneoTextPrimary;
              }
              return Colors.transparent;
            }),
            checkColor: Theme.of(context).scaffoldBackgroundColor,
            side: BorderSide(color: context.xaneoTextMuted, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: documentUri == null
                ? () => onChanged(!value)
                : () => launchUrl(
                      documentUri,
                      mode: LaunchMode.externalApplication,
                    ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                title,
                style: TextStyle(
                  color: context.xaneoTextSecondary,
                  fontSize: 13,
                  height: 1.4,
                  decoration:
                      documentUri == null ? null : TextDecoration.underline,
                  decorationColor: context.xaneoTextSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(11, (index) {
        return Expanded(
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : AppStyles.animationFast,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= index
                  ? context.xaneoTextPrimary
                  : context.xaneoDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
