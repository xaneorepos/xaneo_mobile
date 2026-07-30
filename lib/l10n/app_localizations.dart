import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_es.dart';
import 'app_localizations_zh.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('en'),
    Locale('fr'),
    Locale('es'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('ar'),
  ];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'Xaneo PC'**
  String get appTitle;

  /// Welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Xaneo'**
  String get welcomeTitle;

  /// Welcome description
  ///
  /// In en, this message translates to:
  /// **'Xaneo is now on your computer! Maximum performance and convenience.'**
  String get welcomeDescription;

  /// Get started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedButton;

  /// Privacy screen title
  ///
  /// In en, this message translates to:
  /// **'All your data is secure'**
  String get privacyTitle;

  /// Privacy description
  ///
  /// In en, this message translates to:
  /// **'All messages in Xaneo are protected by end-to-end encryption. Xaneo never knows their content.'**
  String get privacyDescription;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Data storage screen title
  ///
  /// In en, this message translates to:
  /// **'All Xaneo data centers are located in Russia'**
  String get dataStorageTitle;

  /// Data storage description
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves the country and is stored in secure data centers.'**
  String get dataStorageDescription;

  /// Finish button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishButton;

  /// Setup completed message
  ///
  /// In en, this message translates to:
  /// **'Setup completed!'**
  String get setupCompleted;

  /// Login form title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginFormTitle;

  /// Login field hint
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginFieldHint;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordFieldHint;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No account link
  ///
  /// In en, this message translates to:
  /// **'No account?'**
  String get noAccount;

  /// Register button
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// Fill all fields message
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// Logging in message
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// Welcome user message
  ///
  /// In en, this message translates to:
  /// **'Welcome, {username}!'**
  String welcomeUser(String username);

  /// Invalid credentials message
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Please check your username and password.'**
  String get invalidCredentials;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please check your internet connection.'**
  String get connectionError;

  /// Settings title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Notifications setting name
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notifications setting description
  ///
  /// In en, this message translates to:
  /// **'Enable or disable notifications'**
  String get notificationsDescription;

  /// Dark theme setting name
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// Dark theme setting description
  ///
  /// In en, this message translates to:
  /// **'Enable or disable dark theme'**
  String get darkThemeDescription;

  /// Font size setting
  ///
  /// In en, this message translates to:
  /// **'Font size: {size}'**
  String fontSize(int size);

  /// Language setting name
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language setting description
  ///
  /// In en, this message translates to:
  /// **'Select interface language'**
  String get languageDescription;

  /// Select language title
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// App version setting name
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// Registration screen title
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registerTitle;

  /// Registration step 0 title
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get registerStep0Title;

  /// Registration step 0 subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your real name'**
  String get registerStep0Subtitle;

  /// Registration step 1 title
  ///
  /// In en, this message translates to:
  /// **'When were you born?'**
  String get registerStep1Title;

  /// Registration step 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'You must be at least 14 years old'**
  String get registerStep1Subtitle;

  /// Registration step 2 title
  ///
  /// In en, this message translates to:
  /// **'Choose a nickname'**
  String get registerStep2Title;

  /// Registration step 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Nickname must be unique'**
  String get registerStep2Subtitle;

  /// Registration step 3 title
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get registerStep3Title;

  /// Registration step 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification code'**
  String get registerStep3Subtitle;

  /// Registration step 4 title
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get registerStep4Title;

  /// Registration step 4 subtitle
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get registerStep4Subtitle;

  /// Registration step 5 title
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get registerStep5Title;

  /// Registration step 5 subtitle
  ///
  /// In en, this message translates to:
  /// **'This is optional, but nice'**
  String get registerStep5Subtitle;

  /// Registration step 6 title
  ///
  /// In en, this message translates to:
  /// **'Last step'**
  String get registerStep6Title;

  /// Registration step 6 subtitle
  ///
  /// In en, this message translates to:
  /// **'Accept the terms of use'**
  String get registerStep6Subtitle;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// Birth date field label
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get birthDate;

  /// Nickname field label
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// Checking nickname message
  ///
  /// In en, this message translates to:
  /// **'Checking availability...'**
  String get checkingNickname;

  /// Nickname available message
  ///
  /// In en, this message translates to:
  /// **'Nickname available'**
  String get nicknameAvailable;

  /// Nickname taken message
  ///
  /// In en, this message translates to:
  /// **'Nickname taken'**
  String get nicknameTaken;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// Add photo hint
  ///
  /// In en, this message translates to:
  /// **'Tap to add a photo'**
  String get addPhoto;

  /// Remove photo button
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// Accept terms checkbox
  ///
  /// In en, this message translates to:
  /// **'I accept the terms of use'**
  String get acceptTerms;

  /// Accept data processing checkbox
  ///
  /// In en, this message translates to:
  /// **'I agree to the processing of personal data'**
  String get acceptDataProcessing;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Finish button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Back to login button
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// Registration success message
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccess;

  /// Registration error message
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get registrationError;

  /// Enter verification code message
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// Invalid verification code message
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidVerificationCode;

  /// Code sent message
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to email'**
  String get codeSent;

  /// Send code error message
  ///
  /// In en, this message translates to:
  /// **'Error sending code'**
  String get sendCodeError;

  /// Confirm email modal title
  ///
  /// In en, this message translates to:
  /// **'Confirm e-mail'**
  String get confirmEmail;

  /// Code sent to email message
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to\n{email}'**
  String codeSentToEmail(String email);

  /// Verify button
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Resend code button
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// Resend countdown
  ///
  /// In en, this message translates to:
  /// **'Resend in {count} sec'**
  String resendIn(int count);

  /// Accept terms required message
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and data processing consent'**
  String get acceptTermsRequired;

  /// About app menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// About app description
  ///
  /// In en, this message translates to:
  /// **'A modern application for managing and controlling systems.'**
  String get aboutDescription;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Technical information section header
  ///
  /// In en, this message translates to:
  /// **'Technical Information'**
  String get technicalInfo;

  /// Platform label
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// Processor architecture label
  ///
  /// In en, this message translates to:
  /// **'Processor Architecture'**
  String get architecture;

  /// Flutter framework label
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get flutter;

  /// View on GitHub link text
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get viewOnGitHub;

  String get chats;
  String get search;
  String get searchPlaceholder;
  String get savedMessages;
  String get online;
  String get offline;
  String get lastSeenRecently;
  String get musicPlaylist;
  String get reply;
  String get edit;
  String get copy;
  String get pin;
  String get unpin;
  String get delete;
  String get forward;
  String get members;
  String get noMessages;

  String get joinedChat;
  String get leftChat;
  String get subscribedChannel;
  String get unsubscribedChannel;
  String get invited;
  String get systemMessage;
  String get selectChatToStart;
  String get toArchive;
  String get unarchive;
  String get archive;
  String get archiveEmpty;
  String get voiceMessage;
  String get videoMessage;

  String get personalData;
  String get personalDataDesc;
  String get privacyDesc;
  String get chatsSettings;
  String get chatsSettingsDesc;
  String get contacts;
  String get contactsDesc;
  String get security;
  String get securityDesc;
  String get appearance;
  String get appearanceDesc;
  String get energySaving;
  String get energySavingDesc;

  String get account;
  String get interface;
  String get logout;

  String get basicInfo;
  String get nicknameCannotBeChanged;
  String get aboutMe;
  String get aboutMeHint;
  String get save;
  String get saving;
  String get communications;
  String get whoCanMessage;
  String get whoCanCall;
  String get whoCanRecordVoice;
  String get whoCanSendFiles;
  String get whoCanInvite;
  String get profileVisibility;
  String get whoSeesNickname;
  String get everyone;
  String get contactsOnly;
  String get nobody;
  String get addContact;
  String get addContactTitle;
  String get userNicknameHint;
  String get displayNameOptional;
  String get noContactsYet;
  String get appInfo;
  String get checkUpdates;
  String get checkingUpdates;
  String get cancel;
  String get obnovlenie_7e32;
  String get obnovleniePrilozheniya_b6c3;
  String get podgotovkaKZagruzke_a5c7;
  String get ustanovkaZapuschena_d378;
  String get dostupnaNovayaVersiyaPrilozheniya_eeae;
  String get chtoNovogo_74e2;
  String get ofitsialnoeOpisanieRelizaDostupnoNa_3ea3;
  String get istochnikZagruzki_0e6e;
  String get pryamayaUstanovkaVPrilozhenii_16f5;
  String get avtomaticheskoeSkachivanieIZapusk_9a3f;
  String get stranitsaRelizaNaGithub_1531;
  String get propustit_03ee;
  String get ustanovka_516d;
  String get obnovit_dbe5;
  String get lichnyeDannye_be85;
  String get imyaNikneymFotoProfilya_28ac;
  String get privatnost_0899;
  String get ktoMozhetPisatZvonitVidet_1789;
  String get nastroykiChatov_7ca8;
  String get uvedomleniyaTemyIstoriya_51da;
  String get kontakty_7576;
  String get vashiSohranennyeKontakty_a641;
  String get bezopasnost_3677;
  String get sessiiParolAutentifikatsiya_73f5;
  String get vneshniyVid_6873;
  String get temaShriftMasshtab_d8c9;
  String get yazyk_0577;
  String get yazykInterfeysaKlienta_2ad3;
  String get uvedomleniya_d2ed;
  String get zvukiBannery_1b60;
  String get energosberezhenie_0b19;
  String get animatsiiIProizvoditelnost_fba8;
  String get oPrilozhenii_322e;
  String get versiyaProverkaObnovleniySsylki_6efc;
  String get nastroyki_b01b;
  String get nastroyki_c919;
  String get proverkaObnovleniy_f3e0;
  String get neUdalosZagruzitNastroyki_f753;
  String get oshibkaSohraneniya_0387;
  String get dannyeSohraneny_fd62;
  String get gost_9618;
  String get akkaunt_38ac;
  String get interfeys_49be;
  String get vyytiIzAkkaunta_6d41;
  String get informatsiyaOPrilozhenii_00c4;
  String get versiya1001LinuxWindowsMacos_ff6c;
  String get proverka_13bc;
  String get proveritObnovleniya_ab45;
  String get osnovnayaInformatsiya_6fec;
  String get imya_d38d;
  String get vvediteVasheImya_751e;
  String get nikneym_3fea;
  String get nikneymNelzyaIzmenitVPrilozhenii_75d0;
  String get oSebe_0b3b;
  String get rasskazhiteOSebe_1c37;
  String get sohranenie_c15f;
  String get sohranit_74ea;
  String get vse_984b;
  String get tolkoKontakty_a559;
  String get nikto_ba19;
  String get kommunikatsii_1242;
  String get ktoMozhetPisatSoobscheniya_4645;
  String get ktoMozhetZvonit_c427;
  String get ktoMozhetZapisyvatGolosovye_c69a;
  String get ktoMozhetOtpravlyatFayly_2e40;
  String get ktoMozhetPriglashatVGruppy_cdc0;
  String get vidimostProfilya_34bf;
  String get ktoViditMoyNikneym_54b8;
  String get ktoViditMoyAvatar_e9f6;
  String get ktoViditMoyDenRozhdeniya_ccc7;
  String get ktoViditVremyaMoeyAktivnosti_4349;
  String get neUdalosZagruzitKontakty_02a3;
  String get dobavitKontakt_4278;
  String get nikneymPolzovatelya_5610;
  String get otobrazhaemoeImyaOptsionalno_bbd1;
  String get otmena_987b;
  String get dobavit_5eba;
  String get uVasPokaNetSohranennyh_b64b;
  String get pozvonit_ccfa;
  String get napisat_0144;
  String get udalitKontakt_065d;
  String get soobscheniya_7e26;
  String get animatsiiSoobscheniy_bc8b;
  String get pokazyvatAnimatsiiPriOtpravkeI_d663;
  String get arhivirovannyeChaty_d990;
  String get upravlenieArhivom_e843;
  String get ochistitIstoriyu_837a;
  String get udalitVseSoobscheniyaLokalno_fbbd;
  String get aktivnyeSessii_5c96;
  String get etoUstroystvo_26f6;
  String get xaneoPcAktivnoSeychas_25b4;
  String get aktivno_87a4;
  String get dvoynayaAutentifikatsiya_66ae;
  String get zaschitaAkkauntaOdnorazovymParolem_e9f1;
  String get opasnayaZona_25bc;
  String get udalitAkkaunt_05c7;
  String get neobratimoeDeystvie_7232;
  String get tema_9e26;
  String get temnayaTema_cb48;
  String get pereklyuchitMezhduTemnymISvetlym_5415;
  String get razmerShrifta_1155;
  String get a_87a0;
  String get pokazyvatVsplyvayuschieUvedomleniya_754e;
  String get zvuk_9329;
  String get vosproizvoditZvukPriNovomSoobschenii_47cc;
  String get osnovnyeNastroyki_231c;
  String get rezhimEkonomiiEnergii_edfc;
  String get optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb;
  String get avtomaticheskiySpyaschiyRezhim_5955;
  String get perevoditPrilozhenieVSpyaschiyRezhim_1c07;
  String get animatsii_05c7;
  String get uproschennyeAnimatsii_3a13;
  String get umenshaetKolichestvoAnimatsiyInterfeysa_6bf1;
  String get skoroBudetDostupno_de07;
  String get gostevoyRezhim_6d82;
  String get voyditeDlyaDostupaKAkkauntu_a5c8;
  String get nazhmiteDlyaProsmotraIzmeneniy_0255;
  String get vvediteKodPodtverzhdeniya_61af;
  String get nevernyyKodPodtverzhdeniya_7762;
  String get podtverditeEMail_4bd4;
  String get proverit_340b;
  String get otpravitKodPovtorno_7703;
  String get sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e;
  String get tehnologii_6332;
  String get vyNashliPashalku_1a57;
  String get spasiboZaIspolzovanieXaneo_d079;
  String get globalnyyPoisk_77bf;
  String get poiskKontaktovChatovKanalovBotov_db66;
  String get lyudi_c7ae;
  String get gruppy_ebc4;
  String get kanaly_0c11;
  String get boty_d6e4;
  String get izbrannoe_2fc4;
  String get vvediteZaprosDlyaPoiskaPo_9955;
  String get nichegoNeNaydeno_8767;
  String get izbrannoe_b637;
  String get boty_800d;
  String get kanaly_ccec;
  String get gruppy_cfd6;
  String get polzovateli_e0ec;
  String get sohranennyeSoobscheniya_6b62;
  String get bot_0ae1;
  String get bot_0f46;
  String get gruppa_99d9;
  String get kanal_2710;
  String get versiya_3725;
  String get tehnicheskayaInformatsiya_ba0f;
  String get platforma_8848;
  String get arhitekturaProtsessora_c079;
  String get posmotretNaGithub_5238;
  String get zakryt_dd94;
  String get vklyuchitTemnuyuTemu_ed17;
  String get vklyuchitUvedomleniya_d311;
  String get kastomnyyOverleyXaneo_7d39;
  String get animirovannyeUvedomleniyaSBystrymOtvetom_a25d;
  String get aaBbVv_1c6b;
  String get pleylist_a04c;
  String get spisokMuzyki_d477;
  String get loc_0B_5a4d;
  String get b_3b67;
  String get kb_419d;
  String get mb_b808;
  String get gb_e572;
  String get audiozapis_867d;
  String get muzykalnyyTrek_b15d;
  String get muzykalnyeTrekiOtsutstvuyut_3301;
  String get nikneymUzheZanyat_59aa;
  String get oshibkaProverki_2ab0;
  String get emailUzheZanyat_17e1;
  String get oshibkaOtpravkiKoda_a42a;
  String get neobhodimoPrinyatUsloviyaISoglasie_e31e;
  String get registratsiyaUspeshna_9d5c;
  String get oshibkaRegistratsii_b9f2;
  String get nazad_2b0b;
  String get kakVasZovut_68b7;
  String get kogdaVyRodilis_26f2;
  String get pridumayteNikneym_221b;
  String get vashEmail_8bbd;
  String get podtverzhdenieEmail_281f;
  String get sozdayteParol_5f4c;
  String get podtverzhdenieParolya_ebc2;
  String get dobavteFoto_25eb;
  String get posledniyShag_e0c5;
  String get vvediteVasheNastoyascheeImya_e656;
  String get vamDolzhnoBytNeMenee_1111;
  String get nikneymDolzhenBytUnikalnym_952d;
  String get myOtpravimKodPodtverzhdeniya_fc71;
  String get vvedite6ZnachnyyKodIz_f22f;
  String get pridumayteNadezhnyyParol_2312;
  String get povtoriteParolEscheRaz_6723;
  String get etoNeobyazatelnoNoPriyatno_b6a3;
  String get proverteVashiDannyeIPrimite_3121;
  String get registratsiya_0b93;
  String get vasheImya_51eb;
  String get proverkaDostupnosti_da13;
  String get nikneymDostupen_3fc9;
  String get nikneymZanyat_8a5f;
  String get emailDostupen_e903;
  String get emailZanyat_fb40;
  String get kodPodtverzhdeniya_1c9d;
  String get parol_5ebe;
  String get podtverditeParol_e3e3;
  String get nazhmiteChtobyDobavitFoto_d6e8;
  String get udalitFoto_3426;
  String get yaPrinimayuUsloviyaIspolzovaniya_391a;
  String get yaSoglasenNaObrabotkuPersonalnyh_f2a8;
  String get zavershit_b0e3;
  String get dalee_c453;
  String get dataRozhdeniya_505e;
  String get vklyuchitTemnuyuTemuOformleniya_86c4;
  String get yanvar_ee86;
  String get fevral_28ff;
  String get mart_d766;
  String get aprel_03e9;
  String get may_2e53;
  String get iyun_cfcb;
  String get iyul_89fb;
  String get avgust_de5a;
  String get sentyabr_ebfb;
  String get oktyabr_1720;
  String get noyabr_66fb;
  String get dekabr_39b3;
  String get pn_2c1e;
  String get vt_7145;
  String get sr_c6e4;
  String get cht_a51f;
  String get pt_0123;
  String get sb_3a4b;
  String get vs_4ad9;
  String get gotovo_34e1;
  String get oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b;
  String get kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7;
  String get oshibkaZagruzkiKlyucheyNaServer_ff9b;
  String get oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4;
  String get prevyshenLimitV5Akkauntov_a6a9;
  String get oshibkaAvtorizatsii_9f5c;
  String get oshibkaPodklyucheniyaKServeru_8b96;
  String get nazadKMessendzheru_de29;
  String get voytiVAkkaunt_c439;
  String get vvediteParol_1370;
  String get vvediteSvoiDannyeDlyaDostupa_319e;
  String get voyti_63a7;
  String get sobesednik_7025;
  String get vy_0101;
  String get vyDelitesSvoimEkranom_16b1;
  String get polzovatel_f154;
  String get ishodyaschiyVyzov_650b;
  String get vhodyaschiyVyzov_19ff;
  String get podklyucheno_d022;
  String get ozhidanieOtveta_a984;
  String get razgovorPoAudiosvyazi_3ed7;
  String get translyatsiyaVashegoEkranaZapuschena_575a;
  String get sobesednikViditVseChtoProishodit_c759;
  String get vhodyaschiyVyzov_905e;
  String get neizvestnyy_be89;
  String get videozvonok_dd18;
  String get golosovoyZvonok_5410;
  String get otklonit_8b0d;
  String get otvetit_e568;
  String get gruppovoyZvonok_dac1;
  String get podklyuchenieKZvonku_e2cf;
  String get podklyuchenieKVeschaniyu_038b;
  String get uchastnik_cffb;
  String get vy_479c;
  String get svernut_ca9f;
  String get vhodyaschiyVyzov_d2f3;
  String get novoeSoobschenie_1d49;
  String get vashOtvet_40c2;
  String get videovyzov_3353;
  String get audiovyzov_bbb5;
  String get nachatZvonok_3d26;
  String get golosovoyZvonok_b615;
  String get pozvonitPoGolosovoySvyazi_4069;
  String get videozvonok_8142;
  String get pozvonitSVklyuchennoyKameroy_fb05;
  String get zashifrovannoeSoobschenie_ca35;
  String get golosovoeSoobschenie_4a85;
  String get videosoobschenie_d687;
  String get fayl_826d;
  String get zvonok_e8d5;
  String get oshibkaDeshifrovaniya_4146;
  String get zapisyvaetGolosovoe_2a5c;
  String get pechataet_812c;
  String get neUdalosArhivirovatChat_ab89;
  String get neUdalosRazarhivirovatChat_f0d7;
  String get arhiv_56aa;
  String get netUserid_634a;
  String get netKlyucha_337b;
  String get neizvestnyyTipChata_2617;
  String get neUdalosPoluchitKlyuchShifrovaniya_b953;
  String get gruppa_19c2;
  String get uchastnik_5bce;
  String get uchastnika_92d9;
  String get uchastnikov_5d6b;
  String get kanal_64ec;
  String get podpischik_695a;
  String get podpischika_b490;
  String get podpischikov_ba39;
  String get segodnya_9626;
  String get vchera_61d4;
  String get yanvarya_d861;
  String get fevralya_fcf9;
  String get marta_bb77;
  String get aprelya_2b5a;
  String get maya_4dbb;
  String get iyunya_adcb;
  String get iyulya_3236;
  String get avgusta_e3aa;
  String get sentyabrya_a146;
  String get oktyabrya_7abd;
  String get noyabrya_6e78;
  String get dekabrya_29cc;
  String get vyPodpisalisNaKanal_b2b3;
  String get vyPrisoedinilisKGruppe_07bd;
  String get neUdalosPrisoedinitsya_31e6;
  String get vyOtpisalisOtKanala_7698;
  String get vyPokinuliGruppu_5a52;
  String get neUdalosVypolnitDeystvie_3cfd;
  String get neUdalosPereklyuchitAkkaunt_968b;
  String get media_c247;
  String get fayly_200c;
  String get golos_2d89;
  String get ssylki_9f58;
  String get profil_c62a;
  String get imyaPolzovatelya_6fd4;
  String get denRozhdeniya_e41d;
  String get polzovatelSkrylInformatsiyuOSebe_f416;
  String get god_6270;
  String get goda_7443;
  String get let_257a;
  String get skopirovano_f70b;
  String get akkaunty_80b5;
  String get dobavitAkkaunt_5253;
  String get limit5Akkauntov_fdb7;
  String get nazadKChatam_7edb;
  String get chaty_19ad;
  String get globalnyyPoisk_7ff2;
  String get arhivPust_3e22;
  String get netSoobscheniy_29d4;
  String get toDoList_27e1;
  String get opros_6ff1;
  String get fotografiya_5709;
  String get razarhivirovat_416b;
  String get vArhiv_ce22;
  String get chat_c52b;
  String get vyberiteChatDlyaNachalaObscheniya_36a5;
  String get bot_2712;
  String get vSeti_d902;
  String get neVSeti_ee01;
  String get nastroykiChata_1e0d;
  String get pokinutGruppu_e6ce;
  String get prisoedinitsyaKGruppe_eb45;
  String get otpisatsyaOtKanala_fdbc;
  String get podpisatsyaNaKanal_2dad;
  String get netSoobscheniyNapishiteChtoNibud_2bf4;
  String get prisoedinilsyaKChatu_f623;
  String get pokinulChat_d567;
  String get podpisalsyaNaKanal_0673;
  String get otpisalsyaOtKanala_fa13;
  String get polzovatelya_1083;
  String get priglasil_47ae;
  String get rasshifrovka_e47f;
  String get sistemnoeSoobschenie_d2bd;
  String get soobschenie_3715;
  String get videosoobschenie_57f1;
  String get spisokZadach_cfa4;
  String get opros_5902;
  String get vlozhenie_ef44;
  String get fayl_2d46;
  String get zagruzkaFayla_f817;
  String get ishodyaschiyZvonok_8381;
  String get razgovorNeSostoyalsya_67fb;
  String get vhodyaschiyZvonok_5ce9;
  String get otklonennyyZvonok_d499;
  String get vyOtkloniliVyzov_8d1d;
  String get propuschennyyZvonok_e98d;
  String get vyPropustiliVyzov_f17a;
  String get vlozhenie_2474;
  String get tb_0e05;
  String get zapisGolosovogo_9c91;
  String get zapisVideo_dd2a;
  String get otpustiteDlyaOtpravki_ea7b;
  String get emodzi_f822;
  String get panelEmodziVRazrabotke_b6ce;
  String get napisatSoobschenie_62d4;
  String get dobavitVlozhenie_769b;
  String get spisokZadach_1852;
  String get opros_9f36;
  String get zapisGolosovogoGs_db4e;
  String get zapisVideoVs_9676;
  String get uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3;
  String get novyyChat_f775;
  String get imyaPolzovatelyaMin5Simvolov_1232;
  String get vvedite5IliBoleeSimvolov_f983;
  String get polzovateliNeNaydeny_c01a;
  String get mnozhestvennyyVybor_9b60;
  String get odinochnyyVybor_d920;
  String get netGolosov_17d0;
  String get golos_6b94;
  String get golosa_bb8d;
  String get golosov_7f51;
  String get nePoluchenIdFaylaOt_86c8;
  String get faylZagruzhenIPrikreplen_dc24;
  String get neizvestnayaOshibkaZagruzki_68cb;
  String get oshibkaZagruzkiFayla_86e5;
  String get sohranitFaylKak_0f93;
  String get oshibkaSkachivaniyaFayla_34ac;
  String get bezNazvaniya_6584;
  String get bezVoprosa_d390;
  String get netDostupaKMikrofonu_a4ef;
  String get zapisVideoCherezPlaginCamera_b9dd;
  String get kameraNeInitsializirovanaNaEtoy_21e0;
  String get kameraNeGotova_9f09;
  String get zapisVideosoobscheniyaNaEtoyPlatforme_a561;
  String get arecordOstanovlen_edf2;
  String get ffmpegOstanovlen_63a0;
  String get zapisSlishkomKorotkaya_5cda;
  String get oshibkaZapisiFaylPust_106b;
  String get videosoobschenieOtpravlenoSimulyatsiya_fb29;
  String get zapisOtmenena_1609;
  String get otpravitGolosovoeSoobschenie_2481;
  String get imitatsiyaZapisiGolosovogoSoobscheniya_81e7;
  String get otpravit_6da0;
  String get sozdatToDo_8c92;
  String get nazvanieSpiska_c3cc;
  String get punkty_0481;
  String get dobavitPunkt_930c;
  String get sozdat_b059;
  String get sozdatOpros_4b9e;
  String get vopros_0911;
  String get variantyOtveta_ef4e;
  String get dobavitVariant_76be;
  String get golosovoeSoobschenie_33d5;
  String get videosoobschenie_2951;
  String get video_a095;
  String get neUdalosZagruzitIzobrazhenie_3fa0;
  String get muzyka_0660;
  String get netDannyh_dee9;
  String get istoriyaSoobscheniyPustaIliChat_2d07;
  String get obschieMaterialy_11e4;
  String get netMediafaylov_08d2;
  String get zdesBudutOtobrazhatsyaObschieFoto_9bc7;
  String get netFaylov_e95e;
  String get zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c;
  String get netGolosovyhSoobscheniy_2427;
  String get zdesBudutOtobrazhatsyaGolosovyeI_0a73;
  String get netSsylok_b0ec;
  String get zdesBudutOtobrazhatsyaObschieSsylki_6b61;
  String get ssylkaSkopirovanaVBufer_c16e;
  String get netMuzyki_1ca3;
  String get zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23;
  String get udalennyyAkkaunt_ce47;
  String get opisanie_38ca;
  String get mobilnyy_5ac7;
  String get bylANedavno_168d;
  String get minutu_5373;
  String get minuty_5bc9;
  String get minut_b877;
  String get nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a;
  String get poiskLyudeyBotovGrupp_e84e;
  String get vveditePoiskovyyZapros_0b8c;
  String get polzovateli_b8c4;
  String get moiLichnyeSoobscheniya_7d3b;
  String get sozdatNovyyChat_fd41;
  String get lichnyyChat_cbec;
  String get nachatObschenieSPolzovatelem_0578;
  String get sozdatGruppu_459f;
  String get gruppovoyChatDlyaObscheniyaS_01ba;
  String get sozdatKanal_9022;
  String get kanalDlyaShirokoyAuditorii_9dba;
  String get redaktirovanie_1167;
  String get vlevo_1af1;
  String get vpravo_c316;
  String get poGor_ff50;
  String get poVert_b4a9;
  String get vvediteNazvanieGruppy_0a69;
  String get dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0;
  String get gruppaSozdana_6b3b;
  String get oshibkaPriSozdaniiGruppy_794e;
  String get nazhmiteNaIkonkuChtobyVybrat_af03;
  String get nazvanieGruppy_9a39;
  String get opisanieNeobyazatelno_7812;
  String get privatnayaGruppa_d20e;
  String get publichnayaGruppa_50f8;
  String get vhodTolkoPoPriglasheniyu_97a1;
  String get lyuboyMozhetNaytiIVstupit_5e26;
  String get publichnayaSsylkanikneymMyGroup_6640;
  String get vvediteNazvanieKanala_5536;
  String get dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06;
  String get kanalSozdan_1522;
  String get oshibkaPriSozdaniiKanala_7d4b;
  String get nazvanieKanala_c548;
  String get privatnyyKanal_3139;
  String get publichnyyKanal_0f7c;
  String get podpiskaTolkoPoPriglasheniyu_99c3;
  String get lyuboyMozhetNaytiIPodpisatsya_8579;
  String get ssylkanikneymKanalaMychannel_79f6;
  String get yazykInterfeysa_b78b;
  String get dannyeUspeshnoSohraneny_2cc5;
  String get oshibkaPriSohranenii_126f;
  String get lichnyeDannye_10a7;
  String get nikneymUsername_8035;
  String get nikneymNelzyaIzmenit_0b99;
  String get oSebeBio_b730;
  String get rasskazhiteNemnogoOSebe_3daa;
  String get nastroykiPrivatnostiSohraneny_447c;
  String get privatnost_3098;
  String get kommunikatsii_e9b8;
  String get ktoMozhetPisat_3322;
  String get zapisGolosovyh_8073;
  String get otpravkaFaylov_aaca;
  String get priglashatVGruppy_3631;
  String get vidimostProfilya_448f;
  String get ktoViditAvatar_b5d8;
  String get vremyaVSeti_be29;
  String get vneshniyVid_5a0f;
  String get rezhimOformleniyaInterfeysa_b91d;
  String get pokazyvatVizualnyeEffektyIPerehody_3fd7;
  String get razmerTeksta_3c4f;
  String get bezopasnost_fcbc;
  String get dvuhfaktornayaAutentifikatsiya_acdc;
  String get zaschitaAkkaunta2fa_f1ab;
  String get vklyucheno_6b96;
  String get xaneoMobileAktivnoSeychas_3345;
  String get zaschischennyyMessendzher_2f59;
  String get temnayaTema_6018;
  String get vklyuchenaPoUmolchaniyu_7610;
  String get setevoyFiltr_40c2;
  String get vklyuchen_0994;
  String get spisokMuzyki_57d0;
  String get trek_5049;
  String get trekov_d3f4;
  String get pozhaluystaZapolniteVoprosIKak_7ad5;
  String get sozdatOpros_8401;
  String get sozdatSpisokZadach_4018;
  String get pozhaluystaZapolniteNazvanieIKak_3783;
  String get sozdatSpisokZadach_0416;
  String get vhodyaschiyVideozvonok_14d4;
  String get prinyat_5dc5;
  String get netObschihFaylov_bf77;
  String get neUdalosRazarhivirovatChatNa_b6f6;
  String get poiskVArhive_c5d8;
  String get poprobuyteIzmenitZapros_52ea;
  String get zdesBudutNahoditsyaVashiArhivirovannye_7359;
  String get vernut_54aa;
  String get zashifrovannoeSoobschenie_c9ab;
  String get soobschenieNahoditsyaVysheVIstorii_dc90;
  String get otpravlyaetFoto_67c1;
  String get otpravlyaetVideo_ce80;
  String get otpravlyaetFayl_5e88;
  String get ktoTo_8405;
  String get trebuetsyaRazreshenieNaKameruI_06fa;
  String get kameraNeNaydena_208d;
  String get zapisVideoOtmenena_1db7;
  String get slishkomKorotkoeVideosoobschenie_4676;
  String get pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35;
  String get audiozvonok_dcf6;
  String get otpravitFotoVideoAudioIli_37e9;
  String get provedenieGolosovaniyaVChate_a629;
  String get sozdatToDoSpisok_cb50;
  String get spisokZadachSOtmetkamiVypolneniya_c778;
  String get trebuetsyaRazreshenieNaZapisAudio_8175;
  String get slishkomKorotkoeSoobschenie_c2ee;
  String get uderzhivayteKnopkuDlyaZapisi_a762;
  String get udalennyy_40c6;
  String get udalennyy_c2c8;
  String get neobhodimyRazresheniyaNaMikrofonI_224b;
  String get bylATolkoChto_9ac0;
  String get chatNeNayden_ba4f;
  String get napishitePervoeSoobschenie_8260;
  String get prisoedinitsyaKKanalu_f863;
  String get vyPodpisany_5fb9;
  String get otpisatsya_ee2d;
  String get vyUspeshnoPodpisalisNaKanal_9c99;
  String get vyUspeshnoVstupiliVGruppu_61a1;
  String get neUdalosPrisoedinitsyaPoprobuyteEsche_bce5;
  String get vyrezat_a195;
  String get kopirovat_112b;
  String get vstavit_dcc4;
  String get vybratVse_4d09;
  String get zhirnyy_7774;
  String get kursiv_e0b1;
  String get kod_3f34;
  String get zacherknut_02fc;
  String get soobschenie_8b9b;
  String get smahniteDlyaOtmeny_e976;
  String get poisk_bfc9;
  String get udalitChat_4b2b;
  String get udalitKanal_482f;
  String get pozhalovatsya_a7d9;
  String get redaktirovatGruppu_e40a;
  String get udalitGruppu_dff8;
  String get poiskSoobscheniyVremennoNedostupenV_4443;
  String get zhalobaOtpravlenaModeratoram_4547;
  String get redaktirovanieGruppyVremennoNedostupnoV_05d0;
  String get vyUverenyChtoHotiteOchistit_7c3a;
  String get ochistit_7074;
  String get udalit_ed2b;
  String get vyyti_0f05;
  String get oshibkaVosproizvedeniya_ac8a;
  String get novoeZashifrovannoeSoobschenie_4d30;
  String get poiskChatov_779c;
  String get obnovlenie_53e2;
  String get soedinenie_5a58;
  String get lichnye_4cb3;
  String get neUdalosArhivirovatChatNa_36aa;
  String get oshibkaZagruzkiChatov_902f;
  String get povtorit_b914;
  String get netChatov_85e3;
  String get nachniteNovyyRazgovor_8290;
  String get neUdalosZagruzitAkkaunty_8570;
  String get vyberiteAkkaunt_79e7;
  String get bystryyVhodNaEtomUstroystve_3f30;
  String get voytiSParolem_9277;
  String get sozdatXaneoId_4033;
  String get netSohranennyhAkkauntov_b669;
  String get tolkoChto_4493;
  String get emailNedostupen_fc3e;
  String get nevernyyKod_50f9;
  String get oshibkaProverkiKoda_9018;
  String get neobhodimoRazreshenieNaDostupK_5f5c;
  String get oVyboreEmail_2609;
  String get podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0;
  String get zapreschennyh_1f49;
  String get sozdatAkkaunt_19ed;
  String get naprimerIvan_d7cb;
  String get zadayteParol_53d2;
  String get minimum8Simvolov_4ccd;
  String get unikalnoeImyaDlyaVashegoProfilya_a0ea;
  String get vashEmail_879d;
  String get dlyaSvyaziIVosstanovleniyaDostupa_c770;
  String get emailAdres_9130;
  String get vvediteParolEscheRaz_7383;
  String get parolEscheRaz_6daf;
  String get paroliNeSovpadayut_d82f;
  String get ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed;
  String get ddmmgggg_3524;
  String get sdelayteProfilUznavaemym_f2c5;
  String get profilGotov_b57d;
  String get ostalosVsegoParaShagov_37e3;
  String get yaPrinimayuPolzovatelskoeSoglashenie_c431;
  String get yaDayuSoglasieNaObrabotku_0d03;
  String get sVozvrascheniem_77ee;
  String get zagruzka_43e4;
  String get vyberiteAkkauntDlyaVhoda_d3a6;
  String get vvediteVashNikneym_51a6;
  String get voytiVDrugoyAkkaunt_d10f;
  String get nedavnieAkkaunty_953d;
  String get dobroPozhalovatVXaneo_66d0;
  String get xaneoTeperIVMobilnom_e918;
  String get mneUzheInteresno_5365;
  String get vseVashiDannyePodZaschitoy_b7d9;
  String get vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e;
  String get prodolzhit_e9c3;
  String get lokalnyeDataTsentry_f089;
  String get vashiDannyeNikogdaNePokidayut_f871;
  String get kodOtpravlenPovtorno_e109;
  String get dvuhfaktornayanautentifikatsiya_bacc;
  String get naVashEmailOtpravlen6_b457;
  String get podtverdit_e260;
  String get nePoluchiliKodOtpravitPovtorno_c1d2;
  String get imyaNikneymOSebe_7a8d;
  String get zvonkiSoobscheniyaVidimostProfilya_f905;
  String get parolSessii2fa_de9e;
  String get prilozhenie_38aa;
  String get temaRazmerTekstaAnimatsii_f0a8;
  String get pushUvedomleniyaZvuki_9cc2;
  String get oPrilozhenii_77b2;
  String get versiya200Build200_0e7b;
  String get redaktirovatProfil_56ad;
  String get dobavitKontakt_2903;
  String get nikneymPolzovatelyaUsername_a6ff;
  String get otobrazhaemoeImyaNeobyazatelno_340a;
  String get neUdalosNaytiIliDobavit_649f;
  String get ya_feef;
  String get poiskKontaktov_9a71;
  String get spisokKontaktovPust_58c6;
  String get kontaktyNeNaydeny_1b08;

  String get messages;
  String get messageAnimations;
  String get messageAnimationsDesc;
  String get archivedChats;
  String get archiveManagement;
  String get clearHistory;
  String get clearHistoryDesc;
  String get call;
  String get sendMessage;
  String get deleteContact;
  String get activeSessions;
  String get thisDevice;
  String get xaneoPcActiveNow;
  String get activeNow;
  String get twoFactorAuth;
  String get twoFactorAuthDesc;
  String get dangerZone;
  String get deleteAccount;
  String get irreversibleAction;
  String get theme;
  String get darkThemeDesc;
  String get fontSizeText;
  String get showPopups;
  String get sound;
  String get soundDesc;
  String get mainSettings;
  String get energySavingMode;
  String get energySavingModeDesc;
  String get autoSleep;
  String get autoSleepDesc;
  String get animations;
  String get reducedMotion;
  String get reducedMotionDesc;
  String get comingSoon;

  String get updateAvailable;
  String get clickToViewChanges;
  String get newVersionAvailable;
  String get newVersionAvailableTitle;
  String get youHaveLatestVersion;
  String get whatsNew;
  String get officialReleaseNotes;
  String get preparingDownload;
  String get installationStarted;
  String get whoSeesAvatar;
  String get whoSeesBirthday;
  String get whoSeesOnlineTime;

  String get downloadVersion;
  String get downloadSource;
  String get directInAppInstall;
  String get autoDownloadAndRun;
  String get githubReleasePage;
  String get skip;
  String get updateAction;
  String get installAction;
  String get isTyping;
  String get isRecordingVoice;
  String get areTyping;

  String get group;
  String get channel;

  String get profile;
  String get copied;
  String get userHidInfo;
  String get leaveGroup;
  String get joinGroup;
  String get unsubscribeChannel;
  String get subscribeChannel;
  String get deleteChat;
  String get pinChat;
  String get unpinChat;
  String get muteNotifications;
  String get unmuteNotifications;
  String get backToChats;
  String get globalSearch;
  String get chatSettings;
  String get emoji;
  String get attachFile;
  String get startCall;
  String get audioCall;
  String get audioCallDesc;
  String get videoCall;
  String get videoCallDesc;
  String get voiceRecordTitle;
  String get videoRecordTitle;
  String get holdToRecordHint;
  String get addAttachment;
  String get emojiPanelInDev;
  String get recordingVoice;
  String get recordingVideo;
  String get releaseToSend;
  String get typeMessage;
  String get file;
  String get todoList;
  String get poll;
  String get today;
  String get yesterday;
  String get monthJan;
  String get monthFeb;
  String get monthMar;
  String get monthApr;
  String get monthMay;
  String get monthJun;
  String get monthJul;
  String get monthAug;
  String get monthSep;
  String get monthOct;
  String get monthNov;
  String get monthDec;
  String get createTodo;
  String get listName;
  String get todoItems;
  String get addTodoItem;
  String get itemHintPrefix;
  String get createPoll;
  String get pollQuestion;
  String get pollOptions;
  String get addPollOption;
  String get optionHintPrefix;
  String get allowMultipleAnswers;
  String get singleChoice;
  String get accountsTitle;
  String get addAccount;
  String get accountLimitNotice;
  String get media;
  String get files;
  String get voice;
  String get links;
  String get bio;
  String get username;
  String get birthday;
  String get noSharedMedia;
  String get noSharedFiles;
  String get noSharedVoice;
  String get noSharedLinks;
  String get savedMessagesDesc;
  String get music;
  String get noSharedMusic;
  String get secureDesktopCommunicator;
  String get noMessagesTitle;
  String get noMessagesSubtitle;

  String membersCount(int count);
  String subscribersCount(int count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ru', 'en', 'fr', 'es', 'zh', 'ja', 'ko', 'ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru': return AppLocalizationsRu();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
    case 'es': return AppLocalizationsEs();
    case 'zh': return AppLocalizationsZh();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'ar': return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
