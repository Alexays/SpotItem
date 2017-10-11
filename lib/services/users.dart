import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';

/// User class manager
class UsersManager extends BasicService {
  /// Location of user
  Map<String, double> location = {};

  /// Contact of user
  List<dynamic> get contacts => _contacts;

  /// Private variables
  static const MethodChannel _channel = const MethodChannel('lyokone/location');
  static const EventChannel _stream = const EventChannel('lyokone/locationstream');
  Stream<Map<String, double>> _onLocationChanged;
  List<dynamic> _contacts;

  @override
  Future<bool> init() async {
    if (Services.origin == Origin.prod) {
      _onLocationChanged ??= _stream.receiveBroadcastStream();
    }
    await _handleGetContact();
    return true;
  }

  /// Retrieve user location.
  ///
  /// @param force Retrieve user location
  Future<Null> getLocation({bool force = false}) async {
    if ((!force && location != null && location.isNotEmpty) || Services.origin == Origin.mock) {
      return;
    }
    try {
      location =
          await _channel.invokeMethod('getLocation').timeout(const Duration(milliseconds: 200), onTimeout: () {});
    } on PlatformException {
      location = null;
    }
    print(location);
  }

  /// Get distance between two points.
  ///
  /// @param lat2 Second lattitude point
  /// @param lng2 Second Longitude point
  /// @returns Distance in km
  double getDist(double lat2, double lng2) {
    if (location == null || location.isEmpty) {
      return -1.0;
    }
    final pi80 = PI / 180;
    final lat1 = location['latitude'] * pi80;
    final lng1 = location['longitude'] * pi80;
    final lat = lat2 * pi80;
    final lng = lng2 * pi80;

    final r = 6371.0088; // mean radius of Earth in km
    final dlat = lat - lat1;
    final dlng = lng - lng1;
    final a = sin(dlat / 2) * sin(dlat / 2) + cos(lat1) * cos(lat) * sin(dlng / 2) * sin(dlng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final km = r * c;
    return km;
  }

  /// Update user information.
  ///
  /// @param user User data
  /// @param password User password to update
  /// @returns Api body response
  Future<dynamic> updateUser(User user, String password) async {
    final Map<String, dynamic> userJson = JSON.decode(user.toString())..remove('groups');
    if (password != null) {
      userJson['password'] = password;
    }
    final response = await iput('/user/edit', userJson, Services.auth.accessToken);
    if (response.success) {
      Services.auth.user = new User(response.data['user']);
      Services.auth.accessToken = response.data['token'];
      await saveTokens(Services.auth.user.toString(), Services.auth.refreshToken, Services.auth.provider);
    }
    return response;
  }

  /// Get user by id.
  ///
  /// @param userId User id
  /// @returns User class
  Future<dynamic> getUser(String userId) async {
    if (userId == null) {
      return null;
    }
    final response = await iget('/user/$userId', Services.auth.accessToken);
    if (response.success) {
      return new User(response.data);
    }
    return null;
  }

  /// Get contact of user by provider.
  ///
  /// TO-DO Maybe make pager to get all contacts
  Future<Null> _handleGetContact() async {
    final provider = Services.auth.provider;
    if (provider == 'google') {
      final response = await http.get(
        'https://people.googleapis.com/v1/people/me/connections'
            '?personFields=names,emailAddresses&pageSize=2000',
        headers: await Services.auth.googleUser.authHeaders,
      );
      if (response.statusCode != 200) {
        print('People API ${response.statusCode} response: ${response.body}');
        return;
      }
      _contacts = JSON.decode(response.body)['connections'];
      _contacts = _contacts.where((contact) => contact['emailAddresses'] != null).toList();
      // TO-DO convert to custom format
    } else if (provider == 'local') {
      // TO-DO Maybe get member of user groups
    }
  }
}
