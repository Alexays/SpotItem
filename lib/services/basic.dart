import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotitem/keys.dart';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Basic Service
class BasicService {
  /// Check if service is initialized
  bool get initialized => _initialized;

  /// Private variables
  bool _initialized;

  /// Default init function of services
  Future<bool> init() async => true;

  void _handleError(error) {
    showDialog<Null>(
      context: Services.context,
      barrierDismissible: false,
      child: new AlertDialog(
        title: new Text(SpotL.of(Services.context).error),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              const Text('Sorry, we\'re in maintenance !'),
            ],
          ),
        ),
      ),
    );
  }

  /// Http get method.
  ///
  /// @param url Get url
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<ApiRes> iget(String url, [String token]) async {
    assert(url != null);
    if (Services.origin == Origin.mock) {
      return Services.mock;
    }
    final client = new http.Client();
    final verifiedToken = await Services.auth.verifyToken(client, token);
    final response = await client
        .get(Uri.encodeFull('$apiUrl$url'), headers: getHeaders(verifiedToken))
        .whenComplete(client.close)
        .catchError(_handleError);
    try {
      return new ApiRes(JSON.decode(response.body), response.statusCode);
    } catch (err) {
      return new ApiRes.classic();
    }
  }

  /// Http post method.
  ///
  /// @param url Post url
  /// @param payload The payload
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<ApiRes> ipost(String url, Map<String, dynamic> payload,
      [String token]) async {
    assert(url != null && payload != null);
    if (Services.origin == Origin.mock) {
      return Services.mock;
    }
    final client = new http.Client();
    final verifiedToken = await Services.auth.verifyToken(client, token);
    final response = await client
        .post(Uri.encodeFull('$apiUrl$url'),
            headers: getHeaders(verifiedToken), body: JSON.encode(payload))
        .whenComplete(client.close)
        .catchError(_handleError);
    try {
      return new ApiRes(JSON.decode(response.body), response.statusCode);
    } catch (err) {
      return new ApiRes.classic();
    }
  }

  /// Http put method.
  ///
  /// @param url Put url
  /// @param payload The payload
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<ApiRes> iput(String url, Map<String, dynamic> payload,
      [String token]) async {
    assert(url != null && payload != null);
    if (Services.origin == Origin.mock) {
      return Services.mock;
    }
    final client = new http.Client();
    final verifiedToken = await Services.auth.verifyToken(client, token);
    final response = await client
        .put(Uri.encodeFull('$apiUrl$url'),
            headers: getHeaders(verifiedToken), body: JSON.encode(payload))
        .whenComplete(client.close)
        .catchError(_handleError);
    try {
      return new ApiRes(JSON.decode(response.body), response.statusCode);
    } catch (err) {
      return new ApiRes.classic();
    }
  }

  /// Http delete method.
  ///
  /// @param url Delete url
  /// @param token Token to use to authentificate
  /// @returns Api response
  Future<ApiRes> idelete(String url, [String token]) async {
    assert(url != null);
    if (Services.origin == Origin.mock) {
      return Services.mock;
    }
    final client = new http.Client();
    final verifiedToken = await Services.auth.verifyToken(client, token);
    final response = await client
        .delete(Uri.encodeFull('$apiUrl$url'),
            headers: getHeaders(verifiedToken))
        .whenComplete(client.close)
        .catchError(_handleError);
    try {
      return new ApiRes(JSON.decode(response.body), response.statusCode);
    } catch (err) {
      return new ApiRes.classic();
    }
  }

  /// Communicate with websocket server
  ///
  /// @param type Request type
  /// @param data Payload
  Future<Map<String, dynamic>> getWsHeader(String type) async {
    assert(type != null);
    final client = new http.Client();
    if (Services.auth.loggedIn) {
      final verifiedToken = await Services.auth
          .verifyToken(client, Services.auth.accessToken)
          .whenComplete(client.close);
      return {
        'type': type,
        'id': Services.auth.user.id,
        'version': '2',
        'auth': {'headers': getHeaders(verifiedToken)},
      };
    }
    if (Services.auth.ws == null) {
      await Services.auth.connectWs();
    }
    return null;
  }
}
