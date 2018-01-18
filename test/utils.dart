import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http;
import 'package:flutter/services.dart' show createHttpClient;
import 'package:flutter_test/flutter_test.dart';

/// Provide a http mock client
dynamic mockClient(Map<String, dynamic> mockData) => createHttpClient = () =>
    new http.MockClient((request) {
      if (request.url.toString().contains(
              new RegExp(r'([a-z\-_0-9\/\:\.]*\.(jpg|jpeg|png|gif))')) ||
          request.headers['Content-Type'] == 'image/jpg') {
        return new Future<http.Response>.value(
            new http.Response.bytes(_kTransparentImage, 200, request: request));
      }
      return new Future<http.Response>.value(
        new http.Response(JSON.encode(mockData), 200, request: request),
      );
    });

const List<int> _kTransparentImage = const <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
];
