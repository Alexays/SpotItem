import 'package:spotitem/ui/screens/home_screen.dart';
import 'package:spotitem/ui/screens/login_screen.dart';
import 'package:spotitem/ui/screens/register_screen.dart';
import 'package:spotitem/ui/screens/add_item_screen.dart';
import 'package:spotitem/ui/screens/edit_item_screen.dart';
import 'package:spotitem/ui/screens/profile_screen.dart';
import 'package:spotitem/ui/screens/edit_user_screen.dart';
import 'package:spotitem/ui/screens/add_group_screen.dart';
import 'package:spotitem/ui/screens/edit_group_screen.dart';
import 'package:spotitem/ui/views/item_view.dart';
import 'package:fluro/fluro.dart';

class Routes {
  static void configureRoutes(Router router) {
    router
      ..define('/login',
          handler: new Handler(
              handlerFunc: (context, params) => const LoginScreen()))
      ..define('/register',
          handler: new Handler(
              handlerFunc: (context, params) => const RegisterScreen()))
      ..define('/home',
          handler:
              new Handler(handlerFunc: (context, params) => const HomeScreen()))
      ..define('/user/:id',
          handler: new Handler(
              handlerFunc: (context, params) =>
                  new ProfileScreen(params['id'])))
      ..define('/user/edit',
          handler: new Handler(
              handlerFunc: (context, params) => const EditUserScreen()))
      ..define('/items/:id',
          handler: new Handler(
              handlerFunc: (context, params) =>
                  new ItemPage(itemId: params['id'])))
      ..define('/items/:id/edit',
          handler: new Handler(
              handlerFunc: (context, params) =>
                  new EditItemScreen(params['id'])))
      ..define('/item/add',
          handler: new Handler(
              handlerFunc: (context, params) => const AddItemScreen()))
      ..define('/groups/add',
          handler: new Handler(
              handlerFunc: (context, params) => const AddGroupScreen()))
      ..define('/groups/:id/edit',
          handler: new Handler(
              handlerFunc: (context, params) =>
                  new EditGroupScreen(params['id'])));
  }
}
