import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotitem/keys.dart';
import 'package:spotitem/services/services.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotitem/utils.dart';

/// Basic Service
class BasicService {
  /// Check if service is initialized
  bool get initialized => _initialized;

  /// Private variables
  bool _initialized;

  /// Default init function of services
  Future<bool> init() async => true;

  /// Http get method.
  ///
  /// @param url Get url
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<http.Response> iget(String url, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(token);
    final http.Response response = await http.get(Uri.encodeFull('$apiUrl$url'),
        headers: getHeaders(verifiedToken));
    if (response.statusCode != 200) {
      print(response.body);
    }
    return response;
  }

  /// Http post method.
  ///
  /// @param url Post url
  /// @param payload The payload
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<http.Response> ipost(String url, payload, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(token);
    final http.Response response = await http.post(
        Uri.encodeFull('$apiUrl$url'),
        headers: getHeaders(verifiedToken),
        body: payload);
    if (response.statusCode != 200) {
      print(response.body);
    }
    return response;
  }

  /// Http put method.
  ///
  /// @param url Put url
  /// @param payload The payload
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<http.Response> iput(String url, payload, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(token);
    final http.Response response = await http.put(Uri.encodeFull('$apiUrl$url'),
        headers: getHeaders(verifiedToken), body: payload);
    if (response.statusCode != 200) {
      print(response.body);
    }
    return response;
  }

  /// Http delete method.
  ///
  /// @param url Delete url
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<http.Response> idelete(String url, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(token);
    final http.Response response = await http.delete(
        Uri.encodeFull('$apiUrl$url'),
        headers: getHeaders(verifiedToken));
    if (response.statusCode != 200) {
      print(response.body);
    }
    return response;
  }

  /// Save user, refresh_token, provider to storage.
  ///
  /// @param user User data stingified
  /// @param oauthToken The refresh_token
  /// @param provider Login provider
  Future<Null> saveTokens(
      String user, String oauthToken, String provider) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance()
      ..setString(keyUser, user)
      ..setString(keyOauthToken, oauthToken)
      ..setString(keyProvider, provider);
    await prefs.commit();
    Services.auth.provider = provider;
    Services.auth.refreshToken = oauthToken;
  }

  /// Handle web socket push.
  ///
  /// @param res Api ws data
  void handleWsData(res) {
    final dynamic decoded = JSON.decode(res);
    if (decoded['type'] == 'NOTIFICATION') {
      showSnackBar(Services.context, decoded['data']);
    }
  }

  /// Connect to web socket
  ///
  void connectWs() {
    final channel = new IOWebSocketChannel.connect('ws://217.182.65.67:1337');
    channel.sink.add(
        JSON.encode({'type': 'CONNECTION', 'userId': Services.auth.user.id}));
    channel.stream.listen(handleWsData);
  }
}
