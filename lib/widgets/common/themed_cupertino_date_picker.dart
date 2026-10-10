import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../styles/app_styles.dart';

/// Keeps the date wheel on the same font and palette as the Material app.
class ThemedCupertinoDatePicker extends StatelessWidget {
  const ThemedCupertinoDatePicker({
    super.key,
    required this.initialDateTime,
    required this.minimumDate,
    required this.maximumDate,
    required this.onDateTimeChanged,
  });

  final DateTime initialDateTime;
  final DateTime minimumDate;
  final DateTime maximumDate;
  final ValueChanged<DateTime> onDateTimeChanged;

  @override
  Widget build(BuildContext context) {
    final material = Theme.of(context);
    final inherited = CupertinoTheme.of(context);
    return CupertinoTheme(
      data: inherited.copyWith(
        brightness: material.brightness,
        scaffoldBackgroundColor: context.xaneoSurface,
        textTheme: inherited.textTheme.copyWith(
          dateTimePickerTextStyle: material.textTheme.bodyMedium!.copyWith(
            color: context.xaneoTextPrimary,
            fontSize: 22,
          ),
        ),
      ),
      child: CupertinoDatePicker(
        backgroundColor: context.xaneoSurface,
        mode: CupertinoDatePickerMode.date,
        initialDateTime: initialDateTime,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        onDateTimeChanged: onDateTimeChanged,
      ),
    );
  }
}
