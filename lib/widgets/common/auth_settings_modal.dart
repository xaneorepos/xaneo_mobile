import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/locale_provider.dart';
import '../../styles/app_styles.dart';
import 'mobile_language_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';

class AuthSettingsModal extends StatefulWidget {
  const AuthSettingsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AuthSettingsModal(),
    );
  }

  @override
  State<AuthSettingsModal> createState() => _AuthSettingsModalState();
}

class _AuthSettingsModalState extends State<AuthSettingsModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF161616),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text((AppLocalizations.of(context)?.nastroyki_c919 ?? 'Fallback'), style: AppStyles.titleLarge),
            const SizedBox(height: 24),
            
            _buildSettingItem(
              icon: FontAwesomeIcons.moon,
              title: (AppLocalizations.of(context)?.temnayaTema_6018 ?? 'Fallback'),
              subtitle: (AppLocalizations.of(context)?.vklyuchenaPoUmolchaniyu_7610 ?? 'Fallback'),
              trailing: const FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 14),
            ),
            const Divider(color: Colors.white10),
            
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, _) {
                return GestureDetector(
                  onTap: () => MobileLanguageModal.show(context),
                  child: _buildSettingItem(
                    icon: FontAwesomeIcons.language,
                    title: (AppLocalizations.of(context)?.yazyk_0577 ?? 'Fallback'),
                    subtitle: localeProvider.currentLanguageName,
                  ),
                );
              },
            ),
            Divider(color: Colors.white10),
            
            _buildSettingItem(
              icon: FontAwesomeIcons.shield,
              title: (AppLocalizations.of(context)?.setevoyFiltr_40c2 ?? 'Fallback'),
              subtitle: (AppLocalizations.of(context)?.vklyuchen_0994 ?? 'Fallback'),
            ),
            
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Xaneo v${AppConfig.appVersion}',
                style: AppStyles.bodyMuted.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required FaIconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: FaIcon(icon, color: Colors.white70, size: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.bodyMedium.copyWith(color: Colors.white)),
                Text(subtitle, style: AppStyles.bodyMuted.copyWith(fontSize: 13)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
