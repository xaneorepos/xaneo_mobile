import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Xaneo PC';

  @override
  String get welcomeTitle => '欢迎使用 Xaneo';

  @override
  String get welcomeDescription => 'Xaneo 现已登陆电脑端！卓越性能与极佳体验。';

  @override
  String get getStartedButton => '立即开始';

  @override
  String get privacyTitle => '您的所有数据都是安全的';

  @override
  String get privacyDescription => 'Xaneo 中的所有消息均受端到端加密保护。';

  @override
  String get continueButton => '继续';

  @override
  String get dataStorageTitle => 'Xaneo 数据中心均位于俄罗斯';

  @override
  String get dataStorageDescription => '您的数据不会出境，安全存储于合规数据中心。';

  @override
  String get finishButton => '完成';

  @override
  String get setupCompleted => '设置完成！';

  @override
  String get loginFormTitle => '登录系统';

  @override
  String get loginFieldHint => '用户名';

  @override
  String get passwordFieldHint => '密码';

  @override
  String get loginButton => '登录';

  @override
  String get noAccount => '还没有账号？';

  @override
  String get registerButton => '注册账号';

  @override
  String get fillAllFields => '请填写所有必填项';

  @override
  String get loggingIn => '正在登录...';

  @override
  String welcomeUser(String username) => '欢迎，$username！';

  @override
  String get invalidCredentials => '账号或密码错误，请检查后再试。';

  @override
  String get serverError => '服务器错误，请稍后再试。';

  @override
  String get connectionError => '网络连接错误，请检查网络。';

  @override
  String get settings => '设置';

  @override
  String get notifications => '通知设置';

  @override
  String get notificationsDescription => '开启或关闭系统通知';

  @override
  String get darkThemeDescription => '开启或关闭深色主题';

  @override
  String fontSize(int size) => '字体大小: $size';

  @override
  String get language => '界面语言';

  @override
  String get languageDescription => '选择您偏好的界面语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get appVersion => '应用版本';

  @override
  String get registerTitle => '账号注册';

  @override
  String get registerStep0Title => '您的名字是？';

  @override
  String get registerStep0Subtitle => '请输入您的真实姓名';

  @override
  String get registerStep1Title => '您的出生日期？';

  @override
  String get registerStep1Subtitle => '您须年满 14 周岁';

  @override
  String get registerStep2Title => '设置一个昵称';

  @override
  String get registerStep2Subtitle => '昵称必须保持唯一';

  @override
  String get registerStep3Title => '您的电子邮箱';

  @override
  String get registerStep3Subtitle => '我们将向您发送验证码';

  @override
  String get registerStep4Title => '设置密码';

  @override
  String get registerStep4Subtitle => '请输入高强度安全密码';

  @override
  String get registerStep5Title => '添加头像';

  @override
  String get registerStep5Subtitle => '此项可选，推荐设置';

  @override
  String get registerStep6Title => '最后一步';

  @override
  String get registerStep6Subtitle => '阅读并同意服务条款';

  @override
  String get yourName => '姓名';

  @override
  String get birthDate => '出生日期';

  @override
  String get nickname => '昵称';

  @override
  String get checkingNickname => '正在检查昵称...';

  @override
  String get nicknameAvailable => '昵称可用';

  @override
  String get nicknameTaken => '昵称已被占用';

  @override
  String get email => '电子邮箱';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get addPhoto => '点击添加头像';

  @override
  String get removePhoto => '移除头像';

  @override
  String get acceptTerms => '我同意服务条款';

  @override
  String get acceptDataProcessing => '我同意个人信息处理政策';

  @override
  String get back => '上一步';

  @override
  String get next => '下一步';

  @override
  String get finish => '完成';

  @override
  String get backToLogin => '返回登录';

  @override
  String get registrationSuccess => '注册成功！';

  @override
  String get registrationError => '注册失败';

  @override
  String get enterVerificationCode => '请输入验证码';

  @override
  String get invalidVerificationCode => '验证码错误';

  @override
  String get codeSent => '验证码已发送至邮箱';

  @override
  String get sendCodeError => '发送验证码失败';

  @override
  String get confirmEmail => '验证邮箱';

  @override
  String codeSentToEmail(String email) => '验证码已发送至\n$email';

  @override
  String get verify => '验证';

  @override
  String get resendCode => '重新发送验证码';

  @override
  String resendIn(int count) => '$count 秒后可重发';

  @override
  String get acceptTermsRequired => '请阅读并勾选同意服务条款与隐私政策';

  @override
  String get about => '关于';

  @override
  String get aboutDescription => '现代化的系统管理与通讯软件。';

  @override
  String get close => '关闭';

  @override
  String get technicalInfo => '技术信息';

  @override
  String get platform => '运行平台';

  @override
  String get architecture => '处理器架构';

  @override
  String get flutter => 'Flutter';

  @override
  String get viewOnGitHub => '在 GitHub 上查看';

  @override
  String get chats => '聊天';
  @override
  String get search => '搜索';
  @override
  String get searchPlaceholder => '搜索消息和聊天...';
  @override
  String get savedMessages => '收藏消息';
  @override
  String get online => '在线';
  @override
  String get offline => '离线';
  @override
  String get lastSeenRecently => '最近上线';
  @override
  String get musicPlaylist => '音乐播放列表';
  @override
  String get reply => '回复';
  @override
  String get edit => '编辑';
  @override
  String get pin => '置顶';
  @override
  String get unpin => '取消置顶';
  @override
  String get delete => '删除';
  @override
  String get forward => '转发';
  @override
  String get members => '成员';
  @override
  String get noMessages => '暂无消息';

  @override
  String get joinedChat => '加入了聊天';
  @override
  String get leftChat => '离开了聊天';
  @override
  String get subscribedChannel => '订阅了频道';
  @override
  String get unsubscribedChannel => '取消订阅了频道';
  @override
  String get invited => '邀请了';
  @override
  String get systemMessage => '系统消息';
  @override
  String get selectChatToStart => '选择一个聊天开始沟通';
  @override
  String get toArchive => '归档';
  @override
  String get unarchive => '取消归档';
  @override
  String get archive => '归档箱';
  @override
  String get archiveEmpty => '归档箱为空';
  @override
  String get voiceMessage => '语音消息';
  @override
  String get videoMessage => '视频消息';

  @override
  String get personalData => '个人资料';
  @override
  String get personalDataDesc => '姓名、昵称、头像';
  @override
  String get privacyDesc => '设置谁可以发送消息、通话或查看资料';
  @override
  String get chatsSettings => '聊天设置';
  @override
  String get chatsSettingsDesc => '通知、主题与聊天记录';
  @override
  String get contacts => '联系人';
  @override
  String get contactsDesc => '您保存的联系人';
  @override
  String get security => '安全';
  @override
  String get securityDesc => '会话、密码与双重验证';
  @override
  String get appearance => '外观';
  @override
  String get appearanceDesc => '主题、字体与界面缩放';
  @override
  String get energySaving => '省电模式';
  @override
  String get energySavingDesc => '动画效果与系统性能';

  @override
  String get account => '账号设置';
  @override
  String get interface => '界面设置';
  @override
  String get logout => '退出登录';

  @override
  String get basicInfo => '基本信息';
  @override
  String get nicknameCannotBeChanged => '应用内无法修改用户名';
  @override
  String get aboutMe => '个人简介';
  @override
  String get aboutMeHint => '介绍一下您自己...';
  @override
  String get save => '保存';
  @override
  String get saving => '保存中...';
  @override
  String get communications => '通讯设置';
  @override
  String get whoCanMessage => '谁可以向我发消息';
  @override
  String get whoCanCall => '谁可以呼叫我';
  @override
  String get whoCanRecordVoice => '谁可以发送语音';
  @override
  String get whoCanSendFiles => '谁可以发送文件';
  @override
  String get whoCanInvite => '谁可以邀请我加入群组';
  @override
  String get profileVisibility => '个人资料可见性';
  @override
  String get whoSeesNickname => '谁能看见我的用户名';
  @override
  String get everyone => '所有人';
  @override
  String get contactsOnly => '仅限联系人';
  @override
  String get nobody => '任何人都不';
  @override
  String get addContact => '添加';
  @override
  String get addContactTitle => '添加联系人';
  @override
  String get userNicknameHint => '用户的用户名';
  @override
  String get displayNameOptional => '显示名称（可选）';
  @override
  String get noContactsYet => '您暂无保存的联系人';
  @override
  String get appInfo => '应用详细信息';
  @override
  String get checkUpdates => '检查更新';
  @override
  String get checkingUpdates => '正在检查更新...';
  @override
  String get cancel => '取消';
  @override
  String get obnovlenie_7e32 => '更新';
  @override
  String get obnovleniePrilozheniya_b6c3 => '应用程序更新';
  @override
  String get podgotovkaKZagruzke_a5c7 => '正在准备下载...';
  @override
  String get ustanovkaZapuschena_d378 => '安装已经开始！';
  @override
  String get dostupnaNovayaVersiyaPrilozheniya_eeae => '新版本的应用程序可用';
  @override
  String get chtoNovogo_74e2 => '新消息';
  @override
  String get ofitsialnoeOpisanieRelizaDostupnoNa_3ea3 =>
      '官方发布说明可在 GitHub 页面上找到。';
  @override
  String get istochnikZagruzki_0e6e => '下载源码';
  @override
  String get pryamayaUstanovkaVPrilozhenii_16f5 => '直接安装在应用程序中';
  @override
  String get avtomaticheskoeSkachivanieIZapusk_9a3f => '自动下载并启动';
  @override
  String get stranitsaRelizaNaGithub_1531 => 'GitHub 上的发布页面';
  @override
  String get propustit_03ee => '跳过';
  @override
  String get ustanovka_516d => '安装...';
  @override
  String get obnovit_dbe5 => '更新';
  @override
  String get lichnyeDannye_be85 => '个人信息';
  @override
  String get imyaNikneymFotoProfilya_28ac => '姓名、昵称、个人资料照片';
  @override
  String get privatnost_0899 => '隐私';
  @override
  String get ktoMozhetPisatZvonitVidet_1789 => '谁可以写信、打电话、查看个人资料';
  @override
  String get nastroykiChatov_7ca8 => '聊天设置';
  @override
  String get uvedomleniyaTemyIstoriya_51da => '通知、主题、历史记录';
  @override
  String get kontakty_7576 => '联系方式';
  @override
  String get vashiSohranennyeKontakty_a641 => '您保存的联系人';
  @override
  String get bezopasnost_3677 => '安全性';
  @override
  String get sessiiParolAutentifikatsiya_73f5 => '会话、密码、身份验证';
  @override
  String get vneshniyVid_6873 => '外观';
  @override
  String get temaShriftMasshtab_d8c9 => '主题、字体、比例';
  @override
  String get yazyk_0577 => '语言';
  @override
  String get yazykInterfeysaKlienta_2ad3 => '客户端界面语言';
  @override
  String get uvedomleniya_d2ed => '通知';
  @override
  String get zvukiBannery_1b60 => '声音、横幅';
  @override
  String get energosberezhenie_0b19 => '节能';
  @override
  String get animatsiiIProizvoditelnost_fba8 => '动画和表演';
  @override
  String get oPrilozhenii_322e => '关于申请';
  @override
  String get versiyaProverkaObnovleniySsylki_6efc => '版本、检查更新、链接';
  @override
  String get nastroyki_b01b => '设置';
  @override
  String get nastroyki_c919 => '设置';
  @override
  String get proverkaObnovleniy_f3e0 => '正在检查更新...';
  @override
  String get neUdalosZagruzitNastroyki_f753 => '无法加载设置';
  @override
  String get oshibkaSohraneniya_0387 => '保存错误';
  @override
  String get dannyeSohraneny_fd62 => '数据已保存';
  @override
  String get gost_9618 => '嘉宾';
  @override
  String get akkaunt_38ac => '帐户';
  @override
  String get interfeys_49be => '接口';
  @override
  String get vyytiIzAkkaunta_6d41 => '退出您的帐户';
  @override
  String get informatsiyaOPrilozhenii_00c4 => '申请信息';
  @override
  String get versiya1001LinuxWindowsMacos_ff6c =>
      '版本：1.0.loc_0+1（Linux / Windows / macOS）';
  @override
  String get proverka_13bc => '正在检查...';
  @override
  String get proveritObnovleniya_ab45 => '检查更新';
  @override
  String get osnovnayaInformatsiya_6fec => '基本信息';
  @override
  String get imya_d38d => '名称';
  @override
  String get vvediteVasheImya_751e => '输入你的名字';
  @override
  @override
  String get nikneym_3fea => '用户名';
  @override
  String get nikneymNelzyaIzmenitVPrilozhenii_75d0 => '无法在应用程序中更改昵称';
  @override
  String get oSebe_0b3b => '关于我';
  @override
  String get rasskazhiteOSebe_1c37 => '告诉我们你自己...';
  @override
  String get sohranenie_c15f => '正在保存...';
  @override
  String get sohranit_74ea => '保存';
  @override
  @override
  String get vse_984b => '全部';
  @override
  String get tolkoKontakty_a559 => '仅联系人';
  @override
  String get nikto_ba19 => '没有人';
  @override
  String get kommunikatsii_1242 => '通讯';
  @override
  String get ktoMozhetPisatSoobscheniya_4645 => '谁可以写消息';
  @override
  String get ktoMozhetZvonit_c427 => '谁可以打电话';
  @override
  String get ktoMozhetZapisyvatGolosovye_c69a => '谁可以录制声音';
  @override
  String get ktoMozhetOtpravlyatFayly_2e40 => '谁可以发送文件';
  @override
  String get ktoMozhetPriglashatVGruppy_cdc0 => '谁可以邀请加入群组';
  @override
  String get vidimostProfilya_34bf => '个人资料可见性';
  @override
  String get ktoViditMoyNikneym_54b8 => '谁看到我的昵称';
  @override
  String get ktoViditMoyAvatar_e9f6 => '谁能看到我的头像';
  @override
  String get ktoViditMoyDenRozhdeniya_ccc7 => '谁看到我的生日';
  @override
  String get ktoViditVremyaMoeyAktivnosti_4349 => '谁看到我的活动时间';
  @override
  String get neUdalosZagruzitKontakty_02a3 => '加载联系人失败';
  @override
  String get dobavitKontakt_4278 => '添加联系人';
  @override
  String get nikneymPolzovatelya_5610 => '用户昵称';
  @override
  String get otobrazhaemoeImyaOptsionalno_bbd1 => '显示名称（可选）';
  @override
  @override
  String get otmena_987b => '取消';
  @override
  String get dobavit_5eba => '添加';
  @override
  String get uVasPokaNetSohranennyh_b64b => '您还没有任何已保存的联系人';
  @override
  String get pozvonit_ccfa => '致电';
  @override
  String get napisat_0144 => '写';
  @override
  String get udalitKontakt_065d => '删除联系人';
  @override
  String get soobscheniya_7e26 => '留言';
  @override
  String get animatsiiSoobscheniy_bc8b => '消息动画';
  @override
  String get pokazyvatAnimatsiiPriOtpravkeI_d663 => '发送和接收时显示动画';
  @override
  String get arhivirovannyeChaty_d990 => '存档的聊天记录';
  @override
  String get upravlenieArhivom_e843 => '档案管理';
  @override
  String get ochistitIstoriyu_837a => '清除历史记录';
  @override
  String get udalitVseSoobscheniyaLokalno_fbbd => '删除本地所有消息';
  @override
  String get aktivnyeSessii_5c96 => '活跃会话';
  @override
  String get etoUstroystvo_26f6 => '这个装置';
  @override
  String get xaneoPcAktivnoSeychas_25b4 => 'Xaneo PC • 现已启用';
  @override
  String get aktivno_87a4 => '活跃';
  @override
  String get dvoynayaAutentifikatsiya_66ae => '双重认证';
  @override
  String get zaschitaAkkauntaOdnorazovymParolem_e9f1 => '使用一次性密码保护帐户';
  @override
  String get opasnayaZona_25bc => '危险区域';
  @override
  String get udalitAkkaunt_05c7 => '删除帐户';
  @override
  String get neobratimoeDeystvie_7232 => '不可逆转的行动';
  @override
  String get tema_9e26 => '主题';
  @override
  String get temnayaTema_cb48 => '深色主题';
  @override
  String get pereklyuchitMezhduTemnymISvetlym_5415 => '在深色和浅色模式之间切换';
  @override
  String get razmerShrifta_1155 => '字体大小';
  @override
  String get a_87a0 => '一个';
  @override
  String get pokazyvatVsplyvayuschieUvedomleniya_754e => '显示弹出通知';
  @override
  String get zvuk_9329 => '声音';
  @override
  String get vosproizvoditZvukPriNovomSoobschenii_47cc => '新消息播放声音';
  @override
  String get osnovnyeNastroyki_231c => '基本设置';
  @override
  String get rezhimEkonomiiEnergii_edfc => '省电模式';
  @override
  String get optimiziruetRabotuPrilozheniyaDlyaEkonomii_d9eb => '优化应用程序性能以节省资源';
  @override
  String get avtomaticheskiySpyaschiyRezhim_5955 => '自动睡眠模式';
  @override
  String get perevoditPrilozhenieVSpyaschiyRezhim_1c07 => '当应用程序不活动时将其置于睡眠模式';
  @override
  String get animatsii_05c7 => '动画';
  @override
  String get uproschennyeAnimatsii_3a13 => '简化的动画';
  @override
  String get umenshaetKolichestvoAnimatsiyInterfeysa_6bf1 => '减少界面动画数量';
  @override
  String get skoroBudetDostupno_de07 => '即将推出';
  @override
  String get gostevoyRezhim_6d82 => '访客模式';
  @override
  String get voyditeDlyaDostupaKAkkauntu_a5c8 => '登录以访问您的帐户';
  @override
  String get nazhmiteDlyaProsmotraIzmeneniy_0255 => '点击查看更改';
  @override
  String get vvediteKodPodtverzhdeniya_61af => '输入验证码';
  @override
  @override
  String get nevernyyKodPodtverzhdeniya_7762 => '验证码错误';
  @override
  String get podtverditeEMail_4bd4 => '确认您的电子邮件';
  @override
  String get proverit_340b => '检查';
  @override
  @override
  String get otpravitKodPovtorno_7703 => '重新发送验证码';
  @override
  String get sovremennoeDesktopnoePrilozheniensKrasivymInterfeysom_8a4e =>
      '现代桌面应用程序\n具有漂亮的界面和3D效果';
  @override
  String get tehnologii_6332 => '技术';
  @override
  String get vyNashliPashalku_1a57 => '🎉 你发现了一个复活节彩蛋！ 🎉';
  @override
  String get spasiboZaIspolzovanieXaneo_d079 => '感谢您使用 xaneo！';
  @override
  String get globalnyyPoisk_77bf => '全球搜索';
  @override
  @override
  String get poiskKontaktovChatovKanalovBotov_db66 => '搜索联系人、群组、频道、机器人...';
  @override
  @override
  String get lyudi_c7ae => '用户';
  @override
  @override
  String get gruppy_ebc4 => '群组';
  @override
  @override
  String get kanaly_0c11 => '频道';
  @override
  @override
  String get boty_d6e4 => '机器人';
  @override
  @override
  String get izbrannoe_2fc4 => '收藏夹';
  @override
  @override
  String get vvediteZaprosDlyaPoiskaPo_9955 => '输入关键词在 Xaneo 网络中搜索';
  @override
  @override
  String get nichegoNeNaydeno_8767 => '未找到相关结果';
  @override
  @override
  String get izbrannoe_b637 => '收藏夹';
  @override
  @override
  String get boty_800d => '机器人';
  @override
  @override
  String get kanaly_ccec => '频道';
  @override
  @override
  String get gruppy_cfd6 => '群组';
  @override
  @override
  String get polzovateli_e0ec => '用户';
  @override
  @override
  String get sohranennyeSoobscheniya_6b62 => '已保存的消息';
  @override
  @override
  String get bot_0ae1 => '机器人';
  @override
  @override
  String get bot_0f46 => 'bot';
  @override
  @override
  String get gruppa_99d9 => '群组';
  @override
  @override
  String get kanal_2710 => '频道';
  @override
  String get versiya_3725 => '版本';
  @override
  String get tehnicheskayaInformatsiya_ba0f => '技术资料';
  @override
  String get platforma_8848 => '平台';
  @override
  String get arhitekturaProtsessora_c079 => '处理器架构';
  @override
  String get posmotretNaGithub_5238 => '在 GitHub 上查看';
  @override
  String get zakryt_dd94 => '关闭';
  @override
  String get vklyuchitTemnuyuTemu_ed17 => '启用深色主题';
  @override
  String get vklyuchitUvedomleniya_d311 => '启用通知';
  @override
  String get kastomnyyOverleyXaneo_7d39 => '定制 Xaneo 覆盖层';
  @override
  String get animirovannyeUvedomleniyaSBystrymOtvetom_a25d => '具有快速响应的动画通知';
  @override
  String get aaBbVv_1c6b => '啊 bb bb';
  @override
  String get pleylist_a04c => '播放列表';
  @override
  String get spisokMuzyki_d477 => '音乐列表';
  @override
  String get loc_0B_5a4d => '0乙';
  @override
  String get b_3b67 => '乙';
  @override
  String get kb_419d => '知识库';
  @override
  String get mb_b808 => 'MB';
  @override
  String get gb_e572 => '国标';
  @override
  String get audiozapis_867d => '录音';
  @override
  String get muzykalnyyTrek_b15d => '音乐曲目';
  @override
  String get muzykalnyeTrekiOtsutstvuyut_3301 => '没有音乐曲目';
  @override
  @override
  String get nikneymUzheZanyat_59aa => '用户名已被占用';
  @override
  @override
  String get oshibkaProverki_2ab0 => '验证失败';
  @override
  @override
  String get emailUzheZanyat_17e1 => '邮箱已被注册';
  @override
  @override
  String get oshibkaOtpravkiKoda_a42a => '发送验证码失败';
  @override
  @override
  String get neobhodimoPrinyatUsloviyaISoglasie_e31e => '必须同意使用条款及隐私协议';
  @override
  @override
  String get registratsiyaUspeshna_9d5c => '注册成功！';
  @override
  @override
  String get oshibkaRegistratsii_b9f2 => '注册失败';
  @override
  @override
  String get nazad_2b0b => '返回';
  @override
  @override
  String get kakVasZovut_68b7 => '您叫什么名字？';
  @override
  @override
  String get kogdaVyRodilis_26f2 => '您的出生日期？';
  @override
  @override
  String get pridumayteNikneym_221b => '设置用户名';
  @override
  @override
  String get vashEmail_8bbd => '您的邮箱';
  @override
  @override
  String get podtverzhdenieEmail_281f => '邮箱验证';
  @override
  @override
  String get sozdayteParol_5f4c => '创建密码';
  @override
  @override
  String get podtverzhdenieParolya_ebc2 => '确认密码';
  @override
  @override
  String get dobavteFoto_25eb => '添加头像';
  @override
  @override
  String get posledniyShag_e0c5 => '最后一步';
  @override
  @override
  String get vvediteVasheNastoyascheeImya_e656 => '请输入您的真实姓名';
  @override
  @override
  String get vamDolzhnoBytNeMenee_1111 => '您必须年满 13 岁';
  @override
  @override
  String get nikneymDolzhenBytUnikalnym_952d => '用户名必须唯一';
  @override
  @override
  String get myOtpravimKodPodtverzhdeniya_fc71 => '我们将发送验证码至您的邮箱';
  @override
  @override
  String get vvedite6ZnachnyyKodIz_f22f => '请输入邮件中的 6 位验证码';
  @override
  @override
  String get pridumayteNadezhnyyParol_2312 => '设置强密码（至少 8 个字符）';
  @override
  @override
  String get povtoriteParolEscheRaz_6723 => '请再次输入密码';
  @override
  @override
  String get etoNeobyazatelnoNoPriyatno_b6a3 => '此项可选，但有助于朋友识别您';
  @override
  @override
  String get proverteVashiDannyeIPrimite_3121 => '请核对您的信息并同意条款';
  @override
  @override
  String get registratsiya_0b93 => '注册';
  @override
  @override
  String get vasheImya_51eb => '您的名字';
  @override
  @override
  @override
  String get proverkaDostupnosti_da13 => '正在检查可用性...';
  @override
  @override
  @override
  String get nikneymDostupen_3fc9 => '用户名可用';
  @override
  @override
  @override
  String get nikneymZanyat_8a5f => '用户名已被占用';
  @override
  @override
  @override
  String get emailDostupen_e903 => '邮箱可用';
  @override
  @override
  @override
  String get emailZanyat_fb40 => '邮箱已被注册';
  @override
  @override
  String get kodPodtverzhdeniya_1c9d => '验证码';
  @override
  @override
  String get parol_5ebe => '密码';
  @override
  @override
  String get podtverditeParol_e3e3 => '确认密码';
  @override
  @override
  String get nazhmiteChtobyDobavitFoto_d6e8 => '点击添加照片';
  @override
  @override
  String get udalitFoto_3426 => '删除照片';
  @override
  @override
  String get yaPrinimayuUsloviyaIspolzovaniya_391a => '我接受使用条款';
  @override
  @override
  String get yaSoglasenNaObrabotkuPersonalnyh_f2a8 => '我同意个人信息处理协议';
  @override
  @override
  String get zavershit_b0e3 => '完成注册';
  @override
  @override
  String get dalee_c453 => '下一步';
  @override
  @override
  String get dataRozhdeniya_505e => '出生日期';
  @override
  String get vklyuchitTemnuyuTemuOformleniya_86c4 => '启用深色主题';
  @override
  @override
  String get yanvar_ee86 => '一月';
  @override
  @override
  String get fevral_28ff => '二月';
  @override
  @override
  String get mart_d766 => '三月';
  @override
  @override
  String get aprel_03e9 => '四月';
  @override
  @override
  String get may_2e53 => '五月';
  @override
  @override
  String get iyun_cfcb => '六月';
  @override
  @override
  String get iyul_89fb => '七月';
  @override
  @override
  String get avgust_de5a => '八月';
  @override
  @override
  String get sentyabr_ebfb => '九月';
  @override
  @override
  String get oktyabr_1720 => '十月';
  @override
  @override
  String get noyabr_66fb => '十一月';
  @override
  @override
  String get dekabr_39b3 => '十二月';
  @override
  @override
  String get pn_2c1e => '周一';
  @override
  @override
  String get vt_7145 => '周二';
  @override
  @override
  String get sr_c6e4 => '周三';
  @override
  @override
  String get cht_a51f => '周四';
  @override
  @override
  String get pt_0123 => '周五';
  @override
  @override
  String get sb_3a4b => '周六';
  @override
  @override
  String get vs_4ad9 => '周日';
  @override
  @override
  String get gotovo_34e1 => '完成';
  @override
  String get oshibkaVosstanovleniyaKlyucheyNeUdalos_fe7b => '密钥恢复错误（覆盖失败）';
  @override
  String get kriticheskayaOshibkaPriPeresozdaniiKlyuchey_b6d7 =>
      '重新生成加密密钥时出现严重错误';
  @override
  String get oshibkaZagruzkiKlyucheyNaServer_ff9b => '将密钥加载到服务器时出错';
  @override
  String get oshibkaPriPolucheniiKlyucheyShifrovaniya_9bb4 => '检索加密密钥时出错';
  @override
  String get prevyshenLimitV5Akkauntov_a6a9 => '已超出此客户端上 5 个帐户的限制或存在连接错误。';
  @override
  @override
  @override
  String get oshibkaAvtorizatsii_9f5c => '身份验证错误';
  @override
  @override
  @override
  String get oshibkaPodklyucheniyaKServeru_8b96 => '服务器连接错误';
  @override
  @override
  String get nazadKMessendzheru_de29 => '返回消息列表';
  @override
  @override
  String get voytiVAkkaunt_c439 => '登录账号';
  @override
  @override
  String get vvediteParol_1370 => '请输入密码';
  @override
  @override
  String get vvediteSvoiDannyeDlyaDostupa_319e => '请输入您的账号信息以访问消息。';
  @override
  @override
  String get voyti_63a7 => '登录';
  @override
  String get sobesednik_7025 => '对话者';
  @override
  String get vy_0101 => '你';
  @override
  String get vyDelitesSvoimEkranom_16b1 => '您共享您的屏幕';
  @override
  String get polzovatel_f154 => '用户';
  @override
  String get ishodyaschiyVyzov_650b => '拨出电话...';
  @override
  String get vhodyaschiyVyzov_19ff => '来电...';
  @override
  String get podklyucheno_d022 => '已连接';
  @override
  String get ozhidanieOtveta_a984 => '正在等待回复...';
  @override
  String get razgovorPoAudiosvyazi_3ed7 => '音频对话';
  @override
  String get translyatsiyaVashegoEkranaZapuschena_575a => '您的截屏视频已开始';
  @override
  String get sobesednikViditVseChtoProishodit_c759 => '对话者可以看到您桌面上发生的一切';
  @override
  String get vhodyaschiyVyzov_905e => '来电';
  @override
  String get neizvestnyy_be89 => '未知';
  @override
  String get videozvonok_dd18 => '视频通话...';
  @override
  String get golosovoyZvonok_5410 => '语音通话...';
  @override
  String get otklonit_8b0d => '拒绝';
  @override
  String get otvetit_e568 => '回复';
  @override
  String get gruppovoyZvonok_dac1 => '群组通话';
  @override
  String get podklyuchenieKZvonku_e2cf => '正在连接呼叫...';
  @override
  String get podklyuchenieKVeschaniyu_038b => '正在连接广播...';
  @override
  String get uchastnik_cffb => '会员';
  @override
  String get vy_479c => '你';
  @override
  String get svernut_ca9f => '崩溃';
  @override
  String get vhodyaschiyVyzov_d2f3 => '来电';
  @override
  String get novoeSoobschenie_1d49 => '新消息';
  @override
  String get vashOtvet_40c2 => '你的答案...';
  @override
  String get videovyzov_3353 => '视频通话...';
  @override
  String get audiovyzov_bbb5 => '音频通话...';
  @override
  String get nachatZvonok_3d26 => '开始通话';
  @override
  String get golosovoyZvonok_b615 => '语音通话';
  @override
  String get pozvonitPoGolosovoySvyazi_4069 => '拨打语音电话';
  @override
  String get videozvonok_8142 => '视频通话';
  @override
  String get pozvonitSVklyuchennoyKameroy_fb05 => '打开相机通话';
  @override
  String get zashifrovannoeSoobschenie_ca35 => '[加密消息]';
  @override
  String get golosovoeSoobschenie_4a85 => '🎤 语音留言';
  @override
  String get videosoobschenie_d687 => '🎬视频留言';
  @override
  String get fayl_826d => '📎 文件';
  @override
  String get zvonok_e8d5 => '📞 致电';
  @override
  String get oshibkaDeshifrovaniya_4146 => '[解密错误]';
  @override
  String get zapisyvaetGolosovoe_2a5c => '录制语音...';
  @override
  String get pechataet_812c => '打印...';
  @override
  String get neUdalosArhivirovatChat_ab89 => '无法存档聊天记录';
  @override
  String get neUdalosRazarhivirovatChat_f0d7 => '无法取消存档聊天记录';
  @override
  String get arhiv_56aa => '存档';
  @override
  String get netUserid_634a => '[无用户ID]';
  @override
  String get netKlyucha_337b => '[无钥匙]';
  @override
  String get neizvestnyyTipChata_2617 => '[未知聊天类型]';
  @override
  String get neUdalosPoluchitKlyuchShifrovaniya_b953 => '无法获取聊天加密密钥';
  @override
  String get gruppa_19c2 => '组';
  @override
  String get uchastnik_5bce => '参与者';
  @override
  String get uchastnika_92d9 => '参与者';
  @override
  String get uchastnikov_5d6b => '参与者';
  @override
  String get kanal_64ec => '频道';
  @override
  String get podpischik_695a => '订户';
  @override
  String get podpischika_b490 => '订户';
  @override
  String get podpischikov_ba39 => '订户';
  @override
  String get segodnya_9626 => '今天';
  @override
  String get vchera_61d4 => '昨天';
  @override
  String get yanvarya_d861 => '一月';
  @override
  String get fevralya_fcf9 => '二月';
  @override
  String get marta_bb77 => '三月';
  @override
  String get aprelya_2b5a => '四月';
  @override
  String get maya_4dbb => '五月';
  @override
  String get iyunya_adcb => '六月';
  @override
  String get iyulya_3236 => '七月';
  @override
  String get avgusta_e3aa => '八月';
  @override
  String get sentyabrya_a146 => '九月';
  @override
  String get oktyabrya_7abd => '十月';
  @override
  String get noyabrya_6e78 => '十一月';
  @override
  String get dekabrya_29cc => '十二月';
  @override
  String get vyPodpisalisNaKanal_b2b3 => '您已订阅该频道';
  @override
  String get vyPrisoedinilisKGruppe_07bd => '您已加入群组';
  @override
  String get neUdalosPrisoedinitsya_31e6 => '加入失败';
  @override
  String get vyOtpisalisOtKanala_7698 => '您已取消订阅该频道';
  @override
  String get vyPokinuliGruppu_5a52 => '你离开了群组';
  @override
  String get neUdalosVypolnitDeystvie_3cfd => '操作失败';
  @override
  String get neUdalosPereklyuchitAkkaunt_968b => '切换账号失败';
  @override
  String get media_c247 => '媒体';
  @override
  String get fayly_200c => '文件';
  @override
  String get golos_2d89 => '语音';
  @override
  String get ssylki_9f58 => '友情链接';
  @override
  String get profil_c62a => '公司简介';
  @override
  String get imyaPolzovatelya_6fd4 => '用户名';
  @override
  String get denRozhdeniya_e41d => '生日';
  @override
  String get polzovatelSkrylInformatsiyuOSebe_f416 => '用户隐藏了有关自己的信息';
  @override
  String get god_6270 => '年';
  @override
  String get goda_7443 => '年';
  @override
  String get let_257a => '年';
  @override
  String get skopirovano_f70b => '已复制';
  @override
  String get akkaunty_80b5 => '账户';
  @override
  String get dobavitAkkaunt_5253 => '添加账户';
  @override
  String get limit5Akkauntov_fdb7 => '限制：5个账户';
  @override
  String get nazadKChatam_7edb => '返回聊天';
  @override
  String get chaty_19ad => '聊天记录';
  @override
  String get globalnyyPoisk_7ff2 => '全球搜索';
  @override
  String get arhivPust_3e22 => '存档为空';
  @override
  String get netSoobscheniy_29d4 => '没有消息';
  @override
  String get toDoList_27e1 => '📋 待办事项表';
  @override
  String get opros_6ff1 => '🗳️投票';
  @override
  String get fotografiya_5709 => '📷摄影';
  @override
  String get razarhivirovat_416b => '解压';
  @override
  String get vArhiv_ce22 => '到档案馆';
  @override
  String get chat_c52b => '聊天';
  @override
  String get vyberiteChatDlyaNachalaObscheniya_36a5 => '选择聊天开始聊天';
  @override
  String get bot_2712 => '机器人';
  @override
  String get vSeti_d902 => '在线';
  @override
  String get neVSeti_ee01 => '离线';
  @override
  String get nastroykiChata_1e0d => '聊天设置';
  @override
  String get pokinutGruppu_e6ce => '离开群组';
  @override
  String get prisoedinitsyaKGruppe_eb45 => '加入群组';
  @override
  String get otpisatsyaOtKanala_fdbc => '取消订阅频道';
  @override
  String get podpisatsyaNaKanal_2dad => '订阅频道';
  @override
  String get netSoobscheniyNapishiteChtoNibud_2bf4 => '暂无消息。写点什么吧！';
  @override
  String get prisoedinilsyaKChatu_f623 => '加入聊天';
  @override
  String get pokinulChat_d567 => '离开聊天室';
  @override
  String get podpisalsyaNaKanal_0673 => '订阅频道';
  @override
  String get otpisalsyaOtKanala_fa13 => '取消订阅频道';
  @override
  String get polzovatelya_1083 => '用户';
  @override
  String get priglasil_47ae => '邀请';
  @override
  String get rasshifrovka_e47f => '[文字记录...]';
  @override
  String get sistemnoeSoobschenie_d2bd => '系统消息';
  @override
  String get soobschenie_3715 => '留言';
  @override
  String get videosoobschenie_57f1 => '📹视频留言';
  @override
  String get spisokZadach_cfa4 => '📋 任务清单';
  @override
  String get opros_5902 => '📊 民意调查';
  @override
  String get vlozhenie_ef44 => '附件';
  @override
  String get fayl_2d46 => '文件';
  @override
  String get zagruzkaFayla_f817 => '正在加载文件...';
  @override
  String get ishodyaschiyZvonok_8381 => '拨出电话';
  @override
  String get razgovorNeSostoyalsya_67fb => '谈话没有发生';
  @override
  String get vhodyaschiyZvonok_5ce9 => '来电';
  @override
  String get otklonennyyZvonok_d499 => '被拒接电话';
  @override
  String get vyOtkloniliVyzov_8d1d => '您拒绝接听电话';
  @override
  String get propuschennyyZvonok_e98d => '未接来电';
  @override
  String get vyPropustiliVyzov_f17a => '你错过了电话';
  @override
  String get vlozhenie_2474 => '📎 附件';
  @override
  String get tb_0e05 => '结核病';
  @override
  String get zapisGolosovogo_9c91 => '录音...';
  @override
  String get zapisVideo_dd2a => '视频录制...';
  @override
  String get otpustiteDlyaOtpravki_ea7b => '释放发送';
  @override
  String get emodzi_f822 => '表情符号';
  @override
  String get panelEmodziVRazrabotke_b6ce => '表情符号面板正在开发中';
  @override
  String get napisatSoobschenie_62d4 => '写留言...';
  @override
  String get dobavitVlozhenie_769b => '添加附件';
  @override
  String get spisokZadach_1852 => '任务清单';
  @override
  String get opros_9f36 => '民意调查';
  @override
  String get zapisGolosovogoGs_db4e => '录音 (VO)';
  @override
  String get zapisVideoVs_9676 => '视频录制（VS）';
  @override
  String get uderzhivayteKnopkuDlyaZapisinNazhmite_3ab3 =>
      '•按住按钮进行录音\n• 按此键切换模式';
  @override
  @override
  String get novyyChat_f775 => '新建聊天';
  @override
  @override
  String get imyaPolzovatelyaMin5Simvolov_1232 => '用户名（至少 5 个字符）';
  @override
  @override
  String get vvedite5IliBoleeSimvolov_f983 => '请输入 5 个或更多字符';
  @override
  @override
  String get polzovateliNeNaydeny_c01a => '未找到用户';
  @override
  String get mnozhestvennyyVybor_9b60 => '多项选择';
  @override
  String get odinochnyyVybor_d920 => '单选';
  @override
  String get netGolosov_17d0 => '没有投票';
  @override
  String get golos_6b94 => '声音';
  @override
  String get golosa_bb8d => '声音';
  @override
  String get golosov_7f51 => '投票';
  @override
  String get nePoluchenIdFaylaOt_86c8 => '未从服务器收到文件 ID';
  @override
  String get faylZagruzhenIPrikreplen_dc24 => '文件已上传并附加';
  @override
  String get neizvestnayaOshibkaZagruzki_68cb => '未知下载错误';
  @override
  String get oshibkaZagruzkiFayla_86e5 => '文件下载错误';
  @override
  String get sohranitFaylKak_0f93 => '将文件另存为';
  @override
  String get oshibkaSkachivaniyaFayla_34ac => '文件下载错误';
  @override
  String get bezNazvaniya_6584 => '无题';
  @override
  String get bezVoprosa_d390 => '没问题';
  @override
  String get netDostupaKMikrofonu_a4ef => '无法访问麦克风';
  @override
  String get zapisVideoCherezPlaginCamera_b9dd => '📹 相机插件视频录制已开始';
  @override
  String get kameraNeInitsializirovanaNaEtoy_21e0 => '📹 该平台上相机未初始化。';
  @override
  String get kameraNeGotova_9f09 => '相机未准备好';
  @override
  String get zapisVideosoobscheniyaNaEtoyPlatforme_a561 => '📹 本平台无法直接录制视频消息。';
  @override
  String get arecordOstanovlen_edf2 => '🎙️一条记录已被停止';
  @override
  String get ffmpegOstanovlen_63a0 => '📹 ffmpeg 停止了';
  @override
  String get zapisSlishkomKorotkaya_5cda => '条目太短';
  @override
  String get oshibkaZapisiFaylPust_106b => '写入错误：文件为空';
  @override
  String get videosoobschenieOtpravlenoSimulyatsiya_fb29 => '发送视频消息（模拟）';
  @override
  String get zapisOtmenena_1609 => '注册已取消';
  @override
  String get otpravitGolosovoeSoobschenie_2481 => '发送语音消息';
  @override
  String get imitatsiyaZapisiGolosovogoSoobscheniya_81e7 => '模拟录制语音消息。';
  @override
  String get otpravit_6da0 => '发送';
  @override
  String get sozdatToDo_8c92 => '创建待办事项';
  @override
  String get nazvanieSpiska_c3cc => '名单名称';
  @override
  String get punkty_0481 => '项目：';
  @override
  String get dobavitPunkt_930c => '添加项目';
  @override
  String get sozdat_b059 => '创建';
  @override
  String get sozdatOpros_4b9e => '创建调查';
  @override
  String get vopros_0911 => '问题';
  @override
  String get variantyOtveta_ef4e => '答案选项：';
  @override
  String get dobavitVariant_76be => '添加一个选项';
  @override
  String get golosovoeSoobschenie_33d5 => '语音留言';
  @override
  String get videosoobschenie_2951 => '视频留言';
  @override
  String get video_a095 => '视频';
  @override
  String get neUdalosZagruzitIzobrazhenie_3fa0 => '加载图像失败';
  @override
  String get muzyka_0660 => '音乐';
  @override
  String get netDannyh_dee9 => '无数据';
  @override
  String get istoriyaSoobscheniyPustaIliChat_2d07 => '消息记录为空或聊天内容尚未保存到本地';
  @override
  String get obschieMaterialy_11e4 => '一般材料';
  @override
  String get netMediafaylov_08d2 => '没有媒体文件';
  @override
  String get zdesBudutOtobrazhatsyaObschieFoto_9bc7 => '共享的照片和视频将显示在这里';
  @override
  String get netFaylov_e95e => '没有文件';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c => '上传的文件将显示在这里';
  @override
  String get netGolosovyhSoobscheniy_2427 => '没有语音留言';
  @override
  String get zdesBudutOtobrazhatsyaGolosovyeI_0a73 => '此处将显示语音和视频消息';
  @override
  String get netSsylok_b0ec => '没有链接';
  @override
  String get zdesBudutOtobrazhatsyaObschieSsylki_6b61 => '一般链接将出现在这里';
  @override
  String get ssylkaSkopirovanaVBufer_c16e => '链接已复制到剪贴板';
  @override
  String get netMuzyki_1ca3 => '没有音乐';
  @override
  String get zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23 => '提交的曲目将显示在此处';
  @override
  String get udalennyyAkkaunt_ce47 => '已删除帐户';
  @override
  String get opisanie_38ca => '描述';
  @override
  String get mobilnyy_5ac7 => '手机';
  @override
  String get bylANedavno_168d => '是最近';
  @override
  String get minutu_5373 => '分钟';
  @override
  String get minuty_5bc9 => '分钟';
  @override
  String get minut_b877 => '分钟';
  @override
  String get nazhmiteChtobyZagruzitNovuyuVersiyu_8b2a => '点击下载新版本';
  @override
  String get poiskLyudeyBotovGrupp_e84e => '搜索人员、机器人、群组...';
  @override
  String get vveditePoiskovyyZapros_0b8c => '输入您的搜索词';
  @override
  String get polzovateli_b8c4 => '用户';
  @override
  String get moiLichnyeSoobscheniya_7d3b => '我的个人留言';
  @override
  String get sozdatNovyyChat_fd41 => '创建新聊天';
  @override
  String get lichnyyChat_cbec => '个人聊天';
  @override
  String get nachatObschenieSPolzovatelem_0578 => '与用户开始对话';
  @override
  String get sozdatGruppu_459f => '创建一个群组';
  @override
  String get gruppovoyChatDlyaObscheniyaS_01ba => '群聊与朋友交流';
  @override
  String get sozdatKanal_9022 => '创建频道';
  @override
  String get kanalDlyaShirokoyAuditorii_9dba => '面向广泛受众的频道';
  @override
  String get redaktirovanie_1167 => '编辑';
  @override
  String get vlevo_1af1 => '左';
  @override
  String get vpravo_c316 => '右';
  @override
  String get poGor_ff50 => '沿着山';
  @override
  String get poVert_b4a9 => '垂直。';
  @override
  String get vvediteNazvanieGruppy_0a69 => '输入群组名称';
  @override
  String get dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0 =>
      '公共群组需要昵称（@username）';
  @override
  String get gruppaSozdana_6b3b => '群组已创建';
  @override
  String get oshibkaPriSozdaniiGruppy_794e => '创建群组时出错';
  @override
  String get nazhmiteNaIkonkuChtobyVybrat_af03 => '点击图标选择头像';
  @override
  String get nazvanieGruppy_9a39 => '团体名称';
  @override
  String get opisanieNeobyazatelno_7812 => '说明（可选）';
  @override
  String get privatnayaGruppa_d20e => '私人团体';
  @override
  String get publichnayaGruppa_50f8 => '公众组';
  @override
  String get vhodTolkoPoPriglasheniyu_97a1 => '仅限受邀人士入场';
  @override
  String get lyuboyMozhetNaytiIVstupit_5e26 => '任何人都可以找到并加入';
  @override
  String get publichnayaSsylkanikneymMyGroup_6640 => '公共链接/昵称 (@my_group)';
  @override
  String get vvediteNazvanieKanala_5536 => '输入频道名称';
  @override
  String get dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06 =>
      '公共频道需要链接/昵称 (@mychannel)';
  @override
  String get kanalSozdan_1522 => '频道已创建';
  @override
  String get oshibkaPriSozdaniiKanala_7d4b => '创建频道时出错';
  @override
  String get nazvanieKanala_c548 => '频道名称';
  @override
  String get privatnyyKanal_3139 => '私人频道';
  @override
  String get publichnyyKanal_0f7c => '公共频道';
  @override
  String get podpiskaTolkoPoPriglasheniyu_99c3 => '仅限邀请订阅';
  @override
  String get lyuboyMozhetNaytiIPodpisatsya_8579 => '任何人都可以找到并订阅';
  @override
  String get ssylkanikneymKanalaMychannel_79f6 => '频道链接/昵称 (@mychannel)';
  @override
  String get yazykInterfeysa_b78b => '界面语言';
  @override
  String get dannyeUspeshnoSohraneny_2cc5 => '数据保存成功';
  @override
  String get oshibkaPriSohranenii_126f => '保存时出错';
  @override
  String get lichnyeDannye_10a7 => '个人资料';
  @override
  String get nikneymUsername_8035 => '昵称（@用户名）';
  @override
  String get nikneymNelzyaIzmenit_0b99 => '昵称无法更改';
  @override
  String get oSebeBio_b730 => '关于我（简介）';
  @override
  String get rasskazhiteNemnogoOSebe_3daa => '告诉我们一些关于你自己的事......';
  @override
  String get nastroykiPrivatnostiSohraneny_447c => '已保存隐私设置';
  @override
  String get privatnost_3098 => '隐私';
  @override
  String get kommunikatsii_e9b8 => '通讯';
  @override
  String get ktoMozhetPisat_3322 => '谁可以写';
  @override
  String get zapisGolosovyh_8073 => '录音';
  @override
  String get otpravkaFaylov_aaca => '发送文件';
  @override
  String get priglashatVGruppy_3631 => '邀请加入群组';
  @override
  String get vidimostProfilya_448f => '个人资料可见度';
  @override
  String get ktoViditAvatar_b5d8 => '谁能看到头像';
  @override
  String get vremyaVSeti_be29 => '在线时间';
  @override
  String get vneshniyVid_5a0f => '外观';
  @override
  String get rezhimOformleniyaInterfeysa_b91d => '界面设计模式';
  @override
  String get pokazyvatVizualnyeEffektyIPerehody_3fd7 => '显示视觉效果和过渡';
  @override
  String get razmerTeksta_3c4f => '文字大小';
  @override
  String get bezopasnost_fcbc => '安全性';
  @override
  String get dvuhfaktornayaAutentifikatsiya_acdc => '双因素身份验证';
  @override
  String get zaschitaAkkaunta2fa_f1ab => '2FA 账户保护';
  @override
  String get vklyucheno_6b96 => '包含';
  @override
  String get xaneoMobileAktivnoSeychas_3345 => 'Xaneo Mobile • 现已启用';
  @override
  String get zaschischennyyMessendzher_2f59 => '安全信使';
  @override
  String get temnayaTema_6018 => '深色主题';
  @override
  String get vklyuchenaPoUmolchaniyu_7610 => '启用（默认）';
  @override
  String get setevoyFiltr_40c2 => '浪涌滤波器';
  @override
  String get vklyuchen_0994 => '启用';
  @override
  String get spisokMuzyki_57d0 => '音乐列表';
  @override
  String get trek_5049 => '轨道';
  @override
  String get trekov_d3f4 => '曲目';
  @override
  String get pozhaluystaZapolniteVoprosIKak_7ad5 => '请填写问题和至少两个答案选项';
  @override
  String get sozdatOpros_8401 => '创建调查';
  @override
  String get sozdatSpisokZadach_4018 => '创建任务列表';
  @override
  String get pozhaluystaZapolniteNazvanieIKak_3783 => '请填写标题和至少一项';
  @override
  String get sozdatSpisokZadach_0416 => '创建任务列表';
  @override
  String get vhodyaschiyVideozvonok_14d4 => '来电视频通话';
  @override
  String get prinyat_5dc5 => '接受';
  @override
  String get netObschihFaylov_bf77 => '没有共享文件';
  @override
  String get neUdalosRazarhivirovatChatNa_b6f6 => '无法在服务器上取消存档聊天';
  @override
  String get poiskVArhive_c5d8 => '档案搜索...';
  @override
  String get poprobuyteIzmenitZapros_52ea => '尝试更改您的要求';
  @override
  String get zdesBudutNahoditsyaVashiArhivirovannye_7359 => '您存档的聊天记录将位于此处';
  @override
  String get vernut_54aa => '返回';
  @override
  String get zashifrovannoeSoobschenie_c9ab => '加密消息';
  @override
  String get soobschenieNahoditsyaVysheVIstorii_dc90 => '故事中传达的信息更高。';
  @override
  String get otpravlyaetFoto_67c1 => '发送照片...';
  @override
  String get otpravlyaetVideo_ce80 => '发送视频...';
  @override
  String get otpravlyaetFayl_5e88 => '发送文件...';
  @override
  String get ktoTo_8405 => '有人';
  @override
  String get trebuetsyaRazreshenieNaKameruI_06fa => '需要相机和麦克风许可';
  @override
  String get kameraNeNaydena_208d => '找不到相机';
  @override
  String get zapisVideoOtmenena_1db7 => '视频录制已取消';
  @override
  String get slishkomKorotkoeVideosoobschenie_4676 => '视频消息太短';
  @override
  String get pozhaluystaPodozhditeOkonchaniyaZagruzkiFaylov_4c35 => '请等待文件下载完成';
  @override
  String get audiozvonok_dcf6 => '音频通话';
  @override
  String get otpravitFotoVideoAudioIli_37e9 => '发送照片、视频、音频或其他文件';
  @override
  String get provedenieGolosovaniyaVChate_a629 => '在聊天中投票';
  @override
  String get sozdatToDoSpisok_cb50 => '创建待办事项列表';
  @override
  String get spisokZadachSOtmetkamiVypolneniya_c778 => '带有完成标记的任务列表';
  @override
  String get trebuetsyaRazreshenieNaZapisAudio_8175 => '需要许可才能录制音频';
  @override
  String get slishkomKorotkoeSoobschenie_c2ee => '消息太短';
  @override
  String get uderzhivayteKnopkuDlyaZapisi_a762 => '按住按钮进行录音';
  @override
  String get udalennyy_40c6 => '远程';
  @override
  String get udalennyy_c2c8 => '远程';
  @override
  String get neobhodimyRazresheniyaNaMikrofonI_224b => '拨打电话所需的麦克风和摄像头权限';
  @override
  String get bylATolkoChto_9ac0 => '就在那里';
  @override
  String get chatNeNayden_ba4f => '找不到聊天记录';
  @override
  String get napishitePervoeSoobschenie_8260 => '写下您的第一条消息';
  @override
  String get prisoedinitsyaKKanalu_f863 => '加入频道';
  @override
  String get vyPodpisany_5fb9 => '您已订阅';
  @override
  String get otpisatsya_ee2d => '退订';
  @override
  String get vyUspeshnoPodpisalisNaKanal_9c99 => '您已成功订阅频道！';
  @override
  String get vyUspeshnoVstupiliVGruppu_61a1 => '您已成功加群！';
  @override
  String get neUdalosPrisoedinitsyaPoprobuyteEsche_bce5 => '加入失败。再试一次。';
  @override
  String get vyrezat_a195 => '切';
  @override
  String get kopirovat_112b => '复制';
  @override
  String get vstavit_dcc4 => '粘贴';
  @override
  String get vybratVse_4d09 => '选择全部';
  @override
  String get zhirnyy_7774 => '大胆';
  @override
  String get kursiv_e0b1 => '斜体';
  @override
  String get kod_3f34 => '代码';
  @override
  String get zacherknut_02fc => '划掉';
  @override
  String get soobschenie_8b9b => '留言...';
  @override
  String get smahniteDlyaOtmeny_e976 => '滑动取消';
  @override
  String get poisk_bfc9 => '搜索';
  @override
  String get udalitChat_4b2b => '删除聊天记录';
  @override
  String get udalitKanal_482f => '删除频道';
  @override
  String get pozhalovatsya_a7d9 => '投诉';
  @override
  String get redaktirovatGruppu_e40a => '编辑组';
  @override
  String get udalitGruppu_dff8 => '删除组';
  @override
  String get poiskSoobscheniyVremennoNedostupenV_4443 => '移动版暂时无法进行消息搜索';
  @override
  String get zhalobaOtpravlenaModeratoram_4547 => '投诉已发送给版主';
  @override
  String get redaktirovanieGruppyVremennoNedostupnoV_05d0 => '移动版暂时无法进行群组编辑';
  @override
  String get vyUverenyChtoHotiteOchistit_7c3a => '您确定要清除此聊天中的消息历史记录吗？此操作无法撤消。';
  @override
  String get ochistit_7074 => '清除';
  @override
  String get udalit_ed2b => '删除';
  @override
  String get vyyti_0f05 => '退出';
  @override
  String get oshibkaVosproizvedeniya_ac8a => '播放错误';
  @override
  String get novoeZashifrovannoeSoobschenie_4d30 => '新的加密消息';
  @override
  String get poiskChatov_779c => '搜索聊天记录...';
  @override
  String get obnovlenie_53e2 => '更新...';
  @override
  String get soedinenie_5a58 => '连接...';
  @override
  String get lichnye_4cb3 => '个人';
  @override
  String get neUdalosArhivirovatChatNa_36aa => '无法在服务器上存档聊天记录';
  @override
  String get oshibkaZagruzkiChatov_902f => '加载聊天时出错';
  @override
  String get povtorit_b914 => '重复';
  @override
  String get netChatov_85e3 => '没有聊天记录';
  @override
  String get nachniteNovyyRazgovor_8290 => '开始新的对话';
  @override
  String get neUdalosZagruzitAkkaunty_8570 => '无法加载帐户';
  @override
  String get vyberiteAkkaunt_79e7 => '选择一个帐户';
  @override
  String get bystryyVhodNaEtomUstroystve_3f30 => '在此设备上快速登录';
  @override
  String get voytiSParolem_9277 => '使用密码登录';
  @override
  String get sozdatXaneoId_4033 => '创建 Xaneo ID';
  @override
  String get netSohranennyhAkkauntov_b669 => '没有保存的帐户';
  @override
  String get tolkoChto_4493 => '刚才';
  @override
  String get emailNedostupen_fc3e => '电子邮件不可用';
  @override
  String get nevernyyKod_50f9 => '代码无效';
  @override
  String get oshibkaProverkiKoda_9018 => '代码验证错误';
  @override
  String get neobhodimoRazreshenieNaDostupK_5f5c => '访问照片所需的权限';
  @override
  String get oVyboreEmail_2609 => '关于选择电子邮件';
  @override
  String get podderzhivayutsyaVseDomenyElektronnoyPochty_a4e0 => '支持所有电子邮件域，除了';
  @override
  String get zapreschennyh_1f49 => '禁止';
  @override
  String get sozdatAkkaunt_19ed => '创建帐户';
  @override
  String get naprimerIvan_d7cb => '例如，伊万';
  @override
  String get zadayteParol_53d2 => '设置密码';
  @override
  String get minimum8Simvolov_4ccd => '最少 8 个字符';
  @override
  String get unikalnoeImyaDlyaVashegoProfilya_a0ea => '您的个人资料的唯一名称';
  @override
  String get vashEmail_879d => '您的电子邮件';
  @override
  String get dlyaSvyaziIVosstanovleniyaDostupa_c770 => '用于通信和访问恢复';
  @override
  String get emailAdres_9130 => '电子邮件地址';
  @override
  String get vvediteParolEscheRaz_7383 => '再次输入您的密码';
  @override
  String get parolEscheRaz_6daf => '再次输入密码';
  @override
  String get paroliNeSovpadayut_d82f => '密码不匹配';
  @override
  String get ukazhiteVashuRealnuyuDatuRozhdeniya_d9ed => '请注明您的真实出生日期';
  @override
  String get ddmmgggg_3524 => '日.月.年';
  @override
  String get sdelayteProfilUznavaemym_f2c5 => '让您的个人资料易于识别';
  @override
  String get profilGotov_b57d => '个人资料准备就绪';
  @override
  String get ostalosVsegoParaShagov_37e3 => '只剩下几步了';
  @override
  String get yaPrinimayuPolzovatelskoeSoglashenie_c431 => '我接受用户协议';
  @override
  String get yaDayuSoglasieNaObrabotku_0d03 => '我同意处理个人数据';
  @override
  String get sVozvrascheniem_77ee => '欢迎回来';
  @override
  String get zagruzka_43e4 => '正在加载...';
  @override
  String get vyberiteAkkauntDlyaVhoda_d3a6 => '选择一个帐户进行登录';
  @override
  String get vvediteVashNikneym_51a6 => '输入您的昵称';
  @override
  String get voytiVDrugoyAkkaunt_d10f => '登录另一个帐户';
  @override
  String get nedavnieAkkaunty_953d => '最近的帐户';
  @override
  String get dobroPozhalovatVXaneo_66d0 => '欢迎来到 Xaneo';
  @override
  String get xaneoTeperIVMobilnom_e918 => 'Xaneo 现已在移动应用程序中提供！这个信使从未如此方便快捷。';
  @override
  String get mneUzheInteresno_5365 => '我已经有兴趣了';
  @override
  String get vseVashiDannyePodZaschitoy_b7d9 => '您的所有数据都受到保护';
  @override
  String get vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e =>
      '所有消息均受到端到端加密的保护。 Xaneo 在任何阶段都不知道它们的内容。';
  @override
  String get prodolzhit_e9c3 => '继续';
  @override
  String get lokalnyeDataTsentry_f089 => '本地数据中心';
  @override
  String get vashiDannyeNikogdaNePokidayut_f871 => '您的数据永远不会离开该国，并存储在安全的数据中心中。';
  @override
  String get kodOtpravlenPovtorno_e109 => '代码已重新发送';
  @override
  String get dvuhfaktornayanautentifikatsiya_bacc => '双因素\n认证';
  @override
  String get naVashEmailOtpravlen6_b457 => '6 位数字代码已发送至您的电子邮件';
  @override
  String get podtverdit_e260 => '确认';
  @override
  String get nePoluchiliKodOtpravitPovtorno_c1d2 => '没有收到代码？重新发送';
  @override
  String get imyaNikneymOSebe_7a8d => '姓名、昵称、关于你自己';
  @override
  String get zvonkiSoobscheniyaVidimostProfilya_f905 => '通话、消息、个人资料可见性';
  @override
  String get parolSessii2fa_de9e => '密码、会话、2FA';
  @override
  String get prilozhenie_38aa => '附录';
  @override
  String get temaRazmerTekstaAnimatsii_f0a8 => '主题、文字大小、动画';
  @override
  String get pushUvedomleniyaZvuki_9cc2 => '推送通知、声音';
  @override
  String get oPrilozhenii_77b2 => '关于申请';
  @override
  String get versiya200Build200_0e7b => '版本 2.0.loc_0（内部版本 200）';
  @override
  String get redaktirovatProfil_56ad => '编辑个人资料';
  @override
  String get dobavitKontakt_2903 => '添加联系人';
  @override
  String get nikneymPolzovatelyaUsername_a6ff => '用户昵称（@用户名）';
  @override
  String get otobrazhaemoeImyaNeobyazatelno_340a => '显示名称（可选）';
  @override
  String get neUdalosNaytiIliDobavit_649f => '无法找到或添加用户';
  @override
  String get ya_feef => '我';
  @override
  String get poiskKontaktov_9a71 => '搜索联系人...';
  @override
  String get spisokKontaktovPust_58c6 => '联系人列表为空';
  @override
  String get kontaktyNeNaydeny_1b08 => '未找到联系人';

  @override
  String get messages => '消息设置';
  @override
  String get messageAnimations => '消息动画';
  @override
  String get messageAnimationsDesc => '发送和接收消息时显示动画';
  @override
  String get archivedChats => '已归档对话';
  @override
  String get archiveManagement => '归档管理';
  @override
  String get clearHistory => '清空聊天记录';
  @override
  String get clearHistoryDesc => '从本地删除所有消息';
  @override
  String get call => '拨打电话';
  @override
  String get sendMessage => '发送消息';
  @override
  String get deleteContact => '删除联系人';
  @override
  String get activeSessions => '活跃会话';
  @override
  String get thisDevice => '当前设备';
  @override
  String get xaneoPcActiveNow => 'Xaneo PC • 当前在线';
  @override
  String get activeNow => '在线';
  @override
  String get twoFactorAuth => '双重身份验证';
  @override
  String get twoFactorAuthDesc => '使用动态验证码保护账号安全';
  @override
  String get dangerZone => '危险区域';
  @override
  String get deleteAccount => '注销账号';
  @override
  String get irreversibleAction => '此操作无法撤销';
  @override
  String get theme => '主题模式';
  @override
  String get darkThemeDesc => '在深色和浅色外观之间切换';
  @override
  String get fontSizeText => '字体大小';
  @override
  String get showPopups => '显示弹窗通知';
  @override
  String get sound => '提示音';
  @override
  String get soundDesc => '收到新消息时播放声音';
  @override
  String get mainSettings => '主要设置';
  @override
  String get energySavingMode => '省电模式';
  @override
  String get energySavingModeDesc => '优化应用性能以节省电量';
  @override
  String get autoSleep => '自动休眠';
  @override
  String get autoSleepDesc => '空闲时自动进入休眠状态';
  @override
  String get animations => '动画效果';
  @override
  String get reducedMotion => '减弱动态效果';
  @override
  String get reducedMotionDesc => '减少界面动画渲染';
  @override
  String get comingSoon => '即将推出';
  @override
  String get darkTheme => '深色模式';
  @override
  String get version => '版本';

  @override
  String get updateAvailable => '有可用更新';
  @override
  String get clickToViewChanges => '点击查看变更';
  @override
  String get newVersionAvailable => '应用有新版本可用';
  @override
  String get newVersionAvailableTitle => '发现新版本';
  @override
  String get youHaveLatestVersion => '您已安装最新版本';
  @override
  String get whatsNew => '更新日志';
  @override
  String get officialReleaseNotes => '官方发布说明可在 GitHub 上查看';
  @override
  String get preparingDownload => '正在准备下载...';
  @override
  String get installationStarted => '开始安装...';
  @override
  String get whoSeesAvatar => '谁能看见我的头像';
  @override
  String get whoSeesBirthday => '谁能看见我的生日';
  @override
  String get whoSeesOnlineTime => '谁能看见我的在线状态';

  @override
  String get downloadVersion => '下载';
  @override
  String get downloadSource => '下载源';
  @override
  String get directInAppInstall => '应用内直接安装';
  @override
  String get autoDownloadAndRun => '自动下载并启动';
  @override
  String get githubReleasePage => 'GitHub 发布页面';
  @override
  String get skip => '跳过';
  @override
  String get updateAction => '更新';
  @override
  String get installAction => '正在安装...';
  @override
  String get isTyping => '正在输入...';
  @override
  String get isRecordingVoice => '正在录制语音...';
  @override
  String get areTyping => '正在输入...';

  @override
  String membersCount(int count) => '$count 位成员';
  @override
  String subscribersCount(int count) => '$count 位订阅者';

  @override
  String get group => '群组';
  @override
  String get channel => '频道';

  @override
  String get profile => '个人资料';
  @override
  String get userHidInfo => '用户已隐藏个人信息';
  @override
  String get leaveGroup => '退出群组';
  @override
  String get joinGroup => '加入群组';
  @override
  String get unsubscribeChannel => '取消订阅';
  @override
  String get subscribeChannel => '订阅频道';
  @override
  String get deleteChat => '删除聊天';
  @override
  String get pinChat => '置顶';
  @override
  String get unpinChat => '取消置顶';
  @override
  String get muteNotifications => '静音通知';
  @override
  String get unmuteNotifications => '取消静音';
  @override
  String get backToChats => '返回聊天列表';
  @override
  String get globalSearch => '全局搜索';
  @override
  String get chatSettings => '聊天设置';
  @override
  String get emoji => '表情';
  @override
  String get attachFile => '附加文件';
  @override
  String get startCall => '发起通话';
  @override
  String get audioCall => '语音通话';
  @override
  String get audioCallDesc => '通过语音通话';
  @override
  String get videoCall => '视频通话';

  @override
  String get copied => '已复制';

  @override
  String get copy => '复制';

  @override
  String get voiceRecordTitle => '语音录制';
  @override
  String get videoRecordTitle => '视频录制';
  @override
  String get holdToRecordHint => '按住按键录制\n点击切换模式';
  @override
  String get addAttachment => '添加附件';
  @override
  String get emojiPanelInDev => '表情面板开发中';
  @override
  String get recordingVoice => '正在录制语音...';
  @override
  String get recordingVideo => '正在录制视频...';
  @override
  String get releaseToSend => '松开发送';
  @override
  String get videoCallDesc => '开启摄像头通话';

  @override
  String get typeMessage => '输入消息...';
  @override
  String get file => '文件';
  @override
  String get todoList => '任务列表';
  @override
  String get poll => '投票';

  @override
  String get today => '今天';
  @override
  String get yesterday => '昨天';
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
  String get createTodo => '创建待办';
  @override
  String get listName => '列表名称';
  @override
  String get todoItems => '项目';
  @override
  String get addTodoItem => '+ 添加项目';
  @override
  String get itemHintPrefix => '项目';
  @override
  String get createPoll => '创建投票';
  @override
  String get pollQuestion => '问题';
  @override
  String get pollOptions => '选项';
  @override
  String get addPollOption => '+ 添加选项';
  @override
  String get optionHintPrefix => '选项';
  @override
  String get allowMultipleAnswers => '允许多选';
  @override
  String get accountsTitle => '账户';
  @override
  String get addAccount => '添加账户';
  @override
  String get accountLimitNotice => '账户上限: 5';

  @override
  String get singleChoice => '单选';

  @override
  String get media => '媒体';
  @override
  String get files => '文件';
  @override
  String get voice => '语音';
  @override
  String get links => '链接';

  @override
  String get bio => '个人简介';
  @override
  String get username => '用户名';
  @override
  String get birthday => '生日';
  @override
  String get noSharedMedia => '暂无媒体';
  @override
  String get noSharedFiles => '暂无文件';
  @override
  String get noSharedVoice => '暂无语音消息';
  @override
  String get noSharedLinks => '暂无链接';

  @override
  String get savedMessagesDesc => '您的个人笔记、文件和消息云存储';
  @override
  String get music => '音乐';
  @override
  String get noSharedMusic => '暂无音乐';
  @override
  String get secureDesktopCommunicator => '桌面安全通信软件';
  @override
  String get noMessagesTitle => '暂无消息';
  @override
  String get noMessagesSubtitle => '发送一条消息，在 Xaneo Connect 上开启对话吧！';
}
