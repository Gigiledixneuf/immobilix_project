// Importation du modèle de données 'Role' nécessaire pour la liste des rôles de l'utilisateur.
import 'package:immobilx/business/models/user/role.dart';

// Définition de la classe du modèle de données User (Utilisateur).
class User {
  // =============================
  // 🔹 1. PROPRIÉTÉS DU MODÈLE
  // =============================
  final int? id; // Identifiant unique de l'utilisateur.
  final String? fullName; // Nom complet de l'utilisateur.
  final String? email; // Adresse e-mail de l'utilisateur.
  final String? portable; // Numéro de téléphone portable.
  final String? token; // Jeton d'authentification (si applicable, ex: lors de la connexion).
  final String? mainPhotoUrl; // URL de la photo principale de l'utilisateur.
  final DateTime? createdAt; // Date de création du compte utilisateur.
  final DateTime? updatedAt; // Date de dernière mise à jour du compte.
  final List<Role>? roles; // Liste des rôles assignés à l'utilisateur.

  // =============================
  // 🔹 2. CONSTRUCTEUR
  // =============================
  // Constructeur qui initialise toutes les propriétés, toutes sont optionnelles (nullable).
  User({
    this.id,
    this.fullName,
    this.email,
    this.portable,
    this.token,
    this.mainPhotoUrl,
    this.createdAt,
    this.updatedAt,
    this.roles,
  });

  // =============================
  // 🔹 3. CONVERSION DEPUIS JSON (FACTORY CONSTRUCTOR)
  // =============================
  // Factory constructor pour créer une instance de User à partir d'une Map JSON.
  factory User.fromJson(Map<String, dynamic> json) {
    // Tente de récupérer la liste des rôles depuis la clé 'roles'.
    var roleList = json['roles'] as List?;
    List<Role>? roles;

    // Si la liste des rôles existe, la mapper de JSON en une liste d'objets Role.
    if (roleList != null) {
      roles = roleList.map((i) => Role.fromJson(i)).toList();
    }

    // Retourne la nouvelle instance de User avec les données converties.
    return User(
      // Conversion de l'ID en int, gérant les cas où il pourrait être une chaîne.
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      fullName: json['fullName'],
      email: json['email'],
      portable: json['portable'],
      mainPhotoUrl: json['mainPhotoUrl'],
      token: json['token'],
      // Conversion des chaînes de date en objets DateTime.
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      roles: roles,
    );
  }

  // =============================
  // 🔹 4. CONVERSION VERS JSON
  // =============================
  // Méthode pour convertir l'instance de User en une Map JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'portable': portable,
    'token': token,
    // Conversion des objets DateTime en chaînes de caractères au format ISO 8601.
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    // Mappage de la liste des rôles en une liste de Map JSON.
    'roles': roles?.map((role) => role.toJson()).toList(),
  };
}