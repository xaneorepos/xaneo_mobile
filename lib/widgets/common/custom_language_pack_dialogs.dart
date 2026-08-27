import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/language_pack_validator.dart';
import '../../services/runtime_translations.dart';

/// Helper dialogs and functions for Custom Language Pack import and management in mobile
class CustomLanguagePackDialogs {
  /// Open document/file picker, validate, and show preview dialog
  static Future<void> pickAndImportLanguagePack(BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final rt = RuntimeTranslations.instance;

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) return;

      final file = File(path);
      if (!await file.exists()) {
        if (context.mounted) {
          _showErrorDialog(context, rt.resolveByText('Файл не найден'));
        }
        return;
      }

      final fileSize = await file.length();
      if (fileSize > LanguagePackValidator.maxPackSizeBytes) {
        if (context.mounted) {
          _showErrorDialog(context, rt.resolveByText('Размер файла превышает лимит 2 МБ'));
        }
        return;
      }

      final jsonContent = await file.readAsString();
      final validation = await localeProvider.validatePackJson(jsonContent);

      if (!validation.isValid) {
        if (context.mounted) {
          _showValidationErrorsDialog(context, validation.errors);
        }
        return;
      }

      final normalized = validation.normalizedPack;
      if (normalized == null) return;

      if (context.mounted) {
        _showPreviewDialog(context, normalized, validation.warnings);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, '${rt.resolveByText("Ошибка при чтении файла")}: $e');
      }
    }
  }

  static void _showErrorDialog(BuildContext context, String message) {
    final rt = RuntimeTranslations.instance;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161618),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(rt.resolveByText('Ошибка импорта'), style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }

  static void _showValidationErrorsDialog(BuildContext context, List<ValidationIssue> errors) {
    final rt = RuntimeTranslations.instance;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161618),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(rt.resolveByText('Языковой пакет не прошёл валидацию'), style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rt.resolveByText('Обнаружены следующие ошибки в структуре JSON:'),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: errors.length,
                  itemBuilder: (c, idx) {
                    final err = errors[idx];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• ${err.code}: ${err.message}${err.key != null ? ' (${err.key})' : ''}',
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(rt.resolveByText('Закрыть'), style: const TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }

  static void _showPreviewDialog(
    BuildContext context,
    Map<String, dynamic> pack,
    List<ValidationIssue> warnings,
  ) {
    final rt = RuntimeTranslations.instance;
    final strings = pack['strings'] as Map<String, dynamic>? ?? {};
    final name = pack['name'] ?? '';
    final nativeName = pack['native_name'] ?? '';
    final locale = pack['locale'] ?? '';
    final direction = pack['direction'] ?? 'ltr';
    final fallback = pack['fallback_locale'] ?? 'ru';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161618),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          rt.resolveByText('Импорт пользовательского языка'),
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(rt.resolveByText('Название'), '$name ($nativeName)'),
              const SizedBox(height: 6),
              _infoRow(rt.resolveByText('Код локали'), locale.toString()),
              const SizedBox(height: 6),
              _infoRow(rt.resolveByText('Направление письма'), direction.toString().toUpperCase()),
              const SizedBox(height: 6),
              _infoRow(rt.resolveByText('Базовый язык (fallback)'), fallback.toString()),
              const SizedBox(height: 6),
              _infoRow(rt.resolveByText('Переведено строк'), '${strings.length}'),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Text(
                  rt.resolveByText('⚠️ Файл создан третьей стороной. Перевод может быть неточным или вводить в заблуждение. Системные сообщения безопасности не заменяются.'),
                  style: const TextStyle(color: Colors.amberAccent, fontSize: 12, height: 1.3),
                ),
              ),
              if (warnings.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  '${rt.resolveByText("Предупреждения")} (${warnings.length}): ${warnings.first.message}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(rt.resolveByText('Отмена'), style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
              await localeProvider.installAndActivatePack(pack);
            },
            child: Text(rt.resolveByText('Установить и включить')),
          ),
        ],
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
