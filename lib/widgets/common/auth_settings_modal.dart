import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xaneo/l10n/app_localizations.dart';

import '../../config/app_config.dart';
import '../../providers/locale_provider.dart';
import '../../styles/app_styles.dart';
import 'base_custom_modal.dart';
import 'mobile_language_modal.dart';

/// Настройки, которые действительно доступны до авторизации.
class AuthSettingsModal extends BaseCustomModal {
  const AuthSettingsModal({super.key});

  static Future<void> show(BuildContext context) {
    return BaseCustomModal.show(
      context: context,
      child: const AuthSettingsModal(),
    );
  }

  @override
  State<AuthSettingsModal> createState() => _AuthSettingsModalState();
}

class _AuthSettingsModalState extends BaseCustomModalState<AuthSettingsModal> {
  @override
  bool get fitContent => true;

  @override
  double get maxExtent => 0.9;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      controller: scrollController,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n?.nastroyki_c919 ?? 'Settings',
                style: AppStyles.titleLarge,
              ),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.close_rounded,
                color: context.xaneoTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(color: Color(0x1AFFFFFF), height: 1),
        const SizedBox(height: 12),
        Consumer<LocaleProvider>(
          builder: (context, localeProvider, _) {
            return _SettingTile(
              icon: FontAwesomeIcons.language,
              title: l10n?.yazykInterfeysa_b78b ??
                  l10n?.yazyk_0577 ??
                  'Interface language',
              subtitle: localeProvider.currentLanguageName,
              onTap: () => MobileLanguageModal.show(context),
            );
          },
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Xaneo v${AppConfig.appVersion}',
            style: AppStyles.bodyMuted.copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final FaIconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.xaneoOverlay(0.035),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.xaneoDivider,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: context.xaneoTextSecondary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyles.bodyMedium.copyWith(
                        color: context.xaneoTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppStyles.bodyMuted.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.xaneoTextMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
