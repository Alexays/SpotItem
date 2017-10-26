import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/ui/widgets/calendar.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/ui/screens/items/edit_item_screen.dart';

class _Category extends StatelessWidget {
  const _Category({Key key, this.icon, this.children}) : super(key: key);

  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return new Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: new BoxDecoration(border: new Border(bottom: new BorderSide(color: themeData.dividerColor))),
        child: new DefaultTextStyle(
            style: Theme.of(context).textTheme.subhead,
            child: new Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              new Container(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  width: 72.0,
                  child: new Icon(icon, color: themeData.primaryColor)),
              new Expanded(child: new Column(children: children))
            ])));
  }
}

class _ListItem extends StatelessWidget {
  _ListItem({Key key, this.icon, this.lines, this.tooltip, this.onPressed})
      : assert(lines.length > 1),
        super(key: key);

  final IconData icon;
  final List<String> lines;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final List<Widget> columnChildren = lines.sublist(0, lines.length - 1).map((line) => new Text(line)).toList()
      ..insert(0, new Text(lines.last, style: themeData.textTheme.caption));

    final rowChildren = <Widget>[
      new Expanded(child: new Column(crossAxisAlignment: CrossAxisAlignment.start, children: columnChildren))
    ];
    if (icon != null) {
      rowChildren.add(new SizedBox(
          width: 72.0,
          child: new IconButton(icon: new Icon(icon), color: themeData.primaryColor, onPressed: onPressed)));
    }
    return new MergeSemantics(
      child: new Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: rowChildren)),
    );
  }
}

/// Item page class
class ItemPage extends StatefulWidget {
  /// Item page initializer
  const ItemPage({
    Key key,
    this.item,
    this.itemId,
    this.hash = 'n',
  })
      : assert(item != null || itemId != null),
        super(key: key);

  /// Item id
  final String itemId;

  /// Item data
  final Item item;

  /// Hash for hero animation
  final String hash;

  @override
  _ItemPageState createState() => new _ItemPageState(itemId, item, hash);
}

class _ItemPageState extends State<ItemPage> with SingleTickerProviderStateMixin {
  _ItemPageState(this._itemId, this.item, this.hash);

  final String _itemId;
  final String hash;

  TabController _tabController;

  Item item;

