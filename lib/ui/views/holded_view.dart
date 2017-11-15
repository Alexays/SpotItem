import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/ui/screens/items/item_screen.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Items view class
class HoldedView extends StatefulWidget {
  /// Items view initializer
  const HoldedView();

  @override
  State<StatefulWidget> createState() => new _HoldedViewState();
}

class _HoldedViewState extends State<HoldedView> {
  List<Item> _holded;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _holded = Services.items.holded;
    if (_holded.isEmpty) {
      _holded = null;
    }
    _getItems();
  }

  Future<Null> _getItems() async {
    if (_holded != null) {
      return await _refreshIndicatorKey.currentState?.show();
    }
    await _loadItems();
  }

  Future<Null> _loadItems() async {
    final res = await Services.items.getHolded();
    if (!mounted) {
      return;
    }
    setState(() {
      _holded = res;
    });
  }

  Widget getList() {
    if (_holded.isEmpty) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Center(child: new Text(SpotL.of(Services.loc).noItems)),
        ],
      );
    }
    return new ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(), // For RefreshIndicator
      padding: const EdgeInsets.all(20.0),
      itemCount: _holded?.length ?? 0,
      itemBuilder: (context, index) => new GestureDetector(
            onTap: () => showItemPage(_holded[index], 3, context),
            child: new Card(
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new ListTile(
                    leading: const Icon(Icons.event_available),
                    title: new Text(
                      _holded[index].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: new Text(
                      _holded[index].about,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: new Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: new List<Widget>.generate(
                        _holded[index].tracks.length,
                        (i) => getIcon(_holded[index].tracks[i]),
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
  Widget build(BuildContext context) => new RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _loadItems,
      child: _holded == null
          ? const Center(child: const CircularProgressIndicator())
          : getList());
}
