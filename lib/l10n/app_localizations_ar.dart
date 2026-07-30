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
  String get welcomeDescription => 'تطبيق Xaneo أصبح الآن على جهاز الكمبيوتر الخاص بك! أقصى أداء وراحة.';

  @override
  String get getStartedButton => 'ابدأ الآن';

  @override
  String get privacyTitle => 'جميع بياناتك آمنة';

  @override
  String get privacyDescription => 'جميع الرسائل في Xaneo محمية بالتشفير بين الطرفين (E2EE).';

  @override
  String get continueButton => 'متابعة';

  @override
  String get dataStorageTitle => 'جميع مراكز بيانات Xaneo تقع في روسيا';

  @override
  String get dataStorageDescription => 'بياناتك لا تغادر البلاد مطلقًا وتُحفظ في مراكز بيانات آمنة.';

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
  String get invalidCredentials => 'بيانات الاعتماد غير صحيحة. يرجى التحقق من اسم المستخدم وكلمة المرور.';

  @override
  String get serverError => 'خطأ في الخادم. يرجى المحاولة لاحقاً.';

  @override
  String get connectionError => 'خطأ في الاتصال. يرجى التحقق من اتصال الإنترنت.';

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
  String get nicknameCannotBeChanged => 'لا يمكن تغيير اسم المستخدم داخل التطبيق';
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
  String get obnovlenie_7e32 => 'ОБНОВЛЕНИЕ';
  @override
  String get obnovleniePrilozheniya_b6c3 => 'ОБНОВЛЕНИЕ ПРИЛОЖЕНИЯ';
  @override
  String get podgotovkaKZagruzke_a5c7 => 'Подготовка к загрузке...';
  @override
  String get ustanovkaZapuschena_d378 => 'Установка запущена!';
  @override
  String get dostupnaNovayaVersiyaPrilozheniya_eeae => 'Доступна новая версия приложения';
  @override
  String get chtoNovogo_74e2 => 'ЧТО НОВОГО';
  @override
  String get ofitsialnoeOpisanieRelizaDostupnoNa_3ea3 => 'Официальное описание релиза доступно на странице GitHub.';
  @override
  String get istochnikZagruzki_0e6e => 'ИСТОЧНИК ЗАГРУЗКИ';
  @override
  String get pryamayaUstanovkaVPrilozhenii_16f5 => 'Прямая установка в приложении';
  @override
  String get avtomaticheskoeSkachivanieIZapusk_9a3f => 'Автоматическое скачивание и запуск';
  @override
  String get stranitsaRelizaNaGithub_1531 => 'Страница релиза на GitHub';
  @override
  String get propustit_03ee => 'Пропустить';
  @override
  String get ustanovka_516d => 'Установка...';
  @override
  String get obnovit_dbe5 => 'Обновить';
  @override
  String get lichnyeDannye_be85 => 'Личные данные';
  @override
  String get imyaNikneymFotoProfilya_28ac => 'Имя, никнейм, фото профиля';
  @override
  String get privatnost_0899 => 'Приватность';
  @override
  String get ktoMozhetPisatZvonitVidet_1789 => 'Кто может писать, звонить, видеть профиль';
  @override
  String get nastroykiChatov_7ca8 => 'Настройки чатов';
  @override
  String get uvedomleniyaTemyIstoriya_51da => 'Уведомления, темы, история';
  @override
  String get kontakty_7576 => 'Контакты';
  @override
  String get vashiSohranennyeKontakty_a641 => 'Ваши сохранённые контакты';
  @override
  String get bezopasnost_3677 => 'Безопасность';
  @override
  String get sessiiParolAutentifikatsiya_73f5 => 'Сессии, пароль, аутентификация';
  @override
  String get vneshniyVid_6873 => 'Внешний вид';
  @override
  String get temaShriftMasshtab_d8c9 => 'Тема, шрифт, масштаб';
  @override
  String get yazyk_0577 => 'Язык';
  @override
  String get yazykInterfeysaKlienta_2ad3 => 'Язык интерфейса клиента';
  @override
  String get uvedomleniya_d2ed => 'Уведомления';
  @override
  String get zvukiBannery_1b60 => 'Звуки, баннеры';
  @override
  String get energosberezhenie_0b19 => 'Энергосбережение';
  @override
  String get animatsiiIProizvoditelnost_fba8 => 'Анимации и производительность';
  @override
  String get oPrilozhenii_322e => 'О приложении';
  @override
  String get versiyaProverkaObnovleniySsylki_6efc => 'Версия, проверка обновлений, ссылки';
  @override
  String get nastroyki_b01b => 'НАСТРОЙКИ';
  @override
  String get nastroyki_c919 => 'Настройки';
  @override
  String get proverkaObnovleniy_f3e0 => 'Проверка обновлений...';
  @override
  String get neUdalosZagruzitNastroyki_f753 => 'Не удалось загрузить настройки';
  @override
  String get oshibkaSohraneniya_0387 => 'Ошибка сохранения';
  @override
  String get dannyeSohraneny_fd62 => 'Данные сохранены';
  @override
  String get gost_9618 => 'Гость';
  @override
  String get akkaunt_38ac => 'АККАУНТ';
  @override
  String get interfeys_49be => 'ИНТЕРФЕЙС';
  @override
  String get vyytiIzAkkaunta_6d41 => 'Выйти из аккаунта';
  @override
  String get informatsiyaOPrilozhenii_00c4 => 'Информация о приложении';
  @override
  String get versiya1001LinuxWindowsMacos_ff6c => 'Версия: 1.0.loc_0+1 (Linux / Windows / macOS)';
  @override
  String get proverka_13bc => 'Проверка...';
  @override
  String get proveritObnovleniya_ab45 => 'Проверить обновления';
  @override
  String get osnovnayaInformatsiya_6fec => 'Основная информация';
  @override
  String get imya_d38d => 'Имя';
  @override
  String get vvediteVasheImya_751e => 'Введите ваше имя';
  @override
  @override
  String get nikneym_3fea => 'اسم المستخدم';
  @override
  String get nikneymNelzyaIzmenitVPrilozhenii_75d0 => 'Никнейм нельзя изменить в приложении';
  @override
  String get oSebe_0b3b => 'О себе';
  @override
  String get rasskazhiteOSebe_1c37 => 'Расскажите о себе...';
  @override
  String get sohranenie_c15f => 'Сохранение...';
  @override
  String get sohranit_74ea => 'Сохранить';
  @override
  @override
  String get vse_984b => 'الكل';
  @override
  String get tolkoKontakty_a559 => 'Только контакты';
  @override
  String get nikto_ba19 => 'Никто';
  @override
  String get kommunikatsii_1242 => 'Коммуникации';
  @override
  String get ktoMozhetPisatSoobscheniya_4645 => 'Кто может писать сообщения';
  @override
  String get ktoMozhetZvonit_c427 => 'Кто может звонить';
  @override
  String get ktoMozhetZapisyvatGolosovye_c69a => 'Кто может записывать голосовые';
  @override
  String get ktoMozhetOtpravlyatFayly_2e40 => 'Кто может отправлять файлы';
  @override
  String get ktoMozhetPriglashatVGruppy_cdc0 => 'Кто может приглашать в группы';
  @override
  String get vidimostProfilya_34bf => 'Видимость профиля';
  @override
  String get ktoViditMoyNikneym_54b8 => 'Кто видит мой никнейм';
  @override
  String get ktoViditMoyAvatar_e9f6 => 'Кто видит мой аватар';
  @override
  String get ktoViditMoyDenRozhdeniya_ccc7 => 'Кто видит мой день рождения';
  @override
  String get ktoViditVremyaMoeyAktivnosti_4349 => 'Кто видит время моей активности';
  @override
  String get neUdalosZagruzitKontakty_02a3 => 'Не удалось загрузить контакты';
  @override
  String get dobavitKontakt_4278 => 'Добавить контакт';
  @override
  String get nikneymPolzovatelya_5610 => 'Никнейм пользователя';
  @override
  String get otobrazhaemoeImyaOptsionalno_bbd1 => 'Отображаемое имя (опционально)';
  @override
  @override
  String get otmena_987b => 'إلغاء';
  @override
  String get dobavit_5eba => 'Добавить';
  @override
  String get uVasPokaNetSohranennyh_b64b => 'У вас пока нет сохранённых контактов';
  @override
  String get pozvonit_ccfa => 'Позвонить';
  @override
  String get napisat_0144 => 'Написать';
  @override
  String get udalitKontakt_065d => 'Удалить контакт';
  @override
  String get soobscheniya_7e26 => 'Сообщения';
  @override
  String get animatsiiSoobscheniy_bc8b => 'Анимации сообщений';
  @override
  String get pokazyvatAnimatsiiPriOtpravkeI_d663 => 'Показывать анимации при отправке и получении';
  @override
  String get arhivirovannyeChaty_d990 => 'Архивированные чаты';
  @override
  String get upravlenieArhivom_e843 => 'Управление архивом';
  @override
  String get ochistitIstoriyu_837a => 'Очистить историю';
  @override
  String get udalitVseSoobscheniyaLokalno_fbbd => 'Удалить все сообщения локально';
  @override
  String get aktivnyeSessii_5c96 => 'Активные сессии';
  @override
  String get etoUstroystvo_26f6 => 'Это устройство';
  @override
  String get xaneoPcAktivnoSeychas_25b4 => 'Xaneo PC • Активно сейчас';
  @override
  String get aktivno_87a4 => 'Активно';
  @override
  String get dvoynayaAutentifikatsiya_66ae => 'Двойная аутентификация';
  @override
  String get zaschitaAkkauntaOdnorazovymParolem_e9f1 => 'Защита аккаунта одноразовым паролем';
  @override
  String get opasnayaZona_25bc => 'Опасная зона';
  @override
  String get udalitAkkaunt_05c7 => 'Удалить аккаунт';
  @override
  String get neobratimoeDeystvie_7232 => 'Необратимое действие';
  @override
  String get tema_9e26 => 'Тема';
  @override
  String get temnayaTema_cb48 => 'Тёмная тема';
  @override
  String get pereklyuchitMezhduTemnymISvetlym_5415 => 'Переключить между тёмным и светлым режимом';
  @override
  String get razmerShrifta_1155 => 'Размер шрифта';
  @override
  String get a_87a0 => 'А';
  @override
  String get pokazyvatVsplyvayuschieUvedomleniya_754e => 'Показывать всплывающие уведомления';
  @override
  String get zvuk_9329 => 'Звук';
  @override
  String get vosproizvoditZvukPriNovomSoobschenii_47cc => 'Воспроизводить звук при новом сообщении';
  @override
  String get osnovnyeNastroyki_231c => 'Основные настройки';
  @override
  String get rezhimEkonomiiEnergii_edfc => 'Режим экономии энергии';
  @override
  String get optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb => 'Оптимизирует работу приложения для экономии ресурсов';
  @override
  String get avtomaticheskiySpyaschiyRezhim_5955 => 'Автоматический спящий режим';
  @override
  String get perevoditPrilozhenieVSpyaschiyRezhim_1c07 => 'Переводит приложение в спящий режим при неактивности';
  @override
  String get animatsii_05c7 => 'Анимации';
  @override
  String get uproschennyeAnimatsii_3a13 => 'Упрощённые анимации';
  @override
  String get umenshaetKolichestvoAnimatsiyInterfeysa_6bf1 => 'Уменьшает количество анимаций интерфейса';
  @override
  String get skoroBudetDostupno_de07 => 'Скоро будет доступно';
  @override
  String get gostevoyRezhim_6d82 => 'Гостевой режим';
  @override
  String get voyditeDlyaDostupaKAkkauntu_a5c8 => 'Войдите для доступа к аккаунту';
  @override
  String get nazhmiteDlyaProsmotraIzmeneniy_0255 => 'Нажмите для просмотра изменений';
  @override
  String get vvediteKodPodtverzhdeniya_61af => 'Введите код подтверждения';
  @override
  @override
  String get nevernyyKodPodtverzhdeniya_7762 => 'رمز التحقق غير صالحة';
  @override
  String get podtverditeEMail_4bd4 => 'Подтвердите e-mail';
  @override
  String get proverit_340b => 'Проверить';
  @override
  @override
  String get otpravitKodPovtorno_7703 => 'إعادة إرسال الرمز';
  @override
  String get sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e => 'Современное десктопное приложение\nс красивым интерфейсом и 3D эффектами';
  @override
  String get tehnologii_6332 => 'Технологии';
  @override
  String get vyNashliPashalku_1a57 => '🎉 Вы нашли пасхалку! 🎉';
  @override
  String get spasiboZaIspolzovanieXaneo_d079 => 'Спасибо за использование xaneo!';
  @override
  String get globalnyyPoisk_77bf => 'ГЛОБАЛЬНЫЙ ПОИСК';
  @override
  @override
  String get poiskKontaktovChatovKanalovBotov_db66 => 'البحث عن جهات الاتصال، الدردشات، القنوات، البوتات...';
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
  String get vvediteZaprosDlyaPoiskaPo_9955 => 'أدخل الاستعلام للبحث في شبكة Xaneo';
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
  String get versiya_3725 => 'Версия';
  @override
  String get tehnicheskayaInformatsiya_ba0f => 'Техническая информация';
  @override
  String get platforma_8848 => 'Платформа';
  @override
  String get arhitekturaProtsessora_c079 => 'Архитектура процессора';
  @override
  String get posmotretNaGithub_5238 => 'Посмотреть на GitHub';
  @override
  String get zakryt_dd94 => 'Закрыть';
  @override
  String get vklyuchitTemnuyuTemu_ed17 => 'Включить тёмную тему';
  @override
  String get vklyuchitUvedomleniya_d311 => 'Включить уведомления';
  @override
  String get kastomnyyOverleyXaneo_7d39 => 'Кастомный оверлей Xaneo';
  @override
  String get animirovannyeUvedomleniyaSBystrymOtvetom_a25d => 'Анимированные уведомления с быстрым ответом';
  @override
  String get aaBbVv_1c6b => 'Aa Бб Вв';
  @override
  String get pleylist_a04c => 'ПЛЕЙЛИСТ';
  @override
  String get spisokMuzyki_d477 => 'СПИСОК МУЗЫКИ';
  @override
  String get loc_0B_5a4d => '0 Б';
  @override
  String get b_3b67 => 'Б';
  @override
  String get kb_419d => 'КБ';
  @override
  String get mb_b808 => 'МБ';
  @override
  String get gb_e572 => 'ГБ';
  @override
  String get audiozapis_867d => 'Аудиозапись';
  @override
  String get muzykalnyyTrek_b15d => 'Музыкальный трек';
  @override
  String get muzykalnyeTrekiOtsutstvuyut_3301 => 'Музыкальные треки отсутствуют';
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
  String get neobhodimoPrinyatUsloviyaISoglasie_e31e => 'يجب عليك قبول شروط الاستخدام وسياسة الخصوصية';
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
  String get nikneymDolzhenBytUnikalnym_952d => 'يجب أن يكون اسم المستخدم فريدًا';
  @override
  @override
  String get myOtpravimKodPodtverzhdeniya_fc71 => 'سنرسل رمز التحقق إلى بريدك الإلكتروني';
  @override
  @override
  String get vvedite6ZnachnyyKodIz_f22f => 'أدخل الرمز المكون من 6 أرقام';
  @override
  @override
  String get pridumayteNadezhnyyParol_2312 => 'أنشئ كلمة مرور قوية (8 أحرف على الأقل)';
  @override
  @override
  String get povtoriteParolEscheRaz_6723 => 'كرر كلمة المرور مرة أخرى';
  @override
  @override
  String get etoNeobyazatelnoNoPriyatno_b6a3 => 'هذا اختياري ولكن يوصى به';
  @override
  @override
  String get proverteVashiDannyeIPrimite_3121 => 'راجع بياناتك ووافق على الشروط';
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
  String get yaPrinimayuUsloviyaIspolzovaniya_391a => 'أوافق على شروط الاستخدام';
  @override
  @override
  String get yaSoglasenNaObrabotkuPersonalnyh_f2a8 => 'أوافق على معالجة البيانات الشخصية';
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
  String get vklyuchitTemnuyuTemuOformleniya_86c4 => 'Включить тёмную тему оформления';
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
  String get oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b => 'Ошибка восстановления ключей (не удалось перезаписать)';
  @override
  String get kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7 => 'Критическая ошибка при пересоздании ключей шифрования';
  @override
  String get oshibkaZagruzkiKlyucheyNaServer_ff9b => 'Ошибка загрузки ключей на сервер';
  @override
  String get oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4 => 'Ошибка при получении ключей шифрования';
  @override
  String get prevyshenLimitV5Akkauntov_a6a9 => 'Превышен лимит в 5 аккаунтов на этом клиенте или ошибка подключения.';
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
  String get vvediteSvoiDannyeDlyaDostupa_319e => 'أدخل بيانات الاعتماد الخاصة بك للوصول إلى الرسائل.';
  @override
  @override
  String get voyti_63a7 => 'تسجيل الدخول';
  @override
  String get sobesednik_7025 => 'Собеседник';
  @override
  String get vy_0101 => 'Вы';
  @override
  String get vyDelitesSvoimEkranom_16b1 => 'Вы делитесь своим экраном';
  @override
  String get polzovatel_f154 => 'Пользователь';
  @override
  String get ishodyaschiyVyzov_650b => 'Исходящий вызов...';
  @override
  String get vhodyaschiyVyzov_19ff => 'Входящий вызов...';
  @override
  String get podklyucheno_d022 => 'Подключено';
  @override
  String get ozhidanieOtveta_a984 => 'Ожидание ответа...';
  @override
  String get razgovorPoAudiosvyazi_3ed7 => 'Разговор по аудиосвязи';
  @override
  String get translyatsiyaVashegoEkranaZapuschena_575a => 'Трансляция вашего экрана запущена';
  @override
  String get sobesednikViditVseChtoProishodit_c759 => 'Собеседник видит всё, что происходит на вашем рабочем столе';
  @override
  String get vhodyaschiyVyzov_905e => 'ВХОДЯЩИЙ ВЫЗОВ';
  @override
  String get neizvestnyy_be89 => 'Неизвестный';
  @override
  String get videozvonok_dd18 => 'Видеозвонок...';
  @override
  String get golosovoyZvonok_5410 => 'Голосовой звонок...';
  @override
  String get otklonit_8b0d => 'Отклонить';
  @override
  String get otvetit_e568 => 'Ответить';
  @override
  String get gruppovoyZvonok_dac1 => 'Групповой звонок';
  @override
  String get podklyuchenieKZvonku_e2cf => 'Подключение к звонку...';
  @override
  String get podklyuchenieKVeschaniyu_038b => 'Подключение к вещанию...';
  @override
  String get uchastnik_cffb => 'Участник';
  @override
  String get vy_479c => 'ВЫ';
  @override
  String get svernut_ca9f => 'Свернуть';
  @override
  String get vhodyaschiyVyzov_d2f3 => 'Входящий вызов';
  @override
  String get novoeSoobschenie_1d49 => 'Новое сообщение';
  @override
  String get vashOtvet_40c2 => 'Ваш ответ...';
  @override
  String get videovyzov_3353 => 'Видеовызов...';
  @override
  String get audiovyzov_bbb5 => 'Аудиовызов...';
  @override
  String get nachatZvonok_3d26 => 'НАЧАТЬ ЗВОНОК';
  @override
  String get golosovoyZvonok_b615 => 'Голосовой звонок';
  @override
  String get pozvonitPoGolosovoySvyazi_4069 => 'Позвонить по голосовой связи';
  @override
  String get videozvonok_8142 => 'Видеозвонок';
  @override
  String get pozvonitSVklyuchennoyKameroy_fb05 => 'Позвонить с включенной камерой';
  @override
  String get zashifrovannoeSoobschenie_ca35 => '[Зашифрованное сообщение]';
  @override
  String get golosovoeSoobschenie_4a85 => '🎤 Голосовое сообщение';
  @override
  String get videosoobschenie_d687 => '🎬 Видеосообщение';
  @override
  String get fayl_826d => '📎 Файл';
  @override
  String get zvonok_e8d5 => '📞 Звонок';
  @override
  String get oshibkaDeshifrovaniya_4146 => '[Ошибка дешифрования]';
  @override
  String get zapisyvaetGolosovoe_2a5c => 'записывает голосовое...';
  @override
  String get pechataet_812c => 'печатает...';
  @override
  String get neUdalosArhivirovatChat_ab89 => 'Не удалось архивировать чат';
  @override
  String get neUdalosRazarhivirovatChat_f0d7 => 'Не удалось разархивировать чат';
  @override
  String get arhiv_56aa => 'Архив';
  @override
  String get netUserid_634a => '[Нет userId]';
  @override
  String get netKlyucha_337b => '[Нет ключа]';
  @override
  String get neizvestnyyTipChata_2617 => '[Неизвестный тип чата]';
  @override
  String get neUdalosPoluchitKlyuchShifrovaniya_b953 => 'Не удалось получить ключ шифрования для чата';
  @override
  String get gruppa_19c2 => 'группа';
  @override
  String get uchastnik_5bce => 'участник';
  @override
  String get uchastnika_92d9 => 'участника';
  @override
  String get uchastnikov_5d6b => 'участников';
  @override
  String get kanal_64ec => 'канал';
  @override
  String get podpischik_695a => 'подписчик';
  @override
  String get podpischika_b490 => 'подписчика';
  @override
  String get podpischikov_ba39 => 'подписчиков';
  @override
  String get segodnya_9626 => 'Сегодня';
  @override
  String get vchera_61d4 => 'Вчера';
  @override
  String get yanvarya_d861 => 'января';
  @override
  String get fevralya_fcf9 => 'февраля';
  @override
  String get marta_bb77 => 'марта';
  @override
  String get aprelya_2b5a => 'апреля';
  @override
  String get maya_4dbb => 'мая';
  @override
  String get iyunya_adcb => 'июня';
  @override
  String get iyulya_3236 => 'июля';
  @override
  String get avgusta_e3aa => 'августа';
  @override
  String get sentyabrya_a146 => 'сентября';
  @override
  String get oktyabrya_7abd => 'октября';
  @override
  String get noyabrya_6e78 => 'ноября';
  @override
  String get dekabrya_29cc => 'декабря';
  @override
  String get vyPodpisalisNaKanal_b2b3 => 'Вы подписались на канал';
  @override
  String get vyPrisoedinilisKGruppe_07bd => 'Вы присоединились к группе';
  @override
  String get neUdalosPrisoedinitsya_31e6 => 'Не удалось присоединиться';
  @override
  String get vyOtpisalisOtKanala_7698 => 'Вы отписались от канала';
  @override
  String get vyPokinuliGruppu_5a52 => 'Вы покинули группу';
  @override
  String get neUdalosVypolnitDeystvie_3cfd => 'Не удалось выполнить действие';
  @override
  String get neUdalosPereklyuchitAkkaunt_968b => 'Не удалось переключить аккаунт';
  @override
  String get media_c247 => 'Медиа';
  @override
  String get fayly_200c => 'Файлы';
  @override
  String get golos_2d89 => 'Голос';
  @override
  String get ssylki_9f58 => 'Ссылки';
  @override
  String get profil_c62a => 'ПРОФИЛЬ';
  @override
  String get imyaPolzovatelya_6fd4 => 'Имя пользователя';
  @override
  String get denRozhdeniya_e41d => 'День рождения';
  @override
  String get polzovatelSkrylInformatsiyuOSebe_f416 => 'Пользователь скрыл информацию о себе';
  @override
  String get god_6270 => 'год';
  @override
  String get goda_7443 => 'года';
  @override
  String get let_257a => 'лет';
  @override
  String get skopirovano_f70b => 'Скопировано';
  @override
  String get akkaunty_80b5 => 'АККАУНТЫ';
  @override
  String get dobavitAkkaunt_5253 => 'Добавить аккаунт';
  @override
  String get limit5Akkauntov_fdb7 => 'Лимит: 5 аккаунтов';
  @override
  String get nazadKChatam_7edb => 'Назад к чатам';
  @override
  String get chaty_19ad => 'Чаты';
  @override
  String get globalnyyPoisk_7ff2 => 'Глобальный поиск';
  @override
  String get arhivPust_3e22 => 'Архив пуст';
  @override
  String get netSoobscheniy_29d4 => 'Нет сообщений';
  @override
  String get toDoList_27e1 => '📋 To-Do лист';
  @override
  String get opros_6ff1 => '🗳️ Опрос';
  @override
  String get fotografiya_5709 => '📷 Фотография';
  @override
  String get razarhivirovat_416b => 'Разархивировать';
  @override
  String get vArhiv_ce22 => 'В архив';
  @override
  String get chat_c52b => 'Чат';
  @override
  String get vyberiteChatDlyaNachalaObscheniya_36a5 => 'Выберите чат для начала общения';
  @override
  String get bot_2712 => 'бот';
  @override
  String get vSeti_d902 => 'в сети';
  @override
  String get neVSeti_ee01 => 'не в сети';
  @override
  String get nastroykiChata_1e0d => 'Настройки чата';
  @override
  String get pokinutGruppu_e6ce => 'Покинуть группу';
  @override
  String get prisoedinitsyaKGruppe_eb45 => 'Присоединиться к группе';
  @override
  String get otpisatsyaOtKanala_fdbc => 'Отписаться от канала';
  @override
  String get podpisatsyaNaKanal_2dad => 'Подписаться на канал';
  @override
  String get netSoobscheniyNapishiteChtoNibud_2bf4 => 'لا توجد رسائل بعد. اكتب شيئاً!';
  @override
  String get prisoedinilsyaKChatu_f623 => 'присоединился к чату';
  @override
  String get pokinulChat_d567 => 'покинул чат';
  @override
  String get podpisalsyaNaKanal_0673 => 'подписался на канал';
  @override
  String get otpisalsyaOtKanala_fa13 => 'отписался от канала';
  @override
  String get polzovatelya_1083 => 'пользователя';
  @override
  String get priglasil_47ae => 'пригласил';
  @override
  String get rasshifrovka_e47f => '[Расшифровка...]';
  @override
  String get sistemnoeSoobschenie_d2bd => 'Системное сообщение';
  @override
  String get soobschenie_3715 => 'Сообщение';
  @override
  String get videosoobschenie_57f1 => '📹 Видеосообщение';
  @override
  String get spisokZadach_cfa4 => '📋 Список задач';
  @override
  String get opros_5902 => '📊 Опрос';
  @override
  String get vlozhenie_ef44 => 'Вложение';
  @override
  String get fayl_2d46 => 'Файл';
  @override
  String get zagruzkaFayla_f817 => 'Загрузка файла...';
  @override
  String get ishodyaschiyZvonok_8381 => 'Исходящий звонок';
  @override
  String get razgovorNeSostoyalsya_67fb => 'Разговор не состоялся';
  @override
  String get vhodyaschiyZvonok_5ce9 => 'Входящий звонок';
  @override
  String get otklonennyyZvonok_d499 => 'Отклонённый звонок';
  @override
  String get vyOtkloniliVyzov_8d1d => 'Вы отклонили вызов';
  @override
  String get propuschennyyZvonok_e98d => 'Пропущенный звонок';
  @override
  String get vyPropustiliVyzov_f17a => 'Вы пропустили вызов';
  @override
  String get vlozhenie_2474 => '📎 Вложение';
  @override
  String get tb_0e05 => 'ТБ';
  @override
  String get zapisGolosovogo_9c91 => 'Запись голосового...';
  @override
  String get zapisVideo_dd2a => 'Запись видео...';
  @override
  String get otpustiteDlyaOtpravki_ea7b => 'Отпустите для отправки';
  @override
  String get emodzi_f822 => 'Эмодзи';
  @override
  String get panelEmodziVRazrabotke_b6ce => 'Панель эмодзи в разработке';
  @override
  String get napisatSoobschenie_62d4 => 'Написать сообщение...';
  @override
  String get dobavitVlozhenie_769b => 'Добавить вложение';
  @override
  String get spisokZadach_1852 => 'Список задач';
  @override
  String get opros_9f36 => 'Опрос';
  @override
  String get zapisGolosovogoGs_db4e => 'Запись голосового (ГС)';
  @override
  String get zapisVideoVs_9676 => 'Запись видео (ВС)';
  @override
  String get uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3 => '• Удерживайте кнопку для записи\n• Нажмите для переключения режима';
  @override
  @override
  String get novyyChat_f775 => 'محادثة جديدة';
  @override
  @override
  String get imyaPolzovatelyaMin5Simvolov_1232 => 'اسم المستخدم (5 أحرف على الأقل)';
  @override
  @override
  String get vvedite5IliBoleeSimvolov_f983 => 'أدخل 5 أحرف أو أكثر';
  @override
  @override
  String get polzovateliNeNaydeny_c01a => 'لم يتم العثور على مستخدمين';
  @override
  String get mnozhestvennyyVybor_9b60 => 'Множественный выбор';
  @override
  String get odinochnyyVybor_d920 => 'Одиночный выбор';
  @override
  String get netGolosov_17d0 => 'Нет голосов';
  @override
  String get golos_6b94 => 'голос';
  @override
  String get golosa_bb8d => 'голоса';
  @override
  String get golosov_7f51 => 'голосов';
  @override
  String get nePoluchenIdFaylaOt_86c8 => 'Не получен ID файла от сервера';
  @override
  String get faylZagruzhenIPrikreplen_dc24 => 'Файл загружен и прикреплен';
  @override
  String get neizvestnayaOshibkaZagruzki_68cb => 'Неизвестная ошибка загрузки';
  @override
  String get oshibkaZagruzkiFayla_86e5 => 'Ошибка загрузки файла';
  @override
  String get sohranitFaylKak_0f93 => 'Сохранить файл как';
  @override
  String get oshibkaSkachivaniyaFayla_34ac => 'Ошибка скачивания файла';
  @override
  String get bezNazvaniya_6584 => 'Без названия';
  @override
  String get bezVoprosa_d390 => 'Без вопроса';
  @override
  String get netDostupaKMikrofonu_a4ef => 'Нет доступа к микрофону';
  @override
  String get zapisVideoCherezPlaginCamera_b9dd => '📹 Запись видео через плагин camera запущена';
  @override
  String get kameraNeInitsializirovanaNaEtoy_21e0 => '📹 Камера не инициализирована на этой платформе.';
  @override
  String get kameraNeGotova_9f09 => 'Камера не готова';
  @override
  String get zapisVideosoobscheniyaNaEtoyPlatforme_a561 => '📹 Запись видеосообщения на этой платформе недоступна напрямую.';
  @override
  String get arecordOstanovlen_edf2 => '🎙️ arecord остановлен';
  @override
  String get ffmpegOstanovlen_63a0 => '📹 ffmpeg остановлен';
  @override
  String get zapisSlishkomKorotkaya_5cda => 'Запись слишком короткая';
  @override
  String get oshibkaZapisiFaylPust_106b => 'Ошибка записи: файл пуст';
  @override
  String get videosoobschenieOtpravlenoSimulyatsiya_fb29 => 'Видеосообщение отправлено (симуляция)';
  @override
  String get zapisOtmenena_1609 => 'Запись отменена';
  @override
  String get otpravitGolosovoeSoobschenie_2481 => 'Отправить голосовое сообщение';
  @override
  String get imitatsiyaZapisiGolosovogoSoobscheniya_81e7 => 'Имитация записи голосового сообщения.';
  @override
  String get otpravit_6da0 => 'Отправить';
  @override
  String get sozdatToDo_8c92 => 'СОЗДАТЬ TO-DO';
  @override
  String get nazvanieSpiska_c3cc => 'Название списка';
  @override
  String get punkty_0481 => 'Пункты:';
  @override
  String get dobavitPunkt_930c => 'Добавить пункт';
  @override
  String get sozdat_b059 => 'Создать';
  @override
  String get sozdatOpros_4b9e => 'СОЗДАТЬ ОПРОС';
  @override
  String get vopros_0911 => 'Вопрос';
  @override
  String get variantyOtveta_ef4e => 'Варианты ответа:';
  @override
  String get dobavitVariant_76be => 'Добавить вариант';
  @override
  String get golosovoeSoobschenie_33d5 => 'Голосовое сообщение';
  @override
  String get videosoobschenie_2951 => 'Видеосообщение';
  @override
  String get video_a095 => 'Видео';
  @override
  String get neUdalosZagruzitIzobrazhenie_3fa0 => 'Не удалось загрузить изображение';
  @override
  String get muzyka_0660 => 'Музыка';
  @override
  String get netDannyh_dee9 => 'Нет данных';
  @override
  String get istoriyaSoobscheniyPustaIliChat_2d07 => 'История сообщений пуста или чат еще не сохранен локально';
  @override
  String get obschieMaterialy_11e4 => 'Общие материалы';
  @override
  String get netMediafaylov_08d2 => 'Нет медиафайлов';
  @override
  String get zdesBudutOtobrazhatsyaObschieFoto_9bc7 => 'Здесь будут отображаться общие фото и видео';
  @override
  String get netFaylov_e95e => 'Нет файлов';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c => 'Здесь будут отображаться отправленные файлы';
  @override
  String get netGolosovyhSoobscheniy_2427 => 'Нет голосовых сообщений';
  @override
  String get zdesBudutOtobrazhatsyaGolosovyeI_0a73 => 'Здесь будут отображаться голосовые и видеосообщения';
  @override
  String get netSsylok_b0ec => 'Нет ссылок';
  @override
  String get zdesBudutOtobrazhatsyaObschieSsylki_6b61 => 'Здесь будут отображаться общие ссылки';
  @override
  String get ssylkaSkopirovanaVBufer_c16e => 'Ссылка скопирована в буфер';
  @override
  String get netMuzyki_1ca3 => 'Нет музыки';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23 => 'Здесь будут отображаться отправленные треки';
  @override
  String get udalennyyAkkaunt_ce47 => 'удалённый аккаунт';
  @override
  String get opisanie_38ca => 'Описание';
  @override
  String get mobilnyy_5ac7 => 'Мобильный';
  @override
  String get bylANedavno_168d => 'был(-а) недавно';
  @override
  String get minutu_5373 => 'минуту';
  @override
  String get minuty_5bc9 => 'минуты';
  @override
  String get minut_b877 => 'минут';
  @override
  String get nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a => 'Нажмите, чтобы загрузить новую версию';
  @override
  String get poiskLyudeyBotovGrupp_e84e => 'Поиск людей, ботов, групп...';
  @override
  String get vveditePoiskovyyZapros_0b8c => 'Введите поисковый запрос';
  @override
  String get polzovateli_b8c4 => 'Пользователи';
  @override
  String get moiLichnyeSoobscheniya_7d3b => 'Мои личные сообщения';
  @override
  String get sozdatNovyyChat_fd41 => 'Создать новый чат';
  @override
  String get lichnyyChat_cbec => 'Личный чат';
  @override
  String get nachatObschenieSPolzovatelem_0578 => 'Начать общение с пользователем';
  @override
  String get sozdatGruppu_459f => 'Создать группу';
  @override
  String get gruppovoyChatDlyaObscheniyaS_01ba => 'Групповой чат для общения с друзьями';
  @override
  String get sozdatKanal_9022 => 'Создать канал';
  @override
  String get kanalDlyaShirokoyAuditorii_9dba => 'Канал для широкой аудитории';
  @override
  String get redaktirovanie_1167 => 'Редактирование';
  @override
  String get vlevo_1af1 => 'Влево';
  @override
  String get vpravo_c316 => 'Вправо';
  @override
  String get poGor_ff50 => 'По гор.';
  @override
  String get poVert_b4a9 => 'По верт.';
  @override
  String get vvediteNazvanieGruppy_0a69 => 'Введите название группы';
  @override
  String get dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0 => 'Для публичной группы требуется никнейм (@username)';
  @override
  String get gruppaSozdana_6b3b => 'Группа создана';
  @override
  String get oshibkaPriSozdaniiGruppy_794e => 'Ошибка при создании группы';
  @override
  String get nazhmiteNaIkonkuChtobyVybrat_af03 => 'Нажмите на иконку, чтобы выбрать аватарку';
  @override
  String get nazvanieGruppy_9a39 => 'Название группы';
  @override
  String get opisanieNeobyazatelno_7812 => 'Описание (необязательно)';
  @override
  String get privatnayaGruppa_d20e => 'Приватная группа';
  @override
  String get publichnayaGruppa_50f8 => 'Публичная группа';
  @override
  String get vhodTolkoPoPriglasheniyu_97a1 => 'Вход только по приглашению';
  @override
  String get lyuboyMozhetNaytiIVstupit_5e26 => 'Любой может найти и вступить';
  @override
  String get publichnayaSsylkanikneymMyGroup_6640 => 'Публичная ссылка/никнейм (@my_group)';
  @override
  String get vvediteNazvanieKanala_5536 => 'Введите название канала';
  @override
  String get dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06 => 'Для публичного канала требуется ссылка/никнейм (@mychannel)';
  @override
  String get kanalSozdan_1522 => 'Канал создан';
  @override
  String get oshibkaPriSozdaniiKanala_7d4b => 'Ошибка при создании канала';
  @override
  String get nazvanieKanala_c548 => 'Название канала';
  @override
  String get privatnyyKanal_3139 => 'Приватный канал';
  @override
  String get publichnyyKanal_0f7c => 'Публичный канал';
  @override
  String get podpiskaTolkoPoPriglasheniyu_99c3 => 'Подписка только по приглашению';
  @override
  String get lyuboyMozhetNaytiIPodpisatsya_8579 => 'Любой может найти и подписаться';
  @override
  String get ssylkanikneymKanalaMychannel_79f6 => 'Ссылка/никнейм канала (@mychannel)';
  @override
  String get yazykInterfeysa_b78b => 'Язык интерфейса';
  @override
  String get dannyeUspeshnoSohraneny_2cc5 => 'Данные успешно сохранены';
  @override
  String get oshibkaPriSohranenii_126f => 'Ошибка при сохранении';
  @override
  String get lichnyeDannye_10a7 => 'ЛИЧНЫЕ ДАННЫЕ';
  @override
  String get nikneymUsername_8035 => 'Никнейм (@username)';
  @override
  String get nikneymNelzyaIzmenit_0b99 => 'Никнейм нельзя изменить';
  @override
  String get oSebeBio_b730 => 'О себе (Bio)';
  @override
  String get rasskazhiteNemnogoOSebe_3daa => 'Расскажите немного о себе...';
  @override
  String get nastroykiPrivatnostiSohraneny_447c => 'Настройки приватности сохранены';
  @override
  String get privatnost_3098 => 'ПРИВАТНОСТЬ';
  @override
  String get kommunikatsii_e9b8 => 'КОММУНИКАЦИИ';
  @override
  String get ktoMozhetPisat_3322 => 'Кто может писать';
  @override
  String get zapisGolosovyh_8073 => 'Запись голосовых';
  @override
  String get otpravkaFaylov_aaca => 'Отправка файлов';
  @override
  String get priglashatVGruppy_3631 => 'Приглашать в группы';
  @override
  String get vidimostProfilya_448f => 'ВИДИМОСТЬ ПРОФИЛЯ';
  @override
  String get ktoViditAvatar_b5d8 => 'Кто видит аватар';
  @override
  String get vremyaVSeti_be29 => 'Время в сети';
  @override
  String get vneshniyVid_5a0f => 'ВНЕШНИЙ ВИД';
  @override
  String get rezhimOformleniyaInterfeysa_b91d => 'Режим оформления интерфейса';
  @override
  String get pokazyvatVizualnyeEffektyIPerehody_3fd7 => 'Показывать визуальные эффекты и переходы';
  @override
  String get razmerTeksta_3c4f => 'Размер текста';
  @override
  String get bezopasnost_fcbc => 'БЕЗОПАСНОСТЬ';
  @override
  String get dvuhfaktornayaAutentifikatsiya_acdc => 'Двухфакторная аутентификация';
  @override
  String get zaschitaAkkaunta2fa_f1ab => 'Защита аккаунта 2FA';
  @override
  String get vklyucheno_6b96 => 'Включено';
  @override
  String get xaneoMobileAktivnoSeychas_3345 => 'Xaneo Mobile • Активно сейчас';
  @override
  String get zaschischennyyMessendzher_2f59 => 'Защищённый мессенджер';
  @override
  String get temnayaTema_6018 => 'Темная тема';
  @override
  String get vklyuchenaPoUmolchaniyu_7610 => 'Включена (по умолчанию)';
  @override
  String get setevoyFiltr_40c2 => 'Сетевой фильтр';
  @override
  String get vklyuchen_0994 => 'Включен';
  @override
  String get spisokMuzyki_57d0 => 'Список музыки';
  @override
  String get trek_5049 => 'трек';
  @override
  String get trekov_d3f4 => 'треков';
  @override
  String get pozhaluystaZapolniteVoprosIKak_7ad5 => 'Пожалуйста, заполните вопрос и как минимум два варианта ответа';
  @override
  String get sozdatOpros_8401 => 'Создать опрос';
  @override
  String get sozdatSpisokZadach_4018 => 'СОЗДАТЬ СПИСОК ЗАДАЧ';
  @override
  String get pozhaluystaZapolniteNazvanieIKak_3783 => 'Пожалуйста, заполните название и как минимум один пункт';
  @override
  String get sozdatSpisokZadach_0416 => 'Создать список задач';
  @override
  String get vhodyaschiyVideozvonok_14d4 => 'Входящий видеозвонок';
  @override
  String get prinyat_5dc5 => 'Принять';
  @override
  String get netObschihFaylov_bf77 => 'Нет общих файлов';
  @override
  String get neUdalosRazarhivirovatChatNa_b6f6 => 'Не удалось разархивировать чат на сервере';
  @override
  String get poiskVArhive_c5d8 => 'Поиск в архиве...';
  @override
  String get poprobuyteIzmenitZapros_52ea => 'Попробуйте изменить запрос';
  @override
  String get zdesBudutNahoditsyaVashiArhivirovannye_7359 => 'Здесь будут находиться ваши архивированные чаты';
  @override
  String get vernut_54aa => 'Вернуть';
  @override
  String get zashifrovannoeSoobschenie_c9ab => 'Зашифрованное сообщение';
  @override
  String get soobschenieNahoditsyaVysheVIstorii_dc90 => 'Сообщение находится выше в истории';
  @override
  String get otpravlyaetFoto_67c1 => 'отправляет фото...';
  @override
  String get otpravlyaetVideo_ce80 => 'отправляет видео...';
  @override
  String get otpravlyaetFayl_5e88 => 'отправляет файл...';
  @override
  String get ktoTo_8405 => 'Кто-то';
  @override
  String get trebuetsyaRazreshenieNaKameruI_06fa => 'Требуется разрешение на камеру и микрофон';
  @override
  String get kameraNeNaydena_208d => 'Камера не найдена';
  @override
  String get zapisVideoOtmenena_1db7 => 'Запись видео отменена';
  @override
  String get slishkomKorotkoeVideosoobschenie_4676 => 'Слишком короткое видеосообщение';
  @override
  String get pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35 => 'Пожалуйста, подождите окончания загрузки файлов';
  @override
  String get audiozvonok_dcf6 => 'Аудиозвонок';
  @override
  String get otpravitFotoVideoAudioIli_37e9 => 'Отправить фото, видео, аудио или другие файлы';
  @override
  String get provedenieGolosovaniyaVChate_a629 => 'Проведение голосования в чате';
  @override
  String get sozdatToDoSpisok_cb50 => 'Создать To-Do список';
  @override
  String get spisokZadachSOtmetkamiVypolneniya_c778 => 'Список задач с отметками выполнения';
  @override
  String get trebuetsyaRazreshenieNaZapisAudio_8175 => 'Требуется разрешение на запись аудио';
  @override
  String get slishkomKorotkoeSoobschenie_c2ee => 'Слишком короткое сообщение';
  @override
  String get uderzhivayteKnopkuDlyaZapisi_a762 => 'Удерживайте кнопку для записи';
  @override
  String get udalennyy_40c6 => 'удаленный';
  @override
  String get udalennyy_c2c8 => 'удалённый';
  @override
  String get neobhodimyRazresheniyaNaMikrofonI_224b => 'Необходимы разрешения на микрофон и камеру для совершения звонка';
  @override
  String get bylATolkoChto_9ac0 => 'был(-а) только что';
  @override
  String get chatNeNayden_ba4f => 'Чат не найден';
  @override
  String get napishitePervoeSoobschenie_8260 => 'Напишите первое сообщение';
  @override
  String get prisoedinitsyaKKanalu_f863 => 'Присоединиться к каналу';
  @override
  String get vyPodpisany_5fb9 => 'Вы подписаны';
  @override
  String get otpisatsya_ee2d => 'Отписаться';
  @override
  String get vyUspeshnoPodpisalisNaKanal_9c99 => 'Вы успешно подписались на канал!';
  @override
  String get vyUspeshnoVstupiliVGruppu_61a1 => 'Вы успешно вступили в группу!';
  @override
  String get neUdalosPrisoedinitsyaPoprobuyteEsche_bce5 => 'Не удалось присоединиться. Попробуйте еще раз.';
  @override
  String get vyrezat_a195 => 'Вырезать';
  @override
  String get kopirovat_112b => 'Копировать';
  @override
  String get vstavit_dcc4 => 'Вставить';
  @override
  String get vybratVse_4d09 => 'Выбрать все';
  @override
  String get zhirnyy_7774 => 'Жирный';
  @override
  String get kursiv_e0b1 => 'Курсив';
  @override
  String get kod_3f34 => 'Код';
  @override
  String get zacherknut_02fc => 'Зачеркнуть';
  @override
  String get soobschenie_8b9b => 'Сообщение...';
  @override
  String get smahniteDlyaOtmeny_e976 => 'Смахните для отмены';
  @override
  String get poisk_bfc9 => 'Поиск';
  @override
  String get udalitChat_4b2b => 'Удалить чат';
  @override
  String get udalitKanal_482f => 'Удалить канал';
  @override
  String get pozhalovatsya_a7d9 => 'Пожаловаться';
  @override
  String get redaktirovatGruppu_e40a => 'Редактировать группу';
  @override
  String get udalitGruppu_dff8 => 'Удалить группу';
  @override
  String get poiskSoobscheniyVremennoNedostupenV_4443 => 'Поиск сообщений временно недоступен в мобильной версии';
  @override
  String get zhalobaOtpravlenaModeratoram_4547 => 'Жалоба отправлена модераторам';
  @override
  String get redaktirovanieGruppyVremennoNedostupnoV_05d0 => 'Редактирование группы временно недоступно в мобильной версии';
  @override
  String get vyUverenyChtoHotiteOchistit_7c3a => 'Вы уверены, что хотите очистить историю сообщений в этом чате? Это действие нельзя отменить.';
  @override
  String get ochistit_7074 => 'Очистить';
  @override
  String get udalit_ed2b => 'Удалить';
  @override
  String get vyyti_0f05 => 'Выйти';
  @override
  String get oshibkaVosproizvedeniya_ac8a => 'Ошибка воспроизведения';
  @override
  String get novoeZashifrovannoeSoobschenie_4d30 => 'Новое зашифрованное сообщение';
  @override
  String get poiskChatov_779c => 'Поиск чатов...';
  @override
  String get obnovlenie_53e2 => 'Обновление...';
  @override
  String get soedinenie_5a58 => 'Соединение...';
  @override
  String get lichnye_4cb3 => 'Личные';
  @override
  String get neUdalosArhivirovatChatNa_36aa => 'Не удалось архивировать чат на сервере';
  @override
  String get oshibkaZagruzkiChatov_902f => 'Ошибка загрузки чатов';
  @override
  String get povtorit_b914 => 'Повторить';
  @override
  String get netChatov_85e3 => 'Нет чатов';
  @override
  String get nachniteNovyyRazgovor_8290 => 'Начните новый разговор';
  @override
  String get neUdalosZagruzitAkkaunty_8570 => 'Не удалось загрузить аккаунты';
  @override
  String get vyberiteAkkaunt_79e7 => 'Выберите аккаунт';
  @override
  String get bystryyVhodNaEtomUstroystve_3f30 => 'Быстрый вход на этом устройстве';
  @override
  String get voytiSParolem_9277 => 'Войти с паролем';
  @override
  String get sozdatXaneoId_4033 => 'Создать Xaneo ID';
  @override
  String get netSohranennyhAkkauntov_b669 => 'Нет сохранённых аккаунтов';
  @override
  String get tolkoChto_4493 => 'Только что';
  @override
  String get emailNedostupen_fc3e => 'Email недоступен';
  @override
  String get nevernyyKod_50f9 => 'Неверный код';
  @override
  String get oshibkaProverkiKoda_9018 => 'Ошибка проверки кода';
  @override
  String get neobhodimoRazreshenieNaDostupK_5f5c => 'Необходимо разрешение на доступ к фотографиям';
  @override
  String get oVyboreEmail_2609 => 'О выборе Email';
  @override
  String get podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0 => 'Поддерживаются все домены электронной почты, кроме ';
  @override
  String get zapreschennyh_1f49 => 'запрещённых';
  @override
  String get sozdatAkkaunt_19ed => 'Создать аккаунт';
  @override
  String get naprimerIvan_d7cb => 'Например, Иван';
  @override
  String get zadayteParol_53d2 => 'Задайте пароль';
  @override
  String get minimum8Simvolov_4ccd => 'Минимум 8 символов';
  @override
  String get unikalnoeImyaDlyaVashegoProfilya_a0ea => 'Уникальное имя для вашего профиля';
  @override
  String get vashEmail_879d => 'Ваш Email';
  @override
  String get dlyaSvyaziIVosstanovleniyaDostupa_c770 => 'Для связи и восстановления доступа';
  @override
  String get emailAdres_9130 => 'Email адрес';
  @override
  String get vvediteParolEscheRaz_7383 => 'Введите пароль ещё раз';
  @override
  String get parolEscheRaz_6daf => 'Пароль ещё раз';
  @override
  String get paroliNeSovpadayut_d82f => 'Пароли не совпадают';
  @override
  String get ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed => 'Укажите вашу реальную дату рождения';
  @override
  String get ddmmgggg_3524 => 'ДД.ММ.ГГГГ';
  @override
  String get sdelayteProfilUznavaemym_f2c5 => 'Сделайте профиль узнаваемым';
  @override
  String get profilGotov_b57d => 'Профиль готов';
  @override
  String get ostalosVsegoParaShagov_37e3 => 'Осталось всего пара шагов';
  @override
  String get yaPrinimayuPolzovatelskoeSoglashenie_c431 => 'Я принимаю Пользовательское соглашение';
  @override
  String get yaDayuSoglasieNaObrabotku_0d03 => 'Я даю согласие на обработку персональных данных';
  @override
  String get sVozvrascheniem_77ee => 'С возвращением';
  @override
  String get zagruzka_43e4 => 'Загрузка...';
  @override
  String get vyberiteAkkauntDlyaVhoda_d3a6 => 'Выберите аккаунт для входа';
  @override
  String get vvediteVashNikneym_51a6 => 'Введите ваш никнейм';
  @override
  String get voytiVDrugoyAkkaunt_d10f => 'Войти в другой аккаунт';
  @override
  String get nedavnieAkkaunty_953d => 'Недавние аккаунты';
  @override
  String get dobroPozhalovatVXaneo_66d0 => 'Добро пожаловать в Xaneo';
  @override
  String get xaneoTeperIVMobilnom_e918 => 'Xaneo — теперь и в мобильном приложении! Данный мессенджер еще никогда не был таким удобным и быстрым.';
  @override
  String get mneUzheInteresno_5365 => 'Мне уже интересно';
  @override
  String get vseVashiDannyePodZaschitoy_b7d9 => 'Все ваши данные под защитой';
  @override
  String get vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e => 'Все сообщения защищены сквозным шифрованием. Ни на одном из этапов Xaneo не знает их содержимого.';
  @override
  String get prodolzhit_e9c3 => 'Продолжить';
  @override
  String get lokalnyeDataTsentry_f089 => 'Локальные дата центры';
  @override
  String get vashiDannyeNikogdaNePokidayut_f871 => 'Ваши данные никогда не покидают пределы страны и хранятся в защищенных дата центрах.';
  @override
  String get kodOtpravlenPovtorno_e109 => 'Код отправлен повторно';
  @override
  String get dvuhfaktornayanautentifikatsiya_bacc => 'Двухфакторная\nаутентификация';
  @override
  String get naVashEmailOtpravlen6_b457 => 'На ваш email отправлен 6-значный код';
  @override
  String get podtverdit_e260 => 'Подтвердить';
  @override
  String get nePoluchiliKodOtpravitPovtorno_c1d2 => 'Не получили код? Отправить повторно';
  @override
  String get imyaNikneymOSebe_7a8d => 'Имя, никнейм, о себе';
  @override
  String get zvonkiSoobscheniyaVidimostProfilya_f905 => 'Звонки, сообщения, видимость профиля';
  @override
  String get parolSessii2fa_de9e => 'Пароль, сессии, 2FA';
  @override
  String get prilozhenie_38aa => 'ПРИЛОЖЕНИЕ';
  @override
  String get temaRazmerTekstaAnimatsii_f0a8 => 'Тема, размер текста, анимации';
  @override
  String get pushUvedomleniyaZvuki_9cc2 => 'Push-уведомления, звуки';
  @override
  String get oPrilozhenii_77b2 => 'О ПРИЛОЖЕНИИ';
  @override
  String get versiya200Build200_0e7b => 'Версия 2.0.loc_0 (Build 200)';
  @override
  String get redaktirovatProfil_56ad => 'Редактировать профиль';
  @override
  String get dobavitKontakt_2903 => 'ДОБАВИТЬ КОНТАКТ';
  @override
  String get nikneymPolzovatelyaUsername_a6ff => 'Никнейм пользователя (@username)';
  @override
  String get otobrazhaemoeImyaNeobyazatelno_340a => 'Отображаемое имя (необязательно)';
  @override
  String get neUdalosNaytiIliDobavit_649f => 'Не удалось найти или добавить пользователя';
  @override
  String get ya_feef => 'Я';
  @override
  String get poiskKontaktov_9a71 => 'Поиск контактов...';
  @override
  String get spisokKontaktovPust_58c6 => 'Список контактов пуст';
  @override
  String get kontaktyNeNaydeny_1b08 => 'لم يتم العثور على جهات اتصال';
  @override
  String get messages => 'الرسائل';
  @override
  String get messageAnimations => 'رسوم الرسائل المتحركة';
  @override
  String get messageAnimationsDesc => 'إظهار الرسوم المتحركة عند الإرسال والاستلام';
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
  String subscribersCount(int count) => count == 1 ? 'مشترك واحد' : '$count مشتركين';


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
  String get savedMessagesDesc => 'مساحة التخزين السحابية الشخصية للملاحظات والملفات والرسائل';
  @override
  String get music => 'موسيقى';
  @override
  String get noSharedMusic => 'لا توجد موسيقى';
  @override
  String get secureDesktopCommunicator => 'تطبيق تواصل مكتبي آمن';
  @override
  String get noMessagesTitle => 'لا توجد رسائل';
  @override
  String get noMessagesSubtitle => 'أرسل رسالة لبدء المحادثة على Xaneo Connect!';
}
