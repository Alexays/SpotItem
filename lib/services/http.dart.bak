import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/services/services.dart';

/// ContentType of HTTP headers
enum contentType {
  /// Image
  image,

  /// JSON
  json
}

class _ProxyClient implements Client {
  factory _ProxyClient({
    @required Client client,
    String baseUrl,
  }) {
    if (baseUrl == null || baseUrl == '') {
      return client;
    }
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    return new _ProxyClient._(client: client, baseUrl: baseUrl);
  }

  _ProxyClient._({this.client, this.baseUrl});

  final Client client;

  final String baseUrl;

  static final Map<contentType, String> _contentType = <contentType, String>{
    contentType.image: 'image/jpg',
    contentType.json: 'application/json',
  };

  /// Default headers
  static final Map<String, String> _defaultHeaders = <String, String>{
    'Authorization': Services.auth.accessToken, // default Token
    'Spotkey': 'Basic $clientSecret-$version',
    'Accept': _contentType[contentType.json], // default Accept
  };

  String _mergeUrl(String url) => '$baseUrl$url';

  Map<String, String> _mergeHeaders(Map<String, String> headers) {
    return new Map.from(_defaultHeaders)..addAll(headers);
  }

  @override
  Future<Response> head(dynamic url, {Map<String, String> headers}) =>
      client.head(_mergeUrl(url), headers: _mergeHeaders(headers));

  @override
  Future<Response> get(dynamic url, {Map<String, String> headers}) async {
    final _headers = _mergeHeaders(headers);
    final verifiedToken = await Services.auth.verifyToken(
      client,
      _headers['Authorization'],
    );
    _headers['Authorization'] = verifiedToken;
    return client.get(_mergeUrl(url), headers: _headers);
  }

  @override
  Future<Response> post(dynamic url,
          {Map<String, String> headers, dynamic body, Encoding encoding}) =>
      client.post(_mergeUrl(url),
          headers: _mergeHeaders(headers), body: body, encoding: encoding);

  @override
  Future<Response> put(dynamic url,
          {Map<String, String> headers, dynamic body, Encoding encoding}) =>
      client.put(_mergeUrl(url),
          headers: _mergeHeaders(headers), body: body, encoding: encoding);

  @override
  Future<Response> patch(dynamic url,
          {Map<String, String> headers, dynamic body, Encoding encoding}) =>
      client.patch(_mergeUrl(url),
          headers: _mergeHeaders(headers), body: body, encoding: encoding);

  @override
  Future<Response> delete(dynamic url, {Map<String, String> headers}) =>
      client.delete(_mergeUrl(url), headers: _mergeHeaders(headers));

  @override
  Future<String> read(dynamic url, {Map<String, String> headers}) =>
      client.read(_mergeUrl(url), headers: _mergeHeaders(headers));

  @override
  Future<Uint8List> readBytes(dynamic url, {Map<String, String> headers}) =>
      client.readBytes(_mergeUrl(url), headers: _mergeHeaders(headers));

  @override
  Future<StreamedResponse> send(BaseRequest request) => client.send(request);

  @override
  void close() => client.close();
}

/// Create a new http Client
Client createApiClient() {
  final client = createHttpClient();
  return new _ProxyClient(client: client, baseUrl: apiUrl);
}
