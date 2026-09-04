import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Xaneo PC';

  @override
  String get welcomeTitle => 'Bienvenue sur Xaneo';

  @override
  String get welcomeDescription =>
      'Xaneo est maintenant sur votre ordinateur ! Performances et confort.';

  @override
  String get getStartedButton => 'Commencer';

  @override
  String get privacyTitle => 'Toutes vos données sont en sécurité';

  @override
  String get privacyDescription =>
      'Tous les messages sur Xaneo sont protégés par un chiffrement de bout en bout.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get dataStorageTitle =>
      'Tous les centres de données Xaneo sont situés en Russie';

  @override
  String get dataStorageDescription =>
      'Vos données ne quittent jamais le pays et sont stockées dans des centres sécurisés.';

  @override
  String get finishButton => 'Terminer';

  @override
  String get setupCompleted => 'Configuration terminée !';

  @override
  String get loginFormTitle => 'Connexion';

  @override
  String get loginFieldHint => 'Identifiant';

  @override
  String get passwordFieldHint => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get noAccount => 'Pas de compte ?';

  @override
  String get registerButton => 'S\'inscrire';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get loggingIn => 'Connexion en cours...';

  @override
  String welcomeUser(String username) => 'Bienvenue, $username !';

  @override
  String get invalidCredentials =>
      'Identifiants invalides. Veuillez vérifier votre nom d\'utilisateur et votre mot de passe.';

  @override
  String get serverError => 'Erreur serveur. Veuillez réessayer plus tard.';

  @override
  String get connectionError =>
      'Erreur de connexion. Vérifiez votre connexion Internet.';

  @override
  String get settings => 'Paramètres';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDescription =>
      'Activer ou désactiver les notifications';

  @override
  String get darkThemeDescription => 'Activer ou désactiver le thème sombre';

  @override
  String fontSize(int size) => 'Taille de la police : $size';

  @override
  String get language => 'Langue';

  @override
  String get languageDescription => 'Choisir la langue de l\'interface';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get appVersion => 'Version de l\'application';

  @override
  String get registerTitle => 'Inscription';

  @override
  String get registerStep0Title => 'Comment vous appelez-vous ?';

  @override
  String get registerStep0Subtitle => 'Entrez votre vrai nom';

  @override
  String get registerStep1Title => 'Quand êtes-vous né ?';

  @override
  String get registerStep1Subtitle => 'Vous devez avoir au moins 14 ans';

  @override
  String get registerStep2Title => 'Choisissez un pseudo';

  @override
  String get registerStep2Subtitle => 'Le pseudo doit être unique';

  @override
  String get registerStep3Title => 'Votre e-mail';

  @override
  String get registerStep3Subtitle =>
      'Nous vous enverrons un code de vérification';

  @override
  String get registerStep4Title => 'Créer un mot de passe';

  @override
  String get registerStep4Subtitle => 'Créez un mot de passe solide';

  @override
  String get registerStep5Title => 'Ajouter une photo';

  @override
  String get registerStep5Subtitle => 'C\'est facultatif, mais sympa';

  @override
  String get registerStep6Title => 'Dernière étape';

  @override
  String get registerStep6Subtitle => 'Acceptez les conditions d\'utilisation';

  @override
  String get yourName => 'Votre nom';

  @override
  String get birthDate => 'Date de naissance';

  @override
  String get nickname => 'Pseudo';

  @override
  String get checkingNickname => 'Vérification de la disponibilité...';

  @override
  String get nicknameAvailable => 'Pseudo disponible';

  @override
  String get nicknameTaken => 'Pseudo déjà pris';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get addPhoto => 'Appuyez pour ajouter une photo';

  @override
  String get removePhoto => 'Supprimer la photo';

  @override
  String get acceptTerms => 'J\'accepte les conditions d\'utilisation';

  @override
  String get acceptDataProcessing =>
      'J\'accepte le traitement des données personnelles';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get finish => 'Terminer';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get registrationSuccess => 'Inscription réussie !';

  @override
  String get registrationError => 'Erreur d\'inscription';

  @override
  String get enterVerificationCode => 'Entrez le code de vérification';

  @override
  String get invalidVerificationCode => 'Code de vérification invalide';

  @override
  String get codeSent => 'Code de vérification envoyé par e-mail';

  @override
  String get sendCodeError => 'Erreur lors de l\'envoi du code';

  @override
  String get confirmEmail => 'Confirmer l\'e-mail';

  @override
  String codeSentToEmail(String email) =>
      'Nous avons envoyé un code de vérification à\n$email';

  @override
  String get verify => 'Vérifier';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String resendIn(int count) => 'Renvoyer dans $count sec';

  @override
  String get acceptTermsRequired =>
      'Vous devez accepter les conditions d\'utilisation et le traitement des données';

  @override
  String get about => 'À propos';

  @override
  String get aboutDescription =>
      'Une application moderne pour la gestion et le contrôle.';

  @override
  String get close => 'Fermer';

  @override
  String get technicalInfo => 'Informations techniques';

  @override
  String get platform => 'Plate-forme';

  @override
  String get architecture => 'Architecture processeur';

  @override
  String get flutter => 'Flutter';

  @override
  String get viewOnGitHub => 'Voir sur GitHub';

  @override
  String get chats => 'Discussions';
  @override
  String get search => 'Recherche';
  @override
  String get searchPlaceholder => 'Rechercher des messages...';
  @override
  String get savedMessages => 'Messages enregistrés';
  @override
  String get online => 'en ligne';
  @override
  String get offline => 'hors ligne';
  @override
  String get lastSeenRecently => 'vu récemment';
  @override
  String get musicPlaylist => 'Liste de lecture';
  @override
  String get reply => 'Répondre';
  @override
  String get edit => 'Modifier';
  @override
  String get pin => 'Épingler';
  @override
  String get unpin => 'Désépingler';
  @override
  String get delete => 'Supprimer';
  @override
  String get forward => 'Transférer';
  @override
  String get members => 'Membres';
  @override
  String get noMessages => 'Pas encore de messages';

  @override
  String get joinedChat => 'a rejoint la discussion';
  @override
  String get leftChat => 'a quitté la discussion';
  @override
  String get subscribedChannel => 's\'est abonné au canal';
  @override
  String get unsubscribedChannel => 's\'est désabonné du canal';
  @override
  String get invited => 'a invité';
  @override
  String get systemMessage => 'Message système';
  @override
  String get selectChatToStart => 'Sélectionnez une discussion pour commencer';
  @override
  String get toArchive => 'Archiver';
  @override
  String get unarchive => 'Désarchiver';
  @override
  String get archive => 'Archives';
  @override
  String get archiveEmpty => 'L\'archive est vide';
  @override
  String get voiceMessage => 'Message vocal';
  @override
  String get videoMessage => 'Message vidéo';

  @override
  String get personalData => 'Données personnelles';
  @override
  String get personalDataDesc => 'Nom, pseudo, photo de profil';
  @override
  String get privacyDesc => 'Qui peut vous contacter et voir votre profil';
  @override
  String get chatsSettings => 'Paramètres de discussion';
  @override
  String get chatsSettingsDesc => 'Notifications, thèmes, historique';
  @override
  String get contacts => 'Contacts';
  @override
  String get contactsDesc => 'Vos contacts enregistrés';
  @override
  String get security => 'Sécurité';
  @override
  String get securityDesc => 'Sessions, mot de passe, authentification';
  @override
  String get appearance => 'Apparence';
  @override
  String get appearanceDesc => 'Thème, police, échelle';
  @override
  String get energySaving => 'Économie d\'énergie';
  @override
  String get energySavingDesc => 'Animations et performances';

  @override
  String get account => 'COMPTE';
  @override
  String get interface => 'INTERFACE';
  @override
  String get logout => 'Se déconnecter';

  @override
  String get basicInfo => 'Informations de base';
  @override
  String get nicknameCannotBeChanged => 'Le pseudo ne peut pas être modifié';
  @override
  String get aboutMe => 'À propos de moi';
  @override
  String get aboutMeHint => 'Parlez de vous...';
  @override
  String get save => 'Enregistrer';
  @override
  String get saving => 'Enregistrement...';
  @override
  String get communications => 'Communications';
  @override
  String get whoCanMessage => 'Qui peut envoyer des messages';
  @override
  String get whoCanCall => 'Qui peut appeler';
  @override
  String get whoCanRecordVoice => 'Qui peut enregistrer des vocaux';
  @override
  String get whoCanSendFiles => 'Qui peut envoyer des fichiers';
  @override
  String get whoCanInvite => 'Qui peut m\'inviter dans des groupes';
  @override
  String get profileVisibility => 'Visibilité du profil';
  @override
  String get whoSeesNickname => 'Qui voit mon pseudo';
  @override
  String get everyone => 'Tout le monde';
  @override
  String get contactsOnly => 'Contacts uniquement';
  @override
  String get nobody => 'Personne';
  @override
  String get addContact => 'Ajouter';
  @override
  String get addContactTitle => 'Ajouter un contact';
  @override
  String get userNicknameHint => 'Pseudo de l\'utilisateur';
  @override
  String get displayNameOptional => 'Nom d\'affichage (optionnel)';
  @override
  String get noContactsYet => 'Vous n\'avez pas encore de contacts enregistrés';
  @override
  String get appInfo => 'Informations sur l\'application';
  @override
  String get checkUpdates => 'Vérifier les mises à jour';
  @override
  String get checkingUpdates => 'Vérification des mises à jour...';
  @override
  String get cancel => 'Annuler';
  @override
  String get obnovlenie_7e32 => 'MISE À JOUR';
  @override
  String get obnovleniePrilozheniya_b6c3 => 'MISE À JOUR DE L\'APPLICATION';
  @override
  String get podgotovkaKZagruzke_a5c7 => 'Préparation du téléchargement...';
  @override
  String get ustanovkaZapuschena_d378 => 'L\'installation a commencé !';
  @override
  String get dostupnaNovayaVersiyaPrilozheniya_eeae =>
      'Une nouvelle version de l\'application est disponible';
  @override
  String get chtoNovogo_74e2 => 'QUOI DE NEUF';
  @override
  String get ofitsialnoeOpisanieRelizaDostupnoNa_3ea3 =>
      'La description officielle de la version est disponible sur la page GitHub.';
  @override
  String get istochnikZagruzki_0e6e => 'TÉLÉCHARGER LA SOURCE';
  @override
  String get pryamayaUstanovkaVPrilozhenii_16f5 =>
      'Installation directe dans l\'application';
  @override
  String get avtomaticheskoeSkachivanieIZapusk_9a3f =>
      'Téléchargement et lancement automatiques';
  @override
  String get stranitsaRelizaNaGithub_1531 => 'Page de publication sur GitHub';
  @override
  String get propustit_03ee => 'Sauter';
  @override
  String get ustanovka_516d => 'Mise en place...';
  @override
  String get obnovit_dbe5 => 'Mise à jour';
  @override
  String get lichnyeDannye_be85 => 'Informations personnelles';
  @override
  String get imyaNikneymFotoProfilya_28ac => 'Nom, pseudo, photo de profil';
  @override
  String get privatnost_0899 => 'Confidentialité';
  @override
  String get ktoMozhetPisatZvonitVidet_1789 =>
      'Qui peut écrire, appeler, voir le profil';
  @override
  String get nastroykiChatov_7ca8 => 'Paramètres de discussion';
  @override
  String get uvedomleniyaTemyIstoriya_51da =>
      'Notifications, sujets, historique';
  @override
  String get kontakty_7576 => 'Contacts';
  @override
  String get vashiSohranennyeKontakty_a641 => 'Vos contacts enregistrés';
  @override
  String get bezopasnost_3677 => 'Sécurité';
  @override
  String get sessiiParolAutentifikatsiya_73f5 =>
      'Sessions, mot de passe, authentification';
  @override
  String get vneshniyVid_6873 => 'Apparence';
  @override
  String get temaShriftMasshtab_d8c9 => 'Thème, police, échelle';
  @override
  String get yazyk_0577 => 'Langue';
  @override
  String get yazykInterfeysaKlienta_2ad3 => 'Langue de l\'interface client';
  @override
  String get uvedomleniya_d2ed => 'Notifications';
  @override
  String get zvukiBannery_1b60 => 'Sons, bannières';
  @override
  String get energosberezhenie_0b19 => 'Économie d\'énergie';
  @override
  String get animatsiiIProizvoditelnost_fba8 => 'Animations et performances';
  @override
  String get oPrilozhenii_322e => 'À propos de la candidature';
  @override
  String get versiyaProverkaObnovleniySsylki_6efc =>
      'Version, vérifier les mises à jour, les liens';
  @override
  String get nastroyki_b01b => 'PARAMÈTRES';
  @override
  String get nastroyki_c919 => 'Paramètres';
  @override
  String get proverkaObnovleniy_f3e0 => 'Vérification des mises à jour...';
  @override
  String get neUdalosZagruzitNastroyki_f753 =>
      'Échec du chargement des paramètres';
  @override
  String get oshibkaSohraneniya_0387 => 'Enregistrer l\'erreur';
  @override
  String get dannyeSohraneny_fd62 => 'Données enregistrées';
  @override
  String get gost_9618 => 'Invité';
  @override
  String get akkaunt_38ac => 'COMPTE';
  @override
  String get interfeys_49be => 'INTERFACE';
  @override
  String get vyytiIzAkkaunta_6d41 => 'Déconnectez-vous de votre compte';
  @override
  String get informatsiyaOPrilozhenii_00c4 => 'Informations sur la candidature';

  @override
  String get proverka_13bc => 'Vérification...';
  @override
  String get proveritObnovleniya_ab45 => 'Vérifier les mises à jour';
  @override
  String get osnovnayaInformatsiya_6fec => 'Informations de base';
  @override
  String get imya_d38d => 'Nom';
  @override
  String get vvediteVasheImya_751e => 'Entrez votre nom';
  @override
  @override
  String get nikneym_3fea => 'Nom d' 'utilisateur';
  @override
  String get nikneymNelzyaIzmenitVPrilozhenii_75d0 =>
      'Le pseudo ne peut pas être modifié dans l\'application';
  @override
  String get oSebe_0b3b => 'À propos de moi';
  @override
  String get rasskazhiteOSebe_1c37 => 'Parlez-nous de vous...';
  @override
  String get sohranenie_c15f => 'Sauvegarde...';
  @override
  String get sohranit_74ea => 'Enregistrer';
  @override
  @override
  String get vse_984b => 'Tout';
  @override
  String get tolkoKontakty_a559 => 'Contacts uniquement';
  @override
  String get nikto_ba19 => 'Personne';
  @override
  String get kommunikatsii_1242 => 'Communications';
  @override
  String get ktoMozhetPisatSoobscheniya_4645 => 'Qui peut écrire des messages';
  @override
  String get ktoMozhetZvonit_c427 => 'Qui peut appeler';
  @override
  String get ktoMozhetZapisyvatGolosovye_c69a =>
      'Qui peut enregistrer des voix';
  @override
  String get ktoMozhetOtpravlyatFayly_2e40 => 'Qui peut envoyer des fichiers';
  @override
  String get ktoMozhetPriglashatVGruppy_cdc0 =>
      'Qui peut inviter à des groupes';
  @override
  String get vidimostProfilya_34bf => 'Visibilité du profil';
  @override
  String get ktoViditMoyNikneym_54b8 => 'Qui voit mon pseudo';
  @override
  String get ktoViditMoyAvatar_e9f6 => 'Qui voit mon avatar';
  @override
  String get ktoViditMoyDenRozhdeniya_ccc7 => 'Qui voit mon anniversaire';
  @override
  String get ktoViditVremyaMoeyAktivnosti_4349 =>
      'Qui voit mon temps d\'activité';
  @override
  String get neUdalosZagruzitKontakty_02a3 =>
      'Échec du chargement des contacts';
  @override
  String get dobavitKontakt_4278 => 'Ajouter un contact';
  @override
  String get nikneymPolzovatelya_5610 => 'Pseudonyme de l\'utilisateur';
  @override
  String get otobrazhaemoeImyaOptsionalno_bbd1 =>
      'Nom d\'affichage (facultatif)';
  @override
  @override
  String get otmena_987b => 'Annuler';
  @override
  String get dobavit_5eba => 'Ajouter';
  @override
  String get uVasPokaNetSohranennyh_b64b =>
      'Vous n\'avez pas encore de contacts enregistrés';
  @override
  String get pozvonit_ccfa => 'Appeler';
  @override
  String get napisat_0144 => 'Écrire';
  @override
  String get udalitKontakt_065d => 'Supprimer le contact';
  @override
  String get soobscheniya_7e26 => 'Messages';
  @override
  String get animatsiiSoobscheniy_bc8b => 'Animations de messages';
  @override
  String get pokazyvatAnimatsiiPriOtpravkeI_d663 =>
      'Afficher des animations lors de l\'envoi et de la réception';
  @override
  String get arhivirovannyeChaty_d990 => 'Discussions archivées';
  @override
  String get upravlenieArhivom_e843 => 'Gestion des archives';
  @override
  String get ochistitIstoriyu_837a => 'Effacer l\'historique';
  @override
  String get udalitVseSoobscheniyaLokalno_fbbd =>
      'Supprimer tous les messages localement';
  @override
  String get aktivnyeSessii_5c96 => 'Séances actives';
  @override
  String get etoUstroystvo_26f6 => 'Cet appareil';
  @override
  String get xaneoPcAktivnoSeychas_25b4 => 'Xaneo PC • Actif maintenant';
  @override
  String get aktivno_87a4 => 'Actif';
  @override
  String get dvoynayaAutentifikatsiya_66ae => 'Double authentification';
  @override
  String get zaschitaAkkauntaOdnorazovymParolem_e9f1 =>
      'Protection du compte avec mot de passe à usage unique';
  @override
  String get opasnayaZona_25bc => 'Zone dangereuse';
  @override
  String get udalitAkkaunt_05c7 => 'Supprimer le compte';
  @override
  String get neobratimoeDeystvie_7232 => 'Action irréversible';
  @override
  String get tema_9e26 => 'Sujet';
  @override
  String get temnayaTema_cb48 => 'Thème sombre';
  @override
  String get pereklyuchitMezhduTemnymISvetlym_5415 =>
      'Basculer entre les modes sombre et clair';
  @override
  String get razmerShrifta_1155 => 'Taille de la police';
  @override
  String get a_87a0 => 'Un';
  @override
  String get pokazyvatVsplyvayuschieUvedomleniya_754e =>
      'Afficher les notifications contextuelles';
  @override
  String get zvuk_9329 => 'Son';
  @override
  String get vosproizvoditZvukPriNovomSoobschenii_47cc =>
      'Jouer le son sur le nouveau message';
  @override
  String get osnovnyeNastroyki_231c => 'Paramètres de base';
  @override
  String get rezhimEkonomiiEnergii_edfc => 'Mode d\'économie d\'énergie';
  @override
  String get optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb =>
      'Optimise les performances des applications pour économiser les ressources';
  @override
  String get avtomaticheskiySpyaschiyRezhim_5955 => 'Mode veille automatique';
  @override
  String get perevoditPrilozhenieVSpyaschiyRezhim_1c07 =>
      'Met l\'application en mode veille lorsqu\'elle est inactive';
  @override
  String get animatsii_05c7 => 'Animations';
  @override
  String get uproschennyeAnimatsii_3a13 => 'Animations simplifiées';
  @override
  String get umenshaetKolichestvoAnimatsiyInterfeysa_6bf1 =>
      'Réduit le nombre d’animations d’interface';
  @override
  String get skoroBudetDostupno_de07 => 'Bientôt disponible';
  @override
  String get gostevoyRezhim_6d82 => 'Mode Invité';
  @override
  String get voyditeDlyaDostupaKAkkauntu_a5c8 =>
      'Connectez-vous pour accéder à votre compte';
  @override
  String get nazhmiteDlyaProsmotraIzmeneniy_0255 =>
      'Cliquez pour voir les modifications';
  @override
  String get vvediteKodPodtverzhdeniya_61af => 'Entrez le code de vérification';
  @override
  @override
  String get nevernyyKodPodtverzhdeniya_7762 =>
      'Code de vérification incorrect';
  @override
  String get podtverditeEMail_4bd4 => 'Confirmez votre email';
  @override
  String get proverit_340b => 'Vérifier';
  @override
  @override
  String get otpravitKodPovtorno_7703 => 'Renvoyer le code';
  @override
  String get sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e =>
      'Application de bureau moderne\navec une belle interface et des effets 3D';
  @override
  String get tehnologii_6332 => 'Technologies';
  @override
  String get vyNashliPashalku_1a57 =>
      '🎉 Vous avez trouvé un œuf de Pâques ! 🎉';
  @override
  String get spasiboZaIspolzovanieXaneo_d079 => 'Merci d\'utiliser xaneo !';
  @override
  String get globalnyyPoisk_77bf => 'RECHERCHE GLOBALE';
  @override
  @override
  String get poiskKontaktovChatovKanalovBotov_db66 =>
      'Rechercher contacts, groupes, canaux, bots...';
  @override
  @override
  String get lyudi_c7ae => 'Personnes';
  @override
  @override
  String get gruppy_ebc4 => 'Groupes';
  @override
  @override
  String get kanaly_0c11 => 'Canaux';
  @override
  @override
  String get boty_d6e4 => 'Bots';
  @override
  @override
  String get izbrannoe_2fc4 => 'Messages enregistrés';
  @override
  @override
  String get vvediteZaprosDlyaPoiskaPo_9955 =>
      'Saisissez une requête pour chercher sur le réseau Xaneo';
  @override
  @override
  String get nichegoNeNaydeno_8767 => 'Aucun résultat trouvé';
  @override
  @override
  String get izbrannoe_b637 => 'MESSAGES ENREGISTRÉS';
  @override
  @override
  String get boty_800d => 'BOTS';
  @override
  @override
  String get kanaly_ccec => 'CANAUX';
  @override
  @override
  String get gruppy_cfd6 => 'GROUPES';
  @override
  @override
  String get polzovateli_e0ec => 'UTILISATEURS';
  @override
  @override
  String get sohranennyeSoobscheniya_6b62 => 'Messages enregistrés';
  @override
  @override
  String get bot_0ae1 => 'Bot';
  @override
  @override
  String get bot_0f46 => 'bot';
  @override
  @override
  String get gruppa_99d9 => 'Groupe';
  @override
  @override
  String get kanal_2710 => 'Canal';
  @override
  String get versiya_3725 => 'Version';
  @override
  String get tehnicheskayaInformatsiya_ba0f => 'Informations techniques';
  @override
  String get platforma_8848 => 'Plateforme';
  @override
  String get arhitekturaProtsessora_c079 => 'Architecture du processeur';
  @override
  String get posmotretNaGithub_5238 => 'Voir sur GitHub';
  @override
  String get zakryt_dd94 => 'Fermer';
  @override
  String get vklyuchitTemnuyuTemu_ed17 => 'Activer le thème sombre';
  @override
  String get vklyuchitUvedomleniya_d311 => 'Activer les notifications';
  @override
  String get kastomnyyOverleyXaneo_7d39 => 'Superposition Xaneo personnalisée';
  @override
  String get animirovannyeUvedomleniyaSBystrymOtvetom_a25d =>
      'Notifications animées avec réponse rapide';
  @override
  String get aaBbVv_1c6b => 'Aa bb bb';
  @override
  String get pleylist_a04c => 'LISTE DE LECTURE';
  @override
  String get spisokMuzyki_d477 => 'LISTE DE MUSIQUE';
  @override
  String get loc_0B_5a4d => '0B';
  @override
  String get b_3b67 => 'B';
  @override
  String get kb_419d => 'Ko';
  @override
  String get mb_b808 => 'Mo';
  @override
  String get gb_e572 => 'FR';
  @override
  String get audiozapis_867d => 'Enregistrement audio';
  @override
  String get muzykalnyyTrek_b15d => 'Piste de musique';
  @override
  String get muzykalnyeTrekiOtsutstvuyut_3301 =>
      'Il n\'y a pas de morceaux de musique';
  @override
  @override
  String get nikneymUzheZanyat_59aa => 'Le nom d\'utilisateur est déjà pris';
  @override
  @override
  String get oshibkaProverki_2ab0 => 'Erreur de vérification';
  @override
  @override
  String get emailUzheZanyat_17e1 => 'L\'adresse e-mail est déjà utilisée';
  @override
  @override
  String get oshibkaOtpravkiKoda_a42a =>
      'Erreur d\'envoi du code de vérification';
  @override
  @override
  String get neobhodimoPrinyatUsloviyaISoglasie_e31e =>
      'Vous devez accepter les conditions d\'utilisation et la politique de confidentialité';
  @override
  @override
  String get registratsiyaUspeshna_9d5c => 'Inscription réussie !';
  @override
  @override
  String get oshibkaRegistratsii_b9f2 => 'Erreur d\'inscription';
  @override
  @override
  String get nazad_2b0b => 'Retour';
  @override
  @override
  String get kakVasZovut_68b7 => 'Comment vous appelez-vous ?';
  @override
  @override
  String get kogdaVyRodilis_26f2 => 'Quand êtes-vous né(e) ?';
  @override
  @override
  String get pridumayteNikneym_221b => 'Choisissez un nom d' 'utilisateur';
  @override
  @override
  String get vashEmail_8bbd => 'Votre e-mail';
  @override
  @override
  String get podtverzhdenieEmail_281f => 'Vérification de l' 'e-mail';
  @override
  @override
  String get sozdayteParol_5f4c => 'Créez un mot de passe';
  @override
  @override
  String get podtverzhdenieParolya_ebc2 => 'Confirmez le mot de passe';
  @override
  @override
  String get dobavteFoto_25eb => 'Ajoutez une photo';
  @override
  @override
  String get posledniyShag_e0c5 => 'Dernière étape';
  @override
  @override
  String get vvediteVasheNastoyascheeImya_e656 => 'Entrez votre vrai nom';
  @override
  @override
  String get vamDolzhnoBytNeMenee_1111 => 'Vous devez avoir au moins 13 ans';
  @override
  @override
  String get nikneymDolzhenBytUnikalnym_952d =>
      'Le nom d' 'utilisateur doit être unique';
  @override
  @override
  String get myOtpravimKodPodtverzhdeniya_fc71 =>
      'Nous enverrons un code de vérification à votre e-mail';
  @override
  @override
  String get vvedite6ZnachnyyKodIz_f22f => 'Entrez le code à 6 chiffres reçu';
  @override
  @override
  String get pridumayteNadezhnyyParol_2312 =>
      'Créez un mot de passe fort (min. 8 caract.)';
  @override
  @override
  String get povtoriteParolEscheRaz_6723 => 'Répétez le mot de passe';
  @override
  @override
  String get etoNeobyazatelnoNoPriyatno_b6a3 =>
      'C' 'est facultatif mais recommandé';
  @override
  @override
  String get proverteVashiDannyeIPrimite_3121 =>
      'Vérifiez vos informations et acceptez les conditions';
  @override
  @override
  String get registratsiya_0b93 => 'Inscription';
  @override
  @override
  String get vasheImya_51eb => 'Votre nom';
  @override
  @override
  @override
  String get proverkaDostupnosti_da13 => 'Vérification de la disponibilité...';
  @override
  @override
  String get nikneymDostupen_3fc9 => 'Nom d' 'utilisateur disponible';
  @override
  @override
  String get nikneymZanyat_8a5f => 'Nom d' 'utilisateur déjà pris';
  @override
  @override
  @override
  String get emailDostupen_e903 => 'E-mail disponible';
  @override
  @override
  @override
  String get emailZanyat_fb40 => 'E-mail déjà pris';
  @override
  @override
  String get kodPodtverzhdeniya_1c9d => 'Code de vérification';
  @override
  @override
  String get parol_5ebe => 'Mot de passe';
  @override
  @override
  String get podtverditeParol_e3e3 => 'Confirmez le mot de passe';
  @override
  @override
  String get nazhmiteChtobyDobavitFoto_d6e8 => 'Appuyez pour ajouter une photo';
  @override
  @override
  String get udalitFoto_3426 => 'Supprimer la photo';
  @override
  @override
  String get yaPrinimayuUsloviyaIspolzovaniya_391a =>
      'J' 'accepte les Conditions d' 'utilisation';
  @override
  @override
  String get yaSoglasenNaObrabotkuPersonalnyh_f2a8 =>
      'J' 'accepte le traitement des données personnelles';
  @override
  @override
  String get zavershit_b0e3 => 'Terminer';
  @override
  @override
  String get dalee_c453 => 'Suivant';
  @override
  @override
  String get dataRozhdeniya_505e => 'Date de naissance';
  @override
  String get vklyuchitTemnuyuTemuOformleniya_86c4 => 'Activer le thème sombre';
  @override
  @override
  String get yanvar_ee86 => 'Janvier';
  @override
  @override
  String get fevral_28ff => 'Février';
  @override
  @override
  String get mart_d766 => 'Mars';
  @override
  @override
  String get aprel_03e9 => 'Avril';
  @override
  @override
  String get may_2e53 => 'Mai';
  @override
  @override
  String get iyun_cfcb => 'Juin';
  @override
  @override
  String get iyul_89fb => 'Juillet';
  @override
  @override
  String get avgust_de5a => 'Août';
  @override
  @override
  String get sentyabr_ebfb => 'Septembre';
  @override
  @override
  String get oktyabr_1720 => 'Octobre';
  @override
  @override
  String get noyabr_66fb => 'Novembre';
  @override
  @override
  String get dekabr_39b3 => 'Décembre';
  @override
  @override
  String get pn_2c1e => 'Lun';
  @override
  @override
  String get vt_7145 => 'Mar';
  @override
  @override
  String get sr_c6e4 => 'Mer';
  @override
  @override
  String get cht_a51f => 'Jeu';
  @override
  @override
  String get pt_0123 => 'Ven';
  @override
  @override
  String get sb_3a4b => 'Sam';
  @override
  @override
  String get vs_4ad9 => 'Dim';
  @override
  @override
  String get gotovo_34e1 => 'Terminé';
  @override
  String get oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b =>
      'Erreur de récupération de clé (échec de l\'écrasement)';
  @override
  String get kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7 =>
      'Erreur critique lors de la régénération des clés de chiffrement';
  @override
  String get oshibkaZagruzkiKlyucheyNaServer_ff9b =>
      'Erreur lors du chargement des clés sur le serveur';
  @override
  String get oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4 =>
      'Erreur lors de la récupération des clés de chiffrement';
  @override
  String get prevyshenLimitV5Akkauntov_a6a9 =>
      'La limite de 5 comptes sur ce client a été dépassée ou il y a une erreur de connexion.';
  @override
  @override
  String get oshibkaAvtorizatsii_9f5c => 'Erreur d' 'autorisation';
  @override
  @override
  @override
  String get oshibkaPodklyucheniyaKServeru_8b96 =>
      'Erreur de connexion au serveur';
  @override
  @override
  String get nazadKMessendzheru_de29 => 'Retour à la messagerie';
  @override
  @override
  String get voytiVAkkaunt_c439 => 'Connexion';
  @override
  @override
  String get vvediteParol_1370 => 'Entrez le mot de passe';
  @override
  @override
  String get vvediteSvoiDannyeDlyaDostupa_319e =>
      'Saisissez vos identifiants pour accéder aux messages.';
  @override
  @override
  String get voyti_63a7 => 'Se connecter';
  @override
  String get sobesednik_7025 => 'Interlocuteur';
  @override
  String get vy_0101 => 'tu';
  @override
  String get vyDelitesSvoimEkranom_16b1 => 'Vous partagez votre écran';
  @override
  String get polzovatel_f154 => 'Utilisateur';
  @override
  String get ishodyaschiyVyzov_650b => 'Appel sortant...';
  @override
  String get vhodyaschiyVyzov_19ff => 'Appel entrant...';
  @override
  String get podklyucheno_d022 => 'Connecté';
  @override
  String get ozhidanieOtveta_a984 => 'En attente d\'une réponse...';
  @override
  String get razgovorPoAudiosvyazi_3ed7 => 'Conversation audio';
  @override
  String get translyatsiyaVashegoEkranaZapuschena_575a =>
      'Votre screencast a commencé';
  @override
  String get sobesednikViditVseChtoProishodit_c759 =>
      'L\'interlocuteur voit tout ce qui se passe sur votre bureau';
  @override
  String get vhodyaschiyVyzov_905e => 'APPEL ENTRANT';
  @override
  String get neizvestnyy_be89 => 'Inconnu';
  @override
  String get videozvonok_dd18 => 'Appel vidéo...';
  @override
  String get golosovoyZvonok_5410 => 'Appel vocal...';
  @override
  String get otklonit_8b0d => 'Rejeter';
  @override
  String get otvetit_e568 => 'Répondre';
  @override
  String get gruppovoyZvonok_dac1 => 'Appel de groupe';
  @override
  String get podklyuchenieKZvonku_e2cf => 'Connexion à un appel...';
  @override
  String get podklyuchenieKVeschaniyu_038b => 'Connexion à la diffusion...';
  @override
  String get uchastnik_cffb => 'Membre';
  @override
  String get vy_479c => 'VOUS';
  @override
  String get svernut_ca9f => 'Réduire';
  @override
  String get vhodyaschiyVyzov_d2f3 => 'Appel entrant';
  @override
  String get novoeSoobschenie_1d49 => 'Nouveau message';
  @override
  String get vashOtvet_40c2 => 'Votre réponse...';
  @override
  String get videovyzov_3353 => 'Appel vidéo...';
  @override
  String get audiovyzov_bbb5 => 'Appel audio...';
  @override
  String get nachatZvonok_3d26 => 'LANCER UN APPEL';
  @override
  String get golosovoyZvonok_b615 => 'Appel vocal';
  @override
  String get pozvonitPoGolosovoySvyazi_4069 => 'Passer un appel vocal';
  @override
  String get videozvonok_8142 => 'Appel vidéo';
  @override
  String get pozvonitSVklyuchennoyKameroy_fb05 =>
      'Appeler avec la caméra allumée';
  @override
  String get zashifrovannoeSoobschenie_ca35 => '[Message crypté]';
  @override
  String get golosovoeSoobschenie_4a85 => '🎤 Message vocal';
  @override
  String get videosoobschenie_d687 => '🎬 Message vidéo';
  @override
  String get fayl_826d => '📎 Fichier';
  @override
  String get zvonok_e8d5 => '📞 Appel';
  @override
  String get oshibkaDeshifrovaniya_4146 => '[Erreur de décryptage]';
  @override
  String get zapisyvaetGolosovoe_2a5c => 'enregistre la voix...';
  @override
  String get pechataet_812c => 'des imprimés...';
  @override
  String get neUdalosArhivirovatChat_ab89 => 'Échec de l\'archivage du chat';
  @override
  String get neUdalosRazarhivirovatChat_f0d7 =>
      'Échec de la désarchive du chat';
  @override
  String get arhiv_56aa => 'Archiver';
  @override
  String get netUserid_634a => '[Aucun identifiant utilisateur]';
  @override
  String get netKlyucha_337b => '[Pas de clé]';
  @override
  String get neizvestnyyTipChata_2617 => '[Type de discussion inconnu]';
  @override
  String get neUdalosPoluchitKlyuchShifrovaniya_b953 =>
      'Échec de l\'obtention de la clé de cryptage pour le chat';
  @override
  String get gruppa_19c2 => 'groupe';
  @override
  String get uchastnik_5bce => 'participant';
  @override
  String get uchastnika_92d9 => 'participant';
  @override
  String get uchastnikov_5d6b => 'participants';
  @override
  String get kanal_64ec => 'canal';
  @override
  String get podpischik_695a => 'abonné';
  @override
  String get podpischika_b490 => 'abonné';
  @override
  String get podpischikov_ba39 => 'abonnés';
  @override
  String get segodnya_9626 => 'Aujourd\'hui';
  @override
  String get vchera_61d4 => 'Hier';
  @override
  String get yanvarya_d861 => 'janvier';
  @override
  String get fevralya_fcf9 => 'Février';
  @override
  String get marta_bb77 => 'Mars';
  @override
  String get aprelya_2b5a => 'avril';
  @override
  String get maya_4dbb => 'mai';
  @override
  String get iyunya_adcb => 'juin';
  @override
  String get iyulya_3236 => 'juillet';
  @override
  String get avgusta_e3aa => 'août';
  @override
  String get sentyabrya_a146 => 'septembre';
  @override
  String get oktyabrya_7abd => 'octobre';
  @override
  String get noyabrya_6e78 => 'novembre';
  @override
  String get dekabrya_29cc => 'décembre';
  @override
  String get vyPodpisalisNaKanal_b2b3 => 'Vous êtes abonné à la chaîne';
  @override
  String get vyPrisoedinilisKGruppe_07bd => 'Vous avez rejoint le groupe';
  @override
  String get neUdalosPrisoedinitsya_31e6 => 'Impossible de rejoindre';
  @override
  String get vyOtpisalisOtKanala_7698 =>
      'Vous vous êtes désabonné de la chaîne';
  @override
  String get vyPokinuliGruppu_5a52 => 'Tu as quitté le groupe';
  @override
  String get neUdalosVypolnitDeystvie_3cfd => 'L\'action a échoué';
  @override
  String get neUdalosPereklyuchitAkkaunt_968b =>
      'Échec du changement de compte';
  @override
  String get media_c247 => 'Médias';
  @override
  String get fayly_200c => 'Fichiers';
  @override
  String get golos_2d89 => 'Voix';
  @override
  String get ssylki_9f58 => 'Liens';
  @override
  String get profil_c62a => 'PROFIL';
  @override
  String get imyaPolzovatelya_6fd4 => 'Nom d\'utilisateur';
  @override
  String get denRozhdeniya_e41d => 'Anniversaire';
  @override
  String get polzovatelSkrylInformatsiyuOSebe_f416 =>
      'L\'utilisateur a caché des informations sur lui-même';
  @override
  String get god_6270 => 'année';
  @override
  String get goda_7443 => 'année';
  @override
  String get let_257a => 'années';
  @override
  String get skopirovano_f70b => 'Copié';
  @override
  String get akkaunty_80b5 => 'COMPTES';
  @override
  String get dobavitAkkaunt_5253 => 'Ajouter un compte';
  @override
  String get limit5Akkauntov_fdb7 => 'Limite : 5 comptes';
  @override
  String get nazadKChatam_7edb => 'Retour aux discussions';
  @override
  String get chaty_19ad => 'Discussions';
  @override
  String get globalnyyPoisk_7ff2 => 'Recherche globale';
  @override
  String get arhivPust_3e22 => 'L\'archive est vide';
  @override
  String get netSoobscheniy_29d4 => 'Aucun message';
  @override
  String get toDoList_27e1 => '📋 Feuille de tâches';
  @override
  String get opros_6ff1 => '🗳️ Sondage';
  @override
  String get fotografiya_5709 => '📷 Photographie';
  @override
  String get razarhivirovat_416b => 'Décompresser';
  @override
  String get vArhiv_ce22 => 'Vers les archives';
  @override
  String get chat_c52b => 'Discuter';
  @override
  String get vyberiteChatDlyaNachalaObscheniya_36a5 =>
      'Sélectionnez un chat pour commencer à discuter';
  @override
  String get bot_2712 => 'robot';
  @override
  String get vSeti_d902 => 'en ligne';
  @override
  String get neVSeti_ee01 => 'hors ligne';
  @override
  String get nastroykiChata_1e0d => 'Paramètres de discussion';
  @override
  String get pokinutGruppu_e6ce => 'Quitter le groupe';
  @override
  String get prisoedinitsyaKGruppe_eb45 => 'Rejoignez le groupe';
  @override
  String get otpisatsyaOtKanala_fdbc => 'Se désabonner de la chaîne';
  @override
  String get podpisatsyaNaKanal_2dad => 'Abonnez-vous à la chaîne';
  @override
  String get netSoobscheniyNapishiteChtoNibud_2bf4 =>
      'Aucun message. Écrivez quelque chose !';
  @override
  String get prisoedinilsyaKChatu_f623 => 'rejoint le chat';
  @override
  String get pokinulChat_d567 => 'j\'ai quitté le chat';
  @override
  String get podpisalsyaNaKanal_0673 => 'abonné à la chaîne';
  @override
  String get otpisalsyaOtKanala_fa13 => 'désabonné de la chaîne';
  @override
  String get polzovatelya_1083 => 'utilisateur';
  @override
  String get priglasil_47ae => 'invité';
  @override
  String get rasshifrovka_e47f => '[Transcription...]';
  @override
  String get sistemnoeSoobschenie_d2bd => 'Message système';
  @override
  String get soobschenie_3715 => 'Message';
  @override
  String get videosoobschenie_57f1 => '📹Message vidéo';
  @override
  String get spisokZadach_cfa4 => '📋 Liste des tâches';
  @override
  String get opros_5902 => '📊 Sondage';
  @override
  String get vlozhenie_ef44 => 'Pièce jointe';
  @override
  String get fayl_2d46 => 'Fichier';
  @override
  String get zagruzkaFayla_f817 => 'Chargement du fichier...';
  @override
  String get ishodyaschiyZvonok_8381 => 'Appel sortant';
  @override
  String get razgovorNeSostoyalsya_67fb => 'La conversation n\'a pas eu lieu';
  @override
  String get vhodyaschiyZvonok_5ce9 => 'Appel entrant';
  @override
  String get otklonennyyZvonok_d499 => 'Appel rejeté';
  @override
  String get vyOtkloniliVyzov_8d1d => 'Vous avez rejeté l\'appel';
  @override
  String get propuschennyyZvonok_e98d => 'Appel manqué';
  @override
  String get vyPropustiliVyzov_f17a => 'Tu as manqué l\'appel';
  @override
  String get vlozhenie_2474 => '📎Pièce jointe';
  @override
  String get tb_0e05 => 'tuberculose';
  @override
  String get zapisGolosovogo_9c91 => 'Enregistrement vocal...';
  @override
  String get zapisVideo_dd2a => 'Enregistrement vidéo...';
  @override
  String get otpustiteDlyaOtpravki_ea7b => 'Libérer pour envoyer';
  @override
  String get emodzi_f822 => 'Émoji';
  @override
  String get panelEmodziVRazrabotke_b6ce =>
      'Panneau Emoji en cours de développement';
  @override
  String get napisatSoobschenie_62d4 => 'Écrivez un message...';
  @override
  String get dobavitVlozhenie_769b => 'Ajouter une pièce jointe';
  @override
  String get spisokZadach_1852 => 'Liste des tâches';
  @override
  String get opros_9f36 => 'Sondage';
  @override
  String get zapisGolosovogoGs_db4e => 'Enregistrement vocal (VO)';
  @override
  String get zapisVideoVs_9676 => 'Enregistrement vidéo (VS)';
  @override
  String get uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3 =>
      '• Maintenez le bouton enfoncé pour enregistrer\n• Appuyez pour changer de mode';
  @override
  @override
  String get novyyChat_f775 => 'Nouvelle discussion';
  @override
  @override
  String get imyaPolzovatelyaMin5Simvolov_1232 =>
      'Nom d\'utilisateur (min. 5 caractères)';
  @override
  @override
  String get vvedite5IliBoleeSimvolov_f983 => 'Entrez 5 caractères ou plus';
  @override
  @override
  String get polzovateliNeNaydeny_c01a => 'Aucun utilisateur trouvé';
  @override
  String get mnozhestvennyyVybor_9b60 => 'Choix multiples';
  @override
  String get odinochnyyVybor_d920 => 'Sélection unique';
  @override
  String get netGolosov_17d0 => 'Aucun vote';
  @override
  String get golos_6b94 => 'voix';
  @override
  String get golosa_bb8d => 'voix';
  @override
  String get golosov_7f51 => 'voix';
  @override
  String get nePoluchenIdFaylaOt_86c8 => 'ID de fichier non reçu du serveur';
  @override
  String get faylZagruzhenIPrikreplen_dc24 => 'Fichier téléchargé et joint';
  @override
  String get neizvestnayaOshibkaZagruzki_68cb =>
      'Erreur de téléchargement inconnue';
  @override
  String get oshibkaZagruzkiFayla_86e5 => 'Erreur de téléchargement de fichier';
  @override
  String get sohranitFaylKak_0f93 => 'Enregistrer le fichier sous';
  @override
  String get oshibkaSkachivaniyaFayla_34ac =>
      'Erreur de téléchargement de fichier';
  @override
  String get bezNazvaniya_6584 => 'Sans titre';
  @override
  String get bezVoprosa_d390 => 'Aucune question';
  @override
  String get netDostupaKMikrofonu_a4ef => 'Pas d\'accès au microphone';
  @override
  String get zapisVideoCherezPlaginCamera_b9dd =>
      '📹 L\'enregistrement vidéo via le plugin caméra a commencé';
  @override
  String get kameraNeInitsializirovanaNaEtoy_21e0 =>
      '📹 La caméra n\'est pas initialisée sur cette plateforme.';
  @override
  String get kameraNeGotova_9f09 => 'La caméra n\'est pas prête';
  @override
  String get zapisVideosoobscheniyaNaEtoyPlatforme_a561 =>
      '📹 L\'enregistrement des messages vidéo n\'est pas directement disponible sur cette plateforme.';
  @override
  String get arecordOstanovlen_edf2 => '🎙️ un enregistrement a été arrêté';
  @override
  String get ffmpegOstanovlen_63a0 => '📹 ffmpeg arrêté';
  @override
  String get zapisSlishkomKorotkaya_5cda => 'L\'entrée est trop courte';
  @override
  String get oshibkaZapisiFaylPust_106b =>
      'Erreur d\'écriture : le fichier est vide';
  @override
  String get videosoobschenieOtpravlenoSimulyatsiya_fb29 =>
      'Message vidéo envoyé (simulation)';
  @override
  String get zapisOtmenena_1609 => 'Inscription annulée';
  @override
  String get otpravitGolosovoeSoobschenie_2481 => 'Envoyer un message vocal';
  @override
  String get imitatsiyaZapisiGolosovogoSoobscheniya_81e7 =>
      'Simulation d\'enregistrement d\'un message vocal.';
  @override
  String get otpravit_6da0 => 'Envoyer';
  @override
  String get sozdatToDo_8c92 => 'CRÉER UNE TÂCHE';
  @override
  String get nazvanieSpiska_c3cc => 'Nom de la liste';
  @override
  String get punkty_0481 => 'Articles :';
  @override
  String get dobavitPunkt_930c => 'Ajouter un article';
  @override
  String get sozdat_b059 => 'Créer';
  @override
  String get sozdatOpros_4b9e => 'CRÉER UNE ENQUÊTE';
  @override
  String get vopros_0911 => 'Question';
  @override
  String get variantyOtveta_ef4e => 'Options de réponse :';
  @override
  String get dobavitVariant_76be => 'Ajouter une option';
  @override
  String get golosovoeSoobschenie_33d5 => 'Message vocal';
  @override
  String get videosoobschenie_2951 => 'Message vidéo';
  @override
  String get video_a095 => 'Vidéo';
  @override
  String get neUdalosZagruzitIzobrazhenie_3fa0 =>
      'Échec du chargement de l\'image';
  @override
  String get muzyka_0660 => 'Musique';
  @override
  String get netDannyh_dee9 => 'Aucune donnée';
  @override
  String get istoriyaSoobscheniyPustaIliChat_2d07 =>
      'L\'historique des messages est vide ou le chat n\'a pas encore été enregistré localement';
  @override
  String get obschieMaterialy_11e4 => 'Matériel général';
  @override
  String get netMediafaylov_08d2 => 'Aucun fichier multimédia';
  @override
  String get zdesBudutOtobrazhatsyaObschieFoto_9bc7 =>
      'Les photos et vidéos partagées seront affichées ici';
  @override
  String get netFaylov_e95e => 'Aucun fichier';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c =>
      'Les fichiers téléchargés seront affichés ici';
  @override
  String get netGolosovyhSoobscheniy_2427 => 'Pas de messages vocaux';
  @override
  String get zdesBudutOtobrazhatsyaGolosovyeI_0a73 =>
      'Les messages vocaux et vidéo seront affichés ici';
  @override
  String get netSsylok_b0ec => 'Aucun lien';
  @override
  String get zdesBudutOtobrazhatsyaObschieSsylki_6b61 =>
      'Les liens généraux apparaîtront ici';
  @override
  String get ssylkaSkopirovanaVBufer_c16e => 'Lien copié dans le presse-papier';
  @override
  String get netMuzyki_1ca3 => 'Pas de musique';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23 =>
      'Les pistes soumises seront affichées ici';
  @override
  String get udalennyyAkkaunt_ce47 => 'compte supprimé';
  @override
  String get opisanie_38ca => 'Descriptif';
  @override
  String get mobilnyy_5ac7 => 'Mobile';
  @override
  String get bylANedavno_168d => 'était récemment';
  @override
  String get minutu_5373 => 'minute';
  @override
  String get minuty_5bc9 => 'minutes';
  @override
  String get minut_b877 => 'minutes';
  @override
  String get nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a =>
      'Cliquez pour télécharger la nouvelle version';
  @override
  String get poiskLyudeyBotovGrupp_e84e =>
      'Rechercher des personnes, des robots, des groupes...';
  @override
  String get vveditePoiskovyyZapros_0b8c => 'Entrez votre terme de recherche';
  @override
  String get polzovateli_b8c4 => 'Utilisateurs';
  @override
  String get moiLichnyeSoobscheniya_7d3b => 'Mes messages personnels';
  @override
  String get sozdatNovyyChat_fd41 => 'Créer une nouvelle discussion';
  @override
  String get lichnyyChat_cbec => 'Discussion personnelle';
  @override
  String get nachatObschenieSPolzovatelem_0578 =>
      'Démarrer une conversation avec un utilisateur';
  @override
  String get sozdatGruppu_459f => 'Créer un groupe';
  @override
  String get gruppovoyChatDlyaObscheniyaS_01ba =>
      'Chat de groupe pour communiquer avec des amis';
  @override
  String get sozdatKanal_9022 => 'Créer une chaîne';
  @override
  String get kanalDlyaShirokoyAuditorii_9dba => 'Chaîne pour un large public';
  @override
  String get redaktirovanie_1167 => 'Édition';
  @override
  String get vlevo_1af1 => 'Gauche';
  @override
  String get vpravo_c316 => 'À droite';
  @override
  String get poGor_ff50 => 'Le long des montagnes';
  @override
  String get poVert_b4a9 => 'Vert.';
  @override
  String get vvediteNazvanieGruppy_0a69 => 'Entrez le nom du groupe';
  @override
  String get dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0 =>
      'Un groupe public nécessite un pseudo (@username)';
  @override
  String get gruppaSozdana_6b3b => 'Groupe créé';
  @override
  String get oshibkaPriSozdaniiGruppy_794e =>
      'Erreur lors de la création du groupe';
  @override
  String get nazhmiteNaIkonkuChtobyVybrat_af03 =>
      'Cliquez sur l\'icône pour sélectionner un avatar';
  @override
  String get nazvanieGruppy_9a39 => 'Nom du groupe';
  @override
  String get opisanieNeobyazatelno_7812 => 'Description (facultatif)';
  @override
  String get privatnayaGruppa_d20e => 'Groupe privé';
  @override
  String get publichnayaGruppa_50f8 => 'Groupe public';
  @override
  String get vhodTolkoPoPriglasheniyu_97a1 =>
      'Entrée sur invitation uniquement';
  @override
  String get lyuboyMozhetNaytiIVstupit_5e26 =>
      'Tout le monde peut trouver et rejoindre';
  @override
  String get publichnayaSsylkanikneymMyGroup_6640 =>
      'Lien public/surnom (@my_group)';
  @override
  String get vvediteNazvanieKanala_5536 => 'Entrez le nom de la chaîne';
  @override
  String get dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06 =>
      'Une chaîne publique nécessite un lien/surnom (@mychannel)';
  @override
  String get kanalSozdan_1522 => 'Chaîne créée';
  @override
  String get oshibkaPriSozdaniiKanala_7d4b =>
      'Erreur lors de la création du canal';
  @override
  String get nazvanieKanala_c548 => 'Nom de la chaîne';
  @override
  String get privatnyyKanal_3139 => 'Chaîne privée';
  @override
  String get publichnyyKanal_0f7c => 'Chaîne publique';
  @override
  String get podpiskaTolkoPoPriglasheniyu_99c3 =>
      'Inscription sur invitation uniquement';
  @override
  String get lyuboyMozhetNaytiIPodpisatsya_8579 =>
      'Tout le monde peut trouver et s\'abonner';
  @override
  String get ssylkanikneymKanalaMychannel_79f6 =>
      'Lien/pseudonyme de la chaîne (@mychannel)';
  @override
  String get yazykInterfeysa_b78b => 'Langue de l\'interface';
  @override
  String get dannyeUspeshnoSohraneny_2cc5 => 'Données enregistrées avec succès';
  @override
  String get oshibkaPriSohranenii_126f => 'Erreur lors de l\'enregistrement';
  @override
  String get lichnyeDannye_10a7 => 'DONNÉES PERSONNELLES';
  @override
  String get nikneymUsername_8035 => 'Pseudo (@nom d’utilisateur)';
  @override
  String get nikneymNelzyaIzmenit_0b99 => 'Le pseudo ne peut pas être modifié';
  @override
  String get oSebeBio_b730 => 'À propos de moi (Biographie)';
  @override
  String get rasskazhiteNemnogoOSebe_3daa => 'Parlez-nous un peu de vous...';
  @override
  String get nastroykiPrivatnostiSohraneny_447c =>
      'Paramètres de confidentialité enregistrés';
  @override
  String get privatnost_3098 => 'CONFIDENTIALITÉ';
  @override
  String get kommunikatsii_e9b8 => 'COMMUNICATION';
  @override
  String get ktoMozhetPisat_3322 => 'Qui peut écrire';
  @override
  String get zapisGolosovyh_8073 => 'Enregistrement vocal';
  @override
  String get otpravkaFaylov_aaca => 'Envoi de fichiers';
  @override
  String get priglashatVGruppy_3631 => 'Inviter à des groupes';
  @override
  String get vidimostProfilya_448f => 'VISIBILITÉ DU PROFIL';
  @override
  String get ktoViditAvatar_b5d8 => 'Qui voit l\'avatar';
  @override
  String get vremyaVSeti_be29 => 'Temps en ligne';
  @override
  String get vneshniyVid_5a0f => 'APPARENCE';
  @override
  String get rezhimOformleniyaInterfeysa_b91d =>
      'Mode de conception d\'interface';
  @override
  String get pokazyvatVizualnyeEffektyIPerehody_3fd7 =>
      'Afficher les effets visuels et les transitions';
  @override
  String get razmerTeksta_3c4f => 'Taille du texte';
  @override
  String get bezopasnost_fcbc => 'SÉCURITÉ';
  @override
  String get dvuhfaktornayaAutentifikatsiya_acdc =>
      'Authentification à deux facteurs';
  @override
  String get zaschitaAkkaunta2fa_f1ab => 'Protection du compte 2FA';
  @override
  String get vklyucheno_6b96 => 'Inclus';
  @override
  String get xaneoMobileAktivnoSeychas_3345 =>
      'Xaneo Mobile • Actif maintenant';
  @override
  String get zaschischennyyMessendzher_2f59 => 'Messagerie sécurisée';
  @override
  String get temnayaTema_6018 => 'Thème sombre';
  @override
  String get vklyuchenaPoUmolchaniyu_7610 => 'Activé (par défaut)';
  @override
  String get setevoyFiltr_40c2 => 'Filtre contre les surtensions';
  @override
  String get vklyuchen_0994 => 'Activé';
  @override
  String get spisokMuzyki_57d0 => 'Liste de musique';
  @override
  String get trek_5049 => 'piste';
  @override
  String get trekov_d3f4 => 'pistes';
  @override
  String get pozhaluystaZapolniteVoprosIKak_7ad5 =>
      'Veuillez remplir la question et au moins deux options de réponse';
  @override
  String get sozdatOpros_8401 => 'Créer une enquête';
  @override
  String get sozdatSpisokZadach_4018 => 'CRÉER UNE LISTE DE TÂCHES';
  @override
  String get pozhaluystaZapolniteNazvanieIKak_3783 =>
      'Veuillez remplir le titre et au moins un élément';
  @override
  String get sozdatSpisokZadach_0416 => 'Créer une liste de tâches';
  @override
  String get vhodyaschiyVideozvonok_14d4 => 'Appel vidéo entrant';
  @override
  String get prinyat_5dc5 => 'Accepter';
  @override
  String get netObschihFaylov_bf77 => 'Aucun fichier partagé';
  @override
  String get neUdalosRazarhivirovatChatNa_b6f6 =>
      'Échec de la désarchive du chat sur le serveur';
  @override
  String get poiskVArhive_c5d8 => 'Recherche d\'archives...';
  @override
  String get poprobuyteIzmenitZapros_52ea =>
      'Essayez de modifier votre demande';
  @override
  String get zdesBudutNahoditsyaVashiArhivirovannye_7359 =>
      'Vos discussions archivées seront placées ici';
  @override
  String get vernut_54aa => 'Retour';
  @override
  String get zashifrovannoeSoobschenie_c9ab => 'Message crypté';
  @override
  String get soobschenieNahoditsyaVysheVIstorii_dc90 =>
      'Le message est plus haut dans l\'histoire.';
  @override
  String get otpravlyaetFoto_67c1 => 'envoie une photo...';
  @override
  String get otpravlyaetVideo_ce80 => 'envoie une vidéo...';
  @override
  String get otpravlyaetFayl_5e88 => 'envoie le fichier...';
  @override
  String get ktoTo_8405 => 'Quelqu\'un';
  @override
  String get trebuetsyaRazreshenieNaKameruI_06fa =>
      'Autorisation de la caméra et du microphone requise';
  @override
  String get kameraNeNaydena_208d => 'Caméra introuvable';
  @override
  String get zapisVideoOtmenena_1db7 => 'Enregistrement vidéo annulé';
  @override
  String get slishkomKorotkoeVideosoobschenie_4676 =>
      'Message vidéo trop court';
  @override
  String get pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35 =>
      'Veuillez attendre que les fichiers soient téléchargés';
  @override
  String get audiozvonok_dcf6 => 'Appel audio';
  @override
  String get otpravitFotoVideoAudioIli_37e9 =>
      'Envoyer des photos, des vidéos, de l\'audio ou d\'autres fichiers';
  @override
  String get provedenieGolosovaniyaVChate_a629 => 'Voter dans le chat';
  @override
  String get sozdatToDoSpisok_cb50 => 'Créer une liste de tâches';
  @override
  String get spisokZadachSOtmetkamiVypolneniya_c778 =>
      'Liste des tâches avec notes d\'achèvement';
  @override
  String get trebuetsyaRazreshenieNaZapisAudio_8175 =>
      'Nécessite une autorisation pour enregistrer de l\'audio';
  @override
  String get slishkomKorotkoeSoobschenie_c2ee => 'Message trop court';
  @override
  String get uderzhivayteKnopkuDlyaZapisi_a762 =>
      'Maintenez le bouton enfoncé pour enregistrer';
  @override
  String get udalennyy_40c6 => 'à distance';
  @override
  String get udalennyy_c2c8 => 'à distance';
  @override
  String get neobhodimyRazresheniyaNaMikrofonI_224b =>
      'Autorisations de microphone et de caméra requises pour passer un appel';
  @override
  String get bylATolkoChto_9ac0 => 'j\'étais juste là';
  @override
  String get chatNeNayden_ba4f => 'Chat introuvable';
  @override
  String get napishitePervoeSoobschenie_8260 => 'Écrivez votre premier message';
  @override
  String get prisoedinitsyaKKanalu_f863 => 'Rejoignez la chaîne';
  @override
  String get vyPodpisany_5fb9 => 'Vous êtes abonné';
  @override
  String get otpisatsya_ee2d => 'Se désabonner';
  @override
  String get vyUspeshnoPodpisalisNaKanal_9c99 =>
      'Vous vous êtes abonné avec succès à la chaîne !';
  @override
  String get vyUspeshnoVstupiliVGruppu_61a1 =>
      'Vous avez rejoint le groupe avec succès !';
  @override
  String get neUdalosPrisoedinitsyaPoprobuyteEsche_bce5 =>
      'Échec de l\'adhésion. Essayer à nouveau.';
  @override
  String get vyrezat_a195 => 'Couper';
  @override
  String get kopirovat_112b => 'Copier';
  @override
  String get vstavit_dcc4 => 'Coller';
  @override
  String get vybratVse_4d09 => 'Tout sélectionner';
  @override
  String get zhirnyy_7774 => 'Audacieux';
  @override
  String get kursiv_e0b1 => 'Italique';
  @override
  String get kod_3f34 => 'Coder';
  @override
  String get zacherknut_02fc => 'Rayer';
  @override
  String get soobschenie_8b9b => 'Message...';
  @override
  String get smahniteDlyaOtmeny_e976 => 'Glissez pour annuler';
  @override
  String get poisk_bfc9 => 'Rechercher';
  @override
  String get udalitChat_4b2b => 'Supprimer le chat';
  @override
  String get udalitKanal_482f => 'Supprimer la chaîne';
  @override
  String get pozhalovatsya_a7d9 => 'Se plaindre';
  @override
  String get redaktirovatGruppu_e40a => 'Modifier le groupe';
  @override
  String get udalitGruppu_dff8 => 'Supprimer le groupe';
  @override
  String get poiskSoobscheniyVremennoNedostupenV_4443 =>
      'La recherche de messages est temporairement indisponible dans la version mobile';
  @override
  String get zhalobaOtpravlenaModeratoram_4547 =>
      'La plainte a été envoyée aux modérateurs';
  @override
  String get redaktirovanieGruppyVremennoNedostupnoV_05d0 =>
      'L\'édition de groupe est temporairement indisponible dans la version mobile';
  @override
  String get vyUverenyChtoHotiteOchistit_7c3a =>
      'Êtes-vous sûr de vouloir effacer l\'historique de vos messages dans ce chat ? Cette action ne peut pas être annulée.';
  @override
  String get ochistit_7074 => 'Effacer';
  @override
  String get udalit_ed2b => 'Supprimer';
  @override
  String get vyyti_0f05 => 'Se déconnecter';
  @override
  String get oshibkaVosproizvedeniya_ac8a => 'Erreur de lecture';
  @override
  String get novoeZashifrovannoeSoobschenie_4d30 => 'Nouveau message crypté';
  @override
  String get poiskChatov_779c => 'Rechercher des discussions...';
  @override
  String get obnovlenie_53e2 => 'Mise à jour...';
  @override
  String get soedinenie_5a58 => 'Connexion...';
  @override
  String get lichnye_4cb3 => 'Personnel';
  @override
  String get neUdalosArhivirovatChatNa_36aa =>
      'Échec de l\'archivage du chat sur le serveur';
  @override
  String get oshibkaZagruzkiChatov_902f =>
      'Erreur lors du chargement des discussions';
  @override
  String get povtorit_b914 => 'Répéter';
  @override
  String get netChatov_85e3 => 'Pas de discussion';
  @override
  String get nachniteNovyyRazgovor_8290 => 'Démarrer une nouvelle conversation';
  @override
  String get neUdalosZagruzitAkkaunty_8570 => 'Échec du chargement des comptes';
  @override
  String get vyberiteAkkaunt_79e7 => 'Sélectionnez un compte';
  @override
  String get bystryyVhodNaEtomUstroystve_3f30 =>
      'Connexion rapide sur cet appareil';
  @override
  String get voytiSParolem_9277 => 'Connectez-vous avec mot de passe';
  @override
  String get sozdatXaneoId_4033 => 'Créer un identifiant Xaneo';
  @override
  String get netSohranennyhAkkauntov_b669 => 'Aucun compte enregistré';
  @override
  String get tolkoChto_4493 => 'Juste maintenant';
  @override
  String get emailNedostupen_fc3e => 'E-mail non disponible';
  @override
  String get nevernyyKod_50f9 => 'Code invalide';
  @override
  String get oshibkaProverkiKoda_9018 => 'Erreur de vérification du code';
  @override
  String get neobhodimoRazreshenieNaDostupK_5f5c =>
      'Autorisation requise pour accéder aux photos';
  @override
  String get oVyboreEmail_2609 => 'À propos du choix du courrier électronique';
  @override
  String get podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0 =>
      'Tous les domaines de messagerie sont pris en charge, sauf';
  @override
  String get zapreschennyh_1f49 => 'interdit';
  @override
  String get obIspolzovaniiParolya_9739 =>
      'À propos de l\'utilisation du mot de passe';
  @override
  String get parolTolkoDlyaAvariynogoVhoda_b142 =>
      'Le mot de passe sert uniquement en dernier recours : si vous ne pouvez pas vous connecter avec un code du bot Notifications Xaneo ou avec le code envoyé par e-mail.';
  @override
  String get sozdatAkkaunt_19ed => 'Créer un compte';
  @override
  String get naprimerIvan_d7cb => 'Par exemple, Ivan';
  @override
  String get zadayteParol_53d2 => 'Définir un mot de passe';
  @override
  String get minimum8Simvolov_4ccd => 'Minimum 8 caractères';
  @override
  String get unikalnoeImyaDlyaVashegoProfilya_a0ea =>
      'Un nom unique pour votre profil';
  @override
  String get vashEmail_879d => 'Votre e-mail';
  @override
  String get dlyaSvyaziIVosstanovleniyaDostupa_c770 =>
      'Pour la communication et la restauration des accès';
  @override
  String get emailAdres_9130 => 'Adresse e-mail';
  @override
  String get vvediteParolEscheRaz_7383 => 'Entrez à nouveau votre mot de passe';
  @override
  String get parolEscheRaz_6daf => 'Mot de passe à nouveau';
  @override
  String get paroliNeSovpadayut_d82f =>
      'Les mots de passe ne correspondent pas';
  @override
  String get ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed =>
      'Veuillez indiquer votre véritable date de naissance';
  @override
  String get ddmmgggg_3524 => 'JJ.MM.AAAA';
  @override
  String get sdelayteProfilUznavaemym_f2c5 =>
      'Rendez votre profil reconnaissable';
  @override
  String get profilGotov_b57d => 'Profil prêt';
  @override
  String get ostalosVsegoParaShagov_37e3 => 'Il ne reste que quelques pas';
  @override
  String get yaPrinimayuPolzovatelskoeSoglashenie_c431 =>
      'J\'accepte les conditions d\'utilisation';
  @override
  String get yaDayuSoglasieNaObrabotku_0d03 =>
      'J\'accepte le traitement des données personnelles';
  @override
  String get sVozvrascheniem_77ee => 'Bon retour';
  @override
  String get zagruzka_43e4 => 'Chargement...';
  @override
  String get vyberiteAkkauntDlyaVhoda_d3a6 =>
      'Sélectionnez un compte pour vous connecter';
  @override
  String get vvediteVashNikneym_51a6 => 'Entrez votre pseudo';
  @override
  String get voytiVDrugoyAkkaunt_d10f => 'Connectez-vous à un autre compte';
  @override
  String get nedavnieAkkaunty_953d => 'Comptes récents';
  @override
  String get dobroPozhalovatVXaneo_66d0 => 'Bienvenue chez Xaneo';
  @override
  String get xaneoTeperIVMobilnom_e918 =>
      'Xaneo est désormais disponible dans l\'application mobile ! Ce messager n\'a jamais été aussi pratique et rapide.';
  @override
  String get mneUzheInteresno_5365 => 'je suis déjà intéressé';
  @override
  String get vseVashiDannyePodZaschitoy_b7d9 =>
      'Toutes vos données sont protégées';
  @override
  String get vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e =>
      'Tous les messages sont protégés par un cryptage de bout en bout. A aucun moment Xaneo n\'en connaît le contenu.';
  @override
  String get prodolzhit_e9c3 => 'Continuer';
  @override
  String get lokalnyeDataTsentry_f089 => 'Centres de données locaux';
  @override
  String get vashiDannyeNikogdaNePokidayut_f871 =>
      'Vos données ne quittent jamais le pays et sont stockées dans des centres de données sécurisés.';
  @override
  String get kodOtpravlenPovtorno_e109 => 'Code renvoyé';
  @override
  String get dvuhfaktornayanautentifikatsiya_bacc =>
      'À deux facteurs\nauthentification';
  @override
  String get naVashEmailOtpravlen6_b457 =>
      'Un code à 6 chiffres a été envoyé à votre email';
  @override
  String get podtverdit_e260 => 'Confirmer';
  @override
  String get nePoluchiliKodOtpravitPovtorno_c1d2 =>
      'Vous n\'avez pas reçu le code ? Renvoyer';
  @override
  String get imyaNikneymOSebe_7a8d => 'Nom, surnom, à propos de vous';
  @override
  String get zvonkiSoobscheniyaVidimostProfilya_f905 =>
      'Appels, messages, visibilité du profil';
  @override
  String get parolSessii2fa_de9e => 'Mot de passe, sessions, 2FA';
  @override
  String get prilozhenie_38aa => 'ANNEXE';
  @override
  String get temaRazmerTekstaAnimatsii_f0a8 =>
      'Thème, taille du texte, animations';
  @override
  String get pushUvedomleniyaZvuki_9cc2 => 'Notifications push, sons';
  @override
  String get oPrilozhenii_77b2 => 'À PROPOS DE LA DEMANDE';

  @override
  String get redaktirovatProfil_56ad => 'Modifier le profil';
  @override
  String get dobavitKontakt_2903 => 'AJOUTER UN CONTACT';
  @override
  String get nikneymPolzovatelyaUsername_a6ff =>
      'Pseudonyme de l\'utilisateur (@username)';
  @override
  String get otobrazhaemoeImyaNeobyazatelno_340a =>
      'Nom d\'affichage (facultatif)';
  @override
  String get neUdalosNaytiIliDobavit_649f =>
      'Impossible de trouver ou d\'ajouter un utilisateur';
  @override
  String get ya_feef => 'Je';
  @override
  String get poiskKontaktov_9a71 => 'Rechercher des contacts...';
  @override
  String get spisokKontaktovPust_58c6 => 'La liste de contacts est vide';
  @override
  String get kontaktyNeNaydeny_1b08 => 'Contacts non trouvés';
  @override
  String get messages => 'Messages';
  @override
  String get messageAnimations => 'Animations de messages';
  @override
  String get messageAnimationsDesc =>
      'Afficher les animations à l\'envoi et la réception';
  @override
  String get archivedChats => 'Conversations archivées';
  @override
  String get archiveManagement => 'Gestion des archives';
  @override
  String get clearHistory => 'Effacer l\'historique';
  @override
  String get clearHistoryDesc => 'Supprimer tous les messages localement';
  @override
  String get call => 'Appeler';
  @override
  String get sendMessage => 'Envoyer un message';
  @override
  String get deleteContact => 'Supprimer le contact';
  @override
  String get activeSessions => 'Sessions actives';
  @override
  String get thisDevice => 'Cet appareil';
  @override
  String get xaneoPcActiveNow => 'Xaneo PC • Actif actuellement';
  @override
  String get activeNow => 'Actif';
  @override
  String get twoFactorAuth => 'Authentification à deux facteurs';
  @override
  String get twoFactorAuthDesc =>
      'Protéger le compte avec un mot de passe à usage unique';
  @override
  String get dangerZone => 'Zone dangereuse';
  @override
  String get deleteAccount => 'Supprimer le compte';
  @override
  String get irreversibleAction => 'Action irréversible';
  @override
  String get theme => 'Thème';
  @override
  String get darkThemeDesc => 'Basculer entre le mode sombre et clair';
  @override
  String get fontSizeText => 'Taille de la police';
  @override
  String get changePhoto => 'Modifier la photo';
  @override
  String get avatarUpdated => 'Avatar mis à jour';
  @override
  String get avatarUploadFailed => 'Impossible de téléverser l’avatar';
  @override
  String get invalidNicknameFormat =>
      'Pseudo : 3 à 30 caractères ; lettres, chiffres, ., _ et - uniquement';
  @override
  String get deleteAccountPrompt =>
      'Votre profil sera définitivement supprimé. Saisissez votre mot de passe pour confirmer.';
  @override
  String get deleteAccountFailed => 'Impossible de supprimer le compte';
  @override
  String get chatFontSize => 'Taille du texte du chat';
  @override
  String get chatWallpaper => 'Fond du chat';
  @override
  String get myMessageColor => 'Couleur de mes messages';
  @override
  String get otherMessageColor => 'Couleur des autres messages';
  @override
  String get notificationStyle => 'Style des notifications';
  @override
  String get standardNotificationStyle => 'Standard';
  @override
  String get blackRavenNotificationStyle => 'Corbeau noir';
  @override
  String get wallpaperUploadFailed => 'Impossible de téléverser le fond';
  @override
  String get showPopups => 'Afficher les notifications surgissantes';
  @override
  String get sound => 'Son';
  @override
  String get soundDesc => 'Jouer un son lors d\'un nouveau message';
  @override
  String get mainSettings => 'Paramètres principaux';
  @override
  String get energySavingMode => 'Mode économie d\'énergie';
  @override
  String get energySavingModeDesc =>
      'Optimise les performances pour économiser la batterie';
  @override
  String get autoSleep => 'Mode veille automatique';
  @override
  String get autoSleepDesc =>
      'Met l\'application en veille en cas d\'inactivité';
  @override
  String get animations => 'Animations';
  @override
  String get reducedMotion => 'Animations réduites';
  @override
  String get reducedMotionDesc =>
      'Réduit le nombre d\'animations dans l\'interface';
  @override
  String get comingSoon => 'Bientôt disponible';
  @override
  String get darkTheme => 'Thème sombre';
  @override
  String get version => 'Version';

  @override
  String get updateAvailable => 'Mise à jour disponible';
  @override
  String get clickToViewChanges => 'Cliquez pour voir les modifications';
  @override
  String get newVersionAvailable =>
      'Une nouvelle version de l\'application est disponible';
  @override
  String get newVersionAvailableTitle => 'Nouvelle version disponible';
  @override
  String get youHaveLatestVersion => 'Vous utilisez la dernière version';
  @override
  String get whatsNew => 'Quoi de neuf';
  @override
  String get officialReleaseNotes =>
      'Les notes de version officielles sont disponibles sur GitHub';
  @override
  String get preparingDownload => 'Préparation du téléchargement...';
  @override
  String get installationStarted => 'Installation démarrée...';
  @override
  String get whoSeesAvatar => 'Qui voit mon avatar';
  @override
  String get whoSeesBirthday => 'Qui voit mon anniversaire';
  @override
  String get whoSeesOnlineTime => 'Qui voit mon statut en ligne';

  @override
  String get downloadVersion => 'Télécharger';
  @override
  String get downloadSource => 'Source de téléchargement';
  @override
  String get directInAppInstall => 'Installation directe dans l\'application';
  @override
  String get autoDownloadAndRun => 'Téléchargement et lancement automatiques';
  @override
  String get githubReleasePage => 'Page de release sur GitHub';
  @override
  String get skip => 'Passer';
  @override
  String get updateAction => 'Mettre à jour';
  @override
  String get installAction => 'Installation...';
  @override
  String get isTyping => 'écrit...';
  @override
  String get isRecordingVoice => 'enregistre un message vocal...';
  @override
  String get areTyping => 'écrivent...';

  @override
  String membersCount(int count) =>
      count == 1 ? '$count membre' : '$count membres';
  @override
  String subscribersCount(int count) =>
      count == 1 ? '$count abonné' : '$count abonnés';

  @override
  String get group => 'Groupe';
  @override
  String get channel => 'Chaîne';

  @override
  String get profile => 'Profil';
  @override
  String get leaveGroup => 'Quitter le groupe';
  @override
  String get joinGroup => 'Rejoindre le groupe';
  @override
  String get unsubscribeChannel => 'Se désabonner de la chaîne';
  @override
  String get deleteChat => 'Supprimer le chat';
  @override
  String get pinChat => 'Épingler';
  @override
  String get unpinChat => 'Désépingler';
  @override
  String get muteNotifications => 'Désactiver les notifications';
  @override
  String get unmuteNotifications => 'Activer les notifications';
  @override
  String get backToChats => 'Retour aux chats';
  @override
  String get globalSearch => 'Recherche globale';
  @override
  String get chatSettings => 'Paramètres du chat';
  @override
  String get emoji => 'Émoji';
  @override
  String get attachFile => 'Joindre un fichier';
  @override
  String get startCall => 'Démarrer un appel';
  @override
  String get audioCall => 'Appel vocal';
  @override
  String get audioCallDesc => 'Appeler par voix';
  @override
  String get videoCall => 'Appel vidéo';

  @override
  String get copied => 'Copié';

  @override
  String get copy => 'Copier';
  @override
  String get userHidInfo => 'L\'utilisateur a masqué ses informations';
  @override
  String get subscribeChannel => 'S\'abonner à la chaîne';

  @override
  String get voiceRecordTitle => 'Enregistrement vocal';
  @override
  String get videoRecordTitle => 'Enregistrement vidéo';
  @override
  String get holdToRecordHint =>
      'Maintenez pour enregistrer\nAppuyez pour changer de mode';
  @override
  String get addAttachment => 'Ajouter une pièce jointe';
  @override
  String get emojiPanelInDev => 'Panneau émoji en développement';
  @override
  String get recordingVoice => 'Enregistrement vocal...';
  @override
  String get recordingVideo => 'Enregistrement vidéo...';
  @override
  String get releaseToSend => 'Relâchez pour envoyer';
  @override
  String get videoCallDesc => 'Appeler avec la caméra';

  @override
  String get typeMessage => 'Écrire un message...';
  @override
  String get file => 'Fichier';
  @override
  String get todoList => 'Liste de tâches';
  @override
  String get poll => 'Sondage';

  @override
  String get today => 'Aujourd\'hui';
  @override
  String get yesterday => 'Hier';
  @override
  String get monthJan => 'janvier';
  @override
  String get monthFeb => 'février';
  @override
  String get monthMar => 'mars';
  @override
  String get monthApr => 'avril';
  @override
  String get monthMay => 'mai';
  @override
  String get monthJun => 'juin';
  @override
  String get monthJul => 'juillet';
  @override
  String get monthAug => 'août';
  @override
  String get monthSep => 'septembre';
  @override
  String get monthOct => 'octobre';
  @override
  String get monthNov => 'novembre';
  @override
  String get monthDec => 'décembre';
  @override
  String get createTodo => 'CRÉER TO-DO';
  @override
  String get listName => 'Titre de la liste';
  @override
  String get todoItems => 'Éléments';
  @override
  String get addTodoItem => '+ Ajouter un élément';
  @override
  String get itemHintPrefix => 'Élément';
  @override
  String get createPoll => 'CRÉER UN SONDAGE';
  @override
  String get pollQuestion => 'Question';
  @override
  String get pollOptions => 'Options';
  @override
  String get addPollOption => '+ Ajouter une option';
  @override
  String get optionHintPrefix => 'Option';
  @override
  String get allowMultipleAnswers => 'Choix multiples';
  @override
  String get accountsTitle => 'COMPTES';
  @override
  String get addAccount => 'Ajouter un compte';
  @override
  String get accountLimitNotice => 'Limite de 5 comptes';

  @override
  String get singleChoice => 'Choix unique';

  @override
  String get media => 'Médias';
  @override
  String get files => 'Fichiers';
  @override
  String get voice => 'Vocal';
  @override
  String get links => 'Liens';

  @override
  String get bio => 'À propos';
  @override
  String get username => 'Nom d\'utilisateur';
  @override
  String get birthday => 'Date de naissance';
  @override
  String get noSharedMedia => 'Aucun média';
  @override
  String get noSharedFiles => 'Aucun fichier';
  @override
  String get noSharedVoice => 'Aucun message vocal';
  @override
  String get noSharedLinks => 'Aucun lien';

  @override
  String get savedMessagesDesc =>
      'Votre espace de stockage personnel pour notes, fichiers et messages';
  @override
  String get music => 'Musique';
  @override
  String get noSharedMusic => 'Aucune musique';
  @override
  String get secureDesktopCommunicator => 'messager informatique sécurisé';
  @override
  String get noMessagesTitle => 'Aucun message';
  @override
  String get noMessagesSubtitle =>
      'Envoyez un message pour démarrer la discussion sur Xaneo Connect !';

  @override
  String get qrScanTitle => 'Autorisation d\'appareil';
  @override
  String get qrScanSubtitle =>
      'Pointez votre caméra vers le code QR sur l\'écran du client Web ou PC Xaneo';
  @override
  String get qrScanSuccessTitle => 'Appareil autorisé';
  @override
  String get qrScanSuccessDesc =>
      'Autorisation réussie. Les clés de chiffrement de bout en bout (E2EE) ont été transférées vers le nouvel appareil.';
  @override
  String get qrScanInputHint => 'Coller le jeton ou les données...';
  @override
  String get qrScanPasteTooltip => 'Coller depuis le presse-papiers';
  @override
  String get qrScanConfirmButton => 'Confirmer l\'autorisation';
  @override
  String get qrScanProcessing => 'Autorisation de l\'appareil...';

  @override
  String get qrScanConfirmDesc =>
      'Un autre appareil demande l’accès à votre compte. Vérifiez le code court et confirmez la demande.';

  @override
  String get qrScanSecurityNote =>
      'Continuez uniquement si le code QR est affiché sur un appareil que vous contrôlez.';

  @override
  String get qrScanDoneButton => 'Terminé';

  @override
  String get authNotificationSendingCode => 'Envoi du code';

  @override
  String get authNotificationEnterCode => 'Entrez le code';

  @override
  String get authNotificationConfirmLogin => 'Confirmez la connexion';

  @override
  String get authNotificationPasswordLogin => 'Connexion par mot de passe';

  @override
  String get authNotificationSendingSubtitle =>
      'Le code arrivera dans la discussion « Notifications Xaneo ». Ne fermez pas cet écran.';

  @override
  String get authNotificationEnterCodeSubtitle =>
      'Entrez le code à 6 chiffres reçu dans le message.';

  @override
  String get authNotificationConfirmSubtitle =>
      'Ouvrez Xaneo sur un appareil déjà autorisé et vérifiez les détails de la demande.';

  @override
  String get authNotificationPasswordSubtitle =>
      'Cette méthode est disponible uniquement après un délai d\'attente. Le mot de passe n\'est pas enregistré.';

  @override
  String get authNotificationBotSource =>
      'Le code est envoyé par « Notifications Xaneo ».';

  @override
  String authNotificationCodeSentToEmail(String email) =>
      'Code envoyé à $email';

  @override
  String get authNotificationNoBotAccess => 'Pas d\'accès au bot ?';

  @override
  String get authNotificationGetCodeViaEmail => 'Recevoir le code par e-mail';

  @override
  String get authNotificationResendCodeViaEmail =>
      'Renvoyer le code par e-mail';

  @override
  String get authNotificationEmailUnavailable =>
      'Code par e-mail indisponible : aucun e-mail vérifié sur le compte.';

  @override
  String authNotificationEmailAvailableIn(int seconds) =>
      'Le code par e-mail sera disponible dans $seconds s.';

  @override
  String get authNotificationLoginWithPassword =>
      'Se connecter avec le mot de passe';

  @override
  String authNotificationPasswordAvailableIn(int seconds) =>
      'La connexion par mot de passe sera disponible dans $seconds s.';

  @override
  String get authNotificationErrorSendFailed =>
      'Échec de l\'envoi du code. Veuillez réessayer plus tard.';

  @override
  String get authNotificationErrorInvalidCode => 'Code invalide ou expiré';

  @override
  String get authNotificationErrorRequestExpired =>
      'Demande rejetée ou expirée';

  @override
  String get authNotificationErrorEmailFailed =>
      'Échec de l\'envoi du code par e-mail. Veuillez réessayer plus tard.';

  @override
  String get authNotificationErrorPasswordFailed =>
      'Échec de la connexion. Vérifiez votre mot de passe ou recommencez.';

  @override
  String get authNotificationGetCodeBtn => 'Obtenir le code';

  @override
  String get authRejectedTitle => 'Connexion refusée';

  @override
  String get authRejectedDesc =>
      'La demande de connexion a été refusée sur votre autre appareil. Si ce n\'était pas vous, nous vous recommandons de vérifier la sécurité de votre compte.';

  @override
  String get authRejectedButton => 'Compris';

  @override
  String get deviceAuthApprovalSubtitle =>
      'Code vérifié. Autorisez la connexion uniquement si vous avez initié cette demande.';

  @override
  String get deviceAuthApprovalKeysNotice =>
      'Les clés de discussion seront transférées vers le nouvel appareil sous forme chiffrée.';

  @override
  String get deviceAuthApprovalAllow => 'Autoriser la connexion';

  @override
  String get deviceAuthApprovalDecline => 'Refuser';

  @override
  String get deviceAuthDevice => 'Appareil';

  @override
  String get deviceAuthApp => 'Application';

  @override
  String get deviceAuthIp => 'Adresse IP';

  @override
  String get importLanguageFromJson =>
      'Importer une langue depuis un fichier JSON';
  @override
  String get customColor => 'Couleur personnalisée';
  @override
  String get customGradient => 'Dégradé personnalisé';
  @override
  String get colorOne => 'Couleur 1';
  @override
  String get colorTwo => 'Couleur 2';
  @override
  String get diagonal => 'Diagonal';
  @override
  String get vertical => 'Vertical';
  @override
  String get horizontal => 'Horizontal';
}
