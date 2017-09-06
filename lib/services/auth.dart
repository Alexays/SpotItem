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

  String accessToken;
  String refreshToken;
  DateTime exp;
  String provider;

  User user;
  GoogleSignInAccount _googleUser;

  bool _loggedIn = false;

  @override
  Future<bool> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String _userData = prefs.getString(keyUser) ?? '{}';
    final String _provider = prefs.getString(keyProvider);
    final User _user = new User(JSON.decode(_userData));
    final String _refreshToken = prefs.getString(keyOauthToken);
    if (!_user.isValid() || _refreshToken == null || _provider == null) {
      _loggedIn = false;
      await logout();
    } else {
      user = _user;
      refreshToken = _refreshToken;
      provider = _provider;
      if (_provider == 'google') {
        await handleGoogleSignIn(false);
      }
      await getAccessToken();
      _loggedIn = true;
      connectWs();
    }
    return true;
  }

  Future<String> verifyToken(String token) async {
    if (token != accessToken) {
      return token;
    }
    if (exp == null) {
      await logout();
      return null;
    }
    if (loggedIn && new DateTime.now().isAfter(exp)) {
      await getAccessToken();
    }
    return accessToken;
  }

  Future<Null> getAccessToken() async {
    final Response response = await iget('/check/$provider', refreshToken);
    if (response.statusCode == 200) {
      final dynamic bodyJson = JSON.decode(response.body);
      if (bodyJson['success']) {
        accessToken = bodyJson['access_token'];
        exp = new DateTime.fromMillisecondsSinceEpoch(
            (bodyJson['exp'] * 1000) - 30);
        return;
      }
    }
    await logout();
  }

  Future<bool> handleGoogleSignIn([signIn = true]) async {
    try {
      _googleUser = signIn
          ? await _googleSignIn.signIn()
          : await _googleSignIn.signInSilently();
      if (_googleUser == null) {
        logout();
        return false;
      }
      return login({
        'token': (await _googleUser.authentication).accessToken,
        'user':
            '{"id": "${_googleUser.id}", "name": "${_googleUser.displayName}", "email": "${_googleUser.email}", "avatar": "${_googleUser.photoUrl}"}',
      }, 'google');
    } on Exception {
      _loggedIn = false;
    }
    return _loggedIn;
  }

  Future<bool> login(payload, String _provider) async {
    _loggedIn = false;
    final Response response = await ipost('/login/$_provider', payload);
    if (response.statusCode == 200) {
      final dynamic bodyJson = JSON.decode(response.body);
      if (bodyJson['success']) {
        user = new User(bodyJson['user']);
        accessToken = bodyJson['access_token'];
        exp = new DateTime.fromMillisecondsSinceEpoch(bodyJson['exp'] * 1000);
        await saveTokens(user.toString(), bodyJson['refresh_token'], _provider);
        _loggedIn = true;
        connectWs();
      }
    }
    return _loggedIn;
  }

  Future<Null> logout() async {
    if (provider == 'google') {
      await _googleSignIn.signOut();
    }
    await saveTokens(null, null, null);
    _loggedIn = false;
  }

  Future<dynamic> register(user, String password) async {
    user['_id'] = 'null';
    user['groups'] = 'groups';
    user['password'] = password;
    final Response response = await ipost('/signup', user);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }
}