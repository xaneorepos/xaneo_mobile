import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/main.dart';

void main() {
  testWidgets('disabled animation policy exposes reduced motion',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AppAnimationPolicy(
        enabled: false,
        mediaQuery: MediaQueryData(),
        child: _TickerProbe(),
      ),
    ));

    expect(
      tester
          .widget<MediaQuery>(find.byType(MediaQuery).last)
          .data
          .disableAnimations,
      isTrue,
    );
  });
}

class _TickerProbe extends StatelessWidget {
  const _TickerProbe();

  @override
  Widget build(BuildContext context) => const SizedBox();
}
