import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/services/services.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasicService {
  bool get initialized => _initialized;

  bool _initialized;

  Future<bool> init() async => true;

  Future<Response> iget(String url, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(url, token);
    final Client _client = new Client();
    final Response response = await _client
        .get('$apiUrl$url', headers: getHeaders(verifiedToken))
        .whenComplete(_client.close);
    return response;
  }

  Future<Response> ipost(String url, payload, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(url, token);
    final Client _client = new Client();
    final Response response = await _client
        .post('$apiUrl$url', headers: getHeaders(verifiedToken), body: payload)
        .whenComplete(_client.close);
    return response;
  }

  Future<Response> iput(String url, payload, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(url, token);
    final Client _client = new Client();
    final Response response = await _client
        .put('$apiUrl$url', headers: getHeaders(verifiedToken), body: payload)
        .whenComplete(_client.close);
    return response;
  }

  Future<Response> idelete(String url, [String token]) async {
    final String verifiedToken = await Services.auth.verifyToken(url, token);
    final Client _client = new Client();
    final Response response = await _client
        .delete('$apiUrl$url', headers: getHeaders(verifiedToken))
        .whenComplete(_client.close);
    return response;
  }

  Future<Null> saveTokens(
      String user, String oauthToken, String provider) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance()
      ..setString(keyUser, user)
      ..setString(keyOauthToken, oauthToken)
      ..setString(keyProvider, provider);
    await prefs.commit();
    Services.auth.refreshToken = oauthToken;
  }

  void handleWsData(res) {
    final dynamic data = JSON.decode(res);
    if (data['type'] == 'NOTIFICATION') {
      print(data['data']);
    }
  }

  void connectWs() {
    final channel = new IOWebSocketChannel.connect('ws://217.182.65.67:1337');
    channel.sink.add(
        JSON.encode({'type': 'CONNECTION', 'userId': Services.auth.user.id}));
    channel.stream.listen(handleWsData);
  }
}