import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:immobilx/business/models/contrat/contrat.dart';
import 'package:immobilx/business/models/gestion/payment.dart';
import 'package:immobilx/business/services/contrat/contrat_networt_service.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

final _contractsProvider = FutureProvider<List<Contract>>((ref) async {
  return GetIt.I<ContractNetworkService>().getContracts();
});

class LandlordPaymentsPage extends ConsumerWidget {
  const LandlordPaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncContracts = ref.watch(_contractsProvider);
    return asyncContracts.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      error: (e, _) => Center(child: Text('Erreur: $e', style: const TextStyle(color: AppTheme.warningColor))),
      data: (contracts) {
        if (contracts.isEmpty) {
          return const Center(child: Text('Aucun contrat', style: TextStyle(color: AppTheme.subtleTextColor)));
        }
        // MVP: considérer en retard si depositStatus pending
        final overdue = contracts.where((c) => (c.depositStatus?.toLowerCase() ?? 'pending') == 'pending').toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('En retard', style: TextStyle(color: AppTheme.lightTextColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (overdue.isEmpty)
              const Text('Aucun', style: TextStyle(color: AppTheme.subtleTextColor))
            else
              ...overdue.map((c) => _ContractTile(contract: c)),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.darkBackgroundColor),
            const SizedBox(height: 16),
            const Text('Tous les contrats', style: TextStyle(color: AppTheme.lightTextColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...contracts.map((c) => _ContractTile(contract: c)),
          ],
        );
      },
    );
  }
}

class _ContractTile extends StatelessWidget {
  final Contract contract;
  const _ContractTile({required this.contract});

  @override
  Widget build(BuildContext context) {
    final isDepositPending = (contract.depositStatus?.toLowerCase() ?? 'pending') == 'pending';
    return Card(
      color: AppTheme.darkPrimary,
      child: ListTile(
        title: Text(contract.property.name, style: const TextStyle(color: AppTheme.lightTextColor, fontWeight: FontWeight.bold)),
        subtitle: Text('Locataire: ${contract.tenant.fullName}', style: const TextStyle(color: AppTheme.subtleTextColor)),
        trailing: Text(isDepositPending ? 'Dépôt en attente' : 'OK', style: TextStyle(color: isDepositPending ? AppTheme.warningColor : AppTheme.successColor)),
      ),
    );
  }
}




