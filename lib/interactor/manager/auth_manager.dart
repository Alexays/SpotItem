import 'dart:async';
import 'dart:convert';
import 'package:spotitems/keys.dart';
import 'package:spotitems/model/user.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String KEY_USER = 'KEY_USER';
  static const String KEY_OAUTH_TOKEN = 'KEY_AUTH_TOKEN';

  bool get initialized => _initialized;

  bool get loggedIn => _loggedIn;

  User get user => _user;

  OauthClient get oauthClient => _oauthClient;

  final String _clientSecret = CLIENT_SECRET;
  bool _initialized;
  bool _loggedIn;
  User _user;
  OauthClient _oauthClient;

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User user = new User.fromJson(JSON.decode(prefs.getString(KEY_USER)));
    String oauthToken = prefs.getString(KEY_OAUTH_TOKEN);
    final Client _client = new Client();

    if (user == null || oauthToken == null) {
      _loggedIn = false;
      await logout();
    } else {
      _loggedIn = true;
      _user = user;
      _oauthClient = new OauthClient(_client, oauthToken);
    }

    _initialized = true;
  }

  Future<bool> login(String email, String password) async {
    final Client _client = new Client();
    final loginResponse = await _client.post(Uri.encodeFull(API_URL + '/login'),
        headers: {
          'Authorization': 'Basic ${_clientSecret}'
        },
        body: {
          'email': email,
          'password': password
        }).whenComplete(_client.close);

    if (loginResponse.statusCode == 200) {
      final bodyJson = JSON.decode(loginResponse.body);
      if (bodyJson['success']) {
        _user = new User.fromJson(bodyJson['user']);
        await _saveTokens(_user.toString(), bodyJson['token']);
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
    } else {
      _loggedIn = false;
    }

    return _loggedIn;
  }

  Future logout() async {
    await _saveTokens(null, null);
    _loggedIn = false;
  }

  Future _saveTokens(String user, String oauthToken) async {
    final Client _client = new Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY_USER, user);
    prefs.setString(KEY_OAUTH_TOKEN, oauthToken);
    await prefs.commit();
    _oauthClient = new OauthClient(_client, oauthToken);
  }
}

class OauthClient extends _AuthClient {
  OauthClient(Client client, String token) : super(client, 'JWT ${token}');
}

abstract class _AuthClient extends BaseClient {
  final Client _client;
  final String _authorization;

  _AuthClient(this._client, this._authorization);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers['Authorization'] = _authorization;
    return _client.send(request);
  }
}
