import 'package:spot_items/interactor/manager/auth_manager.dart';
import 'package:spot_items/ui/routes.dart';
import 'package:spot_items/ui/splash_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class SpotItemsApp extends StatelessWidget {
  final Router router = new Router();
  final AuthManager _authManager = new AuthManager();

  SpotItemsApp() {
    configureRouter(router, _authManager);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'SpotItemsApp',
      theme: new ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: new SplashScreen(_authManager),
      onGenerateRoute: router.generator,
    );
  }
}
