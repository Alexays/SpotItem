import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/services/items.dart';
import 'package:spotitem/services/auth.dart';
import 'package:spotitem/services/groups.dart';
import 'package:spotitem/services/users.dart';
import 'package:spotitem/services/settings.dart';
import 'package:spotitem/services/social.dart';
import 'package:spotitem/ui/routes.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

/// API Origin
enum Origin {
  /// Mock is used when testing app
  mock,

  /// prod is used in production
  prod
}

/// Service class
class Services {
  static final Services _singleton = new Services._internal();

  /// Users Service
  static final UsersManager users = _singleton._usersManager;

  /// Auth Service
  static final AuthManager auth = _singleton._authManager;

  /// Items Service
  static final ItemsManager items = _singleton._itemsManager;

  /// Groups Service
  static final GroupsManager groups = _singleton._groupsManager;

  /// Settings Service
  static final SettingsManager settings = _singleton._settingsManager;

  /// Social Service
  static final SocialManager social = _singleton._socialManager;

  /// Router
  static final Router router = _singleton._router;

  /// Loc context
  static BuildContext loc = _singleton._loc;

  /// Context
  static BuildContext context = _singleton._context;

  /// Firebase Messaging
  static FirebaseMessaging firebaseMessaging = _singleton._firebaseMessaging;

  /// Firebase analytics
  static FirebaseAnalytics analytics = _singleton._analytics;

  /// Firebase analytics ovserver
  static FirebaseAnalyticsObserver observer = _singleton._observer;

  /// Origin api endpoint
  static Origin origin = _singleton._origin;

  /// Api mock
  static ApiRes mock = _singleton._mock;

  /// Private variables
  AuthManager _authManager;
  ItemsManager _itemsManager;
  GroupsManager _groupsManager;
  UsersManager _usersManager;
  SettingsManager _settingsManager;
  SocialManager _socialManager;
  Router _router;
  BuildContext _context;
  BuildContext _loc;
  FirebaseMessaging _firebaseMessaging;
  FirebaseAnalytics _analytics;
  FirebaseAnalyticsObserver _observer;
  Origin _origin;
  ApiRes _mock;

  Services._internal();

  /// Setup all services.
  ///
  /// @returns All servies is OK
  static Future<bool> setup(Origin origin, [ApiRes mock]) async {
    _singleton._origin = origin;
    _singleton._mock = mock;
    _singleton._settingsManager = new SettingsManager();
    _singleton._authManager = new AuthManager();
    _singleton._itemsManager = new ItemsManager();
    _singleton._groupsManager = new GroupsManager();
    _singleton._usersManager = new UsersManager();
    _singleton._socialManager = new SocialManager();
    _singleton._router = new Router();
    _singleton._firebaseMessaging = new FirebaseMessaging();
    final bool = [
      await _singleton._settingsManager.init(),
      await _singleton._authManager.init(),
      await _singleton._itemsManager.init(),
      await _singleton._groupsManager.init(),
      await _singleton._usersManager.init(),
      await _singleton._socialManager.init(),
    ];
    Routes.configureRoutes(_singleton._router);
    _singleton._firebaseMessaging.configure(
      onMessage: (message) {
        print('onMessage: $message');
      },
      onLaunch: (message) {
        print('onLaunch: $message');
      },
      onResume: (message) {
        print('onResume: $message');
      },
    );
    _singleton._firebaseMessaging
        .requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    _singleton._firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print('Settings registered: $settings');
    });
    _singleton._analytics = new FirebaseAnalytics();
    _singleton._observer = new FirebaseAnalyticsObserver(analytics: _singleton._analytics);
    return !bool.contains(false);
  }
}
