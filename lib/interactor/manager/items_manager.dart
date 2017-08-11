import 'dart:async';
import 'dart:convert';

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

  bool _initialized;
  bool _loading = true;
  List<Item> _items = [];

  Future init() async {
    _items.clear();
    _initialized = true;
  }

  Future loadItems() async {
    if (_items.length == 0) {
      print("Get location");
      try {
        location = await _location.getLocation;
      } on PlatformException {
        location = null;
      }
      print("Load Items...");
      final Client _client = new Client();
      final itemResponse =
          await _client.get(API_URL + '/items').whenComplete(_client.close);
      if (itemResponse.statusCode == 200) {
        var itemJson = JSON.decode(itemResponse.body);
        _items = new List<Item>.generate(itemJson.length, (int index) {
          return new Item.fromJson(itemJson[index]);
        });
        _loading = false;
      } else {
        _loading = false;
      }
    }
    return _items;
  }

  Future<List<Item>> getItems([bool force = false]) async {
    if (force) _items.clear();
    return await loadItems();
  }
}
