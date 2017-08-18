import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/ui/home_screen.dart';
import 'package:spotitems/ui/login_screen.dart';
import 'package:spotitems/ui/add_item_screen.dart';
import 'package:spotitems/ui/edit_item_screen.dart';
import 'package:spotitems/ui/edit_user_screen.dart';
import 'package:spotitems/ui/add_group_screen.dart';
import 'package:spotitems/ui/item_view.dart';
import 'package:spotitems/ui/group_view.dart';
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

HandlerFunc buildEditUserHandler(AuthManager authManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new EditUserScreen(authManager);
}

HandlerFunc buildItemHandler(
    AuthManager authManager, ItemsManager itemsManager) {
  return (BuildContext context, Map<String, dynamic> params) => new OrderPage(
      authManager: authManager,
      itemsManager: itemsManager,
      itemId: params['id']);
}

HandlerFunc buildEditItemHandler(
    AuthManager authManager, ItemsManager itemsManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new EditItemScreen(authManager, itemsManager, params['id']);
}

HandlerFunc buildAddItemHandler(
    AuthManager authManager, ItemsManager itemsManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new AddItemScreen(authManager, itemsManager);
}

HandlerFunc buildAddGroupHandler(
    AuthManager authManager, ItemsManager itemsManager) {
  return (BuildContext context, Map<String, dynamic> params) =>
      new AddGroupScreen(authManager, itemsManager);
}

void configureRouter(
    Router router, AuthManager authManager, ItemsManager itemsManager) {
  router.define('/login',
      handler: new Handler(handlerFunc: buildLoginHandler(authManager)));

  router.define('/home',
      handler: new Handler(
          handlerFunc: buildHomeHandler(authManager, itemsManager)));

  router.define('/user/edit',
      handler: new Handler(handlerFunc: buildEditUserHandler(authManager)));

  router.define('/items/:id',
      handler: new Handler(
          handlerFunc: buildItemHandler(authManager, itemsManager)));

  router.define('/items/:id/edit',
      handler: new Handler(
          handlerFunc: buildEditItemHandler(authManager, itemsManager)));

  router.define('/item/add',
      handler: new Handler(
          handlerFunc: buildAddItemHandler(authManager, itemsManager)));

//   router.define('/groups/:id',
//       handler: new Handler(
//           handlerFunc: buildGroupHandler(authManager, itemsManager)));

  router.define('/groups/add',
      handler: new Handler(
          handlerFunc: buildAddGroupHandler(authManager, itemsManager)));
}
