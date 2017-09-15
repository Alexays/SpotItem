import 'package:flutter/material.dart';

/// Day picker bar class
class DayPickerBar extends StatefulWidget {
  /// Dau picker bar initalizer
  const DayPickerBar({this.selectedDate, this.onChanged});

  /// Selected day in picker
  final DateTime selectedDate;

  /// Provider a listener when value change
  final ValueChanged<DateTime> onChanged;

  @override
  _DayPickerBarState createState() => new _DayPickerBarState();
}

class _DayPickerBarState extends State<DayPickerBar> {
  _DayPickerBarState();
  DateTime _displayedMonth = new DateTime.now();

  @override
  Widget build(BuildContext context) => new Container(
        color: Theme.of(context).canvasColor,
        height: 330.0,
        child: new Row(
          children: <Widget>[
            new IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _displayedMonth = new DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month - 1,
                  );
                });
              },
            ),
            new Expanded(
              child: new DayPicker(
                selectedDate: widget.selectedDate,
                currentDate: new DateTime.now(),
                displayedMonth: _displayedMonth,
                firstDate: new DateTime.now().subtract(new Duration(days: 1)),
                lastDate: new DateTime.now().add(new Duration(days: 30)),
                onChanged: widget.onChanged,
              ),
            ),
            new IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _displayedMonth = new DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),
      );
}
