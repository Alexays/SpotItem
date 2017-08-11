import 'dart:async';
import 'package:spotitems/model/item.dart';
import 'package:spotitems/ui/components/item.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:flutter/material.dart';

class ExplorerView extends StatefulWidget {
  final ItemsManager _itemsManager;
  final int _mode;
  ExplorerView(this._itemsManager, this._mode);

  @override
  State<StatefulWidget> createState() =>
      new _FeedViewState(_itemsManager, _mode);
}

class _FeedViewState extends State<ExplorerView> {
  final ItemsManager _itemsManager;
  final int _mode;
  bool _loading = true;
  List<Item> _items = [];
  _FeedViewState(this._itemsManager, this._mode);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future _loadItems([bool force = false]) async {
    _refreshIndicatorKey.currentState?.show();
    final itemsLoaded = _itemsManager.getItems(force);
    if (itemsLoaded != null) {
      itemsLoaded.then((data) {
        if (!mounted) return;
        setState(() {
          _items = data;
          if (_mode == -1) _items.sort((a, b) => a.dist.compareTo(b.dist));
          _loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      onRefresh: () {
        return _loadItems(true);
      },
      child: _loading
          ? new Center(child: new CircularProgressIndicator())
          : new ItemsList(_items, _itemsManager),
    );
  }
}
