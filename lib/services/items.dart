import 'dart:async';
import 'dart:convert';

import 'package:spotitem/models/item.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';

class ItemsManager extends BasicService {
  /// Get items categories
  List<String> get categories => _categories;

  /// Get items
  List<Item> get items => _items;

  /// Get user items
  List<Item> get myItems => _myItems;

  /// ValueNotifier of tracks filter
  final ValueNotifier<List<String>> tracks =
      new ValueNotifier<List<String>>([]);

  /// Define private variables
  List<Item> _items = <Item>[];
  List<Item> _myItems = <Item>[];
  final List<String> _categories = [
    'jeux',
    'bebe_jeunesse',
    'fete',
    'garage',
    'objet',
    'cuisine',
    'jardin'
  ];

  /// Add item.
  ///
  /// @param payload Item payload
  /// @returns Api body response
  Future<dynamic> addItem(payload) async {
    final Response response =
        await ipost('/items', payload, Services.auth.accessToken);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  /// Edit item by id.
  ///
  /// @param payload Item payload
  /// @returns Api body response
  Future<dynamic> editItem(payload) async {
    final Response response = await iput(
        '/items/${payload['id']}', payload, Services.auth.accessToken);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  /// Delete item by id.
  ///
  /// @param id Item Id
  /// @returns Api body response
  Future<dynamic> deleteItem(String id) async {
    final Response response =
        await idelete('/items/$id', Services.auth.accessToken);
    final dynamic bodyJson = JSON.decode(response.body);
    return bodyJson;
  }

  /// Load items filter by token.
  ///
  /// @returns Items list
  Future<List<Item>> loadItems() async {
    if (_items.isEmpty) {
      await Services.users.getLocation();
      final Response response = await iget(
          '${Services.auth.loggedIn != null ? '/items/auth' : '/items'}',
          Services.auth.loggedIn ? Services.auth.accessToken : null);
      if (response.statusCode == 200) {
        final dynamic itemJson = JSON.decode(response.body);
        _items = new List<Item>.generate(
            itemJson.length,
            (index) => new Item(
                itemJson[index],
                Services.users
                    .getDist(itemJson[index]['lat'], itemJson[index]['lng'])));
      }
    }
    return _items;
  }

  /// Get loaded items or reload it.
  ///
  /// @param force Force reload of items
  /// @returns Items list
  Future<List<Item>> getItems({bool force: false}) async {
    if (force) {
      _items.clear();
    }
    return loadItems();
  }

  /// Get item by id.
  ///
  /// @param itemid Item Id
  /// @returns Item class
  Future<Item> getItem(String itemId) async {
    if (itemId == null) {
      return null;
    }
    final Response response = await iget('/items/$itemId');
    if (response.statusCode == 200) {
      final dynamic itemJson = JSON.decode(response.body);
      return new Item(
          itemJson, Services.users.getDist(itemJson['lat'], itemJson['lng']));
    }
    return null;
  }

  /// Get user items.
  ///
  /// @returns User items list
  Future<List<Item>> getSelfItems() async {
    final Response response =
        await iget('/items/user', Services.auth.accessToken);
    if (response.statusCode == 200) {
      final dynamic itemJson = JSON.decode(response.body);
      _myItems = new List<Item>.generate(
          itemJson.length,
          (index) => new Item(
              itemJson[index],
              Services.users
                  .getDist(itemJson[index]['lat'], itemJson[index]['lng'])));
    }
    return _myItems;
  }
}
