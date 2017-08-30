import 'dart:async';

import 'package:spotitem/models/item.dart';
import 'package:spotitem/ui/widgets/item.dart';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';

class ExplorerView extends StatefulWidget {
  const ExplorerView();

  @override
  State<StatefulWidget> createState() => new _ExplorerViewState();
}

class _ExplorerViewState extends State<ExplorerView> {
  List<Item> _items = <Item>[];
  List<Item> backup = <Item>[];
  bool _loading = true;

  @override
  void initState() {
    _loadItems().then((res) {
      Services.itemsManager.tracks.addListener(getTracks);
    });
    super.initState();
  }

  @override
  void dispose() {
    Services.itemsManager.tracks.removeListener(getTracks);
    super.dispose();
  }

  void getTracks() {
    _items = new List<Item>.from(backup);
    final List<String> _tracks = Services.itemsManager.tracks.value;
    setState(() {
      if (!mounted) {
        return;
      }
      if (_tracks.isNotEmpty) {
        _items = _items
            .where(
                (item) => item.tracks.any((track) => _tracks.contains(track)))
            .toList();
      }
      _loading = false;
    });
  }

  Future<Null> _loadItems([bool force = false]) async {
    final Future<List<Item>> itemsLoaded = Services.itemsManager
        .getItems(force: force, userId: Services.authManager.user?.id);
    if (itemsLoaded != null) {
      itemsLoaded.then((data) {
        if (!mounted) {
          return;
        }
        backup = data;
        setState(() {
          _items = new List<Item>.from(data);
          getTracks();
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
