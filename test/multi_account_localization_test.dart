import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/services/runtime_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('multi-account keys are available to custom language packs', () async {
    final runtime = RuntimeTranslations.instance;
    final manifest = await runtime.getManifest();
    final keys = manifest['keys'] as Map<String, dynamic>;
    expect(keys, contains('messenger.accounts.title'));
    expect(keys, contains('messenger.accounts.removeConfirm'));

    runtime.setActivePack({
      'locale': 'x-test',
      'fallback_locale': 'ru',
      'direction': 'ltr',
      'strings': {'messenger.accounts.title': 'Profiles'},
    });
    expect(
      runtime.resolve('messenger.accounts.title', 'Accounts'),
      'Profiles',
    );
    runtime.clearActivePack();
  });
}
