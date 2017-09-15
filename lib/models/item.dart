import 'dart:convert';
import 'package:spotitem/models/user.dart';

/// Item Model
class Item {
  /// Item class initializer
  Item(data, this.dist)
      : id = data['_id'],
        name = data['name'],
        about = data['about'],
        images = data['images'],
        lastGeo = data['lastGeo'],
        calendar = data['calendar'],
        location = data['location'],
        lat = data['lat'],
        lng = data['lng'],
        tracks = data['tracks'] ?? [],
        groups = data['groups'] ?? [],
        owner = new User(data['owner']);

  /// Item id
  final String id;

  /// Item owner
  final User owner;

  /// Item name
  String name;

  /// Item description
  String about;

  /// Item images
  List<String> images;

  /// Iten last geolocation position
  String lastGeo;

  /// Item calendar
  List<String> calendar;

  /// Item location
  String location;

  /// Item lattitude
  double lat;

  /// Item longitude
  double lng;

  /// Item distance between user
  double dist;

  /// Item tracks
  List<String> tracks;

  /// Item groups
  List<String> groups;

  /// Create item from JSON object
  factory Item.from(item) => new Item(JSON.decode(item.toString()), item.dist);

  /// Check if item is valid
  bool isValid() => id != null && name != null && owner != null;

  @override
  String toString() =>
      'Item{id: $id, name: $name, about: $about, images: $images, lastGeo: $lastGeo, calendar: $calendar, location: $location, lat: $lat, lng: $lng, owner: $owner, groups: groups, $tracks: $tracks}';
}
