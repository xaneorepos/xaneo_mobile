// GENERATED BOILERPLATE ADAPTER FROM CANONICAL MANIFEST
// 100% COMPLETE MANIFEST COVERAGE FOR XANEO MOBILE
// ignore_for_file: non_constant_identifier_names, type=lint, unused_local_variable

import 'app_localizations.dart';
import '../services/runtime_translations.dart';

class DynamicAppLocalizations extends AppLocalizations {
  final AppLocalizations base;
  final RuntimeTranslations _rt = RuntimeTranslations.instance;

  DynamicAppLocalizations(this.base, String locale) : super(locale);

  String _resolve(List<String> keys, String fallback) {
    if (!_rt.hasActiveCustomPack) return fallback;
    for (final key in keys) {
      if (_rt.containsKey(key)) return _rt.get(key);
    }
    return _rt.resolveByText(fallback);
  }

  @override
  String get appTitle => _resolve(const ['appTitle'], base.appTitle);

  @override
  String get welcomeTitle =>
      _resolve(const ['welcomeTitle'], base.welcomeTitle);

  @override
  String get welcomeDescription =>
      _resolve(const ['welcomeDescription'], base.welcomeDescription);

  @override
  String get getStartedButton => _resolve(
      const ['getStartedButton', 'hero.getStarted'], base.getStartedButton);

  @override
  String get privacyTitle => _resolve(const [
        'messenger.settings.privacyTitle',
        'messenger.settings.privacy',
        'privacyTitle'
      ], base.privacyTitle);

  @override
  String get privacyDescription =>
      _resolve(const ['privacyDescription'], base.privacyDescription);

  @override
  String get continueButton => _resolve(const [
        'continueButton',
        'profile.consent.continue',
        'messenger.buttons.continue'
      ], base.continueButton);

  @override
  String get dataStorageTitle =>
      _resolve(const ['dataStorageTitle'], base.dataStorageTitle);

  @override
  String get dataStorageDescription =>
      _resolve(const ['dataStorageDescription'], base.dataStorageDescription);

  @override
  String get finishButton => _resolve(const [
        'finishButton',
        'profile.sessions.end',
        'messenger.call.end',
        'finish'
      ], base.finishButton);

  @override
  String get setupCompleted =>
      _resolve(const ['setupCompleted'], base.setupCompleted);

  @override
  String get loginFormTitle =>
      _resolve(const ['loginFormTitle'], base.loginFormTitle);

  @override
  String get loginFieldHint =>
      _resolve(const ['loginFieldHint'], base.loginFieldHint);

  @override
  String get passwordFieldHint => _resolve(const [
        'passwordFieldHint',
        'login.password',
        'profile.security.password',
        'qrLogin.passwordLabel',
        'password'
      ], base.passwordFieldHint);

  @override
  String get loginButton => _resolve(const [
        'loginButton',
        'header.login',
        'login.loginBtn',
        'qrLogin.submitCodeBtn'
      ], base.loginButton);

  @override
  String get noAccount => _resolve(const ['noAccount'], base.noAccount);

  @override
  String get registerButton =>
      _resolve(const ['registerButton'], base.registerButton);

  @override
  String get fillAllFields =>
      _resolve(const ['fillAllFields'], base.fillAllFields);

  @override
  String get loggingIn => _resolve(const ['loggingIn'], base.loggingIn);

  @override
  String get invalidCredentials =>
      _resolve(const ['invalidCredentials'], base.invalidCredentials);

  @override
  String get serverError => _resolve(const ['serverError'], base.serverError);

  @override
  String get connectionError =>
      _resolve(const ['connectionError'], base.connectionError);

  @override
  String get settings => _resolve(const [
        'messenger.settings.title',
        'header.settings',
        'settings.title',
        'settings',
        'profile.nav.settings',
        'profile.settings.title'
      ], base.settings);

  @override
  String get notifications => _resolve(const [
        'messenger.settings.notificationsTitle',
        'messenger.settings.chatsTitle',
        'settings.notifications',
        'notifications',
        'profile.settings.notifications'
      ], base.notifications);

  @override
  String get notificationsDescription => _resolve(const [
        'messenger.settings.notificationsDesc',
        'messenger.settings.chatsDesc',
        'settings.notificationsDescription',
        'notificationsDescription'
      ], base.notificationsDescription);

  @override
  String get darkTheme => _resolve(const ['darkTheme'], base.darkTheme);

  @override
  String get darkThemeDescription =>
      _resolve(const ['darkThemeDescription'], base.darkThemeDescription);

  @override
  String get language => _resolve(const [
        'messenger.generalSettings.language',
        'messenger.settings.languageTitle',
        'settings.language',
        'common.language',
        'language',
        'profile.settings.language'
      ], base.language);

  @override
  String get languageDescription => _resolve(const [
        'messenger.settings.languageDesc',
        'settings.languageDescription',
        'messenger.settings.generalDesc',
        'languageDescription'
      ], base.languageDescription);

  @override
  String get selectLanguage => _resolve(
      const ['selectLanguage', 'settings.selectLanguage'], base.selectLanguage);

  @override
  String get appVersion => _resolve(const ['appVersion'], base.appVersion);

  @override
  String get registerTitle =>
      _resolve(const ['registerTitle', 'login.register'], base.registerTitle);

  @override
  String get registerStep0Title => _resolve(
      const ['registerStep0Title', 'register.realname'],
      base.registerStep0Title);

  @override
  String get registerStep0Subtitle =>
      _resolve(const ['registerStep0Subtitle'], base.registerStep0Subtitle);

  @override
  String get registerStep1Title =>
      _resolve(const ['registerStep1Title'], base.registerStep1Title);

  @override
  String get registerStep1Subtitle =>
      _resolve(const ['registerStep1Subtitle'], base.registerStep1Subtitle);

  @override
  String get registerStep2Title => _resolve(
      const ['registerStep2Title', 'register.nickname'],
      base.registerStep2Title);

  @override
  String get registerStep2Subtitle =>
      _resolve(const ['registerStep2Subtitle'], base.registerStep2Subtitle);

  @override
  String get registerStep3Title =>
      _resolve(const ['registerStep3Title'], base.registerStep3Title);

  @override
  String get registerStep3Subtitle =>
      _resolve(const ['registerStep3Subtitle'], base.registerStep3Subtitle);

  @override
  String get registerStep4Title =>
      _resolve(const ['registerStep4Title'], base.registerStep4Title);

  @override
  String get registerStep4Subtitle =>
      _resolve(const ['registerStep4Subtitle'], base.registerStep4Subtitle);

  @override
  String get registerStep5Title =>
      _resolve(const ['registerStep5Title'], base.registerStep5Title);

  @override
  String get registerStep5Subtitle =>
      _resolve(const ['registerStep5Subtitle'], base.registerStep5Subtitle);

  @override
  String get registerStep6Title =>
      _resolve(const ['registerStep6Title'], base.registerStep6Title);

  @override
  String get registerStep6Subtitle =>
      _resolve(const ['registerStep6Subtitle'], base.registerStep6Subtitle);

  @override
  String get yourName => _resolve(const [
        'messenger.personal.name',
        'profile.profile.displayName',
        'yourName'
      ], base.yourName);

  @override
  String get birthDate => _resolve(const [
        'birthDate',
        'register.birthdate',
        'profile.profile.birthdate',
        'messenger.personal.birthday'
      ], base.birthDate);

  @override
  String get nickname => _resolve(const [
        'messenger.personal.nickname',
        'profile.profile.username',
        'nickname'
      ], base.nickname);

  @override
  String get checkingNickname =>
      _resolve(const ['checkingNickname'], base.checkingNickname);

  @override
  String get nicknameAvailable =>
      _resolve(const ['nicknameAvailable'], base.nicknameAvailable);

  @override
  String get nicknameTaken =>
      _resolve(const ['nicknameTaken'], base.nicknameTaken);

  @override
  String get email => _resolve(const ['email'], base.email);

  @override
  String get password => _resolve(const [
        'password',
        'login.password',
        'profile.security.password',
        'qrLogin.passwordLabel',
        'passwordFieldHint'
      ], base.password);

  @override
  String get confirmPassword =>
      _resolve(const ['confirmPassword'], base.confirmPassword);

  @override
  String get addPhoto => _resolve(const ['addPhoto'], base.addPhoto);

  @override
  String get removePhoto => _resolve(const ['removePhoto'], base.removePhoto);

  @override
  String get acceptTerms => _resolve(const ['acceptTerms'], base.acceptTerms);

  @override
  String get acceptDataProcessing =>
      _resolve(const ['acceptDataProcessing'], base.acceptDataProcessing);

  @override
  String get back => _resolve(const [
        'common.back',
        'messenger.back',
        'back',
        'support.back',
        'register.back',
        'messenger.datetime.ago'
      ], base.back);

  @override
  String get next => _resolve(
      const ['common.next', 'messenger.next', 'next', 'register.next'],
      base.next);

  @override
  String get finish => _resolve(const [
        'finish',
        'profile.sessions.end',
        'messenger.call.end',
        'finishButton'
      ], base.finish);

  @override
  String get backToLogin => _resolve(const ['backToLogin'], base.backToLogin);

  @override
  String get registrationSuccess =>
      _resolve(const ['registrationSuccess'], base.registrationSuccess);

  @override
  String get registrationError =>
      _resolve(const ['registrationError'], base.registrationError);

  @override
  String get enterVerificationCode =>
      _resolve(const ['enterVerificationCode'], base.enterVerificationCode);

  @override
  String get invalidVerificationCode => _resolve(
      const ['invalidVerificationCode', 'login.invalidConfirmationCode'],
      base.invalidVerificationCode);

  @override
  String get codeSent => _resolve(const ['codeSent'], base.codeSent);

  @override
  String get sendCodeError =>
      _resolve(const ['sendCodeError'], base.sendCodeError);

  @override
  String get confirmEmail =>
      _resolve(const ['confirmEmail'], base.confirmEmail);

  @override
  String get verify =>
      _resolve(const ['verify', 'profile.security.check'], base.verify);

  @override
  String get resendCode => _resolve(const ['resendCode'], base.resendCode);

  @override
  String get acceptTermsRequired =>
      _resolve(const ['acceptTermsRequired'], base.acceptTermsRequired);

  @override
  String get about => _resolve(const [
        'messenger.settings.aboutTitle',
        'settings.about',
        'messenger.settings.title',
        'about'
      ], base.about);

  @override
  String get version => _resolve(const ['version'], base.version);

  @override
  String get aboutDescription => _resolve(const [
        'messenger.settings.aboutDesc',
        'settings.aboutDescription',
        'messenger.settings.title',
        'aboutDescription'
      ], base.aboutDescription);

  @override
  String get close => _resolve(const [
        'common.close',
        'messenger.close',
        'close',
        'messenger.buttons.close',
        'messenger.report.close',
        'qrLogin.closeBtn'
      ], base.close);

  @override
  String get technicalInfo =>
      _resolve(const ['technicalInfo'], base.technicalInfo);

  @override
  String get platform => _resolve(const ['platform'], base.platform);

  @override
  String get architecture =>
      _resolve(const ['architecture'], base.architecture);

  @override
  String get flutter => _resolve(const ['flutter'], base.flutter);

  @override
  String get viewOnGitHub =>
      _resolve(const ['viewOnGitHub'], base.viewOnGitHub);

  @override
  String get chats => _resolve(
      const ['messenger.chats', 'messenger.settings.chatsTitle'], base.chats);

  @override
  String get search => _resolve(const [
        'messenger.search',
        'common.search',
        'header.search',
        'settings.search',
        'messenger.context.search'
      ], base.search);

  @override
  String get searchPlaceholder => _resolve(const [
        'messenger.searchPlaceholder',
        'messenger.search',
        'common.search'
      ], base.searchPlaceholder);

  @override
  String get savedMessages => _resolve(const [
        'messenger.favorites.title',
        'messenger.savedMessages',
        'header.savedMessages'
      ], base.savedMessages);

  @override
  String get online => _resolve(const ['messenger.status.online'], base.online);

  @override
  String get offline => _resolve(
      const ['messenger.status.offline', 'messenger.status.lastSeenRecently'],
      base.offline);

  @override
  String get lastSeenRecently => _resolve(
      const ['messenger.status.lastSeenRecently'], base.lastSeenRecently);

  @override
  String get musicPlaylist => _resolve(
      const ['mobile.musicPlaylist', 'musicPlaylist'], base.musicPlaylist);

  @override
  String get reply => _resolve(const [
        'messenger.reply',
        'messenger.message.reply',
        'messenger.call.answer'
      ], base.reply);

  @override
  String get edit => _resolve(
      const ['messenger.edit', 'messenger.chat.edit', 'messenger.message.edit'],
      base.edit);

  @override
  String get copy =>
      _resolve(const ['messenger.copy', 'messenger.message.copy'], base.copy);

  @override
  String get pin => _resolve(const [
        'messenger.pin',
        'messenger.pinned.title',
        'messenger.message.pin'
      ], base.pin);

  @override
  String get unpin => _resolve(const [
        'messenger.unpin',
        'messenger.pinned.unpin',
        'messenger.message.unpin'
      ], base.unpin);

  @override
  String get delete => _resolve(const [
        'messenger.buttons.delete',
        'messenger.delete.buttons.delete',
        'messenger.moderation.deleteAction',
        'messenger.delete',
        'messenger.message.delete',
        'messenger.chat.delete',
        'profile.settings.deleteAccountBtn'
      ], base.delete);

  @override
  String get forward => _resolve(
      const ['messenger.forward', 'messenger.message.forward'], base.forward);

  @override
  String get members =>
      _resolve(const ['messenger.chatInfo.members'], base.members);

  @override
  String get noMessages =>
      _resolve(const ['mobile.noMessages', 'noMessages'], base.noMessages);

  @override
  String get joinedChat =>
      _resolve(const ['messenger.system.joinedChat'], base.joinedChat);

  @override
  String get leftChat =>
      _resolve(const ['messenger.system.leftChat'], base.leftChat);

  @override
  String get subscribedChannel => _resolve(
      const ['messenger.system.subscribedChannel'], base.subscribedChannel);

  @override
  String get unsubscribedChannel => _resolve(
      const ['messenger.system.unsubscribedChannel'], base.unsubscribedChannel);

  @override
  String get invited =>
      _resolve(const ['messenger.system.invited'], base.invited);

  @override
  String get systemMessage => _resolve(
      const ['mobile.systemMessage', 'systemMessage'], base.systemMessage);

  @override
  String get selectChatToStart =>
      _resolve(const ['messenger.empty.startMessage'], base.selectChatToStart);

  @override
  String get toArchive => _resolve(const [
        'messenger.context.archiveChat',
        'messenger.chat.archive',
        'messenger.archive'
      ], base.toArchive);

  @override
  String get unarchive => _resolve(const [
        'messenger.context.unarchiveChat',
        'messenger.chat.unarchive',
        'messenger.unarchive'
      ], base.unarchive);

  @override
  String get archive =>
      _resolve(const ['messenger.archive.title'], base.archive);

  @override
  String get archiveEmpty => _resolve(
      const ['mobile.archiveEmpty', 'archiveEmpty'], base.archiveEmpty);

  @override
  String get voiceMessage => _resolve(
      const ['mobile.voiceMessage', 'voiceMessage'], base.voiceMessage);

  @override
  String get videoMessage => _resolve(
      const ['mobile.videoMessage', 'videoMessage'], base.videoMessage);

  @override
  String get personalData => _resolve(const [
        'messenger.settings.personalTitle',
        'messenger.settings.personal',
        'messenger.personal.sectionTitle'
      ], base.personalData);

  @override
  String get personalDataDesc => _resolve(
      const ['messenger.settings.personalDesc'], base.personalDataDesc);

  @override
  String get privacyDesc =>
      _resolve(const ['messenger.settings.privacyDesc'], base.privacyDesc);

  @override
  String get chatsSettings => _resolve(
      const ['messenger.settings.chatsTitle', 'messenger.settings.chats'],
      base.chatsSettings);

  @override
  String get chatsSettingsDesc =>
      _resolve(const ['messenger.settings.chatsDesc'], base.chatsSettingsDesc);

  @override
  String get contacts => _resolve(const [
        'messenger.settings.contactsTitle',
        'messenger.contacts.title',
        'messenger.contacts',
        'footer.contacts'
      ], base.contacts);

  @override
  String get contactsDesc =>
      _resolve(const ['messenger.settings.contactsDesc'], base.contactsDesc);

  @override
  String get security => _resolve(const [
        'messenger.settings.securityTitle',
        'messenger.settings.security',
        'profile.nav.security',
        'profile.security.title',
        'aboutSection.title1'
      ], base.security);

  @override
  String get securityDesc =>
      _resolve(const ['messenger.settings.privacyDesc'], base.securityDesc);

  @override
  String get appearance => _resolve(const [
        'messenger.chatSettings.appearance',
        'settings.appearance',
        'messenger.settings.generalTitle'
      ], base.appearance);

  @override
  String get appearanceDesc => _resolve(
      const ['messenger.settings.generalDesc', 'settings.appearance'],
      base.appearanceDesc);

  @override
  String get energySaving => _resolve(const [
        'messenger.settings.energyTitle',
        'messenger.energy.mainSettings',
        'messenger.energy.title'
      ], base.energySaving);

  @override
  String get energySavingDesc => _resolve(
      const ['messenger.settings.energyDesc', 'messenger.energy.mainSettings'],
      base.energySavingDesc);

  @override
  String get account => _resolve(const [
        'messenger.settings.personalTitle',
        'messenger.settings.personal',
        'profile.title',
        'header.profile'
      ], base.account);

  @override
  String get interface => _resolve(
      const ['messenger.settings.generalTitle', 'settings.appearance'],
      base.interface);

  @override
  String get logout => _resolve(
      const ['messenger.settings.logout', 'header.logout', 'common.logout'],
      base.logout);

  @override
  String get basicInfo => _resolve(const [
        'messenger.personal.sectionTitle',
        'messenger.settings.personalTitle'
      ], base.basicInfo);

  @override
  String get nicknameCannotBeChanged => _resolve(
      const ['messenger.personal.nicknameCannotBeChanged'],
      base.nicknameCannotBeChanged);

  @override
  String get aboutMe => _resolve(
      const ['messenger.personal.bio', 'profile.profile.bio'], base.aboutMe);

  @override
  String get aboutMeHint =>
      _resolve(const ['messenger.personal.bioPlaceholder'], base.aboutMeHint);

  @override
  String get save => _resolve(const [
        'messenger.buttons.save',
        'messenger.createGroup.createButton',
        'common.save',
        'profile.profile.save'
      ], base.save);

  @override
  String get saving => _resolve(const ['mobile.saving', 'saving'], base.saving);

  @override
  String get communications =>
      _resolve(const ['messenger.privacy.communications'], base.communications);

  @override
  String get whoCanMessage =>
      _resolve(const ['messenger.privacy.whoCanMessage'], base.whoCanMessage);

  @override
  String get whoCanCall =>
      _resolve(const ['messenger.privacy.whoCanCall'], base.whoCanCall);

  @override
  String get whoCanRecordVoice => _resolve(
      const ['messenger.privacy.whoCanRecordVoice'], base.whoCanRecordVoice);

  @override
  String get whoCanSendFiles => _resolve(
      const ['messenger.privacy.whoCanSendFiles'], base.whoCanSendFiles);

  @override
  String get whoCanInvite => _resolve(
      const ['mobile.whoCanInvite', 'whoCanInvite'], base.whoCanInvite);

  @override
  String get profileVisibility => _resolve(
      const ['messenger.privacy.profileVisibility'], base.profileVisibility);

  @override
  String get whoSeesNickname => _resolve(
      const ['messenger.privacy.whoSeesNickname'], base.whoSeesNickname);

  @override
  String get everyone =>
      _resolve(const ['mobile.everyone', 'everyone'], base.everyone);

  @override
  String get contactsOnly => _resolve(
      const ['mobile.contactsOnly', 'contactsOnly'], base.contactsOnly);

  @override
  String get nobody => _resolve(const ['mobile.nobody', 'nobody'], base.nobody);

  @override
  String get addContact =>
      _resolve(const ['mobile.addContact', 'addContact'], base.addContact);

  @override
  String get addContactTitle => _resolve(
      const ['mobile.addContactTitle', 'addContactTitle'],
      base.addContactTitle);

  @override
  String get userNicknameHint => _resolve(
      const ['mobile.userNicknameHint', 'userNicknameHint'],
      base.userNicknameHint);

  @override
  String get displayNameOptional => _resolve(
      const ['mobile.displayNameOptional', 'displayNameOptional'],
      base.displayNameOptional);

  @override
  String get noContactsYet => _resolve(
      const ['mobile.noContactsYet', 'noContactsYet'], base.noContactsYet);

  @override
  String get appInfo =>
      _resolve(const ['mobile.appInfo', 'appInfo'], base.appInfo);

  @override
  String get checkUpdates => _resolve(
      const ['mobile.checkUpdates', 'checkUpdates'], base.checkUpdates);

  @override
  String get checkingUpdates => _resolve(
      const ['mobile.checkingUpdates', 'checkingUpdates'],
      base.checkingUpdates);

  @override
  String get cancel => _resolve(const [
        'messenger.buttons.cancel',
        'messenger.delete.buttons.cancel',
        'common.cancel',
        'profile.security.cancel',
        'messenger.report.cancel',
        'messenger.todoModal.cancel',
        'messenger.pollModal.cancel'
      ], base.cancel);

  @override
  String get obnovlenie_7e32 => _resolve(
      const ['mobile.obnovlenie_7e32', 'obnovlenie_7e32'],
      base.obnovlenie_7e32);

  @override
  String get obnovleniePrilozheniya_b6c3 => _resolve(const [
        'mobile.obnovleniePrilozheniya_b6c3',
        'obnovleniePrilozheniya_b6c3'
      ], base.obnovleniePrilozheniya_b6c3);

  @override
  String get podgotovkaKZagruzke_a5c7 => _resolve(
      const ['mobile.podgotovkaKZagruzke_a5c7', 'podgotovkaKZagruzke_a5c7'],
      base.podgotovkaKZagruzke_a5c7);

  @override
  String get ustanovkaZapuschena_d378 => _resolve(
      const ['mobile.ustanovkaZapuschena_d378', 'ustanovkaZapuschena_d378'],
      base.ustanovkaZapuschena_d378);

  @override
  String get dostupnaNovayaVersiyaPrilozheniya_eeae => _resolve(const [
        'mobile.dostupnaNovayaVersiyaPrilozheniya_eeae',
        'dostupnaNovayaVersiyaPrilozheniya_eeae'
      ], base.dostupnaNovayaVersiyaPrilozheniya_eeae);

  @override
  String get chtoNovogo_74e2 => _resolve(
      const ['mobile.chtoNovogo_74e2', 'chtoNovogo_74e2'],
      base.chtoNovogo_74e2);

  @override
  String get ofitsialnoeOpisanieRelizaDostupnoNa_3ea3 => _resolve(const [
        'mobile.ofitsialnoeOpisanieRelizaDostupnoNa_3ea3',
        'ofitsialnoeOpisanieRelizaDostupnoNa_3ea3'
      ], base.ofitsialnoeOpisanieRelizaDostupnoNa_3ea3);

  @override
  String get istochnikZagruzki_0e6e => _resolve(
      const ['mobile.istochnikZagruzki_0e6e', 'istochnikZagruzki_0e6e'],
      base.istochnikZagruzki_0e6e);

  @override
  String get pryamayaUstanovkaVPrilozhenii_16f5 => _resolve(const [
        'mobile.pryamayaUstanovkaVPrilozhenii_16f5',
        'pryamayaUstanovkaVPrilozhenii_16f5'
      ], base.pryamayaUstanovkaVPrilozhenii_16f5);

  @override
  String get avtomaticheskoeSkachivanieIZapusk_9a3f => _resolve(const [
        'mobile.avtomaticheskoeSkachivanieIZapusk_9a3f',
        'avtomaticheskoeSkachivanieIZapusk_9a3f'
      ], base.avtomaticheskoeSkachivanieIZapusk_9a3f);

  @override
  String get stranitsaRelizaNaGithub_1531 => _resolve(const [
        'mobile.stranitsaRelizaNaGithub_1531',
        'stranitsaRelizaNaGithub_1531'
      ], base.stranitsaRelizaNaGithub_1531);

  @override
  String get propustit_03ee => _resolve(
      const ['mobile.propustit_03ee', 'propustit_03ee'], base.propustit_03ee);

  @override
  String get ustanovka_516d => _resolve(
      const ['mobile.ustanovka_516d', 'ustanovka_516d'], base.ustanovka_516d);

  @override
  String get obnovit_dbe5 => _resolve(
      const ['mobile.obnovit_dbe5', 'obnovit_dbe5'], base.obnovit_dbe5);

  @override
  String get lichnyeDannye_be85 => _resolve(const [
        'messenger.settings.personalTitle',
        'messenger.settings.personal',
        'messenger.personal.sectionTitle'
      ], base.lichnyeDannye_be85);

  @override
  String get imyaNikneymFotoProfilya_28ac => _resolve(const [
        'mobile.imyaNikneymFotoProfilya_28ac',
        'imyaNikneymFotoProfilya_28ac'
      ], base.imyaNikneymFotoProfilya_28ac);

  @override
  String get privatnost_0899 => _resolve(
      const ['messenger.settings.privacyTitle', 'messenger.privacy.title'],
      base.privatnost_0899);

  @override
  String get ktoMozhetPisatZvonitVidet_1789 => _resolve(const [
        'mobile.ktoMozhetPisatZvonitVidet_1789',
        'ktoMozhetPisatZvonitVidet_1789'
      ], base.ktoMozhetPisatZvonitVidet_1789);

  @override
  String get nastroykiChatov_7ca8 => _resolve(
      const ['messenger.settings.chatsTitle'], base.nastroykiChatov_7ca8);

  @override
  String get uvedomleniyaTemyIstoriya_51da => _resolve(
      const ['messenger.settings.chatsDesc'],
      base.uvedomleniyaTemyIstoriya_51da);

  @override
  String get kontakty_7576 => _resolve(const [
        'messenger.settings.contactsTitle',
        'messenger.contacts.title',
        'messenger.contacts',
        'footer.contacts'
      ], base.kontakty_7576);

  @override
  String get vashiSohranennyeKontakty_a641 => _resolve(const [
        'mobile.vashiSohranennyeKontakty_a641',
        'vashiSohranennyeKontakty_a641'
      ], base.vashiSohranennyeKontakty_a641);

  @override
  String get bezopasnost_3677 => _resolve(const [
        'profile.nav.security',
        'profile.security.title',
        'aboutSection.title1'
      ], base.bezopasnost_3677);

  @override
  String get sessiiParolAutentifikatsiya_73f5 => _resolve(const [
        'mobile.sessiiParolAutentifikatsiya_73f5',
        'sessiiParolAutentifikatsiya_73f5'
      ], base.sessiiParolAutentifikatsiya_73f5);

  @override
  String get vneshniyVid_6873 =>
      _resolve(const ['settings.appearance'], base.vneshniyVid_6873);

  @override
  String get temaShriftMasshtab_d8c9 => _resolve(
      const ['mobile.temaShriftMasshtab_d8c9', 'temaShriftMasshtab_d8c9'],
      base.temaShriftMasshtab_d8c9);

  @override
  String get yazyk_0577 => _resolve(
      const ['profile.settings.language', 'language'], base.yazyk_0577);

  @override
  String get yazykInterfeysaKlienta_2ad3 => _resolve(const [
        'mobile.yazykInterfeysaKlienta_2ad3',
        'yazykInterfeysaKlienta_2ad3'
      ], base.yazykInterfeysaKlienta_2ad3);

  @override
  String get uvedomleniya_d2ed => _resolve(const [
        'settings.notifications',
        'profile.settings.notifications',
        'notifications'
      ], base.uvedomleniya_d2ed);

  @override
  String get zvukiBannery_1b60 => _resolve(
      const ['mobile.zvukiBannery_1b60', 'zvukiBannery_1b60'],
      base.zvukiBannery_1b60);

  @override
  String get energosberezhenie_0b19 => _resolve(
      const ['messenger.settings.energyTitle', 'messenger.energy.title'],
      base.energosberezhenie_0b19);

  @override
  String get animatsiiIProizvoditelnost_fba8 => _resolve(const [
        'mobile.animatsiiIProizvoditelnost_fba8',
        'animatsiiIProizvoditelnost_fba8'
      ], base.animatsiiIProizvoditelnost_fba8);

  @override
  String get oPrilozhenii_322e =>
      _resolve(const ['about'], base.oPrilozhenii_322e);

  @override
  String get versiyaProverkaObnovleniySsylki_6efc => _resolve(const [
        'mobile.versiyaProverkaObnovleniySsylki_6efc',
        'versiyaProverkaObnovleniySsylki_6efc'
      ], base.versiyaProverkaObnovleniySsylki_6efc);

  @override
  String get nastroyki_b01b => _resolve(const [
        'settings.title',
        'profile.nav.settings',
        'profile.settings.title',
        'messenger.settings.title',
        'settings'
      ], base.nastroyki_b01b);

  @override
  String get nastroyki_c919 => _resolve(const [
        'settings.title',
        'profile.nav.settings',
        'profile.settings.title',
        'messenger.settings.title',
        'settings'
      ], base.nastroyki_c919);

  @override
  String get proverkaObnovleniy_f3e0 => _resolve(
      const ['mobile.proverkaObnovleniy_f3e0', 'proverkaObnovleniy_f3e0'],
      base.proverkaObnovleniy_f3e0);

  @override
  String get neUdalosZagruzitNastroyki_f753 => _resolve(const [
        'mobile.neUdalosZagruzitNastroyki_f753',
        'neUdalosZagruzitNastroyki_f753'
      ], base.neUdalosZagruzitNastroyki_f753);

  @override
  String get oshibkaSohraneniya_0387 => _resolve(
      const ['mobile.oshibkaSohraneniya_0387', 'oshibkaSohraneniya_0387'],
      base.oshibkaSohraneniya_0387);

  @override
  String get dannyeSohraneny_fd62 => _resolve(
      const ['mobile.dannyeSohraneny_fd62', 'dannyeSohraneny_fd62'],
      base.dannyeSohraneny_fd62);

  @override
  String get gost_9618 =>
      _resolve(const ['mobile.gost_9618', 'gost_9618'], base.gost_9618);

  @override
  String get akkaunt_38ac => _resolve(
      const ['messenger.settings.personalTitle', 'profile.title'],
      base.akkaunt_38ac);

  @override
  String get interfeys_49be => _resolve(
      const ['messenger.settings.generalTitle', 'settings.appearance'],
      base.interfeys_49be);

  @override
  String get vyytiIzAkkaunta_6d41 => _resolve(
      const ['messenger.settings.logout', 'header.logout', 'common.logout'],
      base.vyytiIzAkkaunta_6d41);

  @override
  String get informatsiyaOPrilozhenii_00c4 => _resolve(const [
        'mobile.informatsiyaOPrilozhenii_00c4',
        'informatsiyaOPrilozhenii_00c4'
      ], base.informatsiyaOPrilozhenii_00c4);

  @override
  String get proverka_13bc => _resolve(
      const ['mobile.proverka_13bc', 'proverka_13bc'], base.proverka_13bc);

  @override
  String get proveritObnovleniya_ab45 => _resolve(
      const ['mobile.proveritObnovleniya_ab45', 'proveritObnovleniya_ab45'],
      base.proveritObnovleniya_ab45);

  @override
  String get osnovnayaInformatsiya_6fec => _resolve(const [
        'messenger.personal.sectionTitle',
        'messenger.settings.personalTitle'
      ], base.osnovnayaInformatsiya_6fec);

  @override
  String get imya_d38d => _resolve(const [
        'messenger.personal.name',
        'profile.profile.displayName',
        'profile.profile.displayNamePlaceholder'
      ], base.imya_d38d);

  @override
  String get vvediteVasheImya_751e => _resolve(
      const ['messenger.personal.namePlaceholder'], base.vvediteVasheImya_751e);

  @override
  String get nikneym_3fea => _resolve(const [
        'messenger.personal.nickname',
        'profile.profile.username',
        'nickname'
      ], base.nikneym_3fea);

  @override
  String get nikneymNelzyaIzmenitVPrilozhenii_75d0 => _resolve(const [
        'mobile.nikneymNelzyaIzmenitVPrilozhenii_75d0',
        'nikneymNelzyaIzmenitVPrilozhenii_75d0'
      ], base.nikneymNelzyaIzmenitVPrilozhenii_75d0);

  @override
  String get oSebe_0b3b => _resolve(
      const ['messenger.personal.bio', 'profile.profile.bio'], base.oSebe_0b3b);

  @override
  String get rasskazhiteOSebe_1c37 => _resolve(
      const ['messenger.personal.bioPlaceholder'], base.rasskazhiteOSebe_1c37);

  @override
  String get sohranenie_c15f => _resolve(
      const ['mobile.sohranenie_c15f', 'sohranenie_c15f'],
      base.sohranenie_c15f);

  @override
  String get sohranit_74ea => _resolve(const [
        'messenger.buttons.save',
        'messenger.createGroup.createButton',
        'common.save',
        'profile.profile.save'
      ], base.sohranit_74ea);

  @override
  String get vse_984b =>
      _resolve(const ['mobile.vse_984b', 'vse_984b'], base.vse_984b);

  @override
  String get tolkoKontakty_a559 => _resolve(
      const ['mobile.tolkoKontakty_a559', 'tolkoKontakty_a559'],
      base.tolkoKontakty_a559);

  @override
  String get nikto_ba19 =>
      _resolve(const ['mobile.nikto_ba19', 'nikto_ba19'], base.nikto_ba19);

  @override
  String get kommunikatsii_1242 => _resolve(
      const ['messenger.privacy.communications'], base.kommunikatsii_1242);

  @override
  String get ktoMozhetPisatSoobscheniya_4645 => _resolve(
      const ['messenger.privacy.whoCanMessage'],
      base.ktoMozhetPisatSoobscheniya_4645);

  @override
  String get ktoMozhetZvonit_c427 => _resolve(
      const ['messenger.privacy.whoCanCall'], base.ktoMozhetZvonit_c427);

  @override
  String get ktoMozhetZapisyvatGolosovye_c69a => _resolve(
      const ['messenger.privacy.whoCanRecordVoice'],
      base.ktoMozhetZapisyvatGolosovye_c69a);

  @override
  String get ktoMozhetOtpravlyatFayly_2e40 => _resolve(
      const ['messenger.privacy.whoCanSendFiles'],
      base.ktoMozhetOtpravlyatFayly_2e40);

  @override
  String get ktoMozhetPriglashatVGruppy_cdc0 => _resolve(const [
        'mobile.ktoMozhetPriglashatVGruppy_cdc0',
        'ktoMozhetPriglashatVGruppy_cdc0'
      ], base.ktoMozhetPriglashatVGruppy_cdc0);

  @override
  String get vidimostProfilya_34bf => _resolve(
      const ['messenger.privacy.profileVisibility'],
      base.vidimostProfilya_34bf);

  @override
  String get ktoViditMoyNikneym_54b8 => _resolve(
      const ['messenger.privacy.whoSeesNickname'],
      base.ktoViditMoyNikneym_54b8);

  @override
  String get ktoViditMoyAvatar_e9f6 => _resolve(
      const ['messenger.privacy.whoSeesAvatar'], base.ktoViditMoyAvatar_e9f6);

  @override
  String get ktoViditMoyDenRozhdeniya_ccc7 => _resolve(
      const ['messenger.privacy.whoSeesBirthday'],
      base.ktoViditMoyDenRozhdeniya_ccc7);

  @override
  String get ktoViditVremyaMoeyAktivnosti_4349 => _resolve(
      const ['messenger.privacy.whoSeesOnlineTime'],
      base.ktoViditVremyaMoeyAktivnosti_4349);

  @override
  String get neUdalosZagruzitKontakty_02a3 => _resolve(
      const ['messenger.contacts.loadError'],
      base.neUdalosZagruzitKontakty_02a3);

  @override
  String get dobavitKontakt_4278 => _resolve(
      const ['mobile.dobavitKontakt_4278', 'dobavitKontakt_4278'],
      base.dobavitKontakt_4278);

  @override
  String get nikneymPolzovatelya_5610 => _resolve(
      const ['mobile.nikneymPolzovatelya_5610', 'nikneymPolzovatelya_5610'],
      base.nikneymPolzovatelya_5610);

  @override
  String get otobrazhaemoeImyaOptsionalno_bbd1 => _resolve(const [
        'mobile.otobrazhaemoeImyaOptsionalno_bbd1',
        'otobrazhaemoeImyaOptsionalno_bbd1'
      ], base.otobrazhaemoeImyaOptsionalno_bbd1);

  @override
  String get otmena_987b => _resolve(const [
        'profile.security.cancel',
        'messenger.delete.buttons.cancel',
        'messenger.report.cancel',
        'messenger.todoModal.cancel',
        'messenger.pollModal.cancel'
      ], base.otmena_987b);

  @override
  String get dobavit_5eba => _resolve(
      const ['mobile.dobavit_5eba', 'dobavit_5eba'], base.dobavit_5eba);

  @override
  String get uVasPokaNetSohranennyh_b64b => _resolve(const [
        'mobile.uVasPokaNetSohranennyh_b64b',
        'uVasPokaNetSohranennyh_b64b'
      ], base.uVasPokaNetSohranennyh_b64b);

  @override
  String get pozvonit_ccfa => _resolve(
      const ['mobile.pozvonit_ccfa', 'pozvonit_ccfa'], base.pozvonit_ccfa);

  @override
  String get napisat_0144 => _resolve(
      const ['mobile.napisat_0144', 'napisat_0144'], base.napisat_0144);

  @override
  String get udalitKontakt_065d => _resolve(const [
        'messenger.context.deleteContactShort',
        'messenger.contacts.deleteTitle'
      ], base.udalitKontakt_065d);

  @override
  String get soobscheniya_7e26 => _resolve(
      const ['mobile.soobscheniya_7e26', 'soobscheniya_7e26'],
      base.soobscheniya_7e26);

  @override
  String get animatsiiSoobscheniy_bc8b => _resolve(
      const ['messenger.energy.messageAnimationsTitle'],
      base.animatsiiSoobscheniy_bc8b);

  @override
  String get pokazyvatAnimatsiiPriOtpravkeI_d663 => _resolve(const [
        'mobile.pokazyvatAnimatsiiPriOtpravkeI_d663',
        'pokazyvatAnimatsiiPriOtpravkeI_d663'
      ], base.pokazyvatAnimatsiiPriOtpravkeI_d663);

  @override
  String get arhivirovannyeChaty_d990 => _resolve(
      const ['messenger.archive.description'], base.arhivirovannyeChaty_d990);

  @override
  String get upravlenieArhivom_e843 => _resolve(
      const ['mobile.upravlenieArhivom_e843', 'upravlenieArhivom_e843'],
      base.upravlenieArhivom_e843);

  @override
  String get ochistitIstoriyu_837a => _resolve(const [
        'messenger.favorites.clearHistory',
        'messenger.context.clearHistory',
        'messenger.delete.historyTitle'
      ], base.ochistitIstoriyu_837a);

  @override
  String get udalitVseSoobscheniyaLokalno_fbbd => _resolve(const [
        'mobile.udalitVseSoobscheniyaLokalno_fbbd',
        'udalitVseSoobscheniyaLokalno_fbbd'
      ], base.udalitVseSoobscheniyaLokalno_fbbd);

  @override
  String get aktivnyeSessii_5c96 =>
      _resolve(const ['profile.sessions.title'], base.aktivnyeSessii_5c96);

  @override
  String get etoUstroystvo_26f6 => _resolve(
      const ['mobile.etoUstroystvo_26f6', 'etoUstroystvo_26f6'],
      base.etoUstroystvo_26f6);

  @override
  String get xaneoPcAktivnoSeychas_25b4 => _resolve(
      const ['mobile.xaneoPcAktivnoSeychas_25b4', 'xaneoPcAktivnoSeychas_25b4'],
      base.xaneoPcAktivnoSeychas_25b4);

  @override
  String get aktivno_87a4 => _resolve(
      const ['mobile.aktivno_87a4', 'aktivno_87a4'], base.aktivno_87a4);

  @override
  String get dvoynayaAutentifikatsiya_66ae => _resolve(const [
        'mobile.dvoynayaAutentifikatsiya_66ae',
        'dvoynayaAutentifikatsiya_66ae'
      ], base.dvoynayaAutentifikatsiya_66ae);

  @override
  String get zaschitaAkkauntaOdnorazovymParolem_e9f1 => _resolve(const [
        'mobile.zaschitaAkkauntaOdnorazovymParolem_e9f1',
        'zaschitaAkkauntaOdnorazovymParolem_e9f1'
      ], base.zaschitaAkkauntaOdnorazovymParolem_e9f1);

  @override
  String get opasnayaZona_25bc => _resolve(
      const ['mobile.opasnayaZona_25bc', 'opasnayaZona_25bc'],
      base.opasnayaZona_25bc);

  @override
  String get udalitAkkaunt_05c7 => _resolve(
      const ['profile.settings.deleteAccount'], base.udalitAkkaunt_05c7);

  @override
  String get neobratimoeDeystvie_7232 => _resolve(
      const ['mobile.neobratimoeDeystvie_7232', 'neobratimoeDeystvie_7232'],
      base.neobratimoeDeystvie_7232);

  @override
  String get tema_9e26 =>
      _resolve(const ['mobile.tema_9e26', 'tema_9e26'], base.tema_9e26);

  @override
  String get temnayaTema_cb48 =>
      _resolve(const ['darkTheme'], base.temnayaTema_cb48);

  @override
  String get pereklyuchitMezhduTemnymISvetlym_5415 => _resolve(const [
        'mobile.pereklyuchitMezhduTemnymISvetlym_5415',
        'pereklyuchitMezhduTemnymISvetlym_5415'
      ], base.pereklyuchitMezhduTemnymISvetlym_5415);

  @override
  String get razmerShrifta_1155 => _resolve(
      const ['mobile.razmerShrifta_1155', 'razmerShrifta_1155'],
      base.razmerShrifta_1155);

  @override
  String get a_87a0 => _resolve(const ['mobile.a_87a0', 'a_87a0'], base.a_87a0);

  @override
  String get pokazyvatVsplyvayuschieUvedomleniya_754e => _resolve(const [
        'mobile.pokazyvatVsplyvayuschieUvedomleniya_754e',
        'pokazyvatVsplyvayuschieUvedomleniya_754e'
      ], base.pokazyvatVsplyvayuschieUvedomleniya_754e);

  @override
  String get zvuk_9329 =>
      _resolve(const ['messenger.call.sound'], base.zvuk_9329);

  @override
  String get vosproizvoditZvukPriNovomSoobschenii_47cc => _resolve(const [
        'mobile.vosproizvoditZvukPriNovomSoobschenii_47cc',
        'vosproizvoditZvukPriNovomSoobschenii_47cc'
      ], base.vosproizvoditZvukPriNovomSoobschenii_47cc);

  @override
  String get osnovnyeNastroyki_231c => _resolve(
      const ['messenger.energy.mainSettings'], base.osnovnyeNastroyki_231c);

  @override
  String get rezhimEkonomiiEnergii_edfc => _resolve(
      const ['messenger.energy.lowPowerTitle'],
      base.rezhimEkonomiiEnergii_edfc);

  @override
  String get optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb => _resolve(const [
        'mobile.optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb',
        'optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb'
      ], base.optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb);

  @override
  String get avtomaticheskiySpyaschiyRezhim_5955 => _resolve(
      const ['messenger.energy.autoSleepTitle'],
      base.avtomaticheskiySpyaschiyRezhim_5955);

  @override
  String get perevoditPrilozhenieVSpyaschiyRezhim_1c07 => _resolve(
      const ['messenger.energy.autoSleepDesc'],
      base.perevoditPrilozhenieVSpyaschiyRezhim_1c07);

  @override
  String get animatsii_05c7 =>
      _resolve(const ['settings.animations'], base.animatsii_05c7);

  @override
  String get uproschennyeAnimatsii_3a13 => _resolve(
      const ['mobile.uproschennyeAnimatsii_3a13', 'uproschennyeAnimatsii_3a13'],
      base.uproschennyeAnimatsii_3a13);

  @override
  String get umenshaetKolichestvoAnimatsiyInterfeysa_6bf1 => _resolve(const [
        'mobile.umenshaetKolichestvoAnimatsiyInterfeysa_6bf1',
        'umenshaetKolichestvoAnimatsiyInterfeysa_6bf1'
      ], base.umenshaetKolichestvoAnimatsiyInterfeysa_6bf1);

  @override
  String get skoroBudetDostupno_de07 => _resolve(
      const ['mobile.skoroBudetDostupno_de07', 'skoroBudetDostupno_de07'],
      base.skoroBudetDostupno_de07);

  @override
  String get gostevoyRezhim_6d82 => _resolve(
      const ['mobile.gostevoyRezhim_6d82', 'gostevoyRezhim_6d82'],
      base.gostevoyRezhim_6d82);

  @override
  String get voyditeDlyaDostupaKAkkauntu_a5c8 => _resolve(const [
        'mobile.voyditeDlyaDostupaKAkkauntu_a5c8',
        'voyditeDlyaDostupaKAkkauntu_a5c8'
      ], base.voyditeDlyaDostupaKAkkauntu_a5c8);

  @override
  String get nazhmiteDlyaProsmotraIzmeneniy_0255 => _resolve(const [
        'mobile.nazhmiteDlyaProsmotraIzmeneniy_0255',
        'nazhmiteDlyaProsmotraIzmeneniy_0255'
      ], base.nazhmiteDlyaProsmotraIzmeneniy_0255);

  @override
  String get vvediteKodPodtverzhdeniya_61af => _resolve(
      const ['enterVerificationCode'], base.vvediteKodPodtverzhdeniya_61af);

  @override
  String get nevernyyKodPodtverzhdeniya_7762 => _resolve(
      const ['login.invalidConfirmationCode', 'invalidVerificationCode'],
      base.nevernyyKodPodtverzhdeniya_7762);

  @override
  String get podtverditeEMail_4bd4 =>
      _resolve(const ['confirmEmail'], base.podtverditeEMail_4bd4);

  @override
  String get proverit_340b =>
      _resolve(const ['profile.security.check', 'verify'], base.proverit_340b);

  @override
  String get otpravitKodPovtorno_7703 =>
      _resolve(const ['resendCode'], base.otpravitKodPovtorno_7703);

  @override
  String get sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e =>
      _resolve(const [
        'mobile.sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e',
        'sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e'
      ], base.sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e);

  @override
  String get tehnologii_6332 =>
      _resolve(const ['about.techTitle'], base.tehnologii_6332);

  @override
  String get vyNashliPashalku_1a57 => _resolve(
      const ['mobile.vyNashliPashalku_1a57', 'vyNashliPashalku_1a57'],
      base.vyNashliPashalku_1a57);

  @override
  String get spasiboZaIspolzovanieXaneo_d079 => _resolve(const [
        'mobile.spasiboZaIspolzovanieXaneo_d079',
        'spasiboZaIspolzovanieXaneo_d079'
      ], base.spasiboZaIspolzovanieXaneo_d079);

  @override
  String get globalnyyPoisk_77bf => _resolve(
      const ['mobile.globalnyyPoisk_77bf', 'globalnyyPoisk_77bf'],
      base.globalnyyPoisk_77bf);

  @override
  String get poiskKontaktovChatovKanalovBotov_db66 => _resolve(
      const ['messenger.search'], base.poiskKontaktovChatovKanalovBotov_db66);

  @override
  String get lyudi_c7ae =>
      _resolve(const ['messenger.reactions.people'], base.lyudi_c7ae);

  @override
  String get gruppy_ebc4 =>
      _resolve(const ['messenger.searchSection.groups'], base.gruppy_ebc4);

  @override
  String get kanaly_0c11 =>
      _resolve(const ['messenger.searchSection.channels'], base.kanaly_0c11);

  @override
  String get boty_d6e4 =>
      _resolve(const ['messenger.searchSection.bots'], base.boty_d6e4);

  @override
  String get izbrannoe_2fc4 =>
      _resolve(const ['messenger.favorites.title'], base.izbrannoe_2fc4);

  @override
  String get vvediteZaprosDlyaPoiskaPo_9955 => _resolve(const [
        'mobile.vvediteZaprosDlyaPoiskaPo_9955',
        'vvediteZaprosDlyaPoiskaPo_9955'
      ], base.vvediteZaprosDlyaPoiskaPo_9955);

  @override
  String get nichegoNeNaydeno_8767 => _resolve(
      const ['messenger.invite.notFound', 'messenger.emoji.notFound'],
      base.nichegoNeNaydeno_8767);

  @override
  String get izbrannoe_b637 =>
      _resolve(const ['messenger.favorites.title'], base.izbrannoe_b637);

  @override
  String get boty_800d =>
      _resolve(const ['messenger.searchSection.bots'], base.boty_800d);

  @override
  String get kanaly_ccec =>
      _resolve(const ['messenger.searchSection.channels'], base.kanaly_ccec);

  @override
  String get gruppy_cfd6 =>
      _resolve(const ['messenger.searchSection.groups'], base.gruppy_cfd6);

  @override
  String get polzovateli_e0ec =>
      _resolve(const ['messenger.searchSection.users'], base.polzovateli_e0ec);

  @override
  String get sohranennyeSoobscheniya_6b62 => _resolve(const [
        'mobile.sohranennyeSoobscheniya_6b62',
        'sohranennyeSoobscheniya_6b62'
      ], base.sohranennyeSoobscheniya_6b62);

  @override
  String get bot_0ae1 =>
      _resolve(const ['messenger.status.bot'], base.bot_0ae1);

  @override
  String get bot_0f46 =>
      _resolve(const ['mobile.bot_0f46', 'bot_0f46'], base.bot_0f46);

  @override
  String get gruppa_99d9 => _resolve(
      const ['messenger.chatInfo.groupTitle', 'knowledgeBase.bots.chatGroup'],
      base.gruppa_99d9);

  @override
  String get kanal_2710 => _resolve(const [
        'messenger.chatInfo.channelTitle',
        'knowledgeBase.bots.chatChannel',
        'messenger.moderation.objectChannel'
      ], base.kanal_2710);

  @override
  String get versiya_3725 => _resolve(const ['version'], base.versiya_3725);

  @override
  String get tehnicheskayaInformatsiya_ba0f =>
      _resolve(const ['technicalInfo'], base.tehnicheskayaInformatsiya_ba0f);

  @override
  String get platforma_8848 =>
      _resolve(const ['platform'], base.platforma_8848);

  @override
  String get arhitekturaProtsessora_c079 =>
      _resolve(const ['architecture'], base.arhitekturaProtsessora_c079);

  @override
  String get posmotretNaGithub_5238 =>
      _resolve(const ['viewOnGitHub'], base.posmotretNaGithub_5238);

  @override
  String get zakryt_dd94 => _resolve(const [
        'messenger.buttons.close',
        'messenger.report.close',
        'qrLogin.closeBtn',
        'close'
      ], base.zakryt_dd94);

  @override
  String get vklyuchitTemnuyuTemu_ed17 => _resolve(
      const ['mobile.vklyuchitTemnuyuTemu_ed17', 'vklyuchitTemnuyuTemu_ed17'],
      base.vklyuchitTemnuyuTemu_ed17);

  @override
  String get vklyuchitUvedomleniya_d311 => _resolve(
      const ['messenger.context.unmuteChat'], base.vklyuchitUvedomleniya_d311);

  @override
  String get kastomnyyOverleyXaneo_7d39 => _resolve(
      const ['mobile.kastomnyyOverleyXaneo_7d39', 'kastomnyyOverleyXaneo_7d39'],
      base.kastomnyyOverleyXaneo_7d39);

  @override
  String get animirovannyeUvedomleniyaSBystrymOtvetom_a25d => _resolve(const [
        'mobile.animirovannyeUvedomleniyaSBystrymOtvetom_a25d',
        'animirovannyeUvedomleniyaSBystrymOtvetom_a25d'
      ], base.animirovannyeUvedomleniyaSBystrymOtvetom_a25d);

  @override
  String get aaBbVv_1c6b =>
      _resolve(const ['mobile.aaBbVv_1c6b', 'aaBbVv_1c6b'], base.aaBbVv_1c6b);

  @override
  String get pleylist_a04c => _resolve(
      const ['mobile.pleylist_a04c', 'pleylist_a04c'], base.pleylist_a04c);

  @override
  String get spisokMuzyki_d477 => _resolve(
      const ['mobile.spisokMuzyki_d477', 'spisokMuzyki_d477'],
      base.spisokMuzyki_d477);

  @override
  String get loc_0B_5a4d =>
      _resolve(const ['mobile.loc_0B_5a4d', 'loc_0B_5a4d'], base.loc_0B_5a4d);

  @override
  String get b_3b67 => _resolve(const ['mobile.b_3b67', 'b_3b67'], base.b_3b67);

  @override
  String get kb_419d =>
      _resolve(const ['mobile.kb_419d', 'kb_419d'], base.kb_419d);

  @override
  String get mb_b808 =>
      _resolve(const ['mobile.mb_b808', 'mb_b808'], base.mb_b808);

  @override
  String get gb_e572 =>
      _resolve(const ['mobile.gb_e572', 'gb_e572'], base.gb_e572);

  @override
  String get audiozapis_867d => _resolve(
      const ['mobile.audiozapis_867d', 'audiozapis_867d'],
      base.audiozapis_867d);

  @override
  String get muzykalnyyTrek_b15d => _resolve(
      const ['mobile.muzykalnyyTrek_b15d', 'muzykalnyyTrek_b15d'],
      base.muzykalnyyTrek_b15d);

  @override
  String get muzykalnyeTrekiOtsutstvuyut_3301 => _resolve(const [
        'mobile.muzykalnyeTrekiOtsutstvuyut_3301',
        'muzykalnyeTrekiOtsutstvuyut_3301'
      ], base.muzykalnyeTrekiOtsutstvuyut_3301);

  @override
  String get nikneymUzheZanyat_59aa => _resolve(
      const ['mobile.nikneymUzheZanyat_59aa', 'nikneymUzheZanyat_59aa'],
      base.nikneymUzheZanyat_59aa);

  @override
  String get oshibkaProverki_2ab0 => _resolve(
      const ['mobile.oshibkaProverki_2ab0', 'oshibkaProverki_2ab0'],
      base.oshibkaProverki_2ab0);

  @override
  String get emailUzheZanyat_17e1 => _resolve(
      const ['mobile.emailUzheZanyat_17e1', 'emailUzheZanyat_17e1'],
      base.emailUzheZanyat_17e1);

  @override
  String get oshibkaOtpravkiKoda_a42a =>
      _resolve(const ['sendCodeError'], base.oshibkaOtpravkiKoda_a42a);

  @override
  String get neobhodimoPrinyatUsloviyaISoglasie_e31e => _resolve(
      const ['acceptTermsRequired'],
      base.neobhodimoPrinyatUsloviyaISoglasie_e31e);

  @override
  String get registratsiyaUspeshna_9d5c =>
      _resolve(const ['registrationSuccess'], base.registratsiyaUspeshna_9d5c);

  @override
  String get oshibkaRegistratsii_b9f2 =>
      _resolve(const ['registrationError'], base.oshibkaRegistratsii_b9f2);

  @override
  String get nazad_2b0b => _resolve(
      const ['support.back', 'register.back', 'back', 'messenger.datetime.ago'],
      base.nazad_2b0b);

  @override
  String get kakVasZovut_68b7 => _resolve(
      const ['register.realname', 'registerStep0Title'], base.kakVasZovut_68b7);

  @override
  String get kogdaVyRodilis_26f2 =>
      _resolve(const ['registerStep1Title'], base.kogdaVyRodilis_26f2);

  @override
  String get pridumayteNikneym_221b => _resolve(
      const ['register.nickname', 'registerStep2Title'],
      base.pridumayteNikneym_221b);

  @override
  String get vashEmail_8bbd =>
      _resolve(const ['registerStep3Title'], base.vashEmail_8bbd);

  @override
  String get podtverzhdenieEmail_281f => _resolve(
      const ['mobile.podtverzhdenieEmail_281f', 'podtverzhdenieEmail_281f'],
      base.podtverzhdenieEmail_281f);

  @override
  String get sozdayteParol_5f4c =>
      _resolve(const ['registerStep4Title'], base.sozdayteParol_5f4c);

  @override
  String get podtverzhdenieParolya_ebc2 => _resolve(
      const ['mobile.podtverzhdenieParolya_ebc2', 'podtverzhdenieParolya_ebc2'],
      base.podtverzhdenieParolya_ebc2);

  @override
  String get dobavteFoto_25eb =>
      _resolve(const ['registerStep5Title'], base.dobavteFoto_25eb);

  @override
  String get posledniyShag_e0c5 =>
      _resolve(const ['registerStep6Title'], base.posledniyShag_e0c5);

  @override
  String get vvediteVasheNastoyascheeImya_e656 => _resolve(
      const ['registerStep0Subtitle'], base.vvediteVasheNastoyascheeImya_e656);

  @override
  String get vamDolzhnoBytNeMenee_1111 => _resolve(
      const ['mobile.vamDolzhnoBytNeMenee_1111', 'vamDolzhnoBytNeMenee_1111'],
      base.vamDolzhnoBytNeMenee_1111);

  @override
  String get nikneymDolzhenBytUnikalnym_952d => _resolve(
      const ['registerStep2Subtitle'], base.nikneymDolzhenBytUnikalnym_952d);

  @override
  String get myOtpravimKodPodtverzhdeniya_fc71 => _resolve(const [
        'mobile.myOtpravimKodPodtverzhdeniya_fc71',
        'myOtpravimKodPodtverzhdeniya_fc71'
      ], base.myOtpravimKodPodtverzhdeniya_fc71);

  @override
  String get vvedite6ZnachnyyKodIz_f22f => _resolve(
      const ['mobile.vvedite6ZnachnyyKodIz_f22f', 'vvedite6ZnachnyyKodIz_f22f'],
      base.vvedite6ZnachnyyKodIz_f22f);

  @override
  String get pridumayteNadezhnyyParol_2312 => _resolve(const [
        'mobile.pridumayteNadezhnyyParol_2312',
        'pridumayteNadezhnyyParol_2312'
      ], base.pridumayteNadezhnyyParol_2312);

  @override
  String get povtoriteParolEscheRaz_6723 => _resolve(const [
        'mobile.povtoriteParolEscheRaz_6723',
        'povtoriteParolEscheRaz_6723'
      ], base.povtoriteParolEscheRaz_6723);

  @override
  String get etoNeobyazatelnoNoPriyatno_b6a3 => _resolve(const [
        'mobile.etoNeobyazatelnoNoPriyatno_b6a3',
        'etoNeobyazatelnoNoPriyatno_b6a3'
      ], base.etoNeobyazatelnoNoPriyatno_b6a3);

  @override
  String get proverteVashiDannyeIPrimite_3121 => _resolve(const [
        'mobile.proverteVashiDannyeIPrimite_3121',
        'proverteVashiDannyeIPrimite_3121'
      ], base.proverteVashiDannyeIPrimite_3121);

  @override
  String get registratsiya_0b93 => _resolve(
      const ['login.register', 'registerTitle'], base.registratsiya_0b93);

  @override
  String get vasheImya_51eb =>
      _resolve(const ['yourName'], base.vasheImya_51eb);

  @override
  String get proverkaDostupnosti_da13 =>
      _resolve(const ['checkingNickname'], base.proverkaDostupnosti_da13);

  @override
  String get nikneymDostupen_3fc9 =>
      _resolve(const ['nicknameAvailable'], base.nikneymDostupen_3fc9);

  @override
  String get nikneymZanyat_8a5f =>
      _resolve(const ['nicknameTaken'], base.nikneymZanyat_8a5f);

  @override
  String get emailDostupen_e903 => _resolve(
      const ['mobile.emailDostupen_e903', 'emailDostupen_e903'],
      base.emailDostupen_e903);

  @override
  String get emailZanyat_fb40 => _resolve(
      const ['mobile.emailZanyat_fb40', 'emailZanyat_fb40'],
      base.emailZanyat_fb40);

  @override
  String get kodPodtverzhdeniya_1c9d => _resolve(
      const ['mobile.kodPodtverzhdeniya_1c9d', 'kodPodtverzhdeniya_1c9d'],
      base.kodPodtverzhdeniya_1c9d);

  @override
  String get parol_5ebe => _resolve(const [
        'login.password',
        'profile.security.password',
        'qrLogin.passwordLabel',
        'passwordFieldHint',
        'password'
      ], base.parol_5ebe);

  @override
  String get podtverditeParol_e3e3 =>
      _resolve(const ['confirmPassword'], base.podtverditeParol_e3e3);

  @override
  String get nazhmiteChtobyDobavitFoto_d6e8 =>
      _resolve(const ['addPhoto'], base.nazhmiteChtobyDobavitFoto_d6e8);

  @override
  String get udalitFoto_3426 =>
      _resolve(const ['removePhoto'], base.udalitFoto_3426);

  @override
  String get yaPrinimayuUsloviyaIspolzovaniya_391a => _resolve(
      const ['acceptTerms'], base.yaPrinimayuUsloviyaIspolzovaniya_391a);

  @override
  String get yaSoglasenNaObrabotkuPersonalnyh_f2a8 => _resolve(
      const ['acceptDataProcessing'],
      base.yaSoglasenNaObrabotkuPersonalnyh_f2a8);

  @override
  String get zavershit_b0e3 => _resolve(const [
        'profile.sessions.end',
        'messenger.call.end',
        'finishButton',
        'finish'
      ], base.zavershit_b0e3);

  @override
  String get dalee_c453 =>
      _resolve(const ['register.next', 'next'], base.dalee_c453);

  @override
  String get dataRozhdeniya_505e => _resolve(const [
        'register.birthdate',
        'profile.profile.birthdate',
        'messenger.personal.birthday',
        'birthDate'
      ], base.dataRozhdeniya_505e);

  @override
  String get vklyuchitTemnuyuTemuOformleniya_86c4 => _resolve(const [
        'mobile.vklyuchitTemnuyuTemuOformleniya_86c4',
        'vklyuchitTemnuyuTemuOformleniya_86c4'
      ], base.vklyuchitTemnuyuTemuOformleniya_86c4);

  @override
  String get yanvar_ee86 =>
      _resolve(const ['mobile.yanvar_ee86', 'yanvar_ee86'], base.yanvar_ee86);

  @override
  String get fevral_28ff =>
      _resolve(const ['mobile.fevral_28ff', 'fevral_28ff'], base.fevral_28ff);

  @override
  String get mart_d766 =>
      _resolve(const ['mobile.mart_d766', 'mart_d766'], base.mart_d766);

  @override
  String get aprel_03e9 =>
      _resolve(const ['mobile.aprel_03e9', 'aprel_03e9'], base.aprel_03e9);

  @override
  String get may_2e53 =>
      _resolve(const ['mobile.may_2e53', 'may_2e53'], base.may_2e53);

  @override
  String get iyun_cfcb =>
      _resolve(const ['mobile.iyun_cfcb', 'iyun_cfcb'], base.iyun_cfcb);

  @override
  String get iyul_89fb =>
      _resolve(const ['mobile.iyul_89fb', 'iyul_89fb'], base.iyul_89fb);

  @override
  String get avgust_de5a =>
      _resolve(const ['mobile.avgust_de5a', 'avgust_de5a'], base.avgust_de5a);

  @override
  String get sentyabr_ebfb => _resolve(
      const ['mobile.sentyabr_ebfb', 'sentyabr_ebfb'], base.sentyabr_ebfb);

  @override
  String get oktyabr_1720 => _resolve(
      const ['mobile.oktyabr_1720', 'oktyabr_1720'], base.oktyabr_1720);

  @override
  String get noyabr_66fb =>
      _resolve(const ['mobile.noyabr_66fb', 'noyabr_66fb'], base.noyabr_66fb);

  @override
  String get dekabr_39b3 =>
      _resolve(const ['mobile.dekabr_39b3', 'dekabr_39b3'], base.dekabr_39b3);

  @override
  String get pn_2c1e =>
      _resolve(const ['mobile.pn_2c1e', 'pn_2c1e'], base.pn_2c1e);

  @override
  String get vt_7145 =>
      _resolve(const ['mobile.vt_7145', 'vt_7145'], base.vt_7145);

  @override
  String get sr_c6e4 =>
      _resolve(const ['mobile.sr_c6e4', 'sr_c6e4'], base.sr_c6e4);

  @override
  String get cht_a51f =>
      _resolve(const ['mobile.cht_a51f', 'cht_a51f'], base.cht_a51f);

  @override
  String get pt_0123 =>
      _resolve(const ['mobile.pt_0123', 'pt_0123'], base.pt_0123);

  @override
  String get sb_3a4b =>
      _resolve(const ['mobile.sb_3a4b', 'sb_3a4b'], base.sb_3a4b);

  @override
  String get vs_4ad9 =>
      _resolve(const ['mobile.vs_4ad9', 'vs_4ad9'], base.vs_4ad9);

  @override
  String get gotovo_34e1 =>
      _resolve(const ['register.done', 'qrScanDoneButton'], base.gotovo_34e1);

  @override
  String get oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b => _resolve(const [
        'mobile.oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b',
        'oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b'
      ], base.oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b);

  @override
  String get kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7 =>
      _resolve(const [
        'mobile.kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7',
        'kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7'
      ], base.kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7);

  @override
  String get oshibkaZagruzkiKlyucheyNaServer_ff9b => _resolve(const [
        'mobile.oshibkaZagruzkiKlyucheyNaServer_ff9b',
        'oshibkaZagruzkiKlyucheyNaServer_ff9b'
      ], base.oshibkaZagruzkiKlyucheyNaServer_ff9b);

  @override
  String get oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4 => _resolve(const [
        'mobile.oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4',
        'oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4'
      ], base.oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4);

  @override
  String get prevyshenLimitV5Akkauntov_a6a9 => _resolve(const [
        'mobile.prevyshenLimitV5Akkauntov_a6a9',
        'prevyshenLimitV5Akkauntov_a6a9'
      ], base.prevyshenLimitV5Akkauntov_a6a9);

  @override
  String get oshibkaAvtorizatsii_9f5c => _resolve(
      const ['mobile.oshibkaAvtorizatsii_9f5c', 'oshibkaAvtorizatsii_9f5c'],
      base.oshibkaAvtorizatsii_9f5c);

  @override
  String get oshibkaPodklyucheniyaKServeru_8b96 => _resolve(const [
        'mobile.oshibkaPodklyucheniyaKServeru_8b96',
        'oshibkaPodklyucheniyaKServeru_8b96'
      ], base.oshibkaPodklyucheniyaKServeru_8b96);

  @override
  String get nazadKMessendzheru_de29 => _resolve(
      const ['mobile.nazadKMessendzheru_de29', 'nazadKMessendzheru_de29'],
      base.nazadKMessendzheru_de29);

  @override
  String get voytiVAkkaunt_c439 => _resolve(
      const ['mobile.voytiVAkkaunt_c439', 'voytiVAkkaunt_c439'],
      base.voytiVAkkaunt_c439);

  @override
  String get vvediteParol_1370 =>
      _resolve(const ['login.enterPassword'], base.vvediteParol_1370);

  @override
  String get vvediteSvoiDannyeDlyaDostupa_319e => _resolve(const [
        'mobile.vvediteSvoiDannyeDlyaDostupa_319e',
        'vvediteSvoiDannyeDlyaDostupa_319e'
      ], base.vvediteSvoiDannyeDlyaDostupa_319e);

  @override
  String get voyti_63a7 => _resolve(const [
        'header.login',
        'login.loginBtn',
        'qrLogin.submitCodeBtn',
        'loginButton'
      ], base.voyti_63a7);

  @override
  String get sobesednik_7025 => _resolve(
      const ['mobile.sobesednik_7025', 'sobesednik_7025'],
      base.sobesednik_7025);

  @override
  String get vy_0101 => _resolve(const ['messenger.chat.you'], base.vy_0101);

  @override
  String get vyDelitesSvoimEkranom_16b1 => _resolve(
      const ['mobile.vyDelitesSvoimEkranom_16b1', 'vyDelitesSvoimEkranom_16b1'],
      base.vyDelitesSvoimEkranom_16b1);

  @override
  String get polzovatel_f154 =>
      _resolve(const ['messenger.system.user'], base.polzovatel_f154);

  @override
  String get ishodyaschiyVyzov_650b =>
      _resolve(const ['messenger.calls.outgoing'], base.ishodyaschiyVyzov_650b);

  @override
  String get vhodyaschiyVyzov_19ff =>
      _resolve(const ['messenger.calls.incoming'], base.vhodyaschiyVyzov_19ff);

  @override
  String get podklyucheno_d022 =>
      _resolve(const ['messenger.call.active'], base.podklyucheno_d022);

  @override
  String get ozhidanieOtveta_a984 =>
      _resolve(const ['messenger.call.waiting'], base.ozhidanieOtveta_a984);

  @override
  String get razgovorPoAudiosvyazi_3ed7 => _resolve(
      const ['messenger.call.active'], base.razgovorPoAudiosvyazi_3ed7);

  @override
  String get translyatsiyaVashegoEkranaZapuschena_575a => _resolve(const [
        'mobile.translyatsiyaVashegoEkranaZapuschena_575a',
        'translyatsiyaVashegoEkranaZapuschena_575a'
      ], base.translyatsiyaVashegoEkranaZapuschena_575a);

  @override
  String get sobesednikViditVseChtoProishodit_c759 => _resolve(const [
        'mobile.sobesednikViditVseChtoProishodit_c759',
        'sobesednikViditVseChtoProishodit_c759'
      ], base.sobesednikViditVseChtoProishodit_c759);

  @override
  String get vhodyaschiyVyzov_905e => _resolve(
      const ['messenger.call.incoming', 'messenger.calls.incoming'],
      base.vhodyaschiyVyzov_905e);

  @override
  String get neizvestnyy_be89 => _resolve(
      const ['mobile.neizvestnyy_be89', 'neizvestnyy_be89'],
      base.neizvestnyy_be89);

  @override
  String get videozvonok_dd18 => _resolve(
      const ['messenger.callType.video', 'messenger.call.videoCall'],
      base.videozvonok_dd18);

  @override
  String get golosovoyZvonok_5410 => _resolve(
      const ['mobile.golosovoyZvonok_5410', 'golosovoyZvonok_5410'],
      base.golosovoyZvonok_5410);

  @override
  String get otklonit_8b0d =>
      _resolve(const ['messenger.call.decline'], base.otklonit_8b0d);

  @override
  String get otvetit_e568 => _resolve(
      const ['messenger.message.reply', 'messenger.call.answer'],
      base.otvetit_e568);

  @override
  String get gruppovoyZvonok_dac1 => _resolve(
      const ['messenger.createGroup.calls', 'messenger.editChat.groupCalls'],
      base.gruppovoyZvonok_dac1);

  @override
  String get podklyuchenieKZvonku_e2cf => _resolve(
      const ['messenger.call.outgoingStatus'], base.podklyuchenieKZvonku_e2cf);

  @override
  String get podklyuchenieKVeschaniyu_038b => _resolve(
      const ['messenger.call.outgoingStatus'],
      base.podklyuchenieKVeschaniyu_038b);

  @override
  String get uchastnik_cffb => _resolve(const [
        'messenger.roles.member',
        'messenger.system.member.one',
        'messenger.chatInfo.memberOne'
      ], base.uchastnik_cffb);

  @override
  String get vy_479c => _resolve(const ['messenger.chat.you'], base.vy_479c);

  @override
  String get svernut_ca9f =>
      _resolve(const ['messenger.call.minimize'], base.svernut_ca9f);

  @override
  String get vhodyaschiyVyzov_d2f3 => _resolve(
      const ['mobile.vhodyaschiyVyzov_d2f3', 'vhodyaschiyVyzov_d2f3'],
      base.vhodyaschiyVyzov_d2f3);

  @override
  String get novoeSoobschenie_1d49 => _resolve(
      const ['messenger.createChat.newMessageTitle'],
      base.novoeSoobschenie_1d49);

  @override
  String get vashOtvet_40c2 => _resolve(
      const ['mobile.vashOtvet_40c2', 'vashOtvet_40c2'], base.vashOtvet_40c2);

  @override
  String get videovyzov_3353 => _resolve(
      const ['mobile.videovyzov_3353', 'videovyzov_3353'],
      base.videovyzov_3353);

  @override
  String get audiovyzov_bbb5 => _resolve(
      const ['mobile.audiovyzov_bbb5', 'audiovyzov_bbb5'],
      base.audiovyzov_bbb5);

  @override
  String get nachatZvonok_3d26 =>
      _resolve(const ['messenger.callType.title'], base.nachatZvonok_3d26);

  @override
  String get golosovoyZvonok_b615 => _resolve(
      const ['mobile.golosovoyZvonok_b615', 'golosovoyZvonok_b615'],
      base.golosovoyZvonok_b615);

  @override
  String get pozvonitPoGolosovoySvyazi_4069 => _resolve(
      const ['messenger.callType.audioDesc'],
      base.pozvonitPoGolosovoySvyazi_4069);

  @override
  String get videozvonok_8142 => _resolve(
      const ['messenger.callType.video', 'messenger.call.videoCall'],
      base.videozvonok_8142);

  @override
  String get pozvonitSVklyuchennoyKameroy_fb05 => _resolve(
      const ['messenger.callType.videoDesc'],
      base.pozvonitSVklyuchennoyKameroy_fb05);

  @override
  String get zashifrovannoeSoobschenie_ca35 => _resolve(
      const ['messenger.message.encrypted'],
      base.zashifrovannoeSoobschenie_ca35);

  @override
  String get golosovoeSoobschenie_4a85 => _resolve(
      const ['mobile.golosovoeSoobschenie_4a85', 'golosovoeSoobschenie_4a85'],
      base.golosovoeSoobschenie_4a85);

  @override
  String get videosoobschenie_d687 => _resolve(
      const ['mobile.videosoobschenie_d687', 'videosoobschenie_d687'],
      base.videosoobschenie_d687);

  @override
  String get fayl_826d =>
      _resolve(const ['mobile.fayl_826d', 'fayl_826d'], base.fayl_826d);

  @override
  String get zvonok_e8d5 =>
      _resolve(const ['messenger.call.call'], base.zvonok_e8d5);

  @override
  String get oshibkaDeshifrovaniya_4146 => _resolve(
      const ['mobile.oshibkaDeshifrovaniya_4146', 'oshibkaDeshifrovaniya_4146'],
      base.oshibkaDeshifrovaniya_4146);

  @override
  String get zapisyvaetGolosovoe_2a5c => _resolve(
      const ['messenger.status.recordingVoice'], base.zapisyvaetGolosovoe_2a5c);

  @override
  String get pechataet_812c =>
      _resolve(const ['messenger.status.typing'], base.pechataet_812c);

  @override
  String get neUdalosArhivirovatChat_ab89 => _resolve(const [
        'mobile.neUdalosArhivirovatChat_ab89',
        'neUdalosArhivirovatChat_ab89'
      ], base.neUdalosArhivirovatChat_ab89);

  @override
  String get neUdalosRazarhivirovatChat_f0d7 => _resolve(const [
        'mobile.neUdalosRazarhivirovatChat_f0d7',
        'neUdalosRazarhivirovatChat_f0d7'
      ], base.neUdalosRazarhivirovatChat_f0d7);

  @override
  String get arhiv_56aa =>
      _resolve(const ['messenger.archive.title'], base.arhiv_56aa);

  @override
  String get netUserid_634a => _resolve(
      const ['mobile.netUserid_634a', 'netUserid_634a'], base.netUserid_634a);

  @override
  String get netKlyucha_337b => _resolve(
      const ['mobile.netKlyucha_337b', 'netKlyucha_337b'],
      base.netKlyucha_337b);

  @override
  String get neizvestnyyTipChata_2617 => _resolve(
      const ['mobile.neizvestnyyTipChata_2617', 'neizvestnyyTipChata_2617'],
      base.neizvestnyyTipChata_2617);

  @override
  String get neUdalosPoluchitKlyuchShifrovaniya_b953 => _resolve(const [
        'mobile.neUdalosPoluchitKlyuchShifrovaniya_b953',
        'neUdalosPoluchitKlyuchShifrovaniya_b953'
      ], base.neUdalosPoluchitKlyuchShifrovaniya_b953);

  @override
  String get gruppa_19c2 => _resolve(
      const ['messenger.chatInfo.groupTitle', 'knowledgeBase.bots.chatGroup'],
      base.gruppa_19c2);

  @override
  String get uchastnik_5bce => _resolve(const [
        'messenger.system.member.one',
        'messenger.chatInfo.memberOne',
        'messenger.roles.member'
      ], base.uchastnik_5bce);

  @override
  String get uchastnika_92d9 => _resolve(
      const ['messenger.system.member.few', 'messenger.chatInfo.memberFew'],
      base.uchastnika_92d9);

  @override
  String get uchastnikov_5d6b => _resolve(const [
        'messenger.system.member.many',
        'messenger.system.member.other',
        'messenger.chatInfo.memberMany'
      ], base.uchastnikov_5d6b);

  @override
  String get kanal_64ec => _resolve(const [
        'messenger.moderation.objectChannel',
        'messenger.chatInfo.channelTitle',
        'knowledgeBase.bots.chatChannel'
      ], base.kanal_64ec);

  @override
  String get podpischik_695a => _resolve(const [
        'messenger.system.subscriber.one',
        'messenger.chatInfo.subscriberOne'
      ], base.podpischik_695a);

  @override
  String get podpischika_b490 => _resolve(const [
        'messenger.system.subscriber.few',
        'messenger.chatInfo.subscriberFew'
      ], base.podpischika_b490);

  @override
  String get podpischikov_ba39 => _resolve(const [
        'messenger.system.subscriber.many',
        'messenger.system.subscriber.other',
        'messenger.chatInfo.subscriberMany'
      ], base.podpischikov_ba39);

  @override
  String get segodnya_9626 =>
      _resolve(const ['messenger.datetime.today'], base.segodnya_9626);

  @override
  String get vchera_61d4 =>
      _resolve(const ['messenger.datetime.yesterday'], base.vchera_61d4);

  @override
  String get yanvarya_d861 => _resolve(
      const ['mobile.yanvarya_d861', 'yanvarya_d861'], base.yanvarya_d861);

  @override
  String get fevralya_fcf9 => _resolve(
      const ['mobile.fevralya_fcf9', 'fevralya_fcf9'], base.fevralya_fcf9);

  @override
  String get marta_bb77 =>
      _resolve(const ['mobile.marta_bb77', 'marta_bb77'], base.marta_bb77);

  @override
  String get aprelya_2b5a => _resolve(
      const ['mobile.aprelya_2b5a', 'aprelya_2b5a'], base.aprelya_2b5a);

  @override
  String get maya_4dbb =>
      _resolve(const ['mobile.maya_4dbb', 'maya_4dbb'], base.maya_4dbb);

  @override
  String get iyunya_adcb =>
      _resolve(const ['mobile.iyunya_adcb', 'iyunya_adcb'], base.iyunya_adcb);

  @override
  String get iyulya_3236 =>
      _resolve(const ['mobile.iyulya_3236', 'iyulya_3236'], base.iyulya_3236);

  @override
  String get avgusta_e3aa => _resolve(
      const ['mobile.avgusta_e3aa', 'avgusta_e3aa'], base.avgusta_e3aa);

  @override
  String get sentyabrya_a146 => _resolve(
      const ['mobile.sentyabrya_a146', 'sentyabrya_a146'],
      base.sentyabrya_a146);

  @override
  String get oktyabrya_7abd => _resolve(
      const ['mobile.oktyabrya_7abd', 'oktyabrya_7abd'], base.oktyabrya_7abd);

  @override
  String get noyabrya_6e78 => _resolve(
      const ['mobile.noyabrya_6e78', 'noyabrya_6e78'], base.noyabrya_6e78);

  @override
  String get dekabrya_29cc => _resolve(
      const ['mobile.dekabrya_29cc', 'dekabrya_29cc'], base.dekabrya_29cc);

  @override
  String get vyPodpisalisNaKanal_b2b3 => _resolve(
      const ['messenger.system.channelSubscribed'],
      base.vyPodpisalisNaKanal_b2b3);

  @override
  String get vyPrisoedinilisKGruppe_07bd => _resolve(const [
        'mobile.vyPrisoedinilisKGruppe_07bd',
        'vyPrisoedinilisKGruppe_07bd'
      ], base.vyPrisoedinilisKGruppe_07bd);

  @override
  String get neUdalosPrisoedinitsya_31e6 => _resolve(const [
        'mobile.neUdalosPrisoedinitsya_31e6',
        'neUdalosPrisoedinitsya_31e6'
      ], base.neUdalosPrisoedinitsya_31e6);

  @override
  String get vyOtpisalisOtKanala_7698 => _resolve(
      const ['mobile.vyOtpisalisOtKanala_7698', 'vyOtpisalisOtKanala_7698'],
      base.vyOtpisalisOtKanala_7698);

  @override
  String get vyPokinuliGruppu_5a52 => _resolve(
      const ['mobile.vyPokinuliGruppu_5a52', 'vyPokinuliGruppu_5a52'],
      base.vyPokinuliGruppu_5a52);

  @override
  String get neUdalosVypolnitDeystvie_3cfd => _resolve(const [
        'mobile.neUdalosVypolnitDeystvie_3cfd',
        'neUdalosVypolnitDeystvie_3cfd'
      ], base.neUdalosVypolnitDeystvie_3cfd);

  @override
  String get neUdalosPereklyuchitAkkaunt_968b => _resolve(const [
        'mobile.neUdalosPereklyuchitAkkaunt_968b',
        'neUdalosPereklyuchitAkkaunt_968b'
      ], base.neUdalosPereklyuchitAkkaunt_968b);

  @override
  String get media_c247 =>
      _resolve(const ['messenger.chatInfo.media'], base.media_c247);

  @override
  String get fayly_200c =>
      _resolve(const ['messenger.chatInfo.files'], base.fayly_200c);

  @override
  String get golos_2d89 => _resolve(
      const ['messenger.chatInfo.voiceMessages', 'about.timelineTag6Voice'],
      base.golos_2d89);

  @override
  String get ssylki_9f58 =>
      _resolve(const ['mobile.ssylki_9f58', 'ssylki_9f58'], base.ssylki_9f58);

  @override
  String get profil_c62a => _resolve(
      const ['header.profile', 'profile.nav.profile', 'profile.profile.title'],
      base.profil_c62a);

  @override
  String get imyaPolzovatelya_6fd4 => _resolve(
      const ['login.username', 'profile.profile.username'],
      base.imyaPolzovatelya_6fd4);

  @override
  String get denRozhdeniya_e41d => _resolve(
      const ['mobile.denRozhdeniya_e41d', 'denRozhdeniya_e41d'],
      base.denRozhdeniya_e41d);

  @override
  String get polzovatelSkrylInformatsiyuOSebe_f416 => _resolve(const [
        'mobile.polzovatelSkrylInformatsiyuOSebe_f416',
        'polzovatelSkrylInformatsiyuOSebe_f416'
      ], base.polzovatelSkrylInformatsiyuOSebe_f416);

  @override
  String get god_6270 => _resolve(const [
        'messenger.datetime.year.one',
        'messenger.premium.planYear',
        'messenger.premium.perYear'
      ], base.god_6270);

  @override
  String get goda_7443 =>
      _resolve(const ['messenger.datetime.year.few'], base.goda_7443);

  @override
  String get let_257a =>
      _resolve(const ['messenger.datetime.year.many'], base.let_257a);

  @override
  String get skopirovano_f70b =>
      _resolve(const ['knowledgeBase.doc.copied'], base.skopirovano_f70b);

  @override
  String get akkaunty_80b5 => _resolve(
      const ['mobile.akkaunty_80b5', 'akkaunty_80b5'], base.akkaunty_80b5);

  @override
  String get dobavitAkkaunt_5253 =>
      _resolve(const ['header.addAccount'], base.dobavitAkkaunt_5253);

  @override
  String get limit5Akkauntov_fdb7 => _resolve(
      const ['mobile.limit5Akkauntov_fdb7', 'limit5Akkauntov_fdb7'],
      base.limit5Akkauntov_fdb7);

  @override
  String get nazadKChatam_7edb => _resolve(
      const ['mobile.nazadKChatam_7edb', 'nazadKChatam_7edb'],
      base.nazadKChatam_7edb);

  @override
  String get chaty_19ad => _resolve(const ['messenger.chats'], base.chaty_19ad);

  @override
  String get globalnyyPoisk_7ff2 =>
      _resolve(const ['messenger.search'], base.globalnyyPoisk_7ff2);

  @override
  String get arhivPust_3e22 => _resolve(
      const ['mobile.arhivPust_3e22', 'arhivPust_3e22'], base.arhivPust_3e22);

  @override
  String get netSoobscheniy_29d4 =>
      _resolve(const ['messenger.empty.noMessages'], base.netSoobscheniy_29d4);

  @override
  String get toDoList_27e1 => _resolve(
      const ['messenger.attach.todoList', 'messenger.todoModal.title'],
      base.toDoList_27e1);

  @override
  String get opros_6ff1 => _resolve(const [
        'messenger.attach.pollShort',
        'messenger.pollModal.defaultQuestion'
      ], base.opros_6ff1);

  @override
  String get fotografiya_5709 => _resolve(
      const ['mobile.fotografiya_5709', 'fotografiya_5709'],
      base.fotografiya_5709);

  @override
  String get razarhivirovat_416b => _resolve(
      const ['messenger.context.unarchiveChat'], base.razarhivirovat_416b);

  @override
  String get vArhiv_ce22 =>
      _resolve(const ['messenger.context.archiveChat'], base.vArhiv_ce22);

  @override
  String get chat_c52b =>
      _resolve(const ['messenger.moderation.objectChat'], base.chat_c52b);

  @override
  String get vyberiteChatDlyaNachalaObscheniya_36a5 => _resolve(
      const ['messenger.empty.startMessage'],
      base.vyberiteChatDlyaNachalaObscheniya_36a5);

  @override
  String get bot_2712 =>
      _resolve(const ['messenger.status.bot'], base.bot_2712);

  @override
  String get vSeti_d902 =>
      _resolve(const ['messenger.status.online'], base.vSeti_d902);

  @override
  String get neVSeti_ee01 => _resolve(
      const ['messenger.status.offline', 'messenger.status.lastSeenRecently'],
      base.neVSeti_ee01);

  @override
  String get nastroykiChata_1e0d => _resolve(
      const ['mobile.nastroykiChata_1e0d', 'nastroykiChata_1e0d'],
      base.nastroykiChata_1e0d);

  @override
  String get pokinutGruppu_e6ce => _resolve(const [
        'messenger.context.leaveGroup',
        'messenger.delete.leaveGroupTitle'
      ], base.pokinutGruppu_e6ce);

  @override
  String get prisoedinitsyaKGruppe_eb45 => _resolve(
      const ['mobile.prisoedinitsyaKGruppe_eb45', 'prisoedinitsyaKGruppe_eb45'],
      base.prisoedinitsyaKGruppe_eb45);

  @override
  String get otpisatsyaOtKanala_fdbc => _resolve(
      const ['mobile.otpisatsyaOtKanala_fdbc', 'otpisatsyaOtKanala_fdbc'],
      base.otpisatsyaOtKanala_fdbc);

  @override
  String get podpisatsyaNaKanal_2dad => _resolve(
      const ['mobile.podpisatsyaNaKanal_2dad', 'podpisatsyaNaKanal_2dad'],
      base.podpisatsyaNaKanal_2dad);

  @override
  String get netSoobscheniyNapishiteChtoNibud_2bf4 => _resolve(
      const ['messenger.empty.startNow'],
      base.netSoobscheniyNapishiteChtoNibud_2bf4);

  @override
  String get prisoedinilsyaKChatu_f623 => _resolve(
      const ['messenger.system.joinedChat'], base.prisoedinilsyaKChatu_f623);

  @override
  String get pokinulChat_d567 =>
      _resolve(const ['messenger.system.leftChat'], base.pokinulChat_d567);

  @override
  String get podpisalsyaNaKanal_0673 => _resolve(
      const ['messenger.system.subscribedChannel'],
      base.podpisalsyaNaKanal_0673);

  @override
  String get otpisalsyaOtKanala_fa13 => _resolve(
      const ['messenger.system.unsubscribedChannel'],
      base.otpisalsyaOtKanala_fa13);

  @override
  String get polzovatelya_1083 =>
      _resolve(const ['messenger.system.user'], base.polzovatelya_1083);

  @override
  String get priglasil_47ae =>
      _resolve(const ['messenger.system.invited'], base.priglasil_47ae);

  @override
  String get rasshifrovka_e47f =>
      _resolve(const ['messenger.message.decrypting'], base.rasshifrovka_e47f);

  @override
  String get sistemnoeSoobschenie_d2bd => _resolve(
      const ['mobile.sistemnoeSoobschenie_d2bd', 'sistemnoeSoobschenie_d2bd'],
      base.sistemnoeSoobschenie_d2bd);

  @override
  String get soobschenie_3715 =>
      _resolve(const ['messenger.input.message'], base.soobschenie_3715);

  @override
  String get videosoobschenie_57f1 => _resolve(
      const ['mobile.videosoobschenie_57f1', 'videosoobschenie_57f1'],
      base.videosoobschenie_57f1);

  @override
  String get spisokZadach_cfa4 => _resolve(
      const ['mobile.spisokZadach_cfa4', 'spisokZadach_cfa4'],
      base.spisokZadach_cfa4);

  @override
  String get opros_5902 => _resolve(const [
        'messenger.attach.pollShort',
        'messenger.pollModal.defaultQuestion'
      ], base.opros_5902);

  @override
  String get vlozhenie_ef44 => _resolve(
      const ['mobile.vlozhenie_ef44', 'vlozhenie_ef44'], base.vlozhenie_ef44);

  @override
  String get fayl_2d46 => _resolve(
      const ['messenger.attach.uploadFile', 'messenger.attach.file'],
      base.fayl_2d46);

  @override
  String get zagruzkaFayla_f817 => _resolve(
      const ['mobile.zagruzkaFayla_f817', 'zagruzkaFayla_f817'],
      base.zagruzkaFayla_f817);

  @override
  String get ishodyaschiyZvonok_8381 => _resolve(
      const ['messenger.calls.outgoing'], base.ishodyaschiyZvonok_8381);

  @override
  String get razgovorNeSostoyalsya_67fb => _resolve(
      const ['messenger.calls.unanswered'], base.razgovorNeSostoyalsya_67fb);

  @override
  String get vhodyaschiyZvonok_5ce9 => _resolve(
      const ['messenger.calls.incoming', 'messenger.call.incoming'],
      base.vhodyaschiyZvonok_5ce9);

  @override
  String get otklonennyyZvonok_d499 =>
      _resolve(const ['messenger.calls.rejected'], base.otklonennyyZvonok_d499);

  @override
  String get vyOtkloniliVyzov_8d1d =>
      _resolve(const ['messenger.calls.declined'], base.vyOtkloniliVyzov_8d1d);

  @override
  String get propuschennyyZvonok_e98d =>
      _resolve(const ['messenger.calls.missed'], base.propuschennyyZvonok_e98d);

  @override
  String get vyPropustiliVyzov_f17a => _resolve(
      const ['messenger.calls.missedByYou'], base.vyPropustiliVyzov_f17a);

  @override
  String get vlozhenie_2474 => _resolve(
      const ['mobile.vlozhenie_2474', 'vlozhenie_2474'], base.vlozhenie_2474);

  @override
  String get tb_0e05 =>
      _resolve(const ['mobile.tb_0e05', 'tb_0e05'], base.tb_0e05);

  @override
  String get zapisGolosovogo_9c91 => _resolve(
      const ['mobile.zapisGolosovogo_9c91', 'zapisGolosovogo_9c91'],
      base.zapisGolosovogo_9c91);

  @override
  String get zapisVideo_dd2a => _resolve(
      const ['mobile.zapisVideo_dd2a', 'zapisVideo_dd2a'],
      base.zapisVideo_dd2a);

  @override
  String get otpustiteDlyaOtpravki_ea7b => _resolve(
      const ['mobile.otpustiteDlyaOtpravki_ea7b', 'otpustiteDlyaOtpravki_ea7b'],
      base.otpustiteDlyaOtpravki_ea7b);

  @override
  String get emodzi_f822 =>
      _resolve(const ['messenger.emoji.title'], base.emodzi_f822);

  @override
  String get panelEmodziVRazrabotke_b6ce => _resolve(const [
        'mobile.panelEmodziVRazrabotke_b6ce',
        'panelEmodziVRazrabotke_b6ce'
      ], base.panelEmodziVRazrabotke_b6ce);

  @override
  String get napisatSoobschenie_62d4 => _resolve(
      const ['mobile.napisatSoobschenie_62d4', 'napisatSoobschenie_62d4'],
      base.napisatSoobschenie_62d4);

  @override
  String get dobavitVlozhenie_769b => _resolve(
      const ['mobile.dobavitVlozhenie_769b', 'dobavitVlozhenie_769b'],
      base.dobavitVlozhenie_769b);

  @override
  String get spisokZadach_1852 => _resolve(
      const ['messenger.todoModal.title', 'messenger.attach.todoList'],
      base.spisokZadach_1852);

  @override
  String get opros_9f36 => _resolve(const [
        'messenger.attach.pollShort',
        'messenger.pollModal.defaultQuestion'
      ], base.opros_9f36);

  @override
  String get zapisGolosovogoGs_db4e => _resolve(
      const ['mobile.zapisGolosovogoGs_db4e', 'zapisGolosovogoGs_db4e'],
      base.zapisGolosovogoGs_db4e);

  @override
  String get zapisVideoVs_9676 => _resolve(
      const ['mobile.zapisVideoVs_9676', 'zapisVideoVs_9676'],
      base.zapisVideoVs_9676);

  @override
  String get uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3 => _resolve(const [
        'mobile.uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3',
        'uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3'
      ], base.uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3);

  @override
  String get novyyChat_f775 => _resolve(
      const ['mobile.novyyChat_f775', 'novyyChat_f775'], base.novyyChat_f775);

  @override
  String get imyaPolzovatelyaMin5Simvolov_1232 => _resolve(const [
        'mobile.imyaPolzovatelyaMin5Simvolov_1232',
        'imyaPolzovatelyaMin5Simvolov_1232'
      ], base.imyaPolzovatelyaMin5Simvolov_1232);

  @override
  String get vvedite5IliBoleeSimvolov_f983 => _resolve(const [
        'mobile.vvedite5IliBoleeSimvolov_f983',
        'vvedite5IliBoleeSimvolov_f983'
      ], base.vvedite5IliBoleeSimvolov_f983);

  @override
  String get polzovateliNeNaydeny_c01a => _resolve(
      const ['mobile.polzovateliNeNaydeny_c01a', 'polzovateliNeNaydeny_c01a'],
      base.polzovateliNeNaydeny_c01a);

  @override
  String get mnozhestvennyyVybor_9b60 => _resolve(
      const ['mobile.mnozhestvennyyVybor_9b60', 'mnozhestvennyyVybor_9b60'],
      base.mnozhestvennyyVybor_9b60);

  @override
  String get odinochnyyVybor_d920 => _resolve(
      const ['mobile.odinochnyyVybor_d920', 'odinochnyyVybor_d920'],
      base.odinochnyyVybor_d920);

  @override
  String get netGolosov_17d0 => _resolve(
      const ['mobile.netGolosov_17d0', 'netGolosov_17d0'],
      base.netGolosov_17d0);

  @override
  String get golos_6b94 =>
      _resolve(const ['about.timelineTag6Voice'], base.golos_6b94);

  @override
  String get golosa_bb8d =>
      _resolve(const ['mobile.golosa_bb8d', 'golosa_bb8d'], base.golosa_bb8d);

  @override
  String get golosov_7f51 => _resolve(
      const ['mobile.golosov_7f51', 'golosov_7f51'], base.golosov_7f51);

  @override
  String get nePoluchenIdFaylaOt_86c8 => _resolve(
      const ['mobile.nePoluchenIdFaylaOt_86c8', 'nePoluchenIdFaylaOt_86c8'],
      base.nePoluchenIdFaylaOt_86c8);

  @override
  String get faylZagruzhenIPrikreplen_dc24 => _resolve(const [
        'mobile.faylZagruzhenIPrikreplen_dc24',
        'faylZagruzhenIPrikreplen_dc24'
      ], base.faylZagruzhenIPrikreplen_dc24);

  @override
  String get neizvestnayaOshibkaZagruzki_68cb => _resolve(const [
        'mobile.neizvestnayaOshibkaZagruzki_68cb',
        'neizvestnayaOshibkaZagruzki_68cb'
      ], base.neizvestnayaOshibkaZagruzki_68cb);

  @override
  String get oshibkaZagruzkiFayla_86e5 => _resolve(
      const ['mobile.oshibkaZagruzkiFayla_86e5', 'oshibkaZagruzkiFayla_86e5'],
      base.oshibkaZagruzkiFayla_86e5);

  @override
  String get sohranitFaylKak_0f93 => _resolve(
      const ['mobile.sohranitFaylKak_0f93', 'sohranitFaylKak_0f93'],
      base.sohranitFaylKak_0f93);

  @override
  String get oshibkaSkachivaniyaFayla_34ac => _resolve(const [
        'mobile.oshibkaSkachivaniyaFayla_34ac',
        'oshibkaSkachivaniyaFayla_34ac'
      ], base.oshibkaSkachivaniyaFayla_34ac);

  @override
  String get bezNazvaniya_6584 => _resolve(
      const ['mobile.bezNazvaniya_6584', 'bezNazvaniya_6584'],
      base.bezNazvaniya_6584);

  @override
  String get bezVoprosa_d390 => _resolve(
      const ['mobile.bezVoprosa_d390', 'bezVoprosa_d390'],
      base.bezVoprosa_d390);

  @override
  String get netDostupaKMikrofonu_a4ef => _resolve(
      const ['mobile.netDostupaKMikrofonu_a4ef', 'netDostupaKMikrofonu_a4ef'],
      base.netDostupaKMikrofonu_a4ef);

  @override
  String get zapisVideoCherezPlaginCamera_b9dd => _resolve(const [
        'mobile.zapisVideoCherezPlaginCamera_b9dd',
        'zapisVideoCherezPlaginCamera_b9dd'
      ], base.zapisVideoCherezPlaginCamera_b9dd);

  @override
  String get kameraNeInitsializirovanaNaEtoy_21e0 => _resolve(const [
        'mobile.kameraNeInitsializirovanaNaEtoy_21e0',
        'kameraNeInitsializirovanaNaEtoy_21e0'
      ], base.kameraNeInitsializirovanaNaEtoy_21e0);

  @override
  String get kameraNeGotova_9f09 => _resolve(
      const ['mobile.kameraNeGotova_9f09', 'kameraNeGotova_9f09'],
      base.kameraNeGotova_9f09);

  @override
  String get zapisVideosoobscheniyaNaEtoyPlatforme_a561 => _resolve(const [
        'mobile.zapisVideosoobscheniyaNaEtoyPlatforme_a561',
        'zapisVideosoobscheniyaNaEtoyPlatforme_a561'
      ], base.zapisVideosoobscheniyaNaEtoyPlatforme_a561);

  @override
  String get arecordOstanovlen_edf2 => _resolve(
      const ['mobile.arecordOstanovlen_edf2', 'arecordOstanovlen_edf2'],
      base.arecordOstanovlen_edf2);

  @override
  String get ffmpegOstanovlen_63a0 => _resolve(
      const ['mobile.ffmpegOstanovlen_63a0', 'ffmpegOstanovlen_63a0'],
      base.ffmpegOstanovlen_63a0);

  @override
  String get zapisSlishkomKorotkaya_5cda => _resolve(const [
        'mobile.zapisSlishkomKorotkaya_5cda',
        'zapisSlishkomKorotkaya_5cda'
      ], base.zapisSlishkomKorotkaya_5cda);

  @override
  String get oshibkaZapisiFaylPust_106b => _resolve(
      const ['mobile.oshibkaZapisiFaylPust_106b', 'oshibkaZapisiFaylPust_106b'],
      base.oshibkaZapisiFaylPust_106b);

  @override
  String get videosoobschenieOtpravlenoSimulyatsiya_fb29 => _resolve(const [
        'mobile.videosoobschenieOtpravlenoSimulyatsiya_fb29',
        'videosoobschenieOtpravlenoSimulyatsiya_fb29'
      ], base.videosoobschenieOtpravlenoSimulyatsiya_fb29);

  @override
  String get zapisOtmenena_1609 => _resolve(
      const ['mobile.zapisOtmenena_1609', 'zapisOtmenena_1609'],
      base.zapisOtmenena_1609);

  @override
  String get otpravitGolosovoeSoobschenie_2481 => _resolve(const [
        'mobile.otpravitGolosovoeSoobschenie_2481',
        'otpravitGolosovoeSoobschenie_2481'
      ], base.otpravitGolosovoeSoobschenie_2481);

  @override
  String get imitatsiyaZapisiGolosovogoSoobscheniya_81e7 => _resolve(const [
        'mobile.imitatsiyaZapisiGolosovogoSoobscheniya_81e7',
        'imitatsiyaZapisiGolosovogoSoobscheniya_81e7'
      ], base.imitatsiyaZapisiGolosovogoSoobscheniya_81e7);

  @override
  String get otpravit_6da0 => _resolve(const [
        'messenger.buttons.send',
        'messenger.todoModal.send',
        'messenger.pollModal.send'
      ], base.otpravit_6da0);

  @override
  String get sozdatToDo_8c92 => _resolve(
      const ['mobile.sozdatToDo_8c92', 'sozdatToDo_8c92'],
      base.sozdatToDo_8c92);

  @override
  String get nazvanieSpiska_c3cc => _resolve(
      const ['messenger.todoModal.listNameLabel'], base.nazvanieSpiska_c3cc);

  @override
  String get punkty_0481 =>
      _resolve(const ['messenger.todoModal.itemsLabel'], base.punkty_0481);

  @override
  String get dobavitPunkt_930c =>
      _resolve(const ['messenger.todoModal.addItem'], base.dobavitPunkt_930c);

  @override
  String get sozdat_b059 =>
      _resolve(const ['messenger.buttons.create'], base.sozdat_b059);

  @override
  String get sozdatOpros_4b9e => _resolve(
      const ['messenger.pollModal.title', 'messenger.attach.poll'],
      base.sozdatOpros_4b9e);

  @override
  String get vopros_0911 =>
      _resolve(const ['messenger.pollModal.questionLabel'], base.vopros_0911);

  @override
  String get variantyOtveta_ef4e => _resolve(
      const ['messenger.pollModal.optionsLabel'], base.variantyOtveta_ef4e);

  @override
  String get dobavitVariant_76be => _resolve(
      const ['messenger.pollModal.addOption'], base.dobavitVariant_76be);

  @override
  String get golosovoeSoobschenie_33d5 => _resolve(
      const ['mobile.golosovoeSoobschenie_33d5', 'golosovoeSoobschenie_33d5'],
      base.golosovoeSoobschenie_33d5);

  @override
  String get videosoobschenie_2951 => _resolve(
      const ['mobile.videosoobschenie_2951', 'videosoobschenie_2951'],
      base.videosoobschenie_2951);

  @override
  String get video_a095 =>
      _resolve(const ['about.timelineTag6Video'], base.video_a095);

  @override
  String get neUdalosZagruzitIzobrazhenie_3fa0 => _resolve(const [
        'mobile.neUdalosZagruzitIzobrazhenie_3fa0',
        'neUdalosZagruzitIzobrazhenie_3fa0'
      ], base.neUdalosZagruzitIzobrazhenie_3fa0);

  @override
  String get muzyka_0660 =>
      _resolve(const ['messenger.chatInfo.music'], base.muzyka_0660);

  @override
  String get netDannyh_dee9 => _resolve(
      const ['mobile.netDannyh_dee9', 'netDannyh_dee9'], base.netDannyh_dee9);

  @override
  String get istoriyaSoobscheniyPustaIliChat_2d07 => _resolve(const [
        'mobile.istoriyaSoobscheniyPustaIliChat_2d07',
        'istoriyaSoobscheniyPustaIliChat_2d07'
      ], base.istoriyaSoobscheniyPustaIliChat_2d07);

  @override
  String get obschieMaterialy_11e4 => _resolve(
      const ['mobile.obschieMaterialy_11e4', 'obschieMaterialy_11e4'],
      base.obschieMaterialy_11e4);

  @override
  String get netMediafaylov_08d2 =>
      _resolve(const ['messenger.chatInfo.noMedia'], base.netMediafaylov_08d2);

  @override
  String get zdesBudutOtobrazhatsyaObschieFoto_9bc7 => _resolve(const [
        'mobile.zdesBudutOtobrazhatsyaObschieFoto_9bc7',
        'zdesBudutOtobrazhatsyaObschieFoto_9bc7'
      ], base.zdesBudutOtobrazhatsyaObschieFoto_9bc7);

  @override
  String get netFaylov_e95e =>
      _resolve(const ['messenger.chatInfo.noFiles'], base.netFaylov_e95e);

  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c => _resolve(const [
        'mobile.zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c',
        'zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c'
      ], base.zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c);

  @override
  String get netGolosovyhSoobscheniy_2427 => _resolve(
      const ['messenger.chatInfo.noVoice'], base.netGolosovyhSoobscheniy_2427);

  @override
  String get zdesBudutOtobrazhatsyaGolosovyeI_0a73 => _resolve(const [
        'mobile.zdesBudutOtobrazhatsyaGolosovyeI_0a73',
        'zdesBudutOtobrazhatsyaGolosovyeI_0a73'
      ], base.zdesBudutOtobrazhatsyaGolosovyeI_0a73);

  @override
  String get netSsylok_b0ec => _resolve(
      const ['mobile.netSsylok_b0ec', 'netSsylok_b0ec'], base.netSsylok_b0ec);

  @override
  String get zdesBudutOtobrazhatsyaObschieSsylki_6b61 => _resolve(const [
        'mobile.zdesBudutOtobrazhatsyaObschieSsylki_6b61',
        'zdesBudutOtobrazhatsyaObschieSsylki_6b61'
      ], base.zdesBudutOtobrazhatsyaObschieSsylki_6b61);

  @override
  String get ssylkaSkopirovanaVBufer_c16e => _resolve(const [
        'mobile.ssylkaSkopirovanaVBufer_c16e',
        'ssylkaSkopirovanaVBufer_c16e'
      ], base.ssylkaSkopirovanaVBufer_c16e);

  @override
  String get netMuzyki_1ca3 =>
      _resolve(const ['messenger.chatInfo.noMusic'], base.netMuzyki_1ca3);

  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23 => _resolve(const [
        'mobile.zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23',
        'zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23'
      ], base.zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23);

  @override
  String get udalennyyAkkaunt_ce47 => _resolve(
      const ['messenger.system.deletedAccount'], base.udalennyyAkkaunt_ce47);

  @override
  String get opisanie_38ca => _resolve(const [
        'messenger.editChat.description',
        'knowledgeBase.doc.thDesc',
        'knowledgeBase.bots.thDesc',
        'knowledgeBase.customLang.thDesc'
      ], base.opisanie_38ca);

  @override
  String get mobilnyy_5ac7 => _resolve(
      const ['mobile.mobilnyy_5ac7', 'mobilnyy_5ac7'], base.mobilnyy_5ac7);

  @override
  String get bylANedavno_168d => _resolve(
      const ['messenger.status.lastSeenRecently'], base.bylANedavno_168d);

  @override
  String get minutu_5373 =>
      _resolve(const ['messenger.datetime.minute.one'], base.minutu_5373);

  @override
  String get minuty_5bc9 => _resolve(
      const ['messenger.datetime.minute.few', 'messenger.time.minutes'],
      base.minuty_5bc9);

  @override
  String get minut_b877 => _resolve(const [
        'messenger.datetime.minute.many',
        'messenger.datetime.minute.other'
      ], base.minut_b877);

  @override
  String get nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a => _resolve(const [
        'mobile.nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a',
        'nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a'
      ], base.nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a);

  @override
  String get poiskLyudeyBotovGrupp_e84e =>
      _resolve(const ['messenger.search'], base.poiskLyudeyBotovGrupp_e84e);

  @override
  String get vveditePoiskovyyZapros_0b8c => _resolve(const [
        'mobile.vveditePoiskovyyZapros_0b8c',
        'vveditePoiskovyyZapros_0b8c'
      ], base.vveditePoiskovyyZapros_0b8c);

  @override
  String get polzovateli_b8c4 =>
      _resolve(const ['messenger.searchSection.users'], base.polzovateli_b8c4);

  @override
  String get moiLichnyeSoobscheniya_7d3b => _resolve(const [
        'mobile.moiLichnyeSoobscheniya_7d3b',
        'moiLichnyeSoobscheniya_7d3b'
      ], base.moiLichnyeSoobscheniya_7d3b);

  @override
  String get sozdatNovyyChat_fd41 =>
      _resolve(const ['messenger.createChat.title'], base.sozdatNovyyChat_fd41);

  @override
  String get lichnyyChat_cbec => _resolve(const [
        'messenger.createChat.newMessageTitle',
        'knowledgeBase.bots.chatPersonal'
      ], base.lichnyyChat_cbec);

  @override
  String get nachatObschenieSPolzovatelem_0578 => _resolve(
      const ['messenger.createChat.newMessageDesc'],
      base.nachatObschenieSPolzovatelem_0578);

  @override
  String get sozdatGruppu_459f => _resolve(
      const ['messenger.createGroup.title', 'messenger.createChat.groupTitle'],
      base.sozdatGruppu_459f);

  @override
  String get gruppovoyChatDlyaObscheniyaS_01ba => _resolve(
      const ['messenger.createGroup.desc', 'messenger.createChat.groupDesc'],
      base.gruppovoyChatDlyaObscheniyaS_01ba);

  @override
  String get sozdatKanal_9022 => _resolve(const [
        'messenger.createChannel.title',
        'messenger.createChat.channelTitle'
      ], base.sozdatKanal_9022);

  @override
  String get kanalDlyaShirokoyAuditorii_9dba => _resolve(const [
        'messenger.createChannel.desc',
        'messenger.createChat.channelDesc'
      ], base.kanalDlyaShirokoyAuditorii_9dba);

  @override
  String get redaktirovanie_1167 => _resolve(
      const ['mobile.redaktirovanie_1167', 'redaktirovanie_1167'],
      base.redaktirovanie_1167);

  @override
  String get vlevo_1af1 =>
      _resolve(const ['mobile.vlevo_1af1', 'vlevo_1af1'], base.vlevo_1af1);

  @override
  String get vpravo_c316 =>
      _resolve(const ['mobile.vpravo_c316', 'vpravo_c316'], base.vpravo_c316);

  @override
  String get poGor_ff50 =>
      _resolve(const ['mobile.poGor_ff50', 'poGor_ff50'], base.poGor_ff50);

  @override
  String get poVert_b4a9 =>
      _resolve(const ['mobile.poVert_b4a9', 'poVert_b4a9'], base.poVert_b4a9);

  @override
  String get vvediteNazvanieGruppy_0a69 => _resolve(
      const ['messenger.createGroup.namePlaceholder'],
      base.vvediteNazvanieGruppy_0a69);

  @override
  String get dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0 => _resolve(const [
        'mobile.dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0',
        'dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0'
      ], base.dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0);

  @override
  String get gruppaSozdana_6b3b => _resolve(
      const ['mobile.gruppaSozdana_6b3b', 'gruppaSozdana_6b3b'],
      base.gruppaSozdana_6b3b);

  @override
  String get oshibkaPriSozdaniiGruppy_794e => _resolve(const [
        'mobile.oshibkaPriSozdaniiGruppy_794e',
        'oshibkaPriSozdaniiGruppy_794e'
      ], base.oshibkaPriSozdaniiGruppy_794e);

  @override
  String get nazhmiteNaIkonkuChtobyVybrat_af03 => _resolve(const [
        'mobile.nazhmiteNaIkonkuChtobyVybrat_af03',
        'nazhmiteNaIkonkuChtobyVybrat_af03'
      ], base.nazhmiteNaIkonkuChtobyVybrat_af03);

  @override
  String get nazvanieGruppy_9a39 => _resolve(
      const ['messenger.createGroup.nameDisplay', 'messenger.createGroup.name'],
      base.nazvanieGruppy_9a39);

  @override
  String get opisanieNeobyazatelno_7812 => _resolve(
      const ['mobile.opisanieNeobyazatelno_7812', 'opisanieNeobyazatelno_7812'],
      base.opisanieNeobyazatelno_7812);

  @override
  String get privatnayaGruppa_d20e => _resolve(
      const ['messenger.createGroup.private'], base.privatnayaGruppa_d20e);

  @override
  String get publichnayaGruppa_50f8 => _resolve(
      const ['messenger.createGroup.public'], base.publichnayaGruppa_50f8);

  @override
  String get vhodTolkoPoPriglasheniyu_97a1 => _resolve(
      const ['messenger.createGroup.privateDescription'],
      base.vhodTolkoPoPriglasheniyu_97a1);

  @override
  String get lyuboyMozhetNaytiIVstupit_5e26 => _resolve(
      const ['messenger.createGroup.typeDescription'],
      base.lyuboyMozhetNaytiIVstupit_5e26);

  @override
  String get publichnayaSsylkanikneymMyGroup_6640 => _resolve(
      const ['messenger.createGroup.nickname'],
      base.publichnayaSsylkanikneymMyGroup_6640);

  @override
  String get vvediteNazvanieKanala_5536 => _resolve(
      const ['messenger.createChannel.namePlaceholder'],
      base.vvediteNazvanieKanala_5536);

  @override
  String get dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06 =>
      _resolve(const [
        'mobile.dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06',
        'dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06'
      ], base.dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06);

  @override
  String get kanalSozdan_1522 => _resolve(
      const ['mobile.kanalSozdan_1522', 'kanalSozdan_1522'],
      base.kanalSozdan_1522);

  @override
  String get oshibkaPriSozdaniiKanala_7d4b => _resolve(const [
        'mobile.oshibkaPriSozdaniiKanala_7d4b',
        'oshibkaPriSozdaniiKanala_7d4b'
      ], base.oshibkaPriSozdaniiKanala_7d4b);

  @override
  String get nazvanieKanala_c548 => _resolve(const [
        'messenger.createChannel.nameDisplay',
        'messenger.createChannel.name'
      ], base.nazvanieKanala_c548);

  @override
  String get privatnyyKanal_3139 => _resolve(
      const ['messenger.createChannel.private'], base.privatnyyKanal_3139);

  @override
  String get publichnyyKanal_0f7c => _resolve(
      const ['messenger.createChannel.public'], base.publichnyyKanal_0f7c);

  @override
  String get podpiskaTolkoPoPriglasheniyu_99c3 => _resolve(
      const ['messenger.createChannel.privateDescription'],
      base.podpiskaTolkoPoPriglasheniyu_99c3);

  @override
  String get lyuboyMozhetNaytiIPodpisatsya_8579 => _resolve(
      const ['messenger.createChannel.typeDescription'],
      base.lyuboyMozhetNaytiIPodpisatsya_8579);

  @override
  String get ssylkanikneymKanalaMychannel_79f6 => _resolve(
      const ['messenger.createChannel.nickname'],
      base.ssylkanikneymKanalaMychannel_79f6);

  @override
  String get yazykInterfeysa_b78b => _resolve(
      const ['messenger.generalSettings.language'], base.yazykInterfeysa_b78b);

  @override
  String get dannyeUspeshnoSohraneny_2cc5 => _resolve(const [
        'mobile.dannyeUspeshnoSohraneny_2cc5',
        'dannyeUspeshnoSohraneny_2cc5'
      ], base.dannyeUspeshnoSohraneny_2cc5);

  @override
  String get oshibkaPriSohranenii_126f => _resolve(
      const ['messenger.toasts.saveError'], base.oshibkaPriSohranenii_126f);

  @override
  String get lichnyeDannye_10a7 => _resolve(const [
        'messenger.settings.personalTitle',
        'messenger.personal.sectionTitle'
      ], base.lichnyeDannye_10a7);

  @override
  String get nikneymUsername_8035 => _resolve(
      const ['mobile.nikneymUsername_8035', 'nikneymUsername_8035'],
      base.nikneymUsername_8035);

  @override
  String get nikneymNelzyaIzmenit_0b99 => _resolve(
      const ['mobile.nikneymNelzyaIzmenit_0b99', 'nikneymNelzyaIzmenit_0b99'],
      base.nikneymNelzyaIzmenit_0b99);

  @override
  String get oSebeBio_b730 => _resolve(
      const ['mobile.oSebeBio_b730', 'oSebeBio_b730'], base.oSebeBio_b730);

  @override
  String get rasskazhiteNemnogoOSebe_3daa => _resolve(const [
        'mobile.rasskazhiteNemnogoOSebe_3daa',
        'rasskazhiteNemnogoOSebe_3daa'
      ], base.rasskazhiteNemnogoOSebe_3daa);

  @override
  String get nastroykiPrivatnostiSohraneny_447c => _resolve(const [
        'mobile.nastroykiPrivatnostiSohraneny_447c',
        'nastroykiPrivatnostiSohraneny_447c'
      ], base.nastroykiPrivatnostiSohraneny_447c);

  @override
  String get privatnost_3098 => _resolve(
      const ['messenger.settings.privacyTitle', 'messenger.privacy.title'],
      base.privatnost_3098);

  @override
  String get kommunikatsii_e9b8 => _resolve(
      const ['messenger.privacy.communications'], base.kommunikatsii_e9b8);

  @override
  String get ktoMozhetPisat_3322 => _resolve(
      const ['mobile.ktoMozhetPisat_3322', 'ktoMozhetPisat_3322'],
      base.ktoMozhetPisat_3322);

  @override
  String get zapisGolosovyh_8073 => _resolve(
      const ['mobile.zapisGolosovyh_8073', 'zapisGolosovyh_8073'],
      base.zapisGolosovyh_8073);

  @override
  String get otpravkaFaylov_aaca => _resolve(
      const ['mobile.otpravkaFaylov_aaca', 'otpravkaFaylov_aaca'],
      base.otpravkaFaylov_aaca);

  @override
  String get priglashatVGruppy_3631 => _resolve(
      const ['mobile.priglashatVGruppy_3631', 'priglashatVGruppy_3631'],
      base.priglashatVGruppy_3631);

  @override
  String get vidimostProfilya_448f => _resolve(
      const ['messenger.privacy.profileVisibility'],
      base.vidimostProfilya_448f);

  @override
  String get ktoViditAvatar_b5d8 => _resolve(
      const ['mobile.ktoViditAvatar_b5d8', 'ktoViditAvatar_b5d8'],
      base.ktoViditAvatar_b5d8);

  @override
  String get vremyaVSeti_be29 => _resolve(
      const ['mobile.vremyaVSeti_be29', 'vremyaVSeti_be29'],
      base.vremyaVSeti_be29);

  @override
  String get vneshniyVid_5a0f =>
      _resolve(const ['settings.appearance'], base.vneshniyVid_5a0f);

  @override
  String get rezhimOformleniyaInterfeysa_b91d => _resolve(const [
        'mobile.rezhimOformleniyaInterfeysa_b91d',
        'rezhimOformleniyaInterfeysa_b91d'
      ], base.rezhimOformleniyaInterfeysa_b91d);

  @override
  String get pokazyvatVizualnyeEffektyIPerehody_3fd7 => _resolve(const [
        'mobile.pokazyvatVizualnyeEffektyIPerehody_3fd7',
        'pokazyvatVizualnyeEffektyIPerehody_3fd7'
      ], base.pokazyvatVizualnyeEffektyIPerehody_3fd7);

  @override
  String get razmerTeksta_3c4f => _resolve(
      const ['messenger.chatSettings.textSize'], base.razmerTeksta_3c4f);

  @override
  String get bezopasnost_fcbc => _resolve(const [
        'profile.nav.security',
        'profile.security.title',
        'aboutSection.title1'
      ], base.bezopasnost_fcbc);

  @override
  String get dvuhfaktornayaAutentifikatsiya_acdc => _resolve(const [
        'features.f5Title',
        'profile.security.tfa',
        'knowledgeBase.main.cardOverviewLi4'
      ], base.dvuhfaktornayaAutentifikatsiya_acdc);

  @override
  String get zaschitaAkkaunta2fa_f1ab => _resolve(
      const ['mobile.zaschitaAkkaunta2fa_f1ab', 'zaschitaAkkaunta2fa_f1ab'],
      base.zaschitaAkkaunta2fa_f1ab);

  @override
  String get vklyucheno_6b96 => _resolve(
      const ['profile.security.enabled', 'messenger.reactions.enabled'],
      base.vklyucheno_6b96);

  @override
  String get xaneoMobileAktivnoSeychas_3345 => _resolve(const [
        'mobile.xaneoMobileAktivnoSeychas_3345',
        'xaneoMobileAktivnoSeychas_3345'
      ], base.xaneoMobileAktivnoSeychas_3345);

  @override
  String get zaschischennyyMessendzher_2f59 => _resolve(const [
        'mobile.zaschischennyyMessendzher_2f59',
        'zaschischennyyMessendzher_2f59'
      ], base.zaschischennyyMessendzher_2f59);

  @override
  String get temnayaTema_6018 => _resolve(
      const ['mobile.temnayaTema_6018', 'temnayaTema_6018'],
      base.temnayaTema_6018);

  @override
  String get vklyuchenaPoUmolchaniyu_7610 => _resolve(const [
        'mobile.vklyuchenaPoUmolchaniyu_7610',
        'vklyuchenaPoUmolchaniyu_7610'
      ], base.vklyuchenaPoUmolchaniyu_7610);

  @override
  String get setevoyFiltr_40c2 => _resolve(
      const ['mobile.setevoyFiltr_40c2', 'setevoyFiltr_40c2'],
      base.setevoyFiltr_40c2);

  @override
  String get vklyuchen_0994 =>
      _resolve(const ['messenger.common.enabled'], base.vklyuchen_0994);

  @override
  String get spisokMuzyki_57d0 => _resolve(
      const ['mobile.spisokMuzyki_57d0', 'spisokMuzyki_57d0'],
      base.spisokMuzyki_57d0);

  @override
  String get trek_5049 =>
      _resolve(const ['mobile.trek_5049', 'trek_5049'], base.trek_5049);

  @override
  String get trekov_d3f4 =>
      _resolve(const ['mobile.trekov_d3f4', 'trekov_d3f4'], base.trekov_d3f4);

  @override
  String get pozhaluystaZapolniteVoprosIKak_7ad5 => _resolve(const [
        'mobile.pozhaluystaZapolniteVoprosIKak_7ad5',
        'pozhaluystaZapolniteVoprosIKak_7ad5'
      ], base.pozhaluystaZapolniteVoprosIKak_7ad5);

  @override
  String get sozdatOpros_8401 => _resolve(const [
        'messenger.pollModal.send',
        'messenger.attach.poll',
        'messenger.pollModal.title'
      ], base.sozdatOpros_8401);

  @override
  String get sozdatSpisokZadach_4018 => _resolve(
      const ['messenger.todoModal.title'], base.sozdatSpisokZadach_4018);

  @override
  String get pozhaluystaZapolniteNazvanieIKak_3783 => _resolve(const [
        'mobile.pozhaluystaZapolniteNazvanieIKak_3783',
        'pozhaluystaZapolniteNazvanieIKak_3783'
      ], base.pozhaluystaZapolniteNazvanieIKak_3783);

  @override
  String get sozdatSpisokZadach_0416 => _resolve(
      const ['messenger.todoModal.send'], base.sozdatSpisokZadach_0416);

  @override
  String get vhodyaschiyVideozvonok_14d4 => _resolve(
      const ['messenger.call.incoming', 'messenger.calls.incoming'],
      base.vhodyaschiyVideozvonok_14d4);

  @override
  String get prinyat_5dc5 =>
      _resolve(const ['messenger.call.accept'], base.prinyat_5dc5);

  @override
  String get netObschihFaylov_bf77 => _resolve(
      const ['messenger.chatInfo.noFiles'], base.netObschihFaylov_bf77);

  @override
  String get neUdalosRazarhivirovatChatNa_b6f6 => _resolve(const [
        'mobile.neUdalosRazarhivirovatChatNa_b6f6',
        'neUdalosRazarhivirovatChatNa_b6f6'
      ], base.neUdalosRazarhivirovatChatNa_b6f6);

  @override
  String get poiskVArhive_c5d8 => _resolve(
      const ['mobile.poiskVArhive_c5d8', 'poiskVArhive_c5d8'],
      base.poiskVArhive_c5d8);

  @override
  String get poprobuyteIzmenitZapros_52ea => _resolve(const [
        'mobile.poprobuyteIzmenitZapros_52ea',
        'poprobuyteIzmenitZapros_52ea'
      ], base.poprobuyteIzmenitZapros_52ea);

  @override
  String get zdesBudutNahoditsyaVashiArhivirovannye_7359 => _resolve(const [
        'mobile.zdesBudutNahoditsyaVashiArhivirovannye_7359',
        'zdesBudutNahoditsyaVashiArhivirovannye_7359'
      ], base.zdesBudutNahoditsyaVashiArhivirovannye_7359);

  @override
  String get vernut_54aa =>
      _resolve(const ['mobile.vernut_54aa', 'vernut_54aa'], base.vernut_54aa);

  @override
  String get zashifrovannoeSoobschenie_c9ab => _resolve(
      const ['messenger.message.encrypted'],
      base.zashifrovannoeSoobschenie_c9ab);

  @override
  String get soobschenieNahoditsyaVysheVIstorii_dc90 => _resolve(const [
        'mobile.soobschenieNahoditsyaVysheVIstorii_dc90',
        'soobschenieNahoditsyaVysheVIstorii_dc90'
      ], base.soobschenieNahoditsyaVysheVIstorii_dc90);

  @override
  String get otpravlyaetFoto_67c1 => _resolve(
      const ['messenger.status.sendingPhoto'], base.otpravlyaetFoto_67c1);

  @override
  String get otpravlyaetVideo_ce80 => _resolve(
      const ['messenger.status.sendingVideo'], base.otpravlyaetVideo_ce80);

  @override
  String get otpravlyaetFayl_5e88 => _resolve(
      const ['messenger.status.sendingFile'], base.otpravlyaetFayl_5e88);

  @override
  String get ktoTo_8405 =>
      _resolve(const ['mobile.ktoTo_8405', 'ktoTo_8405'], base.ktoTo_8405);

  @override
  String get trebuetsyaRazreshenieNaKameruI_06fa => _resolve(const [
        'mobile.trebuetsyaRazreshenieNaKameruI_06fa',
        'trebuetsyaRazreshenieNaKameruI_06fa'
      ], base.trebuetsyaRazreshenieNaKameruI_06fa);

  @override
  String get kameraNeNaydena_208d => _resolve(
      const ['mobile.kameraNeNaydena_208d', 'kameraNeNaydena_208d'],
      base.kameraNeNaydena_208d);

  @override
  String get zapisVideoOtmenena_1db7 => _resolve(
      const ['mobile.zapisVideoOtmenena_1db7', 'zapisVideoOtmenena_1db7'],
      base.zapisVideoOtmenena_1db7);

  @override
  String get slishkomKorotkoeVideosoobschenie_4676 => _resolve(const [
        'mobile.slishkomKorotkoeVideosoobschenie_4676',
        'slishkomKorotkoeVideosoobschenie_4676'
      ], base.slishkomKorotkoeVideosoobschenie_4676);

  @override
  String get pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35 =>
      _resolve(const [
        'mobile.pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35',
        'pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35'
      ], base.pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35);

  @override
  String get audiozvonok_dcf6 =>
      _resolve(const ['messenger.callType.audio'], base.audiozvonok_dcf6);

  @override
  String get otpravitFotoVideoAudioIli_37e9 => _resolve(const [
        'mobile.otpravitFotoVideoAudioIli_37e9',
        'otpravitFotoVideoAudioIli_37e9'
      ], base.otpravitFotoVideoAudioIli_37e9);

  @override
  String get provedenieGolosovaniyaVChate_a629 => _resolve(const [
        'mobile.provedenieGolosovaniyaVChate_a629',
        'provedenieGolosovaniyaVChate_a629'
      ], base.provedenieGolosovaniyaVChate_a629);

  @override
  String get sozdatToDoSpisok_cb50 => _resolve(
      const ['mobile.sozdatToDoSpisok_cb50', 'sozdatToDoSpisok_cb50'],
      base.sozdatToDoSpisok_cb50);

  @override
  String get spisokZadachSOtmetkamiVypolneniya_c778 => _resolve(const [
        'mobile.spisokZadachSOtmetkamiVypolneniya_c778',
        'spisokZadachSOtmetkamiVypolneniya_c778'
      ], base.spisokZadachSOtmetkamiVypolneniya_c778);

  @override
  String get trebuetsyaRazreshenieNaZapisAudio_8175 => _resolve(const [
        'mobile.trebuetsyaRazreshenieNaZapisAudio_8175',
        'trebuetsyaRazreshenieNaZapisAudio_8175'
      ], base.trebuetsyaRazreshenieNaZapisAudio_8175);

  @override
  String get slishkomKorotkoeSoobschenie_c2ee => _resolve(const [
        'mobile.slishkomKorotkoeSoobschenie_c2ee',
        'slishkomKorotkoeSoobschenie_c2ee'
      ], base.slishkomKorotkoeSoobschenie_c2ee);

  @override
  String get uderzhivayteKnopkuDlyaZapisi_a762 => _resolve(const [
        'mobile.uderzhivayteKnopkuDlyaZapisi_a762',
        'uderzhivayteKnopkuDlyaZapisi_a762'
      ], base.uderzhivayteKnopkuDlyaZapisi_a762);

  @override
  String get udalennyy_40c6 => _resolve(
      const ['mobile.udalennyy_40c6', 'udalennyy_40c6'], base.udalennyy_40c6);

  @override
  String get udalennyy_c2c8 => _resolve(
      const ['mobile.udalennyy_c2c8', 'udalennyy_c2c8'], base.udalennyy_c2c8);

  @override
  String get neobhodimyRazresheniyaNaMikrofonI_224b => _resolve(const [
        'mobile.neobhodimyRazresheniyaNaMikrofonI_224b',
        'neobhodimyRazresheniyaNaMikrofonI_224b'
      ], base.neobhodimyRazresheniyaNaMikrofonI_224b);

  @override
  String get bylATolkoChto_9ac0 => _resolve(
      const ['mobile.bylATolkoChto_9ac0', 'bylATolkoChto_9ac0'],
      base.bylATolkoChto_9ac0);

  @override
  String get chatNeNayden_ba4f => _resolve(
      const ['mobile.chatNeNayden_ba4f', 'chatNeNayden_ba4f'],
      base.chatNeNayden_ba4f);

  @override
  String get napishitePervoeSoobschenie_8260 => _resolve(const [
        'mobile.napishitePervoeSoobschenie_8260',
        'napishitePervoeSoobschenie_8260'
      ], base.napishitePervoeSoobschenie_8260);

  @override
  String get prisoedinitsyaKKanalu_f863 => _resolve(
      const ['mobile.prisoedinitsyaKKanalu_f863', 'prisoedinitsyaKKanalu_f863'],
      base.prisoedinitsyaKKanalu_f863);

  @override
  String get vyPodpisany_5fb9 => _resolve(
      const ['mobile.vyPodpisany_5fb9', 'vyPodpisany_5fb9'],
      base.vyPodpisany_5fb9);

  @override
  String get otpisatsya_ee2d => _resolve(
      const ['mobile.otpisatsya_ee2d', 'otpisatsya_ee2d'],
      base.otpisatsya_ee2d);

  @override
  String get vyUspeshnoPodpisalisNaKanal_9c99 => _resolve(const [
        'mobile.vyUspeshnoPodpisalisNaKanal_9c99',
        'vyUspeshnoPodpisalisNaKanal_9c99'
      ], base.vyUspeshnoPodpisalisNaKanal_9c99);

  @override
  String get vyUspeshnoVstupiliVGruppu_61a1 => _resolve(const [
        'mobile.vyUspeshnoVstupiliVGruppu_61a1',
        'vyUspeshnoVstupiliVGruppu_61a1'
      ], base.vyUspeshnoVstupiliVGruppu_61a1);

  @override
  String get neUdalosPrisoedinitsyaPoprobuyteEsche_bce5 => _resolve(const [
        'mobile.neUdalosPrisoedinitsyaPoprobuyteEsche_bce5',
        'neUdalosPrisoedinitsyaPoprobuyteEsche_bce5'
      ], base.neUdalosPrisoedinitsyaPoprobuyteEsche_bce5);

  @override
  String get vyrezat_a195 => _resolve(
      const ['mobile.vyrezat_a195', 'vyrezat_a195'], base.vyrezat_a195);

  @override
  String get kopirovat_112b => _resolve(
      const ['messenger.message.copy', 'knowledgeBase.doc.copy'],
      base.kopirovat_112b);

  @override
  String get vstavit_dcc4 => _resolve(
      const ['mobile.vstavit_dcc4', 'vstavit_dcc4'], base.vstavit_dcc4);

  @override
  String get vybratVse_4d09 => _resolve(
      const ['mobile.vybratVse_4d09', 'vybratVse_4d09'], base.vybratVse_4d09);

  @override
  String get zhirnyy_7774 => _resolve(
      const ['mobile.zhirnyy_7774', 'zhirnyy_7774'], base.zhirnyy_7774);

  @override
  String get kursiv_e0b1 =>
      _resolve(const ['mobile.kursiv_e0b1', 'kursiv_e0b1'], base.kursiv_e0b1);

  @override
  String get kod_3f34 =>
      _resolve(const ['knowledgeBase.bots.thCode'], base.kod_3f34);

  @override
  String get zacherknut_02fc => _resolve(
      const ['mobile.zacherknut_02fc', 'zacherknut_02fc'],
      base.zacherknut_02fc);

  @override
  String get soobschenie_8b9b =>
      _resolve(const ['messenger.input.message'], base.soobschenie_8b9b);

  @override
  String get smahniteDlyaOtmeny_e976 => _resolve(
      const ['mobile.smahniteDlyaOtmeny_e976', 'smahniteDlyaOtmeny_e976'],
      base.smahniteDlyaOtmeny_e976);

  @override
  String get poisk_bfc9 => _resolve(
      const ['messenger.context.search', 'messenger.search'], base.poisk_bfc9);

  @override
  String get udalitChat_4b2b => _resolve(const [
        'messenger.context.deleteChat',
        'messenger.delete.deleteChatTitle'
      ], base.udalitChat_4b2b);

  @override
  String get udalitKanal_482f => _resolve(
      const ['messenger.context.deleteChannel'], base.udalitKanal_482f);

  @override
  String get pozhalovatsya_a7d9 =>
      _resolve(const ['messenger.context.report'], base.pozhalovatsya_a7d9);

  @override
  String get redaktirovatGruppu_e40a => _resolve(const [
        'messenger.context.editGroup',
        'messenger.editChat.editGroupTitle'
      ], base.redaktirovatGruppu_e40a);

  @override
  String get udalitGruppu_dff8 =>
      _resolve(const ['messenger.context.deleteGroup'], base.udalitGruppu_dff8);

  @override
  String get poiskSoobscheniyVremennoNedostupenV_4443 => _resolve(const [
        'mobile.poiskSoobscheniyVremennoNedostupenV_4443',
        'poiskSoobscheniyVremennoNedostupenV_4443'
      ], base.poiskSoobscheniyVremennoNedostupenV_4443);

  @override
  String get zhalobaOtpravlenaModeratoram_4547 => _resolve(const [
        'mobile.zhalobaOtpravlenaModeratoram_4547',
        'zhalobaOtpravlenaModeratoram_4547'
      ], base.zhalobaOtpravlenaModeratoram_4547);

  @override
  String get redaktirovanieGruppyVremennoNedostupnoV_05d0 => _resolve(const [
        'mobile.redaktirovanieGruppyVremennoNedostupnoV_05d0',
        'redaktirovanieGruppyVremennoNedostupnoV_05d0'
      ], base.redaktirovanieGruppyVremennoNedostupnoV_05d0);

  @override
  String get vyUverenyChtoHotiteOchistit_7c3a => _resolve(const [
        'mobile.vyUverenyChtoHotiteOchistit_7c3a',
        'vyUverenyChtoHotiteOchistit_7c3a'
      ], base.vyUverenyChtoHotiteOchistit_7c3a);

  @override
  String get ochistit_7074 => _resolve(const [
        'messenger.delete.buttons.clear',
        'messenger.moderation.clearAction'
      ], base.ochistit_7074);

  @override
  String get udalit_ed2b => _resolve(const [
        'profile.settings.deleteAccountBtn',
        'messenger.buttons.delete',
        'messenger.delete.buttons.delete',
        'messenger.moderation.deleteAction'
      ], base.udalit_ed2b);

  @override
  String get vyyti_0f05 =>
      _resolve(const ['profile.nav.logout'], base.vyyti_0f05);

  @override
  String get oshibkaVosproizvedeniya_ac8a => _resolve(const [
        'mobile.oshibkaVosproizvedeniya_ac8a',
        'oshibkaVosproizvedeniya_ac8a'
      ], base.oshibkaVosproizvedeniya_ac8a);

  @override
  String get novoeZashifrovannoeSoobschenie_4d30 => _resolve(const [
        'mobile.novoeZashifrovannoeSoobschenie_4d30',
        'novoeZashifrovannoeSoobschenie_4d30'
      ], base.novoeZashifrovannoeSoobschenie_4d30);

  @override
  String get poiskChatov_779c => _resolve(
      const ['messenger.forward.searchPlaceholder'], base.poiskChatov_779c);

  @override
  String get obnovlenie_53e2 => _resolve(
      const ['mobile.obnovlenie_53e2', 'obnovlenie_53e2'],
      base.obnovlenie_53e2);

  @override
  String get soedinenie_5a58 => _resolve(
      const ['mobile.soedinenie_5a58', 'soedinenie_5a58'],
      base.soedinenie_5a58);

  @override
  String get lichnye_4cb3 => _resolve(
      const ['mobile.lichnye_4cb3', 'lichnye_4cb3'], base.lichnye_4cb3);

  @override
  String get neUdalosArhivirovatChatNa_36aa => _resolve(const [
        'mobile.neUdalosArhivirovatChatNa_36aa',
        'neUdalosArhivirovatChatNa_36aa'
      ], base.neUdalosArhivirovatChatNa_36aa);

  @override
  String get oshibkaZagruzkiChatov_902f => _resolve(
      const ['mobile.oshibkaZagruzkiChatov_902f', 'oshibkaZagruzkiChatov_902f'],
      base.oshibkaZagruzkiChatov_902f);

  @override
  String get povtorit_b914 => _resolve(
      const ['mobile.povtorit_b914', 'povtorit_b914'], base.povtorit_b914);

  @override
  String get netChatov_85e3 => _resolve(
      const ['mobile.netChatov_85e3', 'netChatov_85e3'], base.netChatov_85e3);

  @override
  String get nachniteNovyyRazgovor_8290 => _resolve(
      const ['mobile.nachniteNovyyRazgovor_8290', 'nachniteNovyyRazgovor_8290'],
      base.nachniteNovyyRazgovor_8290);

