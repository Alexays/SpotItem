import 'dart:async';

import 'package:spotitem/services/items.dart';
import 'package:spotitem/services/auth.dart';

class Services {
  static final Services _singleton = new Services._internal();
  static final AuthManager authManager = _singleton._authManager;
  static final ItemsManager itemsManager = _singleton._itemsManager;
  AuthManager _authManager;
  ItemsManager _itemsManager;

  Services._internal();

  static Future<bool> setup(
      AuthManager authManager, ItemsManager itemsManager) async {
    _singleton._authManager = authManager;
    _singleton._itemsManager = itemsManager;
    final bool auth = await _singleton._authManager.init();
    final bool items = await _singleton._itemsManager.init();
    return auth && items && _singleton._authManager.loggedIn;
  }
}
