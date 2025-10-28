import 'package:flutter/material.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(icon: Icons.add, label: 'Déposer'),
        _buildActionButton(icon: Icons.arrow_upward, label: 'Envoyer'),
        _buildActionButton(icon: Icons.more_horiz, label: 'Plus'),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Le fond du cercle reste en primaryColor.withOpacity(0.1)
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          // 💡 MISE À JOUR : L'icône utilise maintenant lightTextColor (Blanc)
          child: Icon(icon, color: AppTheme.lightTextColor, size: 28),
        ),
        const SizedBox(height: 8),
        // Le texte utilise déjà lightTextColor (Blanc) d'après la correction précédente
        Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTextColor // Défini pour le texte
            )
        ),
      ],
    );
  }
}