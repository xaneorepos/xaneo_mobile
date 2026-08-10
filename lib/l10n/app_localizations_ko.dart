import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Xaneo PC';

  @override
  String get welcomeTitle => 'Xaneo에 오신 것을 환영합니다';

  @override
  String get welcomeDescription => '이제 PC에서도 Xaneo를 만나보세요! 최고의 성능과 편리함.';

  @override
  String get getStartedButton => '시작하기';

  @override
  String get privacyTitle => '모든 데이터는 안전하게 보호됩니다';

  @override
  String get privacyDescription => 'Xaneo의 모든 메시지는 종단간 암호화(E2EE)로 안전하게 보호됩니다.';

  @override
  String get continueButton => '계속';

  @override
  String get dataStorageTitle => '모든 Xaneo 데이터 센터는 러시아에 위치해 있습니다';

  @override
  String get dataStorageDescription => '데이터는 국외로 유출되지 않으며 안전한 데이터 센터에 보관됩니다.';

  @override
  String get finishButton => '완료';

  @override
  String get setupCompleted => '설정이 완료되었습니다!';

  @override
  String get loginFormTitle => '로그인';

  @override
  String get loginFieldHint => '아이디';

  @override
  String get passwordFieldHint => '비밀번호';

  @override
  String get loginButton => '로그인';

  @override
  String get noAccount => '계정이 없으신가요?';

  @override
  String get registerButton => '회원가입';

  @override
  String get fillAllFields => '모든 항목을 입력해 주세요';

  @override
  String get loggingIn => '로그인 중...';

  @override
  String welcomeUser(String username) => '환영합니다, $username 님!';

  @override
  String get invalidCredentials => '아이디 또는 비밀번호가 올바르지 않습니다.';

  @override
  String get serverError => '서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get connectionError => '연결 오류. 인터넷 연결을 확인해 주세요.';

  @override
  String get settings => '설정';

  @override
  String get notifications => '알림';

  @override
  String get notificationsDescription => '알림 켜기/끄기';

  @override
  String get darkThemeDescription => '다크 테마 전환';

  @override
  String fontSize(int size) => '글꼴 크기: $size';

  @override
  String get language => '언어';

  @override
  String get languageDescription => '인터페이스 언어 선택';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get appVersion => '앱 버전';

  @override
  String get registerTitle => '회원가입';

  @override
  String get registerStep0Title => '이름이 무엇인가요?';

  @override
  String get registerStep0Subtitle => '실명을 입력해 주세요';

  @override
  String get registerStep1Title => '생년월일은 언제인가요?';

  @override
  String get registerStep1Subtitle => '만 14세 이상이어야 합니다';

  @override
  String get registerStep2Title => '닉네임 설정';

  @override
  String get registerStep2Subtitle => '닉네임은 고유해야 합니다';

  @override
  String get registerStep3Title => '이메일 주소';

  @override
  String get registerStep3Subtitle => '인증 코드를 전송해 드립니다';

  @override
  String get registerStep4Title => '비밀번호 생성';

  @override
  String get registerStep4Subtitle => '안전한 비밀번호를 만드세요';

  @override
  String get registerStep5Title => '프로필 사진 추가';

  @override
  String get registerStep5Subtitle => '선택 사항입니다';

  @override
  String get registerStep6Title => '마지막 단계';

  @override
  String get registerStep6Subtitle => '이용약관에 동의해 주세요';

  @override
  String get yourName => '이름';

  @override
  String get birthDate => '생년월일';

  @override
  String get nickname => '닉네임';

  @override
  String get checkingNickname => '사용 가능 여부 확인 중...';

  @override
  String get nicknameAvailable => '사용 가능한 닉네임입니다';

  @override
  String get nicknameTaken => '이미 사용 중인 닉네임입니다';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get addPhoto => '탭하여 사진 추가';

  @override
  String get removePhoto => '사진 삭제';

  @override
  String get acceptTerms => '이용약관에 동의합니다';

  @override
  String get acceptDataProcessing => '개인정보 수집 및 이용에 동의합니다';

  @override
  String get back => '이전';

  @override
  String get next => '다음';

  @override
  String get finish => '완료';

  @override
  String get backToLogin => '로그인으로 돌아가기';

  @override
  String get registrationSuccess => '회원가입이 완료되었습니다!';

  @override
  String get registrationError => '회원가입 오류';

  @override
  String get enterVerificationCode => '인증 코드를 입력해 주세요';

  @override
  String get invalidVerificationCode => '유효하지 않은 인증 코드입니다';

  @override
  String get codeSent => '이메일로 인증 코드가 전송되었습니다';

  @override
  String get sendCodeError => '코드 전송 실패';

  @override
  String get confirmEmail => '이메일 인증';

  @override
  String codeSentToEmail(String email) => '다음 이메일로 인증 코드를 보냈습니다\n$email';

  @override
  String get verify => '인증';

  @override
  String get resendCode => '코드 재전송';

  @override
  String resendIn(int count) => '$count초 후 재전송 가능';

  @override
  String get acceptTermsRequired => '이용약관 및 개인정보 처리방침 동의가 필요합니다';

  @override
  String get about => '정보';

  @override
  String get aboutDescription => '시스템 관리 및 통신을 위한 현대적인 애플리케이션.';

  @override
  String get close => '닫기';

  @override
  String get technicalInfo => '기술 정보';

  @override
  String get platform => '플랫폼';

  @override
  String get architecture => '프로세서 아키텍처';

  @override
  String get flutter => 'Flutter';

  @override
  String get viewOnGitHub => 'GitHub에서 보기';

  @override
  String get chats => '대화';
  @override
  String get search => '검색';
  @override
  String get searchPlaceholder => '메시지 및 대화 검색...';
  @override
  String get savedMessages => '저장된 메시지';
  @override
  String get online => '온라인';
  @override
  String get offline => '오프라인';
  @override
  String get lastSeenRecently => '최근에 활동함';
  @override
  String get musicPlaylist => '음악 재생목록';
  @override
  String get reply => '답장';
  @override
  String get edit => '편집';
  @override
  String get pin => '고정';
  @override
  String get unpin => '고정 해제';
  @override
  String get delete => '삭제';
  @override
  String get forward => '전달';
  @override
  String get members => '멤버';
  @override
  String get noMessages => '메시지가 없습니다';

  @override
  String get joinedChat => '님이 대화에 참여했습니다';
  @override
  String get leftChat => '님이 대화를 나갔습니다';
  @override
  String get subscribedChannel => '님이 채널을 구독했습니다';
  @override
  String get unsubscribedChannel => '님이 채널 구독을 해제했습니다';
  @override
  String get invited => '님이 초대했습니다';
  @override
  String get systemMessage => '시스템 메시지';
  @override
  String get selectChatToStart => '대화를 선택하여 메시지 시작';
  @override
  String get toArchive => '보관함으로';
  @override
  String get unarchive => '보관 해제';
  @override
  String get archive => '보관함';
  @override
  String get archiveEmpty => '보관함이 비어 있습니다';
  @override
  String get voiceMessage => '음성 메시지';
  @override
  String get videoMessage => '비디오 메시지';

  @override
  String get personalData => '개인 정보';
  @override
  String get personalDataDesc => '이름, 닉네임, 프로필 사진';
  @override
  String get privacyDesc => '메시지, 전화 및 프로필 공개 설정';
  @override
  String get chatsSettings => '대화 설정';
  @override
  String get chatsSettingsDesc => '알림, 테마, 기록';
  @override
  String get contacts => '연락처';
  @override
  String get contactsDesc => '저장된 연락처';
  @override
  String get security => '보안';
  @override
  String get securityDesc => '세션, 비밀번호, 2단계 인증';
  @override
  String get appearance => '화면 설정';
  @override
  String get appearanceDesc => '테마, 글꼴, 비율';
  @override
  String get energySaving => '절전 모드';
  @override
  String get energySavingDesc => '애니메이션 및 성능';

  @override
  String get account => '계정';
  @override
  String get interface => '인터페이스';
  @override
  String get logout => '로그아웃';

  @override
  String get basicInfo => '기본 정보';
  @override
  String get nicknameCannotBeChanged => '앱 내에서는 닉네임을 변경할 수 없습니다';
  @override
  String get aboutMe => '자기소개';
  @override
  String get aboutMeHint => '자신에 대해 소개해 주세요...';
  @override
  String get save => '저장';
  @override
  String get saving => '저장 중...';
  @override
  String get communications => '커뮤니케이션 설정';
  @override
  String get whoCanMessage => '메시지를 보낼 수 있는 사람';
  @override
  String get whoCanCall => '전화를 걸 수 있는 사람';
  @override
  String get whoCanRecordVoice => '음성 메시지를 보낼 수 있는 사람';
  @override
  String get whoCanSendFiles => '파일을 전송할 수 있는 사람';
  @override
  String get whoCanInvite => '그룹에 초대할 수 있는 사람';
  @override
  String get profileVisibility => '프로필 공개 설정';
  @override
  String get whoSeesNickname => '내 닉네임을 볼 수 있는 사람';
  @override
  String get everyone => '모든 사람';
  @override
  String get contactsOnly => '내 연락처만';
  @override
  String get nobody => '아무도 없음';
  @override
  String get addContact => '추가';
  @override
  String get addContactTitle => '연락처 추가';
  @override
  String get userNicknameHint => '사용자 닉네임';
  @override
  String get displayNameOptional => '표시 이름 (선택 사항)';
  @override
  String get noContactsYet => '저장된 연락처가 없습니다';
  @override
  String get appInfo => '앱 정보';
  @override
  String get checkUpdates => '업데이트 확인';
  @override
  String get checkingUpdates => '업데이트 확인 중...';
  @override
  String get cancel => '취소';
  @override
  String get obnovlenie_7e32 => '업데이트';
  @override
  String get obnovleniePrilozheniya_b6c3 => '앱 업데이트';
  @override
  String get podgotovkaKZagruzke_a5c7 => '다운로드 준비 중...';
  @override
  String get ustanovkaZapuschena_d378 => '설치가 시작되었습니다!';
  @override
  String get dostupnaNovayaVersiyaPrilozheniya_eeae =>
      '새로운 버전의 애플리케이션을 사용할 수 있습니다.';
  @override
  String get chtoNovogo_74e2 => '새로운 소식';
  @override
  String get ofitsialnoeOpisanieRelizaDostupnoNa_3ea3 =>
      '공식 릴리스 설명은 GitHub 페이지에서 확인할 수 있습니다.';
  @override
  String get istochnikZagruzki_0e6e => '다운로드 소스';
  @override
  String get pryamayaUstanovkaVPrilozhenii_16f5 => '애플리케이션에 직접 설치';
  @override
  String get avtomaticheskoeSkachivanieIZapusk_9a3f => '자동 다운로드 및 실행';
  @override
  String get stranitsaRelizaNaGithub_1531 => 'GitHub의 릴리스 페이지';
  @override
  String get propustit_03ee => '건너뛰기';
  @override
  String get ustanovka_516d => '설치...';
  @override
  String get obnovit_dbe5 => '업데이트';
  @override
  String get lichnyeDannye_be85 => '개인정보';
  @override
  String get imyaNikneymFotoProfilya_28ac => '이름, 닉네임, 프로필 사진';
  @override
  String get privatnost_0899 => '개인 정보 보호';
  @override
  String get ktoMozhetPisatZvonitVidet_1789 => '글을 쓰고, 전화하고, 프로필을 볼 수 있는 사람';
  @override
  String get nastroykiChatov_7ca8 => '채팅 설정';
  @override
  String get uvedomleniyaTemyIstoriya_51da => '알림, 주제, 기록';
  @override
  String get kontakty_7576 => '연락처';
  @override
  String get vashiSohranennyeKontakty_a641 => '저장된 연락처';
  @override
  String get bezopasnost_3677 => '보안';
  @override
  String get sessiiParolAutentifikatsiya_73f5 => '세션, 비밀번호, 인증';
  @override
  String get vneshniyVid_6873 => '외관';
  @override
  String get temaShriftMasshtab_d8c9 => '테마, 글꼴, 규모';
  @override
  String get yazyk_0577 => '언어';
  @override
  String get yazykInterfeysaKlienta_2ad3 => '클라이언트 인터페이스 언어';
  @override
  String get uvedomleniya_d2ed => '알림';
  @override
  String get zvukiBannery_1b60 => '소리, 배너';
  @override
  String get energosberezhenie_0b19 => '에너지 절약';
  @override
  String get animatsiiIProizvoditelnost_fba8 => '애니메이션과 퍼포먼스';
  @override
  String get oPrilozhenii_322e => '응용 프로그램에 대해';
  @override
  String get versiyaProverkaObnovleniySsylki_6efc => '버전, 업데이트 확인, 링크';
  @override
  String get nastroyki_b01b => '설정';
  @override
  String get nastroyki_c919 => '설정';
  @override
  String get proverkaObnovleniy_f3e0 => '업데이트 확인 중...';
  @override
  String get neUdalosZagruzitNastroyki_f753 => '설정을 로드하지 못했습니다.';
  @override
  String get oshibkaSohraneniya_0387 => '저장 오류';
  @override
  String get dannyeSohraneny_fd62 => '저장된 데이터';
  @override
  String get gost_9618 => '손님';
  @override
  String get akkaunt_38ac => '계정';
  @override
  String get interfeys_49be => '인터페이스';
  @override
  String get vyytiIzAkkaunta_6d41 => '계정에서 로그아웃하세요';
  @override
  String get informatsiyaOPrilozhenii_00c4 => '신청정보';

  @override
  String get proverka_13bc => '확인 중...';
  @override
  String get proveritObnovleniya_ab45 => '업데이트 확인';
  @override
  String get osnovnayaInformatsiya_6fec => '기본정보';
  @override
  String get imya_d38d => '이름';
  @override
  String get vvediteVasheImya_751e => '이름을 입력하세요';
  @override
  @override
  String get nikneym_3fea => '사용자 이름';
  @override
  String get nikneymNelzyaIzmenitVPrilozhenii_75d0 =>
      '닉네임은 애플리케이션 내에서 변경할 수 없습니다.';
  @override
  String get oSebe_0b3b => '나에 대해';
  @override
  String get rasskazhiteOSebe_1c37 => '자신에 대해 말해 보세요...';
  @override
  String get sohranenie_c15f => '저장 중...';
  @override
  String get sohranit_74ea => '저장';
  @override
  @override
  String get vse_984b => '전체';
  @override
  String get tolkoKontakty_a559 => '연락처만';
  @override
  String get nikto_ba19 => '아무도';
  @override
  String get kommunikatsii_1242 => '커뮤니케이션';
  @override
  String get ktoMozhetPisatSoobscheniya_4645 => '메시지를 작성할 수 있는 사람';
  @override
  String get ktoMozhetZvonit_c427 => '누가 전화할 수 있나요?';
  @override
  String get ktoMozhetZapisyvatGolosovye_c69a => '음성을 녹음할 수 있는 사람';
  @override
  String get ktoMozhetOtpravlyatFayly_2e40 => '파일을 보낼 수 있는 사람';
  @override
  String get ktoMozhetPriglashatVGruppy_cdc0 => '그룹에 초대할 수 있는 사람';
  @override
  String get vidimostProfilya_34bf => '프로필 가시성';
  @override
  String get ktoViditMoyNikneym_54b8 => '내 닉네임을 누가 볼 수 있나요?';
  @override
  String get ktoViditMoyAvatar_e9f6 => '내 아바타를 보는 사람';
  @override
  String get ktoViditMoyDenRozhdeniya_ccc7 => '내 생일을 볼 수 있는 사람';
  @override
  String get ktoViditVremyaMoeyAktivnosti_4349 => '내 활동 시간을 보는 사람';
  @override
  String get neUdalosZagruzitKontakty_02a3 => '연락처를 로드하지 못했습니다.';
  @override
  String get dobavitKontakt_4278 => '연락처 추가';
  @override
  String get nikneymPolzovatelya_5610 => '사용자 닉네임';
  @override
  String get otobrazhaemoeImyaOptsionalno_bbd1 => '표시 이름(선택사항)';
  @override
  @override
  String get otmena_987b => '취소';
  @override
  String get dobavit_5eba => '추가';
  @override
  String get uVasPokaNetSohranennyh_b64b => '아직 저장된 연락처가 없습니다.';
  @override
  String get pozvonit_ccfa => '전화';
  @override
  String get napisat_0144 => '쓰기';
  @override
  String get udalitKontakt_065d => '연락처 삭제';
  @override
  String get soobscheniya_7e26 => '메시지';
  @override
  String get animatsiiSoobscheniy_bc8b => '메시지 애니메이션';
  @override
  String get pokazyvatAnimatsiiPriOtpravkeI_d663 => '보내고 받을 때 애니메이션 표시';
  @override
  String get arhivirovannyeChaty_d990 => '보관된 채팅';
  @override
  String get upravlenieArhivom_e843 => '아카이브 관리';
  @override
  String get ochistitIstoriyu_837a => '기록 지우기';
  @override
  String get udalitVseSoobscheniyaLokalno_fbbd => '모든 메시지를 로컬에서 삭제';
  @override
  String get aktivnyeSessii_5c96 => '활성 세션';
  @override
  String get etoUstroystvo_26f6 => '이 장치';
  @override
  String get xaneoPcAktivnoSeychas_25b4 => 'Xaneo PC • 현재 활성화됨';
  @override
  String get aktivno_87a4 => '활성';
  @override
  String get dvoynayaAutentifikatsiya_66ae => '이중 인증';
  @override
  String get zaschitaAkkauntaOdnorazovymParolem_e9f1 => '일회용 비밀번호로 계정 보호';
  @override
  String get opasnayaZona_25bc => '위험지대';
  @override
  String get udalitAkkaunt_05c7 => '계정 삭제';
  @override
  String get neobratimoeDeystvie_7232 => '되돌릴 수 없는 행동';
  @override
  String get tema_9e26 => '주제';
  @override
  String get temnayaTema_cb48 => '어두운 테마';
  @override
  String get pereklyuchitMezhduTemnymISvetlym_5415 => '어두운 모드와 밝은 모드 간 전환';
  @override
  String get razmerShrifta_1155 => '글꼴 크기';
  @override
  String get a_87a0 => '에이';
  @override
  String get pokazyvatVsplyvayuschieUvedomleniya_754e => '팝업 알림 표시';
  @override
  String get zvuk_9329 => '소리';
  @override
  String get vosproizvoditZvukPriNovomSoobschenii_47cc => '새 메시지에서 소리 재생';
  @override
  String get osnovnyeNastroyki_231c => '기본 설정';
  @override
  String get rezhimEkonomiiEnergii_edfc => '절전 모드';
  @override
  String get optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb =>
      '리소스를 절약하기 위해 애플리케이션 성능을 최적화합니다.';
  @override
  String get avtomaticheskiySpyaschiyRezhim_5955 => '자동 절전 모드';
  @override
  String get perevoditPrilozhenieVSpyaschiyRezhim_1c07 =>
      '비활성 상태일 때 애플리케이션을 절전 모드로 전환합니다.';
  @override
  String get animatsii_05c7 => '애니메이션';
  @override
  String get uproschennyeAnimatsii_3a13 => '단순화된 애니메이션';
  @override
  String get umenshaetKolichestvoAnimatsiyInterfeysa_6bf1 =>
      '인터페이스 애니메이션 수를 줄입니다.';
  @override
  String get skoroBudetDostupno_de07 => '곧 출시 예정';
  @override
  String get gostevoyRezhim_6d82 => '게스트 모드';
  @override
  String get voyditeDlyaDostupaKAkkauntu_a5c8 => '귀하의 계정에 액세스하려면 로그인하세요';
  @override
  String get nazhmiteDlyaProsmotraIzmeneniy_0255 => '변경사항을 보려면 클릭하세요.';
  @override
  String get vvediteKodPodtverzhdeniya_61af => '인증코드를 입력하세요';
  @override
  @override
  String get nevernyyKodPodtverzhdeniya_7762 => '유효하지 않은 인증 코드입니다';
  @override
  String get podtverditeEMail_4bd4 => '이메일을 확인하세요';
  @override
  String get proverit_340b => '확인';
  @override
  @override
  String get otpravitKodPovtorno_7703 => '코드 재전송';
  @override
  String get sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e =>
      '최신 데스크탑 애플리케이션\n아름다운 인터페이스와 3D 효과로';
  @override
  String get tehnologii_6332 => '기술';
  @override
  String get vyNashliPashalku_1a57 => '🎉 부활절 달걀을 찾았습니다! 🎉';
  @override
  String get spasiboZaIspolzovanieXaneo_d079 => 'xaneo를 사용해 주셔서 감사합니다!';
  @override
  String get globalnyyPoisk_77bf => '글로벌 검색';
  @override
  @override
  String get poiskKontaktovChatovKanalovBotov_db66 => '연락처, 대화방, 채널, 봇 검색...';
  @override
  @override
  String get lyudi_c7ae => '사용자';
  @override
  @override
  String get gruppy_ebc4 => '그룹';
  @override
  @override
  String get kanaly_0c11 => '채널';
  @override
  @override
  String get boty_d6e4 => '봇';
  @override
  @override
  String get izbrannoe_2fc4 => '저장된 메시지';
  @override
  @override
  String get vvediteZaprosDlyaPoiskaPo_9955 => '검색어를 입력하여 Xaneo 네트워크 검색';
  @override
  @override
  String get nichegoNeNaydeno_8767 => '검색 결과가 없습니다';
  @override
  @override
  String get izbrannoe_b637 => '저장된 메시지';
  @override
  @override
  String get boty_800d => '봇';
  @override
  @override
  String get kanaly_ccec => '채널';
  @override
  @override
  String get gruppy_cfd6 => '그룹';
  @override
  @override
  String get polzovateli_e0ec => '사용자';
  @override
  @override
  String get sohranennyeSoobscheniya_6b62 => '저장된 메시지';
  @override
  @override
  String get bot_0ae1 => '봇';
  @override
  @override
  String get bot_0f46 => 'bot';
  @override
  @override
  String get gruppa_99d9 => '그룹';
  @override
  @override
  String get kanal_2710 => '채널';
  @override
  String get versiya_3725 => '버전';
  @override
  String get tehnicheskayaInformatsiya_ba0f => '기술정보';
  @override
  String get platforma_8848 => '플랫폼';
  @override
  String get arhitekturaProtsessora_c079 => '프로세서 아키텍처';
  @override
  String get posmotretNaGithub_5238 => 'GitHub에서 보기';
  @override
  String get zakryt_dd94 => '닫기';
  @override
  String get vklyuchitTemnuyuTemu_ed17 => '어두운 테마 활성화';
  @override
  String get vklyuchitUvedomleniya_d311 => '알림 활성화';
  @override
  String get kastomnyyOverleyXaneo_7d39 => '사용자 정의 Xaneo 오버레이';
  @override
  String get animirovannyeUvedomleniyaSBystrymOtvetom_a25d =>
      '빠른 응답을 제공하는 애니메이션 알림';
  @override
  String get aaBbVv_1c6b => '아아 bb bb';
  @override
  String get pleylist_a04c => '재생목록';
  @override
  String get spisokMuzyki_d477 => '음악 목록';
  @override
  String get loc_0B_5a4d => '0B';
  @override
  String get b_3b67 => '비';
  @override
  String get kb_419d => 'KB';
  @override
  String get mb_b808 => 'MB';
  @override
  String get gb_e572 => 'GB';
  @override
  String get audiozapis_867d => '오디오 녹음';
  @override
  String get muzykalnyyTrek_b15d => '음악 트랙';
  @override
  String get muzykalnyeTrekiOtsutstvuyut_3301 => '음악 트랙이 없습니다.';
  @override
  @override
  String get nikneymUzheZanyat_59aa => '이미 사용 중인 사용자 이름입니다';
  @override
  @override
  String get oshibkaProverki_2ab0 => '확인 오류';
  @override
  @override
  String get emailUzheZanyat_17e1 => '이미 등록된 이메일입니다';
  @override
  @override
  String get oshibkaOtpravkiKoda_a42a => '인증 코드 전송 오류';
  @override
  @override
  String get neobhodimoPrinyatUsloviyaISoglasie_e31e =>
      '이용 약관 및 개인정보 처리방침에 동의해야 합니다';
  @override
  @override
  String get registratsiyaUspeshna_9d5c => '회원가입이 완료되었습니다!';
  @override
  @override
  String get oshibkaRegistratsii_b9f2 => '회원가입 오류';
  @override
  @override
  String get nazad_2b0b => '뒤로';
  @override
  @override
  String get kakVasZovut_68b7 => '이름이 무엇인가요?';
  @override
  @override
  String get kogdaVyRodilis_26f2 => '생년월일이 언제인가요?';
  @override
  @override
  String get pridumayteNikneym_221b => '사용자 이름 설정';
  @override
  @override
  String get vashEmail_8bbd => '이메일 주소';
  @override
  @override
  String get podtverzhdenieEmail_281f => '이메일 인증';
  @override
  @override
  String get sozdayteParol_5f4c => '비밀번호 생성';
  @override
  @override
  String get podtverzhdenieParolya_ebc2 => '비밀번호 확인';
  @override
  @override
  String get dobavteFoto_25eb => '프로필 사진 추가';
  @override
  @override
  String get posledniyShag_e0c5 => '마지막 단계';
  @override
  @override
  String get vvediteVasheNastoyascheeImya_e656 => '실명을 입력하세요';
  @override
  @override
  String get vamDolzhnoBytNeMenee_1111 => '13세 이상이어야 합니다';
  @override
  @override
  String get nikneymDolzhenBytUnikalnym_952d => '사용자 이름은 고유해야 합니다';
  @override
  @override
  String get myOtpravimKodPodtverzhdeniya_fc71 => '이메일로 인증 코드가 전송됩니다';
  @override
  @override
  String get vvedite6ZnachnyyKodIz_f22f => '이메일의 6자리 코드를 입력하세요';
  @override
  @override
  String get pridumayteNadezhnyyParol_2312 => '안전한 비밀번호 생성 (최소 8자)';
  @override
  @override
  String get povtoriteParolEscheRaz_6723 => '비밀번호를 다시 입력하세요';
  @override
  @override
  String get etoNeobyazatelnoNoPriyatno_b6a3 => '선택 사항이지만 권장됩니다';
  @override
  @override
  String get proverteVashiDannyeIPrimite_3121 => '정보를 확인하고 약관에 동의하세요';
  @override
  @override
  String get registratsiya_0b93 => '회원가입';
  @override
  @override
  String get vasheImya_51eb => '이름';
  @override
  @override
  @override
  String get proverkaDostupnosti_da13 => '사용 가능 여부 확인 중...';
  @override
  @override
  @override
  String get nikneymDostupen_3fc9 => '사용자 이름 사용 가능';
  @override
  @override
  @override
  String get nikneymZanyat_8a5f => '사용자 이름 사용 불가';
  @override
  @override
  @override
  String get emailDostupen_e903 => '이메일 사용 가능';
  @override
  @override
  @override
  String get emailZanyat_fb40 => '이메일 사용 불가';
  @override
  @override
  String get kodPodtverzhdeniya_1c9d => '인증 코드';
  @override
  @override
  String get parol_5ebe => '비밀번호';
  @override
  @override
  String get podtverditeParol_e3e3 => '비밀번호 확인';
  @override
  @override
  String get nazhmiteChtobyDobavitFoto_d6e8 => '탭하여 사진 추가';
  @override
  @override
  String get udalitFoto_3426 => '사진 삭제';
  @override
  @override
  String get yaPrinimayuUsloviyaIspolzovaniya_391a => '이용 약관에 동의합니다';
  @override
  @override
  String get yaSoglasenNaObrabotkuPersonalnyh_f2a8 => '개인정보 수집 및 이용에 동의합니다';
  @override
  @override
  String get zavershit_b0e3 => '완료';
  @override
  @override
  String get dalee_c453 => '다음';
  @override
  @override
  String get dataRozhdeniya_505e => '생년월일';
  @override
  String get vklyuchitTemnuyuTemuOformleniya_86c4 => '어두운 테마 활성화';
  @override
  @override
  String get yanvar_ee86 => '1월';
  @override
  @override
  String get fevral_28ff => '2월';
  @override
  @override
  String get mart_d766 => '3월';
  @override
  @override
  String get aprel_03e9 => '4월';
  @override
  @override
  String get may_2e53 => '5월';
  @override
  @override
  String get iyun_cfcb => '6월';
  @override
  @override
  String get iyul_89fb => '7월';
  @override
  @override
  String get avgust_de5a => '8월';
  @override
  @override
  String get sentyabr_ebfb => '9월';
  @override
  @override
  String get oktyabr_1720 => '10월';
  @override
  @override
  String get noyabr_66fb => '11월';
  @override
  @override
  String get dekabr_39b3 => '12월';
  @override
  @override
  String get pn_2c1e => '월';
  @override
  @override
  String get vt_7145 => '화';
  @override
  @override
  String get sr_c6e4 => '수';
  @override
  @override
  String get cht_a51f => '목';
  @override
  @override
  String get pt_0123 => '금';
  @override
  @override
  String get sb_3a4b => '토';
  @override
  @override
  String get vs_4ad9 => '일';
  @override
  @override
  String get gotovo_34e1 => '완료';
  @override
  String get oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b =>
      '키 복구 오류(덮어쓰지 못했습니다)';
  @override
  String get kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7 =>
      '암호화 키를 다시 생성할 때 심각한 오류가 발생했습니다.';
  @override
  String get oshibkaZagruzkiKlyucheyNaServer_ff9b =>
      '서버에 키를 로드하는 중에 오류가 발생했습니다.';
  @override
  String get oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4 =>
      '암호화 키를 검색하는 중에 오류가 발생했습니다.';
  @override
  String get prevyshenLimitV5Akkauntov_a6a9 =>
      '이 클라이언트의 계정 한도인 5개를 초과했거나 연결 오류가 있습니다.';
  @override
  @override
  @override
  String get oshibkaAvtorizatsii_9f5c => '인증 오류';
  @override
  @override
  @override
  String get oshibkaPodklyucheniyaKServeru_8b96 => '서버 연결 오류';
  @override
  @override
  String get nazadKMessendzheru_de29 => '메신저로 돌아가기';
  @override
  @override
  String get voytiVAkkaunt_c439 => '계정 로그인';
  @override
  @override
  String get vvediteParol_1370 => '비밀번호 입력';
  @override
  @override
  String get vvediteSvoiDannyeDlyaDostupa_319e => '메시지에 액세스하려면 로그인 정보를 입력하세요.';
  @override
  @override
  String get voyti_63a7 => '로그인';
  @override
  String get sobesednik_7025 => '대담자';
  @override
  String get vy_0101 => '당신';
  @override
  String get vyDelitesSvoimEkranom_16b1 => '화면을 공유합니다';
  @override
  String get polzovatel_f154 => '사용자';
  @override
  String get ishodyaschiyVyzov_650b => '발신 전화...';
  @override
  String get vhodyaschiyVyzov_19ff => '전화 수신 중...';
  @override
  String get podklyucheno_d022 => '연결됨';
  @override
  String get ozhidanieOtveta_a984 => '응답을 기다리는 중...';
  @override
  String get razgovorPoAudiosvyazi_3ed7 => '오디오 대화';
  @override
  String get translyatsiyaVashegoEkranaZapuschena_575a => '스크린캐스트가 시작되었습니다';
  @override
  String get sobesednikViditVseChtoProishodit_c759 =>
      '대담자는 데스크탑에서 일어나는 모든 일을 봅니다.';
  @override
  String get vhodyaschiyVyzov_905e => '수신 전화';
  @override
  String get neizvestnyy_be89 => '알 수 없음';
  @override
  String get videozvonok_dd18 => '영상 통화...';
  @override
  String get golosovoyZvonok_5410 => '음성 통화...';
  @override
  String get otklonit_8b0d => '거부';
  @override
  String get otvetit_e568 => '답장하다';
  @override
  String get gruppovoyZvonok_dac1 => '그룹통화';
  @override
  String get podklyuchenieKZvonku_e2cf => '통화 연결 중...';
  @override
  String get podklyuchenieKVeschaniyu_038b => '브로드캐스트에 연결 중...';
  @override
  String get uchastnik_cffb => '회원';
  @override
  String get vy_479c => '당신';
  @override
  String get svernut_ca9f => '접기';
  @override
  String get vhodyaschiyVyzov_d2f3 => '전화 수신';
  @override
  String get novoeSoobschenie_1d49 => '새 메시지';
  @override
  String get vashOtvet_40c2 => '당신의 대답은 ...';
  @override
  String get videovyzov_3353 => '영상 통화...';
  @override
  String get audiovyzov_bbb5 => '음성통화...';
  @override
  String get nachatZvonok_3d26 => '통화 시작';
  @override
  String get golosovoyZvonok_b615 => '음성통화';
  @override
  String get pozvonitPoGolosovoySvyazi_4069 => '음성 통화 걸기';
  @override
  String get videozvonok_8142 => '영상통화';
  @override
  String get pozvonitSVklyuchennoyKameroy_fb05 => '카메라를 켜고 통화';
  @override
  String get zashifrovannoeSoobschenie_ca35 => '[암호화된 메시지]';
  @override
  String get golosovoeSoobschenie_4a85 => '🎤 음성 메시지';
  @override
  String get videosoobschenie_d687 => '🎬 영상 메시지';
  @override
  String get fayl_826d => '📎 파일';
  @override
  String get zvonok_e8d5 => '📞 전화';
  @override
  String get oshibkaDeshifrovaniya_4146 => '[복호화 오류]';
  @override
  String get zapisyvaetGolosovoe_2a5c => '음성 녹음...';
  @override
  String get pechataet_812c => '인쇄...';
  @override
  String get neUdalosArhivirovatChat_ab89 => '채팅을 보관하지 못했습니다.';
  @override
  String get neUdalosRazarhivirovatChat_f0d7 => '채팅 보관을 취소하지 못했습니다.';
  @override
  String get arhiv_56aa => '아카이브';
  @override
  String get netUserid_634a => '[사용자ID 없음]';
  @override
  String get netKlyucha_337b => '[열쇠 없음]';
  @override
  String get neizvestnyyTipChata_2617 => '[알 수 없는 채팅 유형]';
  @override
  String get neUdalosPoluchitKlyuchShifrovaniya_b953 =>
      '채팅용 암호화 키를 가져오지 못했습니다.';
  @override
  String get gruppa_19c2 => '그룹';
  @override
  String get uchastnik_5bce => '참가자';
  @override
  String get uchastnika_92d9 => '참가자';
  @override
  String get uchastnikov_5d6b => '참가자';
  @override
  String get kanal_64ec => '채널';
  @override
  String get podpischik_695a => '가입자';
  @override
  String get podpischika_b490 => '가입자';
  @override
  String get podpischikov_ba39 => '가입자';
  @override
  String get segodnya_9626 => '오늘';
  @override
  String get vchera_61d4 => '어제';
  @override
  String get yanvarya_d861 => '1월';
  @override
  String get fevralya_fcf9 => '2월';
  @override
  String get marta_bb77 => '3월';
  @override
  String get aprelya_2b5a => '4월';
  @override
  String get maya_4dbb => '5월';
  @override
  String get iyunya_adcb => '6월';
  @override
  String get iyulya_3236 => '7월';
  @override
  String get avgusta_e3aa => '8월';
  @override
  String get sentyabrya_a146 => '9월';
  @override
  String get oktyabrya_7abd => '10월';
  @override
  String get noyabrya_6e78 => '11월';
  @override
  String get dekabrya_29cc => '12월';
  @override
  String get vyPodpisalisNaKanal_b2b3 => '채널을 구독했습니다.';
  @override
  String get vyPrisoedinilisKGruppe_07bd => '그룹에 가입하셨습니다.';
  @override
  String get neUdalosPrisoedinitsya_31e6 => '참여하지 못했습니다.';
  @override
  String get vyOtpisalisOtKanala_7698 => '채널 구독을 취소했습니다.';
  @override
  String get vyPokinuliGruppu_5a52 => '그룹에서 탈퇴하셨습니다.';
  @override
  String get neUdalosVypolnitDeystvie_3cfd => '작업 실패';
  @override
  String get neUdalosPereklyuchitAkkaunt_968b => '계정을 전환하지 못했습니다.';
  @override
  String get media_c247 => '미디어';
  @override
  String get fayly_200c => '파일';
  @override
  String get golos_2d89 => '음성';
  @override
  String get ssylki_9f58 => '링크';
  @override
  String get profil_c62a => '프로필';
  @override
  String get imyaPolzovatelya_6fd4 => '사용자 이름';
  @override
  String get denRozhdeniya_e41d => '생일';
  @override
  String get polzovatelSkrylInformatsiyuOSebe_f416 =>
      '사용자는 자신에 대한 숨겨진 정보를 가지고 있습니다.';
  @override
  String get god_6270 => '년';
  @override
  String get goda_7443 => '년';
  @override
  String get let_257a => '년';
  @override
  String get skopirovano_f70b => '복사됨';
  @override
  String get akkaunty_80b5 => '계정';
  @override
  String get dobavitAkkaunt_5253 => '계정 추가';
  @override
  String get limit5Akkauntov_fdb7 => '제한: 계정 5개';
  @override
  String get nazadKChatam_7edb => '채팅으로 돌아가기';
  @override
  String get chaty_19ad => '채팅';
  @override
  String get globalnyyPoisk_7ff2 => '글로벌 검색';
  @override
  String get arhivPust_3e22 => '아카이브가 비어 있습니다.';
  @override
  String get netSoobscheniy_29d4 => '메시지 없음';
  @override
  String get toDoList_27e1 => '📋 할 일 시트';
  @override
  String get opros_6ff1 => '🗳️ 설문조사';
  @override
  String get fotografiya_5709 => '📷 사진';
  @override
  String get razarhivirovat_416b => '압축을 푼다';
  @override
  String get vArhiv_ce22 => '아카이브로';
  @override
  String get chat_c52b => '채팅';
  @override
  String get vyberiteChatDlyaNachalaObscheniya_36a5 => '채팅을 시작하려면 채팅을 선택하세요.';
  @override
  String get bot_2712 => '봇';
  @override
  String get vSeti_d902 => '온라인';
  @override
  String get neVSeti_ee01 => '오프라인';
  @override
  String get nastroykiChata_1e0d => '채팅 설정';
  @override
  String get pokinutGruppu_e6ce => '그룹 탈퇴';
  @override
  String get prisoedinitsyaKGruppe_eb45 => '그룹에 가입하세요';
  @override
  String get otpisatsyaOtKanala_fdbc => '채널 구독 취소';
  @override
  String get podpisatsyaNaKanal_2dad => '채널을 구독하세요';
  @override
  String get netSoobscheniyNapishiteChtoNibud_2bf4 => '메시지가 없습니다. 무언가 작성해보세요!';
  @override
  String get prisoedinilsyaKChatu_f623 => '채팅에 참여했습니다';
  @override
  String get pokinulChat_d567 => '채팅에서 나갔습니다';
  @override
  String get podpisalsyaNaKanal_0673 => '채널을 구독했습니다';
  @override
  String get otpisalsyaOtKanala_fa13 => '채널 구독 취소됨';
  @override
  String get polzovatelya_1083 => '사용자';
  @override
  String get priglasil_47ae => '초대됨';
  @override
  String get rasshifrovka_e47f => '[대본...]';
  @override
  String get sistemnoeSoobschenie_d2bd => '시스템 메시지';
  @override
  String get soobschenie_3715 => '메시지';
  @override
  String get videosoobschenie_57f1 => '📹 영상 메시지';
  @override
  String get spisokZadach_cfa4 => '📋 작업 목록';
  @override
  String get opros_5902 => '📊 설문조사';
  @override
  String get vlozhenie_ef44 => '첨부파일';
  @override
  String get fayl_2d46 => '파일';
  @override
  String get zagruzkaFayla_f817 => '파일 로드 중...';
  @override
  String get ishodyaschiyZvonok_8381 => '발신전화';
  @override
  String get razgovorNeSostoyalsya_67fb => '대화가 이루어지지 않았습니다';
  @override
  String get vhodyaschiyZvonok_5ce9 => '전화 수신';
  @override
  String get otklonennyyZvonok_d499 => '거부된 통화';
  @override
  String get vyOtkloniliVyzov_8d1d => '전화를 거부하셨습니다.';
  @override
  String get propuschennyyZvonok_e98d => '부재중 전화';
  @override
  String get vyPropustiliVyzov_f17a => '전화를 받지 못하셨어요';
  @override
  String get vlozhenie_2474 => '📎 첨부';
  @override
  String get tb_0e05 => '결핵';
  @override
  String get zapisGolosovogo_9c91 => '음성녹음...';
  @override
  String get zapisVideo_dd2a => '영상녹화...';
  @override
  String get otpustiteDlyaOtpravki_ea7b => '보내려면 손을 떼세요';
  @override
  String get emodzi_f822 => '이모티콘';
  @override
  String get panelEmodziVRazrabotke_b6ce => '개발 중인 이모티콘 패널';
  @override
  String get napisatSoobschenie_62d4 => '메시지를 작성하세요...';
  @override
  String get dobavitVlozhenie_769b => '첨부파일 추가';
  @override
  String get spisokZadach_1852 => '작업 목록';
  @override
  String get opros_9f36 => '설문조사';
  @override
  String get zapisGolosovogoGs_db4e => '음성녹음(VO)';
  @override
  String get zapisVideoVs_9676 => '비디오 녹화(VS)';
  @override
  String get uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3 =>
      '•녹화하려면 버튼을 길게 누르세요.\n• 모드를 전환하려면 누르세요.';
  @override
  @override
  String get novyyChat_f775 => '새 대화';
  @override
  @override
  String get imyaPolzovatelyaMin5Simvolov_1232 => '사용자 이름 (최소 5자)';
  @override
  @override
  String get vvedite5IliBoleeSimvolov_f983 => '5자 이상 입력하세요';
  @override
  @override
  String get polzovateliNeNaydeny_c01a => '사용자를 찾을 수 없습니다';
  @override
  String get mnozhestvennyyVybor_9b60 => '객관식';
  @override
  String get odinochnyyVybor_d920 => '단일 선택';
  @override
  String get netGolosov_17d0 => '투표 없음';
  @override
  String get golos_6b94 => '목소리';
  @override
  String get golosa_bb8d => '목소리';
  @override
  String get golosov_7f51 => '투표';
  @override
  String get nePoluchenIdFaylaOt_86c8 => '서버로부터 파일 ID를 받지 못했습니다.';
  @override
  String get faylZagruzhenIPrikreplen_dc24 => '파일 업로드 및 첨부';
  @override
  String get neizvestnayaOshibkaZagruzki_68cb => '알 수 없는 다운로드 오류';
  @override
  String get oshibkaZagruzkiFayla_86e5 => '파일 다운로드 오류';
  @override
  String get sohranitFaylKak_0f93 => '다른 이름으로 파일 저장';
  @override
  String get oshibkaSkachivaniyaFayla_34ac => '파일 다운로드 오류';
  @override
  String get bezNazvaniya_6584 => '제목 없음';
  @override
  String get bezVoprosa_d390 => '질문 없음';
  @override
  String get netDostupaKMikrofonu_a4ef => '마이크 액세스 권한 없음';
  @override
  String get zapisVideoCherezPlaginCamera_b9dd =>
      '📹 카메라 플러그인을 통한 비디오 녹화가 시작되었습니다';
  @override
  String get kameraNeInitsializirovanaNaEtoy_21e0 =>
      '📹 이 플랫폼에서는 카메라가 초기화되지 않습니다.';
  @override
  String get kameraNeGotova_9f09 => '카메라가 준비되지 않았습니다.';
  @override
  String get zapisVideosoobscheniyaNaEtoyPlatforme_a561 =>
      '📹 이 플랫폼에서는 영상 메시지 녹음을 직접 사용할 수 없습니다.';
  @override
  String get arecordOstanovlen_edf2 => '🎙️ 기록이 중지되었습니다';
  @override
  String get ffmpegOstanovlen_63a0 => '📹 ffmpeg가 중지되었습니다';
  @override
  String get zapisSlishkomKorotkaya_5cda => '항목이 너무 짧습니다.';
  @override
  String get oshibkaZapisiFaylPust_106b => '쓰기 오류: 파일이 비어 있습니다.';
  @override
  String get videosoobschenieOtpravlenoSimulyatsiya_fb29 => '전송된 영상 메시지(시뮬레이션)';
  @override
  String get zapisOtmenena_1609 => '등록이 취소되었습니다.';
  @override
  String get otpravitGolosovoeSoobschenie_2481 => '음성 메시지 보내기';
  @override
  String get imitatsiyaZapisiGolosovogoSoobscheniya_81e7 => '음성 메시지 녹음 시뮬레이션.';
  @override
  String get otpravit_6da0 => '보내기';
  @override
  String get sozdatToDo_8c92 => '할 일 만들기';
  @override
  String get nazvanieSpiska_c3cc => '목록 이름';
  @override
  String get punkty_0481 => '품목:';
  @override
  String get dobavitPunkt_930c => '항목 추가';
  @override
  String get sozdat_b059 => '만들기';
  @override
  String get sozdatOpros_4b9e => '설문조사 만들기';
  @override
  String get vopros_0911 => '질문';
  @override
  String get variantyOtveta_ef4e => '답변 옵션:';
  @override
  String get dobavitVariant_76be => '옵션 추가';
  @override
  String get golosovoeSoobschenie_33d5 => '음성 메시지';
  @override
  String get videosoobschenie_2951 => '영상 메시지';
  @override
  String get video_a095 => '비디오';
  @override
  String get neUdalosZagruzitIzobrazhenie_3fa0 => '이미지를 로드하지 못했습니다.';
  @override
  String get muzyka_0660 => '음악';
  @override
  String get netDannyh_dee9 => '데이터 없음';
  @override
  String get istoriyaSoobscheniyPustaIliChat_2d07 =>
      '메시지 기록이 비어 있거나 채팅이 아직 로컬에 저장되지 않았습니다.';
  @override
  String get obschieMaterialy_11e4 => '일반재료';
  @override
  String get netMediafaylov_08d2 => '미디어 파일 없음';
  @override
  String get zdesBudutOtobrazhatsyaObschieFoto_9bc7 =>
      '공유된 사진과 동영상이 여기에 표시됩니다.';
  @override
  String get netFaylov_e95e => '파일 없음';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c =>
      '업로드된 파일이 여기에 표시됩니다.';
  @override
  String get netGolosovyhSoobscheniy_2427 => '음성 메시지 없음';
  @override
  String get zdesBudutOtobrazhatsyaGolosovyeI_0a73 => '음성 및 영상 메시지가 여기에 표시됩니다';
  @override
  String get netSsylok_b0ec => '링크 없음';
  @override
  String get zdesBudutOtobrazhatsyaObschieSsylki_6b61 => '일반 링크가 여기에 표시됩니다.';
  @override
  String get ssylkaSkopirovanaVBufer_c16e => '링크가 클립보드에 복사되었습니다.';
  @override
  String get netMuzyki_1ca3 => '음악 없음';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23 =>
      '제출된 트랙이 여기에 표시됩니다.';
  @override
  String get udalennyyAkkaunt_ce47 => '삭제된 계정';
  @override
  String get opisanie_38ca => '설명';
  @override
  String get mobilnyy_5ac7 => '모바일';
  @override
  String get bylANedavno_168d => '최근에';
  @override
  String get minutu_5373 => '분';
  @override
  String get minuty_5bc9 => '분';
  @override
  String get minut_b877 => '분';
  @override
  String get nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a => '새 버전을 다운로드하려면 클릭하세요.';
  @override
  String get poiskLyudeyBotovGrupp_e84e => '사람, 봇, 그룹 검색...';
  @override
  String get vveditePoiskovyyZapros_0b8c => '검색어를 입력하세요';
  @override
  String get polzovateli_b8c4 => '사용자';
  @override
  String get moiLichnyeSoobscheniya_7d3b => '내 개인 메시지';
  @override
  String get sozdatNovyyChat_fd41 => '새 채팅 만들기';
  @override
  String get lichnyyChat_cbec => '개인 채팅';
  @override
  String get nachatObschenieSPolzovatelem_0578 => '사용자와 대화 시작';
  @override
  String get sozdatGruppu_459f => '그룹 만들기';
  @override
  String get gruppovoyChatDlyaObscheniyaS_01ba => '친구들과 소통할 수 있는 그룹채팅';
  @override
  String get sozdatKanal_9022 => '채널 만들기';
  @override
  String get kanalDlyaShirokoyAuditorii_9dba => '폭넓은 시청자를 위한 채널';
  @override
  String get redaktirovanie_1167 => '편집';
  @override
  String get vlevo_1af1 => '왼쪽';
  @override
  String get vpravo_c316 => '오른쪽';
  @override
  String get poGor_ff50 => '산을 따라';
  @override
  String get poVert_b4a9 => '수직';
  @override
  String get vvediteNazvanieGruppy_0a69 => '그룹 이름을 입력하세요';
  @override
  String get dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0 =>
      '공개 그룹에는 닉네임(@username)이 필요합니다.';
  @override
  String get gruppaSozdana_6b3b => '그룹이 생성되었습니다.';
  @override
  String get oshibkaPriSozdaniiGruppy_794e => '그룹을 만드는 중에 오류가 발생했습니다.';
  @override
  String get nazhmiteNaIkonkuChtobyVybrat_af03 => '아바타를 선택하려면 아이콘을 클릭하세요.';
  @override
  String get nazvanieGruppy_9a39 => '그룹 이름';
  @override
  String get opisanieNeobyazatelno_7812 => '설명(선택사항)';
  @override
  String get privatnayaGruppa_d20e => '비공개 그룹';
  @override
  String get publichnayaGruppa_50f8 => '공개 그룹';
  @override
  String get vhodTolkoPoPriglasheniyu_97a1 => '초대로만 입장 가능';
  @override
  String get lyuboyMozhetNaytiIVstupit_5e26 => '누구나 찾아 가입할 수 있습니다.';
  @override
  String get publichnayaSsylkanikneymMyGroup_6640 => '공개 링크/닉네임(@my_group)';
  @override
  String get vvediteNazvanieKanala_5536 => '채널 이름을 입력하세요';
  @override
  String get dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06 =>
      '공개 채널에는 링크/닉네임(@mychannel)이 필요합니다.';
  @override
  String get kanalSozdan_1522 => '채널이 생성되었습니다';
  @override
  String get oshibkaPriSozdaniiKanala_7d4b => '채널을 만드는 중에 오류가 발생했습니다.';
  @override
  String get nazvanieKanala_c548 => '채널 이름';
  @override
  String get privatnyyKanal_3139 => '비공개 채널';
  @override
  String get publichnyyKanal_0f7c => '공개 채널';
  @override
  String get podpiskaTolkoPoPriglasheniyu_99c3 => '초대로만 구독 가능';
  @override
  String get lyuboyMozhetNaytiIPodpisatsya_8579 => '누구나 찾아 구독할 수 있습니다.';
  @override
  String get ssylkanikneymKanalaMychannel_79f6 => '채널 링크/닉네임(@mychannel)';
  @override
  String get yazykInterfeysa_b78b => '인터페이스 언어';
  @override
  String get dannyeUspeshnoSohraneny_2cc5 => '데이터가 성공적으로 저장되었습니다';
  @override
  String get oshibkaPriSohranenii_126f => '저장하는 중 오류가 발생했습니다.';
  @override
  String get lichnyeDannye_10a7 => '개인정보';
  @override
  String get nikneymUsername_8035 => '닉네임(@사용자 이름)';
  @override
  String get nikneymNelzyaIzmenit_0b99 => '닉네임은 변경할 수 없습니다';
  @override
  String get oSebeBio_b730 => '나에 대해 (약력)';
  @override
  String get rasskazhiteNemnogoOSebe_3daa => '자신에 대해 좀 알려주세요...';
  @override
  String get nastroykiPrivatnostiSohraneny_447c => '개인정보 보호 설정이 저장되었습니다.';
  @override
  String get privatnost_3098 => '개인정보 보호';
  @override
  String get kommunikatsii_e9b8 => '통신';
  @override
  String get ktoMozhetPisat_3322 => '누가 쓸 수 있나요?';
  @override
  String get zapisGolosovyh_8073 => '음성 녹음';
  @override
  String get otpravkaFaylov_aaca => '파일 보내기';
  @override
  String get priglashatVGruppy_3631 => '그룹에 초대';
  @override
  String get vidimostProfilya_448f => '프로필 가시성';
  @override
  String get ktoViditAvatar_b5d8 => '아바타를 보는 사람';
  @override
  String get vremyaVSeti_be29 => '온라인 시간';
  @override
  String get vneshniyVid_5a0f => '외관';
  @override
  String get rezhimOformleniyaInterfeysa_b91d => '인터페이스 디자인 모드';
  @override
  String get pokazyvatVizualnyeEffektyIPerehody_3fd7 => '시각 효과 및 전환 표시';
  @override
  String get razmerTeksta_3c4f => '텍스트 크기';
  @override
  String get bezopasnost_fcbc => '보안';
  @override
  String get dvuhfaktornayaAutentifikatsiya_acdc => '이중 인증';
  @override
  String get zaschitaAkkaunta2fa_f1ab => '2FA 계정 보호';
  @override
  String get vklyucheno_6b96 => '포함됨';
  @override
  String get xaneoMobileAktivnoSeychas_3345 => 'Xaneo Mobile • 현재 활성화됨';
  @override
  String get zaschischennyyMessendzher_2f59 => '보안 메신저';
  @override
  String get temnayaTema_6018 => '어두운 테마';
  @override
  String get vklyuchenaPoUmolchaniyu_7610 => '활성화됨(기본값)';
  @override
  String get setevoyFiltr_40c2 => '서지 필터';
  @override
  String get vklyuchen_0994 => '활성화됨';
  @override
  String get spisokMuzyki_57d0 => '음악 목록';
  @override
  String get trek_5049 => '트랙';
  @override
  String get trekov_d3f4 => '트랙';
  @override
  String get pozhaluystaZapolniteVoprosIKak_7ad5 =>
      '질문을 작성하고 최소 2개의 답변 옵션을 입력하세요.';
  @override
  String get sozdatOpros_8401 => '설문조사 만들기';
  @override
  String get sozdatSpisokZadach_4018 => '작업 목록 만들기';
  @override
  String get pozhaluystaZapolniteNazvanieIKak_3783 => '제목과 항목을 하나 이상 입력하세요.';
  @override
  String get sozdatSpisokZadach_0416 => '작업 목록 만들기';
  @override
  String get vhodyaschiyVideozvonok_14d4 => '화상 통화 수신';
  @override
  String get prinyat_5dc5 => '수락';
  @override
  String get netObschihFaylov_bf77 => '공유된 파일 없음';
  @override
  String get neUdalosRazarhivirovatChatNa_b6f6 => '서버에서 채팅을 보관 취소하지 못했습니다.';
  @override
  String get poiskVArhive_c5d8 => '아카이브 검색...';
  @override
  String get poprobuyteIzmenitZapros_52ea => '요청을 변경해 보세요';
  @override
  String get zdesBudutNahoditsyaVashiArhivirovannye_7359 =>
      '보관된 채팅이 여기에 저장됩니다.';
  @override
  String get vernut_54aa => '반환';
  @override
  String get zashifrovannoeSoobschenie_c9ab => '암호화된 메시지';
  @override
  String get soobschenieNahoditsyaVysheVIstorii_dc90 => '메시지는 이야기에서 더 높습니다.';
  @override
  String get otpravlyaetFoto_67c1 => '사진을 보내다...';
  @override
  String get otpravlyaetVideo_ce80 => '영상을 보내다...';
  @override
  String get otpravlyaetFayl_5e88 => '파일을 보냅니다...';
  @override
  String get ktoTo_8405 => '누군가';
  @override
  String get trebuetsyaRazreshenieNaKameruI_06fa => '카메라 및 마이크 권한이 필요합니다.';
  @override
  String get kameraNeNaydena_208d => '카메라를 찾을 수 없습니다';
  @override
  String get zapisVideoOtmenena_1db7 => '영상 녹화가 취소되었습니다';
  @override
  String get slishkomKorotkoeVideosoobschenie_4676 => '영상 메시지가 너무 짧습니다.';
  @override
  String get pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35 =>
      '파일이 다운로드될 때까지 기다려 주십시오.';
  @override
  String get audiozvonok_dcf6 => '음성통화';
  @override
  String get otpravitFotoVideoAudioIli_37e9 => '사진, 비디오, 오디오 또는 기타 파일 보내기';
  @override
  String get provedenieGolosovaniyaVChate_a629 => '채팅으로 투표하기';
  @override
  String get sozdatToDoSpisok_cb50 => '할 일 목록 만들기';
  @override
  String get spisokZadachSOtmetkamiVypolneniya_c778 => '완료 표시가 있는 작업 목록';
  @override
  String get trebuetsyaRazreshenieNaZapisAudio_8175 => '오디오를 녹음하려면 권한이 필요합니다';
  @override
  String get slishkomKorotkoeSoobschenie_c2ee => '메시지가 너무 짧습니다.';
  @override
  String get uderzhivayteKnopkuDlyaZapisi_a762 => '녹음하려면 버튼을 길게 누르세요.';
  @override
  String get udalennyy_40c6 => '원격';
  @override
  String get udalennyy_c2c8 => '원격';
  @override
  String get neobhodimyRazresheniyaNaMikrofonI_224b =>
      '전화를 걸기 위해서는 마이크, 카메라 권한이 필요합니다.';
  @override
  String get bylATolkoChto_9ac0 => '그냥 거기 있었어';
  @override
  String get chatNeNayden_ba4f => '채팅을 찾을 수 없습니다';
  @override
  String get napishitePervoeSoobschenie_8260 => '첫 번째 메시지를 작성하세요';
  @override
  String get prisoedinitsyaKKanalu_f863 => '채널에 가입하세요';
  @override
  String get vyPodpisany_5fb9 => '구독 중입니다';
  @override
  String get otpisatsya_ee2d => '구독 취소';
  @override
  String get vyUspeshnoPodpisalisNaKanal_9c99 => '채널을 성공적으로 구독했습니다!';
  @override
  String get vyUspeshnoVstupiliVGruppu_61a1 => '그룹에 성공적으로 가입했습니다!';
  @override
  String get neUdalosPrisoedinitsyaPoprobuyteEsche_bce5 =>
      '가입하지 못했습니다. 다시 시도해 보세요.';
  @override
  String get vyrezat_a195 => '컷';
  @override
  String get kopirovat_112b => '복사';
  @override
  String get vstavit_dcc4 => '붙여넣기';
  @override
  String get vybratVse_4d09 => '모두 선택';
  @override
  String get zhirnyy_7774 => '굵게';
  @override
  String get kursiv_e0b1 => '이탤릭체';
  @override
  String get kod_3f34 => '코드';
  @override
  String get zacherknut_02fc => '줄을 그어 지우세요';
  @override
  String get soobschenie_8b9b => '메시지...';
  @override
  String get smahniteDlyaOtmeny_e976 => '취소하려면 스와이프하세요.';
  @override
  String get poisk_bfc9 => '검색';
  @override
  String get udalitChat_4b2b => '채팅 삭제';
  @override
  String get udalitKanal_482f => '채널 삭제';
  @override
  String get pozhalovatsya_a7d9 => '불평하다';
  @override
  String get redaktirovatGruppu_e40a => '그룹 수정';
  @override
  String get udalitGruppu_dff8 => '그룹 삭제';
  @override
  String get poiskSoobscheniyVremennoNedostupenV_4443 =>
      '모바일 버전에서는 일시적으로 메시지 검색을 사용할 수 없습니다.';
  @override
  String get zhalobaOtpravlenaModeratoram_4547 => '불만사항이 조정자에게 전송되었습니다.';
  @override
  String get redaktirovanieGruppyVremennoNedostupnoV_05d0 =>
      '모바일 버전에서는 일시적으로 그룹 수정이 불가능합니다.';
  @override
  String get vyUverenyChtoHotiteOchistit_7c3a =>
      '이 채팅의 메시지 기록을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';
  @override
  String get ochistit_7074 => '지우기';
  @override
  String get udalit_ed2b => '삭제';
  @override
  String get vyyti_0f05 => '로그아웃';
  @override
  String get oshibkaVosproizvedeniya_ac8a => '재생 오류';
  @override
  String get novoeZashifrovannoeSoobschenie_4d30 => '새로운 암호화된 메시지';
  @override
  String get poiskChatov_779c => '채팅 검색...';
  @override
  String get obnovlenie_53e2 => '업데이트...';
  @override
  String get soedinenie_5a58 => '연결...';
  @override
  String get lichnye_4cb3 => '개인';
  @override
  String get neUdalosArhivirovatChatNa_36aa => '서버에 채팅을 보관하지 못했습니다.';
  @override
  String get oshibkaZagruzkiChatov_902f => '채팅을 로드하는 중에 오류가 발생했습니다.';
  @override
  String get povtorit_b914 => '반복';
  @override
  String get netChatov_85e3 => '채팅 없음';
  @override
  String get nachniteNovyyRazgovor_8290 => '새로운 대화를 시작하세요';
  @override
  String get neUdalosZagruzitAkkaunty_8570 => '계정을 로드하지 못했습니다.';
  @override
  String get vyberiteAkkaunt_79e7 => '계정을 선택하세요';
  @override
  String get bystryyVhodNaEtomUstroystve_3f30 => '이 기기에 빠른 로그인';
  @override
  String get voytiSParolem_9277 => '비밀번호로 로그인';
  @override
  String get sozdatXaneoId_4033 => 'Xaneo ID 생성';
  @override
  String get netSohranennyhAkkauntov_b669 => '저장된 계정 없음';
  @override
  String get tolkoChto_4493 => '지금 막';
  @override
  String get emailNedostupen_fc3e => '이메일을 사용할 수 없습니다.';
  @override
  String get nevernyyKod_50f9 => '잘못된 코드';
  @override
  String get oshibkaProverkiKoda_9018 => '코드 확인 오류';
  @override
  String get neobhodimoRazreshenieNaDostupK_5f5c => '사진에 접근하려면 권한이 필요합니다';
  @override
  String get oVyboreEmail_2609 => '이메일 선택 정보';
  @override
  String get podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0 =>
      '다음을 제외한 모든 이메일 도메인이 지원됩니다.';
  @override
  String get zapreschennyh_1f49 => '금지된';
  @override
  String get sozdatAkkaunt_19ed => '계정 만들기';
  @override
  String get naprimerIvan_d7cb => '예를 들어 이반';
  @override
  String get zadayteParol_53d2 => '비밀번호를 설정하세요';
  @override
  String get minimum8Simvolov_4ccd => '최소 8자';
  @override
  String get unikalnoeImyaDlyaVashegoProfilya_a0ea => '프로필의 고유한 이름';
  @override
  String get vashEmail_879d => '귀하의 이메일';
  @override
  String get dlyaSvyaziIVosstanovleniyaDostupa_c770 => '통신 및 접속 복구를 위해';
  @override
  String get emailAdres_9130 => '이메일 주소';
  @override
  String get vvediteParolEscheRaz_7383 => '비밀번호를 다시 입력하세요.';
  @override
  String get parolEscheRaz_6daf => '비밀번호를 다시 입력하세요';
  @override
  String get paroliNeSovpadayut_d82f => '비밀번호가 일치하지 않습니다.';
  @override
  String get ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed => '실제 생년월일을 알려주세요';
  @override
  String get ddmmgggg_3524 => 'DD.MM.YYYY';
  @override
  String get sdelayteProfilUznavaemym_f2c5 => '프로필을 알아볼 수 있게 만드세요';
  @override
  String get profilGotov_b57d => '프로필 준비됨';
  @override
  String get ostalosVsegoParaShagov_37e3 => '이제 몇 걸음밖에 안 남았어';
  @override
  String get yaPrinimayuPolzovatelskoeSoglashenie_c431 => '사용자 계약에 동의합니다.';
  @override
  String get yaDayuSoglasieNaObrabotku_0d03 => '개인정보 처리에 동의합니다.';
  @override
  String get sVozvrascheniem_77ee => '돌아온 것을 환영합니다';
  @override
  String get zagruzka_43e4 => '로드 중...';
  @override
  String get vyberiteAkkauntDlyaVhoda_d3a6 => '로그인할 계정을 선택하세요';
  @override
  String get vvediteVashNikneym_51a6 => '닉네임을 입력하세요';
  @override
  String get voytiVDrugoyAkkaunt_d10f => '다른 계정으로 로그인';
  @override
  String get nedavnieAkkaunty_953d => '최근 계정';
  @override
  String get dobroPozhalovatVXaneo_66d0 => 'Xaneo에 오신 것을 환영합니다';
  @override
  String get xaneoTeperIVMobilnom_e918 =>
      '이제 Xaneo를 모바일 앱에서 사용할 수 있습니다! 이 메신저가 이렇게 편리하고 빠른 적은 없었습니다.';
  @override
  String get mneUzheInteresno_5365 => '나는 이미 관심이 있습니다';
  @override
  String get vseVashiDannyePodZaschitoy_b7d9 => '귀하의 모든 데이터는 보호됩니다';
  @override
  String get vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e =>
      '모든 메시지는 종단 간 암호화로 보호됩니다. 어떤 단계에서도 Xaneo는 그 내용을 알지 못합니다.';
  @override
  String get prodolzhit_e9c3 => '계속';
  @override
  String get lokalnyeDataTsentry_f089 => '로컬 데이터 센터';
  @override
  String get vashiDannyeNikogdaNePokidayut_f871 =>
      '귀하의 데이터는 절대로 국가 밖으로 유출되지 않으며 안전한 데이터 센터에 저장됩니다.';
  @override
  String get kodOtpravlenPovtorno_e109 => '코드 재전송';
  @override
  String get dvuhfaktornayanautentifikatsiya_bacc => '2요소\n인증';
  @override
  String get naVashEmailOtpravlen6_b457 => '6자리 코드가 이메일로 전송되었습니다';
  @override
  String get podtverdit_e260 => '확인';
  @override
  String get nePoluchiliKodOtpravitPovtorno_c1d2 => '코드를 받지 못하셨나요? 재전송';
  @override
  String get imyaNikneymOSebe_7a8d => '이름, 별명, 자기 소개';
  @override
  String get zvonkiSoobscheniyaVidimostProfilya_f905 => '통화, 메시지, 프로필 공개';
  @override
  String get parolSessii2fa_de9e => '비밀번호, 세션, 2FA';
  @override
  String get prilozhenie_38aa => '부록';
  @override
  String get temaRazmerTekstaAnimatsii_f0a8 => '테마, 텍스트 크기, 애니메이션';
  @override
  String get pushUvedomleniyaZvuki_9cc2 => '푸시 알림, 소리';
  @override
  String get oPrilozhenii_77b2 => '응용 프로그램 정보';

  @override
  String get redaktirovatProfil_56ad => '프로필 수정';
  @override
  String get dobavitKontakt_2903 => '연락처 추가';
  @override
  String get nikneymPolzovatelyaUsername_a6ff => '사용자 닉네임(@username)';
  @override
  String get otobrazhaemoeImyaNeobyazatelno_340a => '표시 이름(선택사항)';
  @override
  String get neUdalosNaytiIliDobavit_649f => '사용자를 찾거나 추가할 수 없습니다.';
  @override
  String get ya_feef => '나';
  @override
  String get poiskKontaktov_9a71 => '연락처 검색...';
  @override
  String get spisokKontaktovPust_58c6 => '연락처 목록이 비어 있습니다.';
  @override
  String get kontaktyNeNaydeny_1b08 => '연락처를 찾을 수 없습니다';
  @override
  String get messages => '메시지';
  @override
  String get messageAnimations => '메시지 애니메이션';
  @override
  String get messageAnimationsDesc => '전송 및 수신 시 애니메이션 표시';
  @override
  String get archivedChats => '보관된 대화';
  @override
  String get archiveManagement => '보관함 관리';
  @override
  String get clearHistory => '대화 기록 삭제';
  @override
  String get clearHistoryDesc => '로컬에 저장된 모든 메시지 삭제';
  @override
  String get call => '음성 통화';
  @override
  String get sendMessage => '메시지 보내기';
  @override
  String get deleteContact => '연락처 삭제';
  @override
  String get activeSessions => '활성 세션';
  @override
  String get thisDevice => '현재 기기';
  @override
  String get xaneoPcActiveNow => 'Xaneo PC • 현재 활동 중';
  @override
  String get activeNow => '활동 중';
  @override
  String get twoFactorAuth => '2단계 인증';
  @override
  String get twoFactorAuthDesc => '일회용 비밀번호로 계정 보호';
  @override
  String get dangerZone => '위험 구역';
  @override
  String get deleteAccount => '계정 탈퇴';
  @override
  String get irreversibleAction => '돌이킬 수 없는 작업';
  @override
  String get theme => '테마';
  @override
  String get darkThemeDesc => '다크 모드와 라이트 모드 전환';
  @override
  String get fontSizeText => '글꼴 크기';
  @override
  String get showPopups => '팝업 알림 표시';
  @override
  String get sound => '알림 소리';
  @override
  String get soundDesc => '새 메시지 도착 시 소리 재생';
  @override
  String get mainSettings => '기본 설정';
  @override
  String get energySavingMode => '절전 모드';
  @override
  String get energySavingModeDesc => '배터리 절약을 위해 성능 최적화';
  @override
  String get autoSleep => '자동 절전 모드';
  @override
  String get autoSleepDesc => '비활동 시 앱을 절전 모드로 전환';
  @override
  String get animations => '애니메이션';
  @override
  String get reducedMotion => '동작 줄이기';
  @override
  String get reducedMotionDesc => '인터페이스 애니메이션 효과 줄이기';
  @override
  String get comingSoon => '출시 예정';
  @override
  String get darkTheme => '다크 테마';
  @override
  String get version => '버전';

  @override
  String get updateAvailable => '업데이트 가능';
  @override
  String get clickToViewChanges => '변경 사항 확인하기';
  @override
  String get newVersionAvailable => '새 버전의 앱을 이용할 수 있습니다';
  @override
  String get newVersionAvailableTitle => '새 버전 이용 가능';
  @override
  String get youHaveLatestVersion => '최신 버전이 설치되어 있습니다';
  @override
  String get whatsNew => '새로운 기능';
  @override
  String get officialReleaseNotes => '공식 릴리스 노트는 GitHub에서 확인 가능합니다';
  @override
  String get preparingDownload => '다운로드 준비 중...';
  @override
  String get installationStarted => '다운로드가 시작되었습니다...';
  @override
  String get whoSeesAvatar => '내 아바타를 볼 수 있는 사람';
  @override
  String get whoSeesBirthday => '내 생일을 볼 수 있는 사람';
  @override
  String get whoSeesOnlineTime => '내 활동 시간을 볼 수 있는 사람';

  @override
  String get downloadVersion => '다운로드';
  @override
  String get downloadSource => '다운로드 출처';
  @override
  String get directInAppInstall => '앱 내 직접 설치';
  @override
  String get autoDownloadAndRun => '자동 다운로드 및 실행';
  @override
  String get githubReleasePage => 'GitHub 릴리스 페이지';
  @override
  String get skip => '건너뛰기';
  @override
  String get updateAction => '업데이트';
  @override
  String get installAction => '설치 중...';
  @override
  String get isTyping => '입력 중...';
  @override
  String get isRecordingVoice => '음성 녹음 중...';
  @override
  String get areTyping => '입력 중...';

  @override
  String membersCount(int count) => '$count명의 멤버';
  @override
  String subscribersCount(int count) => '$count명의 구독자';

  @override
  String get group => '그룹';
  @override
  String get channel => '채널';

  @override
  String get profile => '프로필';
  @override
  String get userHidInfo => '사용자가 정보를 숨겼습니다';
  @override
  String get leaveGroup => '그룹 나가기';
  @override
  String get joinGroup => '그룹 참여';
  @override
  String get unsubscribeChannel => '구독 취소';
  @override
  String get subscribeChannel => '채널 구독';
  @override
  String get deleteChat => '채팅 삭제';
  @override
  String get pinChat => '고정';
  @override
  String get unpinChat => '고정 해제';
  @override
  String get muteNotifications => '알림 끄기';
  @override
  String get unmuteNotifications => '알림 켜기';
  @override
  String get backToChats => '채팅 목록으로 돌아가기';
  @override
  String get globalSearch => '전체 검색';
  @override
  String get chatSettings => '채팅 설정';
  @override
  String get emoji => '이모티콘';
  @override
  String get attachFile => '파일 첨부';
  @override
  String get startCall => '통화 시작';
  @override
  String get audioCall => '음성 통화';
  @override
  String get audioCallDesc => '음성으로 통화 연결';
  @override
  String get videoCall => '영상 통화';

  @override
  String get copied => '복사됨';

  @override
  String get copy => '복사';

  @override
  String get voiceRecordTitle => '음성 녹음';
  @override
  String get videoRecordTitle => '영상 녹화';
  @override
  String get holdToRecordHint => '길게 누르면 녹음\n탭하여 모드 변경';
  @override
  String get addAttachment => '첨부 파일 추가';
  @override
  String get emojiPanelInDev => '이모티콘 패널 개발 중';
  @override
  String get recordingVoice => '음성 녹음 중...';
  @override
  String get recordingVideo => '영상 녹화 중...';
  @override
  String get releaseToSend => '손을 떼면 전송';
  @override
  String get videoCallDesc => '카메라를 켜고 통화 연결';

  @override
  String get typeMessage => '메시지 작성...';
  @override
  String get file => '파일';
  @override
  String get todoList => '할 일 목록';
  @override
  String get poll => '투표';

  @override
  String get today => '오늘';
  @override
  String get yesterday => '어제';
  @override
  String get monthJan => '1월';
  @override
  String get monthFeb => '2월';
  @override
  String get monthMar => '3월';
  @override
  String get monthApr => '4월';
  @override
  String get monthMay => '5월';
  @override
  String get monthJun => '6월';
  @override
  String get monthJul => '7월';
  @override
  String get monthAug => '8월';
  @override
  String get monthSep => '9월';
  @override
  String get monthOct => '10월';
  @override
  String get monthNov => '11월';
  @override
  String get monthDec => '12월';
  @override
  String get createTodo => '할 일 생성';
  @override
  String get listName => '목록 이름';
  @override
  String get todoItems => '항목';
  @override
  String get addTodoItem => '+ 항목 추가';
  @override
  String get itemHintPrefix => '항목';
  @override
  String get createPoll => '투표 생성';
  @override
  String get pollQuestion => '질문';
  @override
  String get pollOptions => '옵션';
  @override
  String get addPollOption => '+ 옵션 추가';
  @override
  String get optionHintPrefix => '옵션';
  @override
  String get allowMultipleAnswers => '다중 선택 허용';
  @override
  String get accountsTitle => '계정';
  @override
  String get addAccount => '계정 추가';
  @override
  String get accountLimitNotice => '계정 한도: 5개';

  @override
  String get singleChoice => '단일 선택';

  @override
  String get media => '미디어';
  @override
  String get files => '파일';
  @override
  String get voice => '음성';
  @override
  String get links => '링크';

  @override
  String get bio => '자기소개';
  @override
  String get username => '사용자 이름';
  @override
  String get birthday => '생일';
  @override
  String get noSharedMedia => '공유된 미디어 없음';
  @override
  String get noSharedFiles => '공유된 파일 없음';
  @override
  String get noSharedVoice => '음성 메시지 없음';
  @override
  String get noSharedLinks => '공유된 링크 없음';

  @override
  String get savedMessagesDesc => '메모, 파일 및 메시지를 위한 개인 클라우드 저장소';
  @override
  String get music => '음악';
  @override
  String get noSharedMusic => '음악 없음';
  @override
  String get secureDesktopCommunicator => '보안 데스크톱 커뮤니케이터';
  @override
  String get noMessagesTitle => '메시지가 없습니다';
  @override
  String get noMessagesSubtitle => 'Xaneo Connect에서 메시지를 보내 대화를 시작해보세요!';

  @override
  String get qrScanTitle => '장치 인증';
  @override
  String get qrScanSubtitle =>
      'Xaneo 웹 또는 PC 클라이언트 화면의 QR 코드를 카메라로 비춰주세요';
  @override
  String get qrScanSuccessTitle => '장치 인증됨';
  @override
  String get qrScanSuccessDesc =>
      '인증이 완료되었습니다. 종단간 암호화(E2EE) 키가 새 장치로 전송되었습니다.';
  @override
  String get qrScanInputHint => '토큰 또는 페이로드 붙여넣기...';
  @override
  String get qrScanPasteTooltip => '클립보드에서 붙여넣기';
  @override
  String get qrScanConfirmButton => '인증 확인';
  @override
  String get qrScanProcessing => '장치 인증 중...';
}