  @override
  String get neUdalosZagruzitAkkaunty_8570 => _resolve(const [
        'mobile.neUdalosZagruzitAkkaunty_8570',
        'neUdalosZagruzitAkkaunty_8570'
      ], base.neUdalosZagruzitAkkaunty_8570);

  @override
  String get vyberiteAkkaunt_79e7 => _resolve(
      const ['mobile.vyberiteAkkaunt_79e7', 'vyberiteAkkaunt_79e7'],
      base.vyberiteAkkaunt_79e7);

  @override
  String get bystryyVhodNaEtomUstroystve_3f30 => _resolve(const [
        'mobile.bystryyVhodNaEtomUstroystve_3f30',
        'bystryyVhodNaEtomUstroystve_3f30'
      ], base.bystryyVhodNaEtomUstroystve_3f30);

  @override
  String get voytiSParolem_9277 => _resolve(
      const ['mobile.voytiSParolem_9277', 'voytiSParolem_9277'],
      base.voytiSParolem_9277);

  @override
  String get sozdatXaneoId_4033 => _resolve(
      const ['mobile.sozdatXaneoId_4033', 'sozdatXaneoId_4033'],
      base.sozdatXaneoId_4033);

  @override
  String get netSohranennyhAkkauntov_b669 => _resolve(const [
        'mobile.netSohranennyhAkkauntov_b669',
        'netSohranennyhAkkauntov_b669'
      ], base.netSohranennyhAkkauntov_b669);

  @override
  String get tolkoChto_4493 => _resolve(
      const ['messenger.status.recentlyOnline', 'messenger.datetime.justNow'],
      base.tolkoChto_4493);

  @override
  String get emailNedostupen_fc3e => _resolve(
      const ['mobile.emailNedostupen_fc3e', 'emailNedostupen_fc3e'],
      base.emailNedostupen_fc3e);

  @override
  String get nevernyyKod_50f9 => _resolve(
      const ['mobile.nevernyyKod_50f9', 'nevernyyKod_50f9'],
      base.nevernyyKod_50f9);

  @override
  String get oshibkaProverkiKoda_9018 => _resolve(
      const ['mobile.oshibkaProverkiKoda_9018', 'oshibkaProverkiKoda_9018'],
      base.oshibkaProverkiKoda_9018);

  @override
  String get neobhodimoRazreshenieNaDostupK_5f5c => _resolve(const [
        'mobile.neobhodimoRazreshenieNaDostupK_5f5c',
        'neobhodimoRazreshenieNaDostupK_5f5c'
      ], base.neobhodimoRazreshenieNaDostupK_5f5c);

  @override
  String get oVyboreEmail_2609 => _resolve(
      const ['mobile.oVyboreEmail_2609', 'oVyboreEmail_2609'],
      base.oVyboreEmail_2609);

  @override
  String get podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0 =>
      _resolve(const [
        'mobile.podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0',
        'podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0'
      ], base.podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0);

  @override
  String get zapreschennyh_1f49 => _resolve(
      const ['mobile.zapreschennyh_1f49', 'zapreschennyh_1f49'],
      base.zapreschennyh_1f49);

  @override
  String get obIspolzovaniiParolya_9739 => _resolve(
      const ['mobile.obIspolzovaniiParolya_9739', 'obIspolzovaniiParolya_9739'],
      base.obIspolzovaniiParolya_9739);

  @override
  String get parolTolkoDlyaAvariynogoVhoda_b142 => _resolve(const [
        'mobile.parolTolkoDlyaAvariynogoVhoda_b142',
        'parolTolkoDlyaAvariynogoVhoda_b142'
      ], base.parolTolkoDlyaAvariynogoVhoda_b142);

  @override
  String get sozdatAkkaunt_19ed => _resolve(
      const ['about.ctaAccount', 'cta.register'], base.sozdatAkkaunt_19ed);

  @override
  String get naprimerIvan_d7cb => _resolve(
      const ['mobile.naprimerIvan_d7cb', 'naprimerIvan_d7cb'],
      base.naprimerIvan_d7cb);

  @override
  String get zadayteParol_53d2 => _resolve(
      const ['mobile.zadayteParol_53d2', 'zadayteParol_53d2'],
      base.zadayteParol_53d2);

  @override
  String get minimum8Simvolov_4ccd => _resolve(
      const ['profile.security.newPasswordPlaceholder'],
      base.minimum8Simvolov_4ccd);

  @override
  String get unikalnoeImyaDlyaVashegoProfilya_a0ea => _resolve(const [
        'mobile.unikalnoeImyaDlyaVashegoProfilya_a0ea',
        'unikalnoeImyaDlyaVashegoProfilya_a0ea'
      ], base.unikalnoeImyaDlyaVashegoProfilya_a0ea);

  @override
  String get vashEmail_879d =>
      _resolve(const ['registerStep3Title'], base.vashEmail_879d);

  @override
  String get dlyaSvyaziIVosstanovleniyaDostupa_c770 => _resolve(const [
        'mobile.dlyaSvyaziIVosstanovleniyaDostupa_c770',
        'dlyaSvyaziIVosstanovleniyaDostupa_c770'
      ], base.dlyaSvyaziIVosstanovleniyaDostupa_c770);

  @override
  String get emailAdres_9130 => _resolve(
      const ['mobile.emailAdres_9130', 'emailAdres_9130'],
      base.emailAdres_9130);

  @override
  String get vvediteParolEscheRaz_7383 => _resolve(
      const ['mobile.vvediteParolEscheRaz_7383', 'vvediteParolEscheRaz_7383'],
      base.vvediteParolEscheRaz_7383);

  @override
  String get parolEscheRaz_6daf => _resolve(
      const ['mobile.parolEscheRaz_6daf', 'parolEscheRaz_6daf'],
      base.parolEscheRaz_6daf);

  @override
  String get paroliNeSovpadayut_d82f => _resolve(
      const ['register.passwordsDontMatch'], base.paroliNeSovpadayut_d82f);

  @override
  String get ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed => _resolve(const [
        'mobile.ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed',
        'ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed'
      ], base.ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed);

  @override
  String get ddmmgggg_3524 => _resolve(
      const ['mobile.ddmmgggg_3524', 'ddmmgggg_3524'], base.ddmmgggg_3524);

  @override
  String get sdelayteProfilUznavaemym_f2c5 => _resolve(const [
        'mobile.sdelayteProfilUznavaemym_f2c5',
        'sdelayteProfilUznavaemym_f2c5'
      ], base.sdelayteProfilUznavaemym_f2c5);

  @override
  String get profilGotov_b57d => _resolve(
      const ['mobile.profilGotov_b57d', 'profilGotov_b57d'],
      base.profilGotov_b57d);

  @override
  String get ostalosVsegoParaShagov_37e3 => _resolve(const [
        'mobile.ostalosVsegoParaShagov_37e3',
        'ostalosVsegoParaShagov_37e3'
      ], base.ostalosVsegoParaShagov_37e3);

  @override
  String get yaPrinimayuPolzovatelskoeSoglashenie_c431 => _resolve(const [
        'mobile.yaPrinimayuPolzovatelskoeSoglashenie_c431',
        'yaPrinimayuPolzovatelskoeSoglashenie_c431'
      ], base.yaPrinimayuPolzovatelskoeSoglashenie_c431);

  @override
  String get yaDayuSoglasieNaObrabotku_0d03 => _resolve(
      const ['profile.consent.label'], base.yaDayuSoglasieNaObrabotku_0d03);

  @override
  String get sVozvrascheniem_77ee => _resolve(
      const ['mobile.sVozvrascheniem_77ee', 'sVozvrascheniem_77ee'],
      base.sVozvrascheniem_77ee);

  @override
  String get zagruzka_43e4 => _resolve(const [
        'messenger.version.loading',
        'messenger.contacts.loading',
        'messenger.reactions.loading',
        'messenger.common.loading'
      ], base.zagruzka_43e4);

  @override
  String get vyberiteAkkauntDlyaVhoda_d3a6 => _resolve(const [
        'mobile.vyberiteAkkauntDlyaVhoda_d3a6',
        'vyberiteAkkauntDlyaVhoda_d3a6'
      ], base.vyberiteAkkauntDlyaVhoda_d3a6);

  @override
  String get vvediteVashNikneym_51a6 => _resolve(
      const ['mobile.vvediteVashNikneym_51a6', 'vvediteVashNikneym_51a6'],
      base.vvediteVashNikneym_51a6);

  @override
  String get voytiVDrugoyAkkaunt_d10f => _resolve(
      const ['mobile.voytiVDrugoyAkkaunt_d10f', 'voytiVDrugoyAkkaunt_d10f'],
      base.voytiVDrugoyAkkaunt_d10f);

  @override
  String get nedavnieAkkaunty_953d =>
      _resolve(const ['login.recentAccounts'], base.nedavnieAkkaunty_953d);

  @override
  String get dobroPozhalovatVXaneo_66d0 =>
      _resolve(const ['welcomeTitle'], base.dobroPozhalovatVXaneo_66d0);

  @override
  String get xaneoTeperIVMobilnom_e918 => _resolve(
      const ['mobile.xaneoTeperIVMobilnom_e918', 'xaneoTeperIVMobilnom_e918'],
      base.xaneoTeperIVMobilnom_e918);

  @override
  String get mneUzheInteresno_5365 => _resolve(
      const ['mobile.mneUzheInteresno_5365', 'mneUzheInteresno_5365'],
      base.mneUzheInteresno_5365);

  @override
  String get vseVashiDannyePodZaschitoy_b7d9 => _resolve(const [
        'mobile.vseVashiDannyePodZaschitoy_b7d9',
        'vseVashiDannyePodZaschitoy_b7d9'
      ], base.vseVashiDannyePodZaschitoy_b7d9);

  @override
  String get vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e =>
      _resolve(const [
        'mobile.vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e',
        'vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e'
      ], base.vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e);

  @override
  String get prodolzhit_e9c3 => _resolve(const [
        'profile.consent.continue',
        'messenger.buttons.continue',
        'continueButton'
      ], base.prodolzhit_e9c3);

  @override
  String get lokalnyeDataTsentry_f089 => _resolve(
      const ['mobile.lokalnyeDataTsentry_f089', 'lokalnyeDataTsentry_f089'],
      base.lokalnyeDataTsentry_f089);

  @override
  String get vashiDannyeNikogdaNePokidayut_f871 => _resolve(const [
        'mobile.vashiDannyeNikogdaNePokidayut_f871',
        'vashiDannyeNikogdaNePokidayut_f871'
      ], base.vashiDannyeNikogdaNePokidayut_f871);

  @override
  String get kodOtpravlenPovtorno_e109 => _resolve(
      const ['mobile.kodOtpravlenPovtorno_e109', 'kodOtpravlenPovtorno_e109'],
      base.kodOtpravlenPovtorno_e109);

  @override
  String get dvuhfaktornayanautentifikatsiya_bacc => _resolve(const [
        'features.f5Title',
        'profile.security.tfa',
        'knowledgeBase.main.cardOverviewLi4'
      ], base.dvuhfaktornayanautentifikatsiya_bacc);

  @override
  String get naVashEmailOtpravlen6_b457 => _resolve(
      const ['mobile.naVashEmailOtpravlen6_b457', 'naVashEmailOtpravlen6_b457'],
      base.naVashEmailOtpravlen6_b457);

  @override
  String get podtverdit_e260 => _resolve(const [
        'profile.security.verify',
        'profile.crop.confirm',
        'messenger.buttons.confirm'
      ], base.podtverdit_e260);

  @override
  String get nePoluchiliKodOtpravitPovtorno_c1d2 => _resolve(const [
        'mobile.nePoluchiliKodOtpravitPovtorno_c1d2',
        'nePoluchiliKodOtpravitPovtorno_c1d2'
      ], base.nePoluchiliKodOtpravitPovtorno_c1d2);

  @override
  String get imyaNikneymOSebe_7a8d => _resolve(
      const ['mobile.imyaNikneymOSebe_7a8d', 'imyaNikneymOSebe_7a8d'],
      base.imyaNikneymOSebe_7a8d);

  @override
  String get zvonkiSoobscheniyaVidimostProfilya_f905 => _resolve(const [
        'mobile.zvonkiSoobscheniyaVidimostProfilya_f905',
        'zvonkiSoobscheniyaVidimostProfilya_f905'
      ], base.zvonkiSoobscheniyaVidimostProfilya_f905);

  @override
  String get parolSessii2fa_de9e => _resolve(
      const ['mobile.parolSessii2fa_de9e', 'parolSessii2fa_de9e'],
      base.parolSessii2fa_de9e);

  @override
  String get prilozhenie_38aa => _resolve(
      const ['mobile.prilozhenie_38aa', 'prilozhenie_38aa'],
      base.prilozhenie_38aa);

  @override
  String get temaRazmerTekstaAnimatsii_f0a8 => _resolve(const [
        'mobile.temaRazmerTekstaAnimatsii_f0a8',
        'temaRazmerTekstaAnimatsii_f0a8'
      ], base.temaRazmerTekstaAnimatsii_f0a8);

  @override
  String get pushUvedomleniyaZvuki_9cc2 => _resolve(
      const ['mobile.pushUvedomleniyaZvuki_9cc2', 'pushUvedomleniyaZvuki_9cc2'],
      base.pushUvedomleniyaZvuki_9cc2);

  @override
  String get oPrilozhenii_77b2 =>
      _resolve(const ['about'], base.oPrilozhenii_77b2);

  @override
  String get redaktirovatProfil_56ad => _resolve(
      const ['mobile.redaktirovatProfil_56ad', 'redaktirovatProfil_56ad'],
      base.redaktirovatProfil_56ad);

  @override
  String get dobavitKontakt_2903 => _resolve(
      const ['messenger.contacts.createTitle'], base.dobavitKontakt_2903);

  @override
  String get nikneymPolzovatelyaUsername_a6ff => _resolve(
      const ['messenger.contacts.namePlaceholder'],
      base.nikneymPolzovatelyaUsername_a6ff);

  @override
  String get otobrazhaemoeImyaNeobyazatelno_340a => _resolve(
      const ['messenger.contacts.name'],
      base.otobrazhaemoeImyaNeobyazatelno_340a);

  @override
  String get neUdalosNaytiIliDobavit_649f => _resolve(const [
        'mobile.neUdalosNaytiIliDobavit_649f',
        'neUdalosNaytiIliDobavit_649f'
      ], base.neUdalosNaytiIliDobavit_649f);

  @override
  String get ya_feef =>
      _resolve(const ['mobile.ya_feef', 'ya_feef'], base.ya_feef);

  @override
  String get poiskKontaktov_9a71 => _resolve(
      const ['messenger.contacts.searchPlaceholder'], base.poiskKontaktov_9a71);

  @override
  String get spisokKontaktovPust_58c6 => _resolve(
      const ['messenger.contacts.empty'], base.spisokKontaktovPust_58c6);

  @override
  String get kontaktyNeNaydeny_1b08 =>
      _resolve(const ['messenger.contacts.empty'], base.kontaktyNeNaydeny_1b08);

  @override
  String get messages =>
      _resolve(const ['mobile.messages', 'messages'], base.messages);

  @override
  String get messageAnimations => _resolve(
      const ['messenger.energy.messageAnimationsTitle'],
      base.messageAnimations);

  @override
  String get messageAnimationsDesc => _resolve(
      const ['mobile.messageAnimationsDesc', 'messageAnimationsDesc'],
      base.messageAnimationsDesc);

  @override
  String get archivedChats =>
      _resolve(const ['messenger.archive.description'], base.archivedChats);

  @override
  String get archiveManagement => _resolve(
      const ['mobile.archiveManagement', 'archiveManagement'],
      base.archiveManagement);

  @override
  String get clearHistory => _resolve(const [
        'messenger.delete.historyTitle',
        'messenger.chat.clearHistory',
        'messenger.clearHistory',
        'messenger.favorites.clearHistory',
        'messenger.context.clearHistory'
      ], base.clearHistory);

  @override
  String get clearHistoryDesc => _resolve(
      const ['mobile.clearHistoryDesc', 'clearHistoryDesc'],
      base.clearHistoryDesc);

  @override
  String get call => _resolve(const ['mobile.call', 'call'], base.call);

  @override
  String get sendMessage =>
      _resolve(const ['mobile.sendMessage', 'sendMessage'], base.sendMessage);

  @override
  String get deleteContact => _resolve(const [
        'messenger.context.deleteContactShort',
        'messenger.contacts.deleteTitle'
      ], base.deleteContact);

  @override
  String get activeSessions =>
      _resolve(const ['profile.sessions.title'], base.activeSessions);

  @override
  String get thisDevice =>
      _resolve(const ['mobile.thisDevice', 'thisDevice'], base.thisDevice);

  @override
  String get xaneoPcActiveNow => _resolve(
      const ['mobile.xaneoPcActiveNow', 'xaneoPcActiveNow'],
      base.xaneoPcActiveNow);

  @override
  String get activeNow =>
      _resolve(const ['mobile.activeNow', 'activeNow'], base.activeNow);

  @override
  String get twoFactorAuth => _resolve(const [
        'features.f5Title',
        'profile.security.tfa',
        'knowledgeBase.main.cardOverviewLi4'
      ], base.twoFactorAuth);

  @override
  String get twoFactorAuthDesc => _resolve(
      const ['mobile.twoFactorAuthDesc', 'twoFactorAuthDesc'],
      base.twoFactorAuthDesc);

  @override
  String get dangerZone =>
      _resolve(const ['mobile.dangerZone', 'dangerZone'], base.dangerZone);

  @override
  String get deleteAccount =>
      _resolve(const ['profile.settings.deleteAccount'], base.deleteAccount);

  @override
  String get irreversibleAction => _resolve(
      const ['mobile.irreversibleAction', 'irreversibleAction'],
      base.irreversibleAction);

  @override
  String get theme => _resolve(const ['mobile.theme', 'theme'], base.theme);

  @override
  String get darkThemeDesc => _resolve(
      const ['mobile.darkThemeDesc', 'darkThemeDesc'], base.darkThemeDesc);

  @override
  String get fontSizeText => _resolve(
      const ['mobile.fontSizeText', 'fontSizeText'], base.fontSizeText);

  @override
  String get changePhoto =>
      _resolve(const ['profile.avatar.change'], base.changePhoto);

  @override
  String get avatarUpdated =>
      _resolve(const ['mobile.avatarUpdated'], base.avatarUpdated);

  @override
  String get avatarUploadFailed =>
      _resolve(const ['mobile.avatarUploadFailed'], base.avatarUploadFailed);

  @override
  String get invalidNicknameFormat => _resolve(
      const ['mobile.invalidNicknameFormat'], base.invalidNicknameFormat);

  @override
  String get deleteAccountPrompt => _resolve(
      const ['profile.settings.deleteAccountDesc'], base.deleteAccountPrompt);

  @override
  String get deleteAccountFailed =>
      _resolve(const ['mobile.deleteAccountFailed'], base.deleteAccountFailed);

  @override
  String get chatFontSize =>
      _resolve(const ['messenger.chatSettings.textSize'], base.chatFontSize);

  @override
  String get chatWallpaper =>
      _resolve(const ['messenger.chatSettings.wallpaper'], base.chatWallpaper);

  @override
  String get myMessageColor => _resolve(
      const ['messenger.chatSettings.myMessages'], base.myMessageColor);

  @override
  String get otherMessageColor => _resolve(
      const ['messenger.chatSettings.otherMessages'], base.otherMessageColor);

  @override
  String get notificationStyle => _resolve(
      const ['messenger.chatSettings.notificationStyle'],
      base.notificationStyle);

  @override
  String get standardNotificationStyle => _resolve(
      const ['messenger.chatSettings.standard'],
      base.standardNotificationStyle);

  @override
  String get blackRavenNotificationStyle => _resolve(
      const ['messenger.chatSettings.blackRaven'],
      base.blackRavenNotificationStyle);

  @override
  String get wallpaperUploadFailed => _resolve(
      const ['mobile.wallpaperUploadFailed'], base.wallpaperUploadFailed);

  @override
  String get showPopups =>
      _resolve(const ['mobile.showPopups', 'showPopups'], base.showPopups);

  @override
  String get sound => _resolve(const ['messenger.call.sound'], base.sound);

  @override
  String get soundDesc =>
      _resolve(const ['mobile.soundDesc', 'soundDesc'], base.soundDesc);

  @override
  String get mainSettings => _resolve(const [
        'messenger.settings.title',
        'header.settings',
        'settings.title',
        'messenger.energy.mainSettings'
      ], base.mainSettings);

  @override
  String get energySavingMode =>
      _resolve(const ['messenger.energy.lowPowerTitle'], base.energySavingMode);

  @override
  String get energySavingModeDesc => _resolve(
      const ['mobile.energySavingModeDesc', 'energySavingModeDesc'],
      base.energySavingModeDesc);

  @override
  String get autoSleep =>
      _resolve(const ['messenger.energy.autoSleepTitle'], base.autoSleep);

  @override
  String get autoSleepDesc =>
      _resolve(const ['messenger.energy.autoSleepDesc'], base.autoSleepDesc);

  @override
  String get animations =>
      _resolve(const ['settings.animations'], base.animations);

  @override
  String get reducedMotion => _resolve(
      const ['mobile.reducedMotion', 'reducedMotion'], base.reducedMotion);

  @override
  String get reducedMotionDesc => _resolve(
      const ['mobile.reducedMotionDesc', 'reducedMotionDesc'],
      base.reducedMotionDesc);

  @override
  String get comingSoon =>
      _resolve(const ['mobile.comingSoon', 'comingSoon'], base.comingSoon);

  @override
  String get updateAvailable => _resolve(
      const ['mobile.updateAvailable', 'updateAvailable'],
      base.updateAvailable);

  @override
  String get clickToViewChanges => _resolve(
      const ['mobile.clickToViewChanges', 'clickToViewChanges'],
      base.clickToViewChanges);

  @override
  String get newVersionAvailable => _resolve(
      const ['mobile.newVersionAvailable', 'newVersionAvailable'],
      base.newVersionAvailable);

  @override
  String get newVersionAvailableTitle => _resolve(
      const ['mobile.newVersionAvailableTitle', 'newVersionAvailableTitle'],
      base.newVersionAvailableTitle);

  @override
  String get youHaveLatestVersion => _resolve(
      const ['mobile.youHaveLatestVersion', 'youHaveLatestVersion'],
      base.youHaveLatestVersion);

  @override
  String get whatsNew =>
      _resolve(const ['mobile.whatsNew', 'whatsNew'], base.whatsNew);

  @override
  String get officialReleaseNotes => _resolve(
      const ['mobile.officialReleaseNotes', 'officialReleaseNotes'],
      base.officialReleaseNotes);

  @override
  String get preparingDownload => _resolve(
      const ['mobile.preparingDownload', 'preparingDownload'],
      base.preparingDownload);

  @override
  String get installationStarted => _resolve(
      const ['mobile.installationStarted', 'installationStarted'],
      base.installationStarted);

  @override
  String get whoSeesAvatar =>
      _resolve(const ['messenger.privacy.whoSeesAvatar'], base.whoSeesAvatar);

  @override
  String get whoSeesBirthday => _resolve(
      const ['messenger.privacy.whoSeesBirthday'], base.whoSeesBirthday);

  @override
  String get whoSeesOnlineTime => _resolve(
      const ['messenger.privacy.whoSeesOnlineTime'], base.whoSeesOnlineTime);

