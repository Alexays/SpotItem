import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Edit item screen
class ScannedItemScreen extends StatefulWidget {
  /// Edit item screen initializer
  const ScannedItemScreen({Key key, this.itemId})
      : assert(itemId != null),
        super(key: key);

  /// Item id
  final String itemId;

  @override
  _ScannedItemScreenState createState() => new _ScannedItemScreenState(itemId);
}

class _ScannedItemScreenState extends State<ScannedItemScreen> {
  _ScannedItemScreenState(this._itemId);

  final String _itemId;

  @override
  void initState() {
    super.initState();
  }

  Future<Null> _updateLocation(BuildContext context) {}

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).book)),
        body: new Builder(
          builder: (context) {
            Services.context = context;
            return new Center(
              child: new Text(SpotL.of(context).updateLocation),
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
              builder: (context) => new Column(
                    children: <Widget>[
                      new RaisedButton(
                        color: Theme.of(context).canvasColor,
                        onPressed: () => Navigator
                            .of(context)
                            .pushReplacementNamed('/items/:$_itemId'),
                        child: new Text(
                          MaterialLocalizations
                              .of(context)
                              .cancelButtonLabel
                              .toUpperCase(),
                          style: new TextStyle(
                              color: Theme.of(context).canvasColor),
                        ),
                      ),
                      new RaisedButton(
                        color: Theme.of(context).accentColor,
                        onPressed: () => _updateLocation(context),
                        child: new Text(
                          SpotL.of(context).save.toUpperCase(),
                          style: new TextStyle(
                              color: Theme.of(context).canvasColor),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      );
}
