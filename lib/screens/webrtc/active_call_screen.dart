import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../styles/app_styles.dart';
import '../../services/webrtc/call_manager.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../services/chat/chat_local_repository.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat/chat_model.dart';
import '../chat/chat_screen.dart';
import '../../widgets/common/premium_page_route.dart';

import 'base_call_screen.dart';
import 'group_active_call_screen.dart';
import 'package:xaneo/l10n/app_localizations.dart';

class ActiveCallScreen extends BaseCallScreen {
  const ActiveCallScreen({super.key});

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends BaseCallScreenState<ActiveCallScreen> {
  String? _lastTargetUserId;
  String? _lastTargetName;
  String? _lastTargetAvatar;
  String? _lastTargetGradient;
  bool _isGroupCall = false;

  @override
  Widget build(BuildContext context) {
    final callManager = Provider.of<CallManager>(context);

    if (callManager.isGroupCall) {
      return const GroupActiveCallScreen();
    }

    // Сохраняем информацию о собеседнике, пока она доступна в CallManager
    if (callManager.targetUserId != null) {
      _lastTargetUserId = callManager.targetUserId;
      _lastTargetName = callManager.targetName;
      _lastTargetAvatar = callManager.targetAvatar;
      _lastTargetGradient = callManager.targetGradient;
      _isGroupCall = callManager.isGroupCall;
    }

    // Если звонок завершен, выходим с экрана и открываем чат с собеседником
    if (callManager.state == CallState.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final navigator = Navigator.of(context);

        // Закрываем ActiveCallScreen, чтобы вернуться на предыдущий экран
        final route = ModalRoute.of(context);
        if (route != null && route.isCurrent) {
          navigator.pop();
        }

        if (_isGroupCall) {
          return;
        }

        if (_lastTargetUserId != null) {
          final currentUserId = context.read<AuthProvider>().user?.id;
          if (currentUserId != null) {
            final otherUserId = int.tryParse(_lastTargetUserId!);
            if (otherUserId != null) {
              final sortedIds = [currentUserId, otherUserId]..sort();
              final chatServerId = 'personal_${sortedIds[0]}_${sortedIds[1]}';

              // Проверяем, не находимся ли мы уже в нужном чате
              bool isAlreadyInChat = false;
              navigator.popUntil((route) {
                if (route.settings.name == 'chat_$chatServerId') {
                  isAlreadyInChat = true;
                }
                return true; // Не удаляем роуты
              });

              if (!isAlreadyInChat) {
                final localChatRepo = context.read<LocalChatRepository>();
                var chat = await localChatRepo.getChatByServerId(chatServerId);
                if (chat == null) {
                  chat = ChatModel(
                    id: chatServerId,
                    name: _lastTargetName ??
                        (AppLocalizations.of(context)?.chat_c52b ?? 'Fallback'),
                    avatar: _lastTargetAvatar,
                    avatarGradient: _lastTargetGradient,
                    isPersonal: true,
                  );
                }
                navigator.push(
                  PremiumPageRoute(
                    page: ChatScreen(chat: chat),
                    transitionType: PremiumTransitionType.chatReveal,
                    settings: RouteSettings(name: 'chat_$chatServerId'),
                  ),
                );
              }
            }
          }
        }
      });
      return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor);
    }

    final isVideo = callManager.callType == 'video';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Основной фон или видеопоток собеседника
          if (callManager.state == CallState.connected) ...[
            if (isVideo && callManager.remoteVideoTrack != null)
              Positioned.fill(
                child: VideoTrackRenderer(
                  callManager.remoteVideoTrack!,
                  fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              )
            else
              // Голосовой звонок или видео еще не пошло
              Positioned.fill(
                child: _buildAudioCallBackground(callManager),
              ),
          ] else ...[
            // Исходящий / ожидания подключения
            Positioned.fill(
              child: _buildCallingBackground(callManager),
            ),
          ],

          // 2. Локальное превью видео (камера)
          if (callManager.state == CallState.connected &&
              isVideo &&
              callManager.localVideoTrack != null &&
              !callManager.isCameraOff)
            Positioned(
              top: 48,
              right: 16,
              width: 110,
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.xaneoRadius(16)),
                  border:
                      Border.all(color: context.xaneoOverlay(0.24), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.xaneoRadius(14)),
                  child: VideoTrackRenderer(
                    callManager.localVideoTrack!,
                    fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirrorMode: VideoViewMirrorMode.auto,
                  ),
                ),
              ),
            ),

          // 3. Информация о собеседнике вверху (Имя, статус)
          Positioned(
            top: 60,
            left: 24,
            right: 150, // чтобы не накладываться на локальное видео
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.xaneoSurface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(context.xaneoRadius(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    callManager.targetName ??
                        (AppLocalizations.of(context)?.polzovatel_f154 ??
                            'Fallback'),
                    style: TextStyle(
                      color: context.xaneoTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusText(callManager.state),
                    style: TextStyle(
                      color: context.xaneoTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Панель управления звонком внизу
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: context.xaneoSurface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(context.xaneoRadius(30)),
                border: Border.all(color: context.xaneoDivider, width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Кнопка спикера (Громкая связь)
                  _buildControlCircleButton(
                    onTap: callManager.toggleSpeaker,
                    icon: callManager.isSpeakerOn
                        ? FontAwesomeIcons.volumeHigh
                        : FontAwesomeIcons.volumeOff,
                    isActive: callManager.isSpeakerOn,
                  ),

                  // Кнопка микрофона (Mute)
                  _buildControlCircleButton(
                    onTap: callManager.toggleMicrophone,
                    icon: callManager.isMicrophoneMuted
                        ? FontAwesomeIcons.microphoneSlash
                        : FontAwesomeIcons.microphone,
                    isActive: !callManager.isMicrophoneMuted,
                  ),

                  // Кнопка камеры (On/Off) - только для видеозвонков
                  if (isVideo)
                    _buildControlCircleButton(
                      onTap: callManager.toggleCamera,
                      icon: callManager.isCameraOff
                          ? FontAwesomeIcons.videoSlash
                          : FontAwesomeIcons.video,
                      isActive: !callManager.isCameraOff,
                    ),

                  // Кнопка сброса (Красная)
                  _buildHangupButton(onTap: () {
                    callManager.hangUp();
                  }),
                ],
              ),
            ),
          ),

          // 5. Полноэкранный черный экран при поднесении к уху (Proximity sensor)
          if (callManager.isNearEar)
            Positioned.fill(
              child: Container(
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusText(CallState state) {
    switch (state) {
      case CallState.outgoing:
        return (AppLocalizations.of(context)?.ishodyaschiyVyzov_650b ??
            'Fallback');
      case CallState.incoming:
        return (AppLocalizations.of(context)?.vhodyaschiyVyzov_19ff ??
            'Fallback');
      case CallState.connected:
        return (AppLocalizations.of(context)?.podklyucheno_d022 ?? 'Fallback');
      default:
        return '';
    }
  }

  Widget _buildCallingBackground(CallManager callManager) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: callingAnimationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140 + (callingAnimationController.value * 60),
                  height: 140 + (callingAnimationController.value * 60),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.xaneoAccent.withValues(
                        alpha: 0.1 * (1 - callingAnimationController.value)),
                  ),
                ),
                child!,
              ],
            );
          },
          child: AvatarWidget(
            avatar: callManager.targetAvatar,
            avatarGradient: callManager.targetGradient,
            hasAvatar: callManager.targetAvatar != null &&
                callManager.targetAvatar!.isNotEmpty,
            username: callManager.targetName ?? 'User',
            size: 130,
          ),
        ),
        const SizedBox(height: 48),
        Text(
          (AppLocalizations.of(context)?.ozhidanieOtveta_a984 ?? 'Fallback'),
          style: TextStyle(
            color: context.xaneoTextSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioCallBackground(CallManager callManager) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarWidget(
            avatar: callManager.targetAvatar,
            avatarGradient: callManager.targetGradient,
            hasAvatar: callManager.targetAvatar != null &&
                callManager.targetAvatar!.isNotEmpty,
            username: callManager.targetName ?? 'User',
            size: 140,
          ),
          const SizedBox(height: 32),
          Text(
            (AppLocalizations.of(context)?.razgovorPoAudiosvyazi_3ed7 ??
                'Fallback'),
            style: TextStyle(
              color: context.xaneoTextSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCircleButton({
    required VoidCallback onTap,
    required FaIconData icon,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? context.xaneoButtonBackground
              : context.xaneoSurfaceElevated,
        ),
        child: Center(
          child: FaIcon(
            icon,
            color: isActive
                ? context.xaneoButtonForeground
                : context.xaneoTextMuted,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildHangupButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.error,
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.phoneSlash,
            color: Theme.of(context).colorScheme.onError,
            size: 20,
          ),
        ),
      ),
    );
  }
}
