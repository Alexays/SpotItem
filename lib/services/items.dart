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

  /// Get tracks without excluded tracks
  List<String> get excludeTracks =>
      tracks.value.where((f) => !_excludedTracks.contains(f)).toList();

  /// Get tracks with excluded tracks
  List<String> get excludedTracks =>
      tracks.value.where((f) => _excludedTracks.contains(f)).toList();

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
  final List<Map<String, dynamic>> filters = [
    {'name': 'Categories', 'type': 'grid', 'data': _categories},
    {'name': 'Advanced', 'type': 'list', 'data': _tracks},
  ];

  /// Private variables
  List<String> get _excludedTracks => [_sortMethod].expand((x) => x).toList();
  List<Item> _data = <Item>[];
  List<Item> _owned = <Item>[];
  List<Item> _holded = <Item>[];
  final List<String> _sortMethod = ['none', 'dist', 'name'];
  static final List<String> _tracks = ['gift', 'group'];
  static final List<String> _categories = [
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
  Future<ApiRes> add(Map<String, dynamic> payload) async {
    assert(payload != null);
    final res = await ipost('/items', payload, Services.auth.accessToken);
    return res;
  }

  /// Edit item by id.
  ///
  /// @param payload Item payload
  /// @returns Api body response
  Future<ApiRes> edit(Map<String, dynamic> payload) async {
    assert(payload != null);
    final id = payload.remove('id');
    final res = await iput('/items/$id', payload, Services.auth.accessToken);
    return res;
  }

  /// Delete item by id.
  ///
  /// @param id Item Id
  /// @returns Api body res
  Future<ApiRes> delete(String id) async {
    assert(id != null);
    final res = await idelete('/items/$id', Services.auth.accessToken);
    return res;
  }

  /// Load items filter by token.
  ///
  /// @returns Items list
  Future<List<Item>> load() async {
    if (_data.isEmpty) {
      await Services.users.getLocation();
      final res = await iget('/items', Services.auth.accessToken);
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
  Future<List<Item>> getAll({bool force: false}) async {
    if (force) {
      _data.clear();
    }
    return load();
  }

  /// Get item by id.
  ///
  /// @param itemid Item Id
  /// @returns Item class
  Future<Item> get(String itemId) async {
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
  Future<List<Item>> getUser() async {
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
  Future<ApiRes> book(String itemId, Map<String, dynamic> payload) async {
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
