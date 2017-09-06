import 'package:spotitem/services/auth.dart';
import 'package:spotitem/services/items.dart';
import 'package:spotitem/services/groups.dart';
import 'package:spotitem/services/users.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

final AuthManager _authManager = new AuthManager();
final ItemsManager _itemsManager = new ItemsManager();
final GroupsManager _groupsManager = new GroupsManager();
final UsersManager _usersManager = new UsersManager();
final Router _router = new Router();

void main() {
  Services
      .setup(
          _authManager, _itemsManager, _groupsManager, _usersManager, _router)
      .then((res) {
    runApp(new SpotItemApp(res));
  });
}