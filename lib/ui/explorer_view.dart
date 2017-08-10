import 'dart:async';
import 'dart:convert';
import 'package:spotitems/model/item.dart';
import 'package:spotitems/ui/components/item.dart';
import 'package:spotitems/keys.dart';
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

    if (!mounted) return;

    setState(() {
      _items = items.toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      onRefresh: _loadItems,
      child: loading ? new Center(child: new CircularProgressIndicator()) : new ItemsList(_items),
    );
  }
}
