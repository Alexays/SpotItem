import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  /// Whether this filter bar is showing the day picker or not
  final bool isExpanded;

  /// Called when the user toggles expansion
  final ValueChanged<bool> onExpandedChanged;

  const FilterBar({this.isExpanded, this.onExpandedChanged});

  @override
  Widget build(BuildContext context) => new MaterialButton(
        onPressed: () => onExpandedChanged(!isExpanded),
        textColor: Colors.white,
        child: new Row(
          children: <Widget>[
            const Text('Filter'),
            new Icon(isExpanded ? Icons.expand_more : Icons.expand_less),
          ],
        ),
      );
}
