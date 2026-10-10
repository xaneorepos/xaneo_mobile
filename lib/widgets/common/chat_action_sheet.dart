import 'package:flutter/material.dart';

import '../../styles/app_styles.dart';
import 'base_custom_modal.dart';

class ChatSheetAction {
  const ChatSheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onSelected,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onSelected;
}

/// Shared appearance for attachment and call menus in a chat.
class ChatActionSheet extends BaseCustomModal {
  const ChatActionSheet({super.key, required this.actions});

  final List<ChatSheetAction> actions;

  static Future<void> show(BuildContext context,
      {required List<ChatSheetAction> actions}) {
    return BaseCustomModal.show<void>(
      context: context,
      child: ChatActionSheet(actions: actions),
    );
  }

  @override
  State<ChatActionSheet> createState() => _ChatActionSheetState();
}

class _ChatActionSheetState extends BaseCustomModalState<ChatActionSheet> {
  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < widget.actions.length; index++) ...[
            if (index > 0) Divider(color: context.xaneoDivider, height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.xaneoOverlay(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.actions[index].icon,
                    color: context.xaneoTextPrimary),
              ),
              title: Text(widget.actions[index].title,
                  style: TextStyle(
                      color: context.xaneoTextPrimary,
                      fontWeight: FontWeight.w600)),
              subtitle: Text(widget.actions[index].subtitle,
                  style:
                      TextStyle(color: context.xaneoTextMuted, fontSize: 12)),
              onTap: () {
                Navigator.of(context).pop();
                widget.actions[index].onSelected();
              },
            ),
          ],
        ],
      ),
    );
  }
}
