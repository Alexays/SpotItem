import 'dart:async';
import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final AuthManager _authManager;
  final ItemsManager _itemsManager;

  SplashScreen(this._authManager, this._itemsManager);

  @override
  State<StatefulWidget> createState() =>
      new _SplashState(_authManager, _itemsManager);
}

class _SplashState extends State<SplashScreen> {
  final AuthManager _authManager;
  final ItemsManager _itemsManager;

  _SplashState(this._authManager, this._itemsManager);

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _itemsManager.close();
  }

  Future _init() async {
    await _authManager.init();
    await _itemsManager.init();

    String route = _authManager.loggedIn ? '/home' : '/login';

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Center(child: new CircularProgressIndicator()));
  }
}
