import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/api.dart';
import 'package:spotitem/keys.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:location/location.dart';
import 'package:google_maps_webservice/geocoding.dart' as geo;
import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart'
    as places;

/// User class manager
class UsersManager extends BasicService {
  /// Platform channel to get deep linking route
  static MethodChannel platform =
      const MethodChannel('channel:fr.arouillard.spotitem/deeplink');

  /// Location of user
  Map<String, double> location;

  /// Private variables
  static final _location = new Location();
  List<dynamic> _contacts;
  final geo.GoogleMapsGeocoding _geocoding =
      new geo.GoogleMapsGeocoding(geoApiKey);

  @override
  Future<bool> init() async {
    _initLocation();
    return true;
  }

  void _initLocation() {
    if (Services.debug) {
      return;
    }
    _location.onLocationChanged.first.then((data) {
      if (location != null && data == null) {
        return;
      }
      location = data;
    });
  }

  /// Retrieve user location.
  ///
  /// @param force Retrieve user location
  Future<Map<String, double>> getLocation({bool force = false}) async {
    if ((!force && location?.isNotEmpty == true) || Services.debug) {
      return location;
    }
    try {
      return location = await _location.getLocation.timeout(
        new Duration(milliseconds: 250),
        onTimeout: () => null,
      );
    } on PlatformException {
      return location = null;
    }
  }

  /// Retrieve user city location
  Future<String> getCity() async {
    if (location == null) {
      return null;
    }
    final res = await _geocoding.searchByLocation(
      new geo.Location(
        location['latitude'],
        location['longitude'],
      ),
    );
    for (var f in res.results[0].addressComponents) {
      if (f.types.contains('locality')) {
        return f.shortName;
      }
    }
    return null;
  }

  /// Show autocomplete city
  Future<String> autocompleteCity(BuildContext context) async {
    assert(context != null);
    final p = await places.showGooglePlacesAutocomplete(
      context: context,
      apiKey: placeApiKey,
      mode: places.Mode.overlay,
      hint: SpotL.of(context).search,
      language: 'fr',
      components: [new places.Component(places.Component.country, 'fr')],
    );
    return p?.description;
  }

  /// Retrieve location by address
  Future<Map<String, double>> locationByAddress([String address]) async {
    address ??= await getCity();
    final geoRes = await _geocoding.searchByAddress(address);
    final _cityLocation = <String, double>{
      'latitude': geoRes.results[0].geometry.location.lat,
      'longitude': geoRes.results[0].geometry.location.lng
    };
    if (location == null) {
      return location = _cityLocation;
    }
    return _cityLocation;
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
    final a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat) * sin(dlng / 2) * sin(dlng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final km = r * c;
    return km;
  }

  /// Update user information.
  ///
  /// @param user User data
  /// @param password User password to update
  /// @returns Api body response
  Future<ApiRes> edit(Map<String, dynamic> payload, String password) async {
    assert(payload != null);
    if (password != null) {
      payload['password'] = password;
    }
    final res = await iput('/users/edit', payload, Services.auth.accessToken);
    if (res.success) {
      Services.auth.accessToken = res.data['token'];
      await Services.auth.saveTokens(
          res.data['user'],
          Services.auth.refreshToken,
          Services.auth.provider,
          Services.auth.lastEmail);
    }
    return res;
  }

  /// Delete user account
  Future<ApiRes> delete() async {
    final res = await idelete(
        '/users/${Services.auth.user.id}', Services.auth.accessToken);
    if (res.success) {
      await Services.auth.logout(force: true);
    }
    return res;
  }

  /// Get user by id.
  ///
  /// @param userId User id
  /// @returns User class
  Future<dynamic> get(String userId) async {
    assert(userId != null);
    final res = await iget('/users/$userId', Services.auth.accessToken);
    if (res.success) {
      return new User(res.data);
    }
    return null;
  }

  /// Retrieve contacts of user by provider.
  ///
  /// TODO: Maybe make pager to get all contacts
  Future<Null> _retrieveContact() async {
    final provider = Services.auth.provider;
    if (provider == 'google') {
      final res = await http.get(
        'https://people.googleapis.com/v1/people/me/connections'
            '?personFields=names,emailAddresses&pageSize=2000',
        headers: await Services.auth.googleUser.authHeaders,
      );
      if (res.statusCode != 200) {
        print('People API ${res.statusCode} res: ${res.body}');
        return;
      }
      _contacts = JSON.decode(res.body)['connections'];
      _contacts = _contacts
          .where((contact) => contact['emailAddresses'] != null)
          .toList();
      // TODO: convert to custom format
    } else if (provider == 'local') {
      // TODO: Maybe get member of user groups
    }
  }

  /// Get contacts
  Future<List<dynamic>> getContact() async {
    if (_contacts != null) {
      return _contacts;
    } else {
      await _retrieveContact();
      return _contacts;
    }
  }
}
