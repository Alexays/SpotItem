import 'package:spotitems/model/user.dart';

class Group {
  String id;
  String name;
  String about;
  List<User> users;
  String owner;

  Group(this.id, this.name, this.about, this.users, this.owner);

  factory Group.fromJson(json) {
    if (json == null) {
      return null;
    }
    return new Group(
        json['_id'],
        json['name'],
        json['about'],
        new List<User>.generate(json['users'].length,
            (index) => new User.fromJson(json['users'][index])),
        json['owner']);
  }

  bool isValid() => name != null;

  @override
  String toString() {
    List<String> usersId = <String>[];
    if (users != null) {
      usersId =
          new List<String>.generate(users.length, (index) => users[index].id);
    }
    return '{"_id": "$id", "name": "$name", "about": "$about", "users": $usersId, "owner": "$owner"}';
  }
}
