import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import 'base_custom_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Модальное окно выбора языка для мобильного приложения на базе BaseCustomModal.
class MobileLanguageModal extends BaseCustomModal {
  const MobileLanguageModal({super.key});

  static Future<void> show(BuildContext context) {
    return BaseCustomModal.show(
      context: context,
      child: const MobileLanguageModal(),
    );
  }

  @override
  State<MobileLanguageModal> createState() => _MobileLanguageModalState();
}

class _MobileLanguageModalState
    extends BaseCustomModalState<MobileLanguageModal> {
  @override
  bool get isResizable => false;

  @override
  double get initialExtent => 0.78;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentCode = localeProvider.locale?.languageCode ?? 'ru';

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.language_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                (AppLocalizations.of(context)?.yazykInterfeysa_b78b ??
                    'Fallback'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: Color(0x1AFFFFFF), height: 1),
        const SizedBox(height: 12),
        ...LocaleProvider.availableLanguages.map((lang) {
          final code = lang['code']!;
          final name = lang['name']!;
          final isSelected = code == currentCode;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                    : Colors.transparent,
              ),
            ),
            child: ListTile(
              dense: true,
              title: Text(
                name,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF818CF8) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF6366F1),
                      size: 20,
                    )
                  : null,
              onTap: () {
                localeProvider.setLocale(Locale(code));
                Navigator.of(context).pop();
              },
            ),
          );
        }),
      ],
    );
  }
}
