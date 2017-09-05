import 'package:spotitem/models/user.dart';

class Item {
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
        tracks = data['tracks'],
        groups = data['groups'],
        owner = new User(data['owner']) {
    assert(id != null);
    assert(owner != null);
    assert(name != null);
  }

  final String id;
  final User owner;
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

  @override
  String toString() =>
      'Item{id: $id, name: $name, about: $about, images: $images, lastGeo: $lastGeo, calendar: $calendar, location: $location, lat: $lat, lng: $lng, owner: $owner, groups: groups, $tracks: $tracks}';
}
