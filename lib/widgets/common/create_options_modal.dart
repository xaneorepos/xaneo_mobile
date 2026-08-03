import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/chat/chat_local_repository.dart';
import '../../services/chat/chat_service.dart';
import '../../services/chat/group_channel_service.dart';
import '../../styles/app_styles.dart';
import 'create_channel_modal.dart';
import 'create_group_modal.dart';
import 'global_search_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Легковесное модальное окно выбора варианта создания (Личный чат, Группа, Канал)
class CreateOptionsModal extends StatelessWidget {
  final ChatService chatService;
  final GroupChannelService groupChannelService;
  final LocalChatRepository localChatRepo;

  const CreateOptionsModal({
    super.key,
    required this.chatService,
    required this.groupChannelService,
    required this.localChatRepo,
  });

  static Future<void> show({
    required BuildContext context,
    required ChatService chatService,
    required GroupChannelService groupChannelService,
    required LocalChatRepository localChatRepo,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => CreateOptionsModal(
        chatService: chatService,
        groupChannelService: groupChannelService,
        localChatRepo: localChatRepo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF141416),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Заголовок
              Padding(
                padding: EdgeInsets.only(left: 4, bottom: 14),
                child: Text(
                  (AppLocalizations.of(context)?.sozdatNovyyChat_fd41 ?? 'Fallback'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppStyles.fontFamily,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              // Вариант 1: Личный чат
              _buildOptionItem(
                context: context,
                icon: FontAwesomeIcons.solidComment,
                iconColor: const Color(0xFF60A5FA),
                title: (AppLocalizations.of(context)?.lichnyyChat_cbec ?? 'Fallback'),
                subtitle: (AppLocalizations.of(context)?.nachatObschenieSPolzovatelem_0578 ?? 'Fallback'),
                onTap: () async {
                  final authProvider = context.read<AuthProvider>();
                  final rootContext = Navigator.of(context).context;

                  Navigator.of(context).pop();
                  await Future.delayed(const Duration(milliseconds: 320));
                  if (!rootContext.mounted) return;

                  GlobalSearchModal.show(
                    context: rootContext,
                    chatService: chatService,
                    localChatRepo: localChatRepo,
                    authProvider: authProvider,
                  );
                },
              ),

              SizedBox(height: 10),

              // Вариант 2: Создать группу
              _buildOptionItem(
                context: context,
                icon: FontAwesomeIcons.users,
                iconColor: const Color(0xFF34D399),
                title: (AppLocalizations.of(context)?.sozdatGruppu_459f ?? 'Fallback'),
                subtitle: (AppLocalizations.of(context)?.gruppovoyChatDlyaObscheniyaS_01ba ?? 'Fallback'),
                onTap: () async {
                  final rootContext = Navigator.of(context).context;

                  Navigator.of(context).pop();
                  await Future.delayed(const Duration(milliseconds: 320));
                  if (!rootContext.mounted) return;

                  CreateGroupModal.show(
                    context: rootContext,
                    groupChannelService: groupChannelService,
                    localChatRepo: localChatRepo,
                  );
                },
              ),

              SizedBox(height: 10),

              // Вариант 3: Создать канал
              _buildOptionItem(
                context: context,
                icon: FontAwesomeIcons.bullhorn,
                iconColor: const Color(0xFFA78BFA),
                title: (AppLocalizations.of(context)?.sozdatKanal_9022 ?? 'Fallback'),
                subtitle: (AppLocalizations.of(context)?.kanalDlyaShirokoyAuditorii_9dba ?? 'Fallback'),
                onTap: () async {
                  final rootContext = Navigator.of(context).context;

                  Navigator.of(context).pop();
                  await Future.delayed(const Duration(milliseconds: 320));
                  if (!rootContext.mounted) return;

                  CreateChannelModal.show(
                    context: rootContext,
                    groupChannelService: groupChannelService,
                    localChatRepo: localChatRepo,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required dynamic icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
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
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppStyles.fontFamily,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                        fontFamily: AppStyles.fontFamily,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                color: Color(0xFF555555),
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
