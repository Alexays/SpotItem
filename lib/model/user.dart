import 'dart:convert';

class User {
  String id;
  String email;
  String firstname;
  String name;
  String avatar;
  List<String> groups;

  User(
      this.id, this.name, this.email, this.firstname, this.avatar, this.groups);

  factory User.fromJson(json) {
    if (json == null) return null;
    var _groups = [];
    if (json['groups'] != null && json['groups'].length > 0) {
      _groups = new List<String>.generate(json['groups'].length, (int index) {
        return json['groups'][index].toString();
      });
    }
    return new User(json['_id'], json['name'], json['email'], json['firstname'],
        json['avatar'], _groups);
  }

  bool isValid() {
    return name != null && email != null && firstname != null;
  }

  @override
  String toString() {
    var _groups = new List<String>.generate(groups.length, (int index) {
      return '"' + groups[index] + '"';
    });
    return '{"_id": "$id", "name": "$name", "email": "$email", "firstname": "$firstname", "avatar": "$avatar", "groups": $_groups}';
  }
}
