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

  bool get initialized => _initialized;

  bool get loading => _loading;

  List<Item> get items => _items;

  List<Item> get myItems => _myItems;

  final String _clientSecret = CLIENT_SECRET;

  final Location _location = new Location();

  Map<String, double> location;

  StreamSubscription<Map<String, double>> _locationSubscription;

  bool _initialized;

  bool _loading = true;

  List<Item> _items = <Item>[];

  List<Item> _myItems = <Item>[];

  Future<bool> init() async {
    try {
      Map<String, double> tmp = await _location.getLocation
          .timeout(const Duration(milliseconds: 300), onTimeout: () {
        location = null;
      });
      if (tmp != null)
        location = tmp;
      else {
        _locationSubscription =
            _location.onLocationChanged.listen((Map<String, double> result) {
          if (result != null) location = result;
        });
      }
    } on PlatformException {
      print("Can't get location");
    }
    _initialized = true;
    return _initialized;
  }

  Future<bool> close() async {
    if (_locationSubscription != null &&
        await _location.onLocationChanged.isEmpty) {
      _locationSubscription.cancel();
      return true;
    }
    return false;
  }

  double getDist(double lat2, double lng2) {
    if (location == null) return null;
    double pi80 = PI / 180;
    double lat1 = location['latitude'] * pi80;
    double lng1 = location['longitude'] * pi80;
    double lat = lat2 * pi80;
    double lng = lng2 * pi80;

    double r = 6371.0088; // mean radius of Earth in km
    double dlat = lat - lat1;
    double dlng = lng - lng1;
    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat) * sin(dlng / 2) * sin(dlng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double km = r * c;
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
      List<String> tracks) async {
    final Client _client = new Client();
    final Response response =
        await _client.post(Uri.encodeFull(API_URL + '/addItem'), headers: {
      'Authorization': 'Basic ${_clientSecret}'
    }, body: {
      'name': name,
      'about': about,
      'owner': userId,
      'holder': userId,
      'lat': lat,
      'lng': lng,
      'images': JSON.encode(images),
      'location': location,
      'tracks': JSON.encode(tracks)
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
      List<String> tracks) async {
    final Client _client = new Client();
    final Response response =
        await _client.put(Uri.encodeFull(API_URL + '/items/' + id), headers: {
      'Authorization': 'Basic ${_clientSecret}'
    }, body: {
      'name': name,
      'about': about,
      'owner': userId,
      'holder': userId,
      'lat': lat,
      'lng': lng,
      'images': JSON.encode(images),
      'location': location,
      'tracks': JSON.encode(tracks)
    }).whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  Future<dynamic> deleteItem(String id) async {
    final Client _client = new Client();
    final Response response = await _client
        .delete(Uri.encodeFull(API_URL + '/items/' + id), headers: {
      'Authorization': 'Basic ${_clientSecret}'
    }).whenComplete(_client.close);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  Future<List<Item>> loadItems(String userId) async {
    if (_items.length == 0) {
      try {
        Map<String, double> tmp = await _location.getLocation
            .timeout(const Duration(milliseconds: 300), onTimeout: () {
          location = null;
        });
        if (tmp != null) location = tmp;
        print(location);
      } on PlatformException {
        print("Can't get location");
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString(keyOauthToken);
      final Client _client = new Client();
      Response response = await _client
          .get(API_URL + (userId != null ? '/items/auth' : '/items'), headers: {
        'Authorization': userId != null ? token : 'Basic ${_clientSecret}'
      }).whenComplete(_client.close);
      if (response.statusCode == 200) {
        final dynamic itemJson = JSON.decode(response.body);
        _items = new List<Item>.generate(itemJson.length, (int index) {
          return new Item.fromJson(itemJson[index],
              getDist(itemJson[index]['lat'], itemJson[index]['lng']));
        });
      }
      _loading = false;
    }
    return _items;
  }

  Future<List<Item>> getItems(
      [bool force = false, String userId = 'no']) async {
    if (force) _items.clear();
    return loadItems(userId);
  }

  Future<Item> getItem(String itemId) async {
    if (itemId == null) return null;
    final Client _client = new Client();
    final Response response = await _client.get(API_URL + '/items/' + itemId,
        headers: {
          'Authorization': 'Basic ${_clientSecret}'
        }).whenComplete(_client.close);
    if (response.statusCode == 200) {
      final dynamic itemJson = JSON.decode(response.body);
      return new Item.fromJson(
          itemJson, getDist(itemJson['lat'], itemJson['lng']));
    }
    return null;
  }

  Future<List<Item>> getSelfItems(String userId) async {
    if (userId == null) return null;
    final Client _client = new Client();
    final Response response = await _client.get(API_URL + '/userItem/' + userId,
        headers: {
          'Authorization': 'Basic ${_clientSecret}'
        }).whenComplete(_client.close);
    if (response.statusCode == 200) {
      final dynamic itemJson = JSON.decode(response.body);
      _myItems = new List<Item>.generate(itemJson.length, (int index) {
        return new Item.fromJson(itemJson[index],
            getDist(itemJson[index]['lat'], itemJson[index]['lng']));
      });
    }
    return _myItems;
  }
}
