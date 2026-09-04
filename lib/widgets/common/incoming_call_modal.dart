import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../services/webrtc/call_manager.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../screens/webrtc/active_call_screen.dart';
import 'base_custom_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';

class IncomingCallModal extends BaseCustomModal {
  const IncomingCallModal({super.key});

  static void show(BuildContext context) async {
    final callManager = context.read<CallManager>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => const IncomingCallModal(),
    );

    // Если закрыли модалку свайпом, тапом вне или крестиком (результат не true),
    // и звонок всё еще во входящем состоянии — отклоняем его.
    if (result != true) {
      if (callManager.state == CallState.incoming) {
        callManager.rejectIncomingCall();
      }
    }
  }

  @override
  State<IncomingCallModal> createState() => _IncomingCallModalState();
}

class _IncomingCallModalState extends BaseCustomModalState<IncomingCallModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  double get initialExtent => 0.45;

  @override
  double get minExtent => 0.45;

  @override
  double get maxExtent => 0.45;

  // buildContent() подписан на CallManager через свой context, поэтому
  // кэшировать содержимое нельзя — модалка перестала бы реагировать на смену
  // состояния звонка (в т.ч. не закрывалась бы при переходе в idle).
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulseController
        ..stop()
        ..value = 0;
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final callManager = Provider.of<CallManager>(context);

    // Если звонок сброшен или завершен (перешел в idle), закрываем модалку
    if (callManager.state == CallState.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final route = ModalRoute.of(context);
        if (route != null && route.isCurrent) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox.shrink();
    }

    final isVideo = callManager.callType == 'video';

    return SingleChildScrollView(
      controller: scrollController,
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),

          // Аватар собеседника (не двигается)
          AvatarWidget(
            avatar: callManager.targetAvatar,
            avatarGradient: callManager.targetGradient,
            hasAvatar: callManager.targetAvatar != null &&
                callManager.targetAvatar!.isNotEmpty,
            username: callManager.targetName ?? 'User',
            size: 80,
          ),

          const SizedBox(height: 20),

          // Текст статуса звонка
          Text(
            isVideo
                ? (AppLocalizations.of(context)?.vhodyaschiyVideozvonok_14d4 ??
                    'Fallback')
                : (AppLocalizations.of(context)?.vhodyaschiyZvonok_5ce9 ??
                    'Fallback'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Имя звонящего
          Text(
            callManager.targetName ??
                (AppLocalizations.of(context)?.neizvestnyy_be89 ?? 'Fallback'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 36),

          // Кнопки управления (Принять / Отклонить)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Кнопка отклонения
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false);
                  },
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEF4444),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: FaIcon(
                              FontAwesomeIcons.phoneSlash,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (AppLocalizations.of(context)?.otklonit_8b0d ??
                              'Fallback'),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Кнопка принятия
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop(true);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ActiveCallScreen(),
                      ),
                    );
                    await callManager.acceptIncomingCall();
                  },
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: FaIcon(
                              isVideo
                                  ? FontAwesomeIcons.video
                                  : FontAwesomeIcons.phone,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (AppLocalizations.of(context)?.prinyat_5dc5 ??
                              'Fallback'),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
