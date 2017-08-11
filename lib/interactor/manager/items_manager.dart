import 'dart:async';
import 'dart:convert';
import 'package:spotitems/keys.dart';
import 'package:spotitems/model/item.dart';
import 'package:http/http.dart';

class ItemsManager {
  bool get initialized => _initialized;

  bool get loading => _loading;

  List<Item> get items => _items;

  bool _initialized;
  bool _loading = true;
  List<Item> _items = [];

  Future init() async {
    _items.clear();
    _initialized = true;
  }

  Future loadItems() async {
    if (_items.length == 0) {
      print("load");
      final Client _client = new Client();
      final itemResponse =
          await _client.get(API_URL + '/items').whenComplete(_client.close);
      if (itemResponse.statusCode == 200) {
        _items = JSON.decode(itemResponse.body);
        _loading = false;
      } else {
        _loading = false;
      }
    }
    return _items;
  }

  Future<List<Item>> getItems(bool force) async {
    if (force) _items.clear();
    return await loadItems();
  }
}
