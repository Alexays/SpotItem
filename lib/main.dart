import 'dart:async';

import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/ui/app.dart';
import 'package:flutter/material.dart';

final AuthManager _authManager = new AuthManager();
final ItemsManager _itemsManager = new ItemsManager();

void main() {
  _init().then((route) {
    runApp(new SpotItemsApp(_authManager, _itemsManager, route));
  });
}

Future<String> _init() async {
  final bool auth = await _authManager.init();
  final bool items = await _itemsManager.init();
  if (auth && items) {
    final String route = _authManager.loggedIn ? '/home' : '/login';
    return (route);
  }
  return '/login';
  //TODO show error page
}
