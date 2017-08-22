import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/ui/routes.dart';
import 'package:spotitems/ui/splash_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class SpotItemsApp extends StatelessWidget {
  final Router router = new Router();
  final AuthManager _authManager = new AuthManager();
  final ItemsManager _itemsManager = new ItemsManager();

  SpotItemsApp() {
    configureRouter(router, _authManager, _itemsManager);
  }

  @override
  Widget build(BuildContext context) => new MaterialApp(
        title: 'SpotItems',
        theme: new ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: new SplashScreen(_authManager, _itemsManager),
        onGenerateRoute: router.generator,
      );
}
