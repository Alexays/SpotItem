import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/ui/screens/item_screen.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/ui/spot_strings.dart';

/// Items view class
class ItemsView extends StatefulWidget {
  /// Items view initializer
  const ItemsView();

  @override
  State<StatefulWidget> createState() => new _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  List<Item> _myItems;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    _getItems();
    super.initState();
  }

  Future<Null> _getItems() async {
    setState(() {
      _myItems = Services.items.myItems;
      if (_myItems.isEmpty) {
        _myItems = null;
      }
    });
    if (_myItems != null) {
      _refreshIndicatorKey.currentState?.show();
    } else {
      _loadItems();
    }
  }

  Future<Null> _loadItems() async {
    final List<Item> res = await Services.items.getSelfItems();
    setState(() {
      _myItems = res;
    });
  }

  Widget getList() {
    if (_myItems.isEmpty) {
      return new Center(child: new Text(SpotL.of(context).noItems()));
    }
    return new ListView.builder(
      // For RefreshIndicator
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      itemCount: _myItems.length,
      itemBuilder: (context, index) => new GestureDetector(
            onTap: () {
              showItemPage(_myItems[index], null, context);
            },
            child: new Card(
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new ListTile(
                    leading: const Icon(Icons.event_available),
                    title: new Text(
                      _myItems[index].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: new Text(
                      _myItems[index].about,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: new Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: new List<Widget>.generate(
                        _myItems[index].tracks.length,
                        (i) => getIcon(_myItems[index].tracks[i]),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) => new RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () => _loadItems(),
      child: _myItems == null
          ? const Center(child: const CircularProgressIndicator())
          : getList());
}
