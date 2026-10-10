import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/styles/app_styles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('selectable font families are bundled', () async {
    final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json'))
        as List<dynamic>;
    final families = manifest.map((entry) => entry['family']).toSet();
    expect(families, containsAll(<String>['Inter', 'Onest', 'Geist']));
  });

  testWidgets('interface text style inherits selected font', (tester) async {
    for (final family in <String>['Onest', 'Geist']) {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(fontFamily: family),
        home: const Scaffold(
          body: Text('Оформление', style: AppStyles.titleLarge),
        ),
      ));
      await tester.pumpAndSettle();
      final element = tester.element(find.text('Оформление'));
      final label = tester.widget<Text>(find.text('Оформление'));
      expect(DefaultTextStyle.of(element).style.merge(label.style).fontFamily,
          family);
    }
  });
}
