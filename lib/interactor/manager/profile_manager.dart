import 'dart:async';

import 'dart:convert';
import 'package:spot_items/model/user.dart';
import 'package:spot_items/interactor/manager/auth_manager.dart';

class ProfileManager {
  final AuthManager _authManager;
  final String _email;

  ProfileManager(this._authManager, this._email);

  Future<User> loadUser() async {
    var oauthClient = _authManager.oauthClient;
    var response = await oauthClient
        .get('https://api.github.com/users/${_email}')
        .whenComplete(oauthClient.close);

    if (response.statusCode == 200) {
      var decoded = JSON.decode(response.body);
      return new User.fromJson(decoded);
    } else {
      throw new Exception('Could not get current user');
    }
  }
}
