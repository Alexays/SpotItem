import 'package:flutter/material.dart';

class DayPickerBar extends StatefulWidget {
  DayPickerBar({this.selectedDate, this.onChanged});

  final DateTime selectedDate;

  final ValueChanged<DateTime> onChanged;

  DayPickerBarState createState() => new DayPickerBarState();
}

class DayPickerBarState extends State<DayPickerBar> {
  DateTime _displayedMonth = new DateTime.now();

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Theme.of(context).canvasColor,
      height: 250.0,
      child: new Row(
        children: <Widget>[
          new IconButton(
            icon: new Icon(Icons.chevron_left),
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
            icon: new Icon(Icons.chevron_right),
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
}
