import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immobilx/pages/home/transactions_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TransactionsList extends ConsumerWidget {
  const TransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mes Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {}, // Laisser pour plus tard
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Liste des transactions
        if (transactionsState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (transactionsState.errorMessage != null)
          Center(child: Text(transactionsState.errorMessage!))
        else if (transactionsState.payments.isEmpty)
            const Center(child: Text("Aucune transaction pour le moment."))
          else
            ListView.builder(
              shrinkWrap: true, // Important dans un Column
              physics: const NeverScrollableScrollPhysics(), // Pas de scroll interne
              itemCount: transactionsState.payments.length,
              itemBuilder: (context, index) {
                final payment = transactionsState.payments[index];
                return _buildTransactionItem(
                  icon: Icons.arrow_downward, // Tous les paiements sont entrants pour le locataire
                  color: AppTheme.successColor,
                  title: 'Paiement du loyer',
                  subtitle: DateFormat('d MMM y, HH:mm').format(payment.createdAt),
                  amount: '+ ${payment.amount.toStringAsFixed(2)} \$',
                );
              },
            ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.chipLabelColor : AppTheme.unselectedChipLabelColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isSelected ? AppTheme.chipBackgroundColor : AppTheme.unselectedChipColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
