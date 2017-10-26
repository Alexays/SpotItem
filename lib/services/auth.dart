import 'dart:async';
import 'dart:convert';
import 'package:spotitem/keys.dart';
import 'package:http/http.dart';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/basic.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotitem/services/services.dart';
import 'package:web_socket_channel/io.dart';
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
  String lastEmail;

  /// Google user data
  GoogleSignInAccount get googleUser => _googleUser;

  /// Ws channel
  IOWebSocketChannel ws;

  /// Private variables
  bool _loggedIn = false;
  GoogleSignInAccount _googleUser;
  final dynamic _wsCallback = {};

  @override
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    final _userData = prefs.getString(keyUser) ?? '{}';
    final _provider = prefs.getString(keyProvider);
    final _refreshToken = prefs.getString(keyOauthToken);
    lastEmail = prefs.getString(keyLastEmail) ?? '';
    try {
      final _user = new User(JSON.decode(_userData));
      if (!_user.isValid() || _refreshToken == null || !providers.contains(_provider)) {
        await logout();
        return !(_loggedIn = false);
      }
      user = _user;
      refreshToken = _refreshToken;
      provider = _provider;
      _loggedIn = true;
      await connectWs();
    } on Exception {
      return _loggedIn = false;
    }
    return _loggedIn;
  }

  /// Check if access_token is expired and regenerate it if expired.
  ///
  /// @param token Token will be user to access API
  /// @returns Valid token
  Future<String> verifyToken(Client client, String token) async {
    if ((token == null && accessToken != null) || token != accessToken) {
      return token;
    }
    if ((loggedIn && (exp == null || new DateTime.now().isAfter(exp))) && !await getAccessToken(client)) {
      await Navigator.of(Services.context).pushNamedAndRemoveUntil('/', (route) => false);
      return null;
    }
    return accessToken;
  }

  /// Regenerate access_token.
  ///
  Future<bool> getAccessToken(Client client) async {
    await _checkProvider();
    var apiRes;
    try {
      final response = await client.get('$apiUrl/check/$provider', headers: getHeaders(refreshToken));
      apiRes = new ApiRes(JSON.decode(response.body), response.statusCode);
    } catch (err) {
      apiRes = new ApiRes.classic();
    }
    if (apiRes.success) {
      accessToken = apiRes.data['access_token'];
      exp = new DateTime.fromMillisecondsSinceEpoch((apiRes.data['exp'] * 1000) - 30);
      return true;
    }
    await logout();
    return false;
  }

  Future<Null> _checkProvider() async {
    switch (provider) {
      case 'google':
        await handleGoogleSignIn(signIn: false);
    }
  }

  /// Pre login with google account.
  ///
  /// @param signIn Login/re-login
  /// @returns Logged or not
  /// TO-DO don't send user data, just get it on API with access_token
  Future<bool> handleGoogleSignIn({bool signIn = true}) async {
    try {
      _googleUser = signIn ? await _googleSignIn.signIn() : await _googleSignIn.signInSilently();
      if (_googleUser == null) {
        await logout();
        return false;
      }
      if (signIn) {
        final authId = await _googleUser.authentication;
        return await login({
          'token': authId.accessToken,
          'email': _googleUser.email,
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
  Future<bool> login(Map<String, dynamic> _payload, String _provider) async {
    _loggedIn = false;
    final response = await ipost('/login/$_provider', _payload);
    if (response.success) {
      if (_payload['email'] != null) {
        await SharedPreferences.getInstance()
          ..setString(keyLastEmail, _payload['email']);
        lastEmail = _payload['email'];
      }
      user = new User(response.data['user']);
      accessToken = response.data['access_token'];
      exp = new DateTime.fromMillisecondsSinceEpoch(response.data['exp'] * 1000);
      await saveTokens(user.toString(), response.data['refresh_token'], _provider);
      _loggedIn = true;
      await connectWs();
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
    await SharedPreferences.getInstance()
      ..clear();
    refreshToken = null;
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
  Future<ApiRes> register(Map<String, dynamic> payload) async {
    payload..remove('_id')..remove('groups');
    final response = await ipost('/signup', payload);
    return response;
  }

  /// Handle web socket push.
  ///
  /// @param res Api ws data
  Future<Null> handleWsData(String res) async {
    final decoded = JSON.decode(res);
    if (decoded['type'] == 'ping') {
      final headers = await getWsHeader('ping');
      if (headers == null) {
        return;
      }
      Services.auth.ws.sink.add(JSON.encode(headers));
    }
    if (decoded['type'] != 'pub') {
      return;
    }
    final payload = decoded['message'];
    if (_wsCallback[payload['type']] != null) {
      _wsCallback[payload['type']](payload);
    }
  }

  /// Add a listener to WS.
  ///
  /// @param handler Name of handler
  /// @param callback Function callback
  void addCallback(String handler, void callback(Map<String, dynamic> res)) {
    _wsCallback[handler] = callback;
  }

  /// Add a listener to WS.
  ///
  /// @param handler Name of handler
  /// @param callback Function callback
  void delCallback(String handler) {
    _wsCallback[handler] = null;
  }

  /// Connect to web socket
  ///
  Future<Null> connectWs() async {
    if (Services.origin == Origin.mock) {
      return;
    }
    Services.auth.ws = new IOWebSocketChannel.connect('ws://$baseHost');
    Services.auth.ws.stream.listen(handleWsData);
    final header = await getWsHeader('hello');
    if (header != null) {
      return;
    }
    Services.auth.ws.sink.add(JSON.encode(header));
  }
}
