import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotitem/keys.dart';
import 'package:spotitem/models/api.dart';
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
  Future<ApiRes> iget(String url, [String token]) async {
    if (Services.origin == Origin.mock) {
      return Services.mock;
    }
    final verifiedToken = await Services.auth.verifyToken(token);
    final response = await http.get(Uri.encodeFull('$apiUrl$url'),
        headers: getHeaders(verifiedToken));
    final apiRes = new ApiRes(JSON.decode(response.body), response.statusCode);
    return apiRes;
  }

  /// Http post method.
  ///
  /// @param url Post url
  /// @param payload The payload
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<ApiRes> ipost(String url, Map<String, dynamic> payload,
      [String token]) async {
    if (Services.origin == Origin.mock) {
      return Services.mock;
    }
    final verifiedToken = await Services.auth.verifyToken(token);
    final response = await http.post(Uri.encodeFull('$apiUrl$url'),
        headers: getHeaders(verifiedToken), body: payload);
    final apiRes = new ApiRes(JSON.decode(response.body), response.statusCode);
    return apiRes;
  }

  /// Http put method.
  ///
  /// @param url Put url
  /// @param payload The payload
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<ApiRes> iput(String url, Map<String, dynamic> payload,
      [String token]) async {
    if (Services.origin == Origin.mock) {
      return Services.mock;
    }
    final verifiedToken = await Services.auth.verifyToken(token);
    final response = await http.put(Uri.encodeFull('$apiUrl$url'),
        headers: getHeaders(verifiedToken), body: payload);
    final apiRes = new ApiRes(JSON.decode(response.body), response.statusCode);
    return apiRes;
  }

  /// Http delete method.
  ///
  /// @param url Delete url
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<ApiRes> idelete(String url, [String token]) async {
    if (Services.origin == Origin.mock) {
      return Services.mock;
    }
    final verifiedToken = await Services.auth.verifyToken(token);
    final response = await http.delete(Uri.encodeFull('$apiUrl$url'),
        headers: getHeaders(verifiedToken));
    final apiRes = new ApiRes(JSON.decode(response.body), response.statusCode);
    return apiRes;
  }

  /// Save user, refresh_token, provider to storage.
  ///
  /// @param user User data stingified
  /// @param oauthToken The refresh_token
  /// @param provider Login provider
  Future<Null> saveTokens(
      String user, String oauthToken, String provider) async {
    final prefs = await SharedPreferences.getInstance()
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
  void handleWsData(String res) {
    final decoded = JSON.decode(res);
    if (decoded['type'] == 'NOTIFICATION') {
      showSnackBar(Services.context, decoded['data']);
    }
  }

  /// Connect to web socket
  ///
  void connectWs() {
    if (Services.origin == Origin.mock) {
      return;
    }
    final channel = new IOWebSocketChannel.connect('ws://217.182.65.67:1337');
    channel.sink.add(
        JSON.encode({'type': 'CONNECTION', 'userId': Services.auth.user.id}));
    channel.stream.listen(handleWsData);
  }
}
