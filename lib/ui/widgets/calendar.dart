import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/ui/widgets/calendar_month.dart';

/// Calendar list class
class Calendar extends StatelessWidget {
  /// Creates a day picker.
  ///
  /// Rarely used directly. Instead, typically used as part of a [MonthPicker].
  const Calendar({
    @required this.selectedDates,
    @required this.onChanged,
    this.allowDisable = false,
    Key key,
  })
      : assert(selectedDates != null),
        assert(onChanged != null),
        super(key: key);

  /// The currently selected dates.
  ///
  /// Dates are highlighted in the picker.
  final List<DateTime> selectedDates;

  ///Disable days which are after lastDay and before Firstday
  final bool allowDisable;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final dates = selectedDates.map((f) => f.millisecondsSinceEpoch);
    var firstDate, lastDate, diff, nbMonth;
    if (dates.isNotEmpty) {
      firstDate = new DateTime.fromMillisecondsSinceEpoch(dates.reduce(math.min));
      lastDate = new DateTime.fromMillisecondsSinceEpoch(dates.reduce(math.max));
      diff = lastDate.subtract(new Duration(milliseconds: firstDate.millisecondsSinceEpoch));
      nbMonth = diff.month + (diff.year - 1970) * 12 + 1;
    } else {
      lastDate = firstDate = new DateTime.now();
      nbMonth = 1;
    }
    return new Container(
        color: Theme.of(context).canvasColor,
        height: 330.0,
        child: new ListView.builder(
            itemCount: !allowDisable ? nbMonth : null,
            itemBuilder: (context, index) => new Container(
                  height: 330.0,
                  child: new CalendarMonth(
                    allowDisable: allowDisable,
                    onChanged: onChanged,
                    selectedDates: selectedDates,
                    currentMonth:
                        new DateTime(firstDate.year + (firstDate.month + index) ~/ 12, (firstDate.month + index) % 12),
                    firstDate: firstDate,
                    lastDate: lastDate,
                  ),
                )));
  }
}
