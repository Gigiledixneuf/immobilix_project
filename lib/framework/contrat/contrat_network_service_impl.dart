import 'dart:convert';
import 'package:immobilx/business/models/contrat/contrat.dart';
import 'package:immobilx/business/services/contrat/contrat_networt_service.dart';
import '../../business/models/gestion/payment.dart';
import '../../business/models/user/user.dart';
import '../../utils/http/HttpUtils.dart';

class ContratNetworkServiceImpl implements ContractNetworkService{
  final String baseUrl;
  final HttpUtils httpUtils;
  final String token;
  ContratNetworkServiceImpl({required this.baseUrl, required this.httpUtils, required this.token});

  // =============================
  // 🔹 1. RÉCUPÉRER TOUS LES CONTRATS
  // =============================
  @override
  Future<List<Contract>> getContracts() async {
    final response = await httpUtils.getData('$baseUrl/api/contracts');
    final data = jsonDecode(response);
    final List<dynamic> contractsJson = data['data'];
    return contractsJson.map((json) => Contract.fromJson(json)).toList();
  }
  // =============================
  // 🔹 2. OBTENIR LES DÉTAILS D’UN CONTRAT
  // =============================
  @override
  Future<Contract> getContractDetails(int id) async {
    final response = await httpUtils.getData('$baseUrl/api/contracts/$id');
    final data = jsonDecode(response);
    return Contract.fromJson(data['data']);
  }
  // =============================
  // 🔹 3. CRÉER UN NOUVEAU CONTRAT
  // =============================
  @override
  Future<Contract> createContract(Map<String, dynamic> contractData) async {
    final response = await httpUtils.postData(
      '$baseUrl/api/contracts',
      body: contractData,
    );
    final data = jsonDecode(response);
    return Contract.fromJson(data['data']);
  }

  // =============================
  // 🔹 4. METTRE À JOUR UN CONTRAT EXISTANT
  // =============================
  @override
  Future<Contract> updateContract(int id, Map<String, dynamic> contractData) async {
    final response = await httpUtils.putData(
      '$baseUrl/api/contracts/$id',
      body: contractData,
    );
    final data = jsonDecode(response);
    return Contract.fromJson(data['data']);
  }
  // =============================
  // 🔹 5. SUPPRIMER UN CONTRAT
  // =============================
  @override
  Future<void> deleteContract(int id) async {
    await httpUtils.deleteData('/contracts/$id');
  }
  // =============================
  // 🔹 6. RÉCUPÉRER LA LISTE DES LOCATAIRES
  // =============================
  @override
  Future<List<User>> getTenants() async {
    final response = await httpUtils.getData('$baseUrl/api/tenants');
    final data = jsonDecode(response);
    final List<dynamic> usersJson = data['data'];
    return usersJson.map((json) => User.fromJson(json)).toList();
  }
  // =============================
  // 🔹 7. EFFECTUER UN PAIEMENT
  // =============================
  @override
  Future<Payment> makePayment(Map<String, dynamic> paymentData) async {
    final response = await httpUtils.postData(
      '$baseUrl/api/payments',
      body: paymentData,
    );
    final data = jsonDecode(response);
    return Payment.fromJson(data['data']);
  }
  // =============================
  // 🔹 8. RÉCUPÉRER LES PAIEMENTS D’UN CONTRAT
  // =============================
  @override
  Future<List<Payment>> getContractPayments(int contractId) async {
    final response = await httpUtils.getData('$baseUrl/api/contracts/$contractId/payments');
    final data = jsonDecode(response);
    final List<dynamic> paymentsJson = data['data']['data'];
    return paymentsJson.map((json) => Payment.fromJson(json)).toList();
  }
}