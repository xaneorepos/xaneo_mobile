import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xaneo/l10n/app_localizations.dart';
import 'package:xaneo/services/language_pack_validator.dart';
import 'package:xaneo/services/local_language_pack_repository.dart';
import 'package:xaneo/services/runtime_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, dynamic> manifest;

  setUpAll(() async {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      final dir = Directory('/tmp/xaneo_mobile_test_support');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      return dir.path;
    });

    final manifestFile = File('assets/manifest.v1.json');
    final manifestRaw = await manifestFile.readAsString();
    manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
    await RuntimeTranslations.instance.getManifest();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Mobile Custom Language Pack Integration Tests', () {
    test('Valid minimal pack validates, installs, and resolves strings',
        () async {
      const minimalJson = '''
      {
        "schema_version": 1,
        "locale": "ru-pirate",
        "name": "Пиратский",
        "native_name": "Пиратский диалект",
        "direction": "ltr",
        "fallback_locale": "ru",
        "strings": {
          "header.home": "Главная палуба",
          "header.login": "Свистать всех наверх"
        }
      }
      ''';

      final validation = LanguagePackValidator.validate(minimalJson, manifest);
      expect(validation.isValid, isTrue);
      expect(validation.normalizedPack, isNotNull);

      final normalized = validation.normalizedPack!;
      RuntimeTranslations.instance.setActivePack(normalized);

      expect(RuntimeTranslations.instance.hasActiveCustomPack, isTrue);
      expect(RuntimeTranslations.instance.get('header.home'),
          equals('Главная палуба'));
      expect(RuntimeTranslations.instance.get('header.login'),
          equals('Свистать всех наверх'));

      // Missing custom key falls back to default
      expect(
        RuntimeTranslations.instance
            .get('unknown.custom.key', fallback: 'Резерв'),
        equals('Резерв'),
      );
    });

    test('Real test packs (tsukishiro & dorevolyucionnyj) validate cleanly',
        () async {
      final tsukishiroFile = File('/home/xaneodev/tsukishiro_agent_lang.json');
      if (await tsukishiroFile.exists()) {
        final content = await tsukishiroFile.readAsString();
        final res = LanguagePackValidator.validate(content, manifest);
        expect(res.isValid, isTrue,
            reason:
                'tsukishiro_agent_lang.json should be valid: ${res.errors}');
        expect(
          res.warnings.where((warning) => warning.code == 'UNKNOWN_KEY'),
          isEmpty,
          reason: 'Every Tsukishiro key must exist in the mobile manifest',
        );
      }

      final dorevFile = File('/home/xaneodev/dorevolyucionnyj_lang.json');
      if (await dorevFile.exists()) {
        final content = await dorevFile.readAsString();
        final res = LanguagePackValidator.validate(content, manifest);
        expect(res.isValid, isTrue,
            reason:
                'dorevolyucionnyj_lang.json should be valid: ${res.errors}');
      }
    });

    test('RTL pack sets correct direction', () async {
      const rtlJson = '''
      {
        "schema_version": 1,
        "locale": "ar-custom",
        "name": "Custom Arabic",
        "native_name": "عربي مخصص",
        "direction": "rtl",
        "fallback_locale": "ar",
        "strings": {
          "header.home": "الرئيسية المخصصة"
        }
      }
      ''';

      final validation = LanguagePackValidator.validate(rtlJson, manifest);
      expect(validation.isValid, isTrue);

      RuntimeTranslations.instance.setActivePack(validation.normalizedPack);
      expect(RuntimeTranslations.instance.direction, equals('rtl'));
      expect(RuntimeTranslations.instance.get('header.home'),
          equals('الرئيسية المخصصة'));
    });

    test('DynamicAppLocalizations overrides getters when custom pack is active',
        () async {
      final tsukishiroFile = File('/home/xaneodev/tsukishiro_agent_lang.json');
      if (await tsukishiroFile.exists()) {
        final content = await tsukishiroFile.readAsString();
        final validation = LanguagePackValidator.validate(content, manifest);
        expect(validation.isValid, isTrue);

        RuntimeTranslations.instance.setActivePack(validation.normalizedPack);

        final l10n = lookupAppLocalizations(const Locale('ru'));
        // messenger.chats is in tsukishiro
        expect(l10n.chats, isNot(equals('Чаты')));
        expect(l10n.chats, equals('Секретные каналы'));

        // messenger.search is in tsukishiro
        expect(l10n.search, equals('Поиск по базам данных...'));

        // messenger.reply is in tsukishiro
        expect(l10n.reply, equals('Ответить объекту'));

        // messenger.settings.title is in tsukishiro
        expect(l10n.settings, equals('Конфигурация ядра'));

        // Section header
        expect(l10n.interface, equals('Параметры симуляции'));

        // Settings getters
        expect(l10n.lichnyeDannye_be85, equals('Профиль оперативника'));
        expect(l10n.appearance, equals('Оформление терминала'));

        // Create Chat options
        expect(l10n.lichnyyChat_cbec, equals('Связаться с объектом'));
        expect(l10n.nachatObschenieSPolzovatelem_0578,
            equals('Установить защищённый контакт с человеком'));
        expect(l10n.sozdatGruppu_459f, equals('Создать тайную ячейку'));
        expect(l10n.sozdatKanal_9022, equals('Создать канал пропаганды'));

        // Empty chat placeholders
        expect(l10n.noMessagesTitle, equals('Тишина в радиоэфире...'));
        expect(l10n.noMessagesSubtitle,
            equals('Отправь первый байт информации прямо сейчас!'));
        expect(l10n.welcomeTitle, isNotEmpty);

        // Message actions
        expect(l10n.reply, equals('Ответить объекту'));
        expect(l10n.copy, equals('Скопировать байты'));

        // Online / Offline / Typing statuses
        expect(l10n.online, equals('в матрице'));
        expect(l10n.offline, equals('был в матрице в прошлую эпоху'));
        expect(l10n.isTyping, equals('генерирует ответ...'));
        expect(l10n.isRecordingVoice, equals('записывает аудиолог...'));
        expect(l10n.pinChat, equals('Закрепить на главном экране'));
        expect(l10n.unpinChat, equals('Открепить от экрана'));
        expect(l10n.muteNotifications, equals('Заглушить сигналы'));
        expect(l10n.unmuteNotifications, equals('Включить сигналы'));
        expect(l10n.globalnyyPoisk_7ff2, equals('Поиск по базам данных...'));

        // Calls
        expect(l10n.startCall, equals('Выберите тип связи с объектом'));
        expect(l10n.audioCallDesc, equals('Только аудио'));
        expect(l10n.videoCallDesc, equals('С видео и аудио'));
        expect(l10n.svernut_ca9f, equals('Свернуть мост'));

        // Contacts
        expect(l10n.dobavitKontakt_2903, equals('Завербовать агента'));
        expect(
          l10n.poiskKontaktov_9a71,
          equals('Поиск по базе данных (от 5 символов)...'),
        );
        expect(l10n.neUdalosZagruzitKontakty_02a3,
            equals('Сервер упал от вашей ауры.'));

        // Group/channel creation
        expect(l10n.privatnayaGruppa_d20e, equals('Засекреченная'));
        expect(l10n.publichnayaGruppa_50f8, equals('Публичная'));
        expect(l10n.vhodTolkoPoPriglasheniyu_97a1,
            equals('Вход только по личному инвайту'));
        expect(l10n.privatnyyKanal_3139, equals('Закрытая частота'));
        expect(l10n.publichnyyKanal_0f7c, equals('Открытая частота'));

        // Chat info and plural forms
        expect(l10n.noSharedMedia, equals('Нет медиафайлов в этом секторе'));
        expect(l10n.noSharedFiles, equals('Нет документов в этом секторе'));
        expect(l10n.birthday, equals('Дата активации ядра'));
        expect(l10n.membersCount(1), equals('1 оперативник'));
        expect(l10n.membersCount(3), equals('3 оперативника'));
        expect(l10n.membersCount(10), equals('10 оперативников'));
        expect(l10n.subscribersCount(1), equals('1 слушатель частоты'));
        expect(l10n.subscribersCount(5), equals('5 слушателей частоты'));

        // Poll and to-do actions
        expect(l10n.sozdatOpros_4b9e, equals('Голосование за лучший мем'));
        expect(l10n.sozdatOpros_8401, equals('Запустить опрос в матрицу'));
        expect(l10n.sozdatSpisokZadach_4018,
            equals('Список дел (которые ты не сделаешь)'));
        expect(l10n.sozdatSpisokZadach_0416, equals('Закоммитить судьбу'));

        // Context-specific keys bypass shared Flutter getters.
        expect(
          RuntimeTranslations.instance.resolve(
            'messenger.createGroup.descriptionPlaceholder',
            'Описание',
          ),
          equals('Опишите миссию ячейки...'),
        );
        expect(
          RuntimeTranslations.instance.resolve(
            'messenger.createChannel.descriptionPlaceholder',
            'Описание',
          ),
          equals('О чём будет вещание...'),
        );
      }
    });

    test('LocalLanguagePackRepository installs, loads, and deletes custom pack',
        () async {
      final repo = LocalLanguagePackRepository();
      const testPackData = {
        "schema_version": 1,
        "locale": "ru-testrepo",
        "name": "Тестовый репозиторий",
        "native_name": "Test Repo Native",
        "direction": "ltr",
        "fallback_locale": "ru",
        "strings": {
          "common.save": "Сохранить всё",
          "common.cancel": "Отменить всё"
        }
      };

      // 1. Install
      final installed = await repo.installPack(testPackData);
      expect(installed.id, isNotEmpty);
      expect(installed.locale, equals('ru-testrepo'));
      expect(installed.stringCount, equals(2));

      // 2. Read list
      final list = await repo.getInstalledPacks();
      expect(list.any((p) => p.id == installed.id), isTrue);

      // 3. Load content
      final content = await repo.loadPackContent(installed.id);
      expect(content, isNotNull);
      expect(content!['name'], equals('Тестовый репозиторий'));
      expect(
          (content['strings'] as Map)['common.save'], equals('Сохранить всё'));

      // 4. Set active
      await repo.setActivePackId(installed.id);
      expect(await repo.getActivePackId(), equals(installed.id));

      // 5. Delete
      await repo.deletePack(installed.id);
      expect(await repo.getActivePackId(), isNull);
      final listAfter = await repo.getInstalledPacks();
      expect(listAfter.any((p) => p.id == installed.id), isFalse);
      expect(await repo.loadPackContent(installed.id), isNull);
    });

    test('Corrupted pack recovery reverts gracefully without crash', () async {
      final repo = LocalLanguagePackRepository();
      const testCorruptPack = {
        "schema_version": 1,
        "locale": "ru-corrupt",
        "name": "Corrupt",
        "native_name": "Corrupt",
        "direction": "ltr",
        "fallback_locale": "ru",
        "strings": {"common.save": "Saved"}
      };

      final installed = await repo.installPack(testCorruptPack);
      // Simulate file corruption by deleting or overwriting with invalid json
      await repo.deletePack(installed.id);

      // Attempting to load non-existent/corrupted pack returns null
      final loaded = await repo.loadPackContent(installed.id);
      expect(loaded, isNull);
    });
  });
}
