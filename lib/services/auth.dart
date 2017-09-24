import 'dart:async';
import 'dart:convert';
import 'package:spotitem/keys.dart';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/basic.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';

GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

/// Auth class manager
class AuthManager extends BasicService {
  /// Check if user is logged in
  bool get loggedIn => _loggedIn;

  /// Token to access API data
  String accessToken;

  /// Token to regenerate access_token
  String refreshToken;

  /// Date of expiration of access_token
  DateTime exp;

  /// Login provider (google, local)
  String provider;

  /// User data
  User user;

  /// Last email used
  String get lastEmail => _lastEmail;

  /// Google user data
  GoogleSignInAccount get googleUser => _googleUser;

  /// Private variables
  bool _loggedIn = false;
  GoogleSignInAccount _googleUser;
  String _lastEmail;

  @override
  Future<bool> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _lastEmail = prefs.getString(keyLastEmail) ?? '';
    final String _userData = prefs.getString(keyUser) ?? '{}';
    final String _provider = prefs.getString(keyProvider);
    final String _refreshToken = prefs.getString(keyOauthToken);
    try {
      final User _user = new User(JSON.decode(_userData));
      if (!_user.isValid() ||
          _refreshToken == null ||
          !providers.contains(_provider)) {
        await logout();
        return _loggedIn = false;
      }
      user = _user;
      refreshToken = _refreshToken;
      provider = _provider;
      switch (_provider) {
        case 'google':
          await handleGoogleSignIn(false);
      }
      connectWs();
    } on Exception {
      return _loggedIn = false;
    }
    return _loggedIn = true;
  }

  /// Check if access_token is expired and regenerate it if expired.
  ///
  /// @param token Token will be user to access API
  /// @returns Valid token
  Future<String> verifyToken(String token) async {
    if ((token == null && accessToken != null) || token != accessToken) {
      return token;
    }
    if (loggedIn && (exp == null || new DateTime.now().isAfter(exp))) {
      if (!await getAccessToken()) {
        await Navigator
            .of(Services.context)
            .pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
    return accessToken;
  }

  /// Regenerate access_token.
  ///
  Future<bool> getAccessToken() async {
    final ApiRes response = await iget('/check/$provider', refreshToken);
    if (response.statusCode == 200 && response.success) {
      accessToken = response.data['access_token'];
      exp = new DateTime.fromMillisecondsSinceEpoch(
          (response.data['exp'] * 1000) - 30);
      return true;
    }
    await logout();
    return false;
  }

  /// Pre login with google account.
  ///
  /// @param signIn Login/re-login
  /// @returns Logged or not
  /// TO-DO don't send user data, just get it on API with access_token
  Future<bool> handleGoogleSignIn([bool signIn = true]) async {
    try {
      _googleUser = signIn
          ? await _googleSignIn.signIn()
          : await _googleSignIn.signInSilently();
      if (_googleUser == null) {
        await logout();
        return false;
      }
      if (signIn) {
        return await login({
          'token': (await _googleUser.authentication).accessToken,
          'user':
              '{"id": "${_googleUser.id}", "name": "${_googleUser.displayName}", "email": "${_googleUser.email}", "avatar": "${_googleUser.photoUrl}"}',
        }, 'google');
      }
    } on Exception {
      _googleUser = null;
      _loggedIn = false;
    }
    return _loggedIn;
  }

  /// Login to api with special provider.
  ///
  /// @param payload User payload
  /// @param _provider Login provider
  /// @returns Logged or not
  Future<bool> login(_payload, String _provider) async {
    _loggedIn = false;
    final ApiRes response = await ipost('/login/$_provider', _payload);
    if (response.statusCode == 200 && response.success) {
      if (_payload['email'] != null) {
        await SharedPreferences.getInstance()
          ..setString(keyLastEmail, _payload['email']);
        _lastEmail = _payload['email'];
      }
      user = new User(response.data['user']);
      accessToken = response.data['access_token'];
      exp =
          new DateTime.fromMillisecondsSinceEpoch(response.data['exp'] * 1000);
      await saveTokens(
          user.toString(), response.data['refresh_token'], _provider);
      _loggedIn = true;
      connectWs();
    }
    return _loggedIn;
  }

  /// Logout an user.
  ///
  Future<Null> logout() async {
    if (provider == 'google') {
      await _googleSignIn.signOut();
    }
    if (providers.contains(provider) && refreshToken != null) {
      await iget('/logout/$provider', refreshToken);
    }
    await saveTokens(null, null, null);
    accessToken = null;
    exp = null;
    provider = null;
    user = null;
    _googleUser = null;
    _loggedIn = false;
  }

  /// Regiser an user.
  ///
  /// @param payload User payload
  /// @returns Api response
  Future<ApiRes> register(payload) async {
    payload['_id'] = '';
    payload['groups'] = '';
    final ApiRes response = await ipost('/signup', payload);
    return response;
  }
}
