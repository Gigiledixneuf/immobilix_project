import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class ActionButtons extends StatelessWidget {
  final bool isLandlord;
  const ActionButtons({super.key, required this.isLandlord});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(context, icon: Icons.add, label: 'Déposer'),
        _buildActionButton(context, icon: Icons.arrow_upward, label: 'Envoyer'),
        if (isLandlord)
          _buildActionButton(context,
              icon: Icons.house,
              label: 'Mes Biens',
              onTap: () => context.go('/app/bailleur/properties')),
        _buildActionButton(context, icon: Icons.more_horiz, label: 'Plus'),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon, required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTextColor // Défini pour le texte
              )),
        ],
      ),
    );
  }
}