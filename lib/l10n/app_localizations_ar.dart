import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Xaneo PC';

  @override
  String get welcomeTitle => 'مرحباً بك في Xaneo';

  @override
  String get welcomeDescription =>
      'تطبيق Xaneo أصبح الآن على جهاز الكمبيوتر الخاص بك! أقصى أداء وراحة.';

  @override
  String get getStartedButton => 'ابدأ الآن';

  @override
  String get privacyTitle => 'جميع بياناتك آمنة';

  @override
  String get privacyDescription =>
      'جميع الرسائل في Xaneo محمية بالتشفير بين الطرفين (E2EE).';

  @override
  String get continueButton => 'متابعة';

  @override
  String get dataStorageTitle => 'جميع مراكز بيانات Xaneo تقع في روسيا';

  @override
  String get dataStorageDescription =>
      'بياناتك لا تغادر البلاد مطلقًا وتُحفظ في مراكز بيانات آمنة.';

  @override
  String get finishButton => 'إنهاء';

  @override
  String get setupCompleted => 'اكتمل الإعداد!';

  @override
  String get loginFormTitle => 'تسجيل الدخول';

  @override
  String get loginFieldHint => 'اسم المستخدم';

  @override
  String get passwordFieldHint => 'كلمة المرور';

  @override
  String get loginButton => 'دخول';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get registerButton => 'إنشاء حساب';

  @override
  String get fillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get loggingIn => 'جاري تسجيل الدخول...';

  @override
  String welcomeUser(String username) => 'مرحباً، $username!';

  @override
  String get invalidCredentials =>
      'بيانات الاعتماد غير صحيحة. يرجى التحقق من اسم المستخدم وكلمة المرور.';

  @override
  String get serverError => 'خطأ في الخادم. يرجى المحاولة لاحقاً.';

  @override
  String get connectionError =>
      'خطأ في الاتصال. يرجى التحقق من اتصال الإنترنت.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsDescription => 'تفعيل أو تعطيل الإشعارات';

  @override
  String get darkThemeDescription => 'تفعيل أو تعطيل الوضع الداكن';

  @override
  String fontSize(int size) => 'حجم الخط: $size';

  @override
  String get language => 'اللغة';

  @override
  String get languageDescription => 'اختر لغة الواجهة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get registerTitle => 'التسجيل';

  @override
  String get registerStep0Title => 'ما اسمك؟';

  @override
  String get registerStep0Subtitle => 'أدخل اسمك الحقيقي';

  @override
  String get registerStep1Title => 'متى ولدت؟';

  @override
  String get registerStep1Subtitle => 'يجب أن يكون عمرك 14 عامًا على الأقل';

  @override
  String get registerStep2Title => 'اختر اسم مستخدم';

  @override
  String get registerStep2Subtitle => 'يجب أن يكون اسم المستخدم فريدًا';

  @override
  String get registerStep3Title => 'بريدك الإلكتروني';

  @override
  String get registerStep3Subtitle => 'سنرسل لك رمز التحقق';

  @override
  String get registerStep4Title => 'أنشئ كلمة مرور';

  @override
  String get registerStep4Subtitle => 'أنشئ كلمة مرور قوية';

  @override
  String get registerStep5Title => 'أضف صورة شخصية';

  @override
  String get registerStep5Subtitle => 'هذا اختياري ولكنه جميل';

  @override
  String get registerStep6Title => 'الخطوة الأخيرة';

  @override
  String get registerStep6Subtitle => 'وافق على شروط الاستخدام';

  @override
  String get yourName => 'اسمك';

  @override
  String get birthDate => 'تاريخ الميلاد';

  @override
  String get nickname => 'اسم المستخدم';

  @override
  String get checkingNickname => 'جاري التحقق من التوفر...';

  @override
  String get nicknameAvailable => 'اسم المستخدم متاح';

  @override
  String get nicknameTaken => 'اسم المستخدم مستخدم بالفعل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get addPhoto => 'اضغط لإضافة صورة';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get acceptTerms => 'أوافق على شروط الاستخدام';

  @override
  String get acceptDataProcessing => 'أوافق على معالجة البيانات الشخصية';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get finish => 'إنهاء';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get registrationSuccess => 'تم التسجيل بنجاح!';

  @override
  String get registrationError => 'خطأ في التسجيل';

  @override
  String get enterVerificationCode => 'أدخل رمز التحقق';

  @override
  String get invalidVerificationCode => 'رمز التحقق غير صحيح';

  @override
  String get codeSent => 'تم إرسال رمز التحقق إلى البريد الإلكتروني';

  @override
  String get sendCodeError => 'خطأ في إرسال الرمز';

  @override
  String get confirmEmail => 'تأكيد البريد الإلكتروني';

  @override
  String codeSentToEmail(String email) => 'لقد أرسلنا رمز التحقق إلى\n$email';

  @override
  String get verify => 'تحقق';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendIn(int count) => 'إعادة الإرسال خلال $count ثانية';

  @override
  String get acceptTermsRequired => 'يجب الموافقة على الشروط وسياسة البيانات';

  @override
  String get about => 'حول التطبيق';

  @override
  String get aboutDescription => 'تطبيق حديث لإدارة الأنظمة والاتصالات.';

  @override
  String get close => 'إغلاق';

  @override
  String get technicalInfo => 'المعلومات التقنية';

  @override
  String get platform => 'المنصة';

  @override
  String get architecture => 'معمارية المعالج';

  @override
  String get flutter => 'Flutter';

  @override
  String get viewOnGitHub => 'عرض على GitHub';

  @override
  String get chats => 'المحادثات';
  @override
  String get search => 'بحث';
  @override
  String get searchPlaceholder => 'البحث في الرسائل والمحادثات...';
  @override
  String get savedMessages => 'الرسائل المحفوظة';
  @override
  String get online => 'متصل';
  @override
  String get offline => 'غير متصل';
  @override
  String get lastSeenRecently => 'آخر ظهور قريباً';
  @override
  String get musicPlaylist => 'قائمة الموسيقى';
  @override
  String get reply => 'رد';
  @override
  String get edit => 'تعديل';
  @override
  String get pin => 'تثبيت';
  @override
  String get unpin => 'إلغاء التثبيت';
  @override
  String get delete => 'حذف';
  @override
  String get forward => 'إعادة توجيه';
  @override
  String get members => 'الأعضاء';
  @override
  String get noMessages => 'لا توجد رسائل بعد';

  @override
  String get joinedChat => 'انضم إلى المحادثة';
  @override
  String get leftChat => 'غادر المحادثة';
  @override
  String get subscribedChannel => 'اشترك في القناة';
  @override
  String get unsubscribedChannel => 'أغلق الاشتراك في القناة';
  @override
  String get invited => 'قام بدعوة';
  @override
  String get systemMessage => 'رسالة النظام';
  @override
  String get selectChatToStart => 'اختر محادثة لبدء التواصل';
  @override
  String get toArchive => 'أرشيف';
  @override
  String get unarchive => 'إلغاء الأرشفة';
  @override
  String get archive => 'الأرشيف';
  @override
  String get archiveEmpty => 'الأرشيف فارغ';
  @override
  String get voiceMessage => 'رسالة صوتية';
  @override
  String get videoMessage => 'رسالة فيديو';

  @override
  String get personalData => 'البيانات الشخصية';
  @override
  String get personalDataDesc => 'الاسم، اسم المستخدم، الصورة الشخصية';
  @override
  String get privacyDesc => 'من يمكنه مراسلتك والاتصال بك ورؤية ملفك';
  @override
  String get chatsSettings => 'إعدادات المحادثات';
  @override
  String get chatsSettingsDesc => 'الإشعارات، الثيمات، السجل';
  @override
  String get contacts => 'جهات الاتصال';
  @override
  String get contactsDesc => 'جهات الاتصال المحفوظة';
  @override
  String get security => 'الأمان';
  @override
  String get securityDesc => 'الجلسات، كلمة المرور، المصادقة';
  @override
  String get appearance => 'المظهر';
  @override
  String get appearanceDesc => 'السمة، الخط، قياس الواجهة';
  @override
  String get energySaving => 'توفير الطاقة';
  @override
  String get energySavingDesc => 'الرسوم المتحركة والأداء';

  @override
  String get account => 'الحساب';
  @override
  String get interface => 'الواجهة';
  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get basicInfo => 'المعلومات الأساسية';
  @override
  String get nicknameCannotBeChanged =>
      'لا يمكن تغيير اسم المستخدم داخل التطبيق';
  @override
  String get aboutMe => 'نبذة عني';
  @override
  String get aboutMeHint => 'اكتب نبذة عنك...';
  @override
  String get save => 'حفظ';
  @override
  String get saving => 'جاري الحفظ...';
  @override
  String get communications => 'الاتصالات';
  @override
  String get whoCanMessage => 'من يمكنه إرسال الرسائل';
  @override
  String get whoCanCall => 'من يمكنه الاتصال';
  @override
  String get whoCanRecordVoice => 'من يمكنه إرسال الرسائل الصوتية';
  @override
  String get whoCanSendFiles => 'من يمكنه إرسال الملفات';
  @override
  String get whoCanInvite => 'من يمكنه دعوتي للمجموعات';
  @override
  String get profileVisibility => 'خصوصية الملف الشخصي';
  @override
  String get whoSeesNickname => 'من يمكنه رؤية اسم المستخدم الخاص بي';
  @override
  String get everyone => 'الجميع';
  @override
  String get contactsOnly => 'جهات الاتصال فقط';
  @override
  String get nobody => 'لا أحد';
  @override
  String get addContact => 'إضافة';
  @override
  String get addContactTitle => 'إضافة جهة اتصال';
  @override
  String get userNicknameHint => 'اسم المستخدم للشخص';
  @override
  String get displayNameOptional => 'الاسم المعروض (اختياري)';
  @override
  String get noContactsYet => 'ليس لديك جهات اتصال محفوظة بعد';
  @override
  String get appInfo => 'معلومات التطبيق';
  @override
  String get checkUpdates => 'التحقق من التحديثات';
  @override
  String get checkingUpdates => 'جاري التحقق من التحديثات...';
  @override
  String get cancel => 'إلغاء';
  @override
  String get obnovlenie_7e32 => 'تحديث';
  @override
  String get obnovleniePrilozheniya_b6c3 => 'تحديث التطبيق';
  @override
  String get podgotovkaKZagruzke_a5c7 => 'جارٍ التحضير للتنزيل...';
  @override
  String get ustanovkaZapuschena_d378 => 'بدأ التثبيت!';
  @override
  String get dostupnaNovayaVersiyaPrilozheniya_eeae =>
      'النسخة الجديدة من التطبيق متاحة';
  @override
  String get chtoNovogo_74e2 => 'ما هو الجديد';
  @override
  String get ofitsialnoeOpisanieRelizaDostupnoNa_3ea3 =>
      'وصف الإصدار الرسمي متاح على صفحة GitHub.';
  @override
  String get istochnikZagruzki_0e6e => 'تنزيل المصدر';
  @override
  String get pryamayaUstanovkaVPrilozhenii_16f5 => 'التثبيت المباشر في التطبيق';
  @override
  String get avtomaticheskoeSkachivanieIZapusk_9a3f =>
      'التنزيل والتشغيل التلقائي';
  @override
  String get stranitsaRelizaNaGithub_1531 => 'صفحة الإصدار على جيثب';
  @override
  String get propustit_03ee => 'تخطي';
  @override
  String get ustanovka_516d => 'التثبيت...';
  @override
  String get obnovit_dbe5 => 'تحديث';
  @override
  String get lichnyeDannye_be85 => 'المعلومات الشخصية';
  @override
  String get imyaNikneymFotoProfilya_28ac => 'الاسم، اللقب، الصورة الشخصية';
  @override
  String get privatnost_0899 => 'الخصوصية';
  @override
  String get ktoMozhetPisatZvonitVidet_1789 =>
      'من يمكنه الكتابة والاتصال ورؤية الملف الشخصي';
  @override
  String get nastroykiChatov_7ca8 => 'إعدادات الدردشة';
  @override
  String get uvedomleniyaTemyIstoriya_51da => 'الإخطارات والموضوعات والتاريخ';
  @override
  String get kontakty_7576 => 'اتصالات';
  @override
  String get vashiSohranennyeKontakty_a641 => 'جهات الاتصال المحفوظة الخاصة بك';
  @override
  String get bezopasnost_3677 => 'الأمن';
  @override
  String get sessiiParolAutentifikatsiya_73f5 =>
      'الجلسات وكلمة المرور والمصادقة';
  @override
  String get vneshniyVid_6873 => 'المظهر';
  @override
  String get temaShriftMasshtab_d8c9 => 'الموضوع، الخط، الحجم';
  @override
  String get yazyk_0577 => 'اللغة';
  @override
  String get yazykInterfeysaKlienta_2ad3 => 'لغة واجهة العميل';
  @override
  String get uvedomleniya_d2ed => 'الإخطارات';
  @override
  String get zvukiBannery_1b60 => 'الأصوات واللافتات';
  @override
  String get energosberezhenie_0b19 => 'توفير الطاقة';
  @override
  String get animatsiiIProizvoditelnost_fba8 => 'الرسوم المتحركة والأداء';
  @override
  String get oPrilozhenii_322e => 'حول التطبيق';
  @override
  String get versiyaProverkaObnovleniySsylki_6efc =>
      'الإصدار، والتحقق من وجود تحديثات، والروابط';
  @override
  String get nastroyki_b01b => 'الإعدادات';
  @override
  String get nastroyki_c919 => 'الإعدادات';
  @override
  String get proverkaObnovleniy_f3e0 => 'جارٍ التحقق من وجود تحديثات...';
  @override
  String get neUdalosZagruzitNastroyki_f753 => 'فشل تحميل الإعدادات';
  @override
  String get oshibkaSohraneniya_0387 => 'خطأ في الحفظ';
  @override
  String get dannyeSohraneny_fd62 => 'تم حفظ البيانات';
  @override
  String get gost_9618 => 'ضيف';
  @override
  String get akkaunt_38ac => 'الحساب';
  @override
  String get interfeys_49be => 'واجهة';
  @override
  String get vyytiIzAkkaunta_6d41 => 'تسجيل الخروج من حسابك';
  @override
  String get informatsiyaOPrilozhenii_00c4 => 'معلومات التطبيق';

  @override
  String get proverka_13bc => 'جارٍ التحقق...';
  @override
  String get proveritObnovleniya_ab45 => 'التحقق من وجود تحديثات';
  @override
  String get osnovnayaInformatsiya_6fec => 'المعلومات الأساسية';
  @override
  String get imya_d38d => 'الاسم';
  @override
  String get vvediteVasheImya_751e => 'أدخل اسمك';
  @override
  @override
  String get nikneym_3fea => 'اسم المستخدم';
  @override
  String get nikneymNelzyaIzmenitVPrilozhenii_75d0 =>
      'لا يمكن تغيير اللقب في التطبيق';
  @override
  String get oSebe_0b3b => 'عني';
  @override
  String get rasskazhiteOSebe_1c37 => 'أخبرنا عن نفسك...';
  @override
  String get sohranenie_c15f => 'جارٍ الحفظ...';
  @override
  String get sohranit_74ea => 'حفظ';
  @override
  @override
  String get vse_984b => 'الكل';
  @override
  String get tolkoKontakty_a559 => 'جهات الاتصال فقط';
  @override
  String get nikto_ba19 => 'لا أحد';
  @override
  String get kommunikatsii_1242 => 'الاتصالات';
  @override
  String get ktoMozhetPisatSoobscheniya_4645 => 'من يستطيع كتابة الرسائل';
  @override
  String get ktoMozhetZvonit_c427 => 'من يمكنه الاتصال';
  @override
  String get ktoMozhetZapisyvatGolosovye_c69a => 'من يستطيع تسجيل الأصوات';
  @override
  String get ktoMozhetOtpravlyatFayly_2e40 => 'من يمكنه إرسال الملفات';
  @override
  String get ktoMozhetPriglashatVGruppy_cdc0 => 'من يمكنه الدعوة إلى المجموعات';
  @override
  String get vidimostProfilya_34bf => 'رؤية الملف الشخصي';
  @override
  String get ktoViditMoyNikneym_54b8 => 'من يرى لقبي';
  @override
  String get ktoViditMoyAvatar_e9f6 => 'من يرى الصورة الرمزية الخاصة بي';
  @override
  String get ktoViditMoyDenRozhdeniya_ccc7 => 'من يرى عيد ميلادي';
  @override
  String get ktoViditVremyaMoeyAktivnosti_4349 => 'من يرى وقت نشاطي';
  @override
  String get neUdalosZagruzitKontakty_02a3 => 'فشل تحميل جهات الاتصال';
  @override
  String get dobavitKontakt_4278 => 'أضف جهة اتصال';
  @override
  String get nikneymPolzovatelya_5610 => 'لقب المستخدم';
  @override
  String get otobrazhaemoeImyaOptsionalno_bbd1 => 'اسم العرض (اختياري)';
  @override
  @override
  String get otmena_987b => 'إلغاء';
  @override
  String get dobavit_5eba => 'أضف';
  @override
  String get uVasPokaNetSohranennyh_b64b =>
      'ليس لديك أية جهات اتصال محفوظة حتى الآن';
  @override
  String get pozvonit_ccfa => 'اتصل';
  @override
  String get napisat_0144 => 'اكتب';
  @override
  String get udalitKontakt_065d => 'حذف جهة الاتصال';
  @override
  String get soobscheniya_7e26 => 'الرسائل';
  @override
  String get animatsiiSoobscheniy_bc8b => 'الرسوم المتحركة للرسالة';
  @override
  String get pokazyvatAnimatsiiPriOtpravkeI_d663 =>
      'إظهار الرسوم المتحركة عند الإرسال والاستقبال';
  @override
  String get arhivirovannyeChaty_d990 => 'الدردشات المؤرشفة';
  @override
  String get upravlenieArhivom_e843 => 'إدارة الأرشيف';
  @override
  String get ochistitIstoriyu_837a => 'مسح التاريخ';
  @override
  String get udalitVseSoobscheniyaLokalno_fbbd => 'حذف جميع الرسائل محليا';
  @override
  String get aktivnyeSessii_5c96 => 'جلسات نشطة';
  @override
  String get etoUstroystvo_26f6 => 'هذا الجهاز';
  @override
  String get xaneoPcAktivnoSeychas_25b4 => 'Xaneo PC • نشط الآن';
  @override
  String get aktivno_87a4 => 'نشط';
  @override
  String get dvoynayaAutentifikatsiya_66ae => 'مصادقة مزدوجة';
  @override
  String get zaschitaAkkauntaOdnorazovymParolem_e9f1 =>
      'حماية الحساب بكلمة مرور لمرة واحدة';
  @override
  String get opasnayaZona_25bc => 'منطقة الخطر';
  @override
  String get udalitAkkaunt_05c7 => 'حذف الحساب';
  @override
  String get neobratimoeDeystvie_7232 => 'عمل لا رجعة فيه';
  @override
  String get tema_9e26 => 'الموضوع';
  @override
  String get temnayaTema_cb48 => 'موضوع مظلم';
  @override
  String get pereklyuchitMezhduTemnymISvetlym_5415 =>
      'التبديل بين الوضع الداكن والخفيف';
  @override
  String get razmerShrifta_1155 => 'حجم الخط';
  @override
  String get a_87a0 => 'أ';
  @override
  String get pokazyvatVsplyvayuschieUvedomleniya_754e =>
      'إظهار الإخطارات المنبثقة';
  @override
  String get zvuk_9329 => 'الصوت';
  @override
  String get vosproizvoditZvukPriNovomSoobschenii_47cc =>
      'تشغيل الصوت على الرسالة الجديدة';
  @override
  String get osnovnyeNastroyki_231c => 'الإعدادات الأساسية';
  @override
  String get rezhimEkonomiiEnergii_edfc => 'وضع توفير الطاقة';
  @override
  String get optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb =>
      'تحسين أداء التطبيق لحفظ الموارد';
  @override
  String get avtomaticheskiySpyaschiyRezhim_5955 => 'وضع السكون التلقائي';
  @override
  String get perevoditPrilozhenieVSpyaschiyRezhim_1c07 =>
      'يضع التطبيق في وضع السكون عندما يكون غير نشط';
  @override
  String get animatsii_05c7 => 'الرسوم المتحركة';
  @override
  String get uproschennyeAnimatsii_3a13 => 'الرسوم المتحركة المبسطة';
  @override
  String get umenshaetKolichestvoAnimatsiyInterfeysa_6bf1 =>
      'يقلل من عدد الرسوم المتحركة للواجهة';
  @override
  String get skoroBudetDostupno_de07 => 'قريبا';
  @override
  String get gostevoyRezhim_6d82 => 'وضع الضيف';
  @override
  String get voyditeDlyaDostupaKAkkauntu_a5c8 =>
      'تسجيل الدخول للوصول إلى حسابك';
  @override
  String get nazhmiteDlyaProsmotraIzmeneniy_0255 => 'انقر لعرض التغييرات';
  @override
  String get vvediteKodPodtverzhdeniya_61af => 'أدخل رمز التحقق';
  @override
  @override
  String get nevernyyKodPodtverzhdeniya_7762 => 'رمز التحقق غير صالحة';
  @override
  String get podtverditeEMail_4bd4 => 'قم بتأكيد بريدك الإلكتروني';
  @override
  String get proverit_340b => 'تحقق';
  @override
  @override
  String get otpravitKodPovtorno_7703 => 'إعادة إرسال الرمز';
  @override
  String get sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e =>
      'تطبيق سطح المكتب الحديث\nمع واجهة جميلة وتأثيرات ثلاثية الأبعاد';
  @override
  String get tehnologii_6332 => 'التقنيات';
  @override
  String get vyNashliPashalku_1a57 => '🎉 لقد وجدت بيضة عيد الفصح! 🎉';
  @override
  String get spasiboZaIspolzovanieXaneo_d079 => 'شكرا لاستخدام زانو!';
  @override
  String get globalnyyPoisk_77bf => 'بحث عالمي';
  @override
  @override
  String get poiskKontaktovChatovKanalovBotov_db66 =>
      'البحث عن جهات الاتصال، الدردشات، القنوات، البوتات...';
  @override
  @override
  String get lyudi_c7ae => 'الأشخاص';
  @override
  @override
  String get gruppy_ebc4 => 'المجموعات';
  @override
  @override
  String get kanaly_0c11 => 'القنوات';
  @override
  @override
  String get boty_d6e4 => 'البوتات';
  @override
  @override
  String get izbrannoe_2fc4 => 'الرسائل المحفوظة';
  @override
  @override
  String get vvediteZaprosDlyaPoiskaPo_9955 =>
      'أدخل الاستعلام للبحث في شبكة Xaneo';
  @override
  @override
  String get nichegoNeNaydeno_8767 => 'لم يتم العثور على نتائج';
  @override
  @override
  String get izbrannoe_b637 => 'الرسائل المحفوظة';
  @override
  @override
  String get boty_800d => 'البوتات';
  @override
  @override
  String get kanaly_ccec => 'القنوات';
  @override
  @override
  String get gruppy_cfd6 => 'المجموعات';
  @override
  @override
  String get polzovateli_e0ec => 'المستخدمون';
  @override
  @override
  String get sohranennyeSoobscheniya_6b62 => 'الرسائل المحفوظة';
  @override
  @override
  String get bot_0ae1 => 'بوت';
  @override
  @override
  String get bot_0f46 => 'bot';
  @override
  @override
  String get gruppa_99d9 => 'مجموعة';
  @override
  @override
  String get kanal_2710 => 'قناة';
  @override
  String get versiya_3725 => 'الإصدار';
  @override
  String get tehnicheskayaInformatsiya_ba0f => 'المعلومات الفنية';
  @override
  String get platforma_8848 => 'منصة';
  @override
  String get arhitekturaProtsessora_c079 => 'بنية المعالج';
  @override
  String get posmotretNaGithub_5238 => 'عرض على جيثب';
  @override
  String get zakryt_dd94 => 'إغلاق';
  @override
  String get vklyuchitTemnuyuTemu_ed17 => 'تمكين المظهر الداكن';
  @override
  String get vklyuchitUvedomleniya_d311 => 'تمكين الإخطارات';
  @override
  String get kastomnyyOverleyXaneo_7d39 => 'تراكب Xaneo مخصص';
  @override
  String get animirovannyeUvedomleniyaSBystrymOtvetom_a25d =>
      'إخطارات متحركة مع استجابة سريعة';
  @override
  String get aaBbVv_1c6b => 'أ ب ب ب';
  @override
  String get pleylist_a04c => 'قائمة التشغيل';
  @override
  String get spisokMuzyki_d477 => 'قائمة الموسيقى';
  @override
  String get loc_0B_5a4d => '0 ب';
  @override
  String get b_3b67 => 'ب';
  @override
  String get kb_419d => 'كيلو بايت';
  @override
  String get mb_b808 => 'ميغابايت';
  @override
  String get gb_e572 => 'غيغابايت';
  @override
  String get audiozapis_867d => 'تسجيل صوتي';
  @override
  String get muzykalnyyTrek_b15d => 'مسار الموسيقى';
  @override
  String get muzykalnyeTrekiOtsutstvuyut_3301 => 'لا توجد مقطوعات موسيقية';
  @override
  @override
  String get nikneymUzheZanyat_59aa => 'اسم المستخدم مستخدم بالفعل';
  @override
  @override
  String get oshibkaProverki_2ab0 => 'خطأ في التحقق';
  @override
  @override
  String get emailUzheZanyat_17e1 => 'البريد الإلكتروني مسجل بالفعل';
  @override
  @override
  String get oshibkaOtpravkiKoda_a42a => 'خطأ في إرسال رمز التحقق';
  @override
  @override
  String get neobhodimoPrinyatUsloviyaISoglasie_e31e =>
      'يجب عليك قبول شروط الاستخدام وسياسة الخصوصية';
  @override
  @override
  String get registratsiyaUspeshna_9d5c => 'تم التسجيل بنجاح!';
  @override
  @override
  String get oshibkaRegistratsii_b9f2 => 'خطأ في التسجيل';
  @override
  @override
  String get nazad_2b0b => 'رجوع';
  @override
  @override
  String get kakVasZovut_68b7 => 'ما هو اسمك؟';
  @override
  @override
  String get kogdaVyRodilis_26f2 => 'متى ولدت؟';
  @override
  @override
  String get pridumayteNikneym_221b => 'اختر اسم المستخدم';
  @override
  @override
  String get vashEmail_8bbd => 'بريدك الإلكتروني';
  @override
  @override
  String get podtverzhdenieEmail_281f => 'تأكيد البريد الإلكتروني';
  @override
  @override
  String get sozdayteParol_5f4c => 'أنشئ كلمة مرور';
  @override
  @override
  String get podtverzhdenieParolya_ebc2 => 'تأكيد كلمة المرور';
  @override
  @override
  String get dobavteFoto_25eb => 'أضف صورة';
  @override
  @override
  String get posledniyShag_e0c5 => 'الخطوة الأخيرة';
  @override
  @override
  String get vvediteVasheNastoyascheeImya_e656 => 'أدخل اسمك الحقيقي';
  @override
  @override
  String get vamDolzhnoBytNeMenee_1111 => 'يجب أن يكون عمرك 13 عامًا على الأقل';
  @override
  @override
  String get nikneymDolzhenBytUnikalnym_952d =>
      'يجب أن يكون اسم المستخدم فريدًا';
  @override
  @override
  String get myOtpravimKodPodtverzhdeniya_fc71 =>
      'سنرسل رمز التحقق إلى بريدك الإلكتروني';
  @override
  @override
  String get vvedite6ZnachnyyKodIz_f22f => 'أدخل الرمز المكون من 6 أرقام';
  @override
  @override
  String get pridumayteNadezhnyyParol_2312 =>
      'أنشئ كلمة مرور قوية (8 أحرف على الأقل)';
  @override
  @override
  String get povtoriteParolEscheRaz_6723 => 'كرر كلمة المرور مرة أخرى';
  @override
  @override
  String get etoNeobyazatelnoNoPriyatno_b6a3 => 'هذا اختياري ولكن يوصى به';
  @override
  @override
  String get proverteVashiDannyeIPrimite_3121 =>
      'راجع بياناتك ووافق على الشروط';
  @override
  @override
  String get registratsiya_0b93 => 'إنشاء حساب';
  @override
  @override
  String get vasheImya_51eb => 'اسمك';
  @override
  @override
  @override
  String get proverkaDostupnosti_da13 => 'جاري التحقق من التوفر...';
  @override
  @override
  @override
  String get nikneymDostupen_3fc9 => 'اسم المستخدم متاح';
  @override
  @override
  @override
  String get nikneymZanyat_8a5f => 'اسم المستخدم مستخدم بالفعل';
  @override
  @override
  @override
  String get emailDostupen_e903 => 'البريد الإلكتروني متاح';
  @override
  @override
  @override
  String get emailZanyat_fb40 => 'البريد الإلكتروني مستخدم بالفعل';
  @override
  @override
  String get kodPodtverzhdeniya_1c9d => 'رمز التحقق';
  @override
  @override
  String get parol_5ebe => 'كلمة المرور';
  @override
  @override
  String get podtverditeParol_e3e3 => 'تأكيد كلمة المرور';
  @override
  @override
  String get nazhmiteChtobyDobavitFoto_d6e8 => 'انقر لإضافة صورة';
  @override
  @override
  String get udalitFoto_3426 => 'حذف الصورة';
  @override
  @override
  String get yaPrinimayuUsloviyaIspolzovaniya_391a =>
      'أوافق على شروط الاستخدام';
  @override
  @override
  String get yaSoglasenNaObrabotkuPersonalnyh_f2a8 =>
      'أوافق على معالجة البيانات الشخصية';
  @override
  @override
  String get zavershit_b0e3 => 'إنهاء';
  @override
  @override
  String get dalee_c453 => 'التالي';
  @override
  @override
  String get dataRozhdeniya_505e => 'تاريخ الميلاد';
  @override
  String get vklyuchitTemnuyuTemuOformleniya_86c4 => 'تمكين المظهر الداكن';
  @override
  @override
  String get yanvar_ee86 => 'يناير';
  @override
  @override
  String get fevral_28ff => 'فبراير';
  @override
  @override
  String get mart_d766 => 'مارس';
  @override
  @override
  String get aprel_03e9 => 'أبريل';
  @override
  @override
  String get may_2e53 => 'مايو';
  @override
  @override
  String get iyun_cfcb => 'يونيو';
  @override
  @override
  String get iyul_89fb => 'يوليو';
  @override
  @override
  String get avgust_de5a => 'أغسطس';
  @override
  @override
  String get sentyabr_ebfb => 'سبتمبر';
  @override
  @override
  String get oktyabr_1720 => 'أكتوبر';
  @override
  @override
  String get noyabr_66fb => 'نوفمبر';
  @override
  @override
  String get dekabr_39b3 => 'ديسمبر';
  @override
  @override
  String get pn_2c1e => 'الإثنين';
  @override
  @override
  String get vt_7145 => 'الثلاثاء';
  @override
  @override
  String get sr_c6e4 => 'الأربعاء';
  @override
  @override
  String get cht_a51f => 'الخميس';
  @override
  @override
  String get pt_0123 => 'الجمعة';
  @override
  @override
  String get sb_3a4b => 'السبت';
  @override
  @override
  String get vs_4ad9 => 'الأحد';
  @override
  @override
  String get gotovo_34e1 => 'تم';
  @override
  String get oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b =>
      'خطأ في استرداد المفتاح (فشلت الكتابة فوقه)';
  @override
  String get kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7 =>
      'خطأ فادح عند إعادة إنشاء مفاتيح التشفير';
  @override
  String get oshibkaZagruzkiKlyucheyNaServer_ff9b =>
      'حدث خطأ أثناء تحميل المفاتيح إلى الخادم';
  @override
  String get oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4 =>
      'حدث خطأ أثناء استرداد مفاتيح التشفير';
  @override
  String get prevyshenLimitV5Akkauntov_a6a9 =>
      'تم تجاوز الحد الأقصى لعدد الحسابات على هذا العميل وهو 5 حسابات أو يوجد خطأ في الاتصال.';
  @override
  @override
  @override
  String get oshibkaAvtorizatsii_9f5c => 'خطأ في المصادقة';
  @override
  @override
  @override
  String get oshibkaPodklyucheniyaKServeru_8b96 => 'خطأ في الاتصال بالخادم';
  @override
  @override
  String get nazadKMessendzheru_de29 => 'العودة إلى تطبيق المراسلة';
  @override
  @override
  String get voytiVAkkaunt_c439 => 'تسجيل الدخول إلى الحساب';
  @override
  @override
  String get vvediteParol_1370 => 'أدخل كلمة المرور';
  @override
  @override
  String get vvediteSvoiDannyeDlyaDostupa_319e =>
      'أدخل بيانات الاعتماد الخاصة بك للوصول إلى الرسائل.';
  @override
  @override
  String get voyti_63a7 => 'تسجيل الدخول';
  @override
  String get sobesednik_7025 => 'المحاور';
  @override
  String get vy_0101 => 'أنت';
  @override
  String get vyDelitesSvoimEkranom_16b1 => 'يمكنك مشاركة الشاشة الخاصة بك';
  @override
  String get polzovatel_f154 => 'المستخدم';
  @override
  String get ishodyaschiyVyzov_650b => 'مكالمة صادرة...';
  @override
  String get vhodyaschiyVyzov_19ff => 'مكالمة واردة...';
  @override
  String get podklyucheno_d022 => 'متصل';
  @override
  String get ozhidanieOtveta_a984 => 'في انتظار الرد...';
  @override
  String get razgovorPoAudiosvyazi_3ed7 => 'محادثة صوتية';
  @override
  String get translyatsiyaVashegoEkranaZapuschena_575a =>
      'لقد بدأ تسجيل الشاشة الخاص بك';
  @override
  String get sobesednikViditVseChtoProishodit_c759 =>
      'يرى المحاور كل ما يحدث على سطح المكتب الخاص بك';
  @override
  String get vhodyaschiyVyzov_905e => 'مكالمة واردة';
  @override
  String get neizvestnyy_be89 => 'غير معروف';
  @override
  String get videozvonok_dd18 => 'مكالمة فيديو...';
  @override
  String get golosovoyZvonok_5410 => 'مكالمة صوتية...';
  @override
  String get otklonit_8b0d => 'رفض';
  @override
  String get otvetit_e568 => 'رد';
  @override
  String get gruppovoyZvonok_dac1 => 'مكالمة جماعية';
  @override
  String get podklyuchenieKZvonku_e2cf => 'جارٍ الاتصال بمكالمة...';
  @override
  String get podklyuchenieKVeschaniyu_038b => 'جارٍ الاتصال بالبث...';
  @override
  String get uchastnik_cffb => 'عضو';
  @override
  String get vy_479c => 'أنت';
  @override
  String get svernut_ca9f => 'طي';
  @override
  String get vhodyaschiyVyzov_d2f3 => 'مكالمة واردة';
  @override
  String get novoeSoobschenie_1d49 => 'رسالة جديدة';
  @override
  String get vashOtvet_40c2 => 'إجابتك...';
  @override
  String get videovyzov_3353 => 'مكالمة فيديو...';
  @override
  String get audiovyzov_bbb5 => 'مكالمة صوتية...';
  @override
  String get nachatZvonok_3d26 => 'ابدأ المكالمة';
  @override
  String get golosovoyZvonok_b615 => 'مكالمة صوتية';
  @override
  String get pozvonitPoGolosovoySvyazi_4069 => 'إجراء مكالمة صوتية';
  @override
  String get videozvonok_8142 => 'مكالمة فيديو';
  @override
  String get pozvonitSVklyuchennoyKameroy_fb05 =>
      'الاتصال بالكاميرا قيد التشغيل';
  @override
  String get zashifrovannoeSoobschenie_ca35 => '[رسالة مشفرة]';
  @override
  String get golosovoeSoobschenie_4a85 => '🎤 رسالة صوتية';
  @override
  String get videosoobschenie_d687 => '🎬 رسالة فيديو';
  @override
  String get fayl_826d => '📎 ملف';
  @override
  String get zvonok_e8d5 => '📞 اتصل';
  @override
  String get oshibkaDeshifrovaniya_4146 => '[خطأ في فك التشفير]';
  @override
  String get zapisyvaetGolosovoe_2a5c => 'يسجل صوت...';
  @override
  String get pechataet_812c => 'مطبوعات...';
  @override
  String get neUdalosArhivirovatChat_ab89 => 'فشل في أرشفة الدردشة';
  @override
  String get neUdalosRazarhivirovatChat_f0d7 => 'فشل في إلغاء أرشفة الدردشة';
  @override
  String get arhiv_56aa => 'أرشيف';
  @override
  String get netUserid_634a => '[لا يوجد معرف مستخدم]';
  @override
  String get netKlyucha_337b => '[لا يوجد مفتاح]';
  @override
  String get neizvestnyyTipChata_2617 => '[نوع الدردشة غير معروف]';
  @override
  String get neUdalosPoluchitKlyuchShifrovaniya_b953 =>
      'فشل الحصول على مفتاح التشفير للدردشة';
  @override
  String get gruppa_19c2 => 'مجموعة';
  @override
  String get uchastnik_5bce => 'مشارك';
  @override
  String get uchastnika_92d9 => 'مشارك';
  @override
  String get uchastnikov_5d6b => 'المشاركين';
  @override
  String get kanal_64ec => 'قناة';
  @override
  String get podpischik_695a => 'مشترك';
  @override
  String get podpischika_b490 => 'مشترك';
  @override
  String get podpischikov_ba39 => 'المشتركين';
  @override
  String get segodnya_9626 => 'اليوم';
  @override
  String get vchera_61d4 => 'أمس';
  @override
  String get yanvarya_d861 => 'يناير';
  @override
  String get fevralya_fcf9 => 'فبراير';
  @override
  String get marta_bb77 => 'مارس';
  @override
  String get aprelya_2b5a => 'أبريل';
  @override
  String get maya_4dbb => 'مايو';
  @override
  String get iyunya_adcb => 'يونيو';
  @override
  String get iyulya_3236 => 'يوليو';
  @override
  String get avgusta_e3aa => 'أغسطس';
  @override
  String get sentyabrya_a146 => 'سبتمبر';
  @override
  String get oktyabrya_7abd => 'أكتوبر';
  @override
  String get noyabrya_6e78 => 'نوفمبر';
  @override
  String get dekabrya_29cc => 'ديسمبر';
  @override
  String get vyPodpisalisNaKanal_b2b3 => 'لقد اشتركت في القناة';
  @override
  String get vyPrisoedinilisKGruppe_07bd => 'لقد انضممت إلى المجموعة';
  @override
  String get neUdalosPrisoedinitsya_31e6 => 'فشل الانضمام';
  @override
  String get vyOtpisalisOtKanala_7698 => 'لقد ألغيت اشتراكك في القناة';
  @override
  String get vyPokinuliGruppu_5a52 => 'لقد تركت المجموعة';
  @override
  String get neUdalosVypolnitDeystvie_3cfd => 'فشل الإجراء';
  @override
  String get neUdalosPereklyuchitAkkaunt_968b => 'فشل في تبديل الحساب';
  @override
  String get media_c247 => 'وسائل الإعلام';
  @override
  String get fayly_200c => 'ملفات';
  @override
  String get golos_2d89 => 'صوت';
  @override
  String get ssylki_9f58 => 'روابط';
  @override
  String get profil_c62a => 'الملف الشخصي';
  @override
  String get imyaPolzovatelya_6fd4 => 'اسم المستخدم';
  @override
  String get denRozhdeniya_e41d => 'عيد ميلاد';
  @override
  String get polzovatelSkrylInformatsiyuOSebe_f416 =>
      'قيام المستخدم بإخفاء معلومات عن نفسه';
  @override
  String get god_6270 => 'سنة';
  @override
  String get goda_7443 => 'سنة';
  @override
  String get let_257a => 'سنوات';
  @override
  String get skopirovano_f70b => 'منقول';
  @override
  String get akkaunty_80b5 => 'الحسابات';
  @override
  String get dobavitAkkaunt_5253 => 'إضافة حساب';
  @override
  String get limit5Akkauntov_fdb7 => 'الحد: 5 حسابات';
  @override
  String get nazadKChatam_7edb => 'العودة إلى الدردشات';
  @override
  String get chaty_19ad => 'الدردشات';
  @override
  String get globalnyyPoisk_7ff2 => 'بحث عالمي';
  @override
  String get arhivPust_3e22 => 'الأرشيف فارغ';
  @override
  String get netSoobscheniy_29d4 => 'لا توجد رسائل';
  @override
  String get toDoList_27e1 => '📋 ورقة المهام';
  @override
  String get opros_6ff1 => '🗳️ استطلاع';
  @override
  String get fotografiya_5709 => '📷 تصوير';
  @override
  String get razarhivirovat_416b => 'بفك';
  @override
  String get vArhiv_ce22 => 'إلى الأرشيف';
  @override
  String get chat_c52b => 'الدردشة';
  @override
  String get vyberiteChatDlyaNachalaObscheniya_36a5 => 'حدد دردشة لبدء الدردشة';
  @override
  String get bot_2712 => 'بوت';
  @override
  String get vSeti_d902 => 'على الانترنت';
  @override
  String get neVSeti_ee01 => 'غير متصل';
  @override
  String get nastroykiChata_1e0d => 'إعدادات الدردشة';
  @override
  String get pokinutGruppu_e6ce => 'مغادرة المجموعة';
  @override
  String get prisoedinitsyaKGruppe_eb45 => 'انضم إلى المجموعة';
  @override
  String get otpisatsyaOtKanala_fdbc => 'إلغاء الاشتراك من القناة';
  @override
  String get podpisatsyaNaKanal_2dad => 'اشترك في القناة';
  @override
  String get netSoobscheniyNapishiteChtoNibud_2bf4 =>
      'لا توجد رسائل بعد. اكتب شيئاً!';
  @override
  String get prisoedinilsyaKChatu_f623 => 'انضم إلى الدردشة';
  @override
  String get pokinulChat_d567 => 'غادر الدردشة';
  @override
  String get podpisalsyaNaKanal_0673 => 'اشتركت في القناة';
  @override
  String get otpisalsyaOtKanala_fa13 => 'تم إلغاء الاشتراك من القناة';
  @override
  String get polzovatelya_1083 => 'user';
  @override
  String get priglasil_47ae => 'مدعو';
  @override
  String get rasshifrovka_e47f => '[نسخة...]';
  @override
  String get sistemnoeSoobschenie_d2bd => 'رسالة النظام';
  @override
  String get soobschenie_3715 => 'رسالة';
  @override
  String get videosoobschenie_57f1 => '📹 رسالة فيديو';
  @override
  String get spisokZadach_cfa4 => '📋 قائمة المهام';
  @override
  String get opros_5902 => '📊 استطلاع';
  @override
  String get vlozhenie_ef44 => 'مرفق';
  @override
  String get fayl_2d46 => 'ملف';
  @override
  String get zagruzkaFayla_f817 => 'جارٍ تحميل الملف...';
  @override
  String get ishodyaschiyZvonok_8381 => 'مكالمة صادرة';
  @override
  String get razgovorNeSostoyalsya_67fb => 'المحادثة لم تتم';
  @override
  String get vhodyaschiyZvonok_5ce9 => 'مكالمة واردة';
  @override
  String get otklonennyyZvonok_d499 => 'مكالمة مرفوضة';
  @override
  String get vyOtkloniliVyzov_8d1d => 'لقد رفضت المكالمة';
  @override
  String get propuschennyyZvonok_e98d => 'مكالمة فائتة';
  @override
  String get vyPropustiliVyzov_f17a => 'لقد فاتتك المكالمة';
  @override
  String get vlozhenie_2474 => '📎 مرفق';
  @override
  String get tb_0e05 => 'السل';
  @override
  String get zapisGolosovogo_9c91 => 'تسجيل صوتي...';
  @override
  String get zapisVideo_dd2a => 'تسجيل فيديو...';
  @override
  String get otpustiteDlyaOtpravki_ea7b => 'الافراج عن إرسال';
  @override
  String get emodzi_f822 => 'الرموز التعبيرية';
  @override
  String get panelEmodziVRazrabotke_b6ce => 'لوحة الرموز التعبيرية قيد التطوير';
  @override
  String get napisatSoobschenie_62d4 => 'أكتب رسالة...';
  @override
  String get dobavitVlozhenie_769b => 'إضافة مرفق';
  @override
  String get spisokZadach_1852 => 'قائمة المهام';
  @override
  String get opros_9f36 => 'استطلاع';
  @override
  String get zapisGolosovogoGs_db4e => 'تسجيل صوتي (VO)';
  @override
  String get zapisVideoVs_9676 => 'تسجيل الفيديو (VS)';
  @override
  String get uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3 =>
      '• اضغط على الزر للتسجيل\n• اضغط لتبديل الوضع';
  @override
  @override
  String get novyyChat_f775 => 'محادثة جديدة';
  @override
  @override
  String get imyaPolzovatelyaMin5Simvolov_1232 =>
      'اسم المستخدم (5 أحرف على الأقل)';
  @override
  @override
  String get vvedite5IliBoleeSimvolov_f983 => 'أدخل 5 أحرف أو أكثر';
  @override
  @override
  String get polzovateliNeNaydeny_c01a => 'لم يتم العثور على مستخدمين';
  @override
  String get mnozhestvennyyVybor_9b60 => 'الاختيار من متعدد';
  @override
  String get odinochnyyVybor_d920 => 'اختيار واحد';
  @override
  String get netGolosov_17d0 => 'لا أصوات';
  @override
  String get golos_6b94 => 'صوت';
  @override
  String get golosa_bb8d => 'أصوات';
  @override
  String get golosov_7f51 => 'الأصوات';
  @override
  String get nePoluchenIdFaylaOt_86c8 => 'لم يتم استلام معرف الملف من الخادم';
  @override
  String get faylZagruzhenIPrikreplen_dc24 => 'تم تحميل الملف وإرفاقه';
  @override
  String get neizvestnayaOshibkaZagruzki_68cb => 'خطأ غير معروف في التحميل';
  @override
  String get oshibkaZagruzkiFayla_86e5 => 'خطأ في تنزيل الملف';
  @override
  String get sohranitFaylKak_0f93 => 'احفظ الملف باسم';
  @override
  String get oshibkaSkachivaniyaFayla_34ac => 'خطأ في تنزيل الملف';
  @override
  String get bezNazvaniya_6584 => 'بدون عنوان';
  @override
  String get bezVoprosa_d390 => 'لا شك';
  @override
  String get netDostupaKMikrofonu_a4ef => 'لا يوجد وصول للميكروفون';
  @override
  String get zapisVideoCherezPlaginCamera_b9dd =>
      '📹 بدأ تسجيل الفيديو عبر البرنامج المساعد للكاميرا';
  @override
  String get kameraNeInitsializirovanaNaEtoy_21e0 =>
      '📹 لم تتم تهيئة الكاميرا على هذه المنصة.';
  @override
  String get kameraNeGotova_9f09 => 'الكاميرا غير جاهزة';
  @override
  String get zapisVideosoobscheniyaNaEtoyPlatforme_a561 =>
      '📹 تسجيل رسائل الفيديو غير متاح مباشرة على هذه المنصة.';
  @override
  String get arecordOstanovlen_edf2 => '🎙️ تم إيقاف التسجيل';
  @override
  String get ffmpegOstanovlen_63a0 => '📹 توقف ffmpeg';
  @override
  String get zapisSlishkomKorotkaya_5cda => 'الإدخال قصير جدًا';
  @override
  String get oshibkaZapisiFaylPust_106b => 'خطأ في الكتابة: الملف فارغ';
  @override
  String get videosoobschenieOtpravlenoSimulyatsiya_fb29 =>
      'تم إرسال رسالة فيديو (محاكاة)';
  @override
  String get zapisOtmenena_1609 => 'تم إلغاء التسجيل';
  @override
  String get otpravitGolosovoeSoobschenie_2481 => 'إرسال رسالة صوتية';
  @override
  String get imitatsiyaZapisiGolosovogoSoobscheniya_81e7 =>
      'محاكاة تسجيل رسالة صوتية.';
  @override
  String get otpravit_6da0 => 'أرسل';
  @override
  String get sozdatToDo_8c92 => 'إنشاء المهام';
  @override
  String get nazvanieSpiska_c3cc => 'اسم القائمة';
  @override
  String get punkty_0481 => 'العناصر:';
  @override
  String get dobavitPunkt_930c => 'إضافة عنصر';
  @override
  String get sozdat_b059 => 'إنشاء';
  @override
  String get sozdatOpros_4b9e => 'إنشاء استطلاع';
  @override
  String get vopros_0911 => 'سؤال';
  @override
  String get variantyOtveta_ef4e => 'خيارات الإجابة:';
  @override
  String get dobavitVariant_76be => 'إضافة خيار';
  @override
  String get golosovoeSoobschenie_33d5 => 'رسالة صوتية';
  @override
  String get videosoobschenie_2951 => 'رسالة فيديو';
  @override
  String get video_a095 => 'فيديو';
  @override
  String get neUdalosZagruzitIzobrazhenie_3fa0 => 'فشل تحميل الصورة';
  @override
  String get muzyka_0660 => 'موسيقى';
  @override
  String get netDannyh_dee9 => 'لا توجد بيانات';
  @override
  String get istoriyaSoobscheniyPustaIliChat_2d07 =>
      'سجل الرسائل فارغ أو لم يتم حفظ الدردشة محليًا بعد';
  @override
  String get obschieMaterialy_11e4 => 'مواد عامة';
  @override
  String get netMediafaylov_08d2 => 'لا توجد ملفات الوسائط';
  @override
  String get zdesBudutOtobrazhatsyaObschieFoto_9bc7 =>
      'سيتم عرض الصور ومقاطع الفيديو المشتركة هنا';
  @override
  String get netFaylov_e95e => 'لا توجد ملفات';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c =>
      'سيتم عرض الملفات التي تم تحميلها هنا';
  @override
  String get netGolosovyhSoobscheniy_2427 => 'لا توجد رسائل صوتية';
  @override
  String get zdesBudutOtobrazhatsyaGolosovyeI_0a73 =>
      'سيتم عرض الرسائل الصوتية والفيديو هنا';
  @override
  String get netSsylok_b0ec => 'لا توجد روابط';
  @override
  String get zdesBudutOtobrazhatsyaObschieSsylki_6b61 =>
      'سوف تظهر الروابط العامة هنا';
  @override
  String get ssylkaSkopirovanaVBufer_c16e => 'تم نسخ الرابط إلى الحافظة';
  @override
  String get netMuzyki_1ca3 => 'لا موسيقى';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23 =>
      'سيتم عرض المسارات المقدمة هنا';
  @override
  String get udalennyyAkkaunt_ce47 => 'الحساب المحذوف';
  @override
  String get opisanie_38ca => 'الوصف';
  @override
  String get mobilnyy_5ac7 => 'الجوال';
  @override
  String get bylANedavno_168d => 'كان مؤخرا';
  @override
  String get minutu_5373 => 'دقيقة';
  @override
  String get minuty_5bc9 => 'دقائق';
  @override
  String get minut_b877 => 'دقائق';
  @override
  String get nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a =>
      'انقر لتنزيل الإصدار الجديد';
  @override
  String get poiskLyudeyBotovGrupp_e84e =>
      'البحث عن الأشخاص والروبوتات والمجموعات...';
  @override
  String get vveditePoiskovyyZapros_0b8c => 'أدخل مصطلح البحث الخاص بك';
  @override
  String get polzovateli_b8c4 => 'المستخدمين';
  @override
  String get moiLichnyeSoobscheniya_7d3b => 'رسائلي الشخصية';
  @override
  String get sozdatNovyyChat_fd41 => 'إنشاء دردشة جديدة';
  @override
  String get lichnyyChat_cbec => 'الدردشة الشخصية';
  @override
  String get nachatObschenieSPolzovatelem_0578 => 'ابدأ محادثة مع مستخدم';
  @override
  String get sozdatGruppu_459f => 'إنشاء مجموعة';
  @override
  String get gruppovoyChatDlyaObscheniyaS_01ba =>
      'دردشة جماعية للتواصل مع الأصدقاء';
  @override
  String get sozdatKanal_9022 => 'إنشاء قناة';
  @override
  String get kanalDlyaShirokoyAuditorii_9dba => 'قناة لجمهور واسع';
  @override
  String get redaktirovanie_1167 => 'التحرير';
  @override
  String get vlevo_1af1 => 'اليسار';
  @override
  String get vpravo_c316 => 'صحيح';
  @override
  String get poGor_ff50 => 'على طول الجبال';
  @override
  String get poVert_b4a9 => 'فير.';
  @override
  String get vvediteNazvanieGruppy_0a69 => 'أدخل اسم المجموعة';
  @override
  String get dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0 =>
      'تتطلب المجموعة العامة لقبًا (@اسم المستخدم)';
  @override
  String get gruppaSozdana_6b3b => 'تم إنشاء المجموعة';
  @override
  String get oshibkaPriSozdaniiGruppy_794e => 'حدث خطأ أثناء إنشاء المجموعة';
  @override
  String get nazhmiteNaIkonkuChtobyVybrat_af03 =>
      'انقر على الأيقونة لتحديد الصورة الرمزية';
  @override
  String get nazvanieGruppy_9a39 => 'اسم المجموعة';
  @override
  String get opisanieNeobyazatelno_7812 => 'الوصف (اختياري)';
  @override
  String get privatnayaGruppa_d20e => 'مجموعة خاصة';
  @override
  String get publichnayaGruppa_50f8 => 'مجموعة عامة';
  @override
  String get vhodTolkoPoPriglasheniyu_97a1 => 'الدخول عن طريق الدعوة فقط';
  @override
  String get lyuboyMozhetNaytiIVstupit_5e26 => 'يمكن لأي شخص البحث والانضمام';
  @override
  String get publichnayaSsylkanikneymMyGroup_6640 =>
      'الرابط العام/الاسم المستعار (@my_group)';
  @override
  String get vvediteNazvanieKanala_5536 => 'أدخل اسم القناة';
  @override
  String get dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06 =>
      'تتطلب القناة العامة رابطًا/اسمًا مستعارًا (@mychannel)';
  @override
  String get kanalSozdan_1522 => 'تم إنشاء القناة';
  @override
  String get oshibkaPriSozdaniiKanala_7d4b => 'حدث خطأ أثناء إنشاء القناة';
  @override
  String get nazvanieKanala_c548 => 'اسم القناة';
  @override
  String get privatnyyKanal_3139 => 'قناة خاصة';
  @override
  String get publichnyyKanal_0f7c => 'قناة عامة';
  @override
  String get podpiskaTolkoPoPriglasheniyu_99c3 => 'الاشتراك عن طريق الدعوة فقط';
  @override
  String get lyuboyMozhetNaytiIPodpisatsya_8579 =>
      'يمكن لأي شخص العثور على والاشتراك';
  @override
  String get ssylkanikneymKanalaMychannel_79f6 =>
      'رابط القناة/الاسم المستعار (@mychannel)';
  @override
  String get yazykInterfeysa_b78b => 'لغة الواجهة';
  @override
  String get dannyeUspeshnoSohraneny_2cc5 => 'تم حفظ البيانات بنجاح';
  @override
  String get oshibkaPriSohranenii_126f => 'حدث خطأ أثناء الحفظ';
  @override
  String get lichnyeDannye_10a7 => 'البيانات الشخصية';
  @override
  String get nikneymUsername_8035 => 'الاسم المستعار (@اسم المستخدم)';
  @override
  String get nikneymNelzyaIzmenit_0b99 => 'لا يمكن تغيير اللقب';
  @override
  String get oSebeBio_b730 => 'عني (السيرة الذاتية)';
  @override
  String get rasskazhiteNemnogoOSebe_3daa => 'أخبرنا قليلاً عن نفسك...';
  @override
  String get nastroykiPrivatnostiSohraneny_447c => 'تم حفظ إعدادات الخصوصية';
  @override
  String get privatnost_3098 => 'الخصوصية';
  @override
  String get kommunikatsii_e9b8 => 'الاتصالات';
  @override
  String get ktoMozhetPisat_3322 => 'من يستطيع الكتابة';
  @override
  String get zapisGolosovyh_8073 => 'تسجيل صوتي';
  @override
  String get otpravkaFaylov_aaca => 'إرسال الملفات';
  @override
  String get priglashatVGruppy_3631 => 'دعوة إلى المجموعات';
  @override
  String get vidimostProfilya_448f => 'رؤية الملف الشخصي';
  @override
  String get ktoViditAvatar_b5d8 => 'من يرى الصورة الرمزية';
  @override
  String get vremyaVSeti_be29 => 'الوقت على الانترنت';
  @override
  String get vneshniyVid_5a0f => 'المظهر';
  @override
  String get rezhimOformleniyaInterfeysa_b91d => 'وضع تصميم الواجهة';
  @override
  String get pokazyvatVizualnyeEffektyIPerehody_3fd7 =>
      'عرض المؤثرات البصرية والانتقالات';
  @override
  String get razmerTeksta_3c4f => 'حجم النص';
  @override
  String get bezopasnost_fcbc => 'الأمن';
  @override
  String get dvuhfaktornayaAutentifikatsiya_acdc => 'المصادقة الثنائية';
  @override
  String get zaschitaAkkaunta2fa_f1ab => 'حماية حساب 2FA';
  @override
  String get vklyucheno_6b96 => 'متضمنة';
  @override
  String get xaneoMobileAktivnoSeychas_3345 => 'Xaneo Mobile • نشط الآن';
  @override
  String get zaschischennyyMessendzher_2f59 => 'رسول آمن';
  @override
  String get temnayaTema_6018 => 'موضوع مظلم';
  @override
  String get vklyuchenaPoUmolchaniyu_7610 => 'ممكّن (افتراضي)';
  @override
  String get setevoyFiltr_40c2 => 'مرشح الطفرة';
  @override
  String get vklyuchen_0994 => 'ممكّن';
  @override
  String get spisokMuzyki_57d0 => 'قائمة الموسيقى';
  @override
  String get trek_5049 => 'المسار';
  @override
  String get trekov_d3f4 => 'المسارات';
  @override
  String get pozhaluystaZapolniteVoprosIKak_7ad5 =>
      'يرجى ملء السؤال وخيارين للإجابة على الأقل';
  @override
  String get sozdatOpros_8401 => 'إنشاء استطلاع';
  @override
  String get sozdatSpisokZadach_4018 => 'إنشاء قائمة المهام';
  @override
  String get pozhaluystaZapolniteNazvanieIKak_3783 =>
      'يرجى ملء العنوان وعنصر واحد على الأقل';
  @override
  String get sozdatSpisokZadach_0416 => 'إنشاء قائمة المهام';
  @override
  String get vhodyaschiyVideozvonok_14d4 => 'مكالمة فيديو واردة';
  @override
  String get prinyat_5dc5 => 'قبول';
  @override
  String get netObschihFaylov_bf77 => 'لا توجد ملفات مشتركة';
  @override
  String get neUdalosRazarhivirovatChatNa_b6f6 =>
      'فشل في إلغاء أرشفة الدردشة على الخادم';
  @override
  String get poiskVArhive_c5d8 => 'البحث في الأرشيف...';
  @override
  String get poprobuyteIzmenitZapros_52ea => 'حاول تغيير طلبك';
  @override
  String get zdesBudutNahoditsyaVashiArhivirovannye_7359 =>
      'سيتم وضع محادثاتك المؤرشفة هنا';
  @override
  String get vernut_54aa => 'العودة';
  @override
  String get zashifrovannoeSoobschenie_c9ab => 'رسالة مشفرة';
  @override
  String get soobschenieNahoditsyaVysheVIstorii_dc90 =>
      'الرسالة أعلى في القصة.';
  @override
  String get otpravlyaetFoto_67c1 => 'يرسل صورة...';
  @override
  String get otpravlyaetVideo_ce80 => 'يرسل فيديو...';
  @override
  String get otpravlyaetFayl_5e88 => 'يرسل الملف...';
  @override
  String get ktoTo_8405 => 'شخص ما';
  @override
  String get trebuetsyaRazreshenieNaKameruI_06fa =>
      'مطلوب إذن الكاميرا والميكروفون';
  @override
  String get kameraNeNaydena_208d => 'لم يتم العثور على الكاميرا';
  @override
  String get zapisVideoOtmenena_1db7 => 'تم إلغاء تسجيل الفيديو';
  @override
  String get slishkomKorotkoeVideosoobschenie_4676 =>
      'رسالة الفيديو قصيرة جدًا';
  @override
  String get pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35 =>
      'الرجاء الانتظار حتى يتم تنزيل الملفات';
  @override
  String get audiozvonok_dcf6 => 'مكالمة صوتية';
  @override
  String get otpravitFotoVideoAudioIli_37e9 =>
      'إرسال الصور ومقاطع الفيديو والصوت أو الملفات الأخرى';
  @override
  String get provedenieGolosovaniyaVChate_a629 => 'التصويت في الدردشة';
  @override
  String get sozdatToDoSpisok_cb50 => 'قم بإنشاء قائمة المهام';
  @override
  String get spisokZadachSOtmetkamiVypolneniya_c778 =>
      'قائمة المهام مع علامات الإنجاز';
  @override
  String get trebuetsyaRazreshenieNaZapisAudio_8175 =>
      'يتطلب إذنًا لتسجيل الصوت';
  @override
  String get slishkomKorotkoeSoobschenie_c2ee => 'الرسالة قصيرة جدًا';
  @override
  String get uderzhivayteKnopkuDlyaZapisi_a762 =>
      'اضغط مع الاستمرار على الزر للتسجيل';
  @override
  String get udalennyy_40c6 => 'عن بعد';
  @override
  String get udalennyy_c2c8 => 'عن بعد';
  @override
  String get neobhodimyRazresheniyaNaMikrofonI_224b =>
      'أذونات الميكروفون والكاميرا مطلوبة لإجراء مكالمة';
  @override
  String get bylATolkoChto_9ac0 => 'كان هناك للتو';
  @override
  String get chatNeNayden_ba4f => 'لم يتم العثور على الدردشة';
  @override
  String get napishitePervoeSoobschenie_8260 => 'اكتب رسالتك الأولى';
  @override
  String get prisoedinitsyaKKanalu_f863 => 'انضم إلى القناة';
  @override
  String get vyPodpisany_5fb9 => 'أنت مشترك';
  @override
  String get otpisatsya_ee2d => 'إلغاء الاشتراك';
  @override
  String get vyUspeshnoPodpisalisNaKanal_9c99 => 'لقد اشتركت في القناة بنجاح!';
  @override
  String get vyUspeshnoVstupiliVGruppu_61a1 => 'لقد انضممت إلى المجموعة بنجاح!';
  @override
  String get neUdalosPrisoedinitsyaPoprobuyteEsche_bce5 =>
      'فشل الانضمام. حاول ثانية.';
  @override
  String get vyrezat_a195 => 'قطع';
  @override
  String get kopirovat_112b => 'نسخ';
  @override
  String get vstavit_dcc4 => 'لصق';
  @override
  String get vybratVse_4d09 => 'حدد الكل';
  @override
  String get zhirnyy_7774 => 'جريئة';
  @override
  String get kursiv_e0b1 => 'مائل';
  @override
  String get kod_3f34 => 'الكود';
  @override
  String get zacherknut_02fc => 'شطب';
  @override
  String get soobschenie_8b9b => 'رسالة...';
  @override
  String get smahniteDlyaOtmeny_e976 => 'اسحب للإلغاء';
  @override
  String get poisk_bfc9 => 'بحث';
  @override
  String get udalitChat_4b2b => 'حذف الدردشة';
  @override
  String get udalitKanal_482f => 'حذف القناة';
  @override
  String get pozhalovatsya_a7d9 => 'شكوى';
  @override
  String get redaktirovatGruppu_e40a => 'تحرير المجموعة';
  @override
  String get udalitGruppu_dff8 => 'حذف المجموعة';
  @override
  String get poiskSoobscheniyVremennoNedostupenV_4443 =>
      'البحث عن الرسائل غير متاح مؤقتًا في إصدار الهاتف المحمول';
  @override
  String get zhalobaOtpravlenaModeratoram_4547 =>
      'تم إرسال الشكوى إلى المشرفين';
  @override
  String get redaktirovanieGruppyVremennoNedostupnoV_05d0 =>
      'تحرير المجموعة غير متاح مؤقتًا في إصدار الهاتف المحمول';
  @override
  String get vyUverenyChtoHotiteOchistit_7c3a =>
      'هل أنت متأكد أنك تريد مسح سجل رسائلك في هذه الدردشة؟ لا يمكن التراجع عن هذا الإجراء.';
  @override
  String get ochistit_7074 => 'واضح';
  @override
  String get udalit_ed2b => 'حذف';
  @override
  String get vyyti_0f05 => 'تسجيل الخروج';
  @override
  String get oshibkaVosproizvedeniya_ac8a => 'خطأ في التشغيل';
  @override
  String get novoeZashifrovannoeSoobschenie_4d30 => 'رسالة مشفرة جديدة';
  @override
  String get poiskChatov_779c => 'بحث في المحادثات...';
  @override
  String get obnovlenie_53e2 => 'تحديث...';
  @override
  String get soedinenie_5a58 => 'اتصال...';
  @override
  String get lichnye_4cb3 => 'شخصي';
  @override
  String get neUdalosArhivirovatChatNa_36aa =>
      'فشل في أرشفة الدردشة على الخادم';
  @override
  String get oshibkaZagruzkiChatov_902f => 'حدث خطأ أثناء تحميل الدردشات';
  @override
  String get povtorit_b914 => 'كرر';
  @override
  String get netChatov_85e3 => 'لا محادثات';
  @override
  String get nachniteNovyyRazgovor_8290 => 'ابدأ محادثة جديدة';
  @override
  String get neUdalosZagruzitAkkaunty_8570 => 'فشل في تحميل الحسابات';
  @override
  String get vyberiteAkkaunt_79e7 => 'حدد حسابًا';
  @override
  String get bystryyVhodNaEtomUstroystve_3f30 =>
      'تسجيل الدخول السريع على هذا الجهاز';
  @override
  String get voytiSParolem_9277 => 'تسجيل الدخول بكلمة المرور';
  @override
  String get sozdatXaneoId_4033 => 'إنشاء معرف Xaneo';
  @override
  String get netSohranennyhAkkauntov_b669 => 'لا توجد حسابات محفوظة';
  @override
  String get tolkoChto_4493 => 'الآن فقط';
  @override
  String get emailNedostupen_fc3e => 'البريد الإلكتروني غير متوفر';
  @override
  String get nevernyyKod_50f9 => 'رمز غير صالح';
  @override
  String get oshibkaProverkiKoda_9018 => 'خطأ في التحقق من الرمز';
  @override
  String get neobhodimoRazreshenieNaDostupK_5f5c =>
      'الإذن المطلوب للوصول إلى الصور';
  @override
  String get oVyboreEmail_2609 => 'حول اختيار البريد الإلكتروني';
  @override
  String get podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0 =>
      'جميع مجالات البريد الإلكتروني مدعومة باستثناء';
  @override
  String get zapreschennyh_1f49 => 'محظور';
  @override
  String get obIspolzovaniiParolya_9739 => 'حول استخدام كلمة المرور';
  @override
  String get parolTolkoDlyaAvariynogoVhoda_b142 =>
      'تُستخدم كلمة المرور فقط في الحالات الطارئة — إذا تعذر تسجيل الدخول برمز من بوت إشعارات Xaneo أو بالرمز المرسل إلى بريدك الإلكتروني.';
  @override
  String get sozdatAkkaunt_19ed => 'إنشاء حساب';
  @override
  String get naprimerIvan_d7cb => 'على سبيل المثال، إيفان';
  @override
  String get zadayteParol_53d2 => 'قم بتعيين كلمة مرور';
  @override
  String get minimum8Simvolov_4ccd => 'الحد الأدنى 8 أحرف';
  @override
  String get unikalnoeImyaDlyaVashegoProfilya_a0ea => 'اسم فريد لملفك الشخصي';
  @override
  String get vashEmail_879d => 'البريد الإلكتروني الخاص بك';
  @override
  String get dlyaSvyaziIVosstanovleniyaDostupa_c770 =>
      'لاستعادة الاتصالات والوصول';
  @override
  String get emailAdres_9130 => 'عنوان البريد الإلكتروني';
  @override
  String get vvediteParolEscheRaz_7383 => 'أدخل كلمة المرور الخاصة بك مرة أخرى';
  @override
  String get parolEscheRaz_6daf => 'كلمة المرور مرة أخرى';
  @override
  String get paroliNeSovpadayut_d82f => 'كلمات المرور غير متطابقة';
  @override
  String get ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed =>
      'يرجى الإشارة إلى تاريخ ميلادك الحقيقي';
  @override
  String get ddmmgggg_3524 => 'يوم.ش.س.س.س';
  @override
  String get sdelayteProfilUznavaemym_f2c5 => 'اجعل ملفك الشخصي مميزًا';
  @override
  String get profilGotov_b57d => 'الملف الشخصي جاهز';
  @override
  String get ostalosVsegoParaShagov_37e3 => 'لم يتبق سوى بضع خطوات';
  @override
  String get yaPrinimayuPolzovatelskoeSoglashenie_c431 =>
      'أوافق على اتفاقية المستخدم';
  @override
  String get yaDayuSoglasieNaObrabotku_0d03 =>
      'أوافق على معالجة البيانات الشخصية';
  @override
  String get sVozvrascheniem_77ee => 'مرحبًا بعودتك';
  @override
  String get zagruzka_43e4 => 'جار التحميل...';
  @override
  String get vyberiteAkkauntDlyaVhoda_d3a6 => 'حدد حسابًا لتسجيل الدخول';
  @override
  String get vvediteVashNikneym_51a6 => 'أدخل لقبك';
  @override
  String get voytiVDrugoyAkkaunt_d10f => 'تسجيل الدخول إلى حساب آخر';
  @override
  String get nedavnieAkkaunty_953d => 'الحسابات الأخيرة';
  @override
  String get dobroPozhalovatVXaneo_66d0 => 'مرحبا بكم في زانو';
  @override
  String get xaneoTeperIVMobilnom_e918 =>
      'Xaneo متوفر الآن في تطبيق الهاتف المحمول! لم يكن هذا الرسول مريحًا وسريعًا من قبل.';
  @override
  String get mneUzheInteresno_5365 => 'أنا مهتم بالفعل';
  @override
  String get vseVashiDannyePodZaschitoy_b7d9 => 'جميع بياناتك محمية';
  @override
  String get vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e =>
      'جميع الرسائل محمية بالتشفير الشامل. لا يعرف Xaneo محتوياتها في أي مرحلة.';
  @override
  String get prodolzhit_e9c3 => 'متابعة';
  @override
  String get lokalnyeDataTsentry_f089 => 'مراكز البيانات المحلية';
  @override
  String get vashiDannyeNikogdaNePokidayut_f871 =>
      'لا تغادر بياناتك البلد أبدًا ويتم تخزينها في مراكز بيانات آمنة.';
  @override
  String get kodOtpravlenPovtorno_e109 => 'تمت إعادة الرمز';
  @override
  String get dvuhfaktornayanautentifikatsiya_bacc => 'عاملين\nالمصادقة';
  @override
  String get naVashEmailOtpravlen6_b457 =>
      'تم إرسال رمز مكون من 6 أرقام إلى بريدك الإلكتروني';
  @override
  String get podtverdit_e260 => 'تأكيد';
  @override
  String get nePoluchiliKodOtpravitPovtorno_c1d2 =>
      'لم تتلق الرمز؟ إعادة الإرسال';
  @override
  String get imyaNikneymOSebe_7a8d => 'الاسم، اللقب، عن نفسك';
  @override
  String get zvonkiSoobscheniyaVidimostProfilya_f905 =>
      'المكالمات والرسائل ورؤية الملف الشخصي';
  @override
  String get parolSessii2fa_de9e => 'كلمة المرور، الجلسات، 2FA';
  @override
  String get prilozhenie_38aa => 'الملحق';
  @override
  String get temaRazmerTekstaAnimatsii_f0a8 =>
      'الموضوع، حجم النص، الرسوم المتحركة';
  @override
  String get pushUvedomleniyaZvuki_9cc2 => 'دفع الإخطارات والأصوات';
  @override
  String get oPrilozhenii_77b2 => 'حول التطبيق';

  @override
  String get redaktirovatProfil_56ad => 'تحرير الملف الشخصي';
  @override
  String get dobavitKontakt_2903 => 'إضافة جهة اتصال';
  @override
  String get nikneymPolzovatelyaUsername_a6ff => 'لقب المستخدم (@اسم المستخدم)';
  @override
  String get otobrazhaemoeImyaNeobyazatelno_340a => 'اسم العرض (اختياري)';
  @override
  String get neUdalosNaytiIliDobavit_649f =>
      'تعذر العثور على المستخدم أو إضافته';
  @override
  String get ya_feef => 'أنا';
  @override
  String get poiskKontaktov_9a71 => 'البحث عن جهات الاتصال...';
  @override
  String get spisokKontaktovPust_58c6 => 'قائمة جهات الاتصال فارغة';
  @override
  String get kontaktyNeNaydeny_1b08 => 'لم يتم العثور على جهات اتصال';
  @override
  String get messages => 'الرسائل';
  @override
  String get messageAnimations => 'رسوم الرسائل المتحركة';
  @override
  String get messageAnimationsDesc =>
      'إظهار الرسوم المتحركة عند الإرسال والاستلام';
  @override
  String get archivedChats => 'المحادثات المؤرشفة';
  @override
  String get archiveManagement => 'إدارة الأرشيف';
  @override
  String get clearHistory => 'مسح السجل';
  @override
  String get clearHistoryDesc => 'حذف جميع الرسائل محلياً';
  @override
  String get call => 'اتصال';
  @override
  String get sendMessage => 'إرسال رسالة';
  @override
  String get deleteContact => 'حذف جهة الاتصال';
  @override
  String get activeSessions => 'الجلسات النشطة';
  @override
  String get thisDevice => 'هذا الجهاز';
  @override
  String get xaneoPcActiveNow => 'Xaneo PC • نشط الآن';
  @override
  String get activeNow => 'نشط';
  @override
  String get twoFactorAuth => 'المصادقة الثنائية';
  @override
  String get twoFactorAuthDesc => 'حماية الحساب برمز مرور لمرة واحدة';
  @override
  String get dangerZone => 'منطقة الخطر';
  @override
  String get deleteAccount => 'حذف الحساب';
  @override
  String get irreversibleAction => 'إجراء لا يمكن التراجع عنه';
  @override
  String get theme => 'المظهر';
  @override
  String get darkThemeDesc => 'التبديل بين الوضع الداكن والفاتح';
  @override
  String get fontSizeText => 'حجم الخط';
  @override
  String get changePhoto => 'تغيير الصورة';
  @override
  String get avatarUpdated => 'تم تحديث الصورة الشخصية';
  @override
  String get avatarUploadFailed => 'تعذر رفع الصورة الشخصية';
  @override
  String get invalidNicknameFormat =>
      'اسم المستخدم: من 3 إلى 30 حرفًا؛ أحرف وأرقام و . و _ و - فقط';
  @override
  String get deleteAccountPrompt =>
      'سيتم حذف ملفك الشخصي نهائيًا. أدخل كلمة المرور للتأكيد.';
  @override
  String get deleteAccountFailed => 'تعذر حذف الحساب';
  @override
  String get chatFontSize => 'حجم خط الدردشة';
  @override
  String get chatWallpaper => 'خلفية الدردشة';
  @override
  String get myMessageColor => 'لون رسائلي';
  @override
  String get otherMessageColor => 'لون رسائل الآخرين';
  @override
  String get notificationStyle => 'نمط الإشعارات';
  @override
  String get standardNotificationStyle => 'قياسي';
  @override
  String get blackRavenNotificationStyle => 'الغراب الأسود';
  @override
  String get wallpaperUploadFailed => 'تعذر رفع خلفية الدردشة';
  @override
  String get showPopups => 'إظهار الإشعارات المنبثقة';
  @override
  String get sound => 'الصوت';
  @override
  String get soundDesc => 'تشغيل صوت عند وصول رسالة جديدة';
  @override
  String get mainSettings => 'الإعدادات الرئيسية';
  @override
  String get energySavingMode => 'وضع توفير الطاقة';
  @override
  String get energySavingModeDesc => 'تحسين أداء التطبيق لتوفير البطارية';
  @override
  String get autoSleep => 'وضع السكون التلقائي';
  @override
  String get autoSleepDesc => 'وضع التطبيق في حالة سكون عند عدم النشاط';
  @override
  String get animations => 'الرسوم المتحركة';
  @override
  String get reducedMotion => 'تقليل الحركة';
  @override
  String get reducedMotionDesc => 'تقليل الرسوم المتحركة في الواجهة';
  @override
  String get comingSoon => 'قريباً';
  @override
  String get darkTheme => 'الوضع الداكن';
  @override
  String get version => 'الإصدار';

  @override
  String get updateAvailable => 'يتوفر تحديث';
  @override
  String get clickToViewChanges => 'انقر لعرض التغييرات';
  @override
  String get newVersionAvailable => 'يتوفر إصدار جديد من التطبيق';
  @override
  String get newVersionAvailableTitle => 'يتوفر إصدار جديد';
  @override
  String get youHaveLatestVersion => 'لديك أحدث إصدار مثبت';
  @override
  String get whatsNew => 'ما الجديد';
  @override
  String get officialReleaseNotes => 'ملاحظات الإصدار الرسمية متاحة على GitHub';
  @override
  String get preparingDownload => 'جاري تحضير التنزيل...';
  @override
  String get installationStarted => 'بدأ التثبيت...';
  @override
  String get whoSeesAvatar => 'من يمكنه رؤية صورتي الشخصية';
  @override
  String get whoSeesBirthday => 'من يمكنه رؤية تاريخ ميلادي';
  @override
  String get whoSeesOnlineTime => 'من يمكنه رؤية وقت نشاطي';

  @override
  String get downloadVersion => 'تنزيل';
  @override
  String get downloadSource => 'مصدر التنزيل';
  @override
  String get directInAppInstall => 'التثبيت المباشر داخل التطبيق';
  @override
  String get autoDownloadAndRun => 'التنزيل والتشغيل التلقائي';
  @override
  String get githubReleasePage => 'صفحة الإصدار على GitHub';
  @override
  String get skip => 'تخطي';
  @override
  String get updateAction => 'تحديث';
  @override
  String get installAction => 'جاري التثبيت...';
  @override
  String get isTyping => 'يكتب...';
  @override
  String get isRecordingVoice => 'سجل صوتاً...';
  @override
  String get areTyping => 'يكتبون...';

  @override
  String membersCount(int count) => count == 1 ? 'عضو واحد' : '$count أعضاء';
  @override
  String subscribersCount(int count) =>
      count == 1 ? 'مشترك واحد' : '$count مشتركين';

  @override
  String get group => 'مجموعة';
  @override
  String get channel => 'قناة';

  @override
  String get profile => 'الملف الشخصي';
  @override
  String get userHidInfo => 'قام المستخدم بإخفاء معلوماته';
  @override
  String get leaveGroup => 'مغادرة المجموعة';
  @override
  String get joinGroup => 'الانضمام إلى المجموعة';
  @override
  String get unsubscribeChannel => 'إلغاء الاشتراك';
  @override
  String get subscribeChannel => 'الاشتراك في القناة';
  @override
  String get deleteChat => 'حذف الدردشة';
  @override
  String get pinChat => 'تثبيت';
  @override
  String get unpinChat => 'إلغاء التثبيت';
  @override
  String get muteNotifications => 'كتم الإشعارات';
  @override
  String get unmuteNotifications => 'تفعيل الإشعارات';
  @override
  String get backToChats => 'العودة إلى الدردشات';
  @override
  String get globalSearch => 'البحث الشامل';
  @override
  String get chatSettings => 'إعدادات الدردشة';
  @override
  String get emoji => 'رمز تعبيري';
  @override
  String get attachFile => 'إرفاق ملف';
  @override
  String get startCall => 'بدء مكالمة';
  @override
  String get audioCall => 'مكالمة صوتية';
  @override
  String get audioCallDesc => 'الاتصال عبر الصوت';
  @override
  String get videoCall => 'مكالمة فيديو';

  @override
  String get copied => 'تم النسخ';

  @override
  String get copy => 'نسخ';

  @override
  String get voiceRecordTitle => 'تسجيل صوتي';
  @override
  String get videoRecordTitle => 'تسجيل فيديو';
  @override
  String get holdToRecordHint => 'اضغط مع الاستمرار للتسجيل\nانقر لتغيير الوضع';
  @override
  String get addAttachment => 'إضافة مرفق';
  @override
  String get emojiPanelInDev => 'لوحة الرموز التعبيرية قيد التطوير';
  @override
  String get recordingVoice => 'جاري تسجيل الصوت...';
  @override
  String get recordingVideo => 'جاري تسجيل الفيديو...';
  @override
  String get releaseToSend => 'اترك للإرسال';
  @override
  String get videoCallDesc => 'الاتصال مع تشغيل الكاميرا';

  @override
  String get typeMessage => 'اكتب رسالة...';
  @override
  String get file => 'ملف';
  @override
  String get todoList => 'قائمة المهام';
  @override
  String get poll => 'استطلاع';

  @override
  String get today => 'اليوم';
  @override
  String get yesterday => 'أمس';
  @override
  String get monthJan => 'يناير';
  @override
  String get monthFeb => 'فبراير';
  @override
  String get monthMar => 'مارس';
  @override
  String get monthApr => 'أبريل';
  @override
  String get monthMay => 'مايو';
  @override
  String get monthJun => 'يونيو';
  @override
  String get monthJul => 'يوليو';
  @override
  String get monthAug => 'أغسطس';
  @override
  String get monthSep => 'سبتمبر';
  @override
  String get monthOct => 'أكتوبر';
  @override
  String get monthNov => 'نوفمبر';
  @override
  String get monthDec => 'ديسمبر';
  @override
  String get createTodo => 'إنشاء قائمة مهام';
  @override
  String get listName => 'عنوان القائمة';
  @override
  String get todoItems => 'العناصر';
  @override
  String get addTodoItem => '+ إضافة عنصر';
  @override
  String get itemHintPrefix => 'عنصر';
  @override
  String get createPoll => 'إنشاء استطلاع';
  @override
  String get pollQuestion => 'السؤال';
  @override
  String get pollOptions => 'خيارات الإجابة';
  @override
  String get addPollOption => '+ إضافة خيار';
  @override
  String get optionHintPrefix => 'خيار';
  @override
  String get allowMultipleAnswers => 'السماح بخيارات متعددة';
  @override
  String get accountsTitle => 'الحسابات';
  @override
  String get addAccount => 'إضافة حساب';
  @override
  String get accountLimitNotice => 'الحد الأقصى 5 حسابات';

  @override
  String get singleChoice => 'خيار واحد';

  @override
  String get media => 'الوسائط';
  @override
  String get files => 'الملفات';
  @override
  String get voice => 'صوتي';
  @override
  String get links => 'الروابط';

  @override
  String get bio => 'نبذة شخصية';
  @override
  String get username => 'اسم المستخدم';
  @override
  String get birthday => 'تاريخ الميلاد';
  @override
  String get noSharedMedia => 'لا توجد وسائط';
  @override
  String get noSharedFiles => 'لا توجد ملفات';
  @override
  String get noSharedVoice => 'لا توجد رسائل صوتية';
  @override
  String get noSharedLinks => 'لا توجد روابط';

  @override
  String get savedMessagesDesc =>
      'مساحة التخزين السحابية الشخصية للملاحظات والملفات والرسائل';
  @override
  String get music => 'موسيقى';
  @override
  String get noSharedMusic => 'لا توجد موسيقى';
  @override
  String get secureDesktopCommunicator => 'تطبيق تواصل مكتبي آمن';
  @override
  String get noMessagesTitle => 'لا توجد رسائل';
  @override
  String get noMessagesSubtitle =>
      'أرسل رسالة لبدء المحادثة على Xaneo Connect!';

  @override
  String get qrScanTitle => 'مصادقة الجهاز';
  @override
  String get qrScanSubtitle =>
      'وجه الكاميرا نحو رمز QR على شاشة تطبيق الويب أو الكمبيوتر الشخصي لـ Xaneo';
  @override
  String get qrScanSuccessTitle => 'تمت مصادقة الجهاز';
  @override
  String get qrScanSuccessDesc =>
      'تمت المصادقة بنجاح. تم نقل مفاتيح التشفير بين الطرفين (E2EE) إلى الجهاز الجديد.';
  @override
  String get qrScanInputHint => 'الصق الرمز أو البيانات...';
  @override
  String get qrScanPasteTooltip => 'نسخ من الحافظة';
  @override
  String get qrScanConfirmButton => 'تأكيد المصادقة';
  @override
  String get qrScanProcessing => 'جاري مصادقة الجهاز...';

  @override
  String get qrScanConfirmDesc =>
      'طلب جهاز آخر تسجيل الدخول إلى حسابك. تحقّق من الرمز القصير وأكّد الطلب.';

  @override
  String get qrScanSecurityNote =>
      'تابع فقط إذا كان رمز QR معروضًا على جهاز تتحكم به.';

  @override
  String get qrScanDoneButton => 'تم';

  @override
  String get authNotificationSendingCode => 'جارٍ إرسال الرمز';

  @override
  String get authNotificationEnterCode => 'أدخل الرمز';

  @override
  String get authNotificationConfirmLogin => 'تأكيد تسجيل الدخول';

  @override
  String get authNotificationPasswordLogin => 'تسجيل الدخول بكلمة المرور';

  @override
  String get authNotificationSendingSubtitle =>
      'سيصل الرمز إلى محادثة "إشعارات Xaneo". لا تغلق هذه الشاشة.';

  @override
  String get authNotificationEnterCodeSubtitle =>
      'أدخل الرمز المكون من 6 أرقام من الرسالة.';

  @override
  String get authNotificationConfirmSubtitle =>
      'افتح Xaneo على جهاز مصرح به مسبقًا وتحقق من تفاصيل الطلب.';

  @override
  String get authNotificationPasswordSubtitle =>
      'هذه الطريقة متاحة فقط بعد انتهاء فترة الانتظار. لا يتم حفظ كلمة المرور.';

  @override
  String get authNotificationBotSource => 'يأتي الرمز من "إشعارات Xaneo".';

  @override
  String authNotificationCodeSentToEmail(String email) =>
      'تم إرسال الرمز إلى $email';

  @override
  String get authNotificationNoBotAccess => 'لا يمكنك الوصول إلى البوت؟';

  @override
  String get authNotificationGetCodeViaEmail => 'الحصول على الرمز عبر البريد';

  @override
  String get authNotificationResendCodeViaEmail =>
      'إعادة إرسال الرمز إلى البريد';

  @override
  String get authNotificationEmailUnavailable =>
      'الرمز عبر البريد غير متاح: لا يوجد بريد إلكتروني موثق في الحساب.';

  @override
  String authNotificationEmailAvailableIn(int seconds) =>
      'سيتوفر الرمز عبر البريد خلال $seconds ثانية.';

  @override
  String get authNotificationLoginWithPassword => 'تسجيل الدخول بكلمة المرور';

  @override
  String authNotificationPasswordAvailableIn(int seconds) =>
      'سيتوفر تسجيل الدخول بكلمة المرور خلال $seconds ثانية.';

  @override
  String get authNotificationErrorSendFailed =>
      'فشل إرسال الرمز. يرجى المحاولة لاحقًا.';

  @override
  String get authNotificationErrorInvalidCode =>
      'رمز غير صالح أو منتهي الصلاحية';

  @override
  String get authNotificationErrorRequestExpired =>
      'تم رفض الطلب أو انتهت صلاحيته';

  @override
  String get authNotificationErrorEmailFailed =>
      'فشل إرسال الرمز إلى البريد. يرجى المحاولة لاحقًا.';

  @override
  String get authNotificationErrorPasswordFailed =>
      'فشل تسجيل الدخول. تحقق من كلمة المرور أو ابدأ من جديد.';

  @override
  String get authNotificationGetCodeBtn => 'الحصول على الرمز';

  @override
  String get authRejectedTitle => 'تم رفض تسجيل الدخول';

  @override
  String get authRejectedDesc =>
      'تم رفض طلب تسجيل الدخول على جهازك الآخر. إذا لم يكن هذا أنت، فنوصي بمراجعة أمان حسابك.';

  @override
  String get authRejectedButton => 'فهمت';

  @override
  String get deviceAuthApprovalSubtitle =>
      'تم التحقق من الرمز. اسمح بتسجيل الدخول فقط إذا كنت أنت من أنشأ هذا الطلب.';

  @override
  String get deviceAuthApprovalKeysNotice =>
      'سيتم نقل مفاتيح المحادثات إلى الجهاز الجديد بشكل مشفر.';

  @override
  String get deviceAuthApprovalAllow => 'السماح بتسجيل الدخول';

  @override
  String get deviceAuthApprovalDecline => 'رفض';

  @override
  String get deviceAuthDevice => 'الجهاز';

  @override
  String get deviceAuthApp => 'التطبيق';

  @override
  String get deviceAuthIp => 'عنوان IP';

  @override
  String get importLanguageFromJson => 'استيراد لغة من ملف JSON';
  @override
  String get customColor => 'لون مخصص';
  @override
  String get customGradient => 'تدرج مخصص';
  @override
  String get colorOne => 'اللون 1';
  @override
  String get colorTwo => 'اللون 2';
  @override
  String get diagonal => 'قطري';
  @override
  String get vertical => 'عمودي';
  @override
  String get horizontal => 'أفقي';
}
