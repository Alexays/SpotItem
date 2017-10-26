import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/ui/widgets/calendar_month.dart';

/// Calendar list class
class Calendar extends StatelessWidget {
  /// Creates a day picker.
  ///
  /// Rarely used directly. Instead, typically used as part of a [MonthPicker].
  Calendar({
    @required this.selectedDates,
    @required this.onChanged,
    Key key,
  })
      : assert(selectedDates != null),
        assert(onChanged != null),
        super(key: key);

  /// The currently selected dates.
  ///
  /// Dates are highlighted in the picker.
  final List<DateTime> selectedDates;

  /// The current date
  final DateTime currentDate = new DateTime.now();

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final datesInt = selectedDates.map((f) => f.millisecondsSinceEpoch);
    final firstDate = new DateTime.fromMillisecondsSinceEpoch(datesInt.reduce(math.min), isUtc: true);
    final lastDate = new DateTime.fromMillisecondsSinceEpoch(datesInt.reduce(math.max), isUtc: true);
    final diff = lastDate.subtract(new Duration(milliseconds: firstDate.millisecondsSinceEpoch));
    final nbMonth = diff.month + (diff.year - 1970) * 12 + 1;
    return new Container(
        color: Theme.of(context).canvasColor,
        height: 330.0,
        child: new ListView.builder(
            itemCount: nbMonth,
            itemBuilder: (context, index) => new Container(
                  height: 330.0,
                  child: new CalendarMonth(
                    onChanged: onChanged,
                    selectedDates: selectedDates,
                    currentMonth: new DateTime(firstDate.year + (nbMonth / 12).round(), firstDate.month + index % 12),
                    firstDate: firstDate,
                    lastDate: lastDate,
                  ),
                )));
  }
}
