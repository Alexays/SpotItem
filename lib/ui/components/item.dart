import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/model/item.dart';
import 'package:spotitems/ui/item_view.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/interactor/manager/auth_manager.dart';

class _ItemsListItem extends StatelessWidget {
  const _ItemsListItem(
      {Key key,
      @required this.itemsManager,
      @required this.item,
      this.hash,
      this.authManager,
      this.onPressed})
      : assert(item != null),
        super(key: key);

  final ItemsManager itemsManager;
  final AuthManager authManager;
  final String hash;
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
                  tag: item.id + '_img_' + hash,
                  child: new FadeInImage(
                      placeholder: new AssetImage('assets/placeholder.png'),
                      image: new NetworkImage(item.images[0]),
                      fit: BoxFit.cover,
                      alignment: FractionalOffset.center)),
              new Positioned(
                top: 15.0,
                left: 15.0,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new RaisedButton(
                        color: theme.primaryColor,
                        child: new Text(
                          item.dist != null
                              ? item.dist.toStringAsFixed(2) + 'km'
                              : '???',
                          style: theme.primaryTextTheme.subhead,
                        ),
                        onPressed: () {})
                  ],
                ),
              ),
              new Positioned(
                top: 15.0,
                right: 15.0,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new IconButton(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      icon: new Icon(Icons.star_border),
                      tooltip: 'Fav this item',
                      onPressed: () {},
                    ),
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
                              ' 12',
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
  final AuthManager _authManager;
  final String _hash;
  final Axis _dir;

  ItemsList(this._items, this._itemsManager, this._authManager, this._hash,
      [this._dir = Axis.vertical]);

  @override
  Widget build(BuildContext context) {
    return _items.length > 0
        ? new ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: _dir,
            padding: new EdgeInsets.symmetric(vertical: 8.0),
            itemCount: _items != null ? _items.length : 0,
            itemExtent: 300.0,
            itemBuilder: (BuildContext context, int index) {
              return new _ItemsListItem(
                  itemsManager: _itemsManager,
                  item: _items[index],
                  hash: _hash,
                  onPressed: () {
                    _showItemPage(_items[index], _authManager, _itemsManager,
                        _hash, context);
                  });
            })
        : new Center(
            child: new Text("No items"),
          );
  }
}

Future<Null> _showItemPage(Item item, AuthManager authManager,
    ItemsManager itemsManager, String hash, context) async {
  Navigator.push(context, new MaterialPageRoute<Null>(
    builder: (BuildContext context) {
      return new OrderPage(
        item: item,
        authManager: authManager,
        itemsManager: itemsManager,
        hash: hash,
      );
    },
  ));
}
