import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:xaneo/models/xnx_theme.dart';
import 'package:xaneo/providers/appearance_provider.dart';
import 'package:xaneo/screens/webrtc/active_call_screen.dart';
import 'package:xaneo/screens/webrtc/group_active_call_screen.dart';
import 'package:xaneo/screens/webrtc/incoming_call_screen.dart';
import 'package:xaneo/services/webrtc/call_manager.dart';
import 'package:xaneo/styles/appearance_typography.dart';
import 'package:xaneo/widgets/common/chat_action_sheet.dart';
import 'package:xaneo/widgets/common/create_poll_todo_modals.dart';
import 'package:xaneo/widgets/common/liquid_glass_nav_bar.dart';
import 'package:xaneo/widgets/common/themed_cupertino_date_picker.dart';

class _Appearance extends ChangeNotifier implements AppearanceProvider {
  _Appearance(this.xnxTheme);

  @override
  final XnxTheme xnxTheme;
  @override
  bool get animationsEnabled => false;
  @override
  Color? xnxColor(String key, {bool? dark}) =>
      xnxTheme.color(key, dark ?? true);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Calls extends ChangeNotifier implements CallManager {
  @override
  CallState get state => CallState.outgoing;
  @override
  String get callType => 'audio';
  @override
  bool get isGroupCall => false;
  @override
  String? get targetUserId => null;
  @override
  String get targetName => 'Caller';
  @override
  String? get targetAvatar => null;
  @override
  String? get targetGradient => null;
  @override
  bool get isMicrophoneMuted => false;
  @override
  bool get isCameraOff => true;
  @override
  bool get isSpeakerOn => false;
  @override
  bool get isNearEar => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final brightness in Brightness.values) {
    final dark = brightness == Brightness.dark;
    final xnx = XnxTheme.preset('Paper')
        .withRadius(22)
        .withFontFamily('Onest')
        .withColor('text-muted', const Color(0xFF765432), dark);
    final appearance = _Appearance(xnx);
    final calls = _Calls();
    final theme = applyAppearanceFont(
      ThemeData(brightness: brightness).copyWith(
        scaffoldBackgroundColor: xnx.color('bg', dark),
        cardColor: xnx.color('surface', dark),
        dividerColor: xnx.color('border', dark),
        colorScheme: ThemeData(brightness: brightness).colorScheme.copyWith(
              primary: xnx.color('accent', dark),
              secondary: xnx.color('text-secondary', dark),
              onSurface: xnx.color('text', dark),
            ),
      ),
      'Onest',
    );

    Widget app(Widget child, {ThemeData? override}) => MultiProvider(
          providers: [
            ChangeNotifierProvider<AppearanceProvider>.value(value: appearance),
            ChangeNotifierProvider<CallManager>.value(value: calls),
          ],
          child: MaterialApp(
            theme: override ?? theme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: Scaffold(body: child),
          ),
        );

    testWidgets('birthday wheel follows font changes in $brightness',
        (tester) async {
      final picker = SizedBox(
        height: 220,
        child: ThemedCupertinoDatePicker(
          initialDateTime: DateTime(2000),
          minimumDate: DateTime(1900),
          maximumDate: DateTime(2026),
          onDateTimeChanged: (_) {},
        ),
      );
      for (final family in ['Onest', 'Geist']) {
        await tester.pumpWidget(
            app(picker, override: applyAppearanceFont(theme, family)));
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(CupertinoDatePicker));
        final style =
            CupertinoTheme.of(context).textTheme.dateTimePickerTextStyle;
        expect(style.fontFamily, family);
        expect(style.color, xnx.color('text', dark));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('navigation and action sheet use XNX in $brightness',
        (tester) async {
      await tester.pumpWidget(app(LiquidGlassNavBar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
      )));
      final styles = tester
          .widgetList<AnimatedDefaultTextStyle>(
              find.byType(AnimatedDefaultTextStyle))
          .where((widget) =>
              widget.style.fontSize == 10 || widget.style.fontSize == 9);
      expect(styles.first.style.fontFamily, 'Onest');
      expect(styles.first.style.color, xnx.color('accent', dark));
      expect(styles.last.style.color, const Color(0xFF765432));
      final panel = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere((widget) => widget.decoration is BoxDecoration);
      expect((panel.decoration! as BoxDecoration).borderRadius,
          BorderRadius.circular(22));

      await tester.pumpWidget(app(ChatActionSheet(actions: [
        ChatSheetAction(
            icon: Icons.phone,
            title: 'Call',
            subtitle: 'Audio',
            onSelected: () {}),
      ])));
      expect(tester.widget<Text>(find.text('Call')).style!.color,
          xnx.color('text', dark));
      expect(tester.widget<Text>(find.text('Audio')).style!.color,
          const Color(0xFF765432));
      expect(tester.takeException(), isNull);
    });

    testWidgets('poll checkbox preserves font and colors in $brightness',
        (tester) async {
      await tester.pumpWidget(app(CreatePollModal(onCreate: (_, __, ___) {})));
      final context = tester.element(find.byType(CheckboxListTile));
      expect(Theme.of(context).textTheme.bodyMedium!.fontFamily, 'Onest');
      expect(Theme.of(context).colorScheme.primary, xnx.color('accent', dark));
      await tester.pumpWidget(app(CreateTodoModal(onCreate: (_, __) {})));
      for (final input
          in tester.widgetList<TextField>(find.byType(TextField))) {
        final border = input.decoration!.enabledBorder! as OutlineInputBorder;
        expect(border.borderRadius, BorderRadius.circular(22));
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('call screens inherit XNX in $brightness', (tester) async {
      for (final screen in [
        const ActiveCallScreen(),
        const GroupActiveCallScreen(),
        const IncomingCallScreen()
      ]) {
        await tester.pumpWidget(app(screen));
        await tester.pump();
        final context = tester.element(find.byWidget(screen));
        final scaffold = tester.widget<Scaffold>(find
            .descendant(
                of: find.byWidget(screen), matching: find.byType(Scaffold))
            .first);
        expect(scaffold.backgroundColor, xnx.color('bg', dark));
        expect(Theme.of(context).textTheme.bodyMedium!.fontFamily, 'Onest');
        expect(
            tester.widget<Text>(find.text('Caller').first).style!.color,
            xnx.color(screen is IncomingCallScreen ? 'text-secondary' : 'text',
                dark));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
