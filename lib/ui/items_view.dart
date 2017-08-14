import 'package:flutter/material.dart';
import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/model/item.dart';
import 'package:spotitems/model/user.dart';

class ItemsView extends StatefulWidget {
  final ItemsManager _itemsManager;
  final AuthManager _authManager;

  ItemsView(this._itemsManager, this._authManager);

  @override
  State<StatefulWidget> createState() =>
      new _ItemsViewState(_itemsManager, _authManager);
}

class _ItemsViewState extends State<ItemsView> {
  _ItemsViewState(this._itemsManager, this._authManager);

  final AuthManager _authManager;
  final ItemsManager _itemsManager;

  bool _loading = true;

  List<Item> _myItems = [];

  @override
  void initState() {
    super.initState();
    if (_authManager.user != null)
      _itemsManager.getSelfItems(_authManager.user.id).then((data) {
        setState(() {
          _myItems = data;
          _loading = false;
        });
      });
  }

  Widget getList() {
    if (_myItems.length == 0) {
      return new Center(
        child: new Text("No items"),
      );
    }
    return new ListView.builder(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _myItems.length,
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new ListTile(
                  leading: const Icon(Icons.event_available),
                  title: new Text(_myItems[index].name),
                  subtitle: new Text(_myItems[index].about),
                ),
                new RaisedButton(
                  child: new Text('Private'),
                  onPressed: () {
                    Navigator
                        .of(context)
                        .pushNamed('/items/${_myItems[index].id}');
                  },
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.all(20.0),
      child: _loading
          ? new Center(child: new CircularProgressIndicator())
          : getList(),
    );
  }
}
