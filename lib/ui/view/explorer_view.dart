import 'dart:async';

import 'package:spotitem/model/item.dart';
import 'package:spotitem/ui/widget/item.dart';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';

class ExplorerView extends StatefulWidget {
  const ExplorerView();

  @override
  State<StatefulWidget> createState() => new _ExplorerViewState();
}

class _ExplorerViewState extends State<ExplorerView> {
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
            : new ItemsList(_items, toString()),
      );
}
