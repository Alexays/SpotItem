import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/ui/routes.dart';
import 'package:spotitems/ui/home_screen.dart';
import 'package:spotitems/ui/login_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class SpotItemsApp extends StatelessWidget {
  final Router router = new Router();
  final AuthManager _authManager;
  final ItemsManager _itemsManager;
  final String route;

  SpotItemsApp(this._authManager, this._itemsManager, this.route) {
    configureRouter(router, _authManager, _itemsManager);
  }

  @override
  Widget build(BuildContext context) => new MaterialApp(
        title: 'SpotItems',
        theme: new ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: route == '/login'
            ? new LoginScreen(_authManager)
            : new HomeScreen(_authManager, _itemsManager),
        onGenerateRoute: router.generator,
      );
}
