import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  FilterBar({this.isExpanded, this.onExpandedChanged});

  /// Whether this filter bar is showing the day picker or not
  final bool isExpanded;

  /// Called when the user toggles expansion
  final ValueChanged<bool> onExpandedChanged;

  static const Color _kFilterColor = Colors.deepOrangeAccent;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return new Container(
      color: Theme.of(context).canvasColor,
      child: new Row(
        children: <Widget>[
          new FlatButton(
            onPressed: () => onExpandedChanged(!isExpanded),
            textColor: theme.primaryColor,
            child: new Row(
              children: <Widget>[
                new Text('Watch Today'),
                new Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          new Expanded(
            child: new Container(),
          ),
          new Container(
            decoration: new BoxDecoration(
              color: _kFilterColor,
              borderRadius: new BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(6.0),
            child: new Text(
              'All items',
              style: theme.primaryTextTheme.button,
            ),
          ),
          new Container(
            decoration: new BoxDecoration(
              color: _kFilterColor,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6.0),
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: new Text(
              ' + ',
              style: theme.primaryTextTheme.button,
            ),
          ),
        ],
      ),
    );
  }
}
