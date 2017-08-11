import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/interactor/manager/profile_manager.dart';
import 'package:spotitems/ui/home_screen.dart';
import 'package:spotitems/ui/login_screen.dart';
import 'package:spotitems/ui/profile_screen.dart';
import 'package:spotitems/ui/add_item_screen.dart';
import 'package:spotitems/ui/edit_item_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

typedef Widget HandlerFunc(BuildContext context, Map<String, dynamic> params);

HandlerFunc buildLoginHandler(AuthManager authManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new LoginScreen(authManager);
}

HandlerFunc buildHomeHandler(
    AuthManager authManager, ItemsManager itemsManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new HomeScreen(authManager, itemsManager);
}

HandlerFunc buildUserHandler(AuthManager authManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new ProfileScreen(new ProfileManager(authManager, params['username']),
          params['username']);
}

HandlerFunc buildEditItemHandler(AuthManager authManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new EditItemScreen(authManager, params['id']);
}

HandlerFunc buildAddItemHandler(AuthManager authManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new AddItemScreen(authManager);
}

void configureRouter(
    Router router, AuthManager authManager, ItemsManager itemsManager) {
  router.define('/login',
      handler: new Handler(handlerFunc: buildLoginHandler(authManager)));

  router.define('/home',
      handler: new Handler(
          handlerFunc: buildHomeHandler(authManager, itemsManager)));

  router.define('/user',
      handler: new Handler(handlerFunc: buildUserHandler(authManager)));

  router.define('/users/:username',
      handler: new Handler(handlerFunc: buildUserHandler(authManager)));

  router.define('/items/:id/edit',
      handler: new Handler(handlerFunc: buildEditItemHandler(authManager)));

  router.define('/addItem',
      handler: new Handler(handlerFunc: buildAddItemHandler(authManager)));
}
