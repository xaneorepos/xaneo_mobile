import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/styles/app_styles.dart';
import 'package:xaneo/widgets/common/confirm_action_modal.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('confirmation modal has readable text in $brightness theme',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: const Scaffold(
          body: ConfirmActionModal(
            title: 'Contrast title',
            message: 'Contrast body',
            confirmLabel: 'Confirm',
          ),
        ),
      ));

      final title = tester.widget<Text>(find.text('Contrast title'));
      final body = tester.widget<Text>(find.text('Contrast body'));
      final surface = brightness == Brightness.dark
          ? const Color(0xFF141416)
          : Colors.white;

      expect(
          _contrast(title.style!.color!, surface), greaterThanOrEqualTo(4.5));
      expect(_contrast(body.style!.color!, surface), greaterThanOrEqualTo(4.5));
    });
  }

  test('shared typography does not force dark-theme colors', () {
    expect(AppStyles.titleLarge.color, isNull);
    expect(AppStyles.bodyMedium.color, isNull);
    expect(AppStyles.bodyMuted.color, isNull);
    expect(AppStyles.inputText.color, isNull);
  });
}

double _contrast(Color first, Color second) {
  final light = first.computeLuminance();
  final dark = second.computeLuminance();
  final high = light > dark ? light : dark;
  final low = light > dark ? dark : light;
  return (high + 0.05) / (low + 0.05);
}
