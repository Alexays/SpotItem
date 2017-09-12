import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/ui/views/item_view.dart';
import 'package:spotitem/utils.dart';

/// Items view class
class ItemsView extends StatefulWidget {
  /// Items view initializer
  const ItemsView();

  @override
  State<StatefulWidget> createState() => new _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  List<Item> _myItems;

  @override
  void initState() {
    if (Services.auth.loggedIn)
      Services.items.getSelfItems().then((data) {
        setState(() {
          _myItems = data;
        });
      });
    super.initState();
  }

  Widget getList() {
    if (_myItems.isEmpty) {
      return const Center(child: const Text('No items'));
    }
    return new ListView.builder(
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
                    subtitle: new Text(limitString(_myItems[index].about, 50)),
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
  Widget build(BuildContext context) => _myItems == null
      ? const Center(child: const CircularProgressIndicator())
      : getList();
}
