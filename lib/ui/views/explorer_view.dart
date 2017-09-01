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
  static List<Item> _items;
  List<Item> backup = [];

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
    if (!mounted) {
      return;
    }
    setState(() {
      if (_tracks.isNotEmpty) {
        _items = _items
            .where(
                (item) => _tracks.every((track) => item.tracks.contains(track)))
            .toList();
      }
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
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) => new RefreshIndicator(
        onRefresh: () => _loadItems(true),
        child: _items == null
            ? const Center(child: const CircularProgressIndicator())
            : new ItemsList(_items, toString()),
      );
}
