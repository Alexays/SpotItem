import 'dart:async';

import 'package:spotitem/models/item.dart';
import 'package:spotitem/ui/widgets/item.dart';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';

class ExplorerView extends StatefulWidget {
  const ExplorerView(this._tracks);

  final List<String> _tracks;

  @override
  State<StatefulWidget> createState() => new _ExplorerViewState();
}

class _ExplorerViewState extends State<ExplorerView> {
  List<Item> _items = <Item>[];
  bool _loading = true;

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  Future<Null> _loadItems([bool force = false]) async {
    final Future<List<Item>> itemsLoaded = Services.itemsManager
        .getItems(force: force, userId: Services.authManager.user?.id);
    if (itemsLoaded != null) {
      itemsLoaded.then((data) {
        if (!mounted) {
          return;
        }
        setState(() {
          _items = new List<Item>.from(data);
          _items = _items.where((item) => item.tracks.contains(widget._tracks));
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
