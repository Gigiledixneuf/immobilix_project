import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immobilx/business/models/user/user.dart';
import 'package:immobilx/business/services/contrat/contrat_networt_service.dart';
import 'package:immobilx/main.dart';

// 1. Définir l'état pour le contrôleur des locataires
class TenantsState {
  final bool isLoading;
  final List<User> tenants;
  final String? errorMessage;

  TenantsState({
    this.isLoading = false,
    this.tenants = const [],
    this.errorMessage,
  });

  TenantsState copyWith({
    bool? isLoading,
    List<User>? tenants,
    String? errorMessage,
  }) {
    return TenantsState(
      isLoading: isLoading ?? this.isLoading,
      tenants: tenants ?? this.tenants,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 2. Créer le StateNotifier pour gérer la logique
class TenantsController extends StateNotifier<TenantsState> {
  final ContractNetworkService _contractNetworkService;

  TenantsController(this._contractNetworkService) : super(TenantsState()) {
    fetchTenants();
  }

  Future<void> fetchTenants() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tenants = await _contractNetworkService.getTenants();
      state = state.copyWith(isLoading: false, tenants: tenants);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Erreur lors de la récupération des locataires.");
      // Gérer l'erreur, par exemple en loggant
      print(e);
    }
  }
}

// 3. Créer le Provider pour exposer le contrôleur
final tenantsControllerProvider = StateNotifierProvider<TenantsController, TenantsState>((ref) {
  final contractService = getIt<ContractNetworkService>();
  return TenantsController(contractService);
});
