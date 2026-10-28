import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'package:provider/provider.dart';
import '../providers/appearance_provider.dart';

/// Matches the create/edit community modals, including their XNX palette.
class ScheduledModalStyle {
  const ScheduledModalStyle._(
      {required this.mobile,
      required this.scale,
      required this.text,
      required this.secondary,
      required this.muted,
      required this.surface,
      required this.panel,
      required this.input,
      required this.border,
      required this.button,
      required this.buttonText,
      required this.radius});
  final bool mobile;
  final double scale;
  final double radius;
  final Color text,
      secondary,
      muted,
      surface,
      panel,
      input,
      border,
      button,
      buttonText;
  factory ScheduledModalStyle.of(BuildContext context) {
    final appearance = context.read<AppearanceProvider>();
    return ScheduledModalStyle._(
        mobile: true,
        scale: 1,
        text: context.xaneoTextPrimary,
        secondary: context.xaneoTextSecondary,
        muted: context.xaneoTextMuted,
        surface: context.xaneoSurface,
        panel: context.xaneoSurfaceElevated,
        input: context.xaneoOverlay(.05),
        border: context.xaneoDivider,
        button: appearance.xnxColor('btn-primary-bg') ??
            appearance.xnxColor('accent') ??
            context.xaneoTextPrimary,
        buttonText: appearance.xnxColor('btn-primary-text') ??
            Theme.of(context).scaffoldBackgroundColor,
        radius: context.xaneoRadius(14));
  }

  TextStyle get fieldTextStyle =>
      TextStyle(color: text, fontSize: (mobile ? 15 : 14) * scale);
  double get gap => 18 * scale;
  ThemeData theme(ThemeData base) {
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    final outline = OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: border));
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
          surface: surface,
          onSurface: text,
          primary: button,
          onPrimary: buttonText,
          outline: border),
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      iconTheme: IconThemeData(color: secondary, size: 18 * scale),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: input,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
        hintStyle: TextStyle(fontSize: 13 * scale, color: muted),
        counterStyle: TextStyle(fontSize: 11 * scale, color: muted),
        border: outline,
        enabledBorder: outline,
        disabledBorder: outline,
        focusedBorder:
            outline.copyWith(borderSide: BorderSide(color: secondary)),
      ),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
        backgroundColor: button,
        foregroundColor: buttonText,
        disabledBackgroundColor: button.withValues(alpha: .15),
        disabledForegroundColor: text.withValues(alpha: .35),
        elevation: 0,
        shape: shape,
        minimumSize: Size(0, (mobile ? 52 : 40) * scale),
        padding:
            EdgeInsets.symmetric(horizontal: 22 * scale, vertical: 12 * scale),
        textStyle: base.textTheme.labelLarge!.copyWith(
            fontSize: (mobile ? 16 : 13) * scale, fontWeight: FontWeight.w600),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
        backgroundColor: input,
        foregroundColor: text,
        side: BorderSide(color: border),
        shape: shape,
        minimumSize: Size(0, 42 * scale),
        padding:
            EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
        textStyle: base.textTheme.labelLarge!
            .copyWith(fontSize: 13 * scale, fontWeight: FontWeight.w500),
      )),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        foregroundColor: secondary,
        shape: shape,
        minimumSize: Size(0, 36 * scale),
        padding:
            EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
        textStyle: base.textTheme.labelLarge!
            .copyWith(fontSize: 13 * scale, fontWeight: FontWeight.w500),
      )),
      iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
        foregroundColor: secondary,
        iconSize: 18 * scale,
        shape: shape,
      )),
    );
  }
}

class ScheduledModalHeader extends StatelessWidget {
  const ScheduledModalHeader(
      {super.key, required this.title, this.actions = const []});
  final String title;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) {
    final style = ScheduledModalStyle.of(context);
    return Padding(
        padding: EdgeInsets.only(bottom: style.gap),
        child: Row(children: [
          Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: style.text,
                      fontSize: (style.mobile ? 19 : 18) * style.scale,
                      fontWeight:
                          style.mobile ? FontWeight.w600 : FontWeight.w700,
                      letterSpacing: style.mobile ? -.4 : 0))),
          ...actions,
        ]));
  }
}

class ScheduledModalLabel extends StatelessWidget {
  const ScheduledModalLabel(
      {super.key, required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final style = ScheduledModalStyle.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(label,
          style: TextStyle(
              color: style.secondary,
              fontSize: 12 * style.scale,
              fontWeight: FontWeight.w600)),
      SizedBox(height: 8 * style.scale),
      child,
    ]);
  }
}

class ScheduledModalFooter extends StatelessWidget {
  const ScheduledModalFooter(
      {super.key,
      required this.label,
      required this.onSave,
      required this.onCancel,
      required this.cancelLabel,
      this.busy = false});
  final String label;
  final String cancelLabel;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool busy;
  @override
  Widget build(BuildContext context) {
    final style = ScheduledModalStyle.of(context);
    final button = FilledButton(
        onPressed: busy ? null : onSave,
        child: busy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: style.buttonText))
            : Text(label));
    return Padding(
        padding: EdgeInsets.only(
            top: style.gap, bottom: style.mobile ? 0 : 8 * style.scale),
        child: style.mobile
            ? SizedBox(width: double.infinity, child: button)
            : Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    onPressed: busy ? null : onCancel,
                    child: Text(cancelLabel)),
                SizedBox(width: 8 * style.scale),
                button,
              ]));
  }
}

class ScheduledModalPanel extends StatelessWidget {
  const ScheduledModalPanel(
      {super.key, required this.child, this.padding = 14});
  final Widget child;
  final double padding;
  @override
  Widget build(BuildContext context) {
    final style = ScheduledModalStyle.of(context);
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(padding * style.scale),
        decoration: BoxDecoration(
            color: style.panel,
            border: Border.all(color: style.border),
            borderRadius: BorderRadius.circular(style.radius)),
        child: child);
  }
}
