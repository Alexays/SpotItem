class User {
  User(data)
      : id = data['_id'],
        email = data['email'],
        firstname = data['firstname'],
        name = data['name'],
        avatar = data['avatar'],
        groups = new List<String>.generate(data['groups']?.length,
            (index) => (data['groups'][index]).toString()) {
    assert(id != null);
    assert(email != null);
    assert(firstname != null);
  }

  final String id;
  final String email;
  String firstname;
  String name;
  String avatar;
  List<String> groups;

  factory User.from(user) => new User(user.toString());

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
