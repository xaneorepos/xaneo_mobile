import 'dart:async';
import 'dart:io';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/api/api_client.dart';
import '../../services/crypto/crypto_service.dart';
import '../../styles/app_styles.dart';
import 'auth_rejected_modal.dart';
import 'six_digit_code_input.dart';

class NotificationLoginPanel extends StatefulWidget {
  const NotificationLoginPanel({
    super.key,
    required this.identifier,
    required this.onCancelled,
    required this.onSuccess,
  });

  final String identifier;
  final VoidCallback onCancelled;
  final VoidCallback onSuccess;

  @override
  State<NotificationLoginPanel> createState() => _NotificationLoginPanelState();
}

class _NotificationLoginPanelState extends State<NotificationLoginPanel> {
  late final TextEditingController _identifier;
  final TextEditingController _code = TextEditingController();
  final TextEditingController _password = TextEditingController();
  crypto.SimpleKeyPair? _keyPair;
  String? _publicKey;
  String? _challenge;
  String? _pollSecret;
  Timer? _timer;
  int _step = 0; // request, bot code, approval, password
  bool _busy = false;
  String? _error;
  bool _emailFallbackAvailable = false;
  bool _passwordFallbackAvailable = false;
  bool _canUseEmail = false;
  bool _emailFallbackSent = false;
  String? _maskedEmail;
  int _emailFallbackRemaining = 60;
  int _passwordFallbackRemaining = 120;
  bool _obscurePassword = true;

  ApiClient get _api => context.read<ApiClient>();

  @override
  void initState() {
    super.initState();
    _identifier = TextEditingController(text: widget.identifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => _request());
  }

