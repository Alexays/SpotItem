import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  /// Whether this filter bar is showing the day picker or not
  final bool isExpanded;

  /// Called when the user toggles expansion
  final ValueChanged<bool> onExpandedChanged;

  const FilterBar({this.isExpanded, this.onExpandedChanged});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Container(
      height: 40.0,
      color: Theme.of(context).canvasColor,
      child: new Row(
        children: <Widget>[
          new FlatButton(
            onPressed: () => onExpandedChanged(!isExpanded),
            textColor: theme.primaryColor,
            child: new Row(
              children: <Widget>[
                const Text('Filter'),
                new Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          new Expanded(
            child: new Container(),
          ),
          new Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: new BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(7.0),
            child: new Text(
              'All items',
              style: theme.primaryTextTheme.button,
            ),
          ),
          new Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(7.0),
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
