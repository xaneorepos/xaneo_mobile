import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xaneo/l10n/app_localizations.dart';

import 'base_custom_modal.dart';

enum ChatContextAction { pin, archive, mute, clearHistory, delete }

class ChatContextMenu extends BaseCustomModal {
  const ChatContextMenu({
    super.key,
    required this.isPinned,
    required this.isArchived,
    required this.isMuted,
    required this.canDelete,
  });

  final bool isPinned;
  final bool isArchived;
  final bool isMuted;
  final bool canDelete;

  static Future<ChatContextAction?> show({
    required BuildContext context,
    required bool isPinned,
    required bool isArchived,
    required bool isMuted,
    required bool canDelete,
  }) {
    return BaseCustomModal.show<ChatContextAction>(
      context: context,
      child: ChatContextMenu(
        isPinned: isPinned,
        isArchived: isArchived,
        isMuted: isMuted,
        canDelete: canDelete,
      ),
    );
  }

  @override
  State<ChatContextMenu> createState() => _ChatContextMenuState();
}

class _ChatContextMenuState extends BaseCustomModalState<ChatContextMenu> {
  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <_ChatMenuEntry>[
      if (!widget.isArchived)
        _ChatMenuEntry(
          action: ChatContextAction.pin,
          icon: FontAwesomeIcons.thumbtack,
          label: widget.isPinned ? l10n.unpinChat : l10n.pinChat,
        ),
      _ChatMenuEntry(
        action: ChatContextAction.archive,
        icon: widget.isArchived
            ? FontAwesomeIcons.boxOpen
            : FontAwesomeIcons.boxArchive,
        label: widget.isArchived ? l10n.unarchive : l10n.toArchive,
      ),
      _ChatMenuEntry(
        action: ChatContextAction.mute,
        icon:
            widget.isMuted ? FontAwesomeIcons.bell : FontAwesomeIcons.bellSlash,
        label:
            widget.isMuted ? l10n.unmuteNotifications : l10n.muteNotifications,
      ),
      _ChatMenuEntry(
        action: ChatContextAction.clearHistory,
        icon: FontAwesomeIcons.trash,
        label: l10n.clearHistory,
      ),
      if (widget.canDelete)
        _ChatMenuEntry(
          action: ChatContextAction.delete,
          icon: FontAwesomeIcons.trashCan,
          label: l10n.deleteChat,
          destructive: true,
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: actions
          .map(
            (entry) => _ChatMenuTile(
              entry: entry,
              onTap: () => Navigator.of(context).pop(entry.action),
            ),
          )
          .toList(),
    );
  }
}

class _ChatMenuEntry {
  const _ChatMenuEntry({
    required this.action,
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final ChatContextAction action;
  final FaIconData icon;
  final String label;
  final bool destructive;
}

class _ChatMenuTile extends StatelessWidget {
  const _ChatMenuTile({required this.entry, required this.onTap});

  final _ChatMenuEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = entry.destructive ? Colors.redAccent : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: FaIcon(entry.icon, size: 17, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatActionConfirmationModal extends BaseCustomModal {
  const ChatActionConfirmationModal({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;

  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    return await BaseCustomModal.show<bool>(
          context: context,
          child: ChatActionConfirmationModal(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
          ),
        ) ??
        false;
  }

  @override
  State<ChatActionConfirmationModal> createState() =>
      _ChatActionConfirmationModalState();
}

class _ChatActionConfirmationModalState
    extends BaseCustomModalState<ChatActionConfirmationModal> {
  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context)!;
    final actionShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(shape: actionShape),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(l10n.cancel),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: actionShape,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(widget.confirmLabel),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
