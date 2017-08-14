class User {
  String id;
  String email;
  String firstname;
  String name;
  String avatar;

  User(this.id, this.name, this.email, this.firstname, this.avatar);

  factory User.fromJson(json) {
    if (json == null) return null;
    return new User(json['_id'], json['name'], json['email'], json['firstname'],
        json['avatar']);
  }

  bool isValid() {
    return name != null && email != null && firstname != null;
  }

  @override
  String toString() {
    return "{\"_id\": \"$id\", \"name\": \"$name\", \"email\": \"$email\", \"firstname\": \"$firstname\", \"avatar\": \"$avatar\"}";
  }
}
