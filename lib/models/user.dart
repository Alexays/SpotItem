import 'dart:convert';

/// User model
class User {
  /// User class initializer
  User(data)
      : id = data['_id'],
        email = data['email'],
        firstname = data['firstname'],
        name = data['name'],
        avatar = data['avatar'],
        groups = data['groups'] is List
            ? new List<String>.generate(data['groups']?.length ?? 0,
                (index) => (data['groups'][index]).toString())
            : <String>[];

  /// User id
  final String id;

  /// User email
  final String email;

  /// User firstname
  String firstname;

  /// User lastname
  String name;

  /// User avatar
  String avatar;

  /// User groups
  List<String> groups;

  /// Create user fron JSON object
  factory User.from(User user) => new User(JSON.decode(user.toString()));

  /// Check if user is valid
  bool isValid() => id != null && firstname != null && email != null;

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
