class User {
  final String id;
  final String email;
  final String firstname;
  final String name;
  final String avatar;

  const User(this.id, this.name, this.email, this.firstname, this.avatar);

  factory User.fromJson(json) {
    if (json == null) {
      return null;
    } else {
      return new User(json['id'], json['name'], json['email'],
          json['firstname'], json['avatar']);
    }
  }

  bool isValid() {
    return name != null && email != null && firstname != null;
  }

  @override
  String toString() {
    return "{\"id\": \"$id\", \"name\": \"$name\", \"email\": \"$email\", \"firstname\": \"$firstname\", \"avatar\": \"$avatar\"}";
  }
}
