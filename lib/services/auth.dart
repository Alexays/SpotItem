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
        _googleUser = await _googleSignIn.signInSilently();
        await handleGoogleSignIn(false);
      } else {
        await getAccessToken();
      }
      _loggedIn = true;
      connectWs();
    }
    return true;
  }

  Future<Null> verifyToken(String url) async {
    if (loggedIn && url != '/check' && !new DateTime.now().isAfter(exp)) {
      await getAccessToken();
    }
  }

  Future<Null> getAccessToken() async {
    final Response response = await iget('/check', refreshToken);
    if (response.statusCode == 200) {
      final dynamic bodyJson = JSON.decode(response.body);
      if (bodyJson['success']) {
        accessToken = bodyJson['access_token'];
        exp = new DateTime.fromMillisecondsSinceEpoch(bodyJson['exp'] * 1000);
        return;
      }
    }
    logout();
  }

  Future<bool> handleGoogleSignIn([signIn = true]) async {
    try {
      if (signIn) {
        _googleUser = await _googleSignIn.signIn();
      }
      if (_googleUser == null) {
        logout();
        return false;
      }
      _loggedIn = false;
      final Response response = await ipost('/login/google', {
        'token': (await _googleUser.authentication).accessToken,
        'user':
            '{"id": "${_googleUser.id}", "name": "${_googleUser.displayName}", "email": "${_googleUser.email}", "avatar": "${_googleUser.photoUrl}"}',
      });
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
    _loggedIn = false;
    final Response response =
        await ipost('/login', {'email': email, 'password': password});
    if (response.statusCode == 200) {
      final dynamic bodyJson = JSON.decode(response.body);
      if (bodyJson['success']) {
        user = new User(bodyJson['user']);
        accessToken = bodyJson['access_token'];
        exp = new DateTime.fromMillisecondsSinceEpoch(bodyJson['exp'] * 1000);
        await saveTokens(user.toString(), bodyJson['refresh_token'], 'local');
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