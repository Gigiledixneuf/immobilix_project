import 'package:immobilx/business/models/user/role.dart';

class User {
  final String? id;
  final String? fullName;
  final String? email;
  final String? portable;
  final String? token;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Role>? roles;

  User({
    this.id,
    this.fullName,
    this.email,
    this.portable,
    this.token,
    this.createdAt,
    this.updatedAt,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var roleList = json['roles'] as List?;
    List<Role>? roles;
    if (roleList != null) {
      roles = roleList.map((i) => Role.fromJson(i)).toList();
    }

    return User(
      id: json['id']?.toString(),
      fullName: json['fullName'],
      email: json['email'],
      portable: json['portable'],
      token: json['token'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'portable': portable,
    'token': token,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'roles': roles?.map((role) => role.toJson()).toList(),
  };
}
