import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/model/item.dart';
import 'package:spotitems/ui/item_view.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';

class _ItemsListItem extends StatelessWidget {
  const _ItemsListItem(
      {Key key,
      @required this.itemsManager,
      @required this.item,
      this.onPressed})
      : assert(item != null),
        super(key: key);

  final ItemsManager itemsManager;
  final Item item;
  final VoidCallback onPressed;

  String getDist(double lat2, double lng2) {
    if (itemsManager.location == null) return '???';
    double pi80 = PI / 180;
    double lat1 = itemsManager.location['latitude'] * pi80;
    double lng1 = itemsManager.location['longitude'] * pi80;
    double lat = lat2 * pi80;
    double lng = lng2 * pi80;

    double r = 6372.797; // mean radius of Earth in km
    double dlat = lat - lat1;
    double dlng = lng - lng1;
    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat) * sin(dlng / 2) * sin(dlng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double km = r * c;

    return km.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return new GestureDetector(
        onTap: onPressed,
        child: new Card(
          child: new Stack(
            fit: StackFit.expand,
            children: <Widget>[
              new Hero(
                  tag: item.id,
                  child: new FadeInImage(
                      placeholder: new AssetImage('assets/placeholder.png'),
                      image: new NetworkImage(item.images[0]),
                      fit: BoxFit.cover,
                      alignment: FractionalOffset.center)),
              new Positioned(
                top: 15.0,
                left: 15.0,
                right: 0.0,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new RaisedButton(
                        color: theme.primaryColor,
                        child: new Text(
                          getDist(item.lat, item.lng) + 'km',
                          style: theme.primaryTextTheme.subhead,
                        ),
                        onPressed: () {})
                  ],
                ),
              ),
              new Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: new Row(children: <Widget>[
                  new Container(
                      padding: const EdgeInsets.all(10.0),
                      color: theme.primaryColor.withOpacity(0.6),
                      height: 40.0,
                      child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Icon(Icons.message, color: Colors.white),
                            new Text(
                              '12',
                              style: theme.primaryTextTheme.subhead,
                            )
                          ])),
                  new Expanded(
                      child: new Container(
                          padding: const EdgeInsets.all(12.0),
                          color: theme.secondaryHeaderColor.withOpacity(0.6),
                          height: 40.0,
                          child: new Text(
                            item.name,
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )))
                ]),
              ),
            ],
          ),
        ));
  }
}

class ItemsList extends StatelessWidget {
  final List<Item> _items;
  final ItemsManager _itemsManager;

  ItemsList(this._items, this._itemsManager);

  @override
  Widget build(BuildContext context) {
    return new ListView(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        itemExtent: 300.0,
        children: _buildItemsList(context));
  }

  List<_ItemsListItem> _buildItemsList(context) {
    return _items
        .map((item) => new _ItemsListItem(
            itemsManager: _itemsManager,
            item: item,
            onPressed: () {
              _showItemPage(item, context);
            }))
        .toList();
  }
}

Future<Null> _showItemPage(dynamic item, context) async {
  Navigator.push(context, new MaterialPageRoute<Null>(
    builder: (BuildContext context) {
      return new OrderPage(item: item);
    },
  ));
}
