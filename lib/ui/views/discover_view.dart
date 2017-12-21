import 'dart:async';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/ui/widgets/item.dart';
import 'package:spotitem/ui/screens/items/item_screen.dart';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Discover view class
class DiscoverView extends StatefulWidget {
  /// Discoverview initializer
  const DiscoverView();

  @override
  State<StatefulWidget> createState() => new _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  List<Item> _items;
  List<Item> _recents;
  List<Item> _groups;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<Null> _loadItems([bool force = false]) async {
    final data = await Services.items.getAll(force: force);
    if (!mounted || data == null) {
      return;
    }
    setState(() {
      _items = data;
      _recents = new List<Item>.from(_items)
          .where((item) => !item.tracks.contains('group'))
          .toList();
      if (_recents.length > 10) {
        _recents.length = 10;
      }
      _groups = new List<Item>.from(_items)
          .where((item) => item.tracks.contains('group'))
          .toList();
      if (_groups.length > 10) {
        _groups.length = 10;
      }
    });
  }

  Widget _buildRecents(BuildContext context) => new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
            child: new Text(
              SpotL.of(context).recentItems,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 25.0,
              ),
            ),
          ),
          new Container(
            height: 250.0,
            child: new DiscoverList(_recents, 0),
          ),
        ],
      );

  Widget _buildGroups(BuildContext context) {
    if (_groups.isEmpty) {
      return new Container();
    }
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Text(
            SpotL.of(context).trackgroup,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25.0,
            ),
          ),
        ),
        new Container(
          height: 250.0,
          child: new DiscoverList(_groups, 1),
        )
      ],
    );
  }

  Widget _buildDiscover() {
    final _widgets = [_buildRecents, _buildGroups];
    return new ListView.builder(
      itemCount: _widgets.length,
      itemBuilder: (context, index) => _widgets[index](context),
    );
  }

  @override
  Widget build(BuildContext context) => new RefreshIndicator(
        onRefresh: () => _loadItems(true),
        child: _items == null
            ? const Center(child: const CircularProgressIndicator())
            : _buildDiscover(),
      );
}

/// Discover list class
class DiscoverList extends StatelessWidget {
  final List<Item> _items;
  final num _hash;

  /// Discover list initializer
  const DiscoverList(this._items, this._hash);

  @override
  Widget build(BuildContext context) => _items.isNotEmpty
      ? new ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(), // RefreshIndicator
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          itemCount: _items?.length,
          itemExtent: 275.0,
          itemBuilder: (context, index) => new ItemsListItem(
                item: _items[index],
                hash: _hash,
                onPressed: () => showItemPage(_items[index], _hash, context),
              ),
        )
      : new Center(child: new Text(SpotL.of(context).noItems));
}
