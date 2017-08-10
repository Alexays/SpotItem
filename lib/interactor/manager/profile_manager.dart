import 'dart:async';

import 'dart:convert';
import 'package:spotitems/model/user.dart';
import 'package:spotitems/interactor/manager/auth_manager.dart';

class ProfileManager {
  final AuthManager _authManager;
  final User _user;

  ProfileManager(this._authManager, this._user);

  Future<User> loadUser() async {
    var oauthClient = _authManager.oauthClient;
    var response = await oauthClient
        .get('https://api.github.com/users/${_user.email}')
        .whenComplete(oauthClient.close);

    if (response.statusCode == 200) {
      var decoded = JSON.decode(response.body);
      return new User.fromJson(decoded);
    } else {
      throw new Exception('Could not get current user');
    }
  }
}
