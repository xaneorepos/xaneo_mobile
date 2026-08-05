import 'package:flutter/material.dart';
import '../../models/update/app_version_info.dart';
import '../update_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Компактный плавающий Тост-баннер уведомления об обновлении (выезжает из навигационной панели)
class CustomUpdateToast extends StatefulWidget {
  final AppVersionInfo updateInfo;
  final VoidCallback onDismiss;

  const CustomUpdateToast({
    super.key,
    required this.updateInfo,
    required this.onDismiss,
  });

  /// Вспомогательный метод для показа тоста из навигационной панели через Overlay
  static OverlayEntry show(BuildContext context, AppVersionInfo updateInfo) {
    late OverlayEntry entry;
    final bottomOffset = MediaQuery.of(context).padding.bottom + 84;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: bottomOffset,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: CustomUpdateToast(
              updateInfo: updateInfo,
              onDismiss: () {
                entry.remove();
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  State<CustomUpdateToast> createState() => _CustomUpdateToastState();
}

class _CustomUpdateToastState extends State<CustomUpdateToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Анимация выезда снизу из-за навигационной панели
    _slideAnimation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Future<void> _handleTap() async {
    final navigatorState = Navigator.of(context);
    final updateInfo = widget.updateInfo;
    await _dismiss();
    XaneoUpdateModal.open(navigatorState.context, updateInfo);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleText =
        AppLocalizations.of(context)?.updateAvailable ?? 'Доступно обновление';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.down,
              onDismissed: (_) {
                widget.onDismiss();
              },
              child: GestureDetector(
                onTap: _handleTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xF2141416)
                        : const Color(0xF21F2937),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Черно-белый логотип / иконка
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          color: Colors.black,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$titleText v${widget.updateInfo.version}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
