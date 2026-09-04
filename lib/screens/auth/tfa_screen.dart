import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../styles/app_styles.dart';
import 'login_screen.dart';
import '../main/main_screen.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Экран подтверждения 2FA
class TfaScreen extends StatefulWidget {
  /// Локальный непрозрачный ключ аккаунта (для быстрого входа)
  final String? accountKey;

  /// Имя пользователя (для отображения)
  final String? username;

  const TfaScreen({
    super.key,
    this.accountKey,
    this.username,
  });

  @override
  State<TfaScreen> createState() => _TfaScreenState();
}

class _TfaScreenState extends State<TfaScreen>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<String> _codeDigits = List.filled(6, '');

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _motionInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppStyles.animationMedium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: AppStyles.curveEaseOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animationController.value = 1;
    } else if (!_motionInitialized) {
      _animationController.forward();
    }
    _motionInitialized = true;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _codeController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      _codeDigits[index] = value;
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _verifyCode();
      }
    } else {
      _codeDigits[index] = '';
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    setState(() {});
  }

  void _verifyCode() {
    final code = _codeDigits.join();
    if (code.length == 6) {
      final auth = context.read<AuthProvider>();

      if (widget.accountKey != null) {
        auth.verifyQuickLoginTfa(code);
      } else {
        // Обычный вход после 2FA
        auth.verifyTfaCode(code);
      }
    }
  }

  void _resendCode() {
    // TODO: Вызвать API для повторной отправки кода
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            (AppLocalizations.of(context)?.kodOtpravlenPovtorno_e109 ??
                'Fallback')),
        backgroundColor: context.xaneoTextPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (auth.isAuthenticated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              });
            }

            return _buildContent(auth);
          },
        ),
      ),
    );
  }

  Widget _buildContent(AuthProvider auth) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: AppStyles.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 80),

            // Иконка
            _buildIcon(),
            const SizedBox(height: 32),

            // Заголовок
            Text(
              (AppLocalizations.of(context)
                      ?.dvuhfaktornayanautentifikatsiya_bacc ??
                  'Fallback'),
              style: AppStyles.titleLarge.copyWith(
                color: context.xaneoTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Описание
            Text(
              (AppLocalizations.of(context)?.naVashEmailOtpravlen6_b457 ??
                  'Fallback'),
              style: AppStyles.bodyMedium.copyWith(
                color: context.xaneoTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Поля для ввода кода
            _buildCodeFields(auth),
            const SizedBox(height: 16),

            // Ошибка
            if (auth.error != null) ...[
              Text(auth.error!.message,
                  style: AppStyles.errorText, textAlign: TextAlign.center),
              const SizedBox(height: 16),
            ],

            // Кнопка подтверждения
            _buildVerifyButton(auth),
            const Spacer(),

            // Отправить код повторно
            _buildResendLink(),
            const SizedBox(height: 16),

            // Отмена
            _buildCancelButton(auth),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: context.xaneoSurface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: context.xaneoDivider, width: 1),
        ),
        child: FaIcon(
          FontAwesomeIcons.shieldHalved,
          size: 34,
          color: context.xaneoTextPrimary,
        ),
      ),
    );
  }

  Widget _buildCodeFields(AuthProvider auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            enabled: !auth.isLoading,
            style: AppStyles.inputText.copyWith(
              color: context.xaneoTextPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: context.xaneoSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.xaneoDivider, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.xaneoDivider, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: context.xaneoTextPrimary, width: 1),
              ),
            ),
            onChanged: (value) => _onDigitEntered(index, value),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton(AuthProvider auth) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: auth.isLoading ? null : _verifyCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.xaneoTextPrimary,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: auth.isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              )
            : Text(
                (AppLocalizations.of(context)?.podtverdit_e260 ?? 'Fallback'),
                style: AppStyles.buttonText.copyWith(
                  color: Theme.of(context).scaffoldBackgroundColor,
                )),
      ),
    );
  }

  Widget _buildResendLink() {
    return Center(
      child: TextButton(
        onPressed: _resendCode,
        style: TextButton.styleFrom(foregroundColor: context.xaneoTextPrimary),
        child: Text((AppLocalizations.of(context)
                ?.nePoluchiliKodOtpravitPovtorno_c1d2 ??
            'Fallback')),
      ),
    );
  }

  Widget _buildCancelButton(AuthProvider auth) {
    return Center(
      child: TextButton(
        onPressed: () {
          auth.resetTfaState();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => auth.isAuthenticated
                  ? const MainScreen()
                  : const LoginScreen(),
            ),
          );
        },
        style: TextButton.styleFrom(foregroundColor: context.xaneoTextPrimary),
        child: Text((AppLocalizations.of(context)?.otmena_987b ?? 'Fallback')),
      ),
    );
  }
}
