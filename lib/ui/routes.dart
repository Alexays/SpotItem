import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/ui/home_screen.dart';
import 'package:spotitems/ui/login_screen.dart';
import 'package:spotitems/ui/register_screen.dart';
import 'package:spotitems/ui/add_item_screen.dart';
import 'package:spotitems/ui/edit_item_screen.dart';
import 'package:spotitems/ui/edit_user_screen.dart';
import 'package:spotitems/ui/add_group_screen.dart';
import 'package:spotitems/ui/item_view.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

typedef Widget HandlerFunc(BuildContext context, Map<String, dynamic> params);

HandlerFunc buildLoginHandler(AuthManager authManager) =>
    (context, params) => new LoginScreen(authManager);

HandlerFunc buildRegisterHandler(AuthManager authManager) =>
    (context, params) => new RegisterScreen(authManager);

HandlerFunc buildHomeHandler(
        AuthManager authManager, ItemsManager itemsManager) =>
    (context, params) => new HomeScreen(authManager, itemsManager);

HandlerFunc buildEditUserHandler(AuthManager authManager) =>
    (context, params) => new EditUserScreen(authManager);

HandlerFunc buildItemHandler(
        AuthManager authManager, ItemsManager itemsManager) =>
    (context, params) => new OrderPage(
        authManager: authManager,
        itemsManager: itemsManager,
        itemId: params['id']);

HandlerFunc buildEditItemHandler(
        AuthManager authManager, ItemsManager itemsManager) =>
    (context, params) =>
        new EditItemScreen(authManager, itemsManager, params['id']);

HandlerFunc buildAddItemHandler(
        AuthManager authManager, ItemsManager itemsManager) =>
    (context, params) => new AddItemScreen(authManager, itemsManager);

HandlerFunc buildAddGroupHandler(
        AuthManager authManager, ItemsManager itemsManager) =>
    (context, params) => new AddGroupScreen(authManager, itemsManager);

void configureRouter(
    Router router, AuthManager authManager, ItemsManager itemsManager) {
  router
    ..define('/login',
        handler: new Handler(handlerFunc: buildLoginHandler(authManager)))
    ..define('/register',
        handler: new Handler(handlerFunc: buildRegisterHandler(authManager)))
    ..define('/home',
        handler: new Handler(
            handlerFunc: buildHomeHandler(authManager, itemsManager)))
    ..define('/user/edit',
        handler: new Handler(handlerFunc: buildEditUserHandler(authManager)))
    ..define('/items/:id',
        handler: new Handler(
            handlerFunc: buildItemHandler(authManager, itemsManager)))
    ..define('/items/:id/edit',
        handler: new Handler(
            handlerFunc: buildEditItemHandler(authManager, itemsManager)))
    ..define('/item/add',
        handler: new Handler(
            handlerFunc: buildAddItemHandler(authManager, itemsManager)))
    ..define('/groups/add',
        handler: new Handler(
            handlerFunc: buildAddGroupHandler(authManager, itemsManager)));

//   router.define('/groups/:id',
//       handler: new Handler(
//           handlerFunc: buildGroupHandler(authManager, itemsManager)));
}
