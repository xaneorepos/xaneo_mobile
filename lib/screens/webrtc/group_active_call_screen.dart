import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'base_call_screen.dart';
import '../../services/webrtc/call_manager.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Экран активного ГРУППОВОГО звонка для мобильной версии
class GroupActiveCallScreen extends BaseCallScreen {
  const GroupActiveCallScreen({super.key});

  @override
  State<GroupActiveCallScreen> createState() => _GroupActiveCallScreenState();
}

class _GroupActiveCallScreenState
    extends BaseCallScreenState<GroupActiveCallScreen> {
  @override
  Widget build(BuildContext context) {
    final callManager = Provider.of<CallManager>(context);

    // Если звонок завершен - закрываем экран
    if (callManager.state == CallState.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final route = ModalRoute.of(context);
        if (route != null && route.isCurrent) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(backgroundColor: Colors.black);
    }

    final groupName = callManager.targetName ??
        (AppLocalizations.of(context)?.gruppovoyZvonok_dac1 ?? 'Fallback');
    final isConnected = callManager.state == CallState.connected;

    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Stack(
        children: [
          // ==========================================
          // 1. ОСНОВНАЯ СЕТКА УЧАСТНИКОВ (GRID / LIST)
          // ==========================================
          if (isConnected) ...[
            Positioned.fill(
              top: MediaQuery.of(context).padding.top + 70,
              bottom: MediaQuery.of(context).padding.bottom + 90,
              left: 16,
              right: 16,
              child: _buildParticipantsGrid(callManager),
            ),
          ] else ...[
            // Экран подключения
            Positioned.fill(
              child: _buildConnectingState(callManager, groupName),
            ),
          ],

          // ==========================================
          // 2. ВЕРХНЯЯ И НИЖНЯЯ ПАНЕЛИ ИЗ BASE SCREEN
          // ==========================================
          buildCallHeader(
            context: context,
            title: groupName,
            subtitle: isConnected
                ? (AppLocalizations.of(context)?.gruppovoyZvonok_dac1 ??
                    'Fallback')
                : (AppLocalizations.of(context)?.podklyuchenieKZvonku_e2cf ??
                    'Fallback'),
            onMinimize: () {
              Navigator.of(context).pop();
            },
          ),

          buildMobileCallControls(
            callManager: callManager,
            onToggleAudio: () => callManager.toggleAudio(),
            onToggleVideo: () => callManager.toggleVideo(),
            onToggleSpeaker: () => callManager.toggleSpeaker(),
            onSwitchCamera: () => callManager.switchCamera(),
            onHangup: () => callManager.endCall(),
          ),

          // 3. Полноэкранный черный экран при поднесении к уху (Proximity sensor)
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

  /// Экран подключения к вещанию
  Widget _buildConnectingState(CallManager callManager, String groupName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.1).animate(
              CurvedAnimation(
                  parent: callingAnimationController, curve: Curves.easeInOut),
            ),
            child: BaseCallAvatar(
              avatar: callManager.targetAvatar,
              avatarGradient: callManager.targetGradient,
              username: groupName,
              size: 96,
            ),
          ),
          SizedBox(height: 20),
          Text(
            groupName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (AppLocalizations.of(context)?.podklyuchenieKVeschaniyu_038b ??
                'Fallback'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Построение адаптивной мобильной сетки участников
  Widget _buildParticipantsGrid(CallManager callManager) {
    final List<Widget> participantTiles = [];

    // 1. Собственный локальный тайл пользователя
    participantTiles.add(_buildParticipantCard(
      name: (AppLocalizations.of(context)?.vy_0101 ?? 'Fallback'),
      isLocal: true,
      isVideoOn: !callManager.isCameraOff,
      avatar: null,
      avatarGradient: null,
      isMuted: callManager.isMicrophoneMuted,
    ));

    // 2. Добавляем карточки всех реальных участников группы
    final participantsMap = callManager.groupParticipants;
    if (participantsMap.isNotEmpty) {
      participantsMap.forEach((uid, pData) {
        participantTiles.add(_buildParticipantCard(
          name: pData['name']?.toString() ??
              '${AppLocalizations.of(context)?.uchastnik_cffb ?? 'Participant'} $uid',
          isLocal: false,
          isVideoOn: false,
          avatar: pData['avatar']?.toString(),
          avatarGradient: pData['gradient']?.toString(),
          isMuted: false,
        ));
      });
    } else {
      // Плейсхолдер вещания при входящем/исходящем звонке
      participantTiles.add(_buildParticipantCard(
        name: callManager.targetName ??
            (AppLocalizations.of(context)?.uchastnik_cffb ?? 'Fallback'),
        isLocal: false,
        isVideoOn: false,
        avatar: callManager.targetAvatar,
        avatarGradient: callManager.targetGradient,
        isMuted: false,
      ));
    }

    final crossAxisCount = participantTiles.length >= 3 ? 2 : 1;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: crossAxisCount == 1 ? 1.4 : 1.1,
      ),
      itemCount: participantTiles.length,
      itemBuilder: (context, index) => participantTiles[index],
    );
  }

  /// Мобильная карточка участника
  Widget _buildParticipantCard({
    required String name,
    required bool isLocal,
    required bool isVideoOn,
    required String? avatar,
    required String? avatarGradient,
    required bool isMuted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Заглушка с аватаркой участника
          Positioned.fill(
            child: Container(
              color: const Color(0xFF151D2A),
              child: Center(
                child: BaseCallAvatar(
                  avatar: avatar,
                  avatarGradient: avatarGradient,
                  username: name,
                  size: 64,
                ),
              ),
            ),
          ),

          // Нижная плашка с именем и индикатором
          Positioned(
            left: 10,
            bottom: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isLocal) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            (AppLocalizations.of(context)?.vy_479c ??
                                'Fallback'),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isMuted)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_off_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
