import 'package:flutter/material.dart';

/// Базовый класс для кастомных модальных окон (Bottom Sheet).
/// Реализует общий дизайн, скругленные углы, индикатор перетаскивания (drag handle),
/// кнопку закрытия и плавное пролистывание.
abstract class BaseCustomModal extends StatefulWidget {
  const BaseCustomModal({super.key});
}

abstract class BaseCustomModalState<T extends BaseCustomModal> extends State<T> {
  late final ScrollController _internalScrollController = ScrollController();

  // Мемоизация содержимого модалки.
  // DraggableScrollableSheet.builder вызывается на КАЖДОМ кадре анимации
  // открытия и перетаскивания. Без кэша это означало полную пересборку дерева
  // buildContent() ~60 раз за один вылет модалки — основной источник микрофризов.
  // build() же вызывается только при реальном изменении состояния (setState),
  // поэтому там мы помечаем кэш грязным.
  Widget? _cachedContent;
  ScrollController? _cachedContentController;
  bool _contentDirty = true;

  /// ВАЖНО: наследник обязан выставить `false`, если в buildContent()
  /// подписывается на InheritedWidget/Provider через переданный туда `context`
  /// (`context.watch`, `Provider.of(context)` без listen: false).
  /// Такая подписка регистрируется на элементе билдера, а не на State, и с
  /// включённым кэшем перерисовка по уведомлению провайдера не дойдёт до
  /// содержимого — оно застынет на старых данных.
  /// Подписки внутри вложенных билдеров (itemBuilder у списков и т.п.)
  /// безопасны: они перестраиваются сами по своей зависимости.
  @protected
  bool get cacheContent => true;

  /// Принудительно сбросить кэш содержимого (если наследник меняет данные
  /// в обход setState).
  @protected
  void invalidateContentCache() => _contentDirty = true;

  Widget _contentFor(BuildContext context, ScrollController scrollController) {
    if (!cacheContent) {
      return buildContent(context, scrollController);
    }
    if (_contentDirty ||
        _cachedContent == null ||
        !identical(scrollController, _cachedContentController)) {
      _cachedContent = buildContent(context, scrollController);
      _cachedContentController = scrollController;
      _contentDirty = false;
    }
    // Возвращаем тот же экземпляр виджета — Flutter пропустит перестройку
    // поддерева при кадрах перетаскивания.
    return _cachedContent!;
  }

  /// Автоматически подгонять высоту модалки под контент (без фиксированного DraggableSheet)
  bool get fitContent => false;

  /// Высота модалки при открытии (в процентах от высоты экрана: 0.0 - 1.0)
  double get initialExtent => 0.65;

  /// Минимальная высота модалки при сворачивании
  double get minExtent => 0.35;

  /// Максимальная высота модалки при полном развертывании
  double get maxExtent => 0.95;

  /// Цвет фона модалки
  Color get backgroundColor => const Color(0xFF141416);

  /// Метод для отрисовки содержимого. Должен быть переопределен в наследниках.
  /// Передаваемый [scrollController] должен быть привязан к ListView/SingleChildScrollView
  /// внутри контента для правильной работы перетаскивания модалки.
  Widget buildContent(BuildContext context, ScrollController scrollController);

  @override
  void dispose() {
    _internalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Состояние изменилось — содержимое надо пересобрать (см. _contentFor).
    _contentDirty = true;

    if (fitContent) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  // Индикатор перетаскивания (Drag Handle)
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
                  buildContent(context, _internalScrollController),
                  const SizedBox(height: 16),
                ],
              ),
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
      builder: (context, scrollController) {
        // clipBehavior вместо отдельного ClipRRect: тот добавлял saveLayer
        // на каждый кадр перетаскивания поверх уже скруглённой decoration.
        // Stack с единственным Positioned.fill убран как избыточный.
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Индикатор перетаскивания (Drag Handle)
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
                // Контент наследника (мемоизирован — см. _contentFor)
                Expanded(
                  child: _contentFor(context, scrollController),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
