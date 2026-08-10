// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Xaneo PC';

  @override
  String get welcomeTitle => 'Welcome to Xaneo';

  @override
  String get welcomeDescription =>
      'Xaneo is now on your computer! Maximum performance and convenience.';

  @override
  String get getStartedButton => 'Get Started';

  @override
  String get privacyTitle => 'All your data is secure';

  @override
  String get privacyDescription =>
      'All messages in Xaneo are protected by end-to-end encryption. Xaneo never knows their content.';

  @override
  String get continueButton => 'Continue';

  @override
  String get dataStorageTitle => 'All Xaneo data centers are located in Russia';

  @override
  String get dataStorageDescription =>
      'Your data never leaves the country and is stored in secure data centers.';

  @override
  String get finishButton => 'Finish';

  @override
  String get setupCompleted => 'Setup completed!';

  @override
  String get loginFormTitle => 'Login';

  @override
  String get loginFieldHint => 'Login';

  @override
  String get passwordFieldHint => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccount => 'No account?';

  @override
  String get registerButton => 'Register';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String welcomeUser(String username) {
    return 'Welcome, $username!';
  }

  @override
  String get invalidCredentials =>
      'Invalid credentials. Please check your username and password.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get connectionError =>
      'Connection error. Please check your internet connection.';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDescription => 'Enable or disable notifications';

  @override
  String get darkThemeDescription => 'Enable or disable dark theme';

  @override
  String fontSize(int size) {
    return 'Font size: $size';
  }

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Select interface language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get appVersion => 'App version';

  @override
  String get registerTitle => 'Registration';

  @override
  String get registerStep0Title => 'What\'s your name?';

  @override
  String get registerStep0Subtitle => 'Enter your real name';

  @override
  String get registerStep1Title => 'When were you born?';

  @override
  String get registerStep1Subtitle => 'You must be at least 14 years old';

  @override
  String get registerStep2Title => 'Choose a nickname';

  @override
  String get registerStep2Subtitle => 'Nickname must be unique';

  @override
  String get registerStep3Title => 'Your email';

  @override
  String get registerStep3Subtitle => 'We\'ll send a verification code';

  @override
  String get registerStep4Title => 'Create a password';

  @override
  String get registerStep4Subtitle => 'Create a strong password';

  @override
  String get registerStep5Title => 'Add a photo';

  @override
  String get registerStep5Subtitle => 'This is optional, but nice';

  @override
  String get registerStep6Title => 'Last step';

  @override
  String get registerStep6Subtitle => 'Accept the terms of use';

  @override
  String get yourName => 'Your name';

  @override
  String get birthDate => 'Birth date';

  @override
  String get nickname => 'Nickname';

  @override
  String get checkingNickname => 'Checking availability...';

  @override
  String get nicknameAvailable => 'Nickname available';

  @override
  String get nicknameTaken => 'Nickname taken';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get addPhoto => 'Tap to add a photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get acceptTerms => 'I accept the terms of use';

  @override
  String get acceptDataProcessing =>
      'I agree to the processing of personal data';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get registrationSuccess => 'Registration successful!';

  @override
  String get registrationError => 'Registration error';

  @override
  String get enterVerificationCode => 'Enter verification code';

  @override
  String get invalidVerificationCode => 'Invalid verification code';

  @override
  String get codeSent => 'Verification code sent to email';

  @override
  String get sendCodeError => 'Error sending code';

  @override
  String get confirmEmail => 'Confirm e-mail';

  @override
  String codeSentToEmail(String email) {
    return 'We sent a verification code to\n$email';
  }

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(int count) {
    return 'Resend in $count sec';
  }

  @override
  String get acceptTermsRequired =>
      'You must accept the terms and data processing consent';

  @override
  String get about => 'About';

  @override
  String get aboutDescription =>
      'A modern application for managing and controlling systems.';

  @override
  String get close => 'Close';

  @override
  String get technicalInfo => 'Technical Information';

  @override
  String get platform => 'Platform';

  @override
  String get architecture => 'Processor Architecture';

  @override
  String get flutter => 'Flutter';

  @override
  String get viewOnGitHub => 'View on GitHub';

  @override
  String get chats => 'Chats';
  @override
  String get search => 'Search';
  @override
  String get searchPlaceholder => 'Search messages and chats...';
  @override
  String get savedMessages => 'Saved Messages';
  @override
  String get online => 'online';
  @override
  String get offline => 'offline';
  @override
  String get lastSeenRecently => 'last seen recently';
  @override
  String get musicPlaylist => 'Music Playlist';
  @override
  String get reply => 'Reply';
  @override
  String get edit => 'Edit';
  @override
  String get pin => 'Pin';
  @override
  String get unpin => 'Unpin';
  @override
  String get delete => 'Delete';
  @override
  String get forward => 'Forward';
  @override
  String get members => 'Members';
  @override
  String get noMessages => 'No messages yet';

  @override
  String get joinedChat => 'joined the chat';
  @override
  String get leftChat => 'left the chat';
  @override
  String get subscribedChannel => 'subscribed to channel';
  @override
  String get unsubscribedChannel => 'unsubscribed from channel';
  @override
  String get invited => 'invited';
  @override
  String get systemMessage => 'System message';
  @override
  String get selectChatToStart => 'Select a chat to start messaging';
  @override
  String get toArchive => 'Archive';
  @override
  String get unarchive => 'Unarchive';
  @override
  String get archive => 'Archive';
  @override
  String get archiveEmpty => 'Archive is empty';
  @override
  String get voiceMessage => 'Voice message';
  @override
  String get videoMessage => 'Video message';

  @override
  String get personalData => 'Personal Data';
  @override
  String get personalDataDesc => 'Name, username, profile photo';
  @override
  String get privacyDesc => 'Who can message, call, or see profile';
  @override
  String get chatsSettings => 'Chat Settings';
  @override
  String get chatsSettingsDesc => 'Notifications, themes, history';
  @override
  String get contacts => 'Contacts';
  @override
  String get contactsDesc => 'Your saved contacts';
  @override
  String get security => 'Security';
  @override
  String get securityDesc => 'Sessions, password, authentication';
  @override
  String get appearance => 'Appearance';
  @override
  String get appearanceDesc => 'Theme, font, UI scaling';
  @override
  String get energySaving => 'Power Saving';
  @override
  String get energySavingDesc => 'Animations and performance';

  @override
  String get account => 'ACCOUNT';
  @override
  String get interface => 'INTERFACE';
  @override
  String get logout => 'Log out';

  @override
  String get basicInfo => 'Basic Information';
  @override
  String get nicknameCannotBeChanged => 'Username cannot be changed in app';
  @override
  String get aboutMe => 'About Me';
  @override
  String get aboutMeHint => 'Tell about yourself...';
  @override
  String get save => 'Save';
  @override
  String get saving => 'Saving...';
  @override
  String get communications => 'Communications';
  @override
  String get whoCanMessage => 'Who can send messages';
  @override
  String get whoCanCall => 'Who can call';
  @override
  String get whoCanRecordVoice => 'Who can record voice notes';
  @override
  String get whoCanSendFiles => 'Who can send files';
  @override
  String get whoCanInvite => 'Who can invite to groups';
  @override
  String get profileVisibility => 'Profile Visibility';
  @override
  String get whoSeesNickname => 'Who sees my username';
  @override
  String get everyone => 'Everyone';
  @override
  String get contactsOnly => 'Contacts Only';
  @override
  String get nobody => 'Nobody';
  @override
  String get addContact => 'Add';
  @override
  String get addContactTitle => 'Add Contact';
  @override
  String get userNicknameHint => 'User\'s username';
  @override
  String get displayNameOptional => 'Display Name (optional)';
  @override
  String get noContactsYet => 'You have no saved contacts yet';
  @override
  String get appInfo => 'Application Information';
  @override
  String get checkUpdates => 'Check for Updates';
  @override
  String get checkingUpdates => 'Checking for updates...';
  @override
  String get cancel => 'Cancel';
  @override
  String get obnovlenie_7e32 => 'UPDATE';
  @override
  String get obnovleniePrilozheniya_b6c3 => 'APP UPDATE';
  @override
  String get podgotovkaKZagruzke_a5c7 => 'Preparing to download...';
  @override
  String get ustanovkaZapuschena_d378 => 'The installation has started!';
  @override
  String get dostupnaNovayaVersiyaPrilozheniya_eeae =>
      'New version of the application is available';
  @override
  String get chtoNovogo_74e2 => 'WHAT\'S NEW';
  @override
  String get ofitsialnoeOpisanieRelizaDostupnoNa_3ea3 =>
      'The official release description is available on the GitHub page.';
  @override
  String get istochnikZagruzki_0e6e => 'DOWNLOAD SOURCE';
  @override
  String get pryamayaUstanovkaVPrilozhenii_16f5 =>
      'Direct installation in the application';
  @override
  String get avtomaticheskoeSkachivanieIZapusk_9a3f =>
      'Automatic download and launch';
  @override
  String get stranitsaRelizaNaGithub_1531 => 'Release page on GitHub';
  @override
  String get propustit_03ee => 'Skip';
  @override
  String get ustanovka_516d => 'Installation...';
  @override
  String get obnovit_dbe5 => 'Update';
  @override
  String get lichnyeDannye_be85 => 'Personal information';
  @override
  String get imyaNikneymFotoProfilya_28ac => 'Name, nickname, profile photo';
  @override
  String get privatnost_0899 => 'Privacy';
  @override
  String get ktoMozhetPisatZvonitVidet_1789 =>
      'Who can write, call, see profile';
  @override
  String get nastroykiChatov_7ca8 => 'Chat settings';
  @override
  String get uvedomleniyaTemyIstoriya_51da => 'Notifications, topics, history';
  @override
  String get kontakty_7576 => 'Contacts';
  @override
  String get vashiSohranennyeKontakty_a641 => 'Your saved contacts';
  @override
  String get bezopasnost_3677 => 'Security';
  @override
  String get sessiiParolAutentifikatsiya_73f5 =>
      'Sessions, password, authentication';
  @override
  String get vneshniyVid_6873 => 'Appearance';
  @override
  String get temaShriftMasshtab_d8c9 => 'Theme, font, scale';
  @override
  String get yazyk_0577 => 'Language';
  @override
  String get yazykInterfeysaKlienta_2ad3 => 'Client interface language';
  @override
  String get uvedomleniya_d2ed => 'Notifications';
  @override
  String get zvukiBannery_1b60 => 'Sounds, banners';
  @override
  String get energosberezhenie_0b19 => 'Energy saving';
  @override
  String get animatsiiIProizvoditelnost_fba8 => 'Animations and Performance';
  @override
  String get oPrilozhenii_322e => 'About the application';
  @override
  String get versiyaProverkaObnovleniySsylki_6efc =>
      'Version, check for updates, links';
  @override
  String get nastroyki_b01b => 'SETTINGS';
  @override
  String get nastroyki_c919 => 'Settings';
  @override
  String get proverkaObnovleniy_f3e0 => 'Checking for updates...';
  @override
  String get neUdalosZagruzitNastroyki_f753 => 'Failed to load settings';
  @override
  String get oshibkaSohraneniya_0387 => 'Save error';
  @override
  String get dannyeSohraneny_fd62 => 'Data saved';
  @override
  String get gost_9618 => 'Guest';
  @override
  String get akkaunt_38ac => 'ACCOUNT';
  @override
  String get interfeys_49be => 'INTERFACE';
  @override
  String get vyytiIzAkkaunta_6d41 => 'Log out of your account';
  @override
  String get informatsiyaOPrilozhenii_00c4 => 'Application information';

  @override
  String get proverka_13bc => 'Checking...';
  @override
  String get proveritObnovleniya_ab45 => 'Check for updates';
  @override
  String get osnovnayaInformatsiya_6fec => 'Basic information';
  @override
  String get imya_d38d => 'Name';
  @override
  String get vvediteVasheImya_751e => 'Enter your name';
  @override
  @override
  String get nikneym_3fea => 'Username';
  @override
  String get nikneymNelzyaIzmenitVPrilozhenii_75d0 =>
      'Nickname cannot be changed in the application';
  @override
  String get oSebe_0b3b => 'About me';
  @override
  String get rasskazhiteOSebe_1c37 => 'Tell us about yourself...';
  @override
  String get sohranenie_c15f => 'Saving...';
  @override
  String get sohranit_74ea => 'Save';
  @override
  @override
  String get vse_984b => 'All';
  @override
  String get tolkoKontakty_a559 => 'Contacts only';
  @override
  String get nikto_ba19 => 'Nobody';
  @override
  String get kommunikatsii_1242 => 'Communications';
  @override
  String get ktoMozhetPisatSoobscheniya_4645 => 'Who can write messages';
  @override
  String get ktoMozhetZvonit_c427 => 'Who can call';
  @override
  String get ktoMozhetZapisyvatGolosovye_c69a => 'Who can record voices';
  @override
  String get ktoMozhetOtpravlyatFayly_2e40 => 'Who can send files';
  @override
  String get ktoMozhetPriglashatVGruppy_cdc0 => 'Who can invite to groups';
  @override
  String get vidimostProfilya_34bf => 'Profile Visibility';
  @override
  String get ktoViditMoyNikneym_54b8 => 'Who sees my nickname';
  @override
  String get ktoViditMoyAvatar_e9f6 => 'Who sees my avatar';
  @override
  String get ktoViditMoyDenRozhdeniya_ccc7 => 'Who sees my birthday';
  @override
  String get ktoViditVremyaMoeyAktivnosti_4349 => 'Who sees my activity time';
  @override
  String get neUdalosZagruzitKontakty_02a3 => 'Failed to load contacts';
  @override
  String get dobavitKontakt_4278 => 'Add a contact';
  @override
  String get nikneymPolzovatelya_5610 => 'User nickname';
  @override
  String get otobrazhaemoeImyaOptsionalno_bbd1 => 'Display name (optional)';
  @override
  @override
  String get otmena_987b => 'Cancel';
  @override
  String get dobavit_5eba => 'Add';
  @override
  String get uVasPokaNetSohranennyh_b64b =>
      'You don\'t have any saved contacts yet';
  @override
  String get pozvonit_ccfa => 'Call';
  @override
  String get napisat_0144 => 'Write';
  @override
  String get udalitKontakt_065d => 'Delete contact';
  @override
  String get soobscheniya_7e26 => 'Messages';
  @override
  String get animatsiiSoobscheniy_bc8b => 'Message Animations';
  @override
  String get pokazyvatAnimatsiiPriOtpravkeI_d663 =>
      'Show animations when sending and receiving';
  @override
  String get arhivirovannyeChaty_d990 => 'Archived chats';
  @override
  String get upravlenieArhivom_e843 => 'Archive management';
  @override
  String get ochistitIstoriyu_837a => 'Clear history';
  @override
  String get udalitVseSoobscheniyaLokalno_fbbd => 'Delete all messages locally';
  @override
  String get aktivnyeSessii_5c96 => 'Active sessions';
  @override
  String get etoUstroystvo_26f6 => 'This device';
  @override
  String get xaneoPcAktivnoSeychas_25b4 => 'Xaneo PC • Active now';
  @override
  String get aktivno_87a4 => 'Active';
  @override
  String get dvoynayaAutentifikatsiya_66ae => 'Double authentication';
  @override
  String get zaschitaAkkauntaOdnorazovymParolem_e9f1 =>
      'Account protection with one-time password';
  @override
  String get opasnayaZona_25bc => 'Danger zone';
  @override
  String get udalitAkkaunt_05c7 => 'Delete account';
  @override
  String get neobratimoeDeystvie_7232 => 'Irreversible action';
  @override
  String get tema_9e26 => 'Subject';
  @override
  String get temnayaTema_cb48 => 'Dark theme';
  @override
  String get pereklyuchitMezhduTemnymISvetlym_5415 =>
      'Switch between dark and light mode';
  @override
  String get razmerShrifta_1155 => 'Font size';
  @override
  String get a_87a0 => 'A';
  @override
  String get pokazyvatVsplyvayuschieUvedomleniya_754e =>
      'Show pop-up notifications';
  @override
  String get zvuk_9329 => 'Sound';
  @override
  String get vosproizvoditZvukPriNovomSoobschenii_47cc =>
      'Play sound on new message';
  @override
  String get osnovnyeNastroyki_231c => 'Basic settings';
  @override
  String get rezhimEkonomiiEnergii_edfc => 'Power Saving Mode';
  @override
  String get optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb =>
      'Optimizes application performance to save resources';
  @override
  String get avtomaticheskiySpyaschiyRezhim_5955 => 'Auto sleep mode';
  @override
  String get perevoditPrilozhenieVSpyaschiyRezhim_1c07 =>
      'Puts the application into sleep mode when inactive';
  @override
  String get animatsii_05c7 => 'Animations';
  @override
  String get uproschennyeAnimatsii_3a13 => 'Simplified animations';
  @override
  String get umenshaetKolichestvoAnimatsiyInterfeysa_6bf1 =>
      'Reduces the number of interface animations';
  @override
  String get skoroBudetDostupno_de07 => 'Coming soon';
  @override
  String get gostevoyRezhim_6d82 => 'Guest mode';
  @override
  String get voyditeDlyaDostupaKAkkauntu_a5c8 => 'Login to access your account';
  @override
  String get nazhmiteDlyaProsmotraIzmeneniy_0255 => 'Click to view changes';
  @override
  String get vvediteKodPodtverzhdeniya_61af => 'Enter verification code';
  @override
  @override
  String get nevernyyKodPodtverzhdeniya_7762 => 'Invalid verification code';
  @override
  String get podtverditeEMail_4bd4 => 'Confirm your email';
  @override
  String get proverit_340b => 'Check';
  @override
  @override
  String get otpravitKodPovtorno_7703 => 'Resend code';
  @override
  String get sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e =>
      'Modern desktop application\nwith a beautiful interface and 3D effects';
  @override
  String get tehnologii_6332 => 'Technologies';
  @override
  String get vyNashliPashalku_1a57 => '🎉 You found an Easter egg! 🎉';
  @override
  String get spasiboZaIspolzovanieXaneo_d079 => 'Thanks for using xaneo!';
  @override
  String get globalnyyPoisk_77bf => 'GLOBAL SEARCH';
  @override
  @override
  String get poiskKontaktovChatovKanalovBotov_db66 =>
      'Search contacts, chats, channels, bots...';
  @override
  @override
  String get lyudi_c7ae => 'People';
  @override
  @override
  String get gruppy_ebc4 => 'Groups';
  @override
  @override
  String get kanaly_0c11 => 'Channels';
  @override
  @override
  String get boty_d6e4 => 'Bots';
  @override
  @override
  String get izbrannoe_2fc4 => 'Saved Messages';
  @override
  @override
  String get vvediteZaprosDlyaPoiskaPo_9955 =>
      'Type a query to search across Xaneo network';
  @override
  @override
  String get nichegoNeNaydeno_8767 => 'Nothing found';
  @override
  @override
  String get izbrannoe_b637 => 'SAVED MESSAGES';
  @override
  @override
  String get boty_800d => 'BOTS';
  @override
  @override
  String get kanaly_ccec => 'CHANNELS';
  @override
  @override
  String get gruppy_cfd6 => 'GROUPS';
  @override
  @override
  String get polzovateli_e0ec => 'USERS';
  @override
  @override
  String get sohranennyeSoobscheniya_6b62 => 'Saved messages';
  @override
  @override
  String get bot_0ae1 => 'Bot';
  @override
  @override
  String get bot_0f46 => 'bot';
  @override
  @override
  String get gruppa_99d9 => 'Group';
  @override
  @override
  String get kanal_2710 => 'Channel';
  @override
  String get versiya_3725 => 'Version';
  @override
  String get tehnicheskayaInformatsiya_ba0f => 'Technical information';
  @override
  String get platforma_8848 => 'Platform';
  @override
  String get arhitekturaProtsessora_c079 => 'Processor architecture';
  @override
  String get posmotretNaGithub_5238 => 'View on GitHub';
  @override
  String get zakryt_dd94 => 'Close';
  @override
  String get vklyuchitTemnuyuTemu_ed17 => 'Enable dark theme';
  @override
  String get vklyuchitUvedomleniya_d311 => 'Enable notifications';
  @override
  String get kastomnyyOverleyXaneo_7d39 => 'Custom Xaneo overlay';
  @override
  String get animirovannyeUvedomleniyaSBystrymOtvetom_a25d =>
      'Animated notifications with quick response';
  @override
  String get aaBbVv_1c6b => 'Aa bb bb';
  @override
  String get pleylist_a04c => 'PLAYLIST';
  @override
  String get spisokMuzyki_d477 => 'MUSIC LIST';
  @override
  String get loc_0B_5a4d => '0 B';
  @override
  String get b_3b67 => 'B';
  @override
  String get kb_419d => 'KB';
  @override
  String get mb_b808 => 'MB';
  @override
  String get gb_e572 => 'GB';
  @override
  String get audiozapis_867d => 'Audio recording';
  @override
  String get muzykalnyyTrek_b15d => 'Music track';
  @override
  String get muzykalnyeTrekiOtsutstvuyut_3301 => 'There are no music tracks';
  @override
  @override
  String get nikneymUzheZanyat_59aa => 'Username is already taken';
  @override
  @override
  String get oshibkaProverki_2ab0 => 'Verification error';
  @override
  @override
  String get emailUzheZanyat_17e1 => 'Email is already registered';
  @override
  @override
  String get oshibkaOtpravkiKoda_a42a => 'Error sending verification code';
  @override
  @override
  String get neobhodimoPrinyatUsloviyaISoglasie_e31e =>
      'You must accept the terms of use and privacy policy';
  @override
  @override
  String get registratsiyaUspeshna_9d5c => 'Registration successful!';
  @override
  @override
  String get oshibkaRegistratsii_b9f2 => 'Registration error';
  @override
  @override
  String get nazad_2b0b => 'Back';
  @override
  @override
  String get kakVasZovut_68b7 => 'What is your name?';
  @override
  @override
  String get kogdaVyRodilis_26f2 => 'When were you born?';
  @override
  @override
  String get pridumayteNikneym_221b => 'Choose a username';
  @override
  @override
  String get vashEmail_8bbd => 'Your Email';
  @override
  @override
  String get podtverzhdenieEmail_281f => 'Email Verification';
  @override
  @override
  String get sozdayteParol_5f4c => 'Create a password';
  @override
  @override
  String get podtverzhdenieParolya_ebc2 => 'Confirm password';
  @override
  @override
  String get dobavteFoto_25eb => 'Add a photo';
  @override
  @override
  String get posledniyShag_e0c5 => 'Final step';
  @override
  @override
  String get vvediteVasheNastoyascheeImya_e656 => 'Enter your real name';
  @override
  @override
  String get vamDolzhnoBytNeMenee_1111 => 'You must be at least 13 years old';
  @override
  @override
  String get nikneymDolzhenBytUnikalnym_952d => 'Username must be unique';
  @override
  @override
  String get myOtpravimKodPodtverzhdeniya_fc71 =>
      'We will send a verification code to your email';
  @override
  @override
  String get vvedite6ZnachnyyKodIz_f22f =>
      'Enter the 6-digit code from the email';
  @override
  @override
  String get pridumayteNadezhnyyParol_2312 =>
      'Create a strong password (min 8 chars)';
  @override
  @override
  String get povtoriteParolEscheRaz_6723 => 'Repeat password once more';
  @override
  @override
  String get etoNeobyazatelnoNoPriyatno_b6a3 =>
      'This is optional, but helps friends find you';
  @override
  @override
  String get proverteVashiDannyeIPrimite_3121 =>
      'Review your information and accept terms';
  @override
  @override
  String get registratsiya_0b93 => 'Registration';
  @override
  @override
  String get vasheImya_51eb => 'Your name';
  @override
  @override
  @override
  String get proverkaDostupnosti_da13 => 'Checking availability...';
  @override
  @override
  @override
  String get nikneymDostupen_3fc9 => 'Username available';
  @override
  @override
  @override
  String get nikneymZanyat_8a5f => 'Username taken';
  @override
  @override
  @override
  String get emailDostupen_e903 => 'Email available';
  @override
  @override
  @override
  String get emailZanyat_fb40 => 'Email taken';
  @override
  @override
  String get kodPodtverzhdeniya_1c9d => 'Verification code';
  @override
  @override
  String get parol_5ebe => 'Password';
  @override
  @override
  String get podtverditeParol_e3e3 => 'Confirm password';
  @override
  @override
  String get nazhmiteChtobyDobavitFoto_d6e8 => 'Tap to add photo';
  @override
  @override
  String get udalitFoto_3426 => 'Delete photo';
  @override
  @override
  String get yaPrinimayuUsloviyaIspolzovaniya_391a =>
      'I accept the Terms of Use';
  @override
  @override
  String get yaSoglasenNaObrabotkuPersonalnyh_f2a8 =>
      'I agree to the processing of personal data';
  @override
  @override
  String get zavershit_b0e3 => 'Finish';
  @override
  @override
  String get dalee_c453 => 'Next';
  @override
  @override
  String get dataRozhdeniya_505e => 'Date of birth';
  @override
  String get vklyuchitTemnuyuTemuOformleniya_86c4 => 'Enable dark theme';
  @override
  @override
  String get yanvar_ee86 => 'January';
  @override
  @override
  String get fevral_28ff => 'February';
  @override
  @override
  String get mart_d766 => 'March';
  @override
  @override
  String get aprel_03e9 => 'April';
  @override
  @override
  String get may_2e53 => 'May';
  @override
  @override
  String get iyun_cfcb => 'June';
  @override
  @override
  String get iyul_89fb => 'July';
  @override
  @override
  String get avgust_de5a => 'August';
  @override
  @override
  String get sentyabr_ebfb => 'September';
  @override
  @override
  String get oktyabr_1720 => 'October';
  @override
  @override
  String get noyabr_66fb => 'November';
  @override
  @override
  String get dekabr_39b3 => 'December';
  @override
  @override
  String get pn_2c1e => 'Mon';
  @override
  @override
  String get vt_7145 => 'Tue';
  @override
  @override
  String get sr_c6e4 => 'Wed';
  @override
  @override
  String get cht_a51f => 'Thu';
  @override
  @override
  String get pt_0123 => 'Fri';
  @override
  @override
  String get sb_3a4b => 'Sat';
  @override
  @override
  String get vs_4ad9 => 'Sun';
  @override
  @override
  String get gotovo_34e1 => 'Done';
  @override
  String get oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b =>
      'Key recovery error (failed to overwrite)';
  @override
  String get kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7 =>
      'Critical error when regenerating encryption keys';
  @override
  String get oshibkaZagruzkiKlyucheyNaServer_ff9b =>
      'Error loading keys to server';
  @override
  String get oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4 =>
      'Error retrieving encryption keys';
  @override
  String get prevyshenLimitV5Akkauntov_a6a9 =>
      'The limit of 5 accounts on this client has been exceeded or there is a connection error.';
  @override
  @override
  @override
  String get oshibkaAvtorizatsii_9f5c => 'Authorization error';
  @override
  @override
  @override
  String get oshibkaPodklyucheniyaKServeru_8b96 => 'Server connection error';
  @override
  @override
  String get nazadKMessendzheru_de29 => 'Back to messenger';
  @override
  @override
  String get voytiVAkkaunt_c439 => 'Log in to account';
  @override
  @override
  String get vvediteParol_1370 => 'Enter password';
  @override
  @override
  String get vvediteSvoiDannyeDlyaDostupa_319e =>
      'Enter your credentials to access your messages.';
  @override
  @override
  String get voyti_63a7 => 'Log In';
  @override
  String get sobesednik_7025 => 'Interlocutor';
  @override
  String get vy_0101 => 'you';
  @override
  String get vyDelitesSvoimEkranom_16b1 => 'You share your screen';
  @override
  String get polzovatel_f154 => 'User';
  @override
  String get ishodyaschiyVyzov_650b => 'Outgoing call...';
  @override
  String get vhodyaschiyVyzov_19ff => 'Incoming call...';
  @override
  String get podklyucheno_d022 => 'Connected';
  @override
  String get ozhidanieOtveta_a984 => 'Waiting for a response...';
  @override
  String get razgovorPoAudiosvyazi_3ed7 => 'Audio conversation';
  @override
  String get translyatsiyaVashegoEkranaZapuschena_575a =>
      'Your screencast has started';
  @override
  String get sobesednikViditVseChtoProishodit_c759 =>
      'The interlocutor sees everything that happens on your desktop';
  @override
  String get vhodyaschiyVyzov_905e => 'INCOMING CALL';
  @override
  String get neizvestnyy_be89 => 'Unknown';
  @override
  String get videozvonok_dd18 => 'Video call...';
  @override
  String get golosovoyZvonok_5410 => 'Voice call...';
  @override
  String get otklonit_8b0d => 'Reject';
  @override
  String get otvetit_e568 => 'Reply';
  @override
  String get gruppovoyZvonok_dac1 => 'Group call';
  @override
  String get podklyuchenieKZvonku_e2cf => 'Connecting to a call...';
  @override
  String get podklyuchenieKVeschaniyu_038b => 'Connecting to broadcast...';
  @override
  String get uchastnik_cffb => 'Member';
  @override
  String get vy_479c => 'YOU';
  @override
  String get svernut_ca9f => 'Collapse';
  @override
  String get vhodyaschiyVyzov_d2f3 => 'Incoming call';
  @override
  String get novoeSoobschenie_1d49 => 'New message';
  @override
  String get vashOtvet_40c2 => 'Your answer...';
  @override
  String get videovyzov_3353 => 'Video call...';
  @override
  String get audiovyzov_bbb5 => 'Audio call...';
  @override
  String get nachatZvonok_3d26 => 'START A CALL';
  @override
  String get golosovoyZvonok_b615 => 'Voice call';
  @override
  String get pozvonitPoGolosovoySvyazi_4069 => 'Make a voice call';
  @override
  String get videozvonok_8142 => 'Video call';
  @override
  String get pozvonitSVklyuchennoyKameroy_fb05 => 'Call with camera on';
  @override
  String get zashifrovannoeSoobschenie_ca35 => '[Encrypted message]';
  @override
  String get golosovoeSoobschenie_4a85 => '🎤 Voice message';
  @override
  String get videosoobschenie_d687 => '🎬 Video message';
  @override
  String get fayl_826d => '📎 File';
  @override
  String get zvonok_e8d5 => '📞 Call';
  @override
  String get oshibkaDeshifrovaniya_4146 => '[Decryption error]';
  @override
  String get zapisyvaetGolosovoe_2a5c => 'records voice...';
  @override
  String get pechataet_812c => 'prints...';
  @override
  String get neUdalosArhivirovatChat_ab89 => 'Failed to archive chat';
  @override
  String get neUdalosRazarhivirovatChat_f0d7 => 'Failed to unarchive chat';
  @override
  String get arhiv_56aa => 'Archive';
  @override
  String get netUserid_634a => '[No userId]';
  @override
  String get netKlyucha_337b => '[No key]';
  @override
  String get neizvestnyyTipChata_2617 => '[Unknown chat type]';
  @override
  String get neUdalosPoluchitKlyuchShifrovaniya_b953 =>
      'Failed to obtain encryption key for chat';
  @override
  String get gruppa_19c2 => 'group';
  @override
  String get uchastnik_5bce => 'participant';
  @override
  String get uchastnika_92d9 => 'participant';
  @override
  String get uchastnikov_5d6b => 'participants';
  @override
  String get kanal_64ec => 'channel';
  @override
  String get podpischik_695a => 'subscriber';
  @override
  String get podpischika_b490 => 'subscriber';
  @override
  String get podpischikov_ba39 => 'subscribers';
  @override
  String get segodnya_9626 => 'Today';
  @override
  String get vchera_61d4 => 'Yesterday';
  @override
  String get yanvarya_d861 => 'January';
  @override
  String get fevralya_fcf9 => 'February';
  @override
  String get marta_bb77 => 'March';
  @override
  String get aprelya_2b5a => 'April';
  @override
  String get maya_4dbb => 'May';
  @override
  String get iyunya_adcb => 'June';
  @override
  String get iyulya_3236 => 'July';
  @override
  String get avgusta_e3aa => 'August';
  @override
  String get sentyabrya_a146 => 'September';
  @override
  String get oktyabrya_7abd => 'October';
  @override
  String get noyabrya_6e78 => 'November';
  @override
  String get dekabrya_29cc => 'December';
  @override
  String get vyPodpisalisNaKanal_b2b3 => 'You have subscribed to the channel';
  @override
  String get vyPrisoedinilisKGruppe_07bd => 'You have joined the group';
  @override
  String get neUdalosPrisoedinitsya_31e6 => 'Failed to join';
  @override
  String get vyOtpisalisOtKanala_7698 =>
      'You have unsubscribed from the channel';
  @override
  String get vyPokinuliGruppu_5a52 => 'You left the group';
  @override
  String get neUdalosVypolnitDeystvie_3cfd => 'Action failed';
  @override
  String get neUdalosPereklyuchitAkkaunt_968b => 'Failed to switch account';
  @override
  String get media_c247 => 'Media';
  @override
  String get fayly_200c => 'Files';
  @override
  String get golos_2d89 => 'Voice';
  @override
  String get ssylki_9f58 => 'Links';
  @override
  String get profil_c62a => 'PROFILE';
  @override
  String get imyaPolzovatelya_6fd4 => 'Username';
  @override
  String get denRozhdeniya_e41d => 'Birthday';
  @override
  String get polzovatelSkrylInformatsiyuOSebe_f416 =>
      'The user has hidden information about himself';
  @override
  String get god_6270 => 'year';
  @override
  String get goda_7443 => 'year';
  @override
  String get let_257a => 'years';
  @override
  String get skopirovano_f70b => 'Copied';
  @override
  String get akkaunty_80b5 => 'ACCOUNTS';
  @override
  String get dobavitAkkaunt_5253 => 'Add account';
  @override
  String get limit5Akkauntov_fdb7 => 'Limit: 5 accounts';
  @override
  String get nazadKChatam_7edb => 'Back to chats';
  @override
  String get chaty_19ad => 'Chats';
  @override
  String get globalnyyPoisk_7ff2 => 'Global search';
  @override
  String get arhivPust_3e22 => 'Archive is empty';
  @override
  String get netSoobscheniy_29d4 => 'No messages';
  @override
  String get toDoList_27e1 => '📋 To-Do sheet';
  @override
  String get opros_6ff1 => '🗳️ Poll';
  @override
  String get fotografiya_5709 => '📷 Photography';
  @override
  String get razarhivirovat_416b => 'Unzip';
  @override
  String get vArhiv_ce22 => 'To the archive';
  @override
  String get chat_c52b => 'Chat';
  @override
  String get vyberiteChatDlyaNachalaObscheniya_36a5 =>
      'Select a chat to start chatting';
  @override
  String get bot_2712 => 'bot';
  @override
  String get vSeti_d902 => 'online';
  @override
  String get neVSeti_ee01 => 'offline';
  @override
  String get nastroykiChata_1e0d => 'Chat settings';
  @override
  String get pokinutGruppu_e6ce => 'Leave group';
  @override
  String get prisoedinitsyaKGruppe_eb45 => 'Join the group';
  @override
  String get otpisatsyaOtKanala_fdbc => 'Unsubscribe from channel';
  @override
  String get podpisatsyaNaKanal_2dad => 'Subscribe to the channel';
  @override
  String get netSoobscheniyNapishiteChtoNibud_2bf4 =>
      'No messages yet. Write something!';
  @override
  String get prisoedinilsyaKChatu_f623 => 'joined the chat';
  @override
  String get pokinulChat_d567 => 'left the chat';
  @override
  String get podpisalsyaNaKanal_0673 => 'subscribed to the channel';
  @override
  String get otpisalsyaOtKanala_fa13 => 'unsubscribed from the channel';
  @override
  String get polzovatelya_1083 => 'user';
  @override
  String get priglasil_47ae => 'invited';
  @override
  String get rasshifrovka_e47f => '[Transcript...]';
  @override
  String get sistemnoeSoobschenie_d2bd => 'System message';
  @override
  String get soobschenie_3715 => 'Message';
  @override
  String get videosoobschenie_57f1 => '📹 Video message';
  @override
  String get spisokZadach_cfa4 => '📋 Task list';
  @override
  String get opros_5902 => '📊 Poll';
  @override
  String get vlozhenie_ef44 => 'Attachment';
  @override
  String get fayl_2d46 => 'File';
  @override
  String get zagruzkaFayla_f817 => 'Loading file...';
  @override
  String get ishodyaschiyZvonok_8381 => 'Outgoing call';
  @override
  String get razgovorNeSostoyalsya_67fb =>
      'The conversation did not take place';
  @override
  String get vhodyaschiyZvonok_5ce9 => 'Incoming call';
  @override
  String get otklonennyyZvonok_d499 => 'Rejected call';
  @override
  String get vyOtkloniliVyzov_8d1d => 'You rejected the call';
  @override
  String get propuschennyyZvonok_e98d => 'Missed call';
  @override
  String get vyPropustiliVyzov_f17a => 'You missed the call';
  @override
  String get vlozhenie_2474 => '📎 Attachment';
  @override
  String get tb_0e05 => 'TB';
  @override
  String get zapisGolosovogo_9c91 => 'Voice recording...';
  @override
  String get zapisVideo_dd2a => 'Video recording...';
  @override
  String get otpustiteDlyaOtpravki_ea7b => 'Release to send';
  @override
  String get emodzi_f822 => 'Emoji';
  @override
  String get panelEmodziVRazrabotke_b6ce => 'Emoji panel under development';
  @override
  String get napisatSoobschenie_62d4 => 'Write a message...';
  @override
  String get dobavitVlozhenie_769b => 'Add attachment';
  @override
  String get spisokZadach_1852 => 'List of tasks';
  @override
  String get opros_9f36 => 'Poll';
  @override
  String get zapisGolosovogoGs_db4e => 'Voice recording (VO)';
  @override
  String get zapisVideoVs_9676 => 'Video recording (VS)';
  @override
  String get uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3 =>
      '•Hold button to record\n• Press to switch mode';
  @override
  @override
  String get novyyChat_f775 => 'New Chat';
  @override
  @override
  String get imyaPolzovatelyaMin5Simvolov_1232 =>
      'Username (min. 5 characters)';
  @override
  @override
  String get vvedite5IliBoleeSimvolov_f983 => 'Enter 5 or more characters';
  @override
  @override
  String get polzovateliNeNaydeny_c01a => 'No users found';
  @override
  String get mnozhestvennyyVybor_9b60 => 'Multiple Choice';
  @override
  String get odinochnyyVybor_d920 => 'Single selection';
  @override
  String get netGolosov_17d0 => 'No votes';
  @override
  String get golos_6b94 => 'voice';
  @override
  String get golosa_bb8d => 'voices';
  @override
  String get golosov_7f51 => 'votes';
  @override
  String get nePoluchenIdFaylaOt_86c8 => 'File ID not received from server';
  @override
  String get faylZagruzhenIPrikreplen_dc24 => 'File uploaded and attached';
  @override
  String get neizvestnayaOshibkaZagruzki_68cb => 'Unknown download error';
  @override
  String get oshibkaZagruzkiFayla_86e5 => 'File download error';
  @override
  String get sohranitFaylKak_0f93 => 'Save file as';
  @override
  String get oshibkaSkachivaniyaFayla_34ac => 'File download error';
  @override
  String get bezNazvaniya_6584 => 'Untitled';
  @override
  String get bezVoprosa_d390 => 'No question';
  @override
  String get netDostupaKMikrofonu_a4ef => 'No microphone access';
  @override
  String get zapisVideoCherezPlaginCamera_b9dd =>
      '📹 Video recording via the camera plugin has started';
  @override
  String get kameraNeInitsializirovanaNaEtoy_21e0 =>
      '📹 The camera is not initialized on this platform.';
  @override
  String get kameraNeGotova_9f09 => 'Camera not ready';
  @override
  String get zapisVideosoobscheniyaNaEtoyPlatforme_a561 =>
      '📹 Video message recording is not directly available on this platform.';
  @override
  String get arecordOstanovlen_edf2 => '🎙️ arecord has been stopped';
  @override
  String get ffmpegOstanovlen_63a0 => '📹 ffmpeg stopped';
  @override
  String get zapisSlishkomKorotkaya_5cda => 'The entry is too short';
  @override
  String get oshibkaZapisiFaylPust_106b => 'Write error: file is empty';
  @override
  String get videosoobschenieOtpravlenoSimulyatsiya_fb29 =>
      'Video message sent (simulation)';
  @override
  String get zapisOtmenena_1609 => 'Registration canceled';
  @override
  String get otpravitGolosovoeSoobschenie_2481 => 'Send a voice message';
  @override
  String get imitatsiyaZapisiGolosovogoSoobscheniya_81e7 =>
      'Simulation of recording a voice message.';
  @override
  String get otpravit_6da0 => 'Send';
  @override
  String get sozdatToDo_8c92 => 'CREATE TO-DO';
  @override
  String get nazvanieSpiska_c3cc => 'List name';
  @override
  String get punkty_0481 => 'Items:';
  @override
  String get dobavitPunkt_930c => 'Add item';
  @override
  String get sozdat_b059 => 'Create';
  @override
  String get sozdatOpros_4b9e => 'CREATE A SURVEY';
  @override
  String get vopros_0911 => 'Question';
  @override
  String get variantyOtveta_ef4e => 'Answer options:';
  @override
  String get dobavitVariant_76be => 'Add an option';
  @override
  String get golosovoeSoobschenie_33d5 => 'Voice message';
  @override
  String get videosoobschenie_2951 => 'Video message';
  @override
  String get video_a095 => 'Video';
  @override
  String get neUdalosZagruzitIzobrazhenie_3fa0 => 'Failed to load image';
  @override
  String get muzyka_0660 => 'Music';
  @override
  String get netDannyh_dee9 => 'No data';
  @override
  String get istoriyaSoobscheniyPustaIliChat_2d07 =>
      'The message history is empty or the chat has not yet been saved locally';
  @override
  String get obschieMaterialy_11e4 => 'General materials';
  @override
  String get netMediafaylov_08d2 => 'No media files';
  @override
  String get zdesBudutOtobrazhatsyaObschieFoto_9bc7 =>
      'Shared photos and videos will be displayed here';
  @override
  String get netFaylov_e95e => 'No files';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c =>
      'Uploaded files will be displayed here';
  @override
  String get netGolosovyhSoobscheniy_2427 => 'No voice messages';
  @override
  String get zdesBudutOtobrazhatsyaGolosovyeI_0a73 =>
      'Voice and video messages will be displayed here';
  @override
  String get netSsylok_b0ec => 'No links';
  @override
  String get zdesBudutOtobrazhatsyaObschieSsylki_6b61 =>
      'General links will appear here';
  @override
  String get ssylkaSkopirovanaVBufer_c16e => 'Link copied to clipboard';
  @override
  String get netMuzyki_1ca3 => 'No music';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23 =>
      'Submitted tracks will be displayed here';
  @override
  String get udalennyyAkkaunt_ce47 => 'deleted account';
  @override
  String get opisanie_38ca => 'Description';
  @override
  String get mobilnyy_5ac7 => 'Mobile';
  @override
  String get bylANedavno_168d => 'was recently';
  @override
  String get minutu_5373 => 'minute';
  @override
  String get minuty_5bc9 => 'minutes';
  @override
  String get minut_b877 => 'minutes';
  @override
  String get nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a =>
      'Click to download new version';
  @override
  String get poiskLyudeyBotovGrupp_e84e => 'Search for people, bots, groups...';
  @override
  String get vveditePoiskovyyZapros_0b8c => 'Enter your search term';
  @override
  String get polzovateli_b8c4 => 'Users';
  @override
  String get moiLichnyeSoobscheniya_7d3b => 'My personal messages';
  @override
  String get sozdatNovyyChat_fd41 => 'Create a new chat';
  @override
  String get lichnyyChat_cbec => 'Personal chat';
  @override
  String get nachatObschenieSPolzovatelem_0578 =>
      'Start a conversation with a user';
  @override
  String get sozdatGruppu_459f => 'Create a group';
  @override
  String get gruppovoyChatDlyaObscheniyaS_01ba =>
      'Group chat to communicate with friends';
  @override
  String get sozdatKanal_9022 => 'Create a channel';
  @override
  String get kanalDlyaShirokoyAuditorii_9dba => 'Channel for a wide audience';
  @override
  String get redaktirovanie_1167 => 'Editing';
  @override
  String get vlevo_1af1 => 'Left';
  @override
  String get vpravo_c316 => 'Right';
  @override
  String get poGor_ff50 => 'Along the mountains';
  @override
  String get poVert_b4a9 => 'Vert.';
  @override
  String get vvediteNazvanieGruppy_0a69 => 'Enter group name';
  @override
  String get dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0 =>
      'A public group requires a nickname (@username)';
  @override
  String get gruppaSozdana_6b3b => 'Group created';
  @override
  String get oshibkaPriSozdaniiGruppy_794e => 'Error creating group';
  @override
  String get nazhmiteNaIkonkuChtobyVybrat_af03 =>
      'Click on the icon to select an avatar';
  @override
  String get nazvanieGruppy_9a39 => 'Group name';
  @override
  String get opisanieNeobyazatelno_7812 => 'Description (optional)';
  @override
  String get privatnayaGruppa_d20e => 'Private group';
  @override
  String get publichnayaGruppa_50f8 => 'Public group';
  @override
  String get vhodTolkoPoPriglasheniyu_97a1 => 'Entry by invitation only';
  @override
  String get lyuboyMozhetNaytiIVstupit_5e26 => 'Anyone can find and join';
  @override
  String get publichnayaSsylkanikneymMyGroup_6640 =>
      'Public link/nickname (@my_group)';
  @override
  String get vvediteNazvanieKanala_5536 => 'Enter channel name';
  @override
  String get dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06 =>
      'A public channel requires a link/nickname (@mychannel)';
  @override
  String get kanalSozdan_1522 => 'Channel created';
  @override
  String get oshibkaPriSozdaniiKanala_7d4b => 'Error creating channel';
  @override
  String get nazvanieKanala_c548 => 'Channel name';
  @override
  String get privatnyyKanal_3139 => 'Private channel';
  @override
  String get publichnyyKanal_0f7c => 'Public channel';
  @override
  String get podpiskaTolkoPoPriglasheniyu_99c3 =>
      'Subscription by invitation only';
  @override
  String get lyuboyMozhetNaytiIPodpisatsya_8579 =>
      'Anyone can find and subscribe';
  @override
  String get ssylkanikneymKanalaMychannel_79f6 =>
      'Channel link/nickname (@mychannel)';
  @override
  String get yazykInterfeysa_b78b => 'Interface language';
  @override
  String get dannyeUspeshnoSohraneny_2cc5 => 'Data saved successfully';
  @override
  String get oshibkaPriSohranenii_126f => 'Error while saving';
  @override
  String get lichnyeDannye_10a7 => 'PERSONAL DATA';
  @override
  String get nikneymUsername_8035 => 'Nickname (@username)';
  @override
  String get nikneymNelzyaIzmenit_0b99 => 'Nickname cannot be changed';
  @override
  String get oSebeBio_b730 => 'About me (Bio)';
  @override
  String get rasskazhiteNemnogoOSebe_3daa =>
      'Tell us a little about yourself...';
  @override
  String get nastroykiPrivatnostiSohraneny_447c => 'Privacy settings saved';
  @override
  String get privatnost_3098 => 'PRIVACY';
  @override
  String get kommunikatsii_e9b8 => 'COMMUNICATIONS';
  @override
  String get ktoMozhetPisat_3322 => 'Who can write';
  @override
  String get zapisGolosovyh_8073 => 'Voice recording';
  @override
  String get otpravkaFaylov_aaca => 'Sending files';
  @override
  String get priglashatVGruppy_3631 => 'Invite to groups';
  @override
  String get vidimostProfilya_448f => 'PROFILE VISIBILITY';
  @override
  String get ktoViditAvatar_b5d8 => 'Who sees the avatar';
  @override
  String get vremyaVSeti_be29 => 'Online time';
  @override
  String get vneshniyVid_5a0f => 'APPEARANCE';
  @override
  String get rezhimOformleniyaInterfeysa_b91d => 'Interface design mode';
  @override
  String get pokazyvatVizualnyeEffektyIPerehody_3fd7 =>
      'Show visual effects and transitions';
  @override
  String get razmerTeksta_3c4f => 'Text size';
  @override
  String get bezopasnost_fcbc => 'SECURITY';
  @override
  String get dvuhfaktornayaAutentifikatsiya_acdc => 'Two-factor authentication';
  @override
  String get zaschitaAkkaunta2fa_f1ab => '2FA account protection';
  @override
  String get vklyucheno_6b96 => 'Included';
  @override
  String get xaneoMobileAktivnoSeychas_3345 => 'Xaneo Mobile • Active now';
  @override
  String get zaschischennyyMessendzher_2f59 => 'Secure messenger';
  @override
  String get temnayaTema_6018 => 'Dark theme';
  @override
  String get vklyuchenaPoUmolchaniyu_7610 => 'Enabled (default)';
  @override
  String get setevoyFiltr_40c2 => 'Surge filter';
  @override
  String get vklyuchen_0994 => 'Enabled';
  @override
  String get spisokMuzyki_57d0 => 'Music list';
  @override
  String get trek_5049 => 'track';
  @override
  String get trekov_d3f4 => 'tracks';
  @override
  String get pozhaluystaZapolniteVoprosIKak_7ad5 =>
      'Please fill out the question and at least two answer options';
  @override
  String get sozdatOpros_8401 => 'Create a survey';
  @override
  String get sozdatSpisokZadach_4018 => 'CREATE TASK LIST';
  @override
  String get pozhaluystaZapolniteNazvanieIKak_3783 =>
      'Please fill in the title and at least one item';
  @override
  String get sozdatSpisokZadach_0416 => 'Create a task list';
  @override
  String get vhodyaschiyVideozvonok_14d4 => 'Incoming video call';
  @override
  String get prinyat_5dc5 => 'Accept';
  @override
  String get netObschihFaylov_bf77 => 'No shared files';
  @override
  String get neUdalosRazarhivirovatChatNa_b6f6 =>
      'Failed to unarchive chat on server';
  @override
  String get poiskVArhive_c5d8 => 'Archive search...';
  @override
  String get poprobuyteIzmenitZapros_52ea => 'Try changing your request';
  @override
  String get zdesBudutNahoditsyaVashiArhivirovannye_7359 =>
      'Your archived chats will go here';
  @override
  String get vernut_54aa => 'Return';
  @override
  String get zashifrovannoeSoobschenie_c9ab => 'Encrypted message';
  @override
  String get soobschenieNahoditsyaVysheVIstorii_dc90 =>
      'The message is higher in the story.';
  @override
  String get otpravlyaetFoto_67c1 => 'sends a photo...';
  @override
  String get otpravlyaetVideo_ce80 => 'sends video...';
  @override
  String get otpravlyaetFayl_5e88 => 'sends file...';
  @override
  String get ktoTo_8405 => 'Someone';
  @override
  String get trebuetsyaRazreshenieNaKameruI_06fa =>
      'Camera and microphone permission required';
  @override
  String get kameraNeNaydena_208d => 'Camera not found';
  @override
  String get zapisVideoOtmenena_1db7 => 'Video recording canceled';
  @override
  String get slishkomKorotkoeVideosoobschenie_4676 => 'Video message too short';
  @override
  String get pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35 =>
      'Please wait until the files are downloaded';
  @override
  String get audiozvonok_dcf6 => 'Audio call';
  @override
  String get otpravitFotoVideoAudioIli_37e9 =>
      'Send photos, videos, audio or other files';
  @override
  String get provedenieGolosovaniyaVChate_a629 => 'Voting in chat';
  @override
  String get sozdatToDoSpisok_cb50 => 'Create a To-Do list';
  @override
  String get spisokZadachSOtmetkamiVypolneniya_c778 =>
      'List of tasks with completion marks';
  @override
  String get trebuetsyaRazreshenieNaZapisAudio_8175 =>
      'Requires permission to record audio';
  @override
  String get slishkomKorotkoeSoobschenie_c2ee => 'Message too short';
  @override
  String get uderzhivayteKnopkuDlyaZapisi_a762 => 'Hold button to record';
  @override
  String get udalennyy_40c6 => 'remote';
  @override
  String get udalennyy_c2c8 => 'remote';
  @override
  String get neobhodimyRazresheniyaNaMikrofonI_224b =>
      'Microphone and camera permissions required to make a call';
  @override
  String get bylATolkoChto_9ac0 => 'was just there';
  @override
  String get chatNeNayden_ba4f => 'Chat not found';
  @override
  String get napishitePervoeSoobschenie_8260 => 'Write your first message';
  @override
  String get prisoedinitsyaKKanalu_f863 => 'Join the channel';
  @override
  String get vyPodpisany_5fb9 => 'You are subscribed';
  @override
  String get otpisatsya_ee2d => 'Unsubscribe';
  @override
  String get vyUspeshnoPodpisalisNaKanal_9c99 =>
      'You have successfully subscribed to the channel!';
  @override
  String get vyUspeshnoVstupiliVGruppu_61a1 =>
      'You have successfully joined the group!';
  @override
  String get neUdalosPrisoedinitsyaPoprobuyteEsche_bce5 =>
      'Failed to join. Try again.';
  @override
  String get vyrezat_a195 => 'Cut';
  @override
  String get kopirovat_112b => 'Copy';
  @override
  String get vstavit_dcc4 => 'Paste';
  @override
  String get vybratVse_4d09 => 'Select all';
  @override
  String get zhirnyy_7774 => 'Bold';
  @override
  String get kursiv_e0b1 => 'Italic';
  @override
  String get kod_3f34 => 'Code';
  @override
  String get zacherknut_02fc => 'Cross out';
  @override
  String get soobschenie_8b9b => 'Message...';
  @override
  String get smahniteDlyaOtmeny_e976 => 'Swipe to cancel';
  @override
  String get poisk_bfc9 => 'Search';
  @override
  String get udalitChat_4b2b => 'Delete chat';
  @override
  String get udalitKanal_482f => 'Delete channel';
  @override
  String get pozhalovatsya_a7d9 => 'Complain';
  @override
  String get redaktirovatGruppu_e40a => 'Edit group';
  @override
  String get udalitGruppu_dff8 => 'Delete group';
  @override
  String get poiskSoobscheniyVremennoNedostupenV_4443 =>
      'Message search is temporarily unavailable in the mobile version';
  @override
  String get zhalobaOtpravlenaModeratoram_4547 =>
      'The complaint has been sent to moderators';
  @override
  String get redaktirovanieGruppyVremennoNedostupnoV_05d0 =>
      'Group editing is temporarily unavailable in the mobile version';
  @override
  String get vyUverenyChtoHotiteOchistit_7c3a =>
      'Are you sure you want to clear your message history in this chat? This action cannot be undone.';
  @override
  String get ochistit_7074 => 'Clear';
  @override
  String get udalit_ed2b => 'Delete';
  @override
  String get vyyti_0f05 => 'Log out';
  @override
  String get oshibkaVosproizvedeniya_ac8a => 'Playback error';
  @override
  String get novoeZashifrovannoeSoobschenie_4d30 => 'New encrypted message';
  @override
  String get poiskChatov_779c => 'Search chats...';
  @override
  String get obnovlenie_53e2 => 'Update...';
  @override
  String get soedinenie_5a58 => 'Connection...';
  @override
  String get lichnye_4cb3 => 'Personal';
  @override
  String get neUdalosArhivirovatChatNa_36aa =>
      'Failed to archive chat on server';
  @override
  String get oshibkaZagruzkiChatov_902f => 'Error loading chats';
  @override
  String get povtorit_b914 => 'Repeat';
  @override
  String get netChatov_85e3 => 'No chats';
  @override
  String get nachniteNovyyRazgovor_8290 => 'Start a new conversation';
  @override
  String get neUdalosZagruzitAkkaunty_8570 => 'Failed to load accounts';
  @override
  String get vyberiteAkkaunt_79e7 => 'Select an account';
  @override
  String get bystryyVhodNaEtomUstroystve_3f30 => 'Quick login on this device';
  @override
  String get voytiSParolem_9277 => 'Login with password';
  @override
  String get sozdatXaneoId_4033 => 'Create Xaneo ID';
  @override
  String get netSohranennyhAkkauntov_b669 => 'No saved accounts';
  @override
  String get tolkoChto_4493 => 'Just now';
  @override
  String get emailNedostupen_fc3e => 'Email not available';
  @override
  String get nevernyyKod_50f9 => 'Invalid code';
  @override
  String get oshibkaProverkiKoda_9018 => 'Code verification error';
  @override
  String get neobhodimoRazreshenieNaDostupK_5f5c =>
      'Permission required to access photos';
  @override
  String get oVyboreEmail_2609 => 'About choosing Email';
  @override
  String get podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0 =>
      'All email domains are supported except';
  @override
  String get zapreschennyh_1f49 => 'prohibited';
  @override
  String get sozdatAkkaunt_19ed => 'Create an account';
  @override
  String get naprimerIvan_d7cb => 'For example, Ivan';
  @override
  String get zadayteParol_53d2 => 'Set a password';
  @override
  String get minimum8Simvolov_4ccd => 'Minimum 8 characters';
  @override
  String get unikalnoeImyaDlyaVashegoProfilya_a0ea =>
      'A unique name for your profile';
  @override
  String get vashEmail_879d => 'Your Email';
  @override
  String get dlyaSvyaziIVosstanovleniyaDostupa_c770 =>
      'For communication and access restoration';
  @override
  String get emailAdres_9130 => 'Email address';
  @override
  String get vvediteParolEscheRaz_7383 => 'Enter your password again';
  @override
  String get parolEscheRaz_6daf => 'Password again';
  @override
  String get paroliNeSovpadayut_d82f => 'Passwords don\'t match';
  @override
  String get ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed =>
      'Please indicate your real date of birth';
  @override
  String get ddmmgggg_3524 => 'DD.MM.YYYY';
  @override
  String get sdelayteProfilUznavaemym_f2c5 => 'Make your profile recognizable';
  @override
  String get profilGotov_b57d => 'Profile ready';
  @override
  String get ostalosVsegoParaShagov_37e3 => 'Just a couple of steps left';
  @override
  String get yaPrinimayuPolzovatelskoeSoglashenie_c431 =>
      'I accept the User Agreement';
  @override
  String get yaDayuSoglasieNaObrabotku_0d03 =>
      'I consent to the processing of personal data';
  @override
  String get sVozvrascheniem_77ee => 'Welcome back';
  @override
  String get zagruzka_43e4 => 'Loading...';
  @override
  String get vyberiteAkkauntDlyaVhoda_d3a6 => 'Select an account to log in';
  @override
  String get vvediteVashNikneym_51a6 => 'Enter your nickname';
  @override
  String get voytiVDrugoyAkkaunt_d10f => 'Login to another account';
  @override
  String get nedavnieAkkaunty_953d => 'Recent Accounts';
  @override
  String get dobroPozhalovatVXaneo_66d0 => 'Welcome to Xaneo';
  @override
  String get xaneoTeperIVMobilnom_e918 =>
      'Xaneo is now available in the mobile app! This messenger has never been so convenient and fast.';
  @override
  String get mneUzheInteresno_5365 => 'I\'m already interested';
  @override
  String get vseVashiDannyePodZaschitoy_b7d9 => 'All your data is protected';
  @override
  String get vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e =>
      'All messages are protected with end-to-end encryption. At no stage does Xaneo know their contents.';
  @override
  String get prodolzhit_e9c3 => 'Continue';
  @override
  String get lokalnyeDataTsentry_f089 => 'Local data centers';
  @override
  String get vashiDannyeNikogdaNePokidayut_f871 =>
      'Your data never leaves the country and is stored in secure data centers.';
  @override
  String get kodOtpravlenPovtorno_e109 => 'Code resent';
  @override
  String get dvuhfaktornayanautentifikatsiya_bacc =>
      'Two-factor\nauthentication';
  @override
  String get naVashEmailOtpravlen6_b457 =>
      'A 6-digit code has been sent to your email';
  @override
  String get podtverdit_e260 => 'Confirm';
  @override
  String get nePoluchiliKodOtpravitPovtorno_c1d2 =>
      'Didn\'t receive the code? Resend';
  @override
  String get imyaNikneymOSebe_7a8d => 'Name, nickname, about yourself';
  @override
  String get zvonkiSoobscheniyaVidimostProfilya_f905 =>
      'Calls, messages, profile visibility';
  @override
  String get parolSessii2fa_de9e => 'Password, sessions, 2FA';
  @override
  String get prilozhenie_38aa => 'APPENDIX';
  @override
  String get temaRazmerTekstaAnimatsii_f0a8 => 'Theme, text size, animations';
  @override
  String get pushUvedomleniyaZvuki_9cc2 => 'Push notifications, sounds';
  @override
  String get oPrilozhenii_77b2 => 'ABOUT THE APPLICATION';

  @override
  String get redaktirovatProfil_56ad => 'Edit profile';
  @override
  String get dobavitKontakt_2903 => 'ADD CONTACT';
  @override
  String get nikneymPolzovatelyaUsername_a6ff => 'User nickname (@username)';
  @override
  String get otobrazhaemoeImyaNeobyazatelno_340a => 'Display name (optional)';
  @override
  String get neUdalosNaytiIliDobavit_649f => 'Could not find or add user';
  @override
  String get ya_feef => 'I';
  @override
  String get poiskKontaktov_9a71 => 'Search for contacts...';
  @override
  String get spisokKontaktovPust_58c6 => 'Contact list is empty';
  @override
  String get kontaktyNeNaydeny_1b08 => 'Contacts not found';

  @override
  String get messages => 'Messages';
  @override
  String get messageAnimations => 'Message Animations';
  @override
  String get messageAnimationsDesc => 'Show animations on send and receive';
  @override
  String get archivedChats => 'Archived Chats';
  @override
  String get archiveManagement => 'Archive Management';
  @override
  String get clearHistory => 'Clear History';
  @override
  String get clearHistoryDesc => 'Delete all messages locally';
  @override
  String get call => 'Call';
  @override
  String get sendMessage => 'Send Message';
  @override
  String get deleteContact => 'Delete Contact';
  @override
  String get activeSessions => 'Active Sessions';
  @override
  String get thisDevice => 'This Device';
  @override
  String get xaneoPcActiveNow => 'Xaneo PC • Active Now';
  @override
  String get activeNow => 'Active';
  @override
  String get twoFactorAuth => 'Two-Factor Authentication';
  @override
  String get twoFactorAuthDesc => 'Protect account with one-time password';
  @override
  String get dangerZone => 'Danger Zone';
  @override
  String get deleteAccount => 'Delete Account';
  @override
  String get irreversibleAction => 'Irreversible action';
  @override
  String get theme => 'Theme';
  @override
  String get darkThemeDesc => 'Switch between dark and light mode';
  @override
  String get fontSizeText => 'Font Size';
  @override
  String get showPopups => 'Show popup notifications';
  @override
  String get sound => 'Sound';
  @override
  String get soundDesc => 'Play sound on new message';
  @override
  String get mainSettings => 'Main Settings';
  @override
  String get energySavingMode => 'Energy Saving Mode';
  @override
  String get energySavingModeDesc => 'Optimizes app performance to save power';
  @override
  String get autoSleep => 'Auto Sleep Mode';
  @override
  String get autoSleepDesc => 'Puts app to sleep when inactive';
  @override
  String get animations => 'Animations';
  @override
  String get reducedMotion => 'Reduced Motion';
  @override
  String get reducedMotionDesc => 'Reduces interface animations';
  @override
  String get comingSoon => 'Coming Soon';
  @override
  String get darkTheme => 'Dark Theme';
  @override
  String get version => 'Version';

  @override
  String get updateAvailable => 'Update available';
  @override
  String get clickToViewChanges => 'Click to view changes';
  @override
  String get newVersionAvailable => 'A new version of the app is available';
  @override
  String get newVersionAvailableTitle => 'New version available';
  @override
  String get youHaveLatestVersion => 'You have the latest version installed';
  @override
  String get whatsNew => 'What\'s new';
  @override
  String get officialReleaseNotes =>
      'Official release notes are available on GitHub';
  @override
  String get preparingDownload => 'Preparing download...';
  @override
  String get installationStarted => 'Installation started...';
  @override
  String get whoSeesAvatar => 'Who sees my avatar';
  @override
  String get whoSeesBirthday => 'Who sees my birthday';
  @override
  String get whoSeesOnlineTime => 'Who sees my last seen';

  @override
  String get downloadVersion => 'Download';
  @override
  String get downloadSource => 'Download source';
  @override
  String get directInAppInstall => 'Direct in-app install';
  @override
  String get autoDownloadAndRun => 'Automatic download and launch';
  @override
  String get githubReleasePage => 'GitHub release page';
  @override
  String get skip => 'Skip';
  @override
  String get updateAction => 'Update';
  @override
  String get installAction => 'Installing...';
  @override
  String get isTyping => 'typing...';
  @override
  String get isRecordingVoice => 'recording voice...';
  @override
  String get areTyping => 'typing...';

  @override
  String membersCount(int count) =>
      count == 1 ? '$count member' : '$count members';
  @override
  String subscribersCount(int count) =>
      count == 1 ? '$count subscriber' : '$count subscribers';

  @override
  String get group => 'Group';
  @override
  String get channel => 'Channel';

  @override
  String get profile => 'Profile';
  @override
  String get userHidInfo => 'User has hidden their info';
  @override
  String get leaveGroup => 'Leave group';
  @override
  String get joinGroup => 'Join group';
  @override
  String get unsubscribeChannel => 'Unsubscribe from channel';
  @override
  String get subscribeChannel => 'Subscribe to channel';
  @override
  String get deleteChat => 'Delete chat';
  @override
  String get pinChat => 'Pin';
  @override
  String get unpinChat => 'Unpin';
  @override
  String get muteNotifications => 'Mute notifications';
  @override
  String get unmuteNotifications => 'Unmute notifications';
  @override
  String get backToChats => 'Back to chats';
  @override
  String get globalSearch => 'Global search';
  @override
  String get chatSettings => 'Chat settings';
  @override
  String get emoji => 'Emoji';
  @override
  String get attachFile => 'Attach file';
  @override
  String get startCall => 'Start call';
  @override
  String get audioCall => 'Audio call';
  @override
  String get audioCallDesc => 'Call via audio';
  @override
  String get videoCall => 'Video call';

  @override
  String get copied => 'Copied';

  @override
  String get copy => 'Copy';

  @override
  String get voiceRecordTitle => 'Voice recording (Voice)';
  @override
  String get videoRecordTitle => 'Video recording (Video)';
  @override
  String get holdToRecordHint => 'Hold button to record\nTap to switch mode';
  @override
  String get addAttachment => 'Add attachment';
  @override
  String get emojiPanelInDev => 'Emoji panel in development';
  @override
  String get recordingVoice => 'Recording voice...';
  @override
  String get recordingVideo => 'Recording video...';
  @override
  String get releaseToSend => 'Release to send';
  @override
  String get videoCallDesc => 'Call with camera on';

  @override
  String get typeMessage => 'Write a message...';
  @override
  String get file => 'File';
  @override
  String get todoList => 'Task list';
  @override
  String get poll => 'Poll';

  @override
  String get today => 'Today';
  @override
  String get yesterday => 'Yesterday';
  @override
  String get monthJan => 'January';
  @override
  String get monthFeb => 'February';
  @override
  String get monthMar => 'March';
  @override
  String get monthApr => 'April';
  @override
  String get monthMay => 'May';
  @override
  String get monthJun => 'June';
  @override
  String get monthJul => 'July';
  @override
  String get monthAug => 'August';
  @override
  String get monthSep => 'September';
  @override
  String get monthOct => 'October';
  @override
  String get monthNov => 'November';
  @override
  String get monthDec => 'December';
  @override
  String get createTodo => 'CREATE TO-DO';
  @override
  String get listName => 'List title';
  @override
  String get todoItems => 'Items';
  @override
  String get addTodoItem => '+ Add item';
  @override
  String get itemHintPrefix => 'Item';
  @override
  String get createPoll => 'CREATE POLL';
  @override
  String get pollQuestion => 'Question';
  @override
  String get pollOptions => 'Options';
  @override
  String get addPollOption => '+ Add option';
  @override
  String get optionHintPrefix => 'Option';
  @override
  String get allowMultipleAnswers => 'Allow multiple choices';
  @override
  String get accountsTitle => 'ACCOUNTS';
  @override
  String get addAccount => 'Add account';
  @override
  String get accountLimitNotice => 'Account limit: 5';

  @override
  String get singleChoice => 'Single choice';

  @override
  String get media => 'Media';
  @override
  String get files => 'Files';
  @override
  String get voice => 'Voice';
  @override
  String get links => 'Links';

  @override
  String get bio => 'Bio';
  @override
  String get username => 'Username';
  @override
  String get birthday => 'Date of birth';
  @override
  String get noSharedMedia => 'No shared media';
  @override
  String get noSharedFiles => 'No shared files';
  @override
  String get noSharedVoice => 'No voice messages';
  @override
  String get noSharedLinks => 'No shared links';

  @override
  String get savedMessagesDesc =>
      'Your personal cloud storage for notes, files, and messages';
  @override
  String get music => 'Music';
  @override
  String get noSharedMusic => 'No music tracks';
  @override
  String get secureDesktopCommunicator => 'secure desktop communicator';
  @override
  String get noMessagesTitle => 'No messages yet';
  @override
  String get noMessagesSubtitle =>
      'Send a message to start the conversation on Xaneo Connect!';

  @override
  String get qrScanTitle => 'Device Authorization';
  @override
  String get qrScanSubtitle => 'Point your camera at the QR code on the Xaneo web or PC client screen';
  @override
  String get qrScanSuccessTitle => 'Device Authorized';
  @override
  String get qrScanSuccessDesc => 'Authorization successful. End-to-end encryption (E2EE) keys transferred to the new device.';
  @override
  String get qrScanInputHint => 'Paste token or payload...';
  @override
  String get qrScanPasteTooltip => 'Paste from clipboard';
  @override
  String get qrScanConfirmButton => 'Confirm Authorization';
  @override
  String get qrScanProcessing => 'Authorizing device...';
}
