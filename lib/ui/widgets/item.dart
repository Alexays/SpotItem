import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/ui/screens/items/item_screen.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/services/services.dart';

/// Items list item
class ItemsListItem extends StatelessWidget {
  /// Items list item initializer
  const ItemsListItem({@required this.item, Key key, this.hash, this.onPressed})
      : assert(item != null),
        super(key: key);

  /// Hash for hero animation
  final num hash;

  /// Item data
  final Item item;

  /// Callback when item is pressed
  final VoidCallback onPressed;

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    final widgets = <Widget>[
      new Expanded(
        child: new Text(
          capitalize(item.name),
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ];
    if (item.dist >= 0) {
      widgets.add(new Chip(
        backgroundColor: theme.primaryColor,
        label: new Text(
          distString(item.dist),
          style: theme.primaryTextTheme.subhead.copyWith(fontSize: 14.0),
        ),
      ));
    }
    return new Row(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: onPressed,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Card(
            child: new Stack(
              children: <Widget>[
                new Hero(
                  tag: '${item.id}$hash',
                  child: new FadeInImage(
                    height: 192.0, // TO-DO weird value
                    placeholder: placeholder,
                    image: item.images.isNotEmpty
                        ? new NetworkImage(
                            '$apiImgUrl${item.images.first}',
                            headers: getHeaders(
                              key: Services.auth.accessToken,
                              type: contentType.image,
                            ),
                          )
                        : placeholder,
                    fit: BoxFit.cover,
                  ),
                ),
                new Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: new Container(
                    decoration: const BoxDecoration(
                      gradient: const LinearGradient(
                        begin: const Alignment(0.0, 1.0),
                        end: const Alignment(0.0, -1.0),
                        colors: const <Color>[
                          Colors.black38,
                          Colors.black12,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: _buildInfo(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const int _childrenPerBlock = 8;
const int _rowsPerBlock = 5;

int _minIndexInRow(int rowIndex) {
  final blockIndex = rowIndex ~/ _rowsPerBlock;
  return const <int>[0, 2, 4, 6, 7][rowIndex % _rowsPerBlock] +
      blockIndex * _childrenPerBlock;
}

int _maxIndexInRow(int rowIndex) {
  final blockIndex = rowIndex ~/ _rowsPerBlock;
  return const <int>[1, 3, 5, 6, 7][rowIndex % _rowsPerBlock] +
      blockIndex * _childrenPerBlock;
}

int _rowAtIndex(int index) {
  final blockCount = index ~/ _childrenPerBlock;
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
    final row = _rowAtIndex(index);
    final column = _columnAtIndex(index);
    final columnSpan = _columnSpanAtIndex(index);
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
    final rowCount = _rowAtIndex(childCount - 1) + 1;
    final rowSpacing = rowStride - tileHeight;
    return rowStride * rowCount - rowSpacing;
  }
}

class _GridDelegate extends SliverGridDelegate {
  static const double _kSpacing = 8.0;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final tileWidth = (constraints.crossAxisExtent - _kSpacing) / 2.0;
    final tileHeight = 40.0 + 144.0 + 40.0;
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

  final num _hash;

  static final _GridDelegate _gridDelegate = new _GridDelegate();

  @override
  Widget build(BuildContext context) => _items.isNotEmpty
      ? new CustomScrollView(
          // For RefreshIndicator
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
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
      : new Center(child: new Text(SpotL.of(context).noItems));
}
