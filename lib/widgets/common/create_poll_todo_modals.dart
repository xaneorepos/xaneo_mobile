import 'package:flutter/material.dart';
import '../../styles/app_styles.dart';
import '../../services/runtime_translations.dart';
import 'base_custom_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';

class CreatePollModal extends BaseCustomModal {
  final Function(String question, List<String> options, bool isMultipleChoice)
      onCreate;

  const CreatePollModal({
    super.key,
    required this.onCreate,
  });

  static void show(
      BuildContext context,
      Function(String question, List<String> options, bool isMultipleChoice)
          onCreate) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (context) => CreatePollModal(onCreate: onCreate),
    );
  }

  @override
  State<CreatePollModal> createState() => _CreatePollModalState();
}

class _CreatePollModalState extends BaseCustomModalState<CreatePollModal> {
  @override
  bool get fitContent => true;

  @override
  double get initialExtent => 0.85;
  @override
  double get maxExtent => 0.95;

  final _questionController = TextEditingController();
  final List<TextEditingController> _optionsControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isMultipleChoice = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _optionsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 10),
        Text(
          (AppLocalizations.of(context)?.sozdatOpros_4b9e ?? 'Fallback'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.xaneoTextSecondary,
            letterSpacing: 1.5,
            fontFamily: AppStyles.fontFamily,
          ),
        ),
        const SizedBox(height: 24),

        // Question Input
        TextField(
          controller: _questionController,
          style: TextStyle(color: context.xaneoTextPrimary, fontSize: 15),
          decoration: InputDecoration(
            labelText:
                (AppLocalizations.of(context)?.vopros_0911 ?? 'Fallback'),
            labelStyle: TextStyle(color: context.xaneoTextMuted, fontSize: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.xaneoDivider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.xaneoTextPrimary),
            ),
            filled: true,
            fillColor: context.xaneoOverlay(0.02),
          ),
        ),
        const SizedBox(height: 20),

        // Options Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              (AppLocalizations.of(context)?.variantyOtveta_ef4e ?? 'Fallback'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.xaneoTextSecondary,
                fontFamily: AppStyles.fontFamily,
              ),
            ),
            if (_optionsControllers.length < 10)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _optionsControllers.add(TextEditingController());
                  });
                },
                icon:
                    Icon(Icons.add, size: 16, color: context.xaneoTextPrimary),
                label: Text(
                  RuntimeTranslations.instance.resolve(
                    'messenger.pollModal.addOption',
                    AppLocalizations.of(context)?.dobavit_5eba ?? 'Fallback',
                  ),
                  style:
                      TextStyle(color: context.xaneoTextPrimary, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Options List
        ...List.generate(_optionsControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _optionsControllers[index],
                    style: TextStyle(
                        color: context.xaneoTextPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: RuntimeTranslations.instance.resolve(
                        'messenger.pollModal.optionPlaceholder',
                        '${AppLocalizations.of(context)?.optionHintPrefix ?? 'Option'} ${index + 1}',
                      ),
                      hintStyle: TextStyle(
                          color: context.xaneoTextMuted, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.xaneoDivider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.xaneoTextPrimary),
                      ),
                      filled: true,
                      fillColor: context.xaneoOverlay(0.02),
                    ),
                  ),
                ),
                if (_optionsControllers.length > 2) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: context.xaneoTextMuted, size: 20),
                    onPressed: () {
                      setState(() {
                        final controller = _optionsControllers.removeAt(index);
                        controller.dispose();
                      });
                    },
                  ),
                ],
              ],
            ),
          );
        }),
        SizedBox(height: 10),

        // Multiple Choice Setting
        Theme(
          data: ThemeData(
            unselectedWidgetColor: context.xaneoTextMuted,
          ),
          child: CheckboxListTile(
            title: Text(
              (AppLocalizations.of(context)?.mnozhestvennyyVybor_9b60 ??
                  'Fallback'),
              style: TextStyle(
                  color: context.xaneoTextPrimary,
                  fontSize: 14,
                  fontFamily: AppStyles.fontFamily),
            ),
            value: _isMultipleChoice,
            activeColor: context.xaneoTextPrimary,
            checkColor: Theme.of(context).scaffoldBackgroundColor,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) {
              setState(() {
                _isMultipleChoice = val ?? false;
              });
            },
          ),
        ),
        const SizedBox(height: 24),

        // Submit Button
        ElevatedButton(
          onPressed: () {
            final question = _questionController.text.trim();
            final options = _optionsControllers
                .map((c) => c.text.trim())
                .where((t) => t.isNotEmpty)
                .toList();
            if (question.isEmpty || options.length < 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text((AppLocalizations.of(context)
                            ?.pozhaluystaZapolniteVoprosIKak_7ad5 ??
                        'Fallback'))),
              );
              return;
            }
            Navigator.pop(context);
            widget.onCreate(question, options, _isMultipleChoice);
          },
          style: AppStyles.primaryButton,
          child: Text(
              (AppLocalizations.of(context)?.sozdatOpros_8401 ?? 'Fallback')),
        ),
      ],
    );
  }
}

class CreateTodoModal extends BaseCustomModal {
  final Function(String title, List<String> items) onCreate;

  const CreateTodoModal({
    super.key,
    required this.onCreate,
  });

  static void show(BuildContext context,
      Function(String title, List<String> items) onCreate) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (context) => CreateTodoModal(onCreate: onCreate),
    );
  }

  @override
  State<CreateTodoModal> createState() => _CreateTodoModalState();
}

class _CreateTodoModalState extends BaseCustomModalState<CreateTodoModal> {
  @override
  bool get fitContent => true;

  @override
  double get initialExtent => 0.85;
  @override
  double get maxExtent => 0.95;

  final _titleController = TextEditingController();
  final List<TextEditingController> _itemsControllers = [
    TextEditingController(),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    for (var c in _itemsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 10),
        Text(
          (AppLocalizations.of(context)?.sozdatSpisokZadach_4018 ?? 'Fallback'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.xaneoTextSecondary,
            letterSpacing: 1.5,
            fontFamily: AppStyles.fontFamily,
          ),
        ),
        const SizedBox(height: 24),

        // Title Input
        TextField(
          controller: _titleController,
          style: TextStyle(color: context.xaneoTextPrimary, fontSize: 15),
          decoration: InputDecoration(
            labelText: (AppLocalizations.of(context)?.nazvanieSpiska_c3cc ??
                'Fallback'),
            labelStyle: TextStyle(color: context.xaneoTextMuted, fontSize: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.xaneoDivider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.xaneoTextPrimary),
            ),
            filled: true,
            fillColor: context.xaneoOverlay(0.02),
          ),
        ),
        const SizedBox(height: 20),

        // Items Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              (AppLocalizations.of(context)?.punkty_0481 ?? 'Fallback'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.xaneoTextSecondary,
                fontFamily: AppStyles.fontFamily,
              ),
            ),
            if (_itemsControllers.length < 20)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _itemsControllers.add(TextEditingController());
                  });
                },
                icon:
                    Icon(Icons.add, size: 16, color: context.xaneoTextPrimary),
                label: Text(
                  RuntimeTranslations.instance.resolve(
                    'messenger.todoModal.addItem',
                    AppLocalizations.of(context)?.dobavit_5eba ?? 'Fallback',
                  ),
                  style:
                      TextStyle(color: context.xaneoTextPrimary, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Items List
        ...List.generate(_itemsControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemsControllers[index],
                    style: TextStyle(
                        color: context.xaneoTextPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: RuntimeTranslations.instance.resolve(
                        'messenger.todoModal.itemPlaceholder',
                        '${AppLocalizations.of(context)?.itemHintPrefix ?? 'Item'} ${index + 1}',
                      ),
                      hintStyle: TextStyle(
                          color: context.xaneoTextMuted, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.xaneoDivider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.xaneoTextPrimary),
                      ),
                      filled: true,
                      fillColor: context.xaneoOverlay(0.02),
                    ),
                  ),
                ),
                if (_itemsControllers.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: context.xaneoTextMuted, size: 20),
                    onPressed: () {
                      setState(() {
                        final controller = _itemsControllers.removeAt(index);
                        controller.dispose();
                      });
                    },
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 24),

        // Submit Button
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final items = _itemsControllers
                .map((c) => c.text.trim())
                .where((t) => t.isNotEmpty)
                .toList();
            if (title.isEmpty || items.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text((AppLocalizations.of(context)
                            ?.pozhaluystaZapolniteNazvanieIKak_3783 ??
                        'Fallback'))),
              );
              return;
            }
            Navigator.pop(context);
            widget.onCreate(title, items);
          },
          style: AppStyles.primaryButton,
          child: Text((AppLocalizations.of(context)?.sozdatSpisokZadach_0416 ??
              'Fallback')),
        ),
      ],
    );
  }
}
