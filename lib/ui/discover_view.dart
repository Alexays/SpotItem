import 'dart:async';

import 'package:spotitems/model/item.dart';
import 'package:spotitems/ui/components/item.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:flutter/material.dart';

typedef List<Item> Filter(List<Item> items);

class DiscoverView extends StatefulWidget {
  final ItemsManager _itemsManager;
  final AuthManager _authManager;
  final Filter _mode;

  const DiscoverView(this._itemsManager, this._authManager, this._mode);

  @override
  State<StatefulWidget> createState() =>
      new _DiscoverViewState(_itemsManager, _mode, _authManager);
}

class _DiscoverViewState extends State<DiscoverView> {
  final ItemsManager _itemsManager;
  final AuthManager _authManager;
  final Filter _mode;
  bool _loading = true;
  List<Item> _items = <Item>[];
  _DiscoverViewState(this._itemsManager, this._mode, this._authManager);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  Future<Null> _loadItems([bool force = false]) async {
    _refreshIndicatorKey.currentState?.show();
    final Future<List<Item>> itemsLoaded =
        _itemsManager.getItems(force: force, userId: _authManager.user?.id);
    if (itemsLoaded == null) {
      return;
    }
    itemsLoaded.then((data) {
      if (!mounted) {
        return;
      }
      setState(() {
        _items = new List<Item>.from(data);
        if (_mode != null) {
          _items = _mode(_items);
        }
        _loading = false;
      });
    });
  }

  Widget _buildDiscover() => new ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return const Padding(
              padding:
                  const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
              child: const Text(
                'Recents items',
                style: const TextStyle(
                    fontWeight: FontWeight.w400, fontSize: 20.0),
              ),
            );
          case 1:
            List<Item> recents = new List<Item>.from(_items);
            recents = recents
                .where((item) => !item.tracks.contains('group'))
                .toList();
            if (recents.length > 10) {
              recents.length = 10;
            }
            return new Container(
              height: 250.0,
              width: MediaQuery.of(context).size.width,
              child: new ItemsList(recents, _itemsManager, _authManager,
                  'recents', Axis.horizontal),
            );
          case 2:
            return const Padding(
              padding:
                  const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
              child: const Text(
                'From your groups',
                style: const TextStyle(
                    fontWeight: FontWeight.w400, fontSize: 20.0),
              ),
            );
          case 3:
            List<Item> groups = new List<Item>.from(_items);
            groups =
                groups.where((item) => item.tracks.contains('group')).toList();
            if (groups.length > 10) {
              groups.length = 10;
            }
            return new Container(
              height: 250.0,
              width: MediaQuery.of(context).size.width,
              child: new ItemsList(groups, _itemsManager, _authManager, 'group',
                  Axis.horizontal),
            );
        }
      });

  @override
  Widget build(BuildContext context) => new RefreshIndicator(
        onRefresh: () => _loadItems(true),
        child: _loading
            ? const Center(child: const CircularProgressIndicator())
            : _buildDiscover(),
      );
}
