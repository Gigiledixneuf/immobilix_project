//generate class user with optional fields and toJosn and fromJson methods

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? token; // Ajout du champ token

  User({this.id, this.name, this.email, this.token});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id']?.toString(), // Correction: Conversion en String
    name: json['name'],
    email: json['email'],
    token: json['token'], // Lecture du token depuis le JSON
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'token': token, // Ajout du token au JSON
  };
}
