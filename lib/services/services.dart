import 'dart:async';

import 'package:spotitem/services/items.dart';
import 'package:spotitem/services/auth.dart';
import 'package:spotitem/services/groups.dart';
import 'package:spotitem/services/users.dart';

class Services {
  static final Services _singleton = new Services._internal();
  static final AuthManager auth = _singleton._authManager;
  static final ItemsManager items = _singleton._itemsManager;
  static final GroupsManager groups = _singleton._groupsManager;
  static final UsersManager users = _singleton._usersManager;
  AuthManager _authManager;
  ItemsManager _itemsManager;
  GroupsManager _groupsManager;
  UsersManager _usersManager;

  Services._internal();

  static Future<bool> setup(AuthManager authManager, ItemsManager itemsManager,
      GroupsManager groupsManager, UsersManager usersManager) async {
    _singleton._authManager = authManager;
    _singleton._itemsManager = itemsManager;
    _singleton._groupsManager = groupsManager;
    _singleton._usersManager = usersManager;
    final bool auth = await _singleton._authManager.init();
    final bool items = await _singleton._itemsManager.init();
    final bool groups = await _singleton._groupsManager.init();
    final bool users = await _singleton._usersManager.init();
    return auth && items && _singleton._authManager.loggedIn && groups && users;
  }
}
