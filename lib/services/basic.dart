import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/services/services.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasicService {
  /// Check if service is initialized
  bool get initialized => _initialized;

  /// Define private variables
  bool _initialized;

  /// Default init function of services
  Future<bool> init() async => true;

  /// Http get method.
  ///
  /// @param url Get url
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<Response> iget(String url, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(token);
    final Client _client = new Client();
    final Response response = await _client
        .get('$apiUrl$url', headers: getHeaders(verifiedToken))
        .whenComplete(_client.close);
    return response;
  }

  /// Http post method.
  ///
  /// @param url Post url
  /// @param payload The payload
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<Response> ipost(String url, payload, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(token);
    final Client _client = new Client();
    final Response response = await _client
        .post('$apiUrl$url', headers: getHeaders(verifiedToken), body: payload)
        .whenComplete(_client.close);
    return response;
  }

  /// Http put method.
  ///
  /// @param url Put url
  /// @param payload The payload
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<Response> iput(String url, payload, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(token);
    final Client _client = new Client();
    final Response response = await _client
        .put('$apiUrl$url', headers: getHeaders(verifiedToken), body: payload)
        .whenComplete(_client.close);
    return response;
  }

  /// Http delete method.
  ///
  /// @param url Delete url
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<Response> idelete(String url, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(token);
    final Client _client = new Client();
    final Response response = await _client
        .delete('$apiUrl$url', headers: getHeaders(verifiedToken))
        .whenComplete(_client.close);
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
    final dynamic data = JSON.decode(res);
    if (data['type'] == 'NOTIFICATION') {
      print(data['data']);
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
