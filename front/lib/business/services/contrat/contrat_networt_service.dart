import '../../models/contrat/contrat.dart'; // Modèle représentant un contrat
import '../../models/gestion/payment.dart'; // Modèle représentant un paiement
import '../../models/user/user.dart'; // Modèle représentant un utilisateur (locataire ou propriétaire)

abstract class ContractNetworkService {

  // =============================
  // 🔹 1. RÉCUPÉRER TOUS LES CONTRATS
  // =============================
  // Retourne une liste de tous les contrats disponibles
  Future<List<Contract>> getContracts();

  // =============================
  // 🔹 2. OBTENIR LES DÉTAILS D’UN CONTRAT
  // =============================
  // Récupère les informations détaillées d’un contrat spécifique selon son ID
  Future<Contract> getContractDetails(int id);

  // =============================
  // 🔹 3. CRÉER UN NOUVEAU CONTRAT
  // =============================
  // Envoie les données d’un nouveau contrat pour le créer sur le serveur
  Future<Contract> createContract(Map<String, dynamic> data);

  // =============================
  // 🔹 4. METTRE À JOUR UN CONTRAT EXISTANT
  // =============================
  // Met à jour un contrat existant avec de nouvelles données
  Future<Contract> updateContract(int id, Map<String, dynamic> data);

  // =============================
  // 🔹 5. SUPPRIMER UN CONTRAT
  // =============================
  // Supprime un contrat spécifique du système à partir de son ID
  Future<void> deleteContract(int id);

  // =============================
  // 🔹 6. RÉCUPÉRER LA LISTE DES LOCATAIRES
  // =============================
  // Récupère tous les locataires (users) enregistrés
  Future<List<User>> getTenants();

  // =============================
  // 🔹 7. EFFECTUER UN PAIEMENT
  // =============================
  // Envoie les données d’un paiement (montant, contrat, date, etc.) pour l’enregistrer
  Future<Payment> makePayment(Map<String, dynamic> paymentData);

  // =============================
  // 🔹 8. RÉCUPÉRER LES PAIEMENTS D’UN CONTRAT
  // =============================
  // Récupère la liste des paiements associés à un contrat donné
  Future<List<Payment>> getContractPayments(int contractId);

  // =============================
  // 🔹 9. PAYER LA CAUTION (DÉPÔT)
  // =============================
  // Lance l’initiation de paiement de dépôt et retourne la réponse brute (peut contenir checkoutUrl)
  Future<Map<String, dynamic>> payDeposit({required int contractId, required double amount, required String paymentMethod});
}
