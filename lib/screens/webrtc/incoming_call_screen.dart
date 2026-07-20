import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../services/webrtc/call_manager.dart';
import '../../widgets/common/avatar_widget.dart';
import 'active_call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callManager = Provider.of<CallManager>(context);

    // Если звонок сброшен или завершен (перешел в idle), закрываем экран
    if (callManager.state == CallState.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
      return const Scaffold(backgroundColor: Colors.black);
    }

    final isVideo = callManager.callType == 'video';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Slate
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Анимированные пульсирующие круги подложки
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140 + (_pulseController.value * 60),
                    height: 140 + (_pulseController.value * 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15 * (1 - _pulseController.value)),
                    ),
                  ),
                  Container(
                    width: 140 + ((_pulseController.value + 0.5) % 1 * 60),
                    height: 140 + ((_pulseController.value + 0.5) % 1 * 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1 * (1 - ((_pulseController.value + 0.5) % 1))),
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. Основное содержимое
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Аватар собеседника
              AvatarWidget(
                avatar: callManager.targetAvatar,
                avatarGradient: callManager.targetGradient,
                hasAvatar: callManager.targetAvatar != null && callManager.targetAvatar!.isNotEmpty,
                username: callManager.targetName ?? 'User',
                size: 130,
              ),

              const SizedBox(height: 32),

              // Текст статуса звонка
              Text(
                isVideo ? 'Входящий видеозвонок' : 'Входящий звонок',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Имя звонящего
              Text(
                callManager.targetName ?? 'Неизвестный',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(flex: 4),

              // Кнопки управления (Принять / Отклонить)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Кнопка отклонения (Красная)
                    GestureDetector(
                      onTap: () {
                        callManager.rejectIncomingCall();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEF4444),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.phoneSlash,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Отклонить',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Кнопка принятия (Зеленая)
                    GestureDetector(
                      onTap: () async {
                        // Открываем экран активного звонка
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const ActiveCallScreen(),
                            ),
                          );
                        }
                        // Принимаем звонок (это соединит с LiveKit)
                        await callManager.acceptIncomingCall();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10B981),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: FaIcon(
                                isVideo ? FontAwesomeIcons.video : FontAwesomeIcons.phone,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Принять',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ],
      ),
    );
  }
}
