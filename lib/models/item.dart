import 'package:spotitem/models/user.dart';

class Item {
  String id;
  String name;
  String about;
  List<String> images;
  String lastGeo;
  List<String> calendar;
  String location;
  double lat;
  double lng;
  double dist;
  List<String> tracks;
  List<String> groups;
  User owner;

  Item(
    this.id,
    this.name,
    this.about,
    this.images,
    this.lastGeo,
    this.calendar,
    this.location,
    this.lat,
    this.lng,
    this.dist,
    this.tracks,
    this.groups,
    this.owner,
  );

  factory Item.fromJson(json, double dist) {
    if (json == null) {
      return null;
    }
    return new Item(
      json['_id'],
      json['name'],
      json['about'],
      json['images'],
      json['lastGeo'],
      json['calendar'],
      json['location'],
      json['lat'],
      json['lng'],
      dist,
      json['tracks'],
      json['groups'],
      new User.fromJson(json['owner']),
    );
  }

  bool isValid() =>
      name != null && about != null && images != null && owner.isValid();

  @override
  String toString() =>
      'Item{id: $id, name: $name, about: $about, images: $images, lastGeo: $lastGeo, calendar: $calendar, location: $location, lat: $lat, lng: $lng, owner: $owner, groups: groups, $tracks: $tracks}';
}
