import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:spotitem/models/item.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';

class ItemsManager extends BasicService {
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

  List<Item> get items => _items;

  List<Item> get myItems => _myItems;

  final ValueNotifier<List<String>> tracks =
      new ValueNotifier<List<String>>([]);

  final Location _location = new Location();

  StreamSubscription<Map<String, double>> _locationSubscription;

  Map<String, double> location;

  List<Item> _items = <Item>[];

  List<Item> _myItems = <Item>[];

  @override
  Future<bool> init() async {
    bool debug = false;
    assert(() {
      debug = true;
      return true;
    });
    if (!debug) {
      try {
        Map<String, double> tmp;
        _location.getLocation.then((data) {
          tmp = data;
        });
        if (tmp != null) {
          location = tmp;
        } else if (location == null) {
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
    }
    return true;
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
    final Response response = await ipost(
        '/items',
        {
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
        },
        Services.auth.accessToken);
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
    final Response response = await iput(
        '/items/$id',
        {
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
        },
        Services.auth.accessToken);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  Future<dynamic> deleteItem(String id) async {
    final Response response =
        await idelete('/items/$id', Services.auth.accessToken);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  Future<List<Item>> loadItems() async {
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
      final Response response = await iget(
          '${Services.auth.loggedIn != null ? '/items/auth' : '/items'}',
          Services.auth.loggedIn ? Services.auth.accessToken : null);
      if (response.statusCode == 200) {
        final dynamic itemJson = JSON.decode(response.body);
        _items = new List<Item>.generate(
            itemJson.length,
            (index) => new Item(itemJson[index],
                getDist(itemJson[index]['lat'], itemJson[index]['lng'])));
      }
    }
    return _items;
  }

  Future<List<Item>> getItems({bool force: false}) async {
    if (force) {
      _items.clear();
    }
    return loadItems();
  }

  Future<Item> getItem(String itemId) async {
    if (itemId == null) {
      return null;
    }
    final Response response = await iget('/items/$itemId');
    if (response.statusCode == 200) {
      final dynamic itemJson = JSON.decode(response.body);
      return new Item(itemJson, getDist(itemJson['lat'], itemJson['lng']));
    }
    return null;
  }

  Future<List<Item>> getSelfItems() async {
    final Response response =
        await iget('/items/user', Services.auth.accessToken);
    if (response.statusCode == 200) {
      final dynamic itemJson = JSON.decode(response.body);
      _myItems = new List<Item>.generate(
          itemJson.length,
          (index) => new Item(itemJson[index],
              getDist(itemJson[index]['lat'], itemJson[index]['lng'])));
    }
    return _myItems;
  }
}
