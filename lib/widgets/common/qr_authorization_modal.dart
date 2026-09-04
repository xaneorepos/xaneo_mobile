import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../styles/app_styles.dart';
import 'base_custom_modal.dart';

class QrAuthorizationConfirmationModal extends BaseCustomModal {
  const QrAuthorizationConfirmationModal({super.key, required this.deviceCode});

  final String deviceCode;

  static Future<bool> confirm({
    required BuildContext context,
    required String deviceCode,
  }) async {
    return await BaseCustomModal.show<bool>(
          context: context,
          isDismissible: false,
          child: QrAuthorizationConfirmationModal(deviceCode: deviceCode),
        ) ??
        false;
  }

  @override
  State<QrAuthorizationConfirmationModal> createState() =>
      _QrAuthorizationConfirmationModalState();
}

class _QrAuthorizationConfirmationModalState
    extends BaseCustomModalState<QrAuthorizationConfirmationModal> {
  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _QrModalIcon(icon: Icons.login_rounded),
        const SizedBox(height: 18),
        Text(
          l10n.qrScanTitle,
          style: TextStyle(
            color: context.xaneoTextPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.qrScanConfirmDesc,
          style: TextStyle(
            color: context.xaneoTextSecondary,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.xaneoOverlay(0.055),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.xaneoDivider),
          ),
          child: Row(
            children: [
              Icon(
                Icons.devices_rounded,
                size: 19,
                color: context.xaneoTextSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.deviceCode,
                  style: TextStyle(
                    color: context.xaneoTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 17,
              color: context.xaneoTextMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.qrScanSecurityNote,
                style: TextStyle(
                  color: context.xaneoTextMuted,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
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
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            l10n.qrScanConfirmButton,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            foregroundColor: context.xaneoTextMuted,
            overlayColor: context.xaneoOverlay(0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: BorderSide(color: context.xaneoDivider),
            textStyle: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

class QrAuthorizationSuccessModal extends BaseCustomModal {
  const QrAuthorizationSuccessModal({super.key});

  static Future<void> show({required BuildContext context}) {
    return BaseCustomModal.show<void>(
      context: context,
      isDismissible: false,
      child: const QrAuthorizationSuccessModal(),
    );
  }

  @override
  State<QrAuthorizationSuccessModal> createState() =>
      _QrAuthorizationSuccessModalState();
}

class _QrAuthorizationSuccessModalState
    extends BaseCustomModalState<QrAuthorizationSuccessModal> {
  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _QrModalIcon(icon: Icons.check_rounded),
        const SizedBox(height: 18),
        Text(
          l10n.qrScanSuccessTitle,
          style: TextStyle(
            color: context.xaneoTextPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.qrScanSuccessDesc,
          style: TextStyle(
            color: context.xaneoTextSecondary,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 22),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.xaneoTextPrimary,
            foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.qrScanDoneButton),
        ),
      ],
    );
  }
}

class _QrModalIcon extends StatelessWidget {
  const _QrModalIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.xaneoOverlay(0.07),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: context.xaneoDivider),
        ),
        child: Icon(icon, color: context.xaneoTextPrimary, size: 24),
      ),
    );
  }
}
