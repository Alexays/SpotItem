import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/model/item.dart';

class _ContactCategory extends StatelessWidget {
  const _ContactCategory({Key key, this.icon, this.children}) : super(key: key);

  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return new Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
        .map((String line) => new Text(line))
        .toList();
    columnChildren.insert(
        0, new Text(lines.last, style: themeData.textTheme.caption));

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
  OrderPage({Key key, @required this.item})
      : assert(item != null),
        super(key: key);

  final Item item;
  @override
  OrderPageState createState() => new OrderPageState();
}

// Displays a product's heading above photos of all of the other products
// arranged in two columns. Enables the user to specify a quantity and add an
// order to the shopping cart.
class OrderPageState extends State<OrderPage> {
  GlobalKey<ScaffoldState> scaffoldKey;

  @override
  void initState() {
    super.initState();
    scaffoldKey =
        new GlobalKey<ScaffoldState>(debugLabel: 'Shrine Order ${widget.key}');
  }

  void showSnackBarMessage(String message) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  final double _appBarHeight = 256.0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: _appBarHeight,
            pinned: true,
            actions: <Widget>[
              new IconButton(
                icon: const Icon(Icons.create),
                tooltip: 'Edit',
                onPressed: () {
                  scaffoldKey.currentState.showSnackBar(const SnackBar(
                      content: const Text(
                          'This is actually just a demo. Editing isn\'t supported.')));
                },
              ),
            ],
            flexibleSpace: new FlexibleSpaceBar(
              title: new Text(widget.item.name),
              background: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new Hero(
                      tag: widget.item.id,
                      child: new Image.network(widget.item.images[0],
                          fit: BoxFit.cover)),
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
          new SliverList(
            delegate: new SliverChildListDelegate(<Widget>[
              new _ContactCategory(
                icon: Icons.info,
                children: <Widget>[
                  new _ContactItem(
                    lines: <String>[
                      widget.item.about,
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
                    onPressed: () {
                      scaffoldKey.currentState.showSnackBar(const SnackBar(
                          content: const Text(
                              'Here, your e-mail application would open.')));
                    },
                    lines: <String>[
                      '${widget.item.owner.firstname} ${widget.item.owner.name}',
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
                    onPressed: () {
                      scaffoldKey.currentState.showSnackBar(const SnackBar(
                          content: const Text(
                              'This would show a map of San Francisco.')));
                    },
                    lines: <String>[
                      widget.item.location,
                      'Location',
                    ],
                  ),
                ],
              ),
              new _ContactCategory(
                icon: Icons.today,
                children: <Widget>[
                  new _ContactItem(
                    lines: <String>['Comming soon', 'comming soon'],
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
