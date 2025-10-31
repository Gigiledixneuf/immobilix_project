// =============================
// 🔹 ENUMS (Types énumérés)
// =============================

// Liste des méthodes de paiement possibles
enum PaymentMethods {
  HBAR,          // Paiement avec la crypto-monnaie Hedera Hashgraph (HBAR)
  USDC,          // Paiement avec le stablecoin USDC (adossé au dollar)
  MOBILE_MONEY,  // Paiement via Mobile Money (M-Pesa, Orange Money, Airtel Money, etc.)
}

// Liste des statuts possibles d’un paiement
enum PaymentStatus {
  PENDING,  // En attente de confirmation (paiement pas encore validé)
  PAID,     // Paiement réussi et confirmé
  FAILED,   // Paiement échoué (erreur, solde insuffisant, etc.)
}

// =============================
// 🔹 CLASSE Payment (Modèle de données)
// =============================
class Payment {
  final int id;                // Identifiant unique du paiement
  final int contractId;        // Référence au contrat associé à ce paiement
  final double amount;         // Montant du paiement
  final String currency;       // Devise utilisée (ex : "USD", "CDF", "USDC", etc.)
  final String paymentMethod;  // Méthode utilisée (ex : "HBAR", "MOBILE_MONEY")
  final String status;         // Statut du paiement (PENDING, PAID ou FAILED)
  final String? transactionId; // ID de transaction externe (optionnel, ex : code Mobile Money)
  final DateTime createdAt;    // Date de création du paiement
  final DateTime updatedAt;    // Dernière date de mise à jour

  // Constructeur : permet de créer un objet Payment avec ses attributs
  Payment({
    required this.id,
    required this.contractId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  // =============================
  // 🔹 factory Payment.fromJson()
  // =============================
  // Méthode de fabrique pour créer un objet Payment à partir d’un JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'], // Récupère l'identifiant depuis le JSON
      contractId: json['contractId'], // Identifiant du contrat lié
      // Convertit le montant en double (même s’il arrive sous forme de texte)
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'], // Devise
      paymentMethod: json['paymentMethod'], // Méthode de paiement
      status: json['status'], // Statut du paiement
      transactionId: json['transactionId'], // ID de transaction optionnel
      // Convertit les chaînes de texte en objets DateTime
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
