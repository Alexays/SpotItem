import 'dart:convert';
import 'package:spotitem/models/user.dart';

/// Item event model
class Event {
  /// Item event class initializer
  Event(Map<String, dynamic> payload)
      : date = new DateTime.fromMillisecondsSinceEpoch(payload['date']),
        holder = payload['holder'],
        data = payload['data'];

  /// date of event
  final DateTime date;

  /// Holder at this date
  final String holder;

  /// Event data
  final Map<String, dynamic> data;

  @override
  String toString() => '{"date": "$date.millisecondsSinceEpoch", "holder": "$holder", "data": $data}';
}

/// Item Model
class Item {
  /// Item class initializer
  Item(Map<String, dynamic> data, this.dist)
      : id = data['_id'],
        name = data['name'],
        about = data['about'],
        images = data['images'] ?? <String>[],
        lastGeo = data['lastGeo'],
        calendar = data['calendar'] is List ? data['calendar'].map((f) => new Event(f)).toList() : <Event>[],
        location = data['location'],
        lat = data['lat'],
        lng = data['lng'],
        tracks = data['tracks'] ?? <String>[],
        groups = data['groups'] ?? <String>[],
        owner = data['owner'] is Map<String, dynamic> ? new User(data['owner']) : new User({'_id': data['owner']});

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
  List<Event> calendar;

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
  factory Item.from(Item item) => new Item(JSON.decode(item.toString()), item.dist);

  /// Check if item is valid
  bool isValid() => id != null && name != null && owner != null;

  @override
  String toString() {
    final _calendar = new List<String>.generate(calendar.length, (i) => calendar[i].toString());
    return '{"_id": "$id", "name": "$name", "about": "$about", "images": $images, "lastGeo": $lastGeo, "calendar": $_calendar, "location": "$location", "lat": $lat, "lng": $lng, "owner": "$owner", "groups": groups, "tracks": $tracks}';
  }
}
