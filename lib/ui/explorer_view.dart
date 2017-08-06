import 'dart:async';
import 'dart:convert';
import 'package:spot_items/model/item.dart';
import 'package:spot_items/ui/components/item.dart';
import 'package:spot_items/keys.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

class ExplorerView extends StatefulWidget {
  ExplorerView();

  @override
  State<StatefulWidget> createState() => new _FeedViewState();
}

class _FeedViewState extends State<ExplorerView> {
  _FeedViewState();
  bool loading = false;
  var _items = <Item>[];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _items.clear();
    loading = true;
    _loadItems();
  }

  Future _loadItems() async {
    _refreshIndicatorKey.currentState?.show();
    final Client _client = new Client();
    var responses = await _client.get(API_URL + '/items');

    var items = JSON.decode(responses.body);

    setState(() {
      _items = items.toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      onRefresh: _loadItems,
      child: new ItemsList(_items),
    );
  }
}