  @override
  String get downloadVersion => _resolve(
      const ['mobile.downloadVersion', 'downloadVersion'],
      base.downloadVersion);

  @override
  String get downloadSource => _resolve(
      const ['mobile.downloadSource', 'downloadSource'], base.downloadSource);

  @override
  String get directInAppInstall => _resolve(
      const ['mobile.directInAppInstall', 'directInAppInstall'],
      base.directInAppInstall);

  @override
  String get autoDownloadAndRun => _resolve(
      const ['mobile.autoDownloadAndRun', 'autoDownloadAndRun'],
      base.autoDownloadAndRun);

  @override
  String get githubReleasePage => _resolve(
      const ['mobile.githubReleasePage', 'githubReleasePage'],
      base.githubReleasePage);

  @override
  String get skip => _resolve(const ['mobile.skip', 'skip'], base.skip);

  @override
  String get updateAction => _resolve(
      const ['mobile.updateAction', 'updateAction'], base.updateAction);

  @override
  String get installAction => _resolve(
      const ['mobile.installAction', 'installAction'], base.installAction);

  @override
  String get isTyping =>
      _resolve(const ['messenger.status.typing'], base.isTyping);

  @override
  String get isRecordingVoice => _resolve(
      const ['messenger.status.recordingVoice'], base.isRecordingVoice);

  @override
  String get areTyping =>
      _resolve(const ['mobile.areTyping', 'areTyping'], base.areTyping);

  @override
  String get group => _resolve(const [
        'messenger.chatInfo.groupTitle',
        'messenger.createGroup.title',
        'messenger.chat.group',
        'common.group',
        'knowledgeBase.bots.chatGroup'
      ], base.group);

  @override
  String get channel => _resolve(const [
        'messenger.chatInfo.channelTitle',
        'messenger.createChannel.title',
        'messenger.chat.channel',
        'common.channel',
        'knowledgeBase.bots.chatChannel',
        'messenger.moderation.objectChannel'
      ], base.channel);

  @override
  String get profile => _resolve(const [
        'header.profile',
        'profile.title',
        'profile.nav.profile',
        'profile.profile.title'
      ], base.profile);

  @override
  String get copied => _resolve(
      const ['common.copied', 'messenger.copied', 'knowledgeBase.doc.copied'],
      base.copied);

  @override
  String get userHidInfo =>
      _resolve(const ['mobile.userHidInfo', 'userHidInfo'], base.userHidInfo);

  @override
  String get leaveGroup => _resolve(const [
        'messenger.context.leaveGroup',
        'messenger.delete.leaveGroupTitle'
      ], base.leaveGroup);

  @override
  String get joinGroup =>
      _resolve(const ['messenger.chat.joinGroup'], base.joinGroup);

  @override
  String get unsubscribeChannel => _resolve(
      const ['messenger.chat.unsubscribeChannel'], base.unsubscribeChannel);

  @override
  String get subscribeChannel => _resolve(
      const ['messenger.chat.subscribeChannel'], base.subscribeChannel);

  @override
  String get deleteChat => _resolve(const [
        'messenger.context.deleteChat',
        'messenger.delete.deleteChatTitle',
        'messenger.chat.delete',
        'messenger.delete'
      ], base.deleteChat);

  @override
  String get pinChat => _resolve(
      const ['messenger.context.pinChat', 'messenger.message.pin'],
      base.pinChat);

  @override
  String get unpinChat => _resolve(const [
        'messenger.context.unpinChat',
        'messenger.message.unpin',
        'messenger.pinned.unpin'
      ], base.unpinChat);

  @override
  String get muteNotifications =>
      _resolve(const ['messenger.context.muteChat'], base.muteNotifications);

  @override
  String get unmuteNotifications => _resolve(
      const ['messenger.context.unmuteChat'], base.unmuteNotifications);

  @override
  String get backToChats =>
      _resolve(const ['mobile.backToChats', 'backToChats'], base.backToChats);

  @override
  String get globalSearch => _resolve(
      const ['mobile.globalSearch', 'globalSearch'], base.globalSearch);

  @override
  String get chatSettings => _resolve(
      const ['mobile.chatSettings', 'chatSettings'], base.chatSettings);

  @override
  String get emoji => _resolve(const ['messenger.emoji.title'], base.emoji);

  @override
  String get attachFile =>
      _resolve(const ['messenger.attach.file'], base.attachFile);

  @override
  String get startCall =>
      _resolve(const ['messenger.callType.title'], base.startCall);

  @override
  String get audioCall => _resolve(
      const ['messenger.callType.audio', 'messenger.call.audioCall'],
      base.audioCall);

  @override
  String get audioCallDesc =>
      _resolve(const ['messenger.callType.audioDesc'], base.audioCallDesc);

  @override
  String get videoCall => _resolve(
      const ['messenger.callType.video', 'messenger.call.videoCall'],
      base.videoCall);

  @override
  String get videoCallDesc =>
      _resolve(const ['messenger.callType.videoDesc'], base.videoCallDesc);

  @override
  String get voiceRecordTitle => _resolve(
      const ['mobile.voiceRecordTitle', 'voiceRecordTitle'],
      base.voiceRecordTitle);

  @override
  String get videoRecordTitle => _resolve(
      const ['mobile.videoRecordTitle', 'videoRecordTitle'],
      base.videoRecordTitle);

  @override
  String get holdToRecordHint => _resolve(
      const ['mobile.holdToRecordHint', 'holdToRecordHint'],
      base.holdToRecordHint);

  @override
  String get addAttachment => _resolve(
      const ['messenger.attach.file', 'messenger.attach.uploadFile'],
      base.addAttachment);

  @override
  String get emojiPanelInDev => _resolve(
      const ['mobile.emojiPanelInDev', 'emojiPanelInDev'],
      base.emojiPanelInDev);

  @override
  String get recordingVoice => _resolve(
      const ['mobile.recordingVoice', 'recordingVoice'], base.recordingVoice);

  @override
  String get recordingVideo => _resolve(
      const ['mobile.recordingVideo', 'recordingVideo'], base.recordingVideo);

  @override
  String get releaseToSend => _resolve(
      const ['mobile.releaseToSend', 'releaseToSend'], base.releaseToSend);

  @override
  String get typeMessage => _resolve(const [
        'messenger.input.message',
        'messenger.typeMessage',
        'messenger.messageInputPlaceholder'
      ], base.typeMessage);

  @override
  String get file => _resolve(const [
        'messenger.attach.uploadFile',
        'messenger.attach.file',
        'common.file'
      ], base.file);

  @override
  String get todoList => _resolve(const [
        'messenger.attach.todoList',
        'messenger.attach.todoListTitle',
        'messenger.todoModal.title'
      ], base.todoList);

  @override
  String get poll => _resolve(const [
        'messenger.attach.pollShort',
        'messenger.attach.poll',
        'messenger.pollModal.title',
        'messenger.pollModal.defaultQuestion'
      ], base.poll);

  @override
  String get today => _resolve(
      const ['common.today', 'messenger.today', 'messenger.datetime.today'],
      base.today);

  @override
  String get yesterday => _resolve(const [
        'common.yesterday',
        'messenger.yesterday',
        'messenger.datetime.yesterday'
      ], base.yesterday);

  @override
  String get monthJan =>
      _resolve(const ['mobile.monthJan', 'monthJan'], base.monthJan);

  @override
  String get monthFeb =>
      _resolve(const ['mobile.monthFeb', 'monthFeb'], base.monthFeb);

  @override
  String get monthMar =>
      _resolve(const ['mobile.monthMar', 'monthMar'], base.monthMar);

  @override
  String get monthApr =>
      _resolve(const ['mobile.monthApr', 'monthApr'], base.monthApr);

  @override
  String get monthMay =>
      _resolve(const ['mobile.monthMay', 'monthMay'], base.monthMay);

  @override
  String get monthJun =>
      _resolve(const ['mobile.monthJun', 'monthJun'], base.monthJun);

  @override
  String get monthJul =>
      _resolve(const ['mobile.monthJul', 'monthJul'], base.monthJul);

  @override
  String get monthAug =>
      _resolve(const ['mobile.monthAug', 'monthAug'], base.monthAug);

  @override
  String get monthSep =>
      _resolve(const ['mobile.monthSep', 'monthSep'], base.monthSep);

  @override
  String get monthOct =>
      _resolve(const ['mobile.monthOct', 'monthOct'], base.monthOct);

  @override
  String get monthNov =>
      _resolve(const ['mobile.monthNov', 'monthNov'], base.monthNov);

  @override
  String get monthDec =>
      _resolve(const ['mobile.monthDec', 'monthDec'], base.monthDec);

  @override
  String get createTodo =>
      _resolve(const ['messenger.todoModal.title'], base.createTodo);

  @override
  String get listName =>
      _resolve(const ['messenger.todoModal.listNameLabel'], base.listName);

  @override
  String get todoItems =>
      _resolve(const ['messenger.todoModal.itemsLabel'], base.todoItems);

  @override
  String get addTodoItem =>
      _resolve(const ['messenger.todoModal.addItem'], base.addTodoItem);

  @override
  String get itemHintPrefix => _resolve(
      const ['messenger.todoModal.itemPlaceholder'], base.itemHintPrefix);

  @override
  String get createPoll => _resolve(
      const ['messenger.pollModal.title', 'messenger.attach.poll'],
      base.createPoll);

  @override
  String get pollQuestion =>
      _resolve(const ['messenger.pollModal.questionLabel'], base.pollQuestion);

  @override
  String get pollOptions =>
      _resolve(const ['messenger.pollModal.optionsLabel'], base.pollOptions);

  @override
  String get addPollOption =>
      _resolve(const ['messenger.pollModal.addOption'], base.addPollOption);

  @override
  String get optionHintPrefix => _resolve(const [
        'messenger.pollModal.optionPlaceholder',
        'messenger.pollModal.emptyOptionText'
      ], base.optionHintPrefix);

  @override
  String get allowMultipleAnswers => _resolve(
      const ['mobile.allowMultipleAnswers', 'allowMultipleAnswers'],
      base.allowMultipleAnswers);

  @override
  String get singleChoice => _resolve(
      const ['mobile.singleChoice', 'singleChoice'], base.singleChoice);

  @override
  String get accountsTitle => _resolve(
      const ['mobile.accountsTitle', 'accountsTitle'], base.accountsTitle);

  @override
  String get addAccount =>
      _resolve(const ['header.addAccount'], base.addAccount);

  @override
  String get accountLimitNotice => _resolve(
      const ['mobile.accountLimitNotice', 'accountLimitNotice'],
      base.accountLimitNotice);

  @override
  String get media =>
      _resolve(const ['messenger.chatInfo.media', 'common.media'], base.media);

  @override
  String get files =>
      _resolve(const ['messenger.chatInfo.files', 'common.files'], base.files);

  @override
  String get voice =>
      _resolve(const ['profile.access.voice', 'common.voice'], base.voice);

  @override
  String get links =>
      _resolve(const ['messenger.chatInfo.links', 'common.links'], base.links);

  @override
  String get bio => _resolve(
      const ['profile.profile.displayName', 'messenger.personal.bio'],
      base.bio);

  @override
  String get username => _resolve(
      const ['profile.profile.username', 'login.username'], base.username);

  @override
  String get birthday => _resolve(
      const ['messenger.personal.birthday', 'profile.profile.birthdate'],
      base.birthday);

  @override
  String get noSharedMedia =>
      _resolve(const ['messenger.chatInfo.noMedia'], base.noSharedMedia);

  @override
  String get noSharedFiles =>
      _resolve(const ['messenger.chatInfo.noFiles'], base.noSharedFiles);

  @override
  String get noSharedVoice =>
      _resolve(const ['messenger.chatInfo.noVoice'], base.noSharedVoice);

  @override
  String get noSharedLinks => _resolve(
      const ['mobile.noSharedLinks', 'noSharedLinks'], base.noSharedLinks);

  @override
  String get savedMessagesDesc => _resolve(const [
        'messenger.favorites.emptyDesc',
        'messenger.savedMessages.desc',
        'messenger.favorites.desc'
      ], base.savedMessagesDesc);

  @override
  String get music => _resolve(const ['messenger.chatInfo.music'], base.music);

  @override
  String get noSharedMusic =>
      _resolve(const ['messenger.chatInfo.noMusic'], base.noSharedMusic);

  @override
  String get secureDesktopCommunicator => _resolve(
      const ['mobile.secureDesktopCommunicator', 'secureDesktopCommunicator'],
      base.secureDesktopCommunicator);

  @override
  String get noMessagesTitle =>
      _resolve(const ['messenger.empty.noMessages'], base.noMessagesTitle);

  @override
  String get noMessagesSubtitle =>
      _resolve(const ['messenger.empty.startNow'], base.noMessagesSubtitle);

  @override
  String get qrScanTitle =>
      _resolve(const ['qrScanTitle', 'qrScanProcessing'], base.qrScanTitle);

  @override
  String get qrScanSubtitle =>
      _resolve(const ['qrScanSubtitle'], base.qrScanSubtitle);

  @override
  String get qrScanSuccessTitle =>
      _resolve(const ['qrScanSuccessTitle'], base.qrScanSuccessTitle);

  @override
  String get qrScanSuccessDesc =>
      _resolve(const ['qrScanSuccessDesc'], base.qrScanSuccessDesc);

  @override
  String get qrScanInputHint =>
      _resolve(const ['qrScanInputHint'], base.qrScanInputHint);

  @override
  String get qrScanPasteTooltip =>
      _resolve(const ['qrScanPasteTooltip'], base.qrScanPasteTooltip);

  @override
  String get qrScanConfirmButton =>
      _resolve(const ['qrScanConfirmButton'], base.qrScanConfirmButton);

  @override
  String get qrScanProcessing => _resolve(
      const ['qrScanProcessing', 'qrScanTitle'], base.qrScanProcessing);

  @override
  String get qrScanConfirmDesc =>
      _resolve(const ['qrScanConfirmDesc'], base.qrScanConfirmDesc);

  @override
  String get qrScanSecurityNote =>
      _resolve(const ['qrScanSecurityNote'], base.qrScanSecurityNote);

  @override
  String get qrScanDoneButton => _resolve(
      const ['qrScanDoneButton', 'register.done'], base.qrScanDoneButton);

  @override
  String get authNotificationSendingCode => _resolve(
      const ['authNotificationSendingCode'], base.authNotificationSendingCode);

  @override
  String get authNotificationEnterCode => _resolve(
      const ['authNotificationEnterCode'], base.authNotificationEnterCode);

  @override
  String get authNotificationConfirmLogin => _resolve(
      const ['authNotificationConfirmLogin'],
      base.authNotificationConfirmLogin);

  @override
  String get authNotificationPasswordLogin => _resolve(
      const ['authNotificationPasswordLogin'],
      base.authNotificationPasswordLogin);

  @override
  String get authNotificationSendingSubtitle => _resolve(
      const ['authNotificationSendingSubtitle'],
      base.authNotificationSendingSubtitle);

  @override
  String get authNotificationEnterCodeSubtitle => _resolve(
      const ['authNotificationEnterCodeSubtitle'],
      base.authNotificationEnterCodeSubtitle);

  @override
  String get authNotificationConfirmSubtitle => _resolve(
      const ['authNotificationConfirmSubtitle'],
      base.authNotificationConfirmSubtitle);

  @override
  String get authNotificationPasswordSubtitle => _resolve(
      const ['authNotificationPasswordSubtitle'],
      base.authNotificationPasswordSubtitle);

  @override
  String get authNotificationBotSource => _resolve(
      const ['authNotificationBotSource'], base.authNotificationBotSource);

  @override
  String get authNotificationNoBotAccess => _resolve(
      const ['authNotificationNoBotAccess'], base.authNotificationNoBotAccess);

  @override
  String get authNotificationGetCodeViaEmail => _resolve(
      const ['authNotificationGetCodeViaEmail'],
      base.authNotificationGetCodeViaEmail);

  @override
  String get authNotificationResendCodeViaEmail => _resolve(
      const ['authNotificationResendCodeViaEmail'],
      base.authNotificationResendCodeViaEmail);

  @override
  String get authNotificationEmailUnavailable => _resolve(
      const ['authNotificationEmailUnavailable'],
      base.authNotificationEmailUnavailable);

  @override
  String get authNotificationLoginWithPassword => _resolve(
      const ['authNotificationLoginWithPassword', 'qrLogin.passwordLogin'],
      base.authNotificationLoginWithPassword);

  @override
  String get authNotificationErrorSendFailed => _resolve(
      const ['authNotificationErrorSendFailed', 'qrLogin.sendCodeFailedErr'],
      base.authNotificationErrorSendFailed);

  @override
  String get authNotificationErrorInvalidCode => _resolve(
      const ['authNotificationErrorInvalidCode'],
      base.authNotificationErrorInvalidCode);

  @override
  String get authNotificationErrorRequestExpired => _resolve(const [
        'authNotificationErrorRequestExpired',
        'qrLogin.requestExpiredErr'
      ], base.authNotificationErrorRequestExpired);

  @override
  String get authNotificationErrorEmailFailed => _resolve(
      const ['authNotificationErrorEmailFailed'],
      base.authNotificationErrorEmailFailed);

  @override
  String get authNotificationErrorPasswordFailed => _resolve(
      const ['authNotificationErrorPasswordFailed'],
      base.authNotificationErrorPasswordFailed);

  @override
  String get authNotificationGetCodeBtn => _resolve(
      const ['authNotificationGetCodeBtn', 'qrLogin.getCodeBtn', 'getCodeBtn'],
      base.authNotificationGetCodeBtn);

  @override
  String get authRejectedTitle =>
      _resolve(const ['authRejectedTitle'], base.authRejectedTitle);

  @override
  String get authRejectedDesc =>
      _resolve(const ['authRejectedDesc'], base.authRejectedDesc);

  @override
  String get authRejectedButton => _resolve(
      const ['authRejectedButton', 'cookie.accept'], base.authRejectedButton);

  @override
  String get deviceAuthApprovalSubtitle => _resolve(
      const ['mobile.deviceAuthApprovalSubtitle', 'deviceAuthApprovalSubtitle'],
      base.deviceAuthApprovalSubtitle);

  @override
  String get deviceAuthApprovalKeysNotice => _resolve(const [
        'mobile.deviceAuthApprovalKeysNotice',
        'deviceAuthApprovalKeysNotice'
      ], base.deviceAuthApprovalKeysNotice);

  @override
  String get deviceAuthApprovalAllow => _resolve(
      const ['mobile.deviceAuthApprovalAllow', 'deviceAuthApprovalAllow'],
      base.deviceAuthApprovalAllow);

  @override
  String get deviceAuthApprovalDecline => _resolve(
      const ['messenger.call.decline'], base.deviceAuthApprovalDecline);

  @override
  String get deviceAuthDevice => _resolve(
      const ['mobile.deviceAuthDevice', 'deviceAuthDevice'],
      base.deviceAuthDevice);

  @override
  String get deviceAuthApp => _resolve(
      const ['mobile.deviceAuthApp', 'deviceAuthApp'], base.deviceAuthApp);

  @override
  String get deviceAuthIp => _resolve(
      const ['mobile.deviceAuthIp', 'deviceAuthIp'], base.deviceAuthIp);

  @override
  String welcomeUser(String username) {
    if (!_rt.hasActiveCustomPack) return base.welcomeUser(username);
    final resolved = _rt.get('welcomeUser',
        params: {'username': username}, fallback: base.welcomeUser(username));
    return resolved;
  }

  @override
  String fontSize(int size) {
    if (!_rt.hasActiveCustomPack) return base.fontSize(size);
    final resolved = _rt.get('fontSize',
        params: {'size': size}, fallback: base.fontSize(size));
    return resolved;
  }

  @override
  String codeSentToEmail(String email) {
    if (!_rt.hasActiveCustomPack) return base.codeSentToEmail(email);
    final resolved = _rt.get('codeSentToEmail',
        params: {'email': email}, fallback: base.codeSentToEmail(email));
    return resolved;
  }

  @override
  String resendIn(int count) {
    if (!_rt.hasActiveCustomPack) return base.resendIn(count);
    final resolved = _rt.get('resendIn',
        params: {'count': count}, fallback: base.resendIn(count));
    return resolved;
  }

  @override
  String membersCount(int count) {
    if (!_rt.hasActiveCustomPack) return base.membersCount(count);
    final mod10 = count % 10;
    final mod100 = count % 100;
    final form = mod10 == 1 && mod100 != 11
        ? 'One'
        : ([2, 3, 4].contains(mod10) && ![12, 13, 14].contains(mod100)
            ? 'Few'
            : 'Many');
    final key = 'messenger.chatInfo.member$form';
    if (!_rt.containsKey(key)) return base.membersCount(count);
    return '$count ${_rt.get(key)}';
  }

  @override
  String subscribersCount(int count) {
    if (!_rt.hasActiveCustomPack) return base.subscribersCount(count);
    final mod10 = count % 10;
    final mod100 = count % 100;
    final form = mod10 == 1 && mod100 != 11
        ? 'One'
        : ([2, 3, 4].contains(mod10) && ![12, 13, 14].contains(mod100)
            ? 'Few'
            : 'Many');
    final key = 'messenger.chatInfo.subscriber$form';
    if (!_rt.containsKey(key)) return base.subscribersCount(count);
    return '$count ${_rt.get(key)}';
  }

  @override
  String authNotificationCodeSentToEmail(String email) {
    if (!_rt.hasActiveCustomPack)
      return base.authNotificationCodeSentToEmail(email);
    final resolved = _rt.get('mobile.authNotificationCodeSentToEmail',
        params: {'email': email},
        fallback: base.authNotificationCodeSentToEmail(email));
    return resolved;
  }

  @override
  String authNotificationEmailAvailableIn(int seconds) {
    if (!_rt.hasActiveCustomPack)
      return base.authNotificationEmailAvailableIn(seconds);
    final resolved = _rt.get('mobile.authNotificationEmailAvailableIn',
        params: {'seconds': seconds},
        fallback: base.authNotificationEmailAvailableIn(seconds));
    return resolved;
  }

  @override
  String authNotificationPasswordAvailableIn(int seconds) {
    if (!_rt.hasActiveCustomPack)
      return base.authNotificationPasswordAvailableIn(seconds);
    final resolved = _rt.get('mobile.authNotificationPasswordAvailableIn',
        params: {'seconds': seconds},
        fallback: base.authNotificationPasswordAvailableIn(seconds));
    return resolved;
  }

  @override
  String get importLanguageFromJson => _resolve(const [
        'importLanguageFromJson',
        'mobile.importLanguageFromJson',
        'messenger.language.importFromJson'
      ], base.importLanguageFromJson);

  @override
  String get customColor =>
      _resolve(const ['customColor', 'mobile.customColor'], base.customColor);
  @override
  String get customGradient => _resolve(
      const ['customGradient', 'mobile.customGradient'], base.customGradient);
  @override
  String get colorOne =>
      _resolve(const ['colorOne', 'mobile.colorOne'], base.colorOne);
  @override
  String get colorTwo =>
      _resolve(const ['colorTwo', 'mobile.colorTwo'], base.colorTwo);
  @override
  String get diagonal =>
      _resolve(const ['diagonal', 'mobile.diagonal'], base.diagonal);
  @override
  String get vertical =>
      _resolve(const ['vertical', 'mobile.vertical'], base.vertical);
  @override
  String get horizontal =>
      _resolve(const ['horizontal', 'mobile.horizontal'], base.horizontal);
}
