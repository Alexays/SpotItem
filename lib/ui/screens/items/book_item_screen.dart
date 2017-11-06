import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/item.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/ui/widgets/calendar.dart';

/// Edit item screen
class BookItemScreen extends StatefulWidget {
  /// Edit item screen initializer
  const BookItemScreen({Key key, this.itemId, this.item})
      : assert(itemId != null || item != null),
        super(key: key);

  /// Item id
  final String itemId;

  /// Item data
  final Item item;

  @override
  _BookItemScreenState createState() => new _BookItemScreenState(itemId, item);
}

class _BookItemScreenState extends State<BookItemScreen> with TickerProviderStateMixin {
  _BookItemScreenState(this._itemId, this._item);

  final String _itemId;

  final List<Event> calendar = [];

  List<Event> concated = [];

  Item _item;

  @override
  void initState() {
    if (_item == null) {
      Services.items.getItem(_itemId).then((data) {
        if (!mounted) {
          return;
        }
        setState(() {
          _item = data;
          concated = new List.from(_item.calendar);
        });
      });
    }
    super.initState();
  }

  Future<Null> bookItem(BuildContext context) async {
    showLoading(context);
    final response = await Services.items.bookItem(_item.id, {'dates': calendar});
    Navigator.of(context).pop();
    if (resValid(context, response)) {
      showSnackBar(context, response.msg);
      await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(title: new Text(SpotL.of(context).book)),
      body: new Builder(
          builder: (context) => new Column(
                children: <Widget>[
                  new Expanded(
                    child: new Calendar(
                      selectedDates: concated,
                      onChanged: (data) {
                        final date = data.first..holder = Services.auth.user.id;
                        setState(() {
                          if (calendar.contains(date)) {
                            calendar.remove(date);
                          } else {
                            calendar.add(date);
                          }
                          concated = new List.from(_item.calendar)..addAll(calendar);
                        });
                      },
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: new ConstrainedBox(
                        constraints:
                            new BoxConstraints.tightFor(height: 48.0, width: MediaQuery.of(context).size.width),
                        child: new RaisedButton(
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            bookItem(context);
                          },
                          child: new Text(
                            SpotL.of(context).save.toUpperCase(),
                            style: new TextStyle(color: Theme.of(context).canvasColor),
                          ),
                        )),
                  ),
                ],
              )));
}
