import 'dart:async';

import 'package:spotitem/services/items.dart';
import 'package:spotitem/services/auth.dart';
import 'package:spotitem/services/groups.dart';
import 'package:spotitem/services/users.dart';
import 'package:spotitem/ui/routes.dart';
import 'package:fluro/fluro.dart';

class Services {
  static final Services _singleton = new Services._internal();
  static final AuthManager auth = _singleton._authManager;
  static final ItemsManager items = _singleton._itemsManager;
  static final GroupsManager groups = _singleton._groupsManager;
  static final UsersManager users = _singleton._usersManager;
  static final Router router = _singleton._router;
  AuthManager _authManager;
  ItemsManager _itemsManager;
  GroupsManager _groupsManager;
  UsersManager _usersManager;
  Router _router;

  Services._internal();

  static Future<bool> setup() async {
    _singleton._authManager = new AuthManager();
    _singleton._itemsManager = new ItemsManager();
    _singleton._groupsManager = new GroupsManager();
    _singleton._usersManager = new UsersManager();
    _singleton._router = new Router();
    final bool auth = await _singleton._authManager.init();
    final bool items = await _singleton._itemsManager.init();
    final bool groups = await _singleton._groupsManager.init();
    final bool users = await _singleton._usersManager.init();
    Routes.configureRoutes(_singleton._router);
    return auth && items && groups && users;
  }
}
