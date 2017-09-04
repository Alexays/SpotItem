import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/basic.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager extends BasicService {
  bool get loggedIn => _loggedIn;

  String oauthToken;

  User user;

  bool _loggedIn;

  @override
  Future<bool> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userData = prefs.getString(keyUser);
    userData ??= '{}';
    final User _user = new User.fromJson(JSON.decode(userData));
    final String _oauthToken = prefs.getString(keyOauthToken);
    if (_user == null || _user.id == null || _oauthToken == null) {
      _loggedIn = false;
      await logout();
    } else {
      user = _user;
      oauthToken = _oauthToken;
      _loggedIn = true;
      connectWs();
    }
    return true;
  }

  void connectWs() {
    final channel = new IOWebSocketChannel.connect('ws://217.182.65.67:1337');
    channel.sink.add(JSON.encode({'type': 1, 'userId': user.id}));
    channel.stream.listen((message) {
      print(message);
    });
  }

  Future<bool> login(String email, String password) async {
    final Client _client = new Client();
    final Response response = await _client.post('$apiUrl/login',
        headers: getHeaders(),
        body: {
          'email': email,
          'password': password
        }).whenComplete(_client.close);
    if (response.statusCode == 200) {
      final dynamic bodyJson = JSON.decode(response.body);
      if (bodyJson['success']) {
        user = new User.fromJson(bodyJson['user']);
        await saveTokens(user.toString(), bodyJson['token']);
        _loggedIn = true;
        connectWs();
      } else {
        _loggedIn = false;
      }
    } else {
      _loggedIn = false;
    }
    return _loggedIn;
  }

  Future<Null> logout() async {
    await saveTokens(null, null);
    _loggedIn = false;
  }

  Future<dynamic> register(User user, String password) async {
    final Client _client = new Client();
    final dynamic userJson = JSON.decode(user.toString());
    userJson['_id'] = 'null';
    userJson['groups'] = 'groups';
    userJson['password'] = password;
    final Response response = await _client
        .post('$apiUrl/signup', headers: getHeaders(), body: userJson)
        .whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }
}
