import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/business/models/contrat/contrat.dart';
import 'package:immobilx/business/models/gestion/payment.dart';
import 'package:immobilx/business/services/contrat/contrat_networt_service.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

final _contractsProvider = FutureProvider<List<Contract>>((ref) async {
  return GetIt.I<ContractNetworkService>().getContracts();
});

final _paymentsProvider = FutureProvider.family<List<Payment>, int>((ref, contractId) async {
  return GetIt.I<ContractNetworkService>().getContractPayments(contractId);
});

class TenantPaymentsPage extends ConsumerWidget {
  const TenantPaymentsPage({super.key});

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
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: contracts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final c = contracts[index];
            final isDepositDue = (c.depositStatus?.toLowerCase() ?? 'pending') == 'pending';
            return Card(
              color: AppTheme.darkPrimary,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.property.name, style: const TextStyle(color: AppTheme.lightTextColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Loyer: ${c.rentAmount.toStringAsFixed(2)} ${c.currency}', style: const TextStyle(color: AppTheme.subtleTextColor)),
                    const SizedBox(height: 12),
                    if (isDepositDue)
                      ElevatedButton(
                        onPressed: () {
                          context.pushNamed('payment_form_page', extra: c, pathParameters: {'id': c.id.toString()});
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: AppTheme.darkBackgroundColor),
                        child: Text('Payer dépôt (${(c.depositAmount ?? c.rentAmount).toStringAsFixed(2)} ${c.currency})'),
                      ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Payment>>(
                      future: ref.read(_paymentsProvider(c.id).future),
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox.shrink();
                        final pays = snap.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Historique', style: TextStyle(color: AppTheme.lightTextColor, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            if (pays.isEmpty)
                              const Text('Aucun paiement', style: TextStyle(color: AppTheme.subtleTextColor))
                            else
                              ...pays.map((p) => Text('- ${p.amount.toStringAsFixed(2)} ${p.currency} • ${p.status}', style: const TextStyle(color: AppTheme.subtleTextColor))),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}




