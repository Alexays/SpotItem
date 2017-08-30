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
    final List<Widget> toBuild = []
      ..add(new FlatButton(
        onPressed: () => onExpandedChanged(!isExpanded),
        textColor: theme.primaryColor,
        child: new Row(
          children: <Widget>[
            const Text('Filter'),
            new Icon(isExpanded ? Icons.expand_more : Icons.expand_less),
          ],
        ),
      ))
      ..add(new Expanded(
        child: new Container(),
      ));
    Services.itemsManager.tracks.value.forEach((track) {
      toBuild.add(
        new Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            decoration: new BoxDecoration(
              color: theme.primaryColor,
              borderRadius: new BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            child: new Row(children: <Widget>[
              getIcon(track, theme.canvasColor),
              const Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5)),
              new Text(
                capitalize(track),
                style: theme.primaryTextTheme.button,
              )
            ])),
      );
    });
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
