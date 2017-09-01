import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';

class FilterBar extends StatelessWidget {
  /// Whether this filter bar is showing the day picker or not
  final bool isExpanded;

  /// Called when the user toggles expansion
  final ValueChanged<bool> onExpandedChanged;

  const FilterBar({this.isExpanded, this.onExpandedChanged});

  List<Widget> _buildBar(ThemeData theme) {
    final List<Widget> toBuild = [];
    Services.items.tracks.value.forEach((track) {
      toBuild
        ..add(
            const Padding(padding: const EdgeInsets.symmetric(horizontal: 2.5)))
        ..add(new Chip(
          avatar: new CircleAvatar(
            backgroundColor: theme.primaryColor,
            child: getIcon(track, theme.canvasColor),
          ),
          label: new Text(capitalize(track)),
        ));
    });
    toBuild
      ..add(new Expanded(
        child: new Container(),
      ))
      ..add(new FlatButton(
        onPressed: () => onExpandedChanged(!isExpanded),
        textColor: theme.primaryColor,
        child: new Row(
          children: <Widget>[
            const Text('Filter'),
            new Icon(isExpanded ? Icons.expand_more : Icons.expand_less),
          ],
        ),
      ));
    return toBuild;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Container(
      color: Theme.of(context).canvasColor,
      child: new Row(children: _buildBar(theme)),
    );
  }
}
