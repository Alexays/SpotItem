import 'package:spot_items/model/user.dart';

class Item {
  final String id;
  final String name;
  final String about;
  final List<String> images;
  final String lastGeo;
  final List<String> calendar;
  final String location;
  final double lat;
  final double lng;
  final List<String> tracks;
  final User owner;

  const Item(
      this.id,
      this.name,
      this.about,
      this.images,
      this.lastGeo,
      this.calendar,
      this.location,
      this.lat,
      this.lng,
      this.owner,
      this.tracks);

  factory Item.fromJson(json) {
    if (json == null) {
      return null;
    } else {
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
          new User.fromJson(json['owner']),
          json['tracks']);
    }
  }

  bool isValid() {
    return name != null && about != null && images != null && owner.isValid();
  }

  @override
  String toString() {
    return 'Item{id: $id, name: $name, about: $about, images: $images, lastGeo: $lastGeo, calendar: $calendar, location: $location, lat: $lat, lng: $lng, owner: $owner, tracks: $tracks}';
  }
}
