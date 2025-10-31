import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business/models/gestion/payment.dart';
import 'package:immobilx/business/services/contrat/contrat_networt_service.dart';
import 'package:immobilx/main.dart';

import 'package:immobilx/business/models/contrat/contrat.dart';

// 1. État
class TransactionsState {
  final bool isLoading;
  final List<Payment> payments;
  final Contract? contract; // Ajout du contrat
  final String? errorMessage;

  TransactionsState({
    this.isLoading = false,
    this.payments = const [],
    this.contract,
    this.errorMessage,
  });

  TransactionsState copyWith({
    bool? isLoading,
    List<Payment>? payments,
    Contract? contract,
    String? errorMessage,
  }) {
    return TransactionsState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
      contract: contract ?? this.contract,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 2. Contrôleur (StateNotifier)
class TransactionsController extends StateNotifier<TransactionsState> {
  final ContractNetworkService _contractService;

  TransactionsController(this._contractService) : super(TransactionsState()) {
    fetchPaymentsForCurrentUser();
  }

  Future<void> fetchPaymentsForCurrentUser() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Pour un locataire, on récupère d'abord ses contrats
      final contracts = await _contractService.getContracts();

      if (contracts.isNotEmpty) {
        final currentContract = contracts.first;
        state = state.copyWith(contract: currentContract);

        final contractId = currentContract.id;
        if (contractId != null) {
          final payments = await _contractService.getContractPayments(contractId);
          state = state.copyWith(isLoading: false, payments: payments);
        } else {
          throw Exception("L'ID du contrat est nul.");
        }
      } else {
        // Pas de contrat, donc pas de paiement à afficher
        state = state.copyWith(isLoading: false, payments: [], contract: null);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Erreur lors de la récupération des transactions.");
      print(e); // Pour le débogage
    }
  }
}

// 3. Provider
final transactionsControllerProvider = StateNotifierProvider<TransactionsController, TransactionsState>((ref) {
  final contractService = getIt<ContractNetworkService>();
  return TransactionsController(contractService);
});
