import 'dart:async';

import 'package:spotitem/models/item.dart';
import 'package:spotitem/ui/widgets/item.dart';
import 'package:spotitem/ui/views/item_view.dart';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';

/// Discover view class
class DiscoverView extends StatefulWidget {
  /// Discoverview initializer
  const DiscoverView();

  @override
  State<StatefulWidget> createState() => new _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  static List<Item> _items;

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  Future<Null> _loadItems([bool force = false]) async {
    final Future<List<Item>> itemsLoaded =
        Services.items.getItems(force: force);
    if (itemsLoaded == null) {
      return;
    }
    itemsLoaded.then((data) {
      if (!mounted) {
        return;
      }
      setState(() {
        _items = data;
      });
    });
  }

  Widget _buildDiscover() => new ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            List<Item> recents = new List<Item>.from(_items);
            recents = recents
                .where((item) => !item.tracks.contains('group'))
                .toList();
            if (recents.length > 10) {
              recents.length = 10;
            }
            return new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: const Text(
                    'Recents items',
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 20.0),
                  ),
                ),
                new Container(
                  height: 200.0,
                  child: new DiscoverList(recents, 'recents'),
                ),
              ],
            );
          case 1:
            List<Item> groups = new List<Item>.from(_items);
            groups =
                groups.where((item) => item.tracks.contains('group')).toList();
            if (groups.isEmpty) {
              return new Container();
            }
            if (groups.length > 10) {
              groups.length = 10;
            }
            return new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: const Text(
                    'From your groups',
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 20.0),
                  ),
                ),
                new Container(
                  height: 200.0,
                  child: new DiscoverList(groups, 'group'),
                )
              ],
            );
        }
      });

  @override
  Widget build(BuildContext context) {
    Services.context = context;
    return new RefreshIndicator(
      onRefresh: () => _loadItems(true),
      child: _items == null
          ? const Center(child: const CircularProgressIndicator())
          : _buildDiscover(),
    );
  }
}

/// Discover list class
class DiscoverList extends StatelessWidget {
  final List<Item> _items;
  final String _hash;

  /// Discover list initializer
  const DiscoverList(this._items, this._hash);

  @override
  Widget build(BuildContext context) => _items.isNotEmpty
      ? new ListView.builder(
          //physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          itemCount: _items?.length,
          itemExtent: 250.0,
          itemBuilder: (context, index) => new ItemsListItem(
              item: _items[index],
              hash: _hash,
              onPressed: () {
                showItemPage(_items[index], _hash, context);
              }))
      : const Center(child: const Text('No items'));
}
