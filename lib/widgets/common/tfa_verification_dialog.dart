import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xaneo/l10n/app_localizations.dart';

import '../../providers/auth_provider.dart';
import '../../styles/app_styles.dart';
import 'base_custom_modal.dart';

class TfaVerificationDialog extends BaseCustomModal {
  const TfaVerificationDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return BaseCustomModal.show<bool>(
      context: context,
      child: const TfaVerificationDialog(),
      isDismissible: false,
    );
  }

  @override
  State<TfaVerificationDialog> createState() => _TfaVerificationDialogState();
}

class _TfaVerificationDialogState
    extends BaseCustomModalState<TfaVerificationDialog> {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  bool get fitContent => true;

  @override
  bool get isResizable => false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_codeController.text.length != 6) return;
    final success =
        await context.read<AuthProvider>().verifyTfaCode(_codeController.text);
    if (success && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.resendTfaCode();
    if (!mounted || !success) return;
    _codeController.clear();
    _focusNode.requestFocus();
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.codeSent)),
    );
  }

  void _cancel() {
    context.read<AuthProvider>().cancelTfa();
    Navigator.of(context).pop(false);
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final canSubmit = _codeController.text.length == 6 && !auth.isLoading;
        final email = auth.user?.email;

        return PopScope(
          canPop: false,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppStyles.backgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppStyles.borderColor),
                      ),
                      alignment: Alignment.center,
                      child: const FaIcon(
                        FontAwesomeIcons.shieldHalved,
                        size: 20,
                        color: AppStyles.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.twoFactorAuth,
                            style: AppStyles.titleLarge.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l10n.twoFactorAuthDesc,
                            style: AppStyles.bodyMuted.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  email?.isNotEmpty == true
                      ? l10n.codeSentToEmail(email!)
                      : l10n.codeSent,
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: 18),
                Text(l10n.enterVerificationCode, style: AppStyles.bodyMuted),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  focusNode: _focusNode,
                  enabled: !auth.isLoading,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  textAlign: TextAlign.center,
                  style: AppStyles.inputText.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    filled: true,
                    fillColor: AppStyles.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppStyles.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppStyles.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppStyles.borderActiveColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _verify(),
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    auth.error!.message.isNotEmpty
                        ? auth.error!.message
                        : l10n.invalidVerificationCode,
                    style: AppStyles.errorText,
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: canSubmit ? _verify : null,
                    style: AppStyles.primaryButton,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.continueButton,
                            style: AppStyles.buttonText),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: auth.isLoading ? null : _cancel,
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: auth.isLoading ? null : _resend,
                      child: Text(l10n.resendCode),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
