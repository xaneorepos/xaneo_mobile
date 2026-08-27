import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../styles/app_styles.dart';

class SixDigitCodeInput extends StatefulWidget {
  const SixDigitCodeInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.autofocus = true,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<SixDigitCodeInput> createState() => _SixDigitCodeInputState();
}

class _SixDigitCodeInputState extends State<SixDigitCodeInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant SixDigitCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _focus() {
    (widget.focusNode ?? FocusScope.of(context)).requestFocus(
      widget.focusNode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const codeLength = 6;
        const spacing = 8.0;
        final availableWidth = constraints.maxWidth - spacing * 5;
        final calculatedWidth = availableWidth / codeLength;
        final boxWidth = calculatedWidth.clamp(36.0, 48.0);
        final rowWidth = boxWidth * codeLength + spacing * 5;

        return Center(
          child: SizedBox(
            width: rowWidth,
            height: 56,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _focus,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(codeLength, (index) {
                      return Container(
                        width: boxWidth,
                        height: 56,
                        margin: EdgeInsets.only(
                          right: index == codeLength - 1 ? 0 : spacing,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.controller.text.length > index
                              ? widget.controller.text[index]
                              : '',
                          style: AppStyles.titleLarge.copyWith(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      autofocus: widget.autofocus,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: codeLength,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        color: Colors.transparent,
                        fontSize: 1,
                      ),
                      cursorColor: Colors.transparent,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
