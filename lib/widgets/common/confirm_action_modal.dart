import 'package:flutter/material.dart';
import 'package:xaneo/l10n/app_localizations.dart';
import '../../styles/app_styles.dart';

import 'base_custom_modal.dart';

/// Простое модальное окно "да/нет" (например, подтверждение перехода по
/// внешней ссылке из inline-кнопки бота). Возвращает true/false, либо
/// false при закрытии свайпом/тапом по фону.
class ConfirmActionModal extends BaseCustomModal {
  const ConfirmActionModal({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;

  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await BaseCustomModal.show<bool>(
      context: context,
      child: ConfirmActionModal(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
      ),
    );
    return result ?? false;
  }

  @override
  State<ConfirmActionModal> createState() => _ConfirmActionModalState();
}

class _ConfirmActionModalState
    extends BaseCustomModalState<ConfirmActionModal> {
  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: context.xaneoTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.message,
          style: TextStyle(color: context.xaneoTextSecondary, fontSize: 14),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n?.cancel ?? 'Отмена'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(widget.confirmLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
