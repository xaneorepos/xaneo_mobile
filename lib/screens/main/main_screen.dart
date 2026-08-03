import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
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
import '../../widgets/common/mobile_settings_modals.dart';
import '../../widgets/common/mobile_language_modal.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/update/update_service.dart';
import '../../widgets/common/custom_update_toast.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Главный экран приложения (после авторизации)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

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
      }
    });
  }

  Future<void> _checkAppUpdate() async {
    final update = await UpdateService().checkForUpdates();
    if (mounted && update != null) {
      CustomUpdateToast.show(context, update);
    }
  }

  @override
  void dispose() {
    NotificationService.isAppReady = false;
    try {
      context.read<CallManager>().removeListener(_handleCallStateChanged);
    } catch (_) {}
    _pageController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: Stack(
        children: [
          // Анимация скольжения экранов
          PageView(
            controller: _pageController,
            physics:
                const NeverScrollableScrollPhysics(), // Блокируем свайп руками для точной синхронизации с панелью
            children: const [
              ChatListScreen(key: ValueKey('chats')),
              ContactsScreen(key: ValueKey('contacts')),
              _SettingsScreen(key: ValueKey('settings')),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 84, // Above the navigation bar
            child: _buildWideMediaBar(),
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
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
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
        final isVisible = playbackProvider.currentAudioUrl != null;

        // AnimatedSwitcher хранит предыдущий виджет во время исчезновения,
        // поэтому содержимое (title/subtitle) не «прыгает» в пустоту при stop().
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
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

  static final _cardDecoration = BoxDecoration(
    color: const Color(0xFF141416),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: const Color(0x14FFFFFF), width: 1.5),
    boxShadow: const [
      BoxShadow(
        color: Color(0x4D000000),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );

  static final _editButtonDecoration = BoxDecoration(
    color: const Color(0x12FFFFFF),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0x1AFFFFFF)),
  );

  static final _bioDecoration = BoxDecoration(
    color: const Color(0x0AFFFFFF),
    borderRadius: BorderRadius.circular(10),
  );

  static final _sectionDecoration = BoxDecoration(
    color: const Color(0xFF141416),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0x14FFFFFF), width: 1.5),
  );

  static final _iconBoxDecoration = BoxDecoration(
    color: const Color(0x14FFFFFF),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: const Color(0x14FFFFFF)),
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
          _buildSection((l10n?.akkaunt_38ac ?? 'Fallback'), [
            _buildItem(
              icon: FontAwesomeIcons.userPen,
              title: (l10n?.lichnyeDannye_be85 ?? 'Fallback'),
              subtitle: (l10n?.imyaNikneymOSebe_7a8d ?? 'Fallback'),
              onTap: () => MobilePersonalModal.show(context),
            ),
            _buildItem(
              icon: FontAwesomeIcons.shieldHalved,
              title: (l10n?.privatnost_0899 ?? 'Fallback'),
              subtitle:
                  (l10n?.zvonkiSoobscheniyaVidimostProfilya_f905 ?? 'Fallback'),
              onTap: () => MobilePrivacyModal.show(context),
            ),
            _buildItem(
              icon: FontAwesomeIcons.lock,
              title: (l10n?.bezopasnost_3677 ?? 'Fallback'),
              subtitle: (l10n?.parolSessii2fa_de9e ?? 'Fallback'),
              isLast: true,
              onTap: () => MobileSecurityModal.show(context),
            ),
          ]),
          const SizedBox(height: 20),
          _buildSection((l10n?.prilozhenie_38aa ?? 'Fallback'), [
            _buildItem(
              icon: FontAwesomeIcons.palette,
              title: (l10n?.vneshniyVid_6873 ?? 'Fallback'),
              subtitle: (l10n?.temaRazmerTekstaAnimatsii_f0a8 ?? 'Fallback'),
              onTap: () => MobileAppearanceModal.show(context),
            ),
            _buildItem(
              icon: FontAwesomeIcons.bell,
              title: (l10n?.uvedomleniya_d2ed ?? 'Fallback'),
              subtitle: (l10n?.pushUvedomleniyaZvuki_9cc2 ?? 'Fallback'),
              onTap: () => MobileAppearanceModal.show(context),
            ),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, _) {
                return _buildItem(
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
          _buildSection((l10n?.oPrilozhenii_77b2 ?? 'Fallback'), [
            _buildItem(
              icon: FontAwesomeIcons.circleInfo,
              title: 'Xaneo Mobile',
              subtitle: (l10n?.versiya200Build200_0e7b ?? 'Fallback'),
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
        decoration: _cardDecoration,
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white38,
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
                decoration: _bioDecoration,
                child: Text(
                  user.bio!.trim(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
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
                decoration: _editButtonDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.penToSquare,
                      size: 13,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (AppLocalizations.of(context)?.redaktirovatProfil_56ad ??
                          'Fallback'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 22, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white38,
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
            decoration: _sectionDecoration,
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildItem({
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
                decoration: _iconBoxDecoration,
                child: Center(
                  child: FaIcon(icon, color: Colors.white, size: 15),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white38,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                color: Colors.white24,
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
    final title = playbackProvider.title;
    final subtitle = playbackProvider.subtitle;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xE6141416), // frosted look
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          // Spinning music disc/icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.music_note_rounded,
                color: isPlaying ? const Color(0xFF4ADE80) : Colors.white70,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title and subtitle
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppStyles.fontFamily,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontFamily: AppStyles.fontFamily,
                  ),
                ),
              ],
            ),
          ),
          // Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded,
                    color: Colors.white, size: 22),
                onPressed: () => playbackProvider.previous(),
              ),
              GestureDetector(
                onTap: () {
                  if (isPlaying) {
                    playbackProvider.pause();
                  } else {
                    playbackProvider.resume();
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded,
                    color: Colors.white, size: 22),
                onPressed: () => playbackProvider.next(),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withOpacity(0.08),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded,
                    color: Colors.white.withOpacity(0.4), size: 20),
                onPressed: () => playbackProvider.stop(),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }
}
