import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immobilx/utils/theme/app_theme.dart';
// Importez votre contrôleur pour les données réelles
// import 'package:immobilx/pages/home/transactions_controller.dart';

class NextPaymentCard extends ConsumerWidget {
  const NextPaymentCard({super.key});

  // Simulation des données de paiement
  // Ceci devrait être remplacé par un appel à un provider Riverpod
  final double nextRentAmount = 1100.00;
  final String nextDueDate = '1er Nov. 2025'; // Date formatée réelle

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si vous aviez un provider, vous le liriez ici:
    // final nextPaymentData = ref.watch(nextPaymentProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Utilisation d'un dégradé plus clair pour la mise en avant
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.9), // Couleur principale
              AppTheme.primaryBlue.withOpacity(0.8),  // Couleur secondaire
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          // Effet de flou retiré pour le moment, le dégradé suffit
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              const Text(
                'Prochain Loyer Dû',
                style: TextStyle(color: AppTheme.lightTextColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),

              // Montant et Échéance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Montant
                  Text(
                    '${nextRentAmount.toStringAsFixed(2)} \$',
                    style: const TextStyle(
                      color: AppTheme.lightTextColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  // Échéance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Échéance:',
                        style: TextStyle(color: AppTheme.subtleTextColor, fontSize: 12),
                      ),
                      Text(
                        nextDueDate,
                        style: TextStyle(
                          color: AppTheme.lightTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bouton Payer maintenant (CTA)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter la logique de navigation vers la page de paiement
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Accès à la page de paiement...')),
                    );
                  },
                  icon: const Icon(Icons.payment, color: AppTheme.darkBackgroundColor),
                  label: const Text(
                    'Payer maintenant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkBackgroundColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange, // Bouton orange vif
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
