import 'package:spotitem/ui/routes.dart';
import 'package:spotitem/ui/screen/home_screen.dart';
import 'package:spotitem/ui/screen/login_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class SpotItemApp extends MaterialApp {
  static final Router router = configureRouter(new Router());
  final bool init;

  SpotItemApp(this.init)
      : super(
          title: 'SpotItem',
          home: init ? const HomeScreen() : const LoginScreen(),
          theme: _spotTheme,
          onGenerateRoute: router.generator,
        );
}

final _spotTheme = new ThemeData(
  primarySwatch: Colors.pink,
);
