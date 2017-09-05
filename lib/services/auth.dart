import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/basic.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class AuthManager extends BasicService {
  bool get loggedIn => _loggedIn;

  String oauthToken;
  String provider;

  User user;
  GoogleSignInAccount _googleUser;

  bool _loggedIn;

  @override
  Future<bool> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String _userData = prefs.getString(keyUser) ?? '{}';
    final String _provider = prefs.getString(keyProvider);
    final User _user = new User(JSON.decode(_userData));
    final String _oauthToken = prefs.getString(keyOauthToken);
    if (_provider == 'google') {
      _googleUser = await _googleSignIn.signInSilently();
      await handleGoogleSignIn(false);
    }
    if (!_user.isValid() || _oauthToken == null || _provider == null) {
      _loggedIn = false;
      await logout();
    } else {
      user = _user;
      oauthToken = _oauthToken;
      provider = _provider;
      _loggedIn = true;
      connectWs();
    }
    return true;
  }

  Future<bool> handleGoogleSignIn([signIn = true]) async {
    try {
      if (signIn) {
        _googleUser = await _googleSignIn.signIn();
      }
      final Client _client = new Client();
      final Response response = await _client
          .post('$apiUrl/login/google', headers: getHeaders(), body: {
        'token': (await _googleUser.authentication).accessToken,
        'user':
            '{"id": "${_googleUser.id}", "name": "${_googleUser.displayName}", "email": "${_googleUser.email}", "avatar": "${_googleUser.photoUrl}"}',
      }).whenComplete(_client.close);
      _loggedIn = false;
      if (response.statusCode == 200) {
        final dynamic bodyJson = JSON.decode(response.body);
        print(bodyJson);
        if (bodyJson['success']) {
          user = new User(bodyJson['user']);
          await saveTokens(user.toString(), bodyJson['token'], 'google');
          _loggedIn = true;
          connectWs();
        }
      }
    } catch (error) {
      _loggedIn = false;
    }
    return _loggedIn;
  }

  Future<bool> login(String email, String password) async {
    final Client _client = new Client();
    final Response response = await _client.post('$apiUrl/login',
        headers: getHeaders(),
        body: {
          'email': email,
          'password': password
        }).whenComplete(_client.close);
    _loggedIn = false;
    if (response.statusCode == 200) {
      final dynamic bodyJson = JSON.decode(response.body);
      if (bodyJson['success']) {
        user = new User(bodyJson['user']);
        await saveTokens(user.toString(), bodyJson['token'], 'local');
        _loggedIn = true;
        connectWs();
      }
    }
    return _loggedIn;
  }

  Future<Null> logout() async {
    await saveTokens(null, null, null);
    _loggedIn = false;
  }

  Future<dynamic> register(user, String password) async {
    final Client _client = new Client();
    user['_id'] = 'null';
    user['groups'] = 'groups';
    user['password'] = password;
    final Response response = await _client
        .post('$apiUrl/signup', headers: getHeaders(), body: user)
        .whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }
}
