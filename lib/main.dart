import 'package:spotitem/interactor/services/auth_manager.dart';
import 'package:spotitem/interactor/services/items_manager.dart';
import 'package:spotitem/interactor/services/services.dart';
import 'package:spotitem/ui/app.dart';
import 'package:flutter/material.dart';

final AuthManager _authManager = new AuthManager();
final ItemsManager _itemsManager = new ItemsManager();

void main() {
  Services.setup(_authManager, _itemsManager).then((res) {
    runApp(new SpotItemApp(res));
  });
}