  @override
  void initState() {
    if (item != null) {
      setState(() {
        _tabController = new TabController(vsync: this, length: item.images.length);
      });
    }
    if (widget.item == null) {
      Services.items.getItem(_itemId).then((data) {
        if (!mounted) {
          return;
        }
        setState(() {
          item = data;
          if (item != null) {
            _tabController = new TabController(vsync: this, length: item.images.length);
          }
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> _doButton(BuildContext context) {
    final widgets = <Widget>[];
    if (Services.auth.loggedIn && item != null && item.owner.id == Services.auth.user.id) {
      widgets.addAll([
        new IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Delete',
          onPressed: () {
            showDialog<Null>(
              context: context,
              barrierDismissible: false,
              child: new AlertDialog(
                title: new Text(SpotL.of(context).confirm),
                content: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      new Text(SpotL.of(context).delItem),
                    ],
                  ),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text(MaterialLocalizations.of(context).cancelButtonLabel),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text(SpotL.of(context).delete.toUpperCase()),
                    onPressed: () {
                      Services.items.deleteItem(item.id).then((resp) {
                        if (resp.success) {
                          Services.items.getItems(force: true);
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        new IconButton(
          icon: const Icon(Icons.create),
          tooltip: 'Edit',
          onPressed: () {
            Navigator.push(
                context,
                new MaterialPageRoute<Null>(
                  builder: (context) => new EditItemScreen(item: item),
                ));
          },
        )
      ]);
    }
    // else {
    //   top.add(new IconButton(
    //     icon: const Icon(Icons.star_border),
    //     tooltip: 'Favorites',
    //     onPressed: () {},
    //   ));
    // }
    return widgets;
  }

  Widget _giftCard() {
    if (!item.tracks.contains('gift')) {
      return new Container();
    }
    return new _Category(
      icon: Icons.card_giftcard,
      children: <Widget>[
        new _ListItem(
          lines: <String>[
            'It\'s a gift !',
            'Yeah !',
          ],
        ),
      ],
    );
  }

  String getWidth() => MediaQuery.of(context).size.width.toInt().toString();

  @override
  Widget build(BuildContext context) => new Scaffold(
        body: new Builder(
            builder: (context) => item == null
                ? const Center(child: const CircularProgressIndicator())
                : new CustomScrollView(
                    slivers: <Widget>[
                      new SliverAppBar(
                        title: new Text(
                          capitalize(item.name),
                          overflow: TextOverflow.ellipsis,
                        ),
                        expandedHeight: 256.0,
                        pinned: true,
                        actions: _doButton(context),
                        flexibleSpace: new GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragUpdate: (details) {
                            if (!_tabController.indexIsChanging) {
                              _tabController.animateTo((_tabController.index - details.delta.dx.clamp(-1, 1))
                                  .clamp(0, _tabController.length - 1));
                            }
                          },
                          child: new FlexibleSpaceBar(
                            background: new Stack(
                              alignment: Alignment.center,
                              fit: StackFit.expand,
                              children: <Widget>[
                                new Container(
                                    color: Theme.of(context).canvasColor,
                                    child: new TabBarView(
                                        controller: _tabController,
                                        children: item.images
                                            .map((f) => (f == item.images.first)
                                                ? new Hero(
                                                    tag: '${item.id}_img_$hash',
                                                    child: new FadeInImage(
                                                      placeholder: placeholder,
                                                      image: new NetworkImage('$apiImgUrl$f'),
                                                      fit: BoxFit.cover,
                                                    ))
                                                : new FadeInImage(
                                                    placeholder: placeholder,
                                                    image: new NetworkImage('$apiImgUrl$f'),
                                                    fit: BoxFit.cover))
                                            .toList())),
                                new Positioned(
                                  bottom: 15.0,
                                  width: MediaQuery.of(context).size.width,
                                  child: new Center(
                                    child: new TabPageSelector(
                                      controller: _tabController,
                                      indicatorSize: 8.0,
                                    ),
                                  ),
                                ),
                                // This gradient ensures that the toolbar icons are distinct
                                // against the background image.
                                new DecoratedBox(
                                  decoration: new BoxDecoration(
                                    gradient: new LinearGradient(
                                      begin: const FractionalOffset(0.5, 0.0),
                                      end: const FractionalOffset(0.5, 0.40),
                                      colors: <Color>[const Color(0x60000000), const Color(0x00000000)],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      new SliverList(
                        delegate: new SliverChildListDelegate(<Widget>[
                          _giftCard(),
                          new _Category(
                            icon: Icons.info,
                            children: <Widget>[
                              new _ListItem(
                                lines: <String>[
                                  capitalize(item.name),
                                  SpotL.of(context).name,
                                ],
                              ),
                              new _ListItem(
                                lines: <String>[
                                  item.about,
                                  SpotL.of(context).about,
                                ],
                              ),
                            ],
                          ),
                          new _Category(
                            icon: Icons.contact_mail,
                            children: <Widget>[
                              new _ListItem(
                                icon: Icons.sms,
                                tooltip: 'Send personal e-mail',
                                onPressed: () {},
                                lines: <String>[
                                  '${item.owner.firstname} ${item.owner.name}',
                                  SpotL.of(context).owner,
                                ],
                              ),
                            ],
                          ),
                          new _Category(
                            icon: Icons.location_on,
                            children: <Widget>[
                              new _ListItem(
                                icon: Icons.map,
                                tooltip: 'Open map',
                                onPressed: () {},
                                lines: <String>[
                                  item.location,
                                  SpotL.of(context).location,
                                ],
                              ),
                            ],
                          ),
                          new Container(
                            child: new Image.network(
                                'https://maps.googleapis.com/maps/api/staticmap?center=${item.lat},${item.lng}&markers=color:blue%7C${item.lat},${item.lng}&zoom=13&maptype=roadmap&size=${getWidth()}x250&key=$staticApiKey'),
                          ),
                          new Stack(
                            children: <Widget>[
                              new Container(
                                height: 330.0,
                                child: new Calendar(
                                  selectedDates: [new DateTime.now()],
                                  onChanged: (data) {
                                    print(data);
                                  },
                                ),
                              ),
                              const Positioned(
                                top: 15.0,
                                left: 15.0,
                                child: const Icon(Icons.today),
                              )
                            ],
                          )
                        ]),
                      ),
                    ],
                  )),
      );
}

/// Pop a Page with item details
Future<Null> showItemPage(Item item, String hash, BuildContext context) async {
  await Navigator.push(
      context,
      new MaterialPageRoute<Null>(
        builder: (context) => new ItemPage(
              item: item,
              hash: hash,
            ),
      ));
}
