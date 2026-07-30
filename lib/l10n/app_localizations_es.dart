import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Xaneo PC';

  @override
  String get welcomeTitle => 'Bienvenido a Xaneo';

  @override
  String get welcomeDescription => '¡Xaneo ahora está en tu computadora! Máximo rendimiento y comodidad.';

  @override
  String get getStartedButton => 'Comenzar';

  @override
  String get privacyTitle => 'Todos tus datos están seguros';

  @override
  String get privacyDescription => 'Todos los mensajes en Xaneo están protegidos con cifrado de extremo a extremo.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get dataStorageTitle => 'Todos los centros de datos de Xaneo están en Rusia';

  @override
  String get dataStorageDescription => 'Tus datos nunca salen del país y se almacenan en centros de datos seguros.';

  @override
  String get finishButton => 'Finalizar';

  @override
  String get setupCompleted => '¡Configuración completada!';

  @override
  String get loginFormTitle => 'Iniciar sesión';

  @override
  String get loginFieldHint => 'Usuario';

  @override
  String get passwordFieldHint => 'Contraseña';

  @override
  String get loginButton => 'Ingresar';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get fillAllFields => 'Por favor, llena todos los campos';

  @override
  String get loggingIn => 'Iniciando sesión...';

  @override
  String welcomeUser(String username) => '¡Bienvenido, $username!';

  @override
  String get invalidCredentials => 'Credenciales inválidas. Revisa tu usuario y contraseña.';

  @override
  String get serverError => 'Error del servidor. Inténtalo más tarde.';

  @override
  String get connectionError => 'Error de conexión. Revisa tu conexión a internet.';

  @override
  String get settings => 'Ajustes';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationsDescription => 'Activar o desactivar notificaciones';

  @override
  String get darkThemeDescription => 'Activar o desactivar tema oscuro';

  @override
  String fontSize(int size) => 'Tamaño de fuente: $size';

  @override
  String get language => 'Idioma';

  @override
  String get languageDescription => 'Selecciona el idioma de la interfaz';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get appVersion => 'Versión de la app';

  @override
  String get registerTitle => 'Registro';

  @override
  String get registerStep0Title => '¿Cómo te llamas?';

  @override
  String get registerStep0Subtitle => 'Ingresa tu nombre real';

  @override
  String get registerStep1Title => '¿Cuándo naciste?';

  @override
  String get registerStep1Subtitle => 'Debes tener al menos 14 años';

  @override
  String get registerStep2Title => 'Elige un apodo';

  @override
  String get registerStep2Subtitle => 'El apodo debe ser único';

  @override
  String get registerStep3Title => 'Tu correo electrónico';

  @override
  String get registerStep3Subtitle => 'Enviaremos un código de verificación';

  @override
  String get registerStep4Title => 'Crea una contraseña';

  @override
  String get registerStep4Subtitle => 'Crea una contraseña segura';

  @override
  String get registerStep5Title => 'Añade una foto';

  @override
  String get registerStep5Subtitle => 'Es opcional, pero genial';

  @override
  String get registerStep6Title => 'Último paso';

  @override
  String get registerStep6Subtitle => 'Acepta los términos de uso';

  @override
  String get yourName => 'Tu nombre';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get nickname => 'Apodo';

  @override
  String get checkingNickname => 'Comprobando disponibilidad...';

  @override
  String get nicknameAvailable => 'Apodo disponible';

  @override
  String get nicknameTaken => 'Apodo ocupado';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get addPhoto => 'Toca para añadir foto';

  @override
  String get removePhoto => 'Eliminar foto';

  @override
  String get acceptTerms => 'Acepto los términos de uso';

  @override
  String get acceptDataProcessing => 'Acepto el procesamiento de datos personales';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get finish => 'Finalizar';

  @override
  String get backToLogin => 'Volver al inicio';

  @override
  String get registrationSuccess => '¡Registro exitoso!';

  @override
  String get registrationError => 'Error de registro';

  @override
  String get enterVerificationCode => 'Ingresa el código de verificación';

  @override
  String get invalidVerificationCode => 'Código de verificación inválido';

  @override
  String get codeSent => 'Código enviado al correo';

  @override
  String get sendCodeError => 'Error al enviar código';

  @override
  String get confirmEmail => 'Confirmar correo';

  @override
  String codeSentToEmail(String email) => 'Enviamos un código de verificación a\n$email';

  @override
  String get verify => 'Verificar';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String resendIn(int count) => 'Reenviar en $count seg';

  @override
  String get acceptTermsRequired => 'Debes aceptar los términos y el tratamiento de datos';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutDescription => 'Una aplicación moderna para gestión y control.';

  @override
  String get close => 'Cerrar';

  @override
  String get technicalInfo => 'Información técnica';

  @override
  String get platform => 'Plataforma';

  @override
  String get architecture => 'Arquitectura del procesador';

  @override
  String get flutter => 'Flutter';

  @override
  String get viewOnGitHub => 'Ver en GitHub';

  @override
  String get chats => 'Chats';
  @override
  String get search => 'Buscar';
  @override
  String get searchPlaceholder => 'Buscar mensajes...';
  @override
  String get savedMessages => 'Mensajes guardados';
  @override
  String get online => 'en línea';
  @override
  String get offline => 'desconectado';
  @override
  String get lastSeenRecently => 'visto recientemente';
  @override
  String get musicPlaylist => 'Lista de música';
  @override
  String get reply => 'Responder';
  @override
  String get edit => 'Editar';
  @override
  String get pin => 'Fijar';
  @override
  String get unpin => 'Desfijar';
  @override
  String get delete => 'Eliminar';
  @override
  String get forward => 'Reenviar';
  @override
  String get members => 'Miembros';
  @override
  String get noMessages => 'No hay mensajes aún';

  @override
  String get joinedChat => 'se unió al chat';
  @override
  String get leftChat => 'salió del chat';
  @override
  String get subscribedChannel => 'se suscribió al canal';
  @override
  String get unsubscribedChannel => 'se desuscribió del canal';
  @override
  String get invited => 'invitó a';
  @override
  String get systemMessage => 'Mensaje del sistema';
  @override
  String get selectChatToStart => 'Selecciona un chat para empezar a conversar';
  @override
  String get toArchive => 'Archivar';
  @override
  String get unarchive => 'Desarchivar';
  @override
  String get archive => 'Archivo';
  @override
  String get archiveEmpty => 'El archivo está vacío';
  @override
  String get voiceMessage => 'Mensaje de voz';
  @override
  String get videoMessage => 'Mensaje de video';

  @override
  String get personalData => 'Datos personales';
  @override
  String get personalDataDesc => 'Nombre, apodo, foto de perfil';
  @override
  String get privacyDesc => 'Quién puede escribir, llamar o ver perfil';
  @override
  String get chatsSettings => 'Ajustes de chat';
  @override
  String get chatsSettingsDesc => 'Notificaciones, temas, historial';
  @override
  String get contacts => 'Contactos';
  @override
  String get contactsDesc => 'Tus contactos guardados';
  @override
  String get security => 'Seguridad';
  @override
  String get securityDesc => 'Sesiones, contraseña, autenticación';
  @override
  String get appearance => 'Apariencia';
  @override
  String get appearanceDesc => 'Tema, fuente, escala';
  @override
  String get energySaving => 'Ahorro de energía';
  @override
  String get energySavingDesc => 'Animaciones y rendimiento';

  @override
  String get account => 'CUENTA';
  @override
  String get interface => 'INTERFAZ';
  @override
  String get logout => 'Cerrar sesión';

  @override
  String get basicInfo => 'Información básica';
  @override
  String get nicknameCannotBeChanged => 'El apodo no se puede cambiar';
  @override
  String get aboutMe => 'Sobre mí';
  @override
  String get aboutMeHint => 'Cuenta algo sobre ti...';
  @override
  String get save => 'Guardar';
  @override
  String get saving => 'Guardando...';
  @override
  String get communications => 'Comunicaciones';
  @override
  String get whoCanMessage => 'Quién puede enviar mensajes';
  @override
  String get whoCanCall => 'Quién puede llamar';
  @override
  String get whoCanRecordVoice => 'Quién puede enviar notas de voz';
  @override
  String get whoCanSendFiles => 'Quién puede enviar archivos';
  @override
  String get whoCanInvite => 'Quién puede invitarme a grupos';
  @override
  String get profileVisibility => 'Visibilidad del perfil';
  @override
  String get whoSeesNickname => 'Quién ve mi apodo';
  @override
  String get everyone => 'Todos';
  @override
  String get contactsOnly => 'Solo contactos';
  @override
  String get nobody => 'Nadie';
  @override
  String get addContact => 'Añadir';
  @override
  String get addContactTitle => 'Añadir contacto';
  @override
  String get userNicknameHint => 'Apodo del usuario';
  @override
  String get displayNameOptional => 'Nombre visible (opcional)';
  @override
  String get noContactsYet => 'Aún no tienes contactos guardados';
  @override
  String get appInfo => 'Información de la aplicación';
  @override
  String get checkUpdates => 'Buscar actualizaciones';
  @override
  String get checkingUpdates => 'Buscando actualizaciones...';
  @override
  String get cancel => 'Cancelar';
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
  String get nikneym_3fea => 'Nombre de usuario';
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
  String get vse_984b => 'Todo';
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
  String get otmena_987b => 'Cancelar';
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
  String get nevernyyKodPodtverzhdeniya_7762 => 'Código de verificación incorrecto';
  @override
  String get podtverditeEMail_4bd4 => 'Подтвердите e-mail';
  @override
  String get proverit_340b => 'Проверить';
  @override
  @override
  String get otpravitKodPovtorno_7703 => 'Reenviar código';
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
  String get poiskKontaktovChatovKanalovBotov_db66 => 'Buscar contactos, chats, canales, bots...';
  @override
  @override
  String get lyudi_c7ae => 'Personas';
  @override
  @override
  String get gruppy_ebc4 => 'Grupos';
  @override
  @override
  String get kanaly_0c11 => 'Canales';
  @override
  @override
  String get boty_d6e4 => 'Bots';
  @override
  @override
  String get izbrannoe_2fc4 => 'Mensajes guardados';
  @override
  @override
  String get vvediteZaprosDlyaPoiskaPo_9955 => 'Escribe una consulta para buscar en la red Xaneo';
  @override
  @override
  String get nichegoNeNaydeno_8767 => 'No se encontraron resultados';
  @override
  @override
  String get izbrannoe_b637 => 'MENSAJES GUARDADOS';
  @override
  @override
  String get boty_800d => 'BOTS';
  @override
  @override
  String get kanaly_ccec => 'CANALES';
  @override
  @override
  String get gruppy_cfd6 => 'GRUPOS';
  @override
  @override
  String get polzovateli_e0ec => 'USUARIOS';
  @override
  @override
  String get sohranennyeSoobscheniya_6b62 => 'Mensajes guardados';
  @override
  @override
  String get bot_0ae1 => 'Bot';
  @override
  @override
  String get bot_0f46 => 'bot';
  @override
  @override
  String get gruppa_99d9 => 'Grupo';
  @override
  @override
  String get kanal_2710 => 'Canal';
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
  String get nikneymUzheZanyat_59aa => 'El nombre de usuario ya está ocupado';
  @override
  @override
  String get oshibkaProverki_2ab0 => 'Error de comprobación';
  @override
  @override
  String get emailUzheZanyat_17e1 => 'El correo electrónico ya está registrado';
  @override
  @override
  String get oshibkaOtpravkiKoda_a42a => 'Error al enviar el código de verificación';
  @override
  @override
  String get neobhodimoPrinyatUsloviyaISoglasie_e31e => 'Debes aceptar los términos de uso y política de privacidad';
  @override
  @override
  String get registratsiyaUspeshna_9d5c => '¡Registro exitoso!';
  @override
  @override
  String get oshibkaRegistratsii_b9f2 => 'Error de registro';
  @override
  @override
  String get nazad_2b0b => 'Volver';
  @override
  @override
  String get kakVasZovut_68b7 => '¿Cómo te llamas?';
  @override
  @override
  String get kogdaVyRodilis_26f2 => '¿Cuándo naciste?';
  @override
  @override
  String get pridumayteNikneym_221b => 'Crea un nombre de usuario';
  @override
  @override
  String get vashEmail_8bbd => 'Tu correo electrónico';
  @override
  @override
  String get podtverzhdenieEmail_281f => 'Verificación de correo';
  @override
  @override
  String get sozdayteParol_5f4c => 'Crea una contraseña';
  @override
  @override
  String get podtverzhdenieParolya_ebc2 => 'Confirma la contraseña';
  @override
  @override
  String get dobavteFoto_25eb => 'Añade una foto';
  @override
  @override
  String get posledniyShag_e0c5 => 'Último paso';
  @override
  @override
  String get vvediteVasheNastoyascheeImya_e656 => 'Introduce tu nombre real';
  @override
  @override
  String get vamDolzhnoBytNeMenee_1111 => 'Debes tener al menos 13 años';
  @override
  @override
  String get nikneymDolzhenBytUnikalnym_952d => 'El nombre de usuario debe ser único';
  @override
  @override
  String get myOtpravimKodPodtverzhdeniya_fc71 => 'Enviaremos un código de verificación a tu correo';
  @override
  @override
  String get vvedite6ZnachnyyKodIz_f22f => 'Introduce el código de 6 dígitos del correo';
  @override
  @override
  String get pridumayteNadezhnyyParol_2312 => 'Crea una contraseña segura (mín. 8 caract.)';
  @override
  @override
  String get povtoriteParolEscheRaz_6723 => 'Repite la contraseña';
  @override
  @override
  String get etoNeobyazatelnoNoPriyatno_b6a3 => 'Es opcional pero recomendado';
  @override
  @override
  String get proverteVashiDannyeIPrimite_3121 => 'Revisa tus datos y acepta los términos';
  @override
  @override
  String get registratsiya_0b93 => 'Registro';
  @override
  @override
  String get vasheImya_51eb => 'Tu nombre';
  @override
  @override
  @override
  String get proverkaDostupnosti_da13 => 'Comprobando disponibilidad...';
  @override
  @override
  @override
  String get nikneymDostupen_3fc9 => 'Nombre de usuario disponible';
  @override
  @override
  @override
  String get nikneymZanyat_8a5f => 'Nombre de usuario ocupado';
  @override
  @override
  @override
  String get emailDostupen_e903 => 'Correo disponible';
  @override
  @override
  @override
  String get emailZanyat_fb40 => 'Correo ocupado';
  @override
  @override
  String get kodPodtverzhdeniya_1c9d => 'Código de verificación';
  @override
  @override
  String get parol_5ebe => 'Contraseña';
  @override
  @override
  String get podtverditeParol_e3e3 => 'Confirma la contraseña';
  @override
  @override
  String get nazhmiteChtobyDobavitFoto_d6e8 => 'Toca para añadir foto';
  @override
  @override
  String get udalitFoto_3426 => 'Eliminar foto';
  @override
  @override
  String get yaPrinimayuUsloviyaIspolzovaniya_391a => 'Acepto los Términos de uso';
  @override
  @override
  String get yaSoglasenNaObrabotkuPersonalnyh_f2a8 => 'Acepto el tratamiento de datos personales';
  @override
  @override
  String get zavershit_b0e3 => 'Finalizar';
  @override
  @override
  String get dalee_c453 => 'Siguiente';
  @override
  @override
  String get dataRozhdeniya_505e => 'Fecha de nacimiento';
  @override
  String get vklyuchitTemnuyuTemuOformleniya_86c4 => 'Включить тёмную тему оформления';
  @override
  @override
  String get yanvar_ee86 => 'Enero';
  @override
  @override
  String get fevral_28ff => 'Febrero';
  @override
  @override
  String get mart_d766 => 'Marzo';
  @override
  @override
  String get aprel_03e9 => 'Abril';
  @override
  @override
  String get may_2e53 => 'Mayo';
  @override
  @override
  String get iyun_cfcb => 'Junio';
  @override
  @override
  String get iyul_89fb => 'Julio';
  @override
  @override
  String get avgust_de5a => 'Agosto';
  @override
  @override
  String get sentyabr_ebfb => 'Septiembre';
  @override
  @override
  String get oktyabr_1720 => 'Octubre';
  @override
  @override
  String get noyabr_66fb => 'Noviembre';
  @override
  @override
  String get dekabr_39b3 => 'Diciembre';
  @override
  @override
  String get pn_2c1e => 'Lun';
  @override
  @override
  String get vt_7145 => 'Mar';
  @override
  @override
  String get sr_c6e4 => 'Mié';
  @override
  @override
  String get cht_a51f => 'Jue';
  @override
  @override
  String get pt_0123 => 'Vie';
  @override
  @override
  String get sb_3a4b => 'Sáb';
  @override
  @override
  String get vs_4ad9 => 'Dom';
  @override
  @override
  String get gotovo_34e1 => 'Listo';
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
  String get oshibkaAvtorizatsii_9f5c => 'Error de autorización';
  @override
  @override
  @override
  String get oshibkaPodklyucheniyaKServeru_8b96 => 'Error de conexión al servidor';
  @override
  @override
  String get nazadKMessendzheru_de29 => 'Volver al mensajero';
  @override
  @override
  String get voytiVAkkaunt_c439 => 'Iniciar sesión';
  @override
  @override
  String get vvediteParol_1370 => 'Introduce la contraseña';
  @override
  @override
  String get vvediteSvoiDannyeDlyaDostupa_319e => 'Introduce tus datos para acceder a los mensajes.';
  @override
  @override
  String get voyti_63a7 => 'Iniciar sesión';
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
  String get netSoobscheniyNapishiteChtoNibud_2bf4 => 'Sin mensajes. ¡Escribe algo!';
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
  String get novyyChat_f775 => 'Nuevo chat';
  @override
  @override
  String get imyaPolzovatelyaMin5Simvolov_1232 => 'Nombre de usuario (mín. 5 caracteres)';
  @override
  @override
  String get vvedite5IliBoleeSimvolov_f983 => 'Introduce 5 o más caracteres';
  @override
  @override
  String get polzovateliNeNaydeny_c01a => 'No se encontraron usuarios';
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
  String get kontaktyNeNaydeny_1b08 => 'Contactos no encontrados';
  @override
  String get messages => 'Mensajes';
  @override
  String get messageAnimations => 'Animaciones de mensajes';
  @override
  String get messageAnimationsDesc => 'Mostrar animaciones al enviar y recibir';
  @override
  String get archivedChats => 'Chats archivados';
  @override
  String get archiveManagement => 'Gestión de archivo';
  @override
  String get clearHistory => 'Borrar historial';
  @override
  String get clearHistoryDesc => 'Eliminar todos los mensajes localmente';
  @override
  String get call => 'Llamar';
  @override
  String get sendMessage => 'Enviar mensaje';
  @override
  String get deleteContact => 'Eliminar contacto';
  @override
  String get activeSessions => 'Sesiones activas';
  @override
  String get thisDevice => 'Este dispositivo';
  @override
  String get xaneoPcActiveNow => 'Xaneo PC • Activo ahora';
  @override
  String get activeNow => 'Activo';
  @override
  String get twoFactorAuth => 'Autenticación en dos pasos';
  @override
  String get twoFactorAuthDesc => 'Proteger cuenta con contraseña de un solo uso';
  @override
  String get dangerZone => 'Zona de peligro';
  @override
  String get deleteAccount => 'Eliminar cuenta';
  @override
  String get irreversibleAction => 'Acción irreversible';
  @override
  String get theme => 'Tema';
  @override
  String get darkThemeDesc => 'Cambiar entre modo oscuro y claro';
  @override
  String get fontSizeText => 'Tamaño de fuente';
  @override
  String get showPopups => 'Mostrar notificaciones emergentes';
  @override
  String get sound => 'Sonido';
  @override
  String get soundDesc => 'Reproducir sonido con un nuevo mensaje';
  @override
  String get mainSettings => 'Ajustes principales';
  @override
  String get energySavingMode => 'Modo de ahorro de energía';
  @override
  String get energySavingModeDesc => 'Optimiza el rendimiento para ahorrar batería';
  @override
  String get autoSleep => 'Modo suspensión automático';
  @override
  String get autoSleepDesc => 'Pone la aplicación en suspensión al estar inactiva';
  @override
  String get animations => 'Animaciones';
  @override
  String get reducedMotion => 'Movimiento reducido';
  @override
  String get reducedMotionDesc => 'Reduce las animaciones de la interfaz';
  @override
  String get comingSoon => 'Próximamente';
  @override
  String get darkTheme => 'Tema oscuro';
  @override
  String get version => 'Versión';

  @override
  String get updateAvailable => 'Actualización disponible';
  @override
  String get clickToViewChanges => 'Haz clic para ver los cambios';
  @override
  String get newVersionAvailable => 'Nueva versión de la aplicación disponible';
  @override
  String get newVersionAvailableTitle => 'Nueva versión disponible';
  @override
  String get youHaveLatestVersion => 'Tienes la última versión instalada';
  @override
  String get whatsNew => 'Qué hay de nuevo';
  @override
  String get officialReleaseNotes => 'Notas oficiales de la versión disponibles en GitHub';
  @override
  String get preparingDownload => 'Preparando descarga...';
  @override
  String get installationStarted => 'Instalación iniciada...';
  @override
  String get whoSeesAvatar => 'Quién ve mi avatar';
  @override
  String get whoSeesBirthday => 'Quién ve mi cumpleaños';
  @override
  String get whoSeesOnlineTime => 'Quién ve mi última vez';


  @override
  String get downloadVersion => 'Descargar';
  @override
  String get downloadSource => 'Fuente de descarga';
  @override
  String get directInAppInstall => 'Instalación directa en la aplicación';
  @override
  String get autoDownloadAndRun => 'Descarga y lanzamiento automáticos';
  @override
  String get githubReleasePage => 'Página de lanzamiento en GitHub';
  @override
  String get skip => 'Omitir';
  @override
  String get updateAction => 'Actualizar';
  @override
  String get installAction => 'Instalando...';
  @override
  String get isTyping => 'escribiendo...';
  @override
  String get isRecordingVoice => 'grabando voz...';
  @override
  String get areTyping => 'escribiendo...';

  @override
  String membersCount(int count) => count == 1 ? '$count miembro' : '$count miembros';
  @override
  String subscribersCount(int count) => count == 1 ? '$count suscriptor' : '$count suscriptores';


  @override
  String get group => 'Grupo';
  @override
  String get channel => 'Canal';


  @override
  String get profile => 'Perfil';
  @override
  String get userHidInfo => 'El usuario ha ocultado su información';
  @override
  String get leaveGroup => 'Salir del grupo';
  @override
  String get joinGroup => 'Unirse al grupo';
  @override
  String get unsubscribeChannel => 'Desactivar suscripción';
  @override
  String get subscribeChannel => 'Suscribirse al canal';
  @override
  String get deleteChat => 'Eliminar chat';
  @override
  String get pinChat => 'Fijar';
  @override
  String get unpinChat => 'Desfijar';
  @override
  String get muteNotifications => 'Silenciar notificaciones';
  @override
  String get unmuteNotifications => 'Activar notificaciones';
  @override
  String get backToChats => 'Volver a los chats';
  @override
  String get globalSearch => 'Búsqueda global';
  @override
  String get chatSettings => 'Ajustes del chat';
  @override
  String get emoji => 'Emoji';
  @override
  String get attachFile => 'Adjuntar archivo';
  @override
  String get startCall => 'Iniciar llamada';
  @override
  String get audioCall => 'Llamada de voz';
  @override
  String get audioCallDesc => 'Llamar por voz';
  @override
  String get videoCall => 'Videollamada';


  @override
  String get copied => 'Copiado';

  @override
  String get copy => 'Copiar';

  @override
  String get voiceRecordTitle => 'Grabación de voz';
  @override
  String get videoRecordTitle => 'Grabación de video';
  @override
  String get holdToRecordHint => 'Mantenga presionado para grabar\nToque para cambiar modo';
  @override
  String get addAttachment => 'Adjuntar archivo';
  @override
  String get emojiPanelInDev => 'Panel de emojis en desarrollo';
  @override
  String get recordingVoice => 'Grabando voz...';
  @override
  String get recordingVideo => 'Grabando video...';
  @override
  String get releaseToSend => 'Suelte para enviar';
  @override
  String get videoCallDesc => 'Llamar con cámara';

  @override
  String get typeMessage => 'Escribir un mensaje...';
  @override
  String get file => 'Archivo';
  @override
  String get todoList => 'Lista de tareas';
  @override
  String get poll => 'Encuesta';

  @override
  String get today => 'Hoy';
  @override
  String get yesterday => 'Ayer';
  @override
  String get monthJan => 'enero';
  @override
  String get monthFeb => 'febrero';
  @override
  String get monthMar => 'marzo';
  @override
  String get monthApr => 'abril';
  @override
  String get monthMay => 'mayo';
  @override
  String get monthJun => 'junio';
  @override
  String get monthJul => 'julio';
  @override
  String get monthAug => 'agosto';
  @override
  String get monthSep => 'septiembre';
  @override
  String get monthOct => 'octubre';
  @override
  String get monthNov => 'noviembre';
  @override
  String get monthDec => 'diciembre';
  @override
  String get createTodo => 'CREAR TO-DO';
  @override
  String get listName => 'Título de la lista';
  @override
  String get todoItems => 'Elementos';
  @override
  String get addTodoItem => '+ Añadir elemento';
  @override
  String get itemHintPrefix => 'Elemento';
  @override
  String get createPoll => 'CREAR ENCUESTA';
  @override
  String get pollQuestion => 'Pregunta';
  @override
  String get pollOptions => 'Opciones';
  @override
  String get addPollOption => '+ Añadir opción';
  @override
  String get optionHintPrefix => 'Opción';
  @override
  String get allowMultipleAnswers => 'Permitir varias opciones';
  @override
  String get accountsTitle => 'CUENTAS';
  @override
  String get addAccount => 'Añadir cuenta';
  @override
  String get accountLimitNotice => 'Límite de 5 cuentas';

  @override
  String get singleChoice => 'Elección única';

  @override
  String get media => 'Multimedia';
  @override
  String get files => 'Archivos';
  @override
  String get voice => 'Voz';
  @override
  String get links => 'Enlaces';

  @override
  String get bio => 'Biografía';
  @override
  String get username => 'Nombre de usuario';
  @override
  String get birthday => 'Fecha de nacimiento';
  @override
  String get noSharedMedia => 'Sin archivos multimedia';
  @override
  String get noSharedFiles => 'Sin archivos';
  @override
  String get noSharedVoice => 'Sin mensajes de voz';
  @override
  String get noSharedLinks => 'Sin enlaces';

  @override
  String get savedMessagesDesc => 'Tu almacenamiento personal para notas, archivos y mensajes';
  @override
  String get music => 'Música';
  @override
  String get noSharedMusic => 'Sin música';
  @override
  String get secureDesktopCommunicator => 'mensajero de escritorio seguro';
  @override
  String get noMessagesTitle => 'Sin mensajes';
  @override
  String get noMessagesSubtitle => '¡Envía un mensaje para iniciar la conversación en Xaneo Connect!';
}
