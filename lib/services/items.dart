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

  /// Get items sort method
  List<String> get sortMethod => _sortMethod;

  /// Get sort method and categories to exlude when filter items
  List<String> get exludeTracks => [_sortMethod, _categories].expand((x) => x).toList();

  /// Get items
  List<Item> get items => _items;

  /// Get user items
  List<Item> get myItems => _myItems;

  /// ValueNotifier of tracks filter
  final ValueNotifier<List<String>> tracks = new ValueNotifier<List<String>>([]);

  /// Private variables
  List<Item> _items = <Item>[];
  List<Item> _myItems = <Item>[];
  final List<String> _sortMethod = ['name', 'dist', 'date'];
  final List<String> _categories = ['jeux', 'bebe_jeunesse', 'fete', 'garage', 'objet', 'cuisine', 'jardin'];

  /// Add item.
  ///
  /// @param payload Item payload
  /// @returns Api body response
  Future<ApiRes> addItem(Map<String, dynamic> payload) async {
    final response = await ipost('/items', payload, Services.auth.accessToken);
    return response;
  }

  /// Edit item by id.
  ///
  /// @param payload Item payload
  /// @returns Api body response
  Future<ApiRes> editItem(Map<String, dynamic> payload) async {
    final response = await iput('/items/${payload['id']}', payload, Services.auth.accessToken);
    return response;
  }

  /// Delete item by id.
  ///
  /// @param id Item Id
  /// @returns Api body response
  Future<ApiRes> deleteItem(String id) async {
    final response = await idelete('/items/$id', Services.auth.accessToken);
    return response;
  }

  /// Load items filter by token.
  ///
  /// @returns Items list
  Future<List<Item>> loadItems() async {
    if (_items.isEmpty) {
      await Services.users.getLocation();
      final response = await iget(Services.auth.loggedIn != null ? '/items/auth' : '/items',
          Services.auth.loggedIn ? Services.auth.accessToken : null);
      if (response.success && response.data is List) {
        return _items = new List<Item>.generate(
                response.data?.length ?? 0,
                (index) => new Item(response.data[index],
                    Services.users.getDist(response.data[index]['lat'], response.data[index]['lng'])))
            .where((item) => item.dist < Services.settings.value.maxDistance)
            .toList();
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
    final response = await iget('/items/$itemId');
    if (response.success) {
      return new Item(response.data, Services.users.getDist(response.data['lat'], response.data['lng']));
    }
    return null;
  }

  /// Get user items.
  ///
  /// @returns User items list
  Future<List<Item>> getUserItems() async {
    final response = await iget('/items/user', Services.auth.accessToken);
    if (response.success && response.data is List) {
      return _myItems = new List<Item>.generate(
          response.data?.length ?? 0,
          (index) => new Item(
              response.data[index], Services.users.getDist(response.data[index]['lat'], response.data[index]['lng'])));
    }
    return _myItems;
  }
}
