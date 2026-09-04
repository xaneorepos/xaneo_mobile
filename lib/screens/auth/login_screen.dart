import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../screens/main/main_screen.dart';
import '../../styles/app_styles.dart';
import '../../widgets/common/auth_settings_modal.dart';
import '../../widgets/common/auth_theme_toggle_button.dart';
import '../../widgets/common/notification_login_dialog.dart';
import 'register_screen.dart';
import 'package:xaneo/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();

  bool _isUsernameValid = false;
  bool _authV2LoginStarted = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(AppStyles.animationFast, () {
        if (mounted) _usernameFocusNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    final username = _usernameController.text.trim();
    setState(() {
      _isUsernameValid = username.length >= AppConfig.minUsernameLength;
    });
  }

  void _goToNextStep() {
    if (_isUsernameValid) {
      setState(() => _authV2LoginStarted = true);
    }
  }

  void _goBack() {
    if (_authV2LoginStarted) {
      setState(() => _authV2LoginStarted = false);
      _usernameFocusNode.requestFocus();
    }
  }

  void _completeNotificationLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _authV2LoginStarted
            ? IconButton(
                icon: FaIcon(FontAwesomeIcons.chevronLeft,
                    color: context.xaneoTextPrimary, size: 18),
                onPressed: isLoading ? null : _goBack,
              )
            : null,
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
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                  width: 60,
                  color: context.xaneoTextPrimary,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (context, error, stackTrace) => Center(
                      child: FaIcon(FontAwesomeIcons.comments,
                          color: context.xaneoTextPrimary, size: 50)),
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
                        begin: const Offset(0.0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _authV2LoginStarted
                    ? NotificationLoginPanel(
                        key: const ValueKey('auth-v2-login'),
                        identifier: _usernameController.text.trim(),
                        onCancelled: _goBack,
                        onSuccess: _completeNotificationLogin,
                      )
                    : _buildUsernameStep(key: const ValueKey('step0')),
              ),
              const SizedBox(height: 32),
              const Spacer(flex: 2),
              if (!_authV2LoginStarted) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : _isUsernameValid
                            ? _goToNextStep
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.xaneoTextPrimary,
                      disabledBackgroundColor: context.xaneoOverlay(0.24),
                      foregroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                strokeWidth: 2))
                        : Text(
                            AppLocalizations.of(context)?.prodolzhit_e9c3 ??
                                'Continue',
                            style: AppStyles.buttonText.copyWith(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            )),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (!_authV2LoginStarted)
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, anim, secAnim) =>
                            const RegisterScreen(),
                        transitionsBuilder: (c, anim, secAnim, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: AppStyles.animationMedium,
                      ));
                    },
                    child: Text(
                      (AppLocalizations.of(context)?.sozdatXaneoId_4033 ??
                          'Fallback'),
                      style: AppStyles.bodyMedium.copyWith(
                        color: context.xaneoTextPrimary,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text((AppLocalizations.of(context)?.sVozvrascheniem_77ee ?? 'Fallback'),
            style: AppStyles.titleGiant.copyWith(
              color: context.xaneoTextPrimary,
            )),
        const SizedBox(height: 8),
        Text(
            (AppLocalizations.of(context)?.vvediteVashNikneym_51a6 ??
                'Fallback'),
            style: AppStyles.bodyMuted.copyWith(
              color: context.xaneoTextMuted,
            )),
        const SizedBox(height: 32),
        TextField(
          controller: _usernameController,
          focusNode: _usernameFocusNode,
          style: AppStyles.inputText.copyWith(color: context.xaneoTextPrimary),
          cursorColor: context.xaneoTextPrimary,
          decoration: InputDecoration(
            filled: false,
            hintText:
                (AppLocalizations.of(context)?.nikneym_3fea ?? 'Fallback'),
            hintStyle:
                AppStyles.inputHint.copyWith(color: context.xaneoTextMuted),
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoDivider)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.xaneoTextPrimary)),
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
          onSubmitted: (_) => _goToNextStep(),
        ),
      ],
    );
  }
}
