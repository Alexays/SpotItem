import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:spotitems/keys.dart';
import 'package:spotitems/model/item.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ItemsManager {
  static const String keyOauthToken = 'KEY_AUTH_TOKEN';
  final List<String> _categories = [
    'jeux',
    'bebe_jeunesse',
    'fete',
    'garage',
    'objet',
    'cuisine',
    'jardin'
  ];

  List<String> get categories => _categories;

  bool get initialized => _initialized;

  bool get loading => _loading;

  List<Item> get items => _items;

  List<Item> get myItems => _myItems;

  final String _clientSecret = clientSecret;

  final Location _location = new Location();

  StreamSubscription<Map<String, double>> _locationSubscription;

  Map<String, double> location;

  bool _initialized;

  bool _loading = true;

  List<Item> _items = <Item>[];

  List<Item> _myItems = <Item>[];

  Future<bool> init() async {
    try {
      final Map<String, double> tmp = await _location.getLocation
          .timeout(const Duration(milliseconds: 300), onTimeout: () {
        location = null;
      });
      if (tmp != null)
        location = tmp;
      else {
        _locationSubscription = _location.onLocationChanged.listen((result) {
          if (result != null) {
            location = result;
            if (_locationSubscription != null) {
              _locationSubscription.cancel();
              _locationSubscription = null;
            }
          }
        });
      }
    } on PlatformException {
      print("Can't get location");
    }
    return _initialized = true;
  }

  double getDist(double lat2, double lng2) {
    if (location == null) {
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

  Future<dynamic> addItem(
      String name,
      String about,
      String userId,
      String lat,
      String lng,
      List<String> images,
      String location,
      List<String> tracks,
      List<String> groups) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString(keyOauthToken);
    final Client _client = new Client();
    final Response response = await _client.post(
        Uri.encodeFull('$apiUrl/items'),
        headers: getHeaders(token),
        body: {
          'name': name,
          'about': about,
          'owner': userId,
          'holder': userId,
          'lat': lat,
          'lng': lng,
          'images': JSON.encode(images),
          'location': location,
          'tracks': JSON.encode(tracks),
          'groups': JSON.encode(groups),
        }).whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  Future<dynamic> editItem(
      String id,
      String name,
      String about,
      String userId,
      String lat,
      String lng,
      List<String> images,
      String location,
      List<String> tracks,
      List<String> groups) async {
    final Client _client = new Client();
    final Response response = await _client
        .put(Uri.encodeFull('$apiUrl/items/$id'), headers: getHeaders(), body: {
      'name': name,
      'about': about,
      'owner': userId,
      'holder': userId,
      'lat': lat,
      'lng': lng,
      'images': JSON.encode(images),
      'location': location,
      'tracks': JSON.encode(tracks),
      'groups': JSON.encode(groups),
    }).whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  Future<dynamic> deleteItem(String id) async {
    final Client _client = new Client();
    final Response response = await _client
        .delete(Uri.encodeFull('$apiUrl/items/$id'), headers: getHeaders())
        .whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  Future<List<Item>> loadItems(String userId) async {
    if (_items.isEmpty) {
      try {
        final Map<String, double> tmp = await _location.getLocation
            .timeout(const Duration(milliseconds: 300), onTimeout: () {
          location = null;
        });
        if (tmp != null) {
          location = tmp;
        }
        print(location);
      } on PlatformException {
        print("Can't get location");
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString(keyOauthToken);
      final Client _client = new Client();
      final Response response = await _client
          .get('$apiUrl${userId != null ? '/items/auth' : '/items'}',
              headers:
                  getHeaders(userId != null ? token : 'Basic $_clientSecret'))
          .whenComplete(_client.close);
      if (response.statusCode == 200) {
        final dynamic itemJson = JSON.decode(response.body);
        _items = new List<Item>.generate(
            itemJson.length,
            (index) => new Item.fromJson(itemJson[index],
                getDist(itemJson[index]['lat'], itemJson[index]['lng'])));
      }
      _loading = false;
    }
    return _items;
  }

  Future<List<Item>> getItems({bool force: false, String userId: 'no'}) async {
    if (force) {
      _items.clear();
    }
    return loadItems(userId);
  }

  Future<Item> getItem(String itemId) async {
    if (itemId == null) {
      return null;
    }
    final Client _client = new Client();
    final Response response = await _client
        .get('$apiUrl/items/$itemId', headers: getHeaders())
        .whenComplete(_client.close);
    if (response.statusCode == 200) {
      final dynamic itemJson = JSON.decode(response.body);
      return new Item.fromJson(
          itemJson, getDist(itemJson['lat'], itemJson['lng']));
    }
    return null;
  }

  Future<List<Item>> getSelfItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString(keyOauthToken);
    final Client _client = new Client();
    final Response response = await _client
        .get('$apiUrl/items/user', headers: getHeaders(token))
        .whenComplete(_client.close);
    if (response.statusCode == 200) {
      final dynamic itemJson = JSON.decode(response.body);
      _myItems = new List<Item>.generate(
          itemJson.length,
          (index) => new Item.fromJson(itemJson[index],
              getDist(itemJson[index]['lat'], itemJson[index]['lng'])));
    }
    return _myItems;
  }
}
