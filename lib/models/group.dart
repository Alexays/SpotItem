import 'package:spotitem/models/user.dart';

class Group {
  Group(data)
      : id = data['_id'],
        name = data['name'],
        about = data['about'],
        users = new List<User>.generate(
            data['users'].length, (index) => new User(data['users'][index])),
        owner = data['owner'] {
    assert(id != null);
    assert(name != null);
    assert(owner != null);
  }

  final String id;
  String name;
  String about;
  List<User> users;
  String owner;

  factory Group.from(group) => new Group(group.toString());

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
