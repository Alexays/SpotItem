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

  /// Returns the color scheme used by spotitem
  MaterialColor spotColor() => new MaterialColor(0xFF0498C1, {
        50: const Color(0xFFE1F3F8),
        100: const Color(0xFFB4E0EC),
        200: const Color(0xFF82CCE0),
        300: const Color(0xFF4FB7D4),
        400: const Color(0xFF2AA7CA),
        500: const Color(0xFF0498C1),
        600: const Color(0xFF0390BB),
        700: const Color(0xFF0385B3),
        800: const Color(0xFF027BAB),
        900: const Color(0xFF016A9E)
      });

  @override
  Widget build(BuildContext context) => new MaterialApp(
        title: 'SpotItems',
        theme: new ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: route == '/login'
            ? new LoginScreen(_authManager)
            : new HomeScreen(_authManager, _itemsManager),
        onGenerateRoute: router.generator,
      );
}
