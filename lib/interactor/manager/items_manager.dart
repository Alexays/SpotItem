import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:spotitems/keys.dart';
import 'package:spotitems/model/item.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class ItemsManager {
  bool get initialized => _initialized;

  bool get loading => _loading;

  List<Item> get items => _items;

  Location _location = new Location();

  Map<String, double> location;

  StreamSubscription<Map<String, double>> _locationSubscription;

  bool _initialized;
  bool _loading = true;
  List<Item> _items = [];

  Future init() async {
    // _locationSubscription =
    //     _location.onLocationChanged.listen((Map<String, double> result) {
    //   if (result != null) location = result;
    // });
    _initialized = true;
  }

  Future close() async {
    if (_locationSubscription != null &&
        await _location.onLocationChanged.isEmpty)
      _locationSubscription.cancel();
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

  Future loadItems() async {
    if (_items.length == 0) {
      print("Get location");
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
      print("Load Items...");
      final Client _client = new Client();
      final itemResponse =
          await _client.get(API_URL + '/items').whenComplete(_client.close);
      if (itemResponse.statusCode == 200) {
        var itemJson = JSON.decode(itemResponse.body);
        _items = new List<Item>.generate(itemJson.length, (int index) {
          return new Item.fromJson(itemJson[index],
              getDist(itemJson[index]['lat'], itemJson[index]['lng']));
        });
      }
      _loading = false;
    }
    return _items;
  }

  Future<List<Item>> getItems([bool force = false]) async {
    if (force) _items.clear();
    return loadItems();
  }
}
