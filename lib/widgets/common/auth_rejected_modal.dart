import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../styles/app_styles.dart';
import 'base_custom_modal.dart';

/// Модальное окно отказа в авторизации
///
/// Отображается, когда запрос на вход был отклонён на другом устройстве
/// или сервером (reject).
class AuthRejectedModal extends BaseCustomModal {
  const AuthRejectedModal({super.key, this.customReason});

  final String? customReason;

  static Future<void> show(
    BuildContext context, {
    String? customReason,
  }) async {
    await BaseCustomModal.show<void>(
      context: context,
      isDismissible: true,
      child: AuthRejectedModal(customReason: customReason),
    );
  }

  @override
  State<AuthRejectedModal> createState() => _AuthRejectedModalState();
}

class _AuthRejectedModalState extends BaseCustomModalState<AuthRejectedModal> {
  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context);
    final muted = context.xaneoTextSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: _RejectedIcon(),
        ),
        const SizedBox(height: 18),
        Text(
          l10n?.authRejectedTitle ?? 'Login Rejected',
          style: TextStyle(
            color: context.xaneoTextPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.customReason ??
              l10n?.authRejectedDesc ??
              'The login request was rejected on your other device. If this wasn\'t you, we recommend checking your account security.',
          style: TextStyle(color: muted, fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            backgroundColor: context.xaneoTextPrimary,
            foregroundColor: context.xaneoSurface,
            overlayColor: context.xaneoTextMuted,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n?.authRejectedButton ?? 'Got it',
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _RejectedIcon extends StatelessWidget {
  const _RejectedIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.25),
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.gpp_bad_rounded,
          size: 24,
          color: Color(0xFFEF4444),
        ),
      ),
    );
  }
}
