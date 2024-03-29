import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Edit item screen
class ScannedItemScreen extends StatefulWidget {
  /// Edit item screen initializer
  const ScannedItemScreen({@required this.itemId, Key key})
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

  /// TODO: retrieve item data and check if in calendar user is
  /// here then if true ask update location else show item page
  @override
  void initState() {
    super.initState();
  }

  Future<Null> _updateLocation(BuildContext context) async {
    showLoading(context);
    Map<String, dynamic> _location = await Services.users.getLocation();
    var _address = await Services.users.getCity();
    if (_location == null) {
      _address = await Services.users.autocompleteCity(context);
      if (_address == null) {
        showSnackBar(context, SpotL.of(context).locationError);
        return;
      }
      _location = await Services.users.locationByAddress(_address);
    }
    _location['location'] = _address;
    await Services.items.updateLocation(_itemId, _location);
    Navigator.of(context).pop();
  }

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
        bottomNavigationBar: new ConstrainedBox(
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
                        style:
                            new TextStyle(color: Theme.of(context).canvasColor),
                      ),
                    ),
                    new RaisedButton(
                      color: Theme.of(context).accentColor,
                      onPressed: () => _updateLocation(context),
                      child: new Text(
                        SpotL.of(context).save.toUpperCase(),
                        style:
                            new TextStyle(color: Theme.of(context).canvasColor),
                      ),
                    ),
                  ],
                ),
          ),
        ),
      );
}
