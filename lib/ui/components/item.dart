import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/model/item.dart';
import 'package:spotitems/ui/item_view.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/keys.dart';
import 'package:spotitems/interactor/utils.dart';

class ItemsListItem extends StatelessWidget {
  const ItemsListItem(
      {@required this.itemsManager,
      @required this.item,
      Key key,
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
    final ThemeData theme = Theme.of(context);
    return new GestureDetector(
        onTap: onPressed,
        child: new Card(
          child: new Stack(
            fit: StackFit.expand,
            children: <Widget>[
              new Hero(
                  tag: '${item.id}_img_$hash',
                  child: new FadeInImage(
                      placeholder: const AssetImage('assets/placeholder.png'),
                      image: new NetworkImage('$apiImgUrl${item.images.first}'),
                      fit: BoxFit.cover,
                      alignment: FractionalOffset.center)),
              new Positioned(
                top: 15.0,
                right: 15.0,
                child: new IconButton(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  icon: const Icon(Icons.star_border),
                  tooltip: 'Fav this item',
                  onPressed: () {},
                ),
              ),
              new Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: new Row(children: <Widget>[
                  new Expanded(
                      child: new Container(
                          padding: const EdgeInsets.all(11.0),
                          color: theme.secondaryHeaderColor.withOpacity(0.5),
                          height: 37.5,
                          child: new Text(
                            capitalize(item.name),
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ))),
                  item.dist >= 0
                      ? new Container(
                          padding: const EdgeInsets.all(10.0),
                          color: theme.primaryColor.withOpacity(0.4),
                          height: 37.5,
                          child: new Text(
                            distString(item.dist),
                            style: theme.primaryTextTheme.subhead,
                          ))
                      : new Container(),
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

  const ItemsList(
      this._items, this._itemsManager, this._authManager, this._hash,
      [this._dir = Axis.vertical]);

  @override
  Widget build(BuildContext context) => _items.isNotEmpty
      ? new ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: _dir,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: _items?.length,
          itemExtent: 275.0,
          itemBuilder: (context, index) => new ItemsListItem(
              itemsManager: _itemsManager,
              item: _items[index],
              hash: _hash,
              onPressed: () {
                showItemPage(
                    _items[index], _authManager, _itemsManager, _hash, context);
              }))
      : const Center(child: const Text('No items'));
}

Future<Null> showItemPage(Item item, AuthManager authManager,
    ItemsManager itemsManager, String hash, BuildContext context) async {
  await Navigator.push(
      context,
      new MaterialPageRoute<Null>(
        builder: (context) => new OrderPage(
              item: item,
              authManager: authManager,
              itemsManager: itemsManager,
              hash: hash,
            ),
      ));
}
