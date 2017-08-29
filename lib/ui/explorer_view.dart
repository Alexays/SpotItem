import 'dart:async';

import 'package:spotitems/model/item.dart';
import 'package:spotitems/ui/components/item.dart';
import 'package:spotitems/interactor/services/services.dart';
import 'package:flutter/material.dart';

typedef List<Item> Filter(List<Item> items);

class ExplorerView extends StatefulWidget {
  final Filter _mode;
  final String _hash;
  const ExplorerView(this._mode, this._hash);

  @override
  State<StatefulWidget> createState() => new _ExplorerViewState(_mode, _hash);
}

class _ExplorerViewState extends State<ExplorerView> {
  _ExplorerViewState(this._mode, this._hash);

  final Filter _mode;
  final String _hash;

  bool _loading = true;
  List<Item> _items = <Item>[];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  Future<Null> _loadItems([bool force = false]) async {
    _refreshIndicatorKey.currentState?.show();
    final Future<List<Item>> itemsLoaded = Services.itemsManager
        .getItems(force: force, userId: Services.authManager.user?.id);
    if (itemsLoaded != null) {
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
  }

  @override
  Widget build(BuildContext context) => new RefreshIndicator(
        onRefresh: () => _loadItems(true),
        child: _loading
            ? const Center(child: const CircularProgressIndicator())
            : new ItemsList(_items, _hash),
      );
}
