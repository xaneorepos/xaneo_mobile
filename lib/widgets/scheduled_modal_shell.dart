import 'package:flutter/material.dart';
import 'scheduled_modal_style.dart';
import 'common/base_custom_modal.dart';

/// Scheduled messages share the app's mobile bottom-sheet surface and motion.
class ScheduledModalShell extends BaseCustomModal {
  const ScheduledModalShell(
      {super.key, required this.child, this.fillHeight = false});
  final Widget child;
  final bool fillHeight;

  static Future<T?> show<T>(
          {required BuildContext context,
          required WidgetBuilder builder,
          bool barrierDismissible = true}) =>
      BaseCustomModal.show<T>(
          context: context,
          isDismissible: barrierDismissible,
          child: InheritedTheme.captureAll(context, Builder(builder: builder)));

  @override
  State<ScheduledModalShell> createState() => _ScheduledModalShellState();
}

class _ScheduledModalShellState
    extends BaseCustomModalState<ScheduledModalShell> {
  @override
  bool get fitContent => !widget.fillHeight;
  @override
  bool get isResizable => false;
  @override
  double get initialExtent => .9;
  @override
  double get maxExtent => .95;
  @override
  Widget buildContent(
          BuildContext context, ScrollController scrollController) =>
      Theme(
          data: ScheduledModalStyle.of(context).theme(Theme.of(context)),
          child: widget.child);
}
