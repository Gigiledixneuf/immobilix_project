import 'dart:convert';

import '../../business/models/user/user.dart';
import '../../business/services/user/userNetworkService.dart';
import '../../utils/http/HttpUtils.dart';
import '../utils/http/localHttpUtils.dart';

class UserNetworkServiceImpl extends UserNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  UserNetworkServiceImpl({required this.baseUrl, required this.httpUtils, required String token});

  @override
  Future<User> login(String email, String password) async {
    final response = await httpUtils.postData(
      '$baseUrl/api/login',
      body: {'email': email, 'password': password},
    );

    final data = jsonDecode(response);
    final userData = data['data']['user'];
    final token = data['data']['token'];

    userData['token'] = token;

    return User.fromJson(userData);
  }

  @override
  Future<User> register(String fullName, String email, String portable, String password, String passwordConfirmation) async {
    final response = await httpUtils.postData(
      '$baseUrl/api/register',
      body: {
        'full_name': fullName,
        'email': email,
        'portable': portable,
        'password': password,
        'password_confirmation': passwordConfirmation
      },
    );

    final data = jsonDecode(response);
    final userData = data['data']['user'];
    final token = data['data']['token'];

    userData['token'] = token;

    return User.fromJson(userData);
  }

  @override
  Future<User> getProfile() async {
    final response = await httpUtils.getData('$baseUrl/api/profile');
    final data = jsonDecode(response);
    // La réponse pour le profil ne contient pas de clé 'data', l'utilisateur est à la racine
    return User.fromJson(data);
  }

  @override
  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    final response = await httpUtils.putData(
      '$baseUrl/api/profile',
      body: profileData,
    );
    final data = jsonDecode(response);
    // La réponse de mise à jour contient un message et l'utilisateur mis à jour
    return User.fromJson(data['user']);
  }
}

void main() async {
  print('🚀 Démarrage du test AdonisJS (login ou register)...');

  final String adonisBaseUrl = 'http://192.168.1.68:3333';
  final HttpUtils httpUtilsInstance = LocalHttpUtils();

  final userNetworkService = UserNetworkServiceImpl(
    baseUrl: adonisBaseUrl,
    httpUtils: httpUtilsInstance,
    token: 'test_token',
  );

  // 🧪 Change cette variable pour tester login ou register
  const bool testRegister = true;

  if (testRegister) {
    // === Test du REGISTER ===
    const String testName = 'John Testeur';
    final String testEmail = 'john${DateTime.now().millisecondsSinceEpoch}@example.com';
    const String testPhone = '+243810000000';
    const String testPassword = 'password';
    const String confirmPassword = 'password';


    try {
      print('\n🧾 Tentative d\'inscription de $testEmail...');
      final user = await userNetworkService.register(testName, testEmail, testPhone, testPassword, confirmPassword);
      print('\n✅ Inscription réussie !');
      print('Utilisateur créé ID: ${user.id}, Email: ${user.email}, Token: ${user.token}');
    } catch (e) {
      print('\n❌ Échec de l\'inscription. Erreur: $e');
    }

  } else {
    // === Test du LOGIN ===
    const String testEmail = 'bailleur2@example.com';
    const String testPassword = 'password';

    try {
      print('\nTentative de connexion à $adonisBaseUrl/api/login pour $testEmail...');
      final user = await userNetworkService.login(testEmail, testPassword);
      print('\n✅ Connexion réussie !');
      print('Utilisateur connecté ID: ${user.id}, Email: ${user.email}');
    } catch (e) {
      print('\n❌ Échec de la connexion. Erreur: $e');
    }
  }
}
