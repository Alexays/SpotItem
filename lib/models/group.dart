import 'dart:convert';
import 'package:spotitem/models/user.dart';

/// Group model
class Group {
  /// Group class initializer
  Group(data)
      : id = data['_id'],
        name = data['name'],
        about = data['about'],
        users = new List<User>.generate(data['users']?.length ?? 0,
            (index) => new User(data['users'][index])),
        owners = new List<User>.generate(data['owners']?.length ?? 0,
            (index) => new User(data['owners'][index]));

  /// Group id
  final String id;

  /// Group name
  String name;

  /// Group description
  String about;

  /// Group users
  List<User> users;

  /// Group owner
  List<User> owners;

  /// Create a group from JSON object
  factory Group.from(group) => new Group(JSON.decode(group.toString()));

  /// Check if a group is valid
  bool isValid() => id != null && name != null;

  @override
  String toString() {
    var usersId = [];
    usersId = new List<String>.generate(
        users?.length ?? 0, (index) => users[index].id);
    return '{"_id": "$id", "name": "$name", "about": "$about", "users": $usersId, "owners": $owners}';
  }
}
