import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/l10n/xb_subscription_localizations.dart';
import 'package:xaneo/services/runtime_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('XbSubscriptionLocalizations (Mobile)', () {
    const supportedLocales = ['ru', 'en', 'fr', 'es', 'zh', 'ja', 'ko', 'ar'];

    testWidgets('All 8 supported languages provide non-empty values for key texts',
        (tester) async {
      for (final code in supportedLocales) {
        late XbSubscriptionLocalizations l10n;

        await tester.pumpWidget(
          Localizations(
            locale: Locale(code),
            delegates: const [DefaultWidgetsLocalizations.delegate],
            child: Builder(
              builder: (context) {
                l10n = XbSubscriptionLocalizations.of(context);
                return const Placeholder();
              },
            ),
          ),
        );

        expect(l10n.text('messenger.premium.menuTitle'), isNotEmpty,
            reason: 'menuTitle missing for $code');
        expect(l10n.text('messenger.premium.menuSubtitle'), isNotEmpty,
            reason: 'menuSubtitle missing for $code');
        expect(l10n.text('messenger.premium.title'), isNotEmpty,
            reason: 'title missing for $code');
        expect(l10n.text('messenger.premium.pill'), isNotEmpty,
            reason: 'pill missing for $code');
        expect(l10n.text('messenger.premium.buy'), isNotEmpty,
            reason: 'buy missing for $code');
        expect(l10n.text('messenger.premium.planMonth'), isNotEmpty,
            reason: 'planMonth missing for $code');
        expect(l10n.text('messenger.premium.planYear'), isNotEmpty,
            reason: 'planYear missing for $code');
      }
    });

    testWidgets(
        'Custom user language pack overrides canonical keys and parameter interpolation works',
        (tester) async {
      late XbSubscriptionLocalizations l10n;

      await tester.pumpWidget(
        Localizations(
          locale: const Locale('ru'),
          delegates: const [DefaultWidgetsLocalizations.delegate],
          child: Builder(
            builder: (context) {
              l10n = XbSubscriptionLocalizations.of(context);
              return const Placeholder();
            },
          ),
        ),
      );

      // Before pack
      expect(l10n.text('messenger.premium.menuTitle'), equals('Подписка XB'));

      // Activate custom user pack
      RuntimeTranslations.instance.setActivePack({
        'locale': 'ru-custom',
        'strings': {
          'messenger.premium.menuTitle': 'Пользовательский XB (Мобильный)',
          'messenger.premium.activeUntil': 'Действует до {date}!',
        },
      });

      expect(
        l10n.text('messenger.premium.menuTitle'),
        equals('Пользовательский XB (Мобильный)'),
      );
      expect(
        l10n.text('messenger.premium.activeUntil', params: {'date': '01.01.2027'}),
        equals('Действует до 01.01.2027!'),
      );

      // Clear custom pack
      RuntimeTranslations.instance.clearActivePack();
      expect(l10n.text('messenger.premium.menuTitle'), equals('Подписка XB'));
    });
  });
}
