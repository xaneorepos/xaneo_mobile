import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Xaneo PC';

  @override
  String get welcomeTitle => 'Xaneoへようこそ';

  @override
  String get welcomeDescription => 'XaneoがPCに登場！最高のパフォーマンスと快適さをお届けします。';

  @override
  String get getStartedButton => '始める';

  @override
  String get privacyTitle => 'すべてのデータは安全です';

  @override
  String get privacyDescription => 'Xaneoのすべてのメッセージはエンドツーエンド暗号化で保護されています。';

  @override
  String get continueButton => '次へ';

  @override
  String get dataStorageTitle => 'Xaneoのすべてのデータセンターはロシアに位置しています';

  @override
  String get dataStorageDescription => 'お客様のデータは国外に出ることなく、安全なデータセンターに保管されます。';

  @override
  String get finishButton => '完了';

  @override
  String get setupCompleted => '設定が完了しました！';

  @override
  String get loginFormTitle => 'ログイン';

  @override
  String get loginFieldHint => 'ユーザー名';

  @override
  String get passwordFieldHint => 'パスワード';

  @override
  String get loginButton => 'ログイン';

  @override
  String get noAccount => 'アカウントをお持ちでないですか？';

  @override
  String get registerButton => '新規登録';

  @override
  String get fillAllFields => 'すべての項目を入力してください';

  @override
  String get loggingIn => 'ログイン中...';

  @override
  String welcomeUser(String username) => 'ようこそ、$username さん！';

  @override
  String get invalidCredentials => 'ユーザー名またはパスワードが正しくありません。';

  @override
  String get serverError => 'サーバーエラーが発生しました。後ほど再試行してください。';

  @override
  String get connectionError => '通信エラー。インターネット接続を確認してください。';

  @override
  String get settings => '設定';

  @override
  String get notifications => '通知';

  @override
  String get notificationsDescription => '通知のオン/オフ';

  @override
  String get darkThemeDescription => 'ダークテーマの切り替え';

  @override
  String fontSize(int size) => 'フォントサイズ: $size';

  @override
  String get language => '言語';

  @override
  String get languageDescription => '表示言語を選択';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get appVersion => 'アプリバージョン';

  @override
  String get registerTitle => 'アカウント登録';

  @override
  String get registerStep0Title => 'お名前は何ですか？';

  @override
  String get registerStep0Subtitle => '本名を入力してください';

  @override
  String get registerStep1Title => '生年月日はいつですか？';

  @override
  String get registerStep1Subtitle => '14歳以上である必要があります';

  @override
  String get registerStep2Title => 'ニックネームを決める';

  @override
  String get registerStep2Subtitle => '一意のニックネームが必要です';

  @override
  String get registerStep3Title => 'メールアドレス';

  @override
  String get registerStep3Subtitle => '確認コードを送信します';

  @override
  String get registerStep4Title => 'パスワードを作成';

  @override
  String get registerStep4Subtitle => '安全なパスワードを設定してください';

  @override
  String get registerStep5Title => 'プロフィール画像を追加';

  @override
  String get registerStep5Subtitle => 'スキップすることも可能です';

  @override
  String get registerStep6Title => '最後のステップ';

  @override
  String get registerStep6Subtitle => '利用規約に同意してください';

  @override
  String get yourName => 'お名前';

  @override
  String get birthDate => '生年月日';

  @override
  String get nickname => 'ニックネーム';

  @override
  String get checkingNickname => '利用可能性を確認中...';

  @override
  String get nicknameAvailable => 'このニックネームは利用可能です';

  @override
  String get nicknameTaken => 'すでに使用されています';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get confirmPassword => 'パスワード（確認）';

  @override
  String get addPhoto => 'タップして写真を追加';

  @override
  String get removePhoto => '写真を削除';

  @override
  String get acceptTerms => '利用規約に同意する';

  @override
  String get acceptDataProcessing => '個人情報の取り扱いに同意する';

  @override
  String get back => '戻る';

  @override
  String get next => '次へ';

  @override
  String get finish => '完了';

  @override
  String get backToLogin => 'ログインへ戻る';

  @override
  String get registrationSuccess => '登録が完了しました！';

  @override
  String get registrationError => '登録エラー';

  @override
  String get enterVerificationCode => '確認コードを入力';

  @override
  String get invalidVerificationCode => '確認コードが正しくありません';

  @override
  String get codeSent => 'メールに確認コードを送信しました';

  @override
  String get sendCodeError => 'コード送信エラー';

  @override
  String get confirmEmail => 'メールアドレスの確認';

  @override
  String codeSentToEmail(String email) => '以下のメールアドレスに確認コードを送信しました\n$email';

  @override
  String get verify => '確認';

  @override
  String get resendCode => 'コードを再送';

  @override
  String resendIn(int count) => '$count秒後に再送可能';

  @override
  String get acceptTermsRequired => '利用規約およびプライバシーポリシーへの同意が必要です';

  @override
  String get about => 'アプリについて';

  @override
  String get aboutDescription => 'モダンなシステム管理・コミュニケーションアプリ。';

  @override
  String get close => '閉じる';

  @override
  String get technicalInfo => '技術情報';

  @override
  String get platform => 'プラットフォーム';

  @override
  String get architecture => 'CPUアーキテクチャ';

  @override
  String get flutter => 'Flutter';

  @override
  String get viewOnGitHub => 'GitHubで見る';

  @override
  String get chats => 'チャット';
  @override
  String get search => '検索';
  @override
  String get searchPlaceholder => 'メッセージやチャットを検索...';
  @override
  String get savedMessages => '保存済みメッセージ';
  @override
  String get online => 'オンライン';
  @override
  String get offline => 'オフライン';
  @override
  String get lastSeenRecently => '最近イン';
  @override
  String get musicPlaylist => '再生リスト';
  @override
  String get reply => '返信';
  @override
  String get edit => '編集';
  @override
  String get pin => 'ピン留め';
  @override
  String get unpin => 'ピン留め解除';
  @override
  String get delete => '削除';
  @override
  String get forward => '転送';
  @override
  String get members => 'メンバー';
  @override
  String get noMessages => 'メッセージはまだありません';

  @override
  String get joinedChat => 'がチャットに参加しました';
  @override
  String get leftChat => 'がチャットを退出しました';
  @override
  String get subscribedChannel => 'がチャンネルに登録しました';
  @override
  String get unsubscribedChannel => 'がチャンネル登録を解除しました';
  @override
  String get invited => 'が招待しました';
  @override
  String get systemMessage => 'システムメッセージ';
  @override
  String get selectChatToStart => 'チャットを選択して会話を開始';
  @override
  String get toArchive => 'アーカイブ';
  @override
  String get unarchive => 'アーカイブ解除';
  @override
  String get archive => 'アーカイブ';
  @override
  String get archiveEmpty => 'アーカイブは空です';
  @override
  String get voiceMessage => 'ボイスメッセージ';
  @override
  String get videoMessage => 'ビデオメッセージ';

  @override
  String get personalData => '個人情報';
  @override
  String get personalDataDesc => '名前、ニックネーム、プロフィール写真';
  @override
  String get privacyDesc => 'メッセージや通話の権限設定';
  @override
  String get chatsSettings => 'チャット設定';
  @override
  String get chatsSettingsDesc => '通知、テーマ、履歴';
  @override
  String get contacts => '連絡先';
  @override
  String get contactsDesc => '保存された連絡先';
  @override
  String get security => 'セキュリティ';
  @override
  String get securityDesc => 'セッション、パスワード、認証';
  @override
  String get appearance => '外観';
  @override
  String get appearanceDesc => 'テーマ、フォント、スケール';
  @override
  String get energySaving => '省電力モード';
  @override
  String get energySavingDesc => 'アニメーションとパフォーマンス';

  @override
  String get account => 'アカウント';
  @override
  String get interface => 'インターフェース';
  @override
  String get logout => 'ログアウト';

  @override
  String get basicInfo => '基本情報';
  @override
  String get nicknameCannotBeChanged => 'ユーザー名はアプリ内で変更できません';
  @override
  String get aboutMe => '自己紹介';
  @override
  String get aboutMeHint => '自己紹介を入力...';
  @override
  String get save => '保存';
  @override
  String get saving => '保存中...';
  @override
  String get communications => '通信権限';
  @override
  String get whoCanMessage => 'メッセージを送信できる人';
  @override
  String get whoCanCall => '通話できる人';
  @override
  String get whoCanRecordVoice => 'ボイスメッセージを送信できる人';
  @override
  String get whoCanSendFiles => 'ファイルを送信できる人';
  @override
  String get whoCanInvite => 'グループに招待できる人';
  @override
  String get profileVisibility => 'プロフィール公開設定';
  @override
  String get whoSeesNickname => 'ユーザー名を表示できる人';
  @override
  String get everyone => '全員';
  @override
  String get contactsOnly => '連絡先のみ';
  @override
  String get nobody => 'だれも';
  @override
  String get addContact => '追加';
  @override
  String get addContactTitle => '連絡先を追加';
  @override
  String get userNicknameHint => 'ユーザーのユーザー名';
  @override
  String get displayNameOptional => '表示名（任意）';
  @override
  String get noContactsYet => '保存された連絡先はまだありません';
  @override
  String get appInfo => 'アプリ情報';
  @override
  String get checkUpdates => 'アップデートを確認';
  @override
  String get checkingUpdates => 'アップデートを確認中...';
  @override
  String get cancel => 'キャンセル';
  @override
  String get obnovlenie_7e32 => '更新';
  @override
  String get obnovleniePrilozheniya_b6c3 => 'アプリのアップデート';
  @override
  String get podgotovkaKZagruzke_a5c7 => 'ダウンロードの準備をしています...';
  @override
  String get ustanovkaZapuschena_d378 => 'インストールが始まりました！';
  @override
  String get dostupnaNovayaVersiyaPrilozheniya_eeae =>
      '新しいバージョンのアプリケーションが利用可能になりました';
  @override
  String get chtoNovogo_74e2 => '最新情報';
  @override
  String get ofitsialnoeOpisanieRelizaDostupnoNa_3ea3 =>
      '公式リリースの説明は GitHub ページでご覧いただけます。';
  @override
  String get istochnikZagruzki_0e6e => 'ソースをダウンロード';
  @override
  String get pryamayaUstanovkaVPrilozhenii_16f5 => 'アプリケーションへの直接インストール';
  @override
  String get avtomaticheskoeSkachivanieIZapusk_9a3f => '自動ダウンロードと起動';
  @override
  String get stranitsaRelizaNaGithub_1531 => 'GitHub のリリースページ';
  @override
  String get propustit_03ee => 'スキップ';
  @override
  String get ustanovka_516d => 'インストール...';
  @override
  String get obnovit_dbe5 => 'アップデート';
  @override
  String get lichnyeDannye_be85 => '個人情報';
  @override
  String get imyaNikneymFotoProfilya_28ac => '名前、ニックネーム、プロフィール写真';
  @override
  String get privatnost_0899 => 'プライバシー';
  @override
  String get ktoMozhetPisatZvonitVidet_1789 => '書き込み、電話、プロフィールの閲覧ができる人';
  @override
  String get nastroykiChatov_7ca8 => 'チャット設定';
  @override
  String get uvedomleniyaTemyIstoriya_51da => 'お知らせ、トピックス、履歴';
  @override
  String get kontakty_7576 => '連絡先';
  @override
  String get vashiSohranennyeKontakty_a641 => '保存した連絡先';
  @override
  String get bezopasnost_3677 => 'セキュリティ';
  @override
  String get sessiiParolAutentifikatsiya_73f5 => 'セッション、パスワード、認証';
  @override
  String get vneshniyVid_6873 => '外観';
  @override
  String get temaShriftMasshtab_d8c9 => 'テーマ、フォント、スケール';
  @override
  String get yazyk_0577 => '言語';
  @override
  String get yazykInterfeysaKlienta_2ad3 => 'クライアントインターフェース言語';
  @override
  String get uvedomleniya_d2ed => '通知';
  @override
  String get zvukiBannery_1b60 => 'サウンド、バナー';
  @override
  String get energosberezhenie_0b19 => '省エネ';
  @override
  String get animatsiiIProizvoditelnost_fba8 => 'アニメーションとパフォーマンス';
  @override
  String get oPrilozhenii_322e => 'アプリケーションについて';
  @override
  String get versiyaProverkaObnovleniySsylki_6efc => 'バージョン、アップデートの確認、リンク';
  @override
  String get nastroyki_b01b => '設定';
  @override
  String get nastroyki_c919 => '設定';
  @override
  String get proverkaObnovleniy_f3e0 => 'アップデートをチェックしています...';
  @override
  String get neUdalosZagruzitNastroyki_f753 => '設定の読み込みに失敗しました';
  @override
  String get oshibkaSohraneniya_0387 => '保存エラー';
  @override
  String get dannyeSohraneny_fd62 => '保存されたデータ';
  @override
  String get gost_9618 => 'ゲスト';
  @override
  String get akkaunt_38ac => 'アカウント';
  @override
  String get interfeys_49be => 'インターフェース';
  @override
  String get vyytiIzAkkaunta_6d41 => 'アカウントからログアウトします';
  @override
  String get informatsiyaOPrilozhenii_00c4 => '申請情報';

  @override
  String get proverka_13bc => '確認中...';
  @override
  String get proveritObnovleniya_ab45 => 'アップデートをチェックする';
  @override
  String get osnovnayaInformatsiya_6fec => '基本情報';
  @override
  String get imya_d38d => '名前';
  @override
  String get vvediteVasheImya_751e => 'あなたの名前を入力してください';
  @override
  @override
  String get nikneym_3fea => 'ユーザー名';
  @override
  String get nikneymNelzyaIzmenitVPrilozhenii_75d0 => 'ニックネームはアプリ内で変更できません';
  @override
  String get oSebe_0b3b => '私について';
  @override
  String get rasskazhiteOSebe_1c37 => 'あなた自身について教えてください...';
  @override
  String get sohranenie_c15f => '保存中...';
  @override
  String get sohranit_74ea => '保存';
  @override
  @override
  String get vse_984b => 'すべて';
  @override
  String get tolkoKontakty_a559 => '連絡先のみ';
  @override
  String get nikto_ba19 => '誰も';
  @override
  String get kommunikatsii_1242 => 'コミュニケーション';
  @override
  String get ktoMozhetPisatSoobscheniya_4645 => 'メッセージを書き込める人';
  @override
  String get ktoMozhetZvonit_c427 => '電話できる人';
  @override
  String get ktoMozhetZapisyvatGolosovye_c69a => '音声を録音できる人';
  @override
  String get ktoMozhetOtpravlyatFayly_2e40 => 'ファイルを送信できる人';
  @override
  String get ktoMozhetPriglashatVGruppy_cdc0 => 'グループに招待できる人';
  @override
  String get vidimostProfilya_34bf => 'プロフィールの可視性';
  @override
  String get ktoViditMoyNikneym_54b8 => '私のニックネームを誰が見るのか';
  @override
  String get ktoViditMoyAvatar_e9f6 => '私のアバターを見るのは誰ですか';
  @override
  String get ktoViditMoyDenRozhdeniya_ccc7 => '私の誕生日を誰が見ますか';
  @override
  String get ktoViditVremyaMoeyAktivnosti_4349 => '私の活動時間を誰が見るのか';
  @override
  String get neUdalosZagruzitKontakty_02a3 => '連絡先のロードに失敗しました';
  @override
  String get dobavitKontakt_4278 => '連絡先を追加する';
  @override
  String get nikneymPolzovatelya_5610 => 'ユーザーのニックネーム';
  @override
  String get otobrazhaemoeImyaOptsionalno_bbd1 => '表示名 (オプション)';
  @override
  @override
  String get otmena_987b => 'キャンセル';
  @override
  String get dobavit_5eba => '追加';
  @override
  String get uVasPokaNetSohranennyh_b64b => '保存された連絡先がまだありません';
  @override
  String get pozvonit_ccfa => '電話をかける';
  @override
  String get napisat_0144 => '書く';
  @override
  String get udalitKontakt_065d => '連絡先を削除する';
  @override
  String get soobscheniya_7e26 => 'メッセージ';
  @override
  String get animatsiiSoobscheniy_bc8b => 'メッセージアニメーション';
  @override
  String get pokazyvatAnimatsiiPriOtpravkeI_d663 => '送受信時にアニメーションを表示する';
  @override
  String get arhivirovannyeChaty_d990 => 'アーカイブされたチャット';
  @override
  String get upravlenieArhivom_e843 => 'アーカイブ管理';
  @override
  String get ochistitIstoriyu_837a => '履歴をクリアする';
  @override
  String get udalitVseSoobscheniyaLokalno_fbbd => 'すべてのメッセージをローカルで削除する';
  @override
  String get aktivnyeSessii_5c96 => 'アクティブなセッション';
  @override
  String get etoUstroystvo_26f6 => 'このデバイス';
  @override
  String get xaneoPcAktivnoSeychas_25b4 => 'Xaneo PC • 現在アクティブです';
  @override
  String get aktivno_87a4 => 'アクティブ';
  @override
  String get dvoynayaAutentifikatsiya_66ae => '二重認証';
  @override
  String get zaschitaAkkauntaOdnorazovymParolem_e9f1 => 'ワンタイムパスワードによるアカウント保護';
  @override
  String get opasnayaZona_25bc => '危険地帯';
  @override
  String get udalitAkkaunt_05c7 => 'アカウントを削除する';
  @override
  String get neobratimoeDeystvie_7232 => '不可逆的なアクション';
  @override
  String get tema_9e26 => '件名';
  @override
  String get temnayaTema_cb48 => 'ダークテーマ';
  @override
  String get pereklyuchitMezhduTemnymISvetlym_5415 => 'ダークモードとライトモードを切り替えます';
  @override
  String get razmerShrifta_1155 => 'フォントサイズ';
  @override
  String get a_87a0 => 'あ';
  @override
  String get pokazyvatVsplyvayuschieUvedomleniya_754e => 'ポップアップ通知を表示する';
  @override
  String get zvuk_9329 => 'サウンド';
  @override
  String get vosproizvoditZvukPriNovomSoobschenii_47cc => '新しいメッセージでサウンドを再生する';
  @override
  String get osnovnyeNastroyki_231c => '基本設定';
  @override
  String get rezhimEkonomiiEnergii_edfc => '省電力モード';
  @override
  String get optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb =>
      'アプリケーションのパフォーマンスを最適化してリソースを節約します';
  @override
  String get avtomaticheskiySpyaschiyRezhim_5955 => 'オートスリープモード';
  @override
  String get perevoditPrilozhenieVSpyaschiyRezhim_1c07 =>
      '非アクティブなときにアプリケーションをスリープモードにします';
  @override
  String get animatsii_05c7 => 'アニメーション';
  @override
  String get uproschennyeAnimatsii_3a13 => '簡略化されたアニメーション';
  @override
  String get umenshaetKolichestvoAnimatsiyInterfeysa_6bf1 =>
      'インターフェースアニメーションの数を削減します。';
  @override
  String get skoroBudetDostupno_de07 => '近日公開予定';
  @override
  String get gostevoyRezhim_6d82 => 'ゲストモード';
  @override
  String get voyditeDlyaDostupaKAkkauntu_a5c8 => 'ログインしてアカウントにアクセスします';
  @override
  String get nazhmiteDlyaProsmotraIzmeneniy_0255 => 'クリックして変更を表示';
  @override
  String get vvediteKodPodtverzhdeniya_61af => '確認コードを入力してください';
  @override
  @override
  String get nevernyyKodPodtverzhdeniya_7762 => '無効な認証コードです';
  @override
  String get podtverditeEMail_4bd4 => 'メールを確認してください';
  @override
  String get proverit_340b => 'チェックする';
  @override
  @override
  String get otpravitKodPovtorno_7703 => 'コードを再送信';
  @override
  String get sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e =>
      '最新のデスクトップ アプリケーション\n美しいインターフェイスと 3D 効果を備えた';
  @override
  String get tehnologii_6332 => 'テクノロジー';
  @override
  String get vyNashliPashalku_1a57 => '🎉 イースターエッグを見つけました! 🎉';
  @override
  String get spasiboZaIspolzovanieXaneo_d079 => 'いつもxaneoをご利用いただきありがとうございます！';
  @override
  String get globalnyyPoisk_77bf => 'グローバル検索';
  @override
  @override
  String get poiskKontaktovChatovKanalovBotov_db66 =>
      '連絡先、チャット、チャンネル、ボットを検索...';
  @override
  @override
  String get lyudi_c7ae => 'ユーザー';
  @override
  @override
  String get gruppy_ebc4 => 'グループ';
  @override
  @override
  String get kanaly_0c11 => 'チャンネル';
  @override
  @override
  String get boty_d6e4 => 'ボット';
  @override
  @override
  String get izbrannoe_2fc4 => '保存用メッセージ';
  @override
  @override
  String get vvediteZaprosDlyaPoiskaPo_9955 => '検索キーワードを入力してXaneoネットワークを検索';
  @override
  @override
  String get nichegoNeNaydeno_8767 => '見つかりませんでした';
  @override
  @override
  String get izbrannoe_b637 => '保存用メッセージ';
  @override
  @override
  String get boty_800d => 'ボット';
  @override
  @override
  String get kanaly_ccec => 'チャンネル';
  @override
  @override
  String get gruppy_cfd6 => 'グループ';
  @override
  @override
  String get polzovateli_e0ec => 'ユーザー';
  @override
  @override
  String get sohranennyeSoobscheniya_6b62 => '保存用メッセージ';
  @override
  @override
  String get bot_0ae1 => 'ボット';
  @override
  @override
  String get bot_0f46 => 'bot';
  @override
  @override
  String get gruppa_99d9 => 'グループ';
  @override
  @override
  String get kanal_2710 => 'チャンネル';
  @override
  String get versiya_3725 => 'バージョン';
  @override
  String get tehnicheskayaInformatsiya_ba0f => '技術情報';
  @override
  String get platforma_8848 => 'プラットフォーム';
  @override
  String get arhitekturaProtsessora_c079 => 'プロセッサアーキテクチャ';
  @override
  String get posmotretNaGithub_5238 => 'GitHub で見る';
  @override
  String get zakryt_dd94 => '閉じる';
  @override
  String get vklyuchitTemnuyuTemu_ed17 => 'ダークテーマを有効にする';
  @override
  String get vklyuchitUvedomleniya_d311 => '通知を有効にする';
  @override
  String get kastomnyyOverleyXaneo_7d39 => 'カスタム Xaneo オーバーレイ';
  @override
  String get animirovannyeUvedomleniyaSBystrymOtvetom_a25d => 'アニメーション通知と素早い応答';
  @override
  String get aaBbVv_1c6b => 'ああ、bb、bb';
  @override
  String get pleylist_a04c => 'プレイリスト';
  @override
  String get spisokMuzyki_d477 => '音楽リスト';
  @override
  String get loc_0B_5a4d => '0B';
  @override
  String get b_3b67 => 'B';
  @override
  String get kb_419d => 'KB';
  @override
  String get mb_b808 => 'MB';
  @override
  String get gb_e572 => 'GB';
  @override
  String get audiozapis_867d => '音声録音';
  @override
  String get muzykalnyyTrek_b15d => '音楽トラック';
  @override
  String get muzykalnyeTrekiOtsutstvuyut_3301 => '音楽トラックがありません';
  @override
  @override
  String get nikneymUzheZanyat_59aa => 'ユーザー名は既に使用されています';
  @override
  @override
  String get oshibkaProverki_2ab0 => '確認エラー';
  @override
  @override
  String get emailUzheZanyat_17e1 => 'メールアドレスは既に登録されています';
  @override
  @override
  String get oshibkaOtpravkiKoda_a42a => '認証コードの送信エラー';
  @override
  @override
  String get neobhodimoPrinyatUsloviyaISoglasie_e31e =>
      '利用規約とプライバシーポリシーに同意する必要があります';
  @override
  @override
  String get registratsiyaUspeshna_9d5c => '登録が完了しました！';
  @override
  @override
  String get oshibkaRegistratsii_b9f2 => '登録エラー';
  @override
  @override
  String get nazad_2b0b => '戻る';
  @override
  @override
  String get kakVasZovut_68b7 => 'お名前は何ですか？';
  @override
  @override
  String get kogdaVyRodilis_26f2 => '生年月日はいつですか？';
  @override
  @override
  String get pridumayteNikneym_221b => 'ユーザー名を作成';
  @override
  @override
  String get vashEmail_8bbd => 'メールアドレス';
  @override
  @override
  String get podtverzhdenieEmail_281f => 'メール認証';
  @override
  @override
  String get sozdayteParol_5f4c => 'パスワードを作成';
  @override
  @override
  String get podtverzhdenieParolya_ebc2 => 'パスワードの確認';
  @override
  @override
  String get dobavteFoto_25eb => '写真を追加';
  @override
  @override
  String get posledniyShag_e0c5 => '最後のステップ';
  @override
  @override
  String get vvediteVasheNastoyascheeImya_e656 => '本名を入力してください';
  @override
  @override
  String get vamDolzhnoBytNeMenee_1111 => '13歳以上である必要があります';
  @override
  @override
  String get nikneymDolzhenBytUnikalnym_952d => 'ユーザー名は一意である必要があります';
  @override
  @override
  String get myOtpravimKodPodtverzhdeniya_fc71 => 'メールアドレスに認証コードを送信します';
  @override
  @override
  String get vvedite6ZnachnyyKodIz_f22f => 'メールで届いた6桁のコードを入力';
  @override
  @override
  String get pridumayteNadezhnyyParol_2312 => '安全なパスワードを作成（8文字以上）';
  @override
  @override
  String get povtoriteParolEscheRaz_6723 => 'もう一度パスワードを入力';
  @override
  @override
  String get etoNeobyazatelnoNoPriyatno_b6a3 => '任意ですが、設定をおすすめします';
  @override
  @override
  String get proverteVashiDannyeIPrimite_3121 => '入力内容を確認し、利用規約に同意してください';
  @override
  @override
  String get registratsiya_0b93 => '新規登録';
  @override
  @override
  String get vasheImya_51eb => 'お名前';
  @override
  @override
  @override
  String get proverkaDostupnosti_da13 => '利用可能性を確認中...';
  @override
  @override
  @override
  String get nikneymDostupen_3fc9 => 'ユーザー名は利用可能です';
  @override
  @override
  @override
  String get nikneymZanyat_8a5f => 'ユーザー名は既に使用されています';
  @override
  @override
  @override
  String get emailDostupen_e903 => 'メールアドレスは利用可能です';
  @override
  @override
  @override
  String get emailZanyat_fb40 => 'メールアドレスは既に使用されています';
  @override
  @override
  String get kodPodtverzhdeniya_1c9d => '認証コード';
  @override
  @override
  String get parol_5ebe => 'パスワード';
  @override
  @override
  String get podtverditeParol_e3e3 => 'パスワードの確認';
  @override
  @override
  String get nazhmiteChtobyDobavitFoto_d6e8 => 'タップして写真を追加';
  @override
  @override
  String get udalitFoto_3426 => '写真を削除';
  @override
  @override
  String get yaPrinimayuUsloviyaIspolzovaniya_391a => '利用規約に同意します';
  @override
  @override
  String get yaSoglasenNaObrabotkuPersonalnyh_f2a8 => '個人情報の取り扱いに同意します';
  @override
  @override
  String get zavershit_b0e3 => '完了';
  @override
  @override
  String get dalee_c453 => '次へ';
  @override
  @override
  String get dataRozhdeniya_505e => '生年月日';
  @override
  String get vklyuchitTemnuyuTemuOformleniya_86c4 => 'ダークテーマを有効にする';
  @override
  @override
  String get yanvar_ee86 => '1月';
  @override
  @override
  String get fevral_28ff => '2月';
  @override
  @override
  String get mart_d766 => '3月';
  @override
  @override
  String get aprel_03e9 => '4月';
  @override
  @override
  String get may_2e53 => '5月';
  @override
  @override
  String get iyun_cfcb => '6月';
  @override
  @override
  String get iyul_89fb => '7月';
  @override
  @override
  String get avgust_de5a => '8月';
  @override
  @override
  String get sentyabr_ebfb => '9月';
  @override
  @override
  String get oktyabr_1720 => '10月';
  @override
  @override
  String get noyabr_66fb => '11月';
  @override
  @override
  String get dekabr_39b3 => '12月';
  @override
  @override
  String get pn_2c1e => '月';
  @override
  @override
  String get vt_7145 => '火';
  @override
  @override
  String get sr_c6e4 => '水';
  @override
  @override
  String get cht_a51f => '木';
  @override
  @override
  String get pt_0123 => '金';
  @override
  @override
  String get sb_3a4b => '土';
  @override
  @override
  String get vs_4ad9 => '日';
  @override
  @override
  String get gotovo_34e1 => '完了';
  @override
  String get oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b => 'キーリカバリエラー（上書き失敗）';
  @override
  String get kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7 =>
      '暗号化キーを再生成するときに重大なエラーが発生しました';
  @override
  String get oshibkaZagruzkiKlyucheyNaServer_ff9b => 'サーバーへのキーのロード中にエラーが発生しました';
  @override
  String get oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4 => '暗号化キーの取得エラー';
  @override
  String get prevyshenLimitV5Akkauntov_a6a9 =>
      'このクライアントのアカウント数の制限である 5 を超えているか、接続エラーが発生しています。';
  @override
  @override
  @override
  String get oshibkaAvtorizatsii_9f5c => '認証エラー';
  @override
  @override
  @override
  String get oshibkaPodklyucheniyaKServeru_8b96 => 'サーバー接続エラー';
  @override
  @override
  String get nazadKMessendzheru_de29 => 'メッセンジャーに戻る';
  @override
  @override
  String get voytiVAkkaunt_c439 => 'アカウントにログイン';
  @override
  @override
  String get vvediteParol_1370 => 'パスワードを入力';
  @override
  @override
  String get vvediteSvoiDannyeDlyaDostupa_319e =>
      'メッセージにアクセスするためにログイン情報を入力してください。';
  @override
  @override
  String get voyti_63a7 => 'ログイン';
  @override
  String get sobesednik_7025 => '対話者';
  @override
  String get vy_0101 => 'あなた';
  @override
  String get vyDelitesSvoimEkranom_16b1 => '画面を共有します';
  @override
  String get polzovatel_f154 => 'ユーザー';
  @override
  String get ishodyaschiyVyzov_650b => '発信中...';
  @override
  String get vhodyaschiyVyzov_19ff => '着信中...';
  @override
  String get podklyucheno_d022 => '接続済み';
  @override
  String get ozhidanieOtveta_a984 => '応答を待っています...';
  @override
  String get razgovorPoAudiosvyazi_3ed7 => '音声会話';
  @override
  String get translyatsiyaVashegoEkranaZapuschena_575a => 'スクリーンキャストが始まりました';
  @override
  String get sobesednikViditVseChtoProishodit_c759 =>
      '対話者はあなたのデスクトップ上で起こっていることをすべて見ています';
  @override
  String get vhodyaschiyVyzov_905e => '着信';
  @override
  String get neizvestnyy_be89 => '不明';
  @override
  String get videozvonok_dd18 => 'ビデオ通話...';
  @override
  String get golosovoyZvonok_5410 => '音声通話...';
  @override
  String get otklonit_8b0d => '拒否する';
  @override
  String get otvetit_e568 => '返信';
  @override
  String get gruppovoyZvonok_dac1 => 'グループ通話';
  @override
  String get podklyuchenieKZvonku_e2cf => '通話に接続しています...';
  @override
  String get podklyuchenieKVeschaniyu_038b => 'ブロードキャストに接続しています...';
  @override
  String get uchastnik_cffb => 'メンバー';
  @override
  String get vy_479c => 'あなた';
  @override
  String get svernut_ca9f => '崩壊する';
  @override
  String get vhodyaschiyVyzov_d2f3 => '着信';
  @override
  String get novoeSoobschenie_1d49 => '新しいメッセージ';
  @override
  String get vashOtvet_40c2 => 'あなたの答えは...';
  @override
  String get videovyzov_3353 => 'ビデオ通話...';
  @override
  String get audiovyzov_bbb5 => '音声通話...';
  @override
  String get nachatZvonok_3d26 => '通話を開始する';
  @override
  String get golosovoyZvonok_b615 => '音声通話';
  @override
  String get pozvonitPoGolosovoySvyazi_4069 => '音声電話をかける';
  @override
  String get videozvonok_8142 => 'ビデオ通話';
  @override
  String get pozvonitSVklyuchennoyKameroy_fb05 => 'カメラをオンにして通話する';
  @override
  String get zashifrovannoeSoobschenie_ca35 => '[暗号化されたメッセージ]';
  @override
  String get golosovoeSoobschenie_4a85 => '🎤 音声メッセージ';
  @override
  String get videosoobschenie_d687 => '🎬ビデオメッセージ';
  @override
  String get fayl_826d => '📎ファイル';
  @override
  String get zvonok_e8d5 => '📞 電話する';
  @override
  String get oshibkaDeshifrovaniya_4146 => '【復号化エラー】';
  @override
  String get zapisyvaetGolosovoe_2a5c => '音声を録音します...';
  @override
  String get pechataet_812c => 'プリント...';
  @override
  String get neUdalosArhivirovatChat_ab89 => 'チャットをアーカイブできませんでした';
  @override
  String get neUdalosRazarhivirovatChat_f0d7 => 'チャットのアーカイブを解除できませんでした';
  @override
  String get arhiv_56aa => 'アーカイブ';
  @override
  String get netUserid_634a => '[ユーザーIDなし]';
  @override
  String get netKlyucha_337b => '【鍵なし】';
  @override
  String get neizvestnyyTipChata_2617 => '[不明なチャット タイプ]';
  @override
  String get neUdalosPoluchitKlyuchShifrovaniya_b953 => 'チャット用の暗号化キーの取得に失敗しました';
  @override
  String get gruppa_19c2 => 'グループ';
  @override
  String get uchastnik_5bce => '参加者';
  @override
  String get uchastnika_92d9 => '参加者';
  @override
  String get uchastnikov_5d6b => '参加者';
  @override
  String get kanal_64ec => 'チャンネル';
  @override
  String get podpischik_695a => '加入者';
  @override
  String get podpischika_b490 => '加入者';
  @override
  String get podpischikov_ba39 => '購読者';
  @override
  String get segodnya_9626 => '今日';
  @override
  String get vchera_61d4 => '昨日';
  @override
  String get yanvarya_d861 => '1月';
  @override
  String get fevralya_fcf9 => '2月';
  @override
  String get marta_bb77 => '3月';
  @override
  String get aprelya_2b5a => '4月';
  @override
  String get maya_4dbb => '5月';
  @override
  String get iyunya_adcb => '6月';
  @override
  String get iyulya_3236 => '7月';
  @override
  String get avgusta_e3aa => '8月';
  @override
  String get sentyabrya_a146 => '9月';
  @override
  String get oktyabrya_7abd => '10月';
  @override
  String get noyabrya_6e78 => '11月';
  @override
  String get dekabrya_29cc => '12月';
  @override
  String get vyPodpisalisNaKanal_b2b3 => 'チャンネル登録しました';
  @override
  String get vyPrisoedinilisKGruppe_07bd => 'グループに参加しました';
  @override
  String get neUdalosPrisoedinitsya_31e6 => '参加できませんでした';
  @override
  String get vyOtpisalisOtKanala_7698 => 'チャンネル登録を解除しました';
  @override
  String get vyPokinuliGruppu_5a52 => 'あなたはグループを離れました';
  @override
  String get neUdalosVypolnitDeystvie_3cfd => 'アクションが失敗しました';
  @override
  String get neUdalosPereklyuchitAkkaunt_968b => 'アカウントの切り替えに失敗しました';
  @override
  String get media_c247 => 'メディア';
  @override
  String get fayly_200c => 'ファイル';
  @override
  String get golos_2d89 => '声';
  @override
  String get ssylki_9f58 => 'リンク';
  @override
  String get profil_c62a => 'プロフィール';
  @override
  String get imyaPolzovatelya_6fd4 => 'ユーザー名';
  @override
  String get denRozhdeniya_e41d => '誕生日';
  @override
  String get polzovatelSkrylInformatsiyuOSebe_f416 => 'ユーザーは自分自身に関する情報を隠しています';
  @override
  String get god_6270 => '年';
  @override
  String get goda_7443 => '年';
  @override
  String get let_257a => '年';
  @override
  String get skopirovano_f70b => 'コピーされました';
  @override
  String get akkaunty_80b5 => 'アカウント';
  @override
  String get dobavitAkkaunt_5253 => 'アカウントを追加';
  @override
  String get limit5Akkauntov_fdb7 => '制限: 5 アカウント';
  @override
  String get nazadKChatam_7edb => 'チャットに戻る';
  @override
  String get chaty_19ad => 'チャット';
  @override
  String get globalnyyPoisk_7ff2 => 'グローバル検索';
  @override
  String get arhivPust_3e22 => 'アーカイブは空です';
  @override
  String get netSoobscheniy_29d4 => 'メッセージはありません';
  @override
  String get toDoList_27e1 => '📋 ToDoシート';
  @override
  String get opros_6ff1 => '🗳️投票';
  @override
  String get fotografiya_5709 => '📷 写真';
  @override
  String get razarhivirovat_416b => '解凍する';
  @override
  String get vArhiv_ce22 => 'アーカイブへ';
  @override
  String get chat_c52b => 'チャット';
  @override
  String get vyberiteChatDlyaNachalaObscheniya_36a5 => 'チャットを選択してチャットを開始します';
  @override
  String get bot_2712 => 'ボット';
  @override
  String get vSeti_d902 => 'オンライン';
  @override
  String get neVSeti_ee01 => 'オフライン';
  @override
  String get nastroykiChata_1e0d => 'チャット設定';
  @override
  String get pokinutGruppu_e6ce => 'グループを離れる';
  @override
  String get prisoedinitsyaKGruppe_eb45 => 'グループに参加する';
  @override
  String get otpisatsyaOtKanala_fdbc => 'チャンネル登録を解除する';
  @override
  String get podpisatsyaNaKanal_2dad => 'チャンネル登録してください';
  @override
  String get netSoobscheniyNapishiteChtoNibud_2bf4 => 'メッセージはありません。何か書いてみましょう！';
  @override
  String get prisoedinilsyaKChatu_f623 => 'チャットに参加しました';
  @override
  String get pokinulChat_d567 => 'チャットを退出した';
  @override
  String get podpisalsyaNaKanal_0673 => 'チャンネル登録しました';
  @override
  String get otpisalsyaOtKanala_fa13 => 'チャンネル登録を解除しました';
  @override
  String get polzovatelya_1083 => 'ユーザー';
  @override
  String get priglasil_47ae => '招待されました';
  @override
  String get rasshifrovka_e47f => '[転写...]';
  @override
  String get sistemnoeSoobschenie_d2bd => 'システムメッセージ';
  @override
  String get soobschenie_3715 => 'メッセージ';
  @override
  String get videosoobschenie_57f1 => '📹ビデオメッセージ';
  @override
  String get spisokZadach_cfa4 => '📋 タスクリスト';
  @override
  String get opros_5902 => '📊 投票';
  @override
  String get vlozhenie_ef44 => 'アタッチメント';
  @override
  String get fayl_2d46 => 'ファイル';
  @override
  String get zagruzkaFayla_f817 => 'ファイルをロード中...';
  @override
  String get ishodyaschiyZvonok_8381 => '発信通話';
  @override
  String get razgovorNeSostoyalsya_67fb => '会話は成立しなかった';
  @override
  String get vhodyaschiyZvonok_5ce9 => '着信';
  @override
  String get otklonennyyZvonok_d499 => '拒否された通話';
  @override
  String get vyOtkloniliVyzov_8d1d => '電話を拒否しました';
  @override
  String get propuschennyyZvonok_e98d => '不在着信';
  @override
  String get vyPropustiliVyzov_f17a => '電話に出られなかった';
  @override
  String get vlozhenie_2474 => '📎添付ファイル';
  @override
  String get tb_0e05 => '結核';
  @override
  String get zapisGolosovogo_9c91 => '音声録音中...';
  @override
  String get zapisVideo_dd2a => 'ビデオ録画中...';
  @override
  String get otpustiteDlyaOtpravki_ea7b => 'リリースして送信する';
  @override
  String get emodzi_f822 => '絵文字';
  @override
  String get panelEmodziVRazrabotke_b6ce => '絵文字パネルは開発中';
  @override
  String get napisatSoobschenie_62d4 => 'メッセージを書いてください...';
  @override
  String get dobavitVlozhenie_769b => '添付ファイルを追加する';
  @override
  String get spisokZadach_1852 => 'タスクのリスト';
  @override
  String get opros_9f36 => '投票';
  @override
  String get zapisGolosovogoGs_db4e => '音声録音（VO）';
  @override
  String get zapisVideoVs_9676 => 'ビデオ録画（VS）';
  @override
  String get uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3 =>
      '•ボタンを長押しして録音します\n• 押してモードを切り替えます';
  @override
  @override
  String get novyyChat_f775 => '新規チャット';
  @override
  @override
  String get imyaPolzovatelyaMin5Simvolov_1232 => 'ユーザー名（5文字以上）';
  @override
  @override
  String get vvedite5IliBoleeSimvolov_f983 => '5文字以上入力してください';
  @override
  @override
  String get polzovateliNeNaydeny_c01a => 'ユーザーが見つかりません';
  @override
  String get mnozhestvennyyVybor_9b60 => '多肢選択';
  @override
  String get odinochnyyVybor_d920 => '単一選択';
  @override
  String get netGolosov_17d0 => '投票なし';
  @override
  String get golos_6b94 => '声';
  @override
  String get golosa_bb8d => '声';
  @override
  String get golosov_7f51 => '投票';
  @override
  String get nePoluchenIdFaylaOt_86c8 => 'ファイルIDがサーバーから受信されませんでした';
  @override
  String get faylZagruzhenIPrikreplen_dc24 => 'ファイルをアップロードして添付しました';
  @override
  String get neizvestnayaOshibkaZagruzki_68cb => '不明なダウンロード エラー';
  @override
  String get oshibkaZagruzkiFayla_86e5 => 'ファイルダウンロードエラー';
  @override
  String get sohranitFaylKak_0f93 => 'ファイルに名前を付けて保存';
  @override
  String get oshibkaSkachivaniyaFayla_34ac => 'ファイルダウンロードエラー';
  @override
  String get bezNazvaniya_6584 => '無題';
  @override
  String get bezVoprosa_d390 => '質問はありません';
  @override
  String get netDostupaKMikrofonu_a4ef => 'マイクへのアクセスがありません';
  @override
  String get zapisVideoCherezPlaginCamera_b9dd => '📹 カメラプラグインによるビデオ録画が開始されました';
  @override
  String get kameraNeInitsializirovanaNaEtoy_21e0 =>
      '📹 このプラットフォームではカメラが初期化されていません。';
  @override
  String get kameraNeGotova_9f09 => 'カメラの準備ができていません';
  @override
  String get zapisVideosoobscheniyaNaEtoyPlatforme_a561 =>
      '📹 このプラットフォームではビデオメッセージの録画を直接利用できません。';
  @override
  String get arecordOstanovlen_edf2 => '🎙️記録は停止されました';
  @override
  String get ffmpegOstanovlen_63a0 => '📹 ffmpeg が停止しました';
  @override
  String get zapisSlishkomKorotkaya_5cda => 'エントリーが短すぎます';
  @override
  String get oshibkaZapisiFaylPust_106b => '書き込みエラー: ファイルが空です';
  @override
  String get videosoobschenieOtpravlenoSimulyatsiya_fb29 =>
      'ビデオメッセージの送信（シミュレーション）';
  @override
  String get zapisOtmenena_1609 => '登録がキャンセルされました';
  @override
  String get otpravitGolosovoeSoobschenie_2481 => '音声メッセージを送信する';
  @override
  String get imitatsiyaZapisiGolosovogoSoobscheniya_81e7 =>
      '音声メッセージの録音のシミュレーション。';
  @override
  String get otpravit_6da0 => '送信';
  @override
  String get sozdatToDo_8c92 => 'TODOを作成する';
  @override
  String get nazvanieSpiska_c3cc => 'リスト名';
  @override
  String get punkty_0481 => 'アイテム:';
  @override
  String get dobavitPunkt_930c => 'アイテムの追加';
  @override
  String get sozdat_b059 => '作成';
  @override
  String get sozdatOpros_4b9e => 'アンケートを作成する';
  @override
  String get vopros_0911 => '質問';
  @override
  String get variantyOtveta_ef4e => '回答の選択肢:';
  @override
  String get dobavitVariant_76be => 'オプションを追加する';
  @override
  String get golosovoeSoobschenie_33d5 => '音声メッセージ';
  @override
  String get videosoobschenie_2951 => 'ビデオメッセージ';
  @override
  String get video_a095 => 'ビデオ';
  @override
  String get neUdalosZagruzitIzobrazhenie_3fa0 => '画像のロードに失敗しました';
  @override
  String get muzyka_0660 => '音楽';
  @override
  String get netDannyh_dee9 => 'データなし';
  @override
  String get istoriyaSoobscheniyPustaIliChat_2d07 =>
      'メッセージ履歴が空であるか、チャットがまだローカルに保存されていません';
  @override
  String get obschieMaterialy_11e4 => '一般的な材料';
  @override
  String get netMediafaylov_08d2 => 'メディアファイルがありません';
  @override
  String get zdesBudutOtobrazhatsyaObschieFoto_9bc7 => '共有された写真とビデオがここに表示されます';
  @override
  String get netFaylov_e95e => 'ファイルがありません';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c =>
      'アップロードされたファイルはここに表示されます';
  @override
  String get netGolosovyhSoobscheniy_2427 => '音声メッセージはありません';
  @override
  String get zdesBudutOtobrazhatsyaGolosovyeI_0a73 => '音声とビデオのメッセージがここに表示されます';
  @override
  String get netSsylok_b0ec => 'リンクはありません';
  @override
  String get zdesBudutOtobrazhatsyaObschieSsylki_6b61 => '一般的なリンクがここに表示されます';
  @override
  String get ssylkaSkopirovanaVBufer_c16e => 'リンクがクリップボードにコピーされました';
  @override
  String get netMuzyki_1ca3 => '音楽なし';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23 =>
      '投稿されたトラックがここに表示されます';
  @override
  String get udalennyyAkkaunt_ce47 => '削除されたアカウント';
  @override
  String get opisanie_38ca => '説明';
  @override
  String get mobilnyy_5ac7 => 'モバイル';
  @override
  String get bylANedavno_168d => '最近だった';
  @override
  String get minutu_5373 => '分';
  @override
  String get minuty_5bc9 => '分';
  @override
  String get minut_b877 => '分';
  @override
  String get nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a =>
      'クリックして新しいバージョンをダウンロードします';
  @override
  String get poiskLyudeyBotovGrupp_e84e => '人、ボット、グループを検索します...';
  @override
  String get vveditePoiskovyyZapros_0b8c => '検索語を入力してください';
  @override
  String get polzovateli_b8c4 => 'ユーザー';
  @override
  String get moiLichnyeSoobscheniya_7d3b => '私の個人的なメッセージ';
  @override
  String get sozdatNovyyChat_fd41 => '新しいチャットを作成する';
  @override
  String get lichnyyChat_cbec => '個人チャット';
  @override
  String get nachatObschenieSPolzovatelem_0578 => 'ユーザーとの会話を開始する';
  @override
  String get sozdatGruppu_459f => 'グループを作成する';
  @override
  String get gruppovoyChatDlyaObscheniyaS_01ba => '友達とコミュニケーションをとるためのグループチャット';
  @override
  String get sozdatKanal_9022 => 'チャンネルを作成する';
  @override
  String get kanalDlyaShirokoyAuditorii_9dba => '幅広い視聴者向けのチャンネル';
  @override
  String get redaktirovanie_1167 => '編集';
  @override
  String get vlevo_1af1 => '左';
  @override
  String get vpravo_c316 => '右';
  @override
  String get poGor_ff50 => '山沿いに';
  @override
  String get poVert_b4a9 => 'ヴェール。';
  @override
  String get vvediteNazvanieGruppy_0a69 => 'グループ名を入力してください';
  @override
  String get dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0 =>
      '公開グループにはニックネーム (@username) が必要です';
  @override
  String get gruppaSozdana_6b3b => 'グループが作成されました';
  @override
  String get oshibkaPriSozdaniiGruppy_794e => 'グループ作成エラー';
  @override
  String get nazhmiteNaIkonkuChtobyVybrat_af03 => 'アイコンをクリックしてアバターを選択します';
  @override
  String get nazvanieGruppy_9a39 => 'グループ名';
  @override
  String get opisanieNeobyazatelno_7812 => '説明 (オプション)';
  @override
  String get privatnayaGruppa_d20e => 'プライベートグループ';
  @override
  String get publichnayaGruppa_50f8 => 'パブリックグループ';
  @override
  String get vhodTolkoPoPriglasheniyu_97a1 => '招待者のみの入場';
  @override
  String get lyuboyMozhetNaytiIVstupit_5e26 => '誰でも見つけて参加できます';
  @override
  String get publichnayaSsylkanikneymMyGroup_6640 =>
      'パブリックリンク/ニックネーム (@my_group)';
  @override
  String get vvediteNazvanieKanala_5536 => 'チャンネル名を入力してください';
  @override
  String get dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06 =>
      'パブリック チャンネルにはリンク/ニックネーム (@mychannel) が必要です';
  @override
  String get kanalSozdan_1522 => 'チャンネルが作成されました';
  @override
  String get oshibkaPriSozdaniiKanala_7d4b => 'チャンネル作成エラー';
  @override
  String get nazvanieKanala_c548 => 'チャンネル名';
  @override
  String get privatnyyKanal_3139 => 'プライベートチャンネル';
  @override
  String get publichnyyKanal_0f7c => 'パブリックチャンネル';
  @override
  String get podpiskaTolkoPoPriglasheniyu_99c3 => '招待制によるサブスクリプションのみ';
  @override
  String get lyuboyMozhetNaytiIPodpisatsya_8579 => '誰でも見つけて購読できます';
  @override
  String get ssylkanikneymKanalaMychannel_79f6 =>
      'チャンネルリンク/ニックネーム (@mychannel)';
  @override
  String get yazykInterfeysa_b78b => 'インターフェース言語';
  @override
  String get dannyeUspeshnoSohraneny_2cc5 => 'データは正常に保存されました';
  @override
  String get oshibkaPriSohranenii_126f => '保存中にエラーが発生しました';
  @override
  String get lichnyeDannye_10a7 => '個人データ';
  @override
  String get nikneymUsername_8035 => 'ニックネーム (@ユーザー名)';
  @override
  String get nikneymNelzyaIzmenit_0b99 => 'ニックネームは変更できません';
  @override
  String get oSebeBio_b730 => '私について (略歴)';
  @override
  String get rasskazhiteNemnogoOSebe_3daa => 'あなた自身について少し教えてください...';
  @override
  String get nastroykiPrivatnostiSohraneny_447c => 'プライバシー設定が保存されました';
  @override
  String get privatnost_3098 => 'プライバシー';
  @override
  String get kommunikatsii_e9b8 => 'コミュニケーション';
  @override
  String get ktoMozhetPisat_3322 => '誰が書けるのか';
  @override
  String get zapisGolosovyh_8073 => '音声録音';
  @override
  String get otpravkaFaylov_aaca => 'ファイルの送信';
  @override
  String get priglashatVGruppy_3631 => 'グループに招待する';
  @override
  String get vidimostProfilya_448f => 'プロフィールの可視性';
  @override
  String get ktoViditAvatar_b5d8 => 'アバターを見る人';
  @override
  String get vremyaVSeti_be29 => 'オンライン時間';
  @override
  String get vneshniyVid_5a0f => '外観';
  @override
  String get rezhimOformleniyaInterfeysa_b91d => 'インターフェースデザインモード';
  @override
  String get pokazyvatVizualnyeEffektyIPerehody_3fd7 => '視覚効果とトランジションを表示する';
  @override
  String get razmerTeksta_3c4f => '文字サイズ';
  @override
  String get bezopasnost_fcbc => 'セキュリティ';
  @override
  String get dvuhfaktornayaAutentifikatsiya_acdc => '二要素認証';
  @override
  String get zaschitaAkkaunta2fa_f1ab => '2FA アカウント保護';
  @override
  String get vklyucheno_6b96 => '付属';
  @override
  String get xaneoMobileAktivnoSeychas_3345 => 'Xaneo モバイル • 現在アクティブです';
  @override
  String get zaschischennyyMessendzher_2f59 => '安全なメッセンジャー';
  @override
  String get temnayaTema_6018 => 'ダークテーマ';
  @override
  String get vklyuchenaPoUmolchaniyu_7610 => '有効 (デフォルト)';
  @override
  String get setevoyFiltr_40c2 => 'サージフィルター';
  @override
  String get vklyuchen_0994 => '有効';
  @override
  String get spisokMuzyki_57d0 => '音楽リスト';
  @override
  String get trek_5049 => 'トラック';
  @override
  String get trekov_d3f4 => 'トラック';
  @override
  String get pozhaluystaZapolniteVoprosIKak_7ad5 =>
      '質問と少なくとも 2 つの回答オプションを入力してください';
  @override
  String get sozdatOpros_8401 => 'アンケートを作成する';
  @override
  String get sozdatSpisokZadach_4018 => 'タスクリストの作成';
  @override
  String get pozhaluystaZapolniteNazvanieIKak_3783 =>
      'タイトルと少なくとも 1 つの項目を入力してください';
  @override
  String get sozdatSpisokZadach_0416 => 'タスクリストを作成する';
  @override
  String get vhodyaschiyVideozvonok_14d4 => 'ビデオ通話の着信';
  @override
  String get prinyat_5dc5 => '受け入れる';
  @override
  String get netObschihFaylov_bf77 => '共有ファイルはありません';
  @override
  String get neUdalosRazarhivirovatChatNa_b6f6 => 'サーバー上のチャットのアーカイブを解除できませんでした';
  @override
  String get poiskVArhive_c5d8 => 'アーカイブ検索...';
  @override
  String get poprobuyteIzmenitZapros_52ea => 'リクエストを変更してみてください';
  @override
  String get zdesBudutNahoditsyaVashiArhivirovannye_7359 =>
      'アーカイブされたチャットはここに移動します';
  @override
  String get vernut_54aa => '戻る';
  @override
  String get zashifrovannoeSoobschenie_c9ab => '暗号化されたメッセージ';
  @override
  String get soobschenieNahoditsyaVysheVIstorii_dc90 => 'メッセージはストーリーの上位にあります。';
  @override
  String get otpravlyaetFoto_67c1 => '写真を送ります...';
  @override
  String get otpravlyaetVideo_ce80 => 'ビデオを送信します...';
  @override
  String get otpravlyaetFayl_5e88 => 'ファイルを送信します...';
  @override
  String get ktoTo_8405 => '誰か';
  @override
  String get trebuetsyaRazreshenieNaKameruI_06fa => 'カメラとマイクの許可が必要です';
  @override
  String get kameraNeNaydena_208d => 'カメラが見つかりません';
  @override
  String get zapisVideoOtmenena_1db7 => 'ビデオ録画がキャンセルされました';
  @override
  String get slishkomKorotkoeVideosoobschenie_4676 => 'ビデオメッセージが短すぎます';
  @override
  String get pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35 =>
      'ファイルがダウンロードされるまでお待ちください';
  @override
  String get audiozvonok_dcf6 => '音声通話';
  @override
  String get otpravitFotoVideoAudioIli_37e9 => '写真、ビデオ、オーディオ、またはその他のファイルを送信する';
  @override
  String get provedenieGolosovaniyaVChate_a629 => 'チャットでの投票';
  @override
  String get sozdatToDoSpisok_cb50 => 'ToDoリストを作成する';
  @override
  String get spisokZadachSOtmetkamiVypolneniya_c778 => '完了マークが付いたタスクのリスト';
  @override
  String get trebuetsyaRazreshenieNaZapisAudio_8175 => '音声を録音するには許可が必要です';
  @override
  String get slishkomKorotkoeSoobschenie_c2ee => 'メッセージが短すぎます';
  @override
  String get uderzhivayteKnopkuDlyaZapisi_a762 => 'ボタンを長押しして録音します';
  @override
  String get udalennyy_40c6 => 'リモート';
  @override
  String get udalennyy_c2c8 => 'リモート';
  @override
  String get neobhodimyRazresheniyaNaMikrofonI_224b => '通話するにはマイクとカメラの許可が必要です';
  @override
  String get bylATolkoChto_9ac0 => 'ちょうどそこにありました';
  @override
  String get chatNeNayden_ba4f => 'チャットが見つかりません';
  @override
  String get napishitePervoeSoobschenie_8260 => '最初のメッセージを書いてください';
  @override
  String get prisoedinitsyaKKanalu_f863 => 'チャンネルに参加する';
  @override
  String get vyPodpisany_5fb9 => 'あなたは購読しています';
  @override
  String get otpisatsya_ee2d => '購読を解除する';
  @override
  String get vyUspeshnoPodpisalisNaKanal_9c99 => 'チャンネル登録が完了しました！';
  @override
  String get vyUspeshnoVstupiliVGruppu_61a1 => 'グループに正常に参加しました!';
  @override
  String get neUdalosPrisoedinitsyaPoprobuyteEsche_bce5 =>
      '参加できませんでした。もう一度やり直してください。';
  @override
  String get vyrezat_a195 => 'カット';
  @override
  String get kopirovat_112b => 'コピー';
  @override
  String get vstavit_dcc4 => 'ペースト';
  @override
  String get vybratVse_4d09 => 'すべて選択';
  @override
  String get zhirnyy_7774 => '太字';
  @override
  String get kursiv_e0b1 => 'イタリック体';
  @override
  String get kod_3f34 => 'コード';
  @override
  String get zacherknut_02fc => '取り消し線を引く';
  @override
  String get soobschenie_8b9b => 'メッセージ...';
  @override
  String get smahniteDlyaOtmeny_e976 => 'スワイプしてキャンセルします';
  @override
  String get poisk_bfc9 => '検索';
  @override
  String get udalitChat_4b2b => 'チャットを削除する';
  @override
  String get udalitKanal_482f => 'チャンネルの削除';
  @override
  String get pozhalovatsya_a7d9 => '苦情を言う';
  @override
  String get redaktirovatGruppu_e40a => 'グループの編集';
  @override
  String get udalitGruppu_dff8 => 'グループの削除';
  @override
  String get poiskSoobscheniyVremennoNedostupenV_4443 =>
      'モバイル版ではメッセージ検索が一時的に利用できなくなります';
  @override
  String get zhalobaOtpravlenaModeratoram_4547 => '苦情はモデレータに送信されました';
  @override
  String get redaktirovanieGruppyVremennoNedostupnoV_05d0 =>
      'モバイル版ではグループ編集が一時的に利用できなくなります';
  @override
  String get vyUverenyChtoHotiteOchistit_7c3a =>
      'このチャットのメッセージ履歴を消去してもよろしいですか?この操作は元に戻すことができません。';
  @override
  String get ochistit_7074 => 'クリア';
  @override
  String get udalit_ed2b => '削除';
  @override
  String get vyyti_0f05 => 'ログアウト';
  @override
  String get oshibkaVosproizvedeniya_ac8a => '再生エラー';
  @override
  String get novoeZashifrovannoeSoobschenie_4d30 => '新しい暗号化メッセージ';
  @override
  String get poiskChatov_779c => 'チャットを検索...';
  @override
  String get obnovlenie_53e2 => '更新...';
  @override
  String get soedinenie_5a58 => '接続...';
  @override
  String get lichnye_4cb3 => '個人的な';
  @override
  String get neUdalosArhivirovatChatNa_36aa => 'サーバー上でチャットをアーカイブできませんでした';
  @override
  String get oshibkaZagruzkiChatov_902f => 'チャットの読み込みエラー';
  @override
  String get povtorit_b914 => 'リピート';
  @override
  String get netChatov_85e3 => 'チャットなし';
  @override
  String get nachniteNovyyRazgovor_8290 => '新しい会話を開始する';
  @override
  String get neUdalosZagruzitAkkaunty_8570 => 'アカウントのロードに失敗しました';
  @override
  String get vyberiteAkkaunt_79e7 => 'アカウントを選択してください';
  @override
  String get bystryyVhodNaEtomUstroystve_3f30 => 'このデバイスでのクイックログイン';
  @override
  String get voytiSParolem_9277 => 'パスワードでログイン';
  @override
  String get sozdatXaneoId_4033 => 'ザネオIDの作成';
  @override
  String get netSohranennyhAkkauntov_b669 => '保存されたアカウントはありません';
  @override
  String get tolkoChto_4493 => 'たった今';
  @override
  String get emailNedostupen_fc3e => '電子メールは利用できません';
  @override
  String get nevernyyKod_50f9 => '無効なコード';
  @override
  String get oshibkaProverkiKoda_9018 => 'コード検証エラー';
  @override
  String get neobhodimoRazreshenieNaDostupK_5f5c => '写真にアクセスするには許可が必要です';
  @override
  String get oVyboreEmail_2609 => '電子メールの選択について';
  @override
  String get podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0 =>
      'を除くすべての電子メール ドメインがサポートされています。';
  @override
  String get zapreschennyh_1f49 => '禁止';
  @override
  String get obIspolzovaniiParolya_9739 => 'パスワードの使用について';
  @override
  String get parolTolkoDlyaAvariynogoVhoda_b142 =>
      'パスワードは、「Xaneo通知」ボットのコードやメールに届くコードでログインできない場合の緊急用です。';
  @override
  String get sozdatAkkaunt_19ed => 'アカウントを作成する';
  @override
  String get naprimerIvan_d7cb => 'たとえば、イワン';
  @override
  String get zadayteParol_53d2 => 'パスワードを設定する';
  @override
  String get minimum8Simvolov_4ccd => '最低 8 文字';
  @override
  String get unikalnoeImyaDlyaVashegoProfilya_a0ea => 'プロフィールの一意の名前';
  @override
  String get vashEmail_879d => 'あなたのメールアドレス';
  @override
  String get dlyaSvyaziIVosstanovleniyaDostupa_c770 => '通信およびアクセス復旧のため';
  @override
  String get emailAdres_9130 => 'メールアドレス';
  @override
  String get vvediteParolEscheRaz_7383 => 'パスワードをもう一度入力してください';
  @override
  String get parolEscheRaz_6daf => 'パスワードを再入力';
  @override
  String get paroliNeSovpadayut_d82f => 'パスワードが一致しません';
  @override
  String get ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed => 'あなたの本当の生年月日を教えてください';
  @override
  String get ddmmgggg_3524 => 'DD.MM.YYYY';
  @override
  String get sdelayteProfilUznavaemym_f2c5 => 'プロフィールを認識できるようにする';
  @override
  String get profilGotov_b57d => 'プロファイルの準備ができました';
  @override
  String get ostalosVsegoParaShagov_37e3 => '残りわずか数ステップ';
  @override
  String get yaPrinimayuPolzovatelskoeSoglashenie_c431 => 'ユーザー契約に同意します';
  @override
  String get yaDayuSoglasieNaObrabotku_0d03 => '個人データの処理に同意します';
  @override
  String get sVozvrascheniem_77ee => 'おかえりなさい';
  @override
  String get zagruzka_43e4 => '読み込み中...';
  @override
  String get vyberiteAkkauntDlyaVhoda_d3a6 => 'ログインするアカウントを選択してください';
  @override
  String get vvediteVashNikneym_51a6 => 'ニックネームを入力してください';
  @override
  String get voytiVDrugoyAkkaunt_d10f => '別のアカウントにログインする';
  @override
  String get nedavnieAkkaunty_953d => '最近のアカウント';
  @override
  String get dobroPozhalovatVXaneo_66d0 => 'ザネオへようこそ';
  @override
  String get xaneoTeperIVMobilnom_e918 =>
      'Xaneo がモバイルアプリで利用できるようになりました。このメッセンジャーはかつてないほど便利で高速です。';
  @override
  String get mneUzheInteresno_5365 => 'すでに興味があります';
  @override
  String get vseVashiDannyePodZaschitoy_b7d9 => 'すべてのデータは保護されています';
  @override
  String get vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e =>
      'すべてのメッセージはエンドツーエンドの暗号化で保護されます。ザネオはどの段階でもその内容を知りません。';
  @override
  String get prodolzhit_e9c3 => '続ける';
  @override
  String get lokalnyeDataTsentry_f089 => 'ローカルデータセンター';
  @override
  String get vashiDannyeNikogdaNePokidayut_f871 =>
      'データは国外に出ることはなく、安全なデータセンターに保管されます。';
  @override
  String get kodOtpravlenPovtorno_e109 => 'コードが再送信されました';
  @override
  String get dvuhfaktornayanautentifikatsiya_bacc => '二要素\n認証';
  @override
  String get naVashEmailOtpravlen6_b457 => '6桁のコードがメールに送信されました';
  @override
  String get podtverdit_e260 => '確認する';
  @override
  String get nePoluchiliKodOtpravitPovtorno_c1d2 => 'コードを受け取っていませんか?再送信';
  @override
  String get imyaNikneymOSebe_7a8d => '名前、ニックネーム、自己紹介';
  @override
  String get zvonkiSoobscheniyaVidimostProfilya_f905 => '通話、メッセージ、プロフィールの公開範囲';
  @override
  String get parolSessii2fa_de9e => 'パスワード、セッション、2FA';
  @override
  String get prilozhenie_38aa => '付録';
  @override
  String get temaRazmerTekstaAnimatsii_f0a8 => 'テーマ、文字サイズ、アニメーション';
  @override
  String get pushUvedomleniyaZvuki_9cc2 => 'プッシュ通知、サウンド';
  @override
  String get oPrilozhenii_77b2 => 'アプリケーションについて';

  @override
  String get redaktirovatProfil_56ad => 'プロフィールの編集';
  @override
  String get dobavitKontakt_2903 => '連絡先を追加';
  @override
  String get nikneymPolzovatelyaUsername_a6ff => 'ユーザーのニックネーム (@username)';
  @override
  String get otobrazhaemoeImyaNeobyazatelno_340a => '表示名 (オプション)';
  @override
  String get neUdalosNaytiIliDobavit_649f => 'ユーザーが見つからないか追加できませんでした';
  @override
  String get ya_feef => '私は';
  @override
  String get poiskKontaktov_9a71 => '連絡先を検索...';
  @override
  String get spisokKontaktovPust_58c6 => '連絡先リストが空です';
  @override
  String get kontaktyNeNaydeny_1b08 => '連絡先が見つかりません';

  @override
  String get messages => 'メッセージ';
  @override
  String get messageAnimations => 'メッセージアニメーション';
  @override
  String get messageAnimationsDesc => '送信・受信時にアニメーションを表示';
  @override
  String get archivedChats => 'アーカイブされたチャット';
  @override
  String get archiveManagement => 'アーカイブ管理';
  @override
  String get clearHistory => '履歴を消去';
  @override
  String get clearHistoryDesc => 'すべてのメッセージ를ローカルから削除';
  @override
  String get call => '通話';
  @override
  String get sendMessage => 'メッセージを送る';
  @override
  String get deleteContact => '連絡先を削除';
  @override
  String get activeSessions => 'アクティブなセッション';
  @override
  String get thisDevice => 'このデバイス';
  @override
  String get xaneoPcActiveNow => 'Xaneo PC • 現在アクティブ';
  @override
  String get activeNow => 'アクティブ';
  @override
  String get twoFactorAuth => '2段階認証';
  @override
  String get twoFactorAuthDesc => 'ワンタイムパスワードでアカウントを保護';
  @override
  String get dangerZone => 'デンジャーゾーン';
  @override
  String get deleteAccount => 'アカウントを削除';
  @override
  String get irreversibleAction => 'この操作は取り消せません';
  @override
  String get theme => 'テーマ';
  @override
  String get darkThemeDesc => 'ダークモードとライトモードを切り替え';
  @override
  String get fontSizeText => 'フォントサイズ';
  @override
  String get changePhoto => '写真を変更';
  @override
  String get avatarUpdated => 'アバターを更新しました';
  @override
  String get avatarUploadFailed => 'アバターをアップロードできませんでした';
  @override
  String get invalidNicknameFormat => 'ニックネームは3～30文字で、英数字、.、_、- のみ使用できます';
  @override
  String get deleteAccountPrompt => 'プロフィールは完全に削除されます。確認のためパスワードを入力してください。';
  @override
  String get deleteAccountFailed => 'アカウントを削除できませんでした';
  @override
  String get chatFontSize => 'チャットの文字サイズ';
  @override
  String get chatWallpaper => 'チャットの背景';
  @override
  String get myMessageColor => '自分のメッセージの色';
  @override
  String get otherMessageColor => '相手のメッセージの色';
  @override
  String get notificationStyle => '通知スタイル';
  @override
  String get standardNotificationStyle => '標準';
  @override
  String get blackRavenNotificationStyle => '黒いワタリガラス';
  @override
  String get wallpaperUploadFailed => '背景をアップロードできませんでした';
  @override
  String get showPopups => 'ポップアップ通知を表示';
  @override
  String get sound => '通知音';
  @override
  String get soundDesc => '新着メッセージ受信時に音を鳴らす';
  @override
  String get mainSettings => '基本設定';
  @override
  String get energySavingMode => '省電力モード';
  @override
  String get energySavingModeDesc => 'バッテリー消費を抑えるために最適化';
  @override
  String get autoSleep => '自動スリープ';
  @override
  String get autoSleepDesc => '非アクティブ時にアプリをスリープ状態にする';
  @override
  String get animations => 'アニメーション';
  @override
  String get reducedMotion => '視覚効果を減らす';
  @override
  String get reducedMotionDesc => 'UIアニメーションの表示を削減';
  @override
  String get comingSoon => '近日公開';
  @override
  String get darkTheme => 'ダークテーマ';
  @override
  String get version => 'バージョン';

  @override
  String get updateAvailable => 'アップデートがあります';
  @override
  String get clickToViewChanges => '変更点を確認';
  @override
  String get newVersionAvailable => '新しいバージョンのアプリが利用可能です';
  @override
  String get newVersionAvailableTitle => '新バージョンが利用可能';
  @override
  String get youHaveLatestVersion => '最新バージョンがインストールされています';
  @override
  String get whatsNew => '新機能';
  @override
  String get officialReleaseNotes => '公式リリースノートはGitHubで確認できます';
  @override
  String get preparingDownload => 'ダウンロードの準備中...';
  @override
  String get installationStarted => 'インストールを開始しました...';
  @override
  String get whoSeesAvatar => 'アバターを表示できる人';
  @override
  String get whoSeesBirthday => '誕生日を表示できる人';
  @override
  String get whoSeesOnlineTime => 'オンライン時間を表示できる人';

  @override
  String get downloadVersion => 'ダウンロード';
  @override
  String get downloadSource => 'ダウンロード元';
  @override
  String get directInAppInstall => 'アプリ内直接インストール';
  @override
  String get autoDownloadAndRun => '自動ダウンロードと起動';
  @override
  String get githubReleasePage => 'GitHub リリースページ';
  @override
  String get skip => 'スキップ';
  @override
  String get updateAction => '更新';
  @override
  String get installAction => 'インストール中...';
  @override
  String get isTyping => '入力中...';
  @override
  String get isRecordingVoice => '音声メッセージを録音中...';
  @override
  String get areTyping => '入力中...';

  @override
  String membersCount(int count) => '$count メンバー';
  @override
  String subscribersCount(int count) => '$count チャンネル登録者';

  @override
  String get group => 'グループ';
  @override
  String get channel => 'チャンネル';

  @override
  String get profile => 'プロフィール';
  @override
  String get userHidInfo => 'ユーザーは情報を非表示にしています';
  @override
  String get leaveGroup => 'グループを退出';
  @override
  String get joinGroup => 'グループに参加';
  @override
  String get unsubscribeChannel => '登録解除';
  @override
  String get subscribeChannel => 'チャンネル登録';
  @override
  String get deleteChat => 'チャットを削除';
  @override
  String get pinChat => 'ピン留め';
  @override
  String get unpinChat => 'ピン留め解除';
  @override
  String get muteNotifications => '通知をミュート';
  @override
  String get unmuteNotifications => '通知のミュートを解除';
  @override
  String get backToChats => 'チャット一覧へ戻る';
  @override
  String get globalSearch => '全体検索';
  @override
  String get chatSettings => 'チャット設定';
  @override
  String get emoji => '絵文字';
  @override
  String get attachFile => 'ファイルを添付';
  @override
  String get startCall => '通話を開始';
  @override
  String get audioCall => '音声通話';
  @override
  String get audioCallDesc => '音声で発信';
  @override
  String get videoCall => 'ビデオ通話';

  @override
  String get copied => 'コピーしました';

  @override
  String get copy => 'コピー';

  @override
  String get voiceRecordTitle => '音声録音';
  @override
  String get videoRecordTitle => 'ビデオ録画';
  @override
  String get holdToRecordHint => '長押しで録音\nタップでモード切替';
  @override
  String get addAttachment => '添付ファイルを追加';
  @override
  String get emojiPanelInDev => '絵文字パネル開発中';
  @override
  String get recordingVoice => '音声録音中...';
  @override
  String get recordingVideo => 'ビデオ録画中...';
  @override
  String get releaseToSend => '離して送信';
  @override
  String get videoCallDesc => 'カメラをオンにして発信';

  @override
  String get typeMessage => 'メッセージを入力...';
  @override
  String get file => 'ファイル';
  @override
  String get todoList => 'タスクリスト';
  @override
  String get poll => '投票';

  @override
  String get today => '今日';
  @override
  String get yesterday => '昨日';
  @override
  String get monthJan => '1月';
  @override
  String get monthFeb => '2月';
  @override
  String get monthMar => '3月';
  @override
  String get monthApr => '4月';
  @override
  String get monthMay => '5月';
  @override
  String get monthJun => '6月';
  @override
  String get monthJul => '7月';
  @override
  String get monthAug => '8月';
  @override
  String get monthSep => '9月';
  @override
  String get monthOct => '10月';
  @override
  String get monthNov => '11月';
  @override
  String get monthDec => '12月';
  @override
  String get createTodo => 'ToDoを作成';
  @override
  String get listName => 'リスト名';
  @override
  String get todoItems => '項目';
  @override
  String get addTodoItem => '+ 項目を追加';
  @override
  String get itemHintPrefix => '項目';
  @override
  String get createPoll => '投票を作成';
  @override
  String get pollQuestion => '質問';
  @override
  String get pollOptions => '選択肢';
  @override
  String get addPollOption => '+ 選択肢を追加';
  @override
  String get optionHintPrefix => '選択肢';
  @override
  String get allowMultipleAnswers => '複数選択を許可';
  @override
  String get accountsTitle => 'アカウント';
  @override
  String get addAccount => 'アカウントを追加';
  @override
  String get accountLimitNotice => 'アカウント上限: 5';

  @override
  String get singleChoice => '単一選択';

  @override
  String get media => 'メディア';
  @override
  String get files => 'ファイル';
  @override
  String get voice => '音声';
  @override
  String get links => 'リンク';

  @override
  String get bio => '自己紹介';
  @override
  String get username => 'ユーザー名';
  @override
  String get birthday => '生年月日';
  @override
  String get noSharedMedia => 'メディアはありません';
  @override
  String get noSharedFiles => 'ファイルはありません';
  @override
  String get noSharedVoice => '音声メッセージはありません';
  @override
  String get noSharedLinks => 'リンクはありません';

  @override
  String get savedMessagesDesc => 'メモ、ファイル、メッセージの個人クラウドストレージ';
  @override
  String get music => '音楽';
  @override
  String get noSharedMusic => '音楽はありません';
  @override
  String get secureDesktopCommunicator => 'セキュアなデスクトップコミュニケーター';
  @override
  String get noMessagesTitle => 'メッセージはありません';
  @override
  String get noMessagesSubtitle => 'メッセージを送信してXaneo Connectで会話を始めましょう！';

  @override
  String get qrScanTitle => 'デバイスの認証';
  @override
  String get qrScanSubtitle => 'XaneoのWeb版またはPCクライアントの画面にあるQRコードにカメラを向けてください';
  @override
  String get qrScanSuccessTitle => 'デバイス認証完了';
  @override
  String get qrScanSuccessDesc =>
      '認証に成功しました。エンドツーエンド暗号化（E2EE）キーが新しいデバイスに転送されました。';
  @override
  String get qrScanInputHint => 'トークンまたはペイロードを貼り付け...';
  @override
  String get qrScanPasteTooltip => 'クリップボードから貼り付け';
  @override
  String get qrScanConfirmButton => '認証を承認';
  @override
  String get qrScanProcessing => 'デバイスを認証中...';

  @override
  String get qrScanConfirmDesc =>
      '別のデバイスからアカウントへのログインが要求されました。短いコードを確認して承認してください。';

  @override
  String get qrScanSecurityNote => '自分が管理するデバイスにQRコードが表示されている場合のみ続行してください。';

  @override
  String get qrScanDoneButton => '完了';

  @override
  String get authNotificationSendingCode => 'コードを送信中';

  @override
  String get authNotificationEnterCode => 'コードを入力';

  @override
  String get authNotificationConfirmLogin => 'ログインを確認';

  @override
  String get authNotificationPasswordLogin => 'パスワードでログイン';

  @override
  String get authNotificationSendingSubtitle =>
      'コードは「Xaneo通知」チャットに送信されます。この画面を閉じないでください。';

  @override
  String get authNotificationEnterCodeSubtitle => 'メッセージに記載された6桁のコードを入力してください。';

  @override
  String get authNotificationConfirmSubtitle =>
      'すでに認証済みの端末でXaneoを開き、リクエスト詳細を確認してください。';

  @override
  String get authNotificationPasswordSubtitle =>
      'この方法は待機時間経過後のみ利用可能です。パスワードは保存されません。';

  @override
  String get authNotificationBotSource => 'コードは「Xaneo通知」から送信されます。';

  @override
  String authNotificationCodeSentToEmail(String email) => '$email にコードを送信しました';

  @override
  String get authNotificationNoBotAccess => 'ボットにアクセスできませんか？';

  @override
  String get authNotificationGetCodeViaEmail => 'メールでコードを受け取る';

  @override
  String get authNotificationResendCodeViaEmail => 'メールにコードを再送信';

  @override
  String get authNotificationEmailUnavailable =>
      'メール認証コードは利用できません：認証済みメールアドレスがありません。';

  @override
  String authNotificationEmailAvailableIn(int seconds) =>
      'メール認証コードはあと $seconds 秒で利用可能になります';

  @override
  String get authNotificationLoginWithPassword => 'パスワードでログイン';

  @override
  String authNotificationPasswordAvailableIn(int seconds) =>
      'パスワードログインはあと $seconds 秒で利用可能になります';

  @override
  String get authNotificationErrorSendFailed => 'コードを送信できませんでした。後でもう一度お試しください。';

  @override
  String get authNotificationErrorInvalidCode => 'コードが無効または期限切れです';

  @override
  String get authNotificationErrorRequestExpired => 'リクエストが拒否されたか期限切れです';

  @override
  String get authNotificationErrorEmailFailed =>
      'メールにコードを送信できませんでした。後でもう一度お試しください。';

  @override
  String get authNotificationErrorPasswordFailed =>
      'ログインに失敗しました。パスワードを確認するか、最初からやり直してください。';

  @override
  String get authNotificationGetCodeBtn => 'コードを取得';

  @override
  String get authRejectedTitle => 'ログインが拒否されました';

  @override
  String get authRejectedDesc =>
      '他の端末でログインリクエストが拒否されました。心当たりがない場合は、アカウントのセキュリティを確認してください。';

  @override
  String get authRejectedButton => '了解';

  @override
  String get deviceAuthApprovalSubtitle =>
      'コードを確認しました。ご自身でリクエストした場合のみログインを許可してください。';

  @override
  String get deviceAuthApprovalKeysNotice => 'チャットキーは暗号化された状態で新しい端末に転送されます。';

  @override
  String get deviceAuthApprovalAllow => 'ログインを許可';

  @override
  String get deviceAuthApprovalDecline => '拒否';

  @override
  String get deviceAuthDevice => 'デバイス';

  @override
  String get deviceAuthApp => 'アプリ';

  @override
  String get deviceAuthIp => 'IPアドレス';

  @override
  String get importLanguageFromJson => 'JSONから言語をインポート';
  @override
  String get customColor => 'カスタムカラー';
  @override
  String get customGradient => 'カスタムグラデーション';
  @override
  String get colorOne => '色 1';
  @override
  String get colorTwo => '色 2';
  @override
  String get diagonal => '斜め';
  @override
  String get vertical => '垂直';
  @override
  String get horizontal => '水平';
}
