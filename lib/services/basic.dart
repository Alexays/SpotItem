import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotitem/keys.dart';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final client = new http.Client();
    final verifiedToken = await Services.auth.verifyToken(client, token);
    final response =
        await client.get(Uri.encodeFull('$apiUrl$url'), headers: getHeaders(verifiedToken)).whenComplete(client.close);
    var apiRes;
    try {
      apiRes = new ApiRes(JSON.decode(response.body), response.statusCode);
    } catch (err) {
      apiRes = new ApiRes.classic();
    }
    return apiRes;
  }

  /// Http post method.
  ///
  /// @param url Post url
  /// @param payload The payload
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<ApiRes> ipost(String url, Map<String, dynamic> payload, [String token]) async {
    if (Services.origin == Origin.mock) {
      return Services.mock;
    }
    final client = new http.Client();
    final verifiedToken = await Services.auth.verifyToken(client, token);
    final response = await client
        .post(Uri.encodeFull('$apiUrl$url'), headers: getHeaders(verifiedToken), body: payload)
        .whenComplete(client.close);
    var apiRes;
    try {
      apiRes = new ApiRes(JSON.decode(response.body), response.statusCode);
    } catch (err) {
      apiRes = new ApiRes.classic();
    }
    return apiRes;
  }

  /// Http put method.
  ///
  /// @param url Put url
  /// @param payload The payload
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<ApiRes> iput(String url, Map<String, dynamic> payload, [String token]) async {
    if (Services.origin == Origin.mock) {
      return Services.mock;
    }
    final client = new http.Client();
    final verifiedToken = await Services.auth.verifyToken(client, token);
    final response = await client
        .put(Uri.encodeFull('$apiUrl$url'), headers: getHeaders(verifiedToken), body: payload)
        .whenComplete(client.close);
    var apiRes;
    try {
      apiRes = new ApiRes(JSON.decode(response.body), response.statusCode);
    } catch (err) {
      apiRes = new ApiRes.classic();
    }
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
    final client = new http.Client();
    final verifiedToken = await Services.auth.verifyToken(client, token);
    final response = await client
        .delete(Uri.encodeFull('$apiUrl$url'), headers: getHeaders(verifiedToken))
        .whenComplete(client.close);
    var apiRes;
    try {
      apiRes = new ApiRes(JSON.decode(response.body), response.statusCode);
    } catch (err) {
      apiRes = new ApiRes.classic();
    }
    return apiRes;
  }

  /// Save user, refresh_token, provider to storage.
  ///
  /// @param user User data stingified
  /// @param oauthToken The refresh_token
  /// @param provider Login provider
  Future<Null> saveTokens(String user, String oauthToken, String provider) async {
    final prefs = await SharedPreferences.getInstance()
      ..setString(keyUser, user)
      ..setString(keyOauthToken, oauthToken)
      ..setString(keyProvider, provider);
    await prefs.commit();
    Services.auth.provider = provider;
    Services.auth.refreshToken = oauthToken;
  }
}
