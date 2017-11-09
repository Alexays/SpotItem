import 'dart:async';

import 'package:spotitem/models/item.dart';
import 'package:spotitem/ui/widgets/item.dart';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';

/// Explorer view class
class ExplorerView extends StatefulWidget {
  /// Explorer view initializer
  const ExplorerView();

  @override
  State<StatefulWidget> createState() => new _ExplorerViewState();
}

class _ExplorerViewState extends State<ExplorerView> {
  static List<Item> _items;

  @override
  void initState() {
    super.initState();
    _loadItems().then((res) {
      if (!mounted) {
        return;
      }
      Services.items.tracks.addListener(getTracks);
    });
  }

  @override
  void dispose() {
    super.dispose();
    Services.items.tracks.removeListener(getTracks);
  }

  void getTracks() {
    if (!mounted) {
      return;
    }
    _items = new List<Item>.from(Services.items.items);
    final _tracks = Services.items.tracks.value.where((f) => !Services.items.exludeTracks.contains(f));
    final _sort = Services.items.tracks.value.where((f) => Services.items.exludeTracks.contains(f));
    if (_tracks != null) {
      setState(() {
        _items = _items.where((item) => _tracks.every((track) => item.tracks.contains(track))).toList();
      });
    }
    _items.sort((i1, i2) {
      switch (_sort.isEmpty ? null : _sort.single) {
        case 'name':
          return i1.name.compareTo(i2.name);
        case 'dist':
          return i1.dist.compareTo(i2.dist);
        default:
          return i1.dist.compareTo(i2.dist);
      }
    });
  }

  Future<Null> _loadItems([bool force = false]) async {
    await Services.items.getItems(force: force);
    getTracks();
  }

  @override
  Widget build(BuildContext context) => new RefreshIndicator(
        onRefresh: () => _loadItems(true),
        child: _items == null ? const Center(child: const CircularProgressIndicator()) : new ItemsList(_items, '5'),
      );
}
