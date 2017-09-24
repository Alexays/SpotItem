import 'dart:async';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/models/api.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';

/// Items class manager
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

  /// Private variables
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
  Future<ApiRes> addItem(payload) async {
    final ApiRes response =
        await ipost('/items', payload, Services.auth.accessToken);
    return response;
  }

  /// Edit item by id.
  ///
  /// @param payload Item payload
  /// @returns Api body response
  Future<ApiRes> editItem(payload) async {
    final ApiRes response = await iput(
        '/items/${payload['id']}', payload, Services.auth.accessToken);
    return response;
  }

  /// Delete item by id.
  ///
  /// @param id Item Id
  /// @returns Api body response
  Future<ApiRes> deleteItem(String id) async {
    final ApiRes response =
        await idelete('/items/$id', Services.auth.accessToken);
    return response;
  }

  /// Load items filter by token.
  ///
  /// @returns Items list
  Future<List<Item>> loadItems() async {
    if (_items.isEmpty) {
      await Services.users.getLocation();
      final ApiRes response = await iget(
          '${Services.auth.loggedIn != null ? '/items/auth' : '/items'}',
          Services.auth.loggedIn ? Services.auth.accessToken : null);
      if (response.statusCode == 200 && response.success) {
        return _items = new List<Item>.generate(
            response.data?.length ?? 0,
            (index) => new Item(
                response.data[index],
                Services.users.getDist(
                    response.data[index]['lat'], response.data[index]['lng'])));
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
    final ApiRes response = await iget('/items/$itemId');
    if (response.statusCode == 200 && response.success) {
      return new Item(response.data,
          Services.users.getDist(response.data['lat'], response.data['lng']));
    }
    return null;
  }

  /// Get user items.
  ///
  /// @returns User items list
  Future<List<Item>> getSelfItems() async {
    final ApiRes response =
        await iget('/items/user', Services.auth.accessToken);
    if (response.statusCode == 200 && response.success) {
      _myItems = new List<Item>.generate(
          response.data?.length ?? 0,
          (index) => new Item(
              response.data[index],
              Services.users.getDist(
                  response.data[index]['lat'], response.data[index]['lng'])));
    }
    return _myItems;
  }
}
