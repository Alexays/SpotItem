import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/ui/widgets/calendar_month.dart';
import 'package:spotitem/models/item.dart';

/// Calendar list class
class Calendar extends StatelessWidget {
  /// Creates a day picker.
  ///
  /// Rarely used directly. Instead, typically used as part of a [MonthPicker].
  const Calendar({
    @required this.selectedDates,
    @required this.onChanged,
    this.edit = false,
    this.allowDisable = false,
    Key key,
  })
      : assert(selectedDates != null),
        assert(onChanged != null),
        super(key: key);

  /// The currently selected dates.
  ///
  /// Dates are highlighted in the picker.
  final List<Event> selectedDates;

  /// Is in edit mode
  final bool edit;

  /// Disable days which are after lastDay and before Firstday
  final bool allowDisable;

  /// Called when the user picks a day.
  final ValueChanged<List<Event>> onChanged;

  @override
  Widget build(BuildContext context) {
    final dates = selectedDates.map((f) => f.date.millisecondsSinceEpoch);
    var firstDate, lastDate, nbMonth;
    if (dates.isNotEmpty) {
      final _firstDate = new DateTime.fromMillisecondsSinceEpoch(dates.reduce(math.min));
      final _lastDate = new DateTime.fromMillisecondsSinceEpoch(dates.reduce(math.max));
      firstDate = new DateTime(_firstDate.year, _firstDate.month);
      lastDate = new DateTime(_lastDate.year, _lastDate.month);
      final diff = lastDate.subtract(new Duration(milliseconds: firstDate.millisecondsSinceEpoch));
      nbMonth = (diff.day ~/ 28) + diff.month + (diff.year - 1970) * 12; // 28 equal minimum nb of day in a month
      firstDate = new DateTime(_firstDate.year, _firstDate.month, _firstDate.day);
      lastDate = new DateTime(_lastDate.year, _lastDate.month, _lastDate.day);
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
                    edit: edit,
                    selectedDates: selectedDates,
                    currentMonth:
                        new DateTime(firstDate.year + (firstDate.month + index) ~/ 12, (firstDate.month + index) % 12),
                    firstDate: firstDate,
                    lastDate: lastDate,
                  ),
                )));
  }
}
