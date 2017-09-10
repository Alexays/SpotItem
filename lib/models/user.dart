import 'dart:convert';

class User {
  User(data)
      : id = data['_id'],
        email = data['email'],
        firstname = data['firstname'],
        name = data['name'],
        avatar = data['avatar'],
        groups = new List<String>.generate(data['groups']?.length ?? 0,
            (index) => (data['groups'][index]).toString());

  final String id;
  final String email;
  String firstname;
  String name;
  String avatar;
  List<String> groups;

  factory User.from(user) => new User(JSON.decode(user.toString()));

  bool isValid() => id != null && name != null && email != null;

  @override
  String toString() {
    List<String> _groups;
    if (groups != null) {
      _groups = new List<String>.generate(
          groups.length, (index) => '"${groups[index]}"');
    }
    return '{"_id": "$id", "name": "$name", "email": "$email", "firstname": "$firstname", "avatar": "$avatar", "groups": $_groups}';
  }
}
