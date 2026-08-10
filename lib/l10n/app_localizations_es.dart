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
  String get welcomeDescription =>
      '¡Xaneo ahora está en tu computadora! Máximo rendimiento y comodidad.';

  @override
  String get getStartedButton => 'Comenzar';

  @override
  String get privacyTitle => 'Todos tus datos están seguros';

  @override
  String get privacyDescription =>
      'Todos los mensajes en Xaneo están protegidos con cifrado de extremo a extremo.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get dataStorageTitle =>
      'Todos los centros de datos de Xaneo están en Rusia';

  @override
  String get dataStorageDescription =>
      'Tus datos nunca salen del país y se almacenan en centros de datos seguros.';

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
  String get invalidCredentials =>
      'Credenciales inválidas. Revisa tu usuario y contraseña.';

  @override
  String get serverError => 'Error del servidor. Inténtalo más tarde.';

  @override
  String get connectionError =>
      'Error de conexión. Revisa tu conexión a internet.';

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
  String get acceptDataProcessing =>
      'Acepto el procesamiento de datos personales';

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
  String codeSentToEmail(String email) =>
      'Enviamos un código de verificación a\n$email';

  @override
  String get verify => 'Verificar';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String resendIn(int count) => 'Reenviar en $count seg';

  @override
  String get acceptTermsRequired =>
      'Debes aceptar los términos y el tratamiento de datos';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutDescription =>
      'Una aplicación moderna para gestión y control.';

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
  String get obnovlenie_7e32 => 'ACTUALIZAR';
  @override
  String get obnovleniePrilozheniya_b6c3 => 'ACTUALIZACIÓN DE LA APLICACIÓN';
  @override
  String get podgotovkaKZagruzke_a5c7 => 'Preparándose para descargar...';
  @override
  String get ustanovkaZapuschena_d378 => '¡La instalación ha comenzado!';
  @override
  String get dostupnaNovayaVersiyaPrilozheniya_eeae =>
      'Nueva versión de la aplicación está disponible.';
  @override
  String get chtoNovogo_74e2 => 'QUE HAY DE NUEVO';
  @override
  String get ofitsialnoeOpisanieRelizaDostupnoNa_3ea3 =>
      'La descripción oficial del lanzamiento está disponible en la página de GitHub.';
  @override
  String get istochnikZagruzki_0e6e => 'DESCARGAR FUENTE';
  @override
  String get pryamayaUstanovkaVPrilozhenii_16f5 =>
      'Instalación directa en la aplicación.';
  @override
  String get avtomaticheskoeSkachivanieIZapusk_9a3f =>
      'Descarga y lanzamiento automáticos';
  @override
  String get stranitsaRelizaNaGithub_1531 => 'Página de lanzamiento en GitHub';
  @override
  String get propustit_03ee => 'Saltar';
  @override
  String get ustanovka_516d => 'Instalación...';
  @override
  String get obnovit_dbe5 => 'Actualizar';
  @override
  String get lichnyeDannye_be85 => 'Información personal';
  @override
  String get imyaNikneymFotoProfilya_28ac => 'Nombre, apodo, foto de perfil.';
  @override
  String get privatnost_0899 => 'Privacidad';
  @override
  String get ktoMozhetPisatZvonitVidet_1789 =>
      '¿Quién puede escribir, llamar, ver perfil?';
  @override
  String get nastroykiChatov_7ca8 => 'Configuración de chat';
  @override
  String get uvedomleniyaTemyIstoriya_51da =>
      'Notificaciones, temas, historial.';
  @override
  String get kontakty_7576 => 'Contactos';
  @override
  String get vashiSohranennyeKontakty_a641 => 'Tus contactos guardados';
  @override
  String get bezopasnost_3677 => 'Seguridad';
  @override
  String get sessiiParolAutentifikatsiya_73f5 =>
      'Sesiones, contraseña, autenticación.';
  @override
  String get vneshniyVid_6873 => 'Apariencia';
  @override
  String get temaShriftMasshtab_d8c9 => 'Tema, fuente, escala';
  @override
  String get yazyk_0577 => 'Idioma';
  @override
  String get yazykInterfeysaKlienta_2ad3 => 'Idioma de la interfaz del cliente';
  @override
  String get uvedomleniya_d2ed => 'Notificaciones';
  @override
  String get zvukiBannery_1b60 => 'Sonidos, pancartas';
  @override
  String get energosberezhenie_0b19 => 'Ahorro de energía';
  @override
  String get animatsiiIProizvoditelnost_fba8 => 'Animaciones y actuación';
  @override
  String get oPrilozhenii_322e => 'Acerca de la aplicación';
  @override
  String get versiyaProverkaObnovleniySsylki_6efc =>
      'Versión, buscar actualizaciones, enlaces';
  @override
  String get nastroyki_b01b => 'AJUSTES';
  @override
  String get nastroyki_c919 => 'Configuración';
  @override
  String get proverkaObnovleniy_f3e0 => 'Buscando actualizaciones...';
  @override
  String get neUdalosZagruzitNastroyki_f753 =>
      'No se pudo cargar la configuración';
  @override
  String get oshibkaSohraneniya_0387 => 'Error al guardar';
  @override
  String get dannyeSohraneny_fd62 => 'Datos guardados';
  @override
  String get gost_9618 => 'Invitado';
  @override
  String get akkaunt_38ac => 'CUENTA';
  @override
  String get interfeys_49be => 'INTERFAZ';
  @override
  String get vyytiIzAkkaunta_6d41 => 'Cerrar sesión en su cuenta';
  @override
  String get informatsiyaOPrilozhenii_00c4 => 'Información de la aplicación';

  @override
  String get proverka_13bc => 'Comprobando...';
  @override
  String get proveritObnovleniya_ab45 => 'Buscar actualizaciones';
  @override
  String get osnovnayaInformatsiya_6fec => 'Información básica';
  @override
  String get imya_d38d => 'Nombre';
  @override
  String get vvediteVasheImya_751e => 'Introduce tu nombre';
  @override
  @override
  String get nikneym_3fea => 'Nombre de usuario';
  @override
  String get nikneymNelzyaIzmenitVPrilozhenii_75d0 =>
      'El apodo no se puede cambiar en la aplicación.';
  @override
  String get oSebe_0b3b => 'Acerca de mi';
  @override
  String get rasskazhiteOSebe_1c37 => 'Cuéntanos sobre ti...';
  @override
  String get sohranenie_c15f => 'Guardando...';
  @override
  String get sohranit_74ea => 'Guardar';
  @override
  @override
  String get vse_984b => 'Todo';
  @override
  String get tolkoKontakty_a559 => 'Solo contactos';
  @override
  String get nikto_ba19 => 'nadie';
  @override
  String get kommunikatsii_1242 => 'Comunicaciones';
  @override
  String get ktoMozhetPisatSoobscheniya_4645 =>
      '¿Quién puede escribir mensajes?\nzxqendzx';
  @override
  String get ktoMozhetZvonit_c427 => 'quien puede llamar';
  @override
  String get ktoMozhetZapisyvatGolosovye_c69a => '¿Quién puede grabar voces?';
  @override
  String get ktoMozhetOtpravlyatFayly_2e40 => '¿Quién puede enviar archivos?';
  @override
  String get ktoMozhetPriglashatVGruppy_cdc0 =>
      '¿Quién puede invitar a grupos?';
  @override
  String get vidimostProfilya_34bf => 'Visibilidad del perfil';
  @override
  String get ktoViditMoyNikneym_54b8 => '¿Quién ve mi apodo?';
  @override
  String get ktoViditMoyAvatar_e9f6 => '¿Quién ve mi avatar?';
  @override
  String get ktoViditMoyDenRozhdeniya_ccc7 => '¿Quién ve mi cumpleaños?';
  @override
  String get ktoViditVremyaMoeyAktivnosti_4349 =>
      '¿Quién ve mi tiempo de actividad?';
  @override
  String get neUdalosZagruzitKontakty_02a3 =>
      'No se pudieron cargar los contactos';
  @override
  String get dobavitKontakt_4278 => 'Agregar un contacto';
  @override
  String get nikneymPolzovatelya_5610 => 'Apodo de usuario';
  @override
  String get otobrazhaemoeImyaOptsionalno_bbd1 =>
      'Nombre para mostrar (opcional)';
  @override
  @override
  String get otmena_987b => 'Cancelar';
  @override
  String get dobavit_5eba => 'Añadir';
  @override
  String get uVasPokaNetSohranennyh_b64b =>
      'Aún no tienes ningún contacto guardado';
  @override
  String get pozvonit_ccfa => 'llamar';
  @override
  String get napisat_0144 => 'escribir';
  @override
  String get udalitKontakt_065d => 'Eliminar contacto';
  @override
  String get soobscheniya_7e26 => 'Mensajes';
  @override
  String get animatsiiSoobscheniy_bc8b => 'Animaciones de mensajes';
  @override
  String get pokazyvatAnimatsiiPriOtpravkeI_d663 =>
      'Mostrar animaciones al enviar y recibir';
  @override
  String get arhivirovannyeChaty_d990 => 'Chats archivados';
  @override
  String get upravlenieArhivom_e843 => 'Gestión de archivos';
  @override
  String get ochistitIstoriyu_837a => 'Borrar historial';
  @override
  String get udalitVseSoobscheniyaLokalno_fbbd =>
      'Eliminar todos los mensajes localmente';
  @override
  String get aktivnyeSessii_5c96 => 'Sesiones activas';
  @override
  String get etoUstroystvo_26f6 => 'este dispositivo';
  @override
  String get xaneoPcAktivnoSeychas_25b4 => 'Xaneo PC • Activo ahora';
  @override
  String get aktivno_87a4 => 'Activo';
  @override
  String get dvoynayaAutentifikatsiya_66ae => 'Doble autenticación';
  @override
  String get zaschitaAkkauntaOdnorazovymParolem_e9f1 =>
      'Protección de cuenta con contraseña de un solo uso';
  @override
  String get opasnayaZona_25bc => 'Zona de peligro';
  @override
  String get udalitAkkaunt_05c7 => 'Eliminar cuenta';
  @override
  String get neobratimoeDeystvie_7232 => 'Acción irreversible';
  @override
  String get tema_9e26 => 'Asunto';
  @override
  String get temnayaTema_cb48 => 'tema oscuro';
  @override
  String get pereklyuchitMezhduTemnymISvetlym_5415 =>
      'Cambiar entre el modo oscuro y claro';
  @override
  String get razmerShrifta_1155 => 'Tamaño de fuente';
  @override
  String get a_87a0 => 'un';
  @override
  String get pokazyvatVsplyvayuschieUvedomleniya_754e =>
      'Mostrar notificaciones emergentes';
  @override
  String get zvuk_9329 => 'sonido';
  @override
  String get vosproizvoditZvukPriNovomSoobschenii_47cc =>
      'Reproducir sonido en mensaje nuevo';
  @override
  String get osnovnyeNastroyki_231c => 'Configuraciones básicas';
  @override
  String get rezhimEkonomiiEnergii_edfc => 'Modo de ahorro de energía';
  @override
  String get optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb =>
      'Optimiza el rendimiento de la aplicación para ahorrar recursos.';
  @override
  String get avtomaticheskiySpyaschiyRezhim_5955 =>
      'Modo de suspensión automático';
  @override
  String get perevoditPrilozhenieVSpyaschiyRezhim_1c07 =>
      'Pone la aplicación en modo de suspensión cuando está inactiva';
  @override
  String get animatsii_05c7 => 'animaciones';
  @override
  String get uproschennyeAnimatsii_3a13 => 'Animaciones simplificadas';
  @override
  String get umenshaetKolichestvoAnimatsiyInterfeysa_6bf1 =>
      'Reduce el número de animaciones de la interfaz.';
  @override
  String get skoroBudetDostupno_de07 => 'Próximamente';
  @override
  String get gostevoyRezhim_6d82 => 'Modo invitado';
  @override
  String get voyditeDlyaDostupaKAkkauntu_a5c8 =>
      'Inicia sesión para acceder a tu cuenta';
  @override
  String get nazhmiteDlyaProsmotraIzmeneniy_0255 =>
      'Haga clic para ver los cambios';
  @override
  String get vvediteKodPodtverzhdeniya_61af =>
      'Ingrese el código de verificación';
  @override
  @override
  String get nevernyyKodPodtverzhdeniya_7762 =>
      'Código de verificación incorrecto';
  @override
  String get podtverditeEMail_4bd4 => 'Confirma tu correo electrónico';
  @override
  String get proverit_340b => 'comprobar';
  @override
  @override
  String get otpravitKodPovtorno_7703 => 'Reenviar código';
  @override
  String get sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e =>
      'Aplicación de escritorio moderna\ncon una hermosa interfaz y efectos 3D';
  @override
  String get tehnologii_6332 => 'Tecnologías';
  @override
  String get vyNashliPashalku_1a57 =>
      '🎉 ¡Encontraste un huevo de Pascua! 🎉\nzxqendzx';
  @override
  String get spasiboZaIspolzovanieXaneo_d079 => '¡Gracias por usar xaneo!';
  @override
  String get globalnyyPoisk_77bf => 'BÚSQUEDA MUNDIAL';
  @override
  @override
  String get poiskKontaktovChatovKanalovBotov_db66 =>
      'Buscar contactos, chats, canales, bots...';
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
  String get vvediteZaprosDlyaPoiskaPo_9955 =>
      'Escribe una consulta para buscar en la red Xaneo';
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
  String get versiya_3725 => 'Versión';
  @override
  String get tehnicheskayaInformatsiya_ba0f => 'Información técnica';
  @override
  String get platforma_8848 => 'Plataforma';
  @override
  String get arhitekturaProtsessora_c079 => 'Arquitectura del procesador';
  @override
  String get posmotretNaGithub_5238 => 'Ver en GitHub';
  @override
  String get zakryt_dd94 => 'Cerrar';
  @override
  String get vklyuchitTemnuyuTemu_ed17 => 'Habilitar tema oscuro';
  @override
  String get vklyuchitUvedomleniya_d311 => 'Habilitar notificaciones';
  @override
  String get kastomnyyOverleyXaneo_7d39 =>
      'Superposición personalizada de Xaneo';
  @override
  String get animirovannyeUvedomleniyaSBystrymOtvetom_a25d =>
      'Notificaciones animadas con respuesta rápida.';
  @override
  String get aaBbVv_1c6b => 'Aa bb bb';
  @override
  String get pleylist_a04c => 'LISTA DE REPRODUCCIÓN';
  @override
  String get spisokMuzyki_d477 => 'LISTA DE MÚSICA';
  @override
  String get loc_0B_5a4d => '0B';
  @override
  String get b_3b67 => 'b';
  @override
  String get kb_419d => 'KB';
  @override
  String get mb_b808 => 'MB';
  @override
  String get gb_e572 => 'ES';
  @override
  String get audiozapis_867d => 'Grabación de audio';
  @override
  String get muzykalnyyTrek_b15d => 'Pista de música';
  @override
  String get muzykalnyeTrekiOtsutstvuyut_3301 => 'No hay pistas de música.';
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
  String get oshibkaOtpravkiKoda_a42a =>
      'Error al enviar el código de verificación';
  @override
  @override
  String get neobhodimoPrinyatUsloviyaISoglasie_e31e =>
      'Debes aceptar los términos de uso y política de privacidad';
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
  String get nikneymDolzhenBytUnikalnym_952d =>
      'El nombre de usuario debe ser único';
  @override
  @override
  String get myOtpravimKodPodtverzhdeniya_fc71 =>
      'Enviaremos un código de verificación a tu correo';
  @override
  @override
  String get vvedite6ZnachnyyKodIz_f22f =>
      'Introduce el código de 6 dígitos del correo';
  @override
  @override
  String get pridumayteNadezhnyyParol_2312 =>
      'Crea una contraseña segura (mín. 8 caract.)';
  @override
  @override
  String get povtoriteParolEscheRaz_6723 => 'Repite la contraseña';
  @override
  @override
  String get etoNeobyazatelnoNoPriyatno_b6a3 => 'Es opcional pero recomendado';
  @override
  @override
  String get proverteVashiDannyeIPrimite_3121 =>
      'Revisa tus datos y acepta los términos';
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
  String get yaPrinimayuUsloviyaIspolzovaniya_391a =>
      'Acepto los Términos de uso';
  @override
  @override
  String get yaSoglasenNaObrabotkuPersonalnyh_f2a8 =>
      'Acepto el tratamiento de datos personales';
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
  String get vklyuchitTemnuyuTemuOformleniya_86c4 => 'Habilitar tema oscuro';
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
  String get oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b =>
      'Error de recuperación de clave (no se pudo sobrescribir)';
  @override
  String get kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7 =>
      'Error crítico al regenerar claves de cifrado';
  @override
  String get oshibkaZagruzkiKlyucheyNaServer_ff9b =>
      'Error al cargar claves al servidor';
  @override
  String get oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4 =>
      'Error al recuperar claves de cifrado';
  @override
  String get prevyshenLimitV5Akkauntov_a6a9 =>
      'Se superó el límite de 5 cuentas en este cliente o hay un error de conexión.';
  @override
  @override
  @override
  String get oshibkaAvtorizatsii_9f5c => 'Error de autorización';
  @override
  @override
  @override
  String get oshibkaPodklyucheniyaKServeru_8b96 =>
      'Error de conexión al servidor';
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
  String get vvediteSvoiDannyeDlyaDostupa_319e =>
      'Introduce tus datos para acceder a los mensajes.';
  @override
  @override
  String get voyti_63a7 => 'Iniciar sesión';
  @override
  String get sobesednik_7025 => 'Interlocutor';
  @override
  String get vy_0101 => 'tu';
  @override
  String get vyDelitesSvoimEkranom_16b1 => 'Compartes tu pantalla';
  @override
  String get polzovatel_f154 => 'Usuario';
  @override
  String get ishodyaschiyVyzov_650b => 'Llamada saliente...';
  @override
  String get vhodyaschiyVyzov_19ff => 'Llamada entrante...';
  @override
  String get podklyucheno_d022 => 'Conectado';
  @override
  String get ozhidanieOtveta_a984 => 'Esperando una respuesta...';
  @override
  String get razgovorPoAudiosvyazi_3ed7 => 'conversación de audio';
  @override
  String get translyatsiyaVashegoEkranaZapuschena_575a =>
      'Tu screencast ha comenzado';
  @override
  String get sobesednikViditVseChtoProishodit_c759 =>
      'El interlocutor ve todo lo que sucede en tu escritorio.';
  @override
  String get vhodyaschiyVyzov_905e => 'LLAMADA ENTRANTE';
  @override
  String get neizvestnyy_be89 => 'Desconocido';
  @override
  String get videozvonok_dd18 => 'Videollamada...';
  @override
  String get golosovoyZvonok_5410 => 'Llamada de voz...';
  @override
  String get otklonit_8b0d => 'Rechazar';
  @override
  String get otvetit_e568 => 'Responder';
  @override
  String get gruppovoyZvonok_dac1 => 'llamada grupal';
  @override
  String get podklyuchenieKZvonku_e2cf => 'Conectando a una llamada...';
  @override
  String get podklyuchenieKVeschaniyu_038b => 'Conectándose para transmitir...';
  @override
  String get uchastnik_cffb => 'Miembro';
  @override
  String get vy_479c => 'TÚ';
  @override
  String get svernut_ca9f => 'Colapso';
  @override
  String get vhodyaschiyVyzov_d2f3 => 'llamada entrante';
  @override
  String get novoeSoobschenie_1d49 => 'Nuevo mensaje';
  @override
  String get vashOtvet_40c2 => 'Tu respuesta...';
  @override
  String get videovyzov_3353 => 'Videollamada...';
  @override
  String get audiovyzov_bbb5 => 'Llamada de audio...';
  @override
  String get nachatZvonok_3d26 => 'INICIAR UNA LLAMADA';
  @override
  String get golosovoyZvonok_b615 => 'llamada de voz';
  @override
  String get pozvonitPoGolosovoySvyazi_4069 =>
      'Hacer una llamada de voz\nzxqendzx';
  @override
  String get videozvonok_8142 => 'Videollamada';
  @override
  String get pozvonitSVklyuchennoyKameroy_fb05 =>
      'Llamar con la cámara encendida';
  @override
  String get zashifrovannoeSoobschenie_ca35 => '[Mensaje cifrado]';
  @override
  String get golosovoeSoobschenie_4a85 => '🎤 Mensaje de voz';
  @override
  String get videosoobschenie_d687 => '🎬 Mensaje de vídeo';
  @override
  String get fayl_826d => '📎 Archivo';
  @override
  String get zvonok_e8d5 => '📞 Llamar';
  @override
  String get oshibkaDeshifrovaniya_4146 => '[Error de descifrado]';
  @override
  String get zapisyvaetGolosovoe_2a5c => 'graba voz...';
  @override
  String get pechataet_812c => 'impresiones...';
  @override
  String get neUdalosArhivirovatChat_ab89 => 'No se pudo archivar el chat';
  @override
  String get neUdalosRazarhivirovatChat_f0d7 =>
      'No se pudo desarchivar el chat';
  @override
  String get arhiv_56aa => 'Archivo';
  @override
  String get netUserid_634a => '[Sin ID de usuario]';
  @override
  String get netKlyucha_337b => '[Sin clave]';
  @override
  String get neizvestnyyTipChata_2617 => '[Tipo de chat desconocido]';
  @override
  String get neUdalosPoluchitKlyuchShifrovaniya_b953 =>
      'No se pudo obtener la clave de cifrado para el chat';
  @override
  String get gruppa_19c2 => 'grupo';
  @override
  String get uchastnik_5bce => 'participante';
  @override
  String get uchastnika_92d9 => 'participante';
  @override
  String get uchastnikov_5d6b => 'participantes';
  @override
  String get kanal_64ec => 'canal';
  @override
  String get podpischik_695a => 'suscriptor';
  @override
  String get podpischika_b490 => 'suscriptor';
  @override
  String get podpischikov_ba39 => 'suscriptores';
  @override
  String get segodnya_9626 => 'hoy';
  @override
  String get vchera_61d4 => 'ayer';
  @override
  String get yanvarya_d861 => 'enero';
  @override
  String get fevralya_fcf9 => 'febrero';
  @override
  String get marta_bb77 => 'marzo';
  @override
  String get aprelya_2b5a => 'abril';
  @override
  String get maya_4dbb => 'mayo';
  @override
  String get iyunya_adcb => 'junio';
  @override
  String get iyulya_3236 => 'julio';
  @override
  String get avgusta_e3aa => 'agosto';
  @override
  String get sentyabrya_a146 => 'septiembre';
  @override
  String get oktyabrya_7abd => 'octubre';
  @override
  String get noyabrya_6e78 => 'noviembre';
  @override
  String get dekabrya_29cc => 'diciembre';
  @override
  String get vyPodpisalisNaKanal_b2b3 => 'Te has suscrito al canal';
  @override
  String get vyPrisoedinilisKGruppe_07bd => 'Te has unido al grupo';
  @override
  String get neUdalosPrisoedinitsya_31e6 => 'No se pudo unir';
  @override
  String get vyOtpisalisOtKanala_7698 => 'Te has dado de baja del canal';
  @override
  String get vyPokinuliGruppu_5a52 => 'Dejaste el grupo';
  @override
  String get neUdalosVypolnitDeystvie_3cfd => 'La acción falló';
  @override
  String get neUdalosPereklyuchitAkkaunt_968b => 'No se pudo cambiar de cuenta';
  @override
  String get media_c247 => 'Medios';
  @override
  String get fayly_200c => 'Archivos';
  @override
  String get golos_2d89 => 'Voz';
  @override
  String get ssylki_9f58 => 'Enlaces';
  @override
  String get profil_c62a => 'PERFIL';
  @override
  String get imyaPolzovatelya_6fd4 => 'Nombre de usuario';
  @override
  String get denRozhdeniya_e41d => 'Cumpleaños';
  @override
  String get polzovatelSkrylInformatsiyuOSebe_f416 =>
      'El usuario ha ocultado información sobre sí mismo.';
  @override
  String get god_6270 => 'año';
  @override
  String get goda_7443 => 'año';
  @override
  String get let_257a => 'años';
  @override
  String get skopirovano_f70b => 'Copiado';
  @override
  String get akkaunty_80b5 => 'CUENTAS';
  @override
  String get dobavitAkkaunt_5253 => 'Agregar cuenta\nzxqendzx';
  @override
  String get limit5Akkauntov_fdb7 => 'Límite: 5 cuentas';
  @override
  String get nazadKChatam_7edb => 'Volver a los chats';
  @override
  String get chaty_19ad => 'Charlas';
  @override
  String get globalnyyPoisk_7ff2 => 'búsqueda global';
  @override
  String get arhivPust_3e22 => 'El archivo está vacío.';
  @override
  String get netSoobscheniy_29d4 => 'Sin mensajes';
  @override
  String get toDoList_27e1 => '📋 Hoja de tareas pendientes';
  @override
  String get opros_6ff1 => '🗳️ Encuesta';
  @override
  String get fotografiya_5709 => '📷 Fotografía';
  @override
  String get razarhivirovat_416b => 'Descomprimir';
  @override
  String get vArhiv_ce22 => 'al archivo';
  @override
  String get chat_c52b => 'Charla';
  @override
  String get vyberiteChatDlyaNachalaObscheniya_36a5 =>
      'Seleccione un chat para comenzar a chatear';
  @override
  String get bot_2712 => 'robot';
  @override
  String get vSeti_d902 => 'en línea';
  @override
  String get neVSeti_ee01 => 'fuera de línea';
  @override
  String get nastroykiChata_1e0d => 'Configuración de chat';
  @override
  String get pokinutGruppu_e6ce => 'Dejar grupo';
  @override
  String get prisoedinitsyaKGruppe_eb45 => 'Únete al grupo';
  @override
  String get otpisatsyaOtKanala_fdbc => 'Darse de baja del canal';
  @override
  String get podpisatsyaNaKanal_2dad => 'Suscríbete al canal';
  @override
  String get netSoobscheniyNapishiteChtoNibud_2bf4 =>
      'Sin mensajes. ¡Escribe algo!';
  @override
  String get prisoedinilsyaKChatu_f623 => 'se unió al chat';
  @override
  String get pokinulChat_d567 => 'abandonó el chat';
  @override
  String get podpisalsyaNaKanal_0673 => 'suscrito al canal';
  @override
  String get otpisalsyaOtKanala_fa13 => 'dado de baja del canal';
  @override
  String get polzovatelya_1083 => 'usuario';
  @override
  String get priglasil_47ae => 'invitado';
  @override
  String get rasshifrovka_e47f => '[Transcripción...]';
  @override
  String get sistemnoeSoobschenie_d2bd => 'Mensaje del sistema';
  @override
  String get soobschenie_3715 => 'Mensaje';
  @override
  String get videosoobschenie_57f1 => '📹 Vídeo mensaje';
  @override
  String get spisokZadach_cfa4 => '📋 Lista de tareas';
  @override
  String get opros_5902 => '📊 Encuesta';
  @override
  String get vlozhenie_ef44 => 'Adjunto';
  @override
  String get fayl_2d46 => 'Archivo';
  @override
  String get zagruzkaFayla_f817 => 'Cargando archivo...';
  @override
  String get ishodyaschiyZvonok_8381 => 'llamada saliente';
  @override
  String get razgovorNeSostoyalsya_67fb => 'La conversación no se produjo.';
  @override
  String get vhodyaschiyZvonok_5ce9 => 'llamada entrante';
  @override
  String get otklonennyyZvonok_d499 => 'llamada rechazada';
  @override
  String get vyOtkloniliVyzov_8d1d => 'Rechazaste la llamada';
  @override
  String get propuschennyyZvonok_e98d => 'llamada perdida';
  @override
  String get vyPropustiliVyzov_f17a => 'perdiste la llamada';
  @override
  String get vlozhenie_2474 => '📎 Adjunto';
  @override
  String get tb_0e05 => 'tuberculosis';
  @override
  String get zapisGolosovogo_9c91 => 'Grabación de voz...';
  @override
  String get zapisVideo_dd2a => 'Grabación de vídeo...';
  @override
  String get otpustiteDlyaOtpravki_ea7b => 'Liberar para enviar';
  @override
  String get emodzi_f822 => 'emojis';
  @override
  String get panelEmodziVRazrabotke_b6ce => 'Panel de emojis en desarrollo';
  @override
  String get napisatSoobschenie_62d4 => 'Escribe un mensaje...';
  @override
  String get dobavitVlozhenie_769b => 'Agregar archivo adjunto';
  @override
  String get spisokZadach_1852 => 'Lista de tareas';
  @override
  String get opros_9f36 => 'Encuesta';
  @override
  String get zapisGolosovogoGs_db4e => 'Grabación de voz (VO)';
  @override
  String get zapisVideoVs_9676 => 'Grabación de vídeo (VS)';
  @override
  String get uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3 =>
      '• Mantenga presionado el botón para grabar\n• Presione para cambiar de modo';
  @override
  @override
  String get novyyChat_f775 => 'Nuevo chat';
  @override
  @override
  String get imyaPolzovatelyaMin5Simvolov_1232 =>
      'Nombre de usuario (mín. 5 caracteres)';
  @override
  @override
  String get vvedite5IliBoleeSimvolov_f983 => 'Introduce 5 o más caracteres';
  @override
  @override
  String get polzovateliNeNaydeny_c01a => 'No se encontraron usuarios';
  @override
  String get mnozhestvennyyVybor_9b60 => 'Opción múltiple';
  @override
  String get odinochnyyVybor_d920 => 'Selección única';
  @override
  String get netGolosov_17d0 => 'Sin votos\nzxqendzx';
  @override
  String get golos_6b94 => 'voz';
  @override
  String get golosa_bb8d => 'voces';
  @override
  String get golosov_7f51 => 'votos';
  @override
  String get nePoluchenIdFaylaOt_86c8 =>
      'ID de archivo no recibido del servidor';
  @override
  String get faylZagruzhenIPrikreplen_dc24 => 'Archivo subido y adjunto';
  @override
  String get neizvestnayaOshibkaZagruzki_68cb =>
      'Error de descarga desconocido';
  @override
  String get oshibkaZagruzkiFayla_86e5 => 'error de descarga de archivos';
  @override
  String get sohranitFaylKak_0f93 => 'guardar archivo como';
  @override
  String get oshibkaSkachivaniyaFayla_34ac => 'error de descarga de archivos';
  @override
  String get bezNazvaniya_6584 => 'Sin título';
  @override
  String get bezVoprosa_d390 => 'No hay duda';
  @override
  String get netDostupaKMikrofonu_a4ef => 'Sin acceso al micrófono';
  @override
  String get zapisVideoCherezPlaginCamera_b9dd =>
      '📹 Se ha iniciado la grabación de vídeo a través del complemento de la cámara.';
  @override
  String get kameraNeInitsializirovanaNaEtoy_21e0 =>
      '📹 La cámara no está inicializada en esta plataforma.';
  @override
  String get kameraNeGotova_9f09 => 'La cámara no está lista';
  @override
  String get zapisVideosoobscheniyaNaEtoyPlatforme_a561 =>
      '📹 La grabación de mensajes de video no está disponible directamente en esta plataforma.';
  @override
  String get arecordOstanovlen_edf2 => '🎙️ se ha detenido un registro';
  @override
  String get ffmpegOstanovlen_63a0 => '📹 ffmpeg detenido';
  @override
  String get zapisSlishkomKorotkaya_5cda => 'La entrada es demasiado corta.';
  @override
  String get oshibkaZapisiFaylPust_106b =>
      'Error de escritura: el archivo está vacío';
  @override
  String get videosoobschenieOtpravlenoSimulyatsiya_fb29 =>
      'Mensaje de vídeo enviado (simulación)';
  @override
  String get zapisOtmenena_1609 => 'Registro cancelado';
  @override
  String get otpravitGolosovoeSoobschenie_2481 => 'Enviar un mensaje de voz';
  @override
  String get imitatsiyaZapisiGolosovogoSoobscheniya_81e7 =>
      'Simulación de grabación de un mensaje de voz.';
  @override
  String get otpravit_6da0 => 'enviar';
  @override
  String get sozdatToDo_8c92 => 'CREAR TAREAS';
  @override
  String get nazvanieSpiska_c3cc => 'Nombre de la lista';
  @override
  String get punkty_0481 => 'Artículos:';
  @override
  String get dobavitPunkt_930c => 'Agregar artículo';
  @override
  String get sozdat_b059 => 'crear';
  @override
  String get sozdatOpros_4b9e => 'CREAR UNA ENCUESTA';
  @override
  String get vopros_0911 => 'Pregunta';
  @override
  String get variantyOtveta_ef4e => 'Opciones de respuesta:';
  @override
  String get dobavitVariant_76be => 'Agregar una opción';
  @override
  String get golosovoeSoobschenie_33d5 => 'Mensaje de voz';
  @override
  String get videosoobschenie_2951 => 'mensaje de vídeo';
  @override
  String get video_a095 => 'Vídeo';
  @override
  String get neUdalosZagruzitIzobrazhenie_3fa0 => 'No se pudo cargar la imagen';
  @override
  String get muzyka_0660 => 'musica';
  @override
  String get netDannyh_dee9 => 'Sin datos';
  @override
  String get istoriyaSoobscheniyPustaIliChat_2d07 =>
      'El historial de mensajes está vacío o el chat aún no se ha guardado localmente';
  @override
  String get obschieMaterialy_11e4 => 'Materiales generales';
  @override
  String get netMediafaylov_08d2 => 'Sin archivos multimedia';
  @override
  String get zdesBudutOtobrazhatsyaObschieFoto_9bc7 =>
      'Las fotos y vídeos compartidos se mostrarán aquí.';
  @override
  String get netFaylov_e95e => 'Sin archivos';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c =>
      'Los archivos cargados se mostrarán aquí.';
  @override
  String get netGolosovyhSoobscheniy_2427 => 'Sin mensajes de voz';
  @override
  String get zdesBudutOtobrazhatsyaGolosovyeI_0a73 =>
      'Los mensajes de voz y vídeo se mostrarán aquí.';
  @override
  String get netSsylok_b0ec => 'Sin enlaces';
  @override
  String get zdesBudutOtobrazhatsyaObschieSsylki_6b61 =>
      'Los enlaces generales aparecerán aquí.';
  @override
  String get ssylkaSkopirovanaVBufer_c16e => 'Enlace copiado al portapapeles';
  @override
  String get netMuzyki_1ca3 => 'sin musica';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23 =>
      'Las pistas enviadas se mostrarán aquí.';
  @override
  String get udalennyyAkkaunt_ce47 => 'cuenta eliminada';
  @override
  String get opisanie_38ca => 'Descripción';
  @override
  String get mobilnyy_5ac7 => 'Móvil';
  @override
  String get bylANedavno_168d => 'fue recientemente';
  @override
  String get minutu_5373 => 'minuto';
  @override
  String get minuty_5bc9 => 'minutos';
  @override
  String get minut_b877 => 'minutos\nzxqendzx';
  @override
  String get nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a =>
      'Haga clic para descargar la nueva versión';
  @override
  String get poiskLyudeyBotovGrupp_e84e => 'Busca personas, bots, grupos...';
  @override
  String get vveditePoiskovyyZapros_0b8c => 'Introduzca su término de búsqueda';
  @override
  String get polzovateli_b8c4 => 'Usuarios';
  @override
  String get moiLichnyeSoobscheniya_7d3b => 'mis mensajes personales';
  @override
  String get sozdatNovyyChat_fd41 => 'Crear un nuevo chat';
  @override
  String get lichnyyChat_cbec => 'charla personal';
  @override
  String get nachatObschenieSPolzovatelem_0578 =>
      'Iniciar una conversación con un usuario';
  @override
  String get sozdatGruppu_459f => 'Crear un grupo';
  @override
  String get gruppovoyChatDlyaObscheniyaS_01ba =>
      'Chat grupal para comunicarse con amigos.';
  @override
  String get sozdatKanal_9022 => 'Crear un canal';
  @override
  String get kanalDlyaShirokoyAuditorii_9dba =>
      'Canal para una amplia audiencia.';
  @override
  String get redaktirovanie_1167 => 'Edición';
  @override
  String get vlevo_1af1 => 'Izquierda';
  @override
  String get vpravo_c316 => 'Derecha';
  @override
  String get poGor_ff50 => 'A lo largo de las montañas';
  @override
  String get poVert_b4a9 => 'Vert.';
  @override
  String get vvediteNazvanieGruppy_0a69 => 'Introduzca el nombre del grupo';
  @override
  String get dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0 =>
      'Un grupo público requiere un apodo (@nombredeusuario)';
  @override
  String get gruppaSozdana_6b3b => 'Grupo creado';
  @override
  String get oshibkaPriSozdaniiGruppy_794e => 'Error al crear grupo';
  @override
  String get nazhmiteNaIkonkuChtobyVybrat_af03 =>
      'Haga clic en el icono para seleccionar un avatar';
  @override
  String get nazvanieGruppy_9a39 => 'Nombre del grupo';
  @override
  String get opisanieNeobyazatelno_7812 => 'Descripción (opcional)';
  @override
  String get privatnayaGruppa_d20e => 'grupo privado';
  @override
  String get publichnayaGruppa_50f8 => 'grupo publico';
  @override
  String get vhodTolkoPoPriglasheniyu_97a1 => 'Entrada sólo por invitación';
  @override
  String get lyuboyMozhetNaytiIVstupit_5e26 =>
      'Cualquiera puede encontrar y unirse';
  @override
  String get publichnayaSsylkanikneymMyGroup_6640 =>
      'Enlace público/apodo (@my_group)';
  @override
  String get vvediteNazvanieKanala_5536 => 'Introduce el nombre del canal';
  @override
  String get dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06 =>
      'Un canal público requiere un enlace/apodo (@mychannel)';
  @override
  String get kanalSozdan_1522 => 'Canal creado';
  @override
  String get oshibkaPriSozdaniiKanala_7d4b => 'Error al crear el canal';
  @override
  String get nazvanieKanala_c548 => 'Nombre del canal';
  @override
  String get privatnyyKanal_3139 => 'canal privado';
  @override
  String get publichnyyKanal_0f7c => 'canal publico';
  @override
  String get podpiskaTolkoPoPriglasheniyu_99c3 =>
      'Suscripción solo por invitación';
  @override
  String get lyuboyMozhetNaytiIPodpisatsya_8579 =>
      'Cualquiera puede buscar y suscribirse.';
  @override
  String get ssylkanikneymKanalaMychannel_79f6 =>
      'Enlace/apodo del canal (@mychannel)';
  @override
  String get yazykInterfeysa_b78b => 'Idioma de la interfaz';
  @override
  String get dannyeUspeshnoSohraneny_2cc5 => 'Datos guardados exitosamente';
  @override
  String get oshibkaPriSohranenii_126f => 'Error al guardar';
  @override
  String get lichnyeDannye_10a7 => 'DATOS PERSONALES';
  @override
  String get nikneymUsername_8035 => 'Apodo (@nombredeusuario)';
  @override
  String get nikneymNelzyaIzmenit_0b99 => 'El apodo no se puede cambiar';
  @override
  String get oSebeBio_b730 => 'Acerca de mí (Biografía)';
  @override
  String get rasskazhiteNemnogoOSebe_3daa => 'Cuéntanos un poco sobre ti...';
  @override
  String get nastroykiPrivatnostiSohraneny_447c =>
      'Configuración de privacidad guardada';
  @override
  String get privatnost_3098 => 'PRIVACIDAD';
  @override
  String get kommunikatsii_e9b8 => 'COMUNICACIONES';
  @override
  String get ktoMozhetPisat_3322 => 'quien puede escribir';
  @override
  String get zapisGolosovyh_8073 => 'Grabación de voz';
  @override
  String get otpravkaFaylov_aaca => 'Enviando archivos';
  @override
  String get priglashatVGruppy_3631 => 'Invitar a grupos';
  @override
  String get vidimostProfilya_448f => 'VISIBILIDAD DEL PERFIL';
  @override
  String get ktoViditAvatar_b5d8 => '¿Quién ve el avatar?';
  @override
  String get vremyaVSeti_be29 => 'tiempo en línea';
  @override
  String get vneshniyVid_5a0f => 'APARIENCIA';
  @override
  String get rezhimOformleniyaInterfeysa_b91d => 'Modo de diseño de interfaz';
  @override
  String get pokazyvatVizualnyeEffektyIPerehody_3fd7 =>
      'Mostrar efectos visuales y transiciones.\nzxqendzx';
  @override
  String get razmerTeksta_3c4f => 'Tamaño del texto';
  @override
  String get bezopasnost_fcbc => 'SEGURIDAD';
  @override
  String get dvuhfaktornayaAutentifikatsiya_acdc =>
      'Autenticación de dos factores';
  @override
  String get zaschitaAkkaunta2fa_f1ab => 'Protección de cuenta 2FA';
  @override
  String get vklyucheno_6b96 => 'Incluido';
  @override
  String get xaneoMobileAktivnoSeychas_3345 => 'Xaneo Móvil • Activo ahora';
  @override
  String get zaschischennyyMessendzher_2f59 => 'Mensajero seguro';
  @override
  String get temnayaTema_6018 => 'tema oscuro';
  @override
  String get vklyuchenaPoUmolchaniyu_7610 => 'Habilitado (predeterminado)';
  @override
  String get setevoyFiltr_40c2 => 'Filtro de sobretensión';
  @override
  String get vklyuchen_0994 => 'Habilitado';
  @override
  String get spisokMuzyki_57d0 => 'lista de musica';
  @override
  String get trek_5049 => 'pista';
  @override
  String get trekov_d3f4 => 'pistas';
  @override
  String get pozhaluystaZapolniteVoprosIKak_7ad5 =>
      'Por favor complete la pregunta y al menos dos opciones de respuesta.';
  @override
  String get sozdatOpros_8401 => 'Crear una encuesta';
  @override
  String get sozdatSpisokZadach_4018 => 'CREAR LISTA DE TAREAS';
  @override
  String get pozhaluystaZapolniteNazvanieIKak_3783 =>
      'Por favor complete el título y al menos un elemento';
  @override
  String get sozdatSpisokZadach_0416 => 'Crear una lista de tareas';
  @override
  String get vhodyaschiyVideozvonok_14d4 => 'videollamada entrante';
  @override
  String get prinyat_5dc5 => 'Aceptar';
  @override
  String get netObschihFaylov_bf77 => 'Sin archivos compartidos';
  @override
  String get neUdalosRazarhivirovatChatNa_b6f6 =>
      'No se pudo desarchivar el chat en el servidor';
  @override
  String get poiskVArhive_c5d8 => 'Búsqueda de archivos...';
  @override
  String get poprobuyteIzmenitZapros_52ea => 'Intente cambiar su solicitud';
  @override
  String get zdesBudutNahoditsyaVashiArhivirovannye_7359 =>
      'Tus chats archivados irán aquí';
  @override
  String get vernut_54aa => 'Regresar';
  @override
  String get zashifrovannoeSoobschenie_c9ab => 'mensaje cifrado';
  @override
  String get soobschenieNahoditsyaVysheVIstorii_dc90 =>
      'El mensaje está más arriba en la historia.';
  @override
  String get otpravlyaetFoto_67c1 => 'manda una foto...';
  @override
  String get otpravlyaetVideo_ce80 => 'envía vídeo...';
  @override
  String get otpravlyaetFayl_5e88 => 'envía archivo...';
  @override
  String get ktoTo_8405 => 'alguien';
  @override
  String get trebuetsyaRazreshenieNaKameruI_06fa =>
      'Se requiere permiso para la cámara y el micrófono';
  @override
  String get kameraNeNaydena_208d => 'Cámara no encontrada';
  @override
  String get zapisVideoOtmenena_1db7 => 'Grabación de vídeo cancelada';
  @override
  String get slishkomKorotkoeVideosoobschenie_4676 =>
      'Mensaje de vídeo demasiado corto';
  @override
  String get pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35 =>
      'Espere hasta que se descarguen los archivos.';
  @override
  String get audiozvonok_dcf6 => 'llamada de audio';
  @override
  String get otpravitFotoVideoAudioIli_37e9 =>
      'Enviar fotos, vídeos, audio u otros archivos.';
  @override
  String get provedenieGolosovaniyaVChate_a629 => 'Votar en el chat';
  @override
  String get sozdatToDoSpisok_cb50 => 'Crear una lista de tareas pendientes';
  @override
  String get spisokZadachSOtmetkamiVypolneniya_c778 =>
      'Lista de tareas con notas de finalización';
  @override
  String get trebuetsyaRazreshenieNaZapisAudio_8175 =>
      'Requiere permiso para grabar audio.';
  @override
  String get slishkomKorotkoeSoobschenie_c2ee => 'Mensaje demasiado corto';
  @override
  String get uderzhivayteKnopkuDlyaZapisi_a762 =>
      'Mantenga presionado el botón para grabar';
  @override
  String get udalennyy_40c6 => 'remoto';
  @override
  String get udalennyy_c2c8 => 'remoto';
  @override
  String get neobhodimyRazresheniyaNaMikrofonI_224b =>
      'Se requieren permisos de micrófono y cámara para realizar una llamada';
  @override
  String get bylATolkoChto_9ac0 => 'estaba ahí';
  @override
  String get chatNeNayden_ba4f => 'Chat no encontrado';
  @override
  String get napishitePervoeSoobschenie_8260 => 'Escribe tu primer mensaje';
  @override
  String get prisoedinitsyaKKanalu_f863 => 'Únete al canal';
  @override
  String get vyPodpisany_5fb9 => 'estas suscrito';
  @override
  String get otpisatsya_ee2d => 'Darse de baja';
  @override
  String get vyUspeshnoPodpisalisNaKanal_9c99 =>
      '¡Te has suscrito exitosamente al canal!';
  @override
  String get vyUspeshnoVstupiliVGruppu_61a1 =>
      '¡Te has unido exitosamente al grupo!';
  @override
  String get neUdalosPrisoedinitsyaPoprobuyteEsche_bce5 =>
      'No se pudo unir. Intentar otra vez.';
  @override
  String get vyrezat_a195 => 'cortar';
  @override
  String get kopirovat_112b => 'Copiar\nzxqendzx';
  @override
  String get vstavit_dcc4 => 'Pegar';
  @override
  String get vybratVse_4d09 => 'Seleccionar todo';
  @override
  String get zhirnyy_7774 => 'Negrita';
  @override
  String get kursiv_e0b1 => 'cursiva';
  @override
  String get kod_3f34 => 'Código';
  @override
  String get zacherknut_02fc => 'tachar';
  @override
  String get soobschenie_8b9b => 'Mensaje...';
  @override
  String get smahniteDlyaOtmeny_e976 => 'Desliza para cancelar';
  @override
  String get poisk_bfc9 => 'Buscar';
  @override
  String get udalitChat_4b2b => 'Eliminar chat';
  @override
  String get udalitKanal_482f => 'Eliminar canal';
  @override
  String get pozhalovatsya_a7d9 => 'quejarse';
  @override
  String get redaktirovatGruppu_e40a => 'Editar grupo';
  @override
  String get udalitGruppu_dff8 => 'Eliminar grupo';
  @override
  String get poiskSoobscheniyVremennoNedostupenV_4443 =>
      'La búsqueda de mensajes no está disponible temporalmente en la versión móvil';
  @override
  String get zhalobaOtpravlenaModeratoram_4547 =>
      'La queja ha sido enviada a los moderadores.';
  @override
  String get redaktirovanieGruppyVremennoNedostupnoV_05d0 =>
      'La edición grupal no está disponible temporalmente en la versión móvil';
  @override
  String get vyUverenyChtoHotiteOchistit_7c3a =>
      '¿Estás seguro de que deseas borrar tu historial de mensajes en este chat? Esta acción no se puede deshacer.';
  @override
  String get ochistit_7074 => 'Borrar';
  @override
  String get udalit_ed2b => 'Eliminar';
  @override
  String get vyyti_0f05 => 'Cerrar sesión';
  @override
  String get oshibkaVosproizvedeniya_ac8a => 'Error de reproducción';
  @override
  String get novoeZashifrovannoeSoobschenie_4d30 => 'Nuevo mensaje cifrado';
  @override
  String get poiskChatov_779c => 'Buscar chats...';
  @override
  String get obnovlenie_53e2 => 'Actualizar...';
  @override
  String get soedinenie_5a58 => 'Conexión...';
  @override
  String get lichnye_4cb3 => 'personales';
  @override
  String get neUdalosArhivirovatChatNa_36aa =>
      'No se pudo archivar el chat en el servidor';
  @override
  String get oshibkaZagruzkiChatov_902f => 'Error al cargar chats';
  @override
  String get povtorit_b914 => 'repetir';
  @override
  String get netChatov_85e3 => 'Sin chats';
  @override
  String get nachniteNovyyRazgovor_8290 => 'Iniciar una nueva conversación';
  @override
  String get neUdalosZagruzitAkkaunty_8570 =>
      'No se pudieron cargar las cuentas';
  @override
  String get vyberiteAkkaunt_79e7 => 'Seleccione una cuenta';
  @override
  String get bystryyVhodNaEtomUstroystve_3f30 =>
      'Inicio de sesión rápido en este dispositivo';
  @override
  String get voytiSParolem_9277 => 'Iniciar sesión con contraseña';
  @override
  String get sozdatXaneoId_4033 => 'Crear ID de Xaneo';
  @override
  String get netSohranennyhAkkauntov_b669 => 'No hay cuentas guardadas';
  @override
  String get tolkoChto_4493 => 'Justo ahora';
  @override
  String get emailNedostupen_fc3e => 'Correo electrónico no disponible';
  @override
  String get nevernyyKod_50f9 => 'código no válido';
  @override
  String get oshibkaProverkiKoda_9018 => 'Error de verificación de código';
  @override
  String get neobhodimoRazreshenieNaDostupK_5f5c =>
      'Se requiere permiso para acceder a las fotos.';
  @override
  String get oVyboreEmail_2609 => 'Acerca de elegir correo electrónico';
  @override
  String get podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0 =>
      'Todos los dominios de correo electrónico son compatibles excepto';
  @override
  String get zapreschennyh_1f49 => 'prohibido';
  @override
  String get sozdatAkkaunt_19ed => 'Crear una cuenta';
  @override
  String get naprimerIvan_d7cb => 'Por ejemplo, Iván';
  @override
  String get zadayteParol_53d2 => 'Establecer una contraseña';
  @override
  String get minimum8Simvolov_4ccd => 'Mínimo 8 caracteres';
  @override
  String get unikalnoeImyaDlyaVashegoProfilya_a0ea =>
      'Un nombre único para tu perfil';
  @override
  String get vashEmail_879d => 'Tu correo electrónico';
  @override
  String get dlyaSvyaziIVosstanovleniyaDostupa_c770 =>
      'Para restauración de comunicaciones y accesos.';
  @override
  String get emailAdres_9130 => 'Dirección de correo electrónico';
  @override
  String get vvediteParolEscheRaz_7383 => 'Ingrese su contraseña nuevamente';
  @override
  String get parolEscheRaz_6daf => 'Contraseña nuevamente';
  @override
  String get paroliNeSovpadayut_d82f => 'Las contraseñas no coinciden';
  @override
  String get ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed =>
      'Por favor indica tu fecha real de nacimiento';
  @override
  String get ddmmgggg_3524 => 'DD.MM.AAAA';
  @override
  String get sdelayteProfilUznavaemym_f2c5 =>
      'Haz que tu perfil sea reconocible\nzxqendzx';
  @override
  String get profilGotov_b57d => 'Perfil listo';
  @override
  String get ostalosVsegoParaShagov_37e3 => 'Sólo quedan un par de pasos';
  @override
  String get yaPrinimayuPolzovatelskoeSoglashenie_c431 =>
      'Acepto el Acuerdo de Usuario';
  @override
  String get yaDayuSoglasieNaObrabotku_0d03 =>
      'Doy mi consentimiento para el tratamiento de datos personales';
  @override
  String get sVozvrascheniem_77ee => 'Bienvenido de nuevo';
  @override
  String get zagruzka_43e4 => 'Cargando...';
  @override
  String get vyberiteAkkauntDlyaVhoda_d3a6 =>
      'Seleccione una cuenta para iniciar sesión';
  @override
  String get vvediteVashNikneym_51a6 => 'Introduce tu apodo';
  @override
  String get voytiVDrugoyAkkaunt_d10f => 'Iniciar sesión en otra cuenta';
  @override
  String get nedavnieAkkaunty_953d => 'Cuentas recientes';
  @override
  String get dobroPozhalovatVXaneo_66d0 => 'Bienvenido a Xaneo';
  @override
  String get xaneoTeperIVMobilnom_e918 =>
      '¡Xaneo ya está disponible en la aplicación móvil! Este mensajero nunca ha sido tan conveniente y rápido.';
  @override
  String get mneUzheInteresno_5365 => 'ya estoy interesado';
  @override
  String get vseVashiDannyePodZaschitoy_b7d9 =>
      'Todos tus datos están protegidos';
  @override
  String get vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e =>
      'Todos los mensajes están protegidos con cifrado de extremo a extremo. Xaneo en ningún momento conoce su contenido.';
  @override
  String get prodolzhit_e9c3 => 'Continuar';
  @override
  String get lokalnyeDataTsentry_f089 => 'Centros de datos locales';
  @override
  String get vashiDannyeNikogdaNePokidayut_f871 =>
      'Tus datos nunca salen del país y se almacenan en centros de datos seguros.';
  @override
  String get kodOtpravlenPovtorno_e109 => 'Código reenviado';
  @override
  String get dvuhfaktornayanautentifikatsiya_bacc =>
      'Dos factores\nautenticación';
  @override
  String get naVashEmailOtpravlen6_b457 =>
      'Se ha enviado un código de 6 dígitos a su correo electrónico';
  @override
  String get podtverdit_e260 => 'Confirmar';
  @override
  String get nePoluchiliKodOtpravitPovtorno_c1d2 =>
      '¿No recibiste el código? Reenviar';
  @override
  String get imyaNikneymOSebe_7a8d => 'Nombre, apodo, sobre ti';
  @override
  String get zvonkiSoobscheniyaVidimostProfilya_f905 =>
      'Llamadas, mensajes, visibilidad del perfil.';
  @override
  String get parolSessii2fa_de9e => 'Contraseña, sesiones, 2FA';
  @override
  String get prilozhenie_38aa => 'APÉNDICE';
  @override
  String get temaRazmerTekstaAnimatsii_f0a8 =>
      'Tema, tamaño del texto, animaciones.';
  @override
  String get pushUvedomleniyaZvuki_9cc2 => 'Notificaciones push, sonidos.';
  @override
  String get oPrilozhenii_77b2 => 'ACERCA DE LA APLICACIÓN';

  @override
  String get redaktirovatProfil_56ad => 'Editar perfil';
  @override
  String get dobavitKontakt_2903 => 'AÑADIR CONTACTO';
  @override
  String get nikneymPolzovatelyaUsername_a6ff =>
      'Apodo de usuario (@nombredeusuario)';
  @override
  String get otobrazhaemoeImyaNeobyazatelno_340a =>
      'Nombre para mostrar (opcional)';
  @override
  String get neUdalosNaytiIliDobavit_649f =>
      'No se pudo encontrar ni agregar usuario';
  @override
  String get ya_feef => 'yo';
  @override
  String get poiskKontaktov_9a71 => 'Buscar contactos...';
  @override
  String get spisokKontaktovPust_58c6 =>
      'La lista de contactos está vacía\nzxqendzx';
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
  String get twoFactorAuthDesc =>
      'Proteger cuenta con contraseña de un solo uso';
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
  String get energySavingModeDesc =>
      'Optimiza el rendimiento para ahorrar batería';
  @override
  String get autoSleep => 'Modo suspensión automático';
  @override
  String get autoSleepDesc =>
      'Pone la aplicación en suspensión al estar inactiva';
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
  String get officialReleaseNotes =>
      'Notas oficiales de la versión disponibles en GitHub';
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
  String membersCount(int count) =>
      count == 1 ? '$count miembro' : '$count miembros';
  @override
  String subscribersCount(int count) =>
      count == 1 ? '$count suscriptor' : '$count suscriptores';

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
  String get holdToRecordHint =>
      'Mantenga presionado para grabar\nToque para cambiar modo';
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
  String get savedMessagesDesc =>
      'Tu almacenamiento personal para notas, archivos y mensajes';
  @override
  String get music => 'Música';
  @override
  String get noSharedMusic => 'Sin música';
  @override
  String get secureDesktopCommunicator => 'mensajero de escritorio seguro';
  @override
  String get noMessagesTitle => 'Sin mensajes';
  @override
  String get noMessagesSubtitle =>
      '¡Envía un mensaje para iniciar la conversación en Xaneo Connect!';

  @override
  String get qrScanTitle => 'Autorización de dispositivo';
  @override
  String get qrScanSubtitle =>
      'Apunta tu cámara al código QR en la pantalla de la versión web o cliente de PC de Xaneo';
  @override
  String get qrScanSuccessTitle => 'Dispositivo autorizado';
  @override
  String get qrScanSuccessDesc =>
      'Autorización exitosa. Las claves de cifrado de extremo a extremo (E2EE) se transfirieron al nuevo dispositivo.';
  @override
  String get qrScanInputHint => 'Pega el token o payload...';
  @override
  String get qrScanPasteTooltip => 'Pegar del portapapeles';
  @override
  String get qrScanConfirmButton => 'Confirmar autorización';
  @override
  String get qrScanProcessing => 'Autorizando dispositivo...';
}
