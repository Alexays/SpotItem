import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';

class UsersManager extends BasicService {
  Future<dynamic> updateUser(User user, String password) async {
    final Client _client = new Client();
    final dynamic userJson = JSON.decode(user.toString());
    userJson['groups'] = 'groups';
    if (password != null) {
      userJson['password'] = password;
    }
    final Response response = await _client
        .put('$apiUrl/user/edit',
            headers: getHeaders(Services.auth.oauthToken), body: userJson)
        .whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    if (response.statusCode == 200 && bodyJson['success']) {
      Services.auth.user = new User.fromJson(bodyJson['user']);
      await saveTokens(Services.auth.user.toString(), bodyJson['token']);
    }
    return bodyJson;
  }

  Future<dynamic> getUser(String userId) async {
    if (userId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client
        .get('$apiUrl/user/$userId',
            headers: getHeaders(Services.auth.oauthToken))
        .whenComplete(_client.close);
    if (response.statusCode == 200) {
      final dynamic userJson = JSON.decode(response.body);
      return new User.fromJson(userJson);
    }
    return null;
  }
}
