import 'package:flutter/material.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list),
              label: const Text('Filtrer'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Onglets de filtre
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFilterChip('Tout', isSelected: true),
            _buildFilterChip('Paiements Reçus'),
            _buildFilterChip('Retraits'),
          ],
        ),
        const SizedBox(height: 20),
        // Liste des transactions
        _buildTransactionItem(
          icon: Icons.arrow_downward,
          color: AppTheme.successColor, // Utilisation du thème
          title: 'Loyer - Helen T.',
          subtitle: 'Aujourd\'hui, 08:09',
          amount: '+ \$500.00',
        ),
        _buildTransactionItem(
          icon: Icons.arrow_upward,
          color: AppTheme.warningColor, // Utilisation du thème
          title: 'Retrait Mobile Money',
          subtitle: 'Hier, 14:21',
          amount: '- \$1250.00',
        ),
        _buildTransactionItem(
          icon: Icons.arrow_downward,
          color: AppTheme.successColor, // Utilisation du thème
          title: 'Loyer - Mark R.',
          subtitle: '18 Oct, 11:30',
          amount: '+ \$720.00',
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
