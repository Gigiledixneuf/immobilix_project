import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/pages/home/transactions_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class PropertySummaryCard extends ConsumerWidget {
  const PropertySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Supposons que transactionsControllerProvider soit le bon chemin
    final contract = ref.watch(transactionsControllerProvider).contract;

    if (contract == null || contract.property == null) {
      // Afficher un message si le locataire n'a pas encore de contrat/logement
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text(
            "Aucun logement lié à votre profil pour le moment.",
            style: TextStyle(color: AppTheme.subtleTextColor),
          ),
        ),
      );
    }
    final property = contract.property!;

    return GestureDetector(
      onTap: () {
        context.go('/app/properties/${property.id}');
      },
      child: Card(
        // 1. Fond sombre
        color: AppTheme.darkPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // S'assure que la colonne prend le moins d'espace possible
            children: [
              // Titre de la carte
              Text(
                "Votre Logement Actuel",
                style: AppTheme.headingStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // Nom du Bien
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.apartment, color: AppTheme.subtleTextColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.name,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.lightTextColor),
                        ),
                        const SizedBox(height: 4),
                        // Adresse
                        Text(
                          '${property.address}, ${property.city}',
                          style: TextStyle(fontSize: 14, color: AppTheme.subtleTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Divider(color: AppTheme.subtleTextColor, height: 1),
              const SizedBox(height: 16),

              // 3. Mise en valeur du loyer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.darkBackgroundColor, // Fond plus sombre pour le loyer
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Loyer Mensuel",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTextColor,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "${property.price.toStringAsFixed(2)} \$",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
