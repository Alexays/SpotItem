import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Filter Bar class
class FilterBar extends StatelessWidget implements PreferredSizeWidget {
  /// Filter Bar initializer
  const FilterBar({
    @required this.onChanged,
    @required this.onExpand,
    @required this.tracks,
    this.isExpanded = false,
    Key key,
  });

  /// Item tracks
  final List<String> tracks;

  /// Called when the tracks changed.
  final ValueChanged<List<String>> onChanged;

  /// Called when the filter bar expand
  final ValueChanged<bool> onExpand;

  /// Fitler bar is expanded
  final bool isExpanded;

  /// Size of filter bar, default is 36.0 (height of button)
  @override
  Size get preferredSize => new Size.fromHeight(isExpanded ? 161.0 : 36.0);

  Widget _buildBar(BuildContext context) => new Row(
        children: <Widget>[
          new MaterialButton(
            onPressed: () => onExpand(isExpanded),
            child: new Row(
              children: <Widget>[
                const Text(
                  'Filter',
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                )
              ],
            ),
          ),
          new Expanded(
            child: new PopupMenuButton(
              padding: ButtonTheme.of(context).padding,
              child: new ConstrainedBox(
                constraints: new BoxConstraints(
                  minWidth: ButtonTheme.of(context).minWidth,
                  minHeight: ButtonTheme.of(context).height,
                ),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Sort by',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              itemBuilder: (context) => Services.items.sortMethod.map((f) {
                    switch (f) {
                      case 'name':
                        return new CheckedPopupMenuItem(
                          checked: tracks.contains('name'),
                          value: f,
                          child: new Text(SpotL.of(context).name),
                        );
                      case 'dist':
                        return new CheckedPopupMenuItem(
                          checked: tracks.contains('dist') ||
                              !tracks.any(
                                  (f) => Services.items.sortMethod.contains(f)),
                          value: f,
                          child: new Text(SpotL.of(context).dist),
                        );
                    }
                  }).toList(),
              onSelected: (action) => onChanged(
                    [
                      tracks
                          .where((f) =>
                              !Services.items.sortMethod.any((d) => d == f))
                          .toList(),
                      [action]
                    ].expand((x) => x).toList(),
                  ),
            ),
          ),
          new MaterialButton(
            onPressed: () {},
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Advanced',
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final widgets = [
      _buildBar(context),
    ];
    if (isExpanded) {
      widgets.add(
        new Container(
          height: 125.0,
          width: MediaQuery.of(context).size.width,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                decoration: new BoxDecoration(
                  border: new Border.all(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                width: MediaQuery.of(context).size.width * 30 / 100,
                child: new ListView(
                  padding: const EdgeInsets.all(10.0),
                  itemExtent: 30.0,
                  children: <Widget>[
                    new InkWell(
                      onTap: () {},
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new Text(
                              'Categories',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              new Expanded(
                child: new Container(
                  height: 125.0,
                  color: Theme.of(context).accentColor,
                  child: new GridView.count(
                    padding: const EdgeInsets.all(15.0),
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    children: Services.items.categories.map((f) {
                      if (tracks.contains(f)) {
                        new RaisedButton(
                          child: new Image.asset('assets/$f.png'),
                          onPressed: () => tracks.remove(f),
                        );
                      }
                      return new FlatButton(
                        child: new Image.asset('assets/$f.png'),
                        onPressed: () => onChanged(tracks
                            .where((f) =>
                                !Services.items.categories.any((d) => d == f))
                            .toList()
                              ..add(f)),
                      );
                    }).toList(),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
