import 'package:flutter/material.dart';

/// Home screen item
class HomeScreenItem {
  /// Home screen item
  final BottomNavigationBarItem item;

  /// Home screen item contents
  final List<Widget> contents;

  /// Home screen item content
  final Widget content;

  /// Home screen sub app bar widget
  final bool filter;

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
    this.content,
    this.sub,
    this.filter = false,
    this.fabs,
  })
      : item = new BottomNavigationBarItem(icon: icon, title: new Text(title)),
        key = new Key(title),
        contents = sub != null ? sub.map((f) => f.content).toList() : null;
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
