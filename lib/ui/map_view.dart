import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:flutter/material.dart';

class MapView extends StatefulWidget {
  final ItemsManager _itemsManager;

  MapView(this._itemsManager);

  @override
  State<StatefulWidget> createState() => new _MapViewState(_itemsManager);
}

class _MapViewState extends State<MapView> {
  final ItemsManager _itemsManager;

  _MapViewState(this._itemsManager);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Image.network(
          "https://maps.googleapis.com/maps/api/staticmap?center=${_itemsManager.location["latitude"]},${_itemsManager.location["longitude"]}&zoom=18&size=${MediaQuery.of(context).size.width}x${MediaQuery.of(context).size.height}&key=AIzaSyAJh3ASTwUBo06fQai_PZJa-R9czeRC2D0"),
    );
  }
}
