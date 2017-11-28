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
    this.isExpanded = false,
    Key key,
  });

  /// Called when the tracks changed.
  final ValueChanged<List<String>> onChanged;

  /// Called when the filter bar expand
  final ValueChanged<bool> onExpand;

  /// Fitler bar is expanded
  final bool isExpanded;

  /// Size of filter bar, default is 36.0 (height of button)
  @override
  Size get preferredSize {
    return new Size.fromHeight(isExpanded ? 110.0 : 36.0);
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new MaterialButton(
          onPressed: () => onExpand(isExpanded),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
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
                        checked: Services.items.tracks.value.contains('name'),
                        value: f,
                        child: new Text(SpotL.of(context).name),
                      );
                    case 'dist':
                      return new CheckedPopupMenuItem(
                        checked: Services.items.tracks.value.contains('dist') ||
                            !Services.items.tracks.value.any(
                                (f) => Services.items.sortMethod.contains(f)),
                        value: f,
                        child: new Text(SpotL.of(context).dist),
                      );
                  }
                }).toList(),
            onSelected: (action) => onChanged(
                  Services.items.tracks.value = [
                    Services.items.tracks.value
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
  }
}
