import 'dart:async';
import 'dart:convert';
import 'package:spotitems/model/item.dart';
import 'package:spotitems/ui/components/item.dart';
import 'package:spotitems/keys.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

class ExplorerView extends StatefulWidget {
  final ItemsManager _itemsManager;
  ExplorerView(this._itemsManager);

  @override
  State<StatefulWidget> createState() => new _FeedViewState(_itemsManager);
}

class _FeedViewState extends State<ExplorerView> {
  final ItemsManager _itemsManager;
  bool _loading = true;
  List<Item> _items = [];
  _FeedViewState(this._itemsManager);
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
        setState(() {
          _items = data;
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
          : new ItemsList(_items),
    );
  }
}
