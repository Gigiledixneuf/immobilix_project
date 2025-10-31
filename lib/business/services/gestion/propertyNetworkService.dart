import '../../models/gestion/application.dart';
import '../../models/gestion/property.dart';

// Définition de l'interface (classe abstraite) pour le service de réseau des propriétés.
// Cette interface définit le contrat (les méthodes) que toute implémentation du service
// de propriétés doit respecter.
abstract class PropertyNetworkService {

  // =============================
  // 🔹 1. OBTENIR LES DÉTAILS D’UNE PROPRIÉTÉ
  // =============================
  // Récupère une seule propriété en utilisant son identifiant (ID).
  // Doit retourner un Future qui complète avec un objet Property.
  Future<Property> getProperty(int id);

  // =============================
  // 🔹 2. RÉCUPÉRER TOUTES LES PROPRIÉTÉS
  // =============================
  // Récupère une liste de toutes les propriétés disponibles.
  // Doit retourner un Future qui complète avec une liste d'objets Property.
  Future<List<Property>> getProperties();

  // =============================
  // 🔹 2bis. RÉCUPÉRER LES PROPRIÉTÉS PUBLIQUES (option disponible)
  // =============================
  Future<List<Property>> getPublicProperties({bool availableOnly});

  // =============================
  // 🔹 3. CRÉER UNE NOUVELLE PROPRIÉTÉ
  // =============================
  // Crée une nouvelle propriété en envoyant ses données.
  // 'data' est une Map contenant les champs de la nouvelle propriété.
  // Doit retourner un Future qui complète avec l'objet Property créé (souvent avec un nouvel ID).
  Future<Property> createProperty(Map<String, dynamic> data);

  // =============================
  // 🔹 4. POSTULER À UNE PROPRIÉTÉ (APPLY)
  // =============================
  Future<void> applyToProperty({required int propertyId, String? message});

  // =============================
  // 🔹 5. LISTER LES CANDIDATURES D’UNE PROPRIÉTÉ (BAILLEUR)
  // =============================
  Future<List<ApplicationModel>> getApplicationsForProperty({required int propertyId});

  // Accepter / Refuser une candidature
  Future<ApplicationModel> acceptApplication({required int applicationId});
  Future<ApplicationModel> rejectApplication({required int applicationId});

  // Créer un contrat depuis une candidature (MVP)
  Future<Map<String, dynamic>> createContractFromApplication({required int applicationId});
}