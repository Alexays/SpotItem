import 'package:spotitems/model/user.dart';

class Group {
  String id;
  String name;
  String about;
  List<User> users;

  Group(this.id, this.name, this.about, this.users);

  factory Group.fromJson(json) {
    if (json == null) return null;
    return new Group(
        json['_id'],
        json['name'],
        json['about'],
        new List<User>.generate(json['users'].length, (int index) {
          return new User.fromJson(json['users'][index]);
        }));
  }

  bool isValid() {
    return name != null;
  }

  @override
  String toString() {
    List<String> usersId = [];
    if (users != null) {
      usersId = new List<String>.generate(users.length, (int index) {
        return users[index].id;
      });
    }
    return "{\"_id\": \"$id\", \"name\": \"$name\", \"about\": \"$about\", \"users\": \"$usersId\"}";
  }
}
