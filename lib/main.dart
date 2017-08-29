import 'package:spotitems/interactor/services/auth_manager.dart';
import 'package:spotitems/interactor/services/items_manager.dart';
import 'package:spotitems/interactor/services/services.dart';
import 'package:spotitems/ui/app.dart';
import 'package:flutter/material.dart';

final AuthManager _authManager = new AuthManager();
final ItemsManager _itemsManager = new ItemsManager();

void main() {
  Services.setup(_authManager, _itemsManager).then((res) {
    runApp(new SpotItemsApp(res));
  });
}
