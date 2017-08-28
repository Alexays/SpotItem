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

  Widget _buildDiscover() {
    List<Item> recents = new List<Item>.from(_items);
    recents = recents.where((item) => !item.tracks.contains('group')).toList();
    if (recents.length > 10) {
      recents.length = 10;
    }
    List<Item> groups = new List<Item>.from(_items);
    groups = groups.where((item) => item.tracks.contains('group')).toList();
    if (groups.isEmpty) {
      return new Container();
    }
    if (groups.length > 10) {
      groups.length = 10;
    }
    final List<SpotListItem> _spotListItem = [
      new SpotListItem('Recents items', recents),
      new SpotListItem('From your groups', groups),
    ];
    return new ItemsList(
        _spotListItem, _itemsManager, _authManager, 'discover');
  }

  @override
  Widget build(BuildContext context) => new RefreshIndicator(
        onRefresh: () => _loadItems(true),
        child: _loading
            ? const Center(child: const CircularProgressIndicator())
            : _buildDiscover(),
      );
}
