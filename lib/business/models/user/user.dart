//generate class user with optional fields and toJosn and fromJson methods

class User {
  final String? id;
  final String? name;
  final String? email;

  User({this.id, this.name, this.email});

  factory User.fromJson(json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
      );

  Map toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}
