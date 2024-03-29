import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/ui/screens/items/edit_item_screen.dart';
import 'package:spotitem/ui/screens/items/book_item_screen.dart';

class _Category extends StatelessWidget {
  const _Category({Key key, this.icon, this.children}) : super(key: key);

  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(color: themeData.dividerColor),
        ),
      ),
      child: new DefaultTextStyle(
        style: Theme.of(context).textTheme.subhead,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              width: 72.0,
              child: new Icon(icon, color: themeData.primaryColor),
            ),
            new Expanded(child: new Column(children: children))
          ],
        ),
      ),
    );
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
    final List<Widget> columnChildren = lines
        .sublist(0, lines.length - 1)
        .map((line) => new Text(line))
        .toList()
          ..insert(0, new Text(lines.last, style: themeData.textTheme.caption));

    final rowChildren = <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columnChildren,
        ),
      )
    ];
    if (icon != null) {
      rowChildren.add(
        new SizedBox(
          width: 72.0,
          child: new IconButton(
            icon: new Icon(icon),
            color: themeData.primaryColor,
            onPressed: onPressed,
          ),
        ),
      );
    }
    return new MergeSemantics(
      child: new Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rowChildren,
        ),
      ),
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
    this.hash = 0,
  })
      : assert(item != null || itemId != null),
        super(key: key);

  /// Item id
  final String itemId;

  /// Item data
  final Item item;

  /// Hash for hero animation
  final num hash;

  @override
  _ItemPageState createState() => new _ItemPageState(itemId, item, hash);
}

class _ItemPageState extends State<ItemPage>
    with SingleTickerProviderStateMixin {
  _ItemPageState(this._itemId, this.item, this.hash);

  final String _itemId;
  final num hash;

  TabController _tabController;

  Item item;

  @override
  void initState() {
    super.initState();
    if (item != null) {
      _initControler();
      return;
    }
    Services.items.get(_itemId).then((data) {
      if (!mounted) {
        return;
      }
      setState(() {
        item = data;
        _initControler();
      });
    });
  }

  void _initControler() {
    if (item == null) {
      return;
    }
    _tabController = new TabController(vsync: this, length: item.images.length);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future<Null> _deleteItem(BuildContext context) async {
    final res = await Services.items.delete(item.id);
    if (!resValid(context, res)) {
      return;
    }
    await Services.items.getAll(force: true);
    await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  List<Widget> _doButton(BuildContext context) {
    final widgets = <Widget>[];
    if (Services.auth.loggedIn && item?.owner?.id == Services.auth.user.id) {
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
                    child: new Text(
                        MaterialLocalizations.of(context).cancelButtonLabel),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  new FlatButton(
                    child: new Text(SpotL.of(context).delete.toUpperCase()),
                    onPressed: () => _deleteItem(context),
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
              ),
            );
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

  Widget _buildCarrousel(BuildContext context) => new GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          if (_tabController.indexIsChanging) {
            return;
          }
          _tabController.animateTo(
              (_tabController.index - details.delta.dx.clamp(-1, 1))
                  .clamp(0, _tabController.length - 1));
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
                              tag: '${item.id}$hash',
                              child: new FadeInImage(
                                placeholder: placeholder,
                                image: new NetworkImage(
                                  '$imgUrl$f',
                                  headers: getHeaders(
                                    key: Services.auth.accessToken,
                                    type: contentType.image,
                                  ),
                                ),
                                fit: BoxFit.cover,
                              ),
                            )
                          : new FadeInImage(
                              placeholder: placeholder,
                              image: new NetworkImage(
                                '$imgUrl$f',
                                headers: getHeaders(
                                  key: Services.auth.accessToken,
                                  type: contentType.image,
                                ),
                              ),
                              fit: BoxFit.cover,
                            ))
                      .toList(),
                ),
              ),
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
              const DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: const LinearGradient(
                    begin: const Alignment(0.0, -1.0),
                    end: const Alignment(0.0, -0.4),
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
      );

  List<Widget> _buildInfo(BuildContext context) => <Widget>[
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
      ];

  Future<Null> _bookItem(BuildContext context) => Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          fullscreenDialog: true,
          builder: (context) => new BookItemScreen(item: item),
        ),
      );

  @override
  Widget build(BuildContext context) => new Scaffold(
        body: new Builder(
          builder: (context) {
            Services.context = context;
            return item == null
                ? const Center(child: const CircularProgressIndicator())
                : new Column(
                    children: <Widget>[
                      new Expanded(
                        child: new CustomScrollView(
                          slivers: <Widget>[
                            new SliverAppBar(
                              title: new Text(
                                capitalize(item.name),
                                overflow: TextOverflow.ellipsis,
                              ),
                              expandedHeight: 256.0,
                              pinned: true,
                              actions: _doButton(context),
                              flexibleSpace: _buildCarrousel(context),
                            ),
                            new SliverList(
                              delegate: new SliverChildListDelegate(
                                _buildInfo(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new ConstrainedBox(
                        constraints: new BoxConstraints.tightFor(
                            height: 48.0,
                            width: MediaQuery.of(context).size.width),
                        child: new RaisedButton(
                          color: Theme.of(context).accentColor,
                          onPressed: () => _bookItem(context),
                          child: new Text(
                            SpotL.of(context).book.toUpperCase(),
                            style: new TextStyle(
                              color: Theme.of(context).canvasColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      );
}

/// Pop a Page with item details
Future<Null> showItemPage(Item item, num hash, BuildContext context) async {
  await Navigator.push(
    context,
    new MaterialPageRoute<Null>(
      builder: (context) => new ItemPage(
            item: item,
            hash: hash,
          ),
    ),
  );
}
