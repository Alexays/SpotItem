import 'package:flutter/material.dart';

/// Home screen item
class HomeScreenItem {
  /// Home screen item
  final BottomNavigationBarItem item;

  /// Home screen item body wich can be widget or a list of widgets
  final dynamic body;

  /// Home screen item content used when filters length greater than 0
  final Widget filter;

  /// Home screen item tabs
  final List<HomeScreenSubItem> sub;

  /// Home screen item fabs
  final List<FloatingActionButton> fabs;

  /// Home screen item title
  final String title;

  /// Tabs key
  final Key key;

  /// Home screen item initalizer
  HomeScreenItem({
    parent,
    Widget icon,
    this.title,
    Widget content,
    this.sub,
    this.filter,
    this.fabs,
  })
      : item = new BottomNavigationBarItem(icon: icon, title: new Text(title)),
        key = new Key(title),
        body = sub != null ? sub.map((f) => f.content).toList() : content;
}

/// Home screen sub item
class HomeScreenSubItem {
  /// Home screen sub item title
  final String title;

  /// Home screen sub item content
  final Widget content;

  /// Home screen sub item initializer
  const HomeScreenSubItem(this.title, this.content);
}
