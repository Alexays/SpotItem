import 'dart:async';
import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final AuthManager _authManager;
  final ItemsManager _itemsManager;

  const SplashScreen(this._authManager, this._itemsManager);

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

  Future<Null> _init() async {
    final bool auth = await _authManager.init();
    final bool items = await _itemsManager.init();
    if (auth && items) {
      final String route = _authManager.loggedIn ? '/home' : '/login';
      Navigator.pushReplacementNamed(context, route);
    }
    //TODO show error page
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: const Center(child: const CircularProgressIndicator()));
}
