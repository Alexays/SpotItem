import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';

class UsersManager extends BasicService {
  Future<dynamic> updateUser(User user, String password) async {
    final dynamic userJson = JSON.decode(user.toString());
    userJson['groups'] = 'groups';
    if (password != null) {
      userJson['password'] = password;
    }
    final Response response =
        await iput('/user/edit', userJson, Services.auth.accessToken);
    final dynamic bodyJson = JSON.decode(response.body);
    if (response.statusCode == 200 && bodyJson['success']) {
      Services.auth.user = new User(bodyJson['user']);
      await saveTokens(Services.auth.user.toString(), bodyJson['token'],
          Services.auth.provider);
    }
    return bodyJson;
  }

  Future<dynamic> getUser(String userId) async {
    if (userId == null) {
      return null;
    }
    final Response response =
        await iget('/user/$userId', Services.auth.accessToken);
    if (response.statusCode == 200) {
      final dynamic userJson = JSON.decode(response.body);
      return new User(userJson);
    }
    return null;
  }
}