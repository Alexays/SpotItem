import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/model/item.dart';
import 'package:spotitems/ui/item_view.dart';

class _ItemsListItem extends StatelessWidget {
  const _ItemsListItem({Key key, @required this.item, this.onPressed})
      : assert(item != null),
        super(key: key);

  final Item item;
  final VoidCallback onPressed;

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
                  child: new Image.network(
                    item.images[0],
                    fit: BoxFit.cover,
                    alignment: FractionalOffset.center,
                  )),
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

  ItemsList(this._items);

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
            item: new Item.fromJson(item),
            onPressed: () {
              _showItemPage(new Item.fromJson(item), context);
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
