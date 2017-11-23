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

class _BookItemScreenState extends State<BookItemScreen> {
  _BookItemScreenState(this._itemId, this._item);

  final String _itemId;

  final List<DateTime> toAdd = [];

  List<Event> concated = [];

  Item _item;

  @override
  void initState() {
    super.initState();
    if (_item == null) {
      Services.items.getItem(_itemId).then((data) {
        if (!mounted) {
          return;
        }
        setState(() {
          _item = data;
          concated = _item.calendar;
        });
      });
    } else {
      concated = _item.calendar;
    }
  }

  Future<Null> bookItem(BuildContext context) async {
    showLoading(context);
    final response = await Services.items
        .bookItem(_item.id, {'dates': toAdd.map((f) => f.toString()).toList()});
    if (!resValid(context, response)) {
      Navigator.of(context).pop();
      return;
    }
    showSnackBar(context, response.msg);
    await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).book)),
        body: new Builder(
          builder: (context) {
            Services.context = context;
            return new Calendar(
              selectedDates: concated,
              onChanged: (data) => setState(() {
                    final date = new Event({
                      'data': data.first.data,
                      'date': data.first.date.toString(),
                      'holder': Services.auth.user.id
                    });
                    if (toAdd?.isNotEmpty == true &&
                        toAdd.firstWhere((f) => f == date.date,
                                orElse: () => null) !=
                            null) {
                      toAdd.removeWhere((f) => f == date.date);
                    } else {
                      toAdd.add(date.date);
                    }
                    final tmp = new List<DateTime>.from(toAdd);
                    concated = new List<Event>.from(_item.calendar).map((f) {
                      final len = tmp.length;
                      tmp.removeWhere((d) =>
                          d.day == f.date.day &&
                          d.month == f.date.month &&
                          d.year == f.date.year);
                      if (tmp.length != len) {
                        return new Event({
                          'data': f.data,
                          'date': f.date.toString(),
                          'holder': Services.auth.user.id
                        });
                      }
                      return f;
                    }).toList();
                  }),
            );
          },
        ),
        bottomNavigationBar: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: new ConstrainedBox(
            constraints: new BoxConstraints.tightFor(
              height: 48.0,
              width: MediaQuery.of(context).size.width,
            ),
            child: new Builder(
              builder: (context) => new RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () => bookItem(context),
                    child: new Text(
                      SpotL.of(context).book.toUpperCase(),
                      style:
                          new TextStyle(color: Theme.of(context).canvasColor),
                    ),
                  ),
            ),
          ),
        ),
      );
}
