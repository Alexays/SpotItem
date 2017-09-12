import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/ui/screens/item_screen.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/utils.dart';

/// Items list item
class ItemsListItem extends StatelessWidget {
  /// Items list item initializer
  const ItemsListItem({@required this.item, Key key, this.hash, this.onPressed})
      : assert(item != null),
        super(key: key);

  /// Hash for hero animation
  final String hash;

  /// Item data
  final Item item;

  /// Callback when item is pressed
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new GestureDetector(
        onTap: onPressed,
        child: new Card(
          child: new Stack(
            fit: StackFit.expand,
            children: <Widget>[
              new Hero(
                  tag: '${item.id}_img_$hash',
                  child: new FadeInImage(
                    placeholder: placeholder,
                    image: new NetworkImage('$apiImgUrl${item.images.first}'),
                    fit: BoxFit.cover,
                  )),
              // new Positioned(
              //   top: 15.0,
              //   right: 15.0,
              //   child: new IconButton(
              //     color: const Color.fromARGB(255, 255, 255, 255),
              //     icon: const Icon(Icons.star_border),
              //     tooltip: 'Fav this item',
              //     onPressed: () {},
              //   ),
              // ),
              new Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: new Row(children: <Widget>[
                  new Expanded(
                      child: new Container(
                          padding: const EdgeInsets.all(11.0),
                          color: theme.secondaryHeaderColor.withOpacity(0.75),
                          height: 37.5,
                          child: new Text(
                            capitalize(item.name),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ))),
                  item.dist >= 0
                      ? new Container(
                          padding: const EdgeInsets.all(10.0),
                          color: theme.primaryColor.withOpacity(0.75),
                          height: 37.5,
                          child: new Text(
                            distString(item.dist),
                            style: theme.primaryTextTheme.subhead,
                          ))
                      : new Container(),
                ]),
              ),
            ],
          ),
        ));
  }
}

const int _childrenPerBlock = 8;
const int _rowsPerBlock = 5;

int _minIndexInRow(int rowIndex) {
  final int blockIndex = rowIndex ~/ _rowsPerBlock;
  return const <int>[0, 2, 4, 6, 7][rowIndex % _rowsPerBlock] +
      blockIndex * _childrenPerBlock;
}

int _maxIndexInRow(int rowIndex) {
  final int blockIndex = rowIndex ~/ _rowsPerBlock;
  return const <int>[1, 3, 5, 6, 7][rowIndex % _rowsPerBlock] +
      blockIndex * _childrenPerBlock;
}

int _rowAtIndex(int index) {
  final int blockCount = index ~/ _childrenPerBlock;
  return const <int>[
        0,
        0,
        1,
        1,
        2,
        2,
        3,
        4
      ][index - blockCount * _childrenPerBlock] +
      blockCount * _rowsPerBlock;
}

int _columnAtIndex(int index) =>
    const <int>[0, 1, 0, 1, 0, 1, 0, 0][index % _childrenPerBlock];

int _columnSpanAtIndex(int index) =>
    const <int>[1, 1, 1, 1, 1, 1, 2, 2][index % _childrenPerBlock];

class _GridLayout extends SliverGridLayout {
  const _GridLayout({
    @required this.rowStride,
    @required this.columnStride,
    @required this.tileHeight,
    @required this.tileWidth,
  });

  final double rowStride;
  final double columnStride;
  final double tileHeight;
  final double tileWidth;

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) =>
      _minIndexInRow(scrollOffset ~/ rowStride);

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) =>
      _maxIndexInRow(scrollOffset ~/ rowStride);

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final int row = _rowAtIndex(index);
    final int column = _columnAtIndex(index);
    final int columnSpan = _columnSpanAtIndex(index);
    return new SliverGridGeometry(
      scrollOffset: row * rowStride,
      crossAxisOffset: column * columnStride,
      mainAxisExtent: tileHeight,
      crossAxisExtent: tileWidth + (columnSpan - 1) * columnStride,
    );
  }

  @override
  double estimateMaxScrollOffset(int childCount) {
    if (childCount == null || childCount == 0) {
      return 0.0;
    }
    final int rowCount = _rowAtIndex(childCount - 1) + 1;
    final double rowSpacing = rowStride - tileHeight;
    return rowStride * rowCount - rowSpacing;
  }
}

class _GridDelegate extends SliverGridDelegate {
  static const double _kSpacing = 8.0;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double tileWidth = (constraints.crossAxisExtent - _kSpacing) / 2.0;
    final double tileHeight = 40.0 + 144.0 + 40.0;
    return new _GridLayout(
      tileWidth: tileWidth,
      tileHeight: tileHeight,
      rowStride: tileHeight + _kSpacing,
      columnStride: tileWidth + _kSpacing,
    );
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) => false;
}

/// Items list class
class ItemsList extends StatelessWidget {
  /// Items list initializer
  const ItemsList(this._items, this._hash);

  final List<Item> _items;

  final String _hash;

  static final _GridDelegate _gridDelegate = new _GridDelegate();

  @override
  Widget build(BuildContext context) => _items.isNotEmpty
      ? new CustomScrollView(slivers: <Widget>[
          new SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: new SliverGrid(
              gridDelegate: _gridDelegate,
              delegate: new SliverChildListDelegate(
                _items
                    .map((item) => new ItemsListItem(
                          item: item,
                          hash: _hash,
                          onPressed: () {
                            showItemPage(item, _hash, context);
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
        ])
      : const Center(child: const Text('No items'));
}
