import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scale_provider.dart';

/// Кастомное базовое модальное окно Xaneo PC.
/// Построено ровно по тому же принципу, анимации (Fade+Scale) и дизайну,
/// что и модальное окно смены аккаунтов (Account Switcher) и модалка информации о чате.
abstract class BaseCustomModal extends StatefulWidget {
  final String modalTag;
  final String title;

  const BaseCustomModal({
    super.key,
    this.modalTag = '',
    this.title = '',
  });

  /// Вызов модального окна через showGeneralDialog в едином стиле Xaneo PC
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget modal,
    String barrierLabel = 'XaneoModal',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showGeneralDialog<T>(
      context: context,
      barrierLabel: barrierLabel,
      barrierDismissible: true,
      barrierColor: isDark
          ? Colors.black.withValues(alpha: 0.85)
          : Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) => modal,
    );
  }
}

abstract class BaseCustomModalState<T extends BaseCustomModal> extends State<T> {
  late final ScrollController internalScrollController = ScrollController();

  /// Базовая ширина модалки в логических пикселях (умножается на scale)
  double get modalWidth => 520.0;

  /// Процент максимальной высоты экрана
  double get modalHeightFactor => 0.80;

  /// Метод отрисовки содержимого
  Widget buildContent(BuildContext context, ScrollController scrollController, bool isDark, double scale);

  @override
  void dispose() {
    internalScrollController.dispose();
    super.dispose();
  }

  /// Получение заголовка модального окна (переопределяется в наследниках для динамической локализации)
  String getModalTitle(BuildContext context) {
    if (widget.modalTag.isNotEmpty) return widget.modalTag.toUpperCase();
    if (widget.title.isNotEmpty) return widget.title.toUpperCase();
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaleProvider = Provider.of<ScaleProvider>(context, listen: false);
    final scale = scaleProvider.scale;
    final screenSize = MediaQuery.of(context).size;

    final bgColor = isDark ? const Color(0xFF0C0C0C) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB);

    final headerText = getModalTitle(context);

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: modalWidth * scale,
          constraints: BoxConstraints(
            maxHeight: screenSize.height * modalHeightFactor,
          ),
          margin: EdgeInsets.all(20 * scale),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.06),
                blurRadius: 24 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Шапка (Заголовок категории в стиле Account Switcher + кнопка Закрыть)
                Padding(
                  padding: EdgeInsets.fromLTRB(20 * scale, 18 * scale, 20 * scale, 12 * scale),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        headerText,
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5 * scale,
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontFamily: 'Inter',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(
                            Icons.close_rounded,
                            size: 18 * scale,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Контент
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 18 * scale),
                    child: buildContent(context, internalScrollController, isDark, scale),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
