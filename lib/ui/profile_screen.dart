import 'package:spotitems/interactor/manager/profile_manager.dart';
import 'package:spotitems/ui/profile_view.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileManager _profileManager;
  final String _username;

  ProfileScreen(this._profileManager, this._username);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(),
      body: new ProfileView(_profileManager, _username),
    );
  }
}
