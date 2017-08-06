import 'package:spot_items/interactor/manager/auth_manager.dart';
import 'package:spot_items/interactor/manager/profile_manager.dart';
import 'package:spot_items/ui/home_screen.dart';
import 'package:spot_items/ui/login_screen.dart';
import 'package:spot_items/ui/profile_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

typedef Widget HandlerFunc(BuildContext context, Map<String, dynamic> params);

HandlerFunc buildLoginHandler(AuthManager authManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new LoginScreen(authManager);
}

HandlerFunc buildHomeHandler(AuthManager authManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new HomeScreen(authManager);
}

HandlerFunc buildUserHandler(AuthManager authManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new ProfileScreen(new ProfileManager(authManager, params['username']),
          params['username']);
}

HandlerFunc buildItemHandler(AuthManager authManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new ProfileScreen(new ProfileManager(authManager, params['username']),
          params['username']);
}

void configureRouter(Router router, AuthManager authManager) {
  router.define('/login',
      handler: new Handler(handlerFunc: buildLoginHandler(authManager)));

  router.define('/home',
      handler: new Handler(handlerFunc: buildHomeHandler(authManager)));

  router.define('/user',
      handler: new Handler(handlerFunc: buildUserHandler(authManager)));

  router.define('/users/:username',
      handler: new Handler(handlerFunc: buildUserHandler(authManager)));

  router.define('/items/:id/edit',
      handler: new Handler(handlerFunc: buildItemHandler(authManager)));
}
