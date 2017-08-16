import 'dart:async';

import 'package:spotitems/model/item.dart';
import 'package:spotitems/ui/components/item.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:flutter/material.dart';

typedef List<Item> Filter(List<Item> items);

class ExplorerView extends StatefulWidget {
  final ItemsManager _itemsManager;
  final AuthManager _authManager;
  final Filter _mode;
  ExplorerView(this._itemsManager, this._authManager, this._mode);

  @override
  State<StatefulWidget> createState() =>
      new _ExplorerViewState(_itemsManager, _mode, _authManager);
}

class _ExplorerViewState extends State<ExplorerView> {
  final ItemsManager _itemsManager;
  final AuthManager _authManager;
  final Filter _mode;
  bool _loading = true;
  List<Item> _items = [];
  _ExplorerViewState(this._itemsManager, this._mode, this._authManager);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  Future _loadItems([bool force = false]) async {
    _refreshIndicatorKey.currentState?.show();
    final itemsLoaded = _itemsManager.getItems(force);
    if (itemsLoaded != null) {
      itemsLoaded.then((data) {
        if (!mounted) return;
        setState(() {
          _items = new List<Item>.from(data);
          if (_mode != null) _items = _mode(_items);
          _loading = false;
        });
      });
    }
  }

  Widget _buildExplorer() {
    return new ItemsList(_items, _itemsManager, _authManager, _mode.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      onRefresh: () {
        return _loadItems(true);
      },
      child: _loading
          ? new Center(child: new CircularProgressIndicator())
          : _buildExplorer(),
    );
  }
}
