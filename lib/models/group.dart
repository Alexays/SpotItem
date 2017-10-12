import 'dart:convert';
import 'package:spotitem/models/user.dart';

/// Group model
class Group {
  /// Group class initializer
  Group(Map<String, dynamic> data)
      : id = data['_id'],
        name = data['name'],
        about = data['about'],
        users = data['users'] is List ? data['users'].map((f) => new User(f)).toList() : <User>[],
        owners = data['owners'] is List ? data['owners'].map((f) => new User(f)).toList() : <User>[];

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
  factory Group.from(Group group) => new Group(JSON.decode(group.toString()));

  /// Check if a group is valid
  bool isValid() => id != null && name != null;

  @override
  String toString() {
    final usersId = new List<String>.generate(users?.length ?? 0, (index) => '"${users[index].id}"');
    final ownersId = new List<String>.generate(owners?.length ?? 0, (index) => '"${owners[index].id}"');
    return '{"_id": "$id", "name": "$name", "about": "$about", "users": $usersId, "owners": $ownersId}';
  }
}
