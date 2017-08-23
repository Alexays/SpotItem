import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/model/item.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/keys.dart';
import 'package:spotitems/ui/components/date_picker.dart';

class _ContactCategory extends StatelessWidget {
  const _ContactCategory({Key key, this.icon, this.children}) : super(key: key);

  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return new Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: new BoxDecoration(
            border: new Border(
                bottom: new BorderSide(color: themeData.dividerColor))),
        child: new DefaultTextStyle(
            style: Theme.of(context).textTheme.subhead,
            child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      width: 72.0,
                      child: new Icon(icon, color: themeData.primaryColor)),
                  new Expanded(child: new Column(children: children))
                ])));
  }
}

class _ContactItem extends StatelessWidget {
  _ContactItem({Key key, this.icon, this.lines, this.tooltip, this.onPressed})
      : assert(lines.length > 1),
        super(key: key);

  final IconData icon;
  final List<String> lines;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final List<Widget> columnChildren = lines
        .sublist(0, lines.length - 1)
        .map((line) => new Text(line))
        .toList()
          ..insert(0, new Text(lines.last, style: themeData.textTheme.caption));

    final List<Widget> rowChildren = <Widget>[
      new Expanded(
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnChildren))
    ];
    if (icon != null) {
      rowChildren.add(new SizedBox(
          width: 72.0,
          child: new IconButton(
              icon: new Icon(icon),
              color: themeData.primaryColor,
              onPressed: onPressed)));
    }
    return new MergeSemantics(
      child: new Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rowChildren)),
    );
  }
}

class OrderPage extends StatefulWidget {
  const OrderPage({
    @required this.itemsManager,
    @required this.authManager,
    Key key,
    this.item,
    this.itemId,
    this.hash = 'n',
  })
      : super(key: key);

  final AuthManager authManager;
  final ItemsManager itemsManager;
  final String itemId;
  final Item item;
  final String hash;

  @override
  OrderPageState createState() => new OrderPageState(itemId, item, hash);
}

class OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  OrderPageState(this._itemId, this.item, this.hash);

  final String _itemId;
  final String hash;

  bool _loading = true;

  TabController _tabController;

  Item item;

  final double _appBarHeight = 256.0;

  bool dragStopped = true;

  @override
  void initState() {
    super.initState();
    if (item != null) {
      setState(() {
        _tabController =
            new TabController(vsync: this, length: item.images.length);
        _loading = false;
      });
    }
    if (widget.item == null) {
      widget.itemsManager.getItem(_itemId).then((data) {
        setState(() {
          item = data;
          if (item != null) {
            _tabController =
                new TabController(vsync: this, length: item.images.length);
            _loading = false;
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> doButton() {
    final List<Widget> top = <Widget>[];
    if (widget.authManager.loggedIn &&
        item != null &&
        item.owner.id == widget.authManager.user.id) {
      top
        ..add(new IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Delete',
          onPressed: () {
            showDialog<Null>(
              context: context,
              barrierDismissible: false, // user must tap button!
              child: new AlertDialog(
                title: const Text('Delete confirmation'),
                content: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      const Text('Are you sure to delete this item ?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      widget.itemsManager.deleteItem(item.id).then((resp) {
                        if (resp['success']) {
                          widget.itemsManager.getItems(force: true);
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ))
        ..add(new IconButton(
          icon: const Icon(Icons.create),
          tooltip: 'Edit',
          onPressed: () {
            Navigator.of(context).pushNamed('/items/${item.id}/edit');
          },
        ));
    } else {
      top.add(new IconButton(
        icon: const Icon(Icons.star_border),
        tooltip: 'Favorites',
        onPressed: () {},
      ));
    }
    return top;
  }

  Widget giftCard() {
    if (!item.tracks.contains('gift')) {
      return new Container();
    }
    return new _ContactCategory(
      icon: Icons.card_giftcard,
      children: <Widget>[
        new _ContactItem(
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
        body: _loading
            ? const Center(child: const CircularProgressIndicator())
            : new CustomScrollView(
                slivers: <Widget>[
                  new SliverAppBar(
                    expandedHeight: _appBarHeight,
                    pinned: true,
                    actions: doButton(),
                    flexibleSpace: new GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        if (dragStopped == true &&
                            details.delta.dx < 0 &&
                            _tabController.index < item.images.length - 1) {
                          _tabController.index = _tabController.index + 1;
                          dragStopped = false;
                        } else if (dragStopped == true &&
                            details.delta.dx > 0 &&
                            _tabController.index > 0) {
                          _tabController.index = _tabController.index - 1;
                          dragStopped = false;
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        dragStopped = true;
                      },
                      child: new FlexibleSpaceBar(
                        title: new Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        centerTitle: false,
                        background: new Stack(
                          alignment: FractionalOffset.center,
                          fit: StackFit.expand,
                          children: <Widget>[
                            new TabBarView(
                                controller: _tabController,
                                children: new List<Widget>.generate(
                                    item.images.length, (index) {
                                  if (index == 0) {
                                    return new Hero(
                                        tag: '${item.id}_img_$hash',
                                        child: new FadeInImage(
                                            placeholder: const AssetImage(
                                                'assets/placeholder.png'),
                                            image: new NetworkImage(
                                                '$apiImgUrl${item.images[index]}'),
                                            fit: BoxFit.cover,
                                            alignment:
                                                FractionalOffset.center));
                                  } else {
                                    return new FadeInImage(
                                        placeholder: const AssetImage(
                                            'assets/placeholder.png'),
                                        image: new NetworkImage(
                                            '$apiImgUrl${item.images[index]}'),
                                        fit: BoxFit.cover,
                                        alignment: FractionalOffset.center);
                                  }
                                })),

                            // This gradient ensures that the toolbar icons are distinct
                            // against the background image.
                            const DecoratedBox(
                              decoration: const BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: const FractionalOffset(0.5, 0.0),
                                  end: const FractionalOffset(0.5, 0.30),
                                  colors: const <Color>[
                                    const Color(0x60000000),
                                    const Color(0x00000000)
                                  ],
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
                      giftCard(),
                      new _ContactCategory(
                        icon: Icons.info,
                        children: <Widget>[
                          new _ContactItem(
                            lines: <String>[
                              item.about,
                              'About',
                            ],
                          ),
                        ],
                      ),
                      new _ContactCategory(
                        icon: Icons.contact_mail,
                        children: <Widget>[
                          new _ContactItem(
                            icon: Icons.sms,
                            tooltip: 'Send personal e-mail',
                            onPressed: () {},
                            lines: <String>[
                              '${item.owner.firstname} ${item.owner.name}',
                              'Owner',
                            ],
                          ),
                        ],
                      ),
                      new _ContactCategory(
                        icon: Icons.location_on,
                        children: <Widget>[
                          new _ContactItem(
                            icon: Icons.map,
                            tooltip: 'Open map',
                            onPressed: () {},
                            lines: <String>[
                              item.location,
                              'Location',
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
                          new DayPickerBar(
                            selectedDate: new DateTime.now(),
                            onChanged: (date) {},
                          ),
                          new Positioned(
                            top: 15.0,
                            left: 15.0,
                            child: new Icon(Icons.today),
                          )
                        ],
                      )
                    ]),
                  ),
                ],
              ),
      );
}
