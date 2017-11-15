import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/ui/screens/items/item_screen.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';

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
    super.initState();
    _myItems = Services.items.owned;
    if (_myItems.isEmpty) {
      _myItems = null;
    }
    _getItems();
  }

  Future<Null> _getItems() async {
    if (_myItems != null) {
      return await _refreshIndicatorKey.currentState?.show();
    }
    await _loadItems();
  }

  Future<Null> _loadItems() async {
    final res = await Services.items.getUserItems();
    if (!mounted) {
      return;
    }
    setState(() {
      _myItems = res;
    });
  }

  Widget getList() {
    if (_myItems.isEmpty) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Center(child: new Text(SpotL.of(Services.loc).noItems)),
          const Padding(padding: const EdgeInsets.all(10.0)),
          new RaisedButton(
            child: new Text(SpotL.of(Services.loc).addItem),
            onPressed: () =>
                Navigator.of(Services.context).pushNamed('/items/add/'),
          ),
        ],
      );
    }
    return new ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(), // For RefreshIndicator
      padding: const EdgeInsets.all(20.0),
      itemCount: _myItems?.length ?? 0,
      itemBuilder: (context, index) => new GestureDetector(
            onTap: () => showItemPage(_myItems[index], 3, context),
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
      onRefresh: _loadItems,
      child: _myItems == null
          ? const Center(child: const CircularProgressIndicator())
          : getList());
}
