import 'package:immobilx/business/models/gestion/property.dart'; // Modèle de la propriété concernée par le contrat
import 'package:immobilx/business/models/user/user.dart';         // Modèle de l'utilisateur (locataire)

// =============================
// 🔹 CLASSE Contract (Modèle de données)
// =============================
class Contract {
  final int id;                    // Identifiant unique du contrat
  final int propertyId;            // Identifiant de la propriété associée
  final int tenantId;              // Identifiant du locataire lié au contrat
  final DateTime startDate;        // Date de début du contrat
  final DateTime? endDate;         // Date de fin du contrat (peut être nulle si en cours)
  final String? description;       // Description ou remarques du contrat
  final double rentAmount;         // Montant du loyer mensuel
  final String currency;           // Devise du paiement (ex : "USD", "CDF")
  final String status;             // Statut du contrat (ex : "ACTIVE", "ENDED", "CANCELLED")
  final int depositMonths;         // Nombre de mois de caution exigés
  final double? depositAmount;     // Montant total du dépôt de garantie (optionnel)
  final String depositStatus;      // Statut de la caution (ex : "PAID", "UNPAID")
  final String? hederaContractId;  // Identifiant du contrat sur Hedera Hashgraph (si connecté à la blockchain)
  final DateTime createdAt;        // Date de création du contrat
  final DateTime updatedAt;        // Dernière date de mise à jour
  final Property property;         // Objet Property contenant les infos du bien concerné
  final User tenant;               // Objet User représentant le locataire

  // =============================
  // 🔹 Constructeur
  // =============================
  Contract({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.startDate,
    this.endDate,
    this.description,
    required this.rentAmount,
    required this.currency,
    required this.status,
    required this.depositMonths,
    this.depositAmount,
    required this.depositStatus,
    this.hederaContractId,
    required this.createdAt,
    required this.updatedAt,
    required this.property,
    required this.tenant,
  });

  // =============================
  // 🔹 factory Contract.fromJson()
  // =============================
  // Méthode permettant de transformer une réponse JSON en un objet Contract
  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'], // ID du contrat
      propertyId: json['propertyId'], // ID de la propriété concernée
      tenantId: json['tenantId'], // ID du locataire
      startDate: DateTime.parse(json['startDate']), // Conversion de la date de début
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null, // Conversion conditionnelle de la date de fin
      description: json['description'], // Description (optionnelle)
      rentAmount: double.parse(json['rentAmount'].toString()), // Conversion du montant en double
      currency: json['currency'], // Devise
      status: json['status'], // Statut du contrat
      depositMonths: json['depositMonths'], // Nombre de mois de dépôt
      depositAmount: json['depositAmount'] != null
          ? double.parse(json['depositAmount'].toString())
          : null, // Montant du dépôt (si présent)
      depositStatus: json['depositStatus'], // Statut de la caution
      hederaContractId: json['hederaContractId'], // ID du contrat sur Hedera (si existant)
      createdAt: DateTime.parse(json['createdAt']), // Date de création
      updatedAt: DateTime.parse(json['updatedAt']), // Dernière mise à jour
      property: Property.fromJson(json['property']), // Conversion du JSON en objet Property
      tenant: User.fromJson(json['tenant']), // Conversion du JSON en objet User (locataire)
    );
  }
}
