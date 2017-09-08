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
          theme: new ThemeData(
              primarySwatch: _spotTheme(),
              accentColor: const Color(0xFF06A6D2),
              scaffoldBackgroundColor: Colors.white,
              primaryColor: _spotTheme(),
              backgroundColor: Colors.white),
          onGenerateRoute: Services.router?.generator,
          showPerformanceOverlay: false,
        );
}

MaterialColor _spotTheme() => new MaterialColor(0xFF0498C1, {
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
