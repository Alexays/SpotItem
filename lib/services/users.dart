import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';
import 'package:location/location.dart';

/// User class manager
class UsersManager extends BasicService {
  /// Location of user
  Map<String, double> location = {};

  /// Contact of user
  List<dynamic> get contacts => _contacts;

  /// Private variables
  final Location _location = new Location();
  List<dynamic> _contacts;

  @override
  Future<bool> init() async {
    await _location.onLocationChanged.single
        .timeout(const Duration(milliseconds: 200), onTimeout: () {});
    await getLocation();
    await _handleGetContact();
    return true;
  }

  /// Retrieve user location.
  ///
  /// @param force Retrieve user location
  Future<Null> getLocation([bool force = false]) async {
    if (!force && location != null && location.isNotEmpty) {
      return;
    }
    try {
      location = await _location.getLocation
          .timeout(const Duration(milliseconds: 200), onTimeout: () {
        location = null;
      });
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
    final double pi80 = PI / 180;
    final double lat1 = location['latitude'] * pi80;
    final double lng1 = location['longitude'] * pi80;
    final double lat = lat2 * pi80;
    final double lng = lng2 * pi80;

    final double r = 6371.0088; // mean radius of Earth in km
    final double dlat = lat - lat1;
    final double dlng = lng - lng1;
    final double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat) * sin(dlng / 2) * sin(dlng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double km = r * c;
    return km;
  }

  /// Update user information.
  ///
  /// @param user User data
  /// @param password User password to update
  /// @returns Api body response
  Future<dynamic> updateUser(User user, String password) async {
    final dynamic userJson = JSON.decode(user.toString());
    userJson['groups'] = 'groups';
    if (password != null) {
      userJson['password'] = password;
    }
    final ApiRes response =
        await iput('/user/edit', userJson, Services.auth.accessToken);
    if (response.success) {
      Services.auth.user = new User(response.data['user']);
      Services.auth.accessToken = response.data['token'];
      await saveTokens(Services.auth.user.toString(),
          Services.auth.refreshToken, Services.auth.provider);
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
    final ApiRes response =
        await iget('/user/$userId', Services.auth.accessToken);
    if (response.success) {
      return new User(response.data);
    }
    return null;
  }

  /// Get contact of user by provider.
  ///
  /// TO-DO Maybe make pager to get all contacts
  Future<Null> _handleGetContact() async {
    final String provider = Services.auth.provider;
    if (provider == 'google') {
      final http.Response response = await http.get(
        'https://people.googleapis.com/v1/people/me/connections'
            '?personFields=names,emailAddresses&pageSize=2000',
        headers: await Services.auth.googleUser.authHeaders,
      );
      if (response.statusCode != 200) {
        print('People API ${response.statusCode} response: ${response.body}');
        return;
      }
      _contacts = JSON.decode(response.body)['connections'];
      _contacts = _contacts
          .where((contact) => contact['emailAddresses'] != null)
          .toList();
      // TO-DO convert to custom format
    } else if (provider == 'local') {
      // TO-DO Maybe get member of user groups
    }
  }
}
