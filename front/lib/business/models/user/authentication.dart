// create model class for authentication name and password with toJson and fromJson methods

class Authentication {
  final String? name;
  final String? password;

  Authentication({this.name, this.password});

  factory Authentication.fromJson(json) => Authentication(
        name: json['name'],
        password: json['password'],
      );

  Map toJson() => {
        'name': name,
        'password': password,
      };
}