  Future<void> _request() async {
    if (_identifier.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final pair = await crypto.X25519().newKeyPair();
      final pub = await pair.extractPublicKey();
      final pubHex = Uint8List.fromList(pub.bytes)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      final rawDeviceName =
          '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
      final deviceName = rawDeviceName.length > 120
          ? rawDeviceName.substring(0, 120)
          : rawDeviceName;
      final response =
          await _api.post('/auth/notification-login/request/', data: {
        'identifier': _identifier.text.trim(),
        'client_type': 'mobile',
        'recipient_public_key': pubHex,
        'device_name': deviceName,
      });
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      final challenge = data['challenge_id']?.toString() ?? '';
      final pollSecret = data['poll_secret']?.toString() ?? '';
      if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(challenge) ||
          pollSecret.length < 32) {
        throw StateError('Некорректный ответ сервера');
      }
      _keyPair = pair;
      _publicKey = pubHex;
      _challenge = challenge;
      _pollSecret = pollSecret;
      setState(() {
        _busy = false;
        _step = 1;
      });
      _timer?.cancel();
      _timer =
          Timer.periodic(const Duration(milliseconds: 1500), (_) => _poll());
      await _poll();
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _busy = false;
          _error = l10n?.authNotificationErrorSendFailed ??
              'Failed to send code. Please try again later.';
        });
      }
    }
  }

  Future<void> _verify() async {
    if (_code.text.length != 6) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _api.post('/auth/notification-login/verify/', data: {
        'challenge_id': _challenge,
        'poll_secret': _pollSecret,
        'code': _code.text,
      });
      if (!mounted) return;
      setState(() {
        _busy = false;
        _step = 2;
      });
      _timer ??=
          Timer.periodic(const Duration(milliseconds: 1500), (_) => _poll());
      await _poll();
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _busy = false;
          _error = l10n?.authNotificationErrorInvalidCode ??
              'Invalid or expired code';
        });
      }
    }
  }

  Future<void> _poll() async {
    if (_challenge == null || _pollSecret == null || _step == 0 || _step == 3) {
      return;
    }
    try {
      final response = await _api.post('/auth/device-login/status/', data: {
        'challenge_id': _challenge,
        'poll_secret': _pollSecret,
      });
      final data = Map<String, dynamic>.from(response.data as Map);
      final status = data['status']?.toString();
      if (status == 'rejected' || status == 'declined' || status == 'denied') {
        _timer?.cancel();
        _timer = null;
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        setState(() {
          _busy = false;
          _step = 1;
          _code.clear();
          _error = l10n?.authNotificationErrorRequestExpired ??
              'Request rejected or expired';
        });
        await AuthRejectedModal.show(context);
        return;
      }
      if (status != 'approved') {
        if (!mounted) return;
        final remaining = data['password_fallback_remaining'];
        final elapsed = data['seconds_elapsed'];
        setState(() {
          _emailFallbackAvailable = data['allow_email_fallback'] == true;
          _passwordFallbackAvailable = data['allow_password_fallback'] == true;
          _canUseEmail = data['can_use_email'] == true;
          _emailFallbackSent = data['email_fallback_sent'] == true;
          _maskedEmail = data['email_masked']?.toString();
          if (elapsed is num) {
            _emailFallbackRemaining = (60 - elapsed).clamp(0, 60).toInt();
          }
          if (remaining is num) {
            _passwordFallbackRemaining = remaining.ceil().clamp(0, 120);
          }
        });
        return;
      }
      if (!mounted) return;
      _timer?.cancel();
      setState(() => _busy = true);
      await _completeLogin(data);
    } on DioException catch (e) {
      if (!mounted) return;
      final respData = e.response?.data;
      final status = respData is Map ? respData['status']?.toString() : null;
      final isRejected =
          status == 'rejected' || status == 'declined' || status == 'denied';
      if (isRejected) {
        _timer?.cancel();
        _timer = null;
        final l10n = AppLocalizations.of(context);
        setState(() {
          _busy = false;
          _step = 1;
          _code.clear();
          _error = l10n?.authNotificationErrorRequestExpired ??
              'Request rejected or expired';
        });
        await AuthRejectedModal.show(context);
        return;
      }
      if (_step == 2) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _busy = false;
          _error = l10n?.authNotificationErrorRequestExpired ??
              'Request rejected or expired';
        });
      }
    } catch (_) {
      if (mounted && _step == 2) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _busy = false;
          _error = l10n?.authNotificationErrorRequestExpired ??
              'Request rejected or expired';
        });
      }
    }
  }

  Future<void> _sendEmailFallback() async {
    if (!_emailFallbackAvailable || !_canUseEmail || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response =
          await _api.post('/auth/notification-login/fallback-email/', data: {
        'challenge_id': _challenge,
        'poll_secret': _pollSecret,
      });
      if (!mounted) return;
      final data = Map<String, dynamic>.from(response.data as Map);
      setState(() {
        _busy = false;
        _emailFallbackSent = true;
        _maskedEmail = data['email_masked']?.toString() ?? _maskedEmail;
        _code.clear();
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _busy = false;
          _error = l10n?.authNotificationErrorEmailFailed ??
              'Failed to send code to email. Please try again later.';
        });
      }
    }
  }

  void _openPasswordFallback() {
    _timer?.cancel();
    setState(() {
      _step = 3;
      _error = null;
      _password.clear();
    });
  }

  Future<void> _loginWithPassword() async {
    if (_password.text.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response =
          await _api.post('/auth/notification-login/password/', data: {
        'challenge_id': _challenge,
        'poll_secret': _pollSecret,
        'password': _password.text,
      });
      await _completeLogin(
        Map<String, dynamic>.from(response.data as Map),
        password: _password.text,
      );
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _busy = false;
          _error = l10n?.authNotificationErrorPasswordFailed ??
              'Failed to log in. Check your password or start over.';
        });
      }
    }
  }

  Future<void> _completeLogin(
    Map<String, dynamic> data, {
    String? password,
  }) async {
    if (!mounted) return;
    final cryptoService = context.read<CryptoService>();
    final auth = context.read<AuthProvider>();
    final access = data['access']?.toString();
    final refresh = data['refresh']?.toString();
    final deviceGrant = data['device_grant']?.toString();
    final user = data['user'];
    if (access == null ||
        refresh == null ||
        deviceGrant == null ||
        user is! Map) {
      throw StateError('Некорректный ответ сервера');
    }
    final userData = Map<String, dynamic>.from(user);
    final targetUserId = (userData['id'] as num?)?.toInt();
    if (targetUserId == null) throw StateError('Некорректный пользователь');
    final previousUserId = auth.user?.id;
    await cryptoService.activateAccountScope(targetUserId.toString());
    try {
      final transfer = data['transfer_payload'];
      if (transfer is Map && _keyPair != null && _publicKey != null) {
        final ok = await cryptoService.importDeviceTransferPayload(
          transferPayload: Map<String, dynamic>.from(transfer),
          ephemeralKeyPair: _keyPair!,
          token: _challenge!,
          recipientPublicKeyHex: _publicKey!,
        );
        if (!ok) throw StateError('Не удалось перенести ключи шифрования');
      } else if (data['xsec2'] is Map && password != null) {
        final ok = await cryptoService.tryRestoreKeysFromServerPayload(
          Map<String, dynamic>.from(data['xsec2'] as Map),
          password: password,
          username: _identifier.text.trim(),
        );
        if (!ok) {
          throw StateError('Не удалось восстановить ключи шифрования');
        }
      }
    } catch (_) {
      if (previousUserId != null) {
        await cryptoService.activateAccountScope(previousUserId.toString());
      } else {
        await cryptoService.deactivateAccountScope();
      }
      rethrow;
    }
    await auth.authService.tokenStorage.saveAccountSession(
      userData: userData,
      accessToken: access,
      refreshToken: refresh,
      deviceGrant: deviceGrant,
    );
    await auth.checkAuthStatus(cryptoService: cryptoService);
    if (mounted) widget.onSuccess();
  }

  Future<void> _close() async {
    _timer?.cancel();
    if (_challenge != null && _pollSecret != null) {
      try {
        await _api.post('/auth/device-login/cancel/',
            data: {'challenge_id': _challenge, 'poll_secret': _pollSecret});
      } catch (_) {}
    }
    if (mounted) widget.onCancelled();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _identifier.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _step == 0
        ? (l10n?.authNotificationSendingCode ?? 'Sending code')
        : _step == 1
            ? (l10n?.authNotificationEnterCode ?? 'Enter code')
            : _step == 2
                ? (l10n?.authNotificationConfirmLogin ?? 'Confirm login')
                : (l10n?.authNotificationPasswordLogin ?? 'Password login');
    final subtitle = _step == 0
        ? (l10n?.authNotificationSendingSubtitle ??
            'The code will be sent to the "Xaneo Notifications" chat. Do not close this screen.')
        : _step == 1
            ? (l10n?.authNotificationEnterCodeSubtitle ??
                'Enter the 6-digit code from the message.')
            : _step == 2
                ? (l10n?.authNotificationConfirmSubtitle ??
                    'Open Xaneo on an already authorized device and check request details.')
                : (l10n?.authNotificationPasswordSubtitle ??
                    'This method is only available after a waiting period. Password is not saved.');
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppStyles.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, style: AppStyles.bodyMuted.copyWith(height: 1.4)),
          const SizedBox(height: 22),
          if (_step == 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: CircularProgressIndicator(),
              ),
            ),
          if (_step == 1)
            Column(children: [
              SixDigitCodeInput(
                controller: _code,
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: 10),
              Text(
                _emailFallbackSent && _maskedEmail != null
                    ? (l10n?.authNotificationCodeSentToEmail(_maskedEmail!) ??
                        'Code sent to $_maskedEmail')
                    : (l10n?.authNotificationBotSource ??
                        'The code is sent from "Xaneo Notifications".'),
                style: AppStyles.bodyMuted.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 16),
              if (_emailFallbackAvailable) ...[
                Text(
                  l10n?.authNotificationNoBotAccess ?? 'No access to the bot?',
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: 4),
                if (_canUseEmail)
                  TextButton(
                    onPressed: _busy ? null : _sendEmailFallback,
                    child: Text(_emailFallbackSent
                        ? (l10n?.authNotificationResendCodeViaEmail ??
                            'Resend code to email')
                        : (l10n?.authNotificationGetCodeViaEmail ??
                            'Get code via email')),
                  )
                else
                  Text(
                    l10n?.authNotificationEmailUnavailable ??
                        'Email code unavailable: no verified email on this account.',
                    style: AppStyles.bodyMuted.copyWith(fontSize: 12),
                  ),
              ] else
                Text(
                  l10n?.authNotificationEmailAvailableIn(
                          _emailFallbackRemaining) ??
                      'Email code will be available in $_emailFallbackRemaining sec.',
                  style: AppStyles.bodyMuted.copyWith(fontSize: 12),
                ),
              if (_passwordFallbackAvailable)
                TextButton(
                  onPressed: _busy ? null : _openPasswordFallback,
                  child: Text(l10n?.authNotificationLoginWithPassword ??
                      'Log in with password'),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n?.authNotificationPasswordAvailableIn(
                            _passwordFallbackRemaining) ??
                        'Password login will be available in $_passwordFallbackRemaining sec.',
                    style: AppStyles.bodyMuted.copyWith(fontSize: 12),
                  ),
                ),
            ]),
          if (_step == 2)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(22),
                    child: CircularProgressIndicator())),
          if (_step == 3)
            TextField(
              controller: _password,
              autofocus: true,
              obscureText: _obscurePassword,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n?.parol_5ebe ?? 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              onSubmitted: (_) => _loginWithPassword(),
            ),
          if (_error != null)
            Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!,
                    style: const TextStyle(color: AppStyles.errorColor))),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(
                child: TextButton(
                    onPressed: _busy ? null : _close,
                    child: Text(l10n?.otmena_987b ?? 'Cancel'))),
            if (_step != 2) ...[
              const SizedBox(width: 12),
              Expanded(
                  child: FilledButton(
                      onPressed: _busy
                          ? null
                          : (_step == 0
                              ? _request
                              : _step == 1
                                  ? _verify
                                  : _loginWithPassword),
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_step == 0
                              ? (l10n?.authNotificationGetCodeBtn ?? 'Get code')
                              : _step == 1
                                  ? (l10n?.prodolzhit_e9c3 ?? 'Continue')
                                  : (l10n?.voyti_63a7 ?? 'Log in')))),
            ],
          ]),
        ],
      ),
    );
  }
}
