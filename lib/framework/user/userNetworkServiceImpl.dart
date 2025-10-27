import 'dart:convert';

import '../../business/models/user/authentication.dart';
import '../../business/models/user/user.dart';
import '../../business/services/user/userNetworkService.dart';
import '../../utils/http/HttpUtils.dart';
import '../utils/http/localHttpUtils.dart';

class UserNetworkServiceImpl extends UserNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  UserNetworkServiceImpl({required this.baseUrl, required this.httpUtils, required String token});

  @override
  Future<User> recupererInfoUtilisateur() {
    // TODO: implement recupererInfoUtilisateur
    throw UnimplementedError();
  }

  @override
  Future<User> login(String email, String password) async {
    // 1. Utilisation de postData comme défini dans HttpUtils
    final response = await httpUtils.postData(
      '$baseUrl/api/login',
      body: {'email': email, 'password': password},
    );

    // 2. Décodage de la réponse JSON (qui est une chaîne de caractères)
    final data = jsonDecode(response);

    // 3. Extraction des données de l'utilisateur et du token
    final userData = data['data']['user'];
    final token = data['data']['token'];

    // 4. Ajout du token aux données de l'utilisateur avant de créer l'objet User
    //    Ceci permet de conserver le token avec l'utilisateur.
    userData['token'] = token;

    // 5. Création et retour de l'objet User
    return User.fromJson(userData);
  }

  @override
  Future<User> register(String fullName, String email, String portable, String password, String passwordConfirmation) async {
    // 1. Utilisation de postData
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

    // 2. Décodage de la réponse JSON
    final data = jsonDecode(response);

    // 3. Extraction des données de l'utilisateur et du token
    final userData = data['data']['user'];
    final token = data['data']['token'];

    // 4. Ajout du token aux données de l'utilisateur
    userData['token'] = token;

    // 5. Création et retour de l'objet User
    return User.fromJson(userData);
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
