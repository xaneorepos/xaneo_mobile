import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../models/auth/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/playback_provider.dart';
import '../../styles/app_styles.dart';
import '../../widgets/common/liquid_glass_nav_bar.dart';
import '../auth/login_screen.dart';
import '../chat/chat_list_screen.dart';
import '../contacts/contacts_screen.dart';
import '../../services/webrtc/call_manager.dart';
import '../../widgets/common/incoming_call_modal.dart';
import '../../providers/locale_provider.dart';
import '../../providers/appearance_provider.dart';
import '../../widgets/common/mobile_settings_modals.dart';
import '../../widgets/common/mobile_language_modal.dart';
import '../../widgets/common/mobile_accounts_modal.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../widgets/common/music_playlist_modal.dart';
import '../../widgets/common/track_artwork.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/update/update_service.dart';
import '../../services/api/api_client.dart';
import '../../services/crypto/crypto_service.dart';
import '../../models/update/app_version_info.dart';
import '../../widgets/common/custom_update_toast.dart';
import '../../widgets/common/device_auth_approval_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';
import '../../l10n/account_localizations.dart';

/// Главный экран приложения (после авторизации)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;
  Timer? _deviceAuthTimer;
  final Set<String> _handledDeviceAuthRequests = {};
  bool _deviceAuthDialogOpen = false;
  AppVersionInfo? _pendingUpdate;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Подписываемся на CallManager для отслеживания входящих вызовов
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CallManager>().addListener(_handleCallStateChanged);

        // Помечаем, что приложение готово, и проверяем наличие отложенных звонков
        NotificationService.isAppReady = true;
        NotificationService.checkPendingCallPayload();

        _checkAppUpdate();
        _checkPendingDeviceAuth();
        _deviceAuthTimer = Timer.periodic(
          const Duration(seconds: 4),
          (_) => _checkPendingDeviceAuth(),
        );
      }
    });
  }

  Future<void> _checkAppUpdate() async {
    final update = await UpdateService().checkForUpdates(force: true);
    if (update != null && mounted) {
      setState(() {
        _pendingUpdate = update;
      });
    }
  }

  @override
  void dispose() {
    NotificationService.isAppReady = false;
    _deviceAuthTimer?.cancel();
    try {
      context.read<CallManager>().removeListener(_handleCallStateChanged);
    } catch (_) {}
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkPendingDeviceAuth() async {
    if (!mounted || _deviceAuthDialogOpen) return;
    try {
      final response =
          await context.read<ApiClient>().get('/auth/device-login/pending/');
      final data = Map<String, dynamic>.from(response.data as Map);
      final requests = data['requests'];
      if (requests is! List) return;
      for (final raw in requests) {
        if (raw is! Map) continue;
        final request = Map<String, dynamic>.from(raw);
        final id = request['challenge_id']?.toString();
        if (id == null || _handledDeviceAuthRequests.contains(id)) continue;
        await _showDeviceAuthApproval(request);
        break;
      }
    } catch (_) {}
  }

  Future<void> _showDeviceAuthApproval(Map<String, dynamic> request) async {
    if (!mounted) return;
    _deviceAuthDialogOpen = true;
    final challenge = request['challenge_id']?.toString() ?? '';
    final device = request['device_name']?.toString();
    final client = request['client_type']?.toString() ?? 'устройство';
    final api = context.read<ApiClient>();
    final crypto = context.read<CryptoService>();
    final approved = await DeviceAuthApprovalModal.confirm(
      context: context,
      deviceName: device?.isNotEmpty == true ? device! : 'Новое устройство',
      clientName: _deviceAuthClientName(client),
      ipAddress: request['ip_address']?.toString().trim().isNotEmpty == true
          ? request['ip_address'].toString()
          : 'Не определён',
    );
    try {
      Map<String, dynamic>? transfer;
      if (approved == true) {
        final publicKey = request['recipient_public_key']?.toString();
        if (publicKey != null) {
          transfer = await crypto.createQrTransferPayload(publicKey, challenge);
        }
      }
      await api.post('/auth/device-login/decision/', data: {
        'challenge_id': challenge,
        'confirmed': approved == true,
        if (transfer != null) 'transfer_payload': transfer,
        if (approved == true && transfer == null) 'no_keys': true,
      });
      _handledDeviceAuthRequests.add(challenge);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось обработать запрос на вход')),
        );
      }
    } finally {
      _deviceAuthDialogOpen = false;
    }
  }

  String _deviceAuthClientName(String client) {
    switch (client.toLowerCase()) {
      case 'web':
        return 'Веб-версия Xaneo';
      case 'pc':
        return 'Xaneo PC';
      case 'mobile':
        return 'Xaneo Mobile';
      default:
        return client.isEmpty ? 'Неизвестный клиент' : client;
    }
  }

  void _handleCallStateChanged() {
    if (!mounted) return;
    final callManager = context.read<CallManager>();
    if (callManager.state == CallState.incoming) {
      IncomingCallModal.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Account-scoped screens cache repositories, streams and other state in
    // their State objects. Recreate that subtree when quick login activates a
    // different user so it cannot keep using the Drift connection that the
    // LocalChatRepository ProxyProvider has just closed.
    final activeUserId = context.select<AuthProvider, int?>(
      (auth) => auth.user?.id,
    );
    final appearance = context.watch<AppearanceProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Анимация скольжения экранов
          PageView(
            key: ValueKey('account-pages-$activeUserId'),
            controller: _pageController,
            physics:
                const NeverScrollableScrollPhysics(), // Блокируем свайп руками для точной синхронизации с панелью
            children: [
              ChatListScreen(key: ValueKey('chats-$activeUserId')),
              ContactsScreen(key: ValueKey('contacts-$activeUserId')),
              _SettingsScreen(key: ValueKey('settings-$activeUserId')),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 84, // Above the navigation bar
            child: _buildWideMediaBar(),
          ),
          if (_pendingUpdate != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 84,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CustomUpdateToast(
                  updateInfo: _pendingUpdate!,
                  onDismiss: () {
                    setState(() {
                      _pendingUpdate = null;
                    });
                  },
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LiquidGlassNavBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                if (_currentIndex != index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  if (appearance.animationsEnabled) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  } else {
                    _pageController.jumpToPage(index);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideMediaBar() {
    return Consumer<PlaybackProvider>(
      builder: (context, playbackProvider, child) {
        final isVisible = playbackProvider.showPlayerControls;

        // AnimatedSwitcher хранит предыдущий виджет во время исчезновения,
        // поэтому содержимое (title/subtitle) не «прыгает» в пустоту при stop().
        return AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (widget, animation) {
            return SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.topCenter,
              child: FadeTransition(opacity: animation, child: widget),
            );
          },
          // Уникальный ключ заставляет AnimatedSwitcher переключаться,
          // когда плеер появляется/исчезает. Пока виден — один и тот же ключ,
          // и контент обновляется на месте без пересоздания.
          child: isVisible
              ? const _MediaBarContent(key: ValueKey('media_bar_visible'))
              : const SizedBox.shrink(key: ValueKey('media_bar_hidden')),
        );
      },
    );
  }
}

/// Экран настроек вынесен в отдельный StatelessWidget, чтобы:
/// 1. Изолировать ребилды от _MainScreenState (AuthProvider, etc.).
/// 2. Позволить PageView кешировать виджет между переключениями вкладок.
class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen({super.key});

  // ─── Кешированные декорации (создаются один раз) ───────────────────────────

  BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
        color: context.xaneoSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.xaneoDivider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: context.isDarkTheme ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  BoxDecoration _editButtonDecoration(BuildContext context) => BoxDecoration(
        color: context.xaneoOverlay(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.xaneoDivider),
      );

  BoxDecoration _bioDecoration(BuildContext context) => BoxDecoration(
        color: context.xaneoOverlay(0.04),
        borderRadius: BorderRadius.circular(10),
      );

  BoxDecoration _sectionDecoration(BuildContext context) => BoxDecoration(
        color: context.xaneoSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.xaneoDivider, width: 1.5),
      );

  BoxDecoration _iconBoxDecoration(BuildContext context) => BoxDecoration(
        color: context.xaneoOverlay(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.xaneoDivider),
      );

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthProvider, UserModel?>((auth) => auth.user);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 24, bottom: 100),
        children: [
          if (user != null) ...[
            _buildProfileCard(context, user),
            const SizedBox(height: 24),
          ],
          _buildSection(context, (l10n?.akkaunt_38ac ?? 'Fallback'), [
            _buildItem(
              context,
              icon: FontAwesomeIcons.userGroup,
              title: AccountLocalizations.of(context).text('title'),
              subtitle: AccountLocalizations.of(context).text('subtitle'),
              onTap: () => MobileAccountsModal.show(context),
            ),
            _buildItem(
              context,
              icon: FontAwesomeIcons.userPen,
              title: (l10n?.lichnyeDannye_be85 ?? 'Fallback'),
              subtitle: (l10n?.imyaNikneymOSebe_7a8d ?? 'Fallback'),
              onTap: () => MobilePersonalModal.show(context),
            ),
            _buildItem(
              context,
              icon: FontAwesomeIcons.shieldHalved,
              title: (l10n?.privatnost_0899 ?? 'Fallback'),
              subtitle:
                  (l10n?.zvonkiSoobscheniyaVidimostProfilya_f905 ?? 'Fallback'),
              onTap: () => MobilePrivacyModal.show(context),
            ),
            _buildItem(
              context,
              icon: FontAwesomeIcons.lock,
              title: (l10n?.bezopasnost_3677 ?? 'Fallback'),
              subtitle: (l10n?.parolSessii2fa_de9e ?? 'Fallback'),
              isLast: true,
              onTap: () => MobileSecurityModal.show(context),
            ),
          ]),
          const SizedBox(height: 20),
          _buildSection(context, (l10n?.prilozhenie_38aa ?? 'Fallback'), [
            _buildItem(
              context,
              icon: FontAwesomeIcons.palette,
              title: (l10n?.vneshniyVid_6873 ?? 'Fallback'),
              subtitle: (l10n?.temaRazmerTekstaAnimatsii_f0a8 ?? 'Fallback'),
              onTap: () => MobileAppearanceModal.show(context),
            ),
            _buildItem(
              context,
              icon: FontAwesomeIcons.bell,
              title: (l10n?.uvedomleniya_d2ed ?? 'Fallback'),
              subtitle: (l10n?.pushUvedomleniyaZvuki_9cc2 ?? 'Fallback'),
              onTap: () => MobileAppearanceModal.show(context),
            ),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, _) {
                return _buildItem(
                  context,
                  icon: FontAwesomeIcons.language,
                  title: (l10n?.yazykInterfeysa_b78b ?? 'Fallback'),
                  subtitle: localeProvider.currentLanguageName,
                  isLast: true,
                  onTap: () => MobileLanguageModal.show(context),
                );
              },
            ),
          ]),
          const SizedBox(height: 20),
          _buildSection(context, (l10n?.oPrilozhenii_77b2 ?? 'Fallback'), [
            _buildItem(
              context,
              icon: FontAwesomeIcons.circleInfo,
              title: 'Xaneo Mobile',
              subtitle: 'v${AppConfig.appVersion} (${AppConfig.buildNumber})',
              isLast: true,
              onTap: () => MobileAboutModal.show(context),
            ),
          ]),
          const SizedBox(height: 28),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel user) {
    final displayName = user.firstName ?? user.username;
    final hasBio = user.bio != null && user.bio!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Аватарка (корректный парсинг фото, SVG и сгенерированных градиентов)
                AvatarWidget(
                  avatar: user.avatar,
                  avatarGradient: user.avatarGradient,
                  hasAvatar: user.avatar != null && user.avatar!.isNotEmpty,
                  username: displayName,
                  size: 64,
                ),
                const SizedBox(width: 16),
                // Имя, @username и email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.xaneoTextPrimary,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.xaneoTextSecondary,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.xaneoTextMuted,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasBio) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: _bioDecoration(context),
                child: Text(
                  user.bio!.trim(),
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: context.xaneoTextSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            // Кнопка Редактировать профиль
            GestureDetector(
              onTap: () => MobilePersonalModal.show(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: _editButtonDecoration(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.penToSquare,
                      size: 13,
                      color: context.xaneoTextSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (AppLocalizations.of(context)?.redaktirovatProfil_56ad ??
                          'Fallback'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.xaneoTextPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 22, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.xaneoTextMuted,
              fontFamily: 'Inter',
              letterSpacing: 1.3,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          // Убран ClipRRect — он создаёт saveLayer каждый кадр.
          // Скругление обеспечивает borderRadius в декорации контейнера.
          child: Container(
            decoration: _sectionDecoration(context),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required dynamic icon,
    required String title,
    String? subtitle,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: _iconBoxDecoration(context),
                child: Center(
                  child:
                      FaIcon(icon, color: context.xaneoTextPrimary, size: 15),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.xaneoTextPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.xaneoTextMuted,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                color: context.xaneoTextMuted,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: Center(
            child: Text(
              (AppLocalizations.of(context)?.vyytiIzAkkaunta_6d41 ??
                  'Fallback'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF888888),
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Содержимое плавающего медиа-бара. Вынесено в отдельный виджет, чтобы
/// AnimatedSwitcher сохранял его целиком (со всеми последними значениями)
/// во время анимации исчезновения.
class _MediaBarContent extends StatelessWidget {
  const _MediaBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    final playbackProvider = context.watch<PlaybackProvider>();
    final isPlaying = playbackProvider.isPlaying;
    final title = playbackProvider.title.isEmpty
        ? (AppLocalizations.of(context)?.audiozapis_867d ?? 'Аудиозапись')
        : playbackProvider.title;
    final subtitle = playbackProvider.subtitle;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppStyles.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isPlaying ? playbackProvider.pause : playbackProvider.resume,
            child: SizedBox(
              width: 36,
              height: 36,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TrackArtwork(
                      uri: playbackProvider.currentArtUri,
                      fallback: const ColoredBox(color: Color(0xFF27272A)),
                    ),
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.28),
                    ),
                    Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppStyles.textPrimaryColor,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => MusicPlaylistModal.show(
                context,
                initialPlaylist: playbackProvider.playlist,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppStyles.textPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppStyles.fontFamily,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppStyles.textSecondaryColor,
                        fontSize: 10.5,
                        fontFamily: AppStyles.fontFamily,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: playbackProvider.dismissPlayerControls,
            icon: const Icon(
              Icons.close_rounded,
              color: AppStyles.textMutedColor,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(
              width: 36,
              height: 36,
            ),
          ),
        ],
      ),
    );
  }
}
