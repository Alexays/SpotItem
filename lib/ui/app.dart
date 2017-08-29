import 'package:spotitem/ui/routes.dart';
import 'package:spotitem/ui/home_screen.dart';
import 'package:spotitem/ui/login_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class SpotItemApp extends MaterialApp {
  static final Router router = configureRouter(new Router());
  final bool init;

  SpotItemApp(this.init)
      : super(
          debugShowCheckedModeBanner: false,
          title: 'SpotItem',
          home: init ? const HomeScreen() : const LoginScreen(),
          theme: new ThemeData(
            primarySwatch: Colors.pink,
          ),
          onGenerateRoute: router.generator,
        );
}

final _twitchTheme = new ThemeData(
  primaryColor: const Color.fromRGBO(0x67, 0x3A, 0xB7, 1.0),
  accentColor: const Color.fromRGBO(0x9E, 0x9E, 0x9E, 1.0),
);
