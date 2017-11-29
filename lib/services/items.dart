import 'dart:async';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/models/api.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/services/basic.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/keys.dart';
import 'package:qrcode_reader/QRCodeReader.dart';

/// Items class manager
class ItemsManager extends BasicService {
  /// Get items categories
  List<String> get categories => _categories;

  /// Get items sort method
  List<String> get sortMethod => _sortMethod;

  /// Get sort method and categories to exlude when filter items
  List<String> get exludeTracks => [_sortMethod].expand((x) => x).toList();

  /// Get items
  List<Item> get data => _data;

  /// Get user items
  List<Item> get owned => _owned;

  /// Get holded items
  List<Item> get holded => _holded;

  /// ValueNotifier of tracks filter
  final ValueNotifier<List<String>> tracks =
      new ValueNotifier<List<String>>([]);

  /// Filters of explorer
  final filters = [
    {'name': 'Categories', 'type': 'grid'},
    {'name': 'Advanced', 'type': 'grid'}
  ];

  /// Private variables
  List<Item> _data = <Item>[];
  List<Item> _owned = <Item>[];
  List<Item> _holded = <Item>[];
  final List<String> _sortMethod = ['dist', 'name'];
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
  Future<ApiRes> addItem(Map<String, dynamic> payload) async {
    assert(payload != null);
    final res = await ipost('/items', payload, Services.auth.accessToken);
    return res;
  }

  /// Edit item by id.
  ///
  /// @param payload Item payload
  /// @returns Api body response
  Future<ApiRes> editItem(Map<String, dynamic> payload) async {
    assert(payload != null);
    final id = payload.remove('id');
    final res = await iput('/items/$id', payload, Services.auth.accessToken);
    return res;
  }

  /// Delete item by id.
  ///
  /// @param id Item Id
  /// @returns Api body res
  Future<ApiRes> deleteItem(String id) async {
    assert(id != null);
    final res = await idelete('/items/$id', Services.auth.accessToken);
    return res;
  }

  /// Load items filter by token.
  ///
  /// @returns Items list
  Future<List<Item>> loadItems() async {
    if (_data.isEmpty) {
      await Services.users.getLocation();
      final res = await iget(
          Services.auth.loggedIn != null ? '/items/auth' : '/items',
          Services.auth.loggedIn ? Services.auth.accessToken : null);
      if (res.success && res.data is List) {
        return _data = res.data
            .map((f) => new Item(f, Services.users.getDist(f['lat'], f['lng'])))
            .where((item) => item.dist < Services.settings.value.maxDistance)
            .toList();
      }
    }
    return _data;
  }

  /// Get loaded items or reload it.
  ///
  /// @param force Force reload of items
  /// @returns Items list
  Future<List<Item>> getItems({bool force: false}) async {
    if (force) {
      _data.clear();
    }
    return loadItems();
  }

  /// Get item by id.
  ///
  /// @param itemid Item Id
  /// @returns Item class
  Future<Item> getItem(String itemId) async {
    assert(itemId != null);
    final res = await iget('/items/$itemId');
    if (res.success) {
      return new Item(
          res.data, Services.users.getDist(res.data['lat'], res.data['lng']));
    }
    return null;
  }

  /// Get user items.
  ///
  /// @returns User items list
  Future<List<Item>> getUserItems() async {
    final res = await iget('/items/user', Services.auth.accessToken);
    if (res.success && res.data is List) {
      return _owned = res.data
          .map((f) => new Item(f, Services.users.getDist(f['lat'], f['lng'])))
          .toList();
    }
    return _owned;
  }

  /// Delete item by id.
  ///
  /// @param id Item Id
  /// @param payload data
  /// @returns Api body response
  Future<ApiRes> bookItem(String itemId, Map<String, dynamic> payload) async {
    assert(itemId != null && payload != null);
    final res = await iput('/items/$itemId/book', payload);
    return res;
  }

  /// Get user items.
  ///
  /// @returns User items list
  Future<List<Item>> getHolded() async {
    final res = await iget('/items/holded', Services.auth.accessToken);
    if (res.success && res.data is List) {
      return _holded = res.data
          .map((f) => new Item(f, Services.users.getDist(f['lat'], f['lng'])))
          .toList();
    }
    return _holded;
  }

  /// Update location of a item if user has item
  Future<ApiRes> updateLocation(
    String itemId,
    Map<String, dynamic> payload,
  ) async {
    assert(itemId != null && payload != null);
    final res = await iput('/items/$itemId/location', payload);
    return res;
  }

  /// Parse a given qrCode.
  ///
  /// @param QRcode data
  /// @returns Item id
  String parseCode(String code) {
    assert(code != null);
    final parsed = code.substring('$apiUrl/items/'.length);
    if (parsed.contains('/')) {
      final split = parsed.split('/');
      return split[0].trim();
    }
    return parsed.trim();
  }

  /// Read QrCode
  Future<Null> qrReader(BuildContext context) async {
    final buffer = await new QRCodeReader().scan();
    final itemId = Services.items.parseCode(buffer);
    await Navigator.of(context).pushReplacementNamed('/items/:$itemId/scanned');
  }
}
