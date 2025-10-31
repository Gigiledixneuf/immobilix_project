// Importation de la librairie 'dart:convert' pour l'encodage et le décodage JSON.
import 'dart:convert';

import '../../../business/models/gestion/property.dart';
import '../../../business/models/gestion/application.dart';
import '../../../business/services/gestion/propertyNetworkService.dart';
import '../../../utils/http/HttpUtils.dart';

// Implémentation concrète du service réseau pour les propriétés.
// Ce service communique avec l'API backend pour effectuer les opérations CRUD.
class PropertyNetworkServiceImpl extends PropertyNetworkService {
  final String baseUrl;   // URL de base de l’API (ex: http://localhost:3333)
  final HttpUtils httpUtils; // Classe utilitaire pour envoyer les requêtes HTTP

  PropertyNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  // =============================
  // 🔹 1. OBTENIR LES DÉTAILS D’UNE PROPRIÉTÉ
  // =============================
  @override
  Future<Property> getProperty(int id) async {
    // Effectue une requête GET pour récupérer les données d'une propriété spécifique.
    final response = await httpUtils.getData('$baseUrl/api/properties/$id');

    // Décodage des données JSON reçues.
    final data = jsonDecode(response);

    // Conversion du JSON en modèle Property.
    return Property.fromJson(data['data']);
  }

  // =============================
  // 🔹 2. RÉCUPÉRER TOUTES LES PROPRIÉTÉS
  // =============================
  @override
  Future<List<Property>> getProperties() async {
    // Envoie une requête GET pour récupérer toutes les propriétés
    final response = await httpUtils.getData('$baseUrl/api/properties');

    // Décodage du JSON obtenu
    final data = jsonDecode(response);
    final List<dynamic> propertiesJson = data['data'];

    // Conversion de chaque item JSON en modèle Property
    return propertiesJson.map((json) => Property.fromJson(json)).toList();
  }

  // Récupère les propriétés publiques (exposées aux visiteurs / locataires)
  @override
  Future<List<Property>> getPublicProperties({bool availableOnly = true}) async {
    // Appelle l'endpoint public, avec un paramètre optionnel "available"
    final response = await httpUtils.getData(
      '$baseUrl/api/public/properties',
      queryParams: availableOnly ? { 'available': 'true' } : null,
    );

    final data = jsonDecode(response);
    final List<dynamic> propertiesJson = data['data'];

    return propertiesJson.map((json) => Property.fromJson(json)).toList();
  }

  // =============================
  // 🔹 3. CRÉER UNE NOUVELLE PROPRIÉTÉ
  // =============================
  @override
  Future<Property> createProperty(Map<String, dynamic> propertyData) async {
    // Vérifie si une image locale a été fournie.
    // Si oui => utilisation d'un upload multipart.
    final String? imagePath = propertyData.remove('main_photo_local_path');

    String response;

    if (imagePath != null && imagePath.isNotEmpty) {
      // Envoi avec multipart pour gérer l’image
      response = await httpUtils.postMultipart(
        '$baseUrl/api/properties',
        fields: propertyData.map((k, v) => MapEntry(k, '$v')),
        files: { 'main_photo_url': imagePath },
      );
    } else {
      // Envoi classique JSON si pas d’image
      final r = await httpUtils.postData(
        '$baseUrl/api/properties',
        body: propertyData,
      );
      response = r;
    }

    // Traitement de la réponse JSON
    final data = jsonDecode(response);
    return Property.fromJson(data['data']);
  }

  // Soumettre une candidature pour une propriété
  @override
  Future<void> applyToProperty({required int propertyId, String? message}) async {
    // POST simple sans multipart
    await httpUtils.postData(
      '$baseUrl/api/properties/$propertyId/apply',
      body: { if (message != null) 'message': message },
    );
  }

  // Récupérer la liste des candidatures d’une propriété
  @override
  Future<List<ApplicationModel>> getApplicationsForProperty({required int propertyId}) async {
    final response = await httpUtils.getData('$baseUrl/api/properties/$propertyId/applications');

    final data = jsonDecode(response);
    final List<dynamic> items = data['data'];

    // Conversion JSON → Liste de modèles ApplicationModel
    return items.map((j) => ApplicationModel.fromJson(j)).toList();
  }

  // Accepter une candidature
  @override
  Future<ApplicationModel> acceptApplication({required int applicationId}) async {
    final response = await httpUtils.postData(
      '$baseUrl/api/applications/$applicationId/accept',
      body: {},
    );

    final data = jsonDecode(response);
    return ApplicationModel.fromJson(data['data']);
  }

  // Rejeter une candidature
  @override
  Future<ApplicationModel> rejectApplication({required int applicationId}) async {
    final response = await httpUtils.postData(
      '$baseUrl/api/applications/$applicationId/reject',
      body: {},
    );

    final data = jsonDecode(response);
    return ApplicationModel.fromJson(data['data']);
  }

  // Créer un contrat à partir d’une application acceptée
  @override
  Future<Map<String, dynamic>> createContractFromApplication({required int applicationId}) async {
    final response = await httpUtils.postData(
      '$baseUrl/api/applications/$applicationId/create-contract',
      body: {},
    );

    // Le backend renvoie probablement { success: true, data: {...} }
    final data = jsonDecode(response);
    return data;
  }
}
