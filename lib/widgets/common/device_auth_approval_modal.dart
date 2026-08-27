import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'base_custom_modal.dart';

class DeviceAuthApprovalModal extends BaseCustomModal {
  const DeviceAuthApprovalModal({
    super.key,
    required this.deviceName,
    required this.clientName,
    required this.ipAddress,
  });

  final String deviceName;
  final String clientName;
  final String ipAddress;

  static Future<bool> confirm({
    required BuildContext context,
    required String deviceName,
    required String clientName,
    required String ipAddress,
  }) async {
    return await BaseCustomModal.show<bool>(
          context: context,
          isDismissible: false,
          child: DeviceAuthApprovalModal(
            deviceName: deviceName,
            clientName: clientName,
            ipAddress: ipAddress,
          ),
        ) ??
        false;
  }

  @override
  State<DeviceAuthApprovalModal> createState() =>
      _DeviceAuthApprovalModalState();
}

class _DeviceAuthApprovalModalState
    extends BaseCustomModalState<DeviceAuthApprovalModal> {
  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context);
    final muted = Colors.white.withValues(alpha: 0.62);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: _SecurityIcon(),
        ),
        const SizedBox(height: 18),
        Text(
          l10n?.authNotificationConfirmLogin ?? 'Confirm login',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n?.deviceAuthApprovalSubtitle ??
              'Code verified. Allow login only if you initiated this request.',
          style: TextStyle(color: muted, fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 18),
        _AuthFacts(
          deviceName: widget.deviceName,
          clientName: widget.clientName,
          ipAddress: widget.ipAddress,
        ),
        const SizedBox(height: 13),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.key_outlined,
              size: 17,
              color: Colors.white.withValues(alpha: 0.46),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n?.deviceAuthApprovalKeysNotice ??
                    'Chat keys will be transferred to the new device in encrypted form.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.46),
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
            backgroundColor: const Color(0xFFFAFAFA),
            foregroundColor: const Color(0xFF18181B),
            overlayColor: const Color(0xFFE4E4E7),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n?.deviceAuthApprovalAllow ?? 'Allow Login'),
        ),
        const SizedBox(height: 4),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            foregroundColor: Colors.white.withValues(alpha: 0.58),
            overlayColor: Colors.white.withValues(alpha: 0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n?.deviceAuthApprovalDecline ?? 'Decline'),
        ),
      ],
    );
  }
}

class _SecurityIcon extends StatelessWidget {
  const _SecurityIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: const Icon(
        Icons.verified_user_outlined,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class _AuthFacts extends StatelessWidget {
  const _AuthFacts({
    required this.deviceName,
    required this.clientName,
    required this.ipAddress,
  });

  final String deviceName;
  final String clientName;
  final String ipAddress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _FactRow(
              label: l10n?.deviceAuthDevice ?? 'Device', value: deviceName),
          const Divider(height: 1, indent: 14, endIndent: 14),
          _FactRow(
              label: l10n?.deviceAuthApp ?? 'Application', value: clientName),
          const Divider(height: 1, indent: 14, endIndent: 14),
          _FactRow(
              label: l10n?.deviceAuthIp ?? 'IP address', value: ipAddress),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 102,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
