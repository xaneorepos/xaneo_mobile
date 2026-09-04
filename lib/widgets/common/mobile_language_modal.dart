import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/runtime_translations.dart';
import '../../styles/app_styles.dart';
import 'base_custom_modal.dart';
import 'custom_language_pack_dialogs.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Модальное окно выбора языка для мобильного приложения на базе BaseCustomModal
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
  double get initialExtent => 0.85;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final rt = RuntimeTranslations.instance;
    final currentCode = localeProvider.locale?.languageCode ?? 'ru';
    final hasActiveCustom = localeProvider.hasActiveCustomPack;
    final installedPacks = localeProvider.installedCustomPacks;
    final activePack = localeProvider.activeCustomPack;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
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
                    'Язык интерфейса'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.xaneoTextPrimary,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: context.xaneoTextMuted,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(color: Color(0x1AFFFFFF), height: 1),
        const SizedBox(height: 12),

        // ─── Кнопка импорта JSON ──────────────────────────────────────────
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.xaneoTextPrimary,
              foregroundColor: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.file_upload_outlined, size: 20),
            label: Text(
              (AppLocalizations.of(context)?.importLanguageFromJson ??
                  rt.resolveByText('Импортировать язык из JSON')),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            onPressed: () =>
                CustomLanguagePackDialogs.pickAndImportLanguagePack(context),
          ),
        ),

        // ─── Пользовательские языки (если установлены) ─────────────────────
        if (installedPacks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              rt.resolveByText('Пользовательские языки').toUpperCase(),
              style: TextStyle(
                color: context.xaneoTextMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ...installedPacks.map((pack) {
            final isSelected = hasActiveCustom && activePack?.id == pack.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                    : context.xaneoOverlay(0.03),
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
                  pack.name,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : context.xaneoTextPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  '${pack.nativeName} (${pack.locale}) • ${pack.stringCount} ${rt.resolveByText("строк")}',
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF6366F1).withValues(alpha: 0.7)
                        : context.xaneoTextMuted,
                    fontSize: 12,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: context.xaneoTextMuted, size: 18),
                      tooltip: rt.resolveByText('Удалить'),
                      onPressed: () async {
                        await localeProvider.deleteCustomPack(pack.id);
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  await localeProvider.activateCustomPack(pack.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            );
          }),
          const SizedBox(height: 12),
        ],

        // ─── Официальные языки ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            rt.resolveByText('Официальные языки').toUpperCase(),
            style: TextStyle(
              color: context.xaneoTextMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...LocaleProvider.availableLanguages.map((lang) {
          final code = lang['code']!;
          final name = lang['name']!;
          final isSelected = !hasActiveCustom && code == currentCode;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                  : context.xaneoOverlay(0.03),
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
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : context.xaneoTextPrimary,
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
