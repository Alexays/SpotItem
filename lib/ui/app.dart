import 'package:spotitem/ui/screens/home_screen.dart';
import 'package:spotitem/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';

class SpotItemApp extends MaterialApp {
  final bool init;

  SpotItemApp(this.init)
      : super(
          title: 'SpotItem',
          home: init ? const HomeScreen() : const LoginScreen(),
          theme: _spotTheme,
          onGenerateRoute: Services.router.generator,
          showPerformanceOverlay: false,
        );
}

final _spotTheme =
    new ThemeData(primarySwatch: Colors.pink, accentColor: Colors.pinkAccent);
