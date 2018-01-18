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

  final List<Event> toAdd = [];

  List<Event> concated = [];

  Item _item;

  @override
  void initState() {
    super.initState();
    if (_item == null) {
      Services.items.get(_itemId).then((data) {
        if (!mounted) {
          return;
        }
        setState(() {
          _item = data;
          concated = new List<Event>.from(_item.calendar);
        });
      });
    } else {
      concated = new List<Event>.from(_item.calendar);
    }
  }

  Future<Null> bookItem(BuildContext context) async {
    showLoading(context);
    final response = await Services.items
        .book(_item.id, {'dates': toAdd.map((f) => f.toString()).toList()});
    if (!resValid(context, response)) {
      Navigator.of(context).pop();
      return;
    }
    showSnackBar(context, response.msg);
    await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _getNewSelectedDates(List<Event> data) {
    final len = toAdd.length;
    toAdd.removeWhere(
      (f) => data.any((d) => d.date == f.date),
    );
    if (len == toAdd.length) {
      toAdd.addAll(data);
    }
  }

  void _mergeDates() {
    final tmp = new List<Event>.from(toAdd);
    concated = new List<Event>.generate(_item.calendar.length, (i) {
      final event = _item.calendar[i];
      Event date;
      tmp.removeWhere((d) {
        if (compareDates(d.date, event.date)) {
          date = d;
          return true;
        }
        return false;
      });
      if (date != null) {
        return date;
      }
      return event;
    });
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
                    _getNewSelectedDates(data);
                    _mergeDates();
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
                      style: new TextStyle(
                        color: Theme.of(context).canvasColor,
                      ),
                    ),
                  ),
            ),
          ),
        ),
      );
}
