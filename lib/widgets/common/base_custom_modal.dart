import 'package:flutter/material.dart';

/// Общая оболочка мобильных bottom sheet без лишних слоёв и ручного кеша.
abstract class BaseCustomModal extends StatefulWidget {
  const BaseCustomModal({super.key});

  /// Открывает мобильную модалку с короткой compositing-анимацией.
  ///
  /// Настройки по умолчанию рассчитаны на фиксированные листы: системный
  /// BottomSheet не создаёт лишний drag gesture arena и не перехватывает focus
  /// во время первого кадра. Для действительно перетаскиваемых листов нужно
  /// явно передать [enableDrag].
  static Future<R?> show<R>({
    required BuildContext context,
    required Widget child,
    bool enableDrag = false,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<R>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: false,
      requestFocus: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.none,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 180),
        reverseDuration: Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => child,
    );
  }
}

abstract class BaseCustomModalState<T extends BaseCustomModal>
    extends State<T> {
  final ScrollController _internalScrollController = ScrollController();

  bool get fitContent => false;
  bool get isResizable => true;
  double get initialExtent => 0.65;
  double get minExtent => 0.35;
  double get maxExtent => 0.95;
  Color get backgroundColor => const Color(0xFF141416);

  Widget buildContent(BuildContext context, ScrollController scrollController);

  @override
  void dispose() {
    _internalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    if (fitContent) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: _buildSurface(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  _buildHandle(),
                  const SizedBox(height: 16),
                  buildContent(context, _internalScrollController),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!isResizable) {
      final availableHeight = screenSize.height - bottomInset;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: availableHeight * initialExtent,
          child: _buildSurface(
            child: _buildScrollableBody(
              context,
              _internalScrollController,
            ),
          ),
        ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: initialExtent,
      minChildSize: minExtent,
      maxChildSize: maxExtent,
      expand: false,
      builder: (context, scrollController) => _buildSurface(
        child: _buildScrollableBody(context, scrollController),
      ),
    );
  }

  Widget _buildScrollableBody(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildHandle(),
          const SizedBox(height: 16),
          Expanded(child: buildContent(context, scrollController)),
        ],
      ),
    );
  }

  Widget _buildSurface({required Widget child}) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
