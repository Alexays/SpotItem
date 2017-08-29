import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/model/item.dart';

class ItemsView extends StatefulWidget {
  const ItemsView();

  @override
  State<StatefulWidget> createState() => new _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  bool _loading = true;

  List<Item> _myItems = <Item>[];

  @override
  void initState() {
    if (Services.authManager.loggedIn)
      Services.itemsManager.getSelfItems().then((data) {
        setState(() {
          _myItems = data;
          _loading = false;
        });
      });
    super.initState();
  }

  Widget getList() {
    if (_myItems.isEmpty) {
      return const Center(
        child: const Text('No items'),
      );
    }
    return new ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: _myItems.length,
        itemBuilder: (context, index) => new GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/items/${_myItems[index].id}');
              },
              child: new Card(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new ListTile(
                        leading: const Icon(Icons.event_available),
                        title: new Text(_myItems[index].name),
                        subtitle: new Text(_myItems[index].about),
                        trailing: new Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: new List<Widget>.generate(
                                _myItems[index].tracks.length, (i) {
                              switch (_myItems[index].tracks[i]) {
                                case 'private':
                                  return const Icon(Icons.lock);
                                case 'gift':
                                  return const Icon(Icons.card_giftcard);
                                case 'group':
                                  return const Icon(Icons.people);
                                default:
                                  return const Text('');
                              }
                            })))
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) => _loading
      ? const Center(child: const CircularProgressIndicator())
      : getList();
}
