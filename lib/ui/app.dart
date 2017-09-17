import 'dart:async';
import 'package:spotitem/ui/screens/home_screen.dart';
import 'package:spotitem/ui/screens/login_screen.dart';
import 'package:spotitem/ui/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/ui/spot_strings.dart';

class _SpotLocalizationsDelegate extends LocalizationsDelegate<SpotL> {
  @override
  Future<SpotL> load(Locale locale) => SpotL.load(locale);

  @override
  bool shouldReload(_SpotLocalizationsDelegate old) => false;
}

/// SpotitemApp class
class SpotItemApp extends MaterialApp {
  /// Services is Init
  final bool init;

  ///SpotItemApp initlializer
  SpotItemApp(this.init)
      : super(
          title: 'SpotItem',
          home: new Builder(builder: (context) {
            Services.loc = context;
            return init
                ? (Services.auth.loggedIn
                    ? const HomeScreen()
                    : const LoginScreen())
                : const ErrorScreen();
          }),
          theme: new ThemeData(
              accentColor: const Color(0xFF06A6D2),
              indicatorColor: Colors.white,
              primarySwatch: new MaterialColor(0xFF0498C1, {
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
              }),
              backgroundColor: Colors.white),
          onGenerateRoute: Services.router?.generator,
          showPerformanceOverlay: false,
          localizationsDelegates: <_SpotLocalizationsDelegate>[
            new _SpotLocalizationsDelegate(),
          ],
          supportedLocales: const <Locale>[
            const Locale('en', 'US'),
            const Locale('fr', 'FR')
          ],
        );
}
