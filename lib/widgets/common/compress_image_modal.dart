import 'package:flutter/material.dart';
import 'package:xaneo/l10n/app_localizations.dart';

import 'base_custom_modal.dart';

/// Спрашивает, нужно ли сжать фото перед отправкой (экономия трафика) —
/// тот же выбор, что и в imagePreviewModal веб-клиента (checkbox "Сжать
/// изображение для быстрой отправки").
///
/// Возвращает true (сжать), false (отправить как есть) или null (отмена).
class CompressImageModal extends BaseCustomModal {
  const CompressImageModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return BaseCustomModal.show<bool>(
      context: context,
      child: const CompressImageModal(),
    );
  }

  @override
  State<CompressImageModal> createState() => _CompressImageModalState();
}

class _CompressImageModalState
    extends BaseCustomModalState<CompressImageModal> {
  bool _compress = true;

  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Отправка фото',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _compress = !_compress),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Checkbox(
                  value: _compress,
                  onChanged: (v) => setState(() => _compress = v ?? true),
                ),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'Сжать изображение для быстрой отправки',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n?.cancel ?? 'Отмена'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_compress),
                child: const Text('Отправить'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}