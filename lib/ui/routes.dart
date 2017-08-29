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

HandlerFunc buildLoginHandler() => (context, params) => const LoginScreen();

HandlerFunc buildRegisterHandler() =>
    (context, params) => const RegisterScreen();

HandlerFunc buildHomeHandler() => (context, params) => const HomeScreen();

HandlerFunc buildEditUserHandler() =>
    (context, params) => const EditUserScreen();

HandlerFunc buildItemHandler() =>
    (context, params) => new OrderPage(itemId: params['id']);

HandlerFunc buildEditItemHandler() =>
    (context, params) => new EditItemScreen(params['id']);

HandlerFunc buildAddItemHandler() => (context, params) => const AddItemScreen();

HandlerFunc buildAddGroupHandler() =>
    (context, params) => const AddGroupScreen();

Router configureRouter(Router router) {
  router
    ..define('/login', handler: new Handler(handlerFunc: buildLoginHandler()))
    ..define('/register',
        handler: new Handler(handlerFunc: buildRegisterHandler()))
    ..define('/home', handler: new Handler(handlerFunc: buildHomeHandler()))
    ..define('/user/edit',
        handler: new Handler(handlerFunc: buildEditUserHandler()))
    ..define('/items/:id',
        handler: new Handler(handlerFunc: buildItemHandler()))
    ..define('/items/:id/edit',
        handler: new Handler(handlerFunc: buildEditItemHandler()))
    ..define('/item/add',
        handler: new Handler(handlerFunc: buildAddItemHandler()))
    ..define('/groups/add',
        handler: new Handler(handlerFunc: buildAddGroupHandler()));

//   router.define('/groups/:id',
//       handler: new Handler(
//           handlerFunc: buildGroupHandler(authManager, itemsManager)));
  return router;
}
