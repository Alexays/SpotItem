import 'package:spotitem/ui/screens/register_screen.dart';
import 'package:spotitem/ui/screens/items/add_item_screen.dart';
import 'package:spotitem/ui/screens/items/edit_item_screen.dart';
import 'package:spotitem/ui/screens/users/profile_screen.dart';
import 'package:spotitem/ui/screens/users/edit_user_screen.dart';
import 'package:spotitem/ui/screens/groups/add_group_screen.dart';
import 'package:spotitem/ui/screens/groups/edit_group_screen.dart';
import 'package:spotitem/ui/screens/debug_screen.dart';
import 'package:spotitem/ui/screens/contact_screen.dart';
import 'package:spotitem/ui/screens/items/item_screen.dart';
import 'package:fluro/fluro.dart';

/// Routes Class
class Routes {
  /// Configure all routes
  static void configureRoutes(Router router) {
    router
      ..define('/register',
          handler: new Handler(
              handlerFunc: (context, params) => const RegisterScreen()))
      ..define('/profile/:id',
          handler: new Handler(
              handlerFunc: (context, params) =>
                  new ProfileScreen(params['id'])))
      ..define('/profile/edit/',
          handler: new Handler(
              handlerFunc: (context, params) => const EditUserScreen()))
      ..define('/items/:id',
          handler: new Handler(
              handlerFunc: (context, params) =>
                  new ItemPage(itemId: params['id'])))
      ..define('/items/:id/edit',
          handler: new Handler(
              handlerFunc: (context, params) =>
                  new EditItemScreen(itemId: params['id'])))
      ..define('/item/add',
          handler: new Handler(
              handlerFunc: (context, params) => const AddItemScreen()))
      ..define('/groups/add',
          handler: new Handler(
              handlerFunc: (context, params) => const AddGroupScreen()))
      ..define('/groups/:id/edit',
          handler: new Handler(
              handlerFunc: (context, params) =>
                  new EditGroupScreen(groupId: params['id'])))
      ..define('/contacts',
          handler: new Handler(
              handlerFunc: (context, params) => const ContactScreen()))
      ..define('/debug',
          handler: new Handler(
              handlerFunc: (context, params) => const DebugScreen()));
  }
}
