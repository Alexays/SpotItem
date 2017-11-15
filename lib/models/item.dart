import 'dart:convert';
import 'package:spotitem/models/user.dart';

/// Item event model
class Event {
  /// Item event class initializer
  Event(Map<String, dynamic> payload)
      : date = DateTime.parse(payload['date']).toLocal(),
        holder = payload['holder'],
        data = payload['data'];

  /// date of event
  final DateTime date;

  /// Holder at this date
  final String holder;

  /// Event data
  final Map<String, dynamic> data;

  /// Convert class to json
  Map<String, dynamic> toJson() =>
      {'date': '$date', 'holder': holder, 'data': data};
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
        calendar = data['calendar'] is List
            ? data['calendar'].map((f) => new Event(f)).toList()
            : <Event>[],
        location = data['location'],
        lat = data['lat'],
        lng = data['lng'],
        tracks = data['tracks'] ?? <String>[],
        groups = data['groups'] ?? <String>[],
        owner = data['owner'] is Map<String, dynamic>
            ? new User(data['owner'])
            : new User({'_id': data['owner']});

  /// Item id
  final String id;

  /// Item owner
  final User owner;

  /// Item name
  final String name;

  /// Item description
  final String about;

  /// Item images
  final List<String> images;

  /// Iten last geolocation position
  final String lastGeo;

  /// Item calendar
  final List<Event> calendar;

  /// Item location
  final String location;

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
  factory Item.from(Item item) =>
      new Item(JSON.decode(item.toString()), item.dist);

  /// Check if item is valid
  bool isValid() => id != null && name != null && owner != null;

  /// Convert class to json
  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'about': about,
        'images': images,
        'lastGeo': lastGeo,
        'calendar': calendar.map((f) => f.toJson()).toList(),
        'location': location,
        'lat': lat.toString(),
        'lng': lng.toString(),
        'owner': owner.toJson(),
        'groups': groups,
        'tracks': tracks,
      };

  @override
  String toString() => JSON.encode(toJson());
}
