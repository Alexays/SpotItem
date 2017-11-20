import 'package:spotitem/ui/screens/register_screen.dart';
import 'package:spotitem/ui/screens/items/add_item_screen.dart';
import 'package:spotitem/ui/screens/items/edit_item_screen.dart';
import 'package:spotitem/ui/screens/users/profile_screen.dart';
import 'package:spotitem/ui/screens/users/edit_user_screen.dart';
import 'package:spotitem/ui/screens/groups/add_group_screen.dart';
import 'package:spotitem/ui/screens/groups/edit_group_screen.dart';
import 'package:spotitem/ui/screens/social/add_conversation_screen.dart';
import 'package:spotitem/ui/screens/debug_screen.dart';
import 'package:spotitem/ui/screens/contact_screen.dart';
import 'package:spotitem/ui/screens/settings_screen.dart';
import 'package:spotitem/ui/screens/items/item_screen.dart';
import 'package:spotitem/ui/screens/error_screen.dart';
import 'package:flutter/material.dart';

/// Static Routes
Map<String, WidgetBuilder> staticRoutes = {
  '/register': (_) => new RegisterScreen(),
  '/profile/edit/': (_) => const EditUserScreen(),
  '/items/add/': (_) => const AddItemScreen(),
  '/groups/add/': (_) => const AddGroupScreen(),
  '/messages/add/': (_) => const AddConvScreen(),
  '/contacts': (_) => const ContactScreen(),
  '/settings': (_) => const SettingsScreen(),
  '/debug': (_) => const DebugScreen(),
  '/error': (_) => const ErrorScreen(),
};

/// Configure all routes
Route<dynamic> configureRoutes(RouteSettings settings) {
  final splittedName = settings.name.split('/');
  final params = splittedName
      .where((f) => f.startsWith(':'))
      .map((f) => f.substring(1))
      .toList();
  final routes = splittedName
      .map((f) => params.any((d) => f.length > 1 && d == f.substring(1))
          ? ':params'
          : f)
      .join('/');
  switch (routes) {
    case '/profile/:params':
      return new MaterialPageRoute<dynamic>(
          settings: settings, builder: (_) => new ProfileScreen(params[0]));
    case '/items/:params':
      return new MaterialPageRoute<dynamic>(
          settings: settings, builder: (_) => new ItemPage(itemId: params[0]));
    case '/items/:params/book':
      return new MaterialPageRoute<dynamic>(
          settings: settings,
          fullscreenDialog: true,
          builder: (_) => new ItemPage(itemId: params[0]));
    case '/items/:params/edit':
      return new MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => new EditItemScreen(itemId: params[0]));
    case '/groups/:params/edit':
      return new MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => new EditGroupScreen(groupId: params[0]));
    default:
      return errorRoute(settings);
  }
}

/// On error routes
Route<dynamic> errorRoute(RouteSettings settings) =>
    new MaterialPageRoute<dynamic>(
        settings: settings, builder: (_) => const ErrorScreen());
