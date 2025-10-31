import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../business/models/contrat/contrat.dart';
import 'package:immobilx/business/services/contrat/contrat_networt_service.dart';
import 'package:immobilx/main.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/utils/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:immobilx/pages/profile/profile_controller.dart';

// Fournit une instance de ContractNetworkService via l’injection de dépendances (getIt)
final contractServiceProvider = Provider<ContractNetworkService>((ref) => getIt<ContractNetworkService>());

// Provider pour charger la liste des contrats depuis le serveur
final contractListProvider = FutureProvider<List<Contract>>((ref) async {
  final contractService = ref.read(contractServiceProvider);
  return await contractService.getContracts();
});

// Page principale d’affichage des contrats
class ContractListPage extends ConsumerWidget {
  const ContractListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupère la liste des contrats (FutureProvider)
    final asyncContracts = ref.watch(contractListProvider);

    // Récupère les infos du profil utilisateur
    final profileState = ref.watch(profileControllerProvider);

    // Vérifie si l’utilisateur connecté est un bailleur
    final isLandlord = profileState.user?.roles?.any((role) => role.name == 'bailleur') ?? false;

    // Utilisation d’un Stack pour positionner manuellement le FloatingActionButton
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.darkBackgroundColor,
          appBar: AppBar(
            title: const Text('Mes Contrats', style: TextStyle(color: AppTheme.lightTextColor)),
            backgroundColor: AppTheme.darkBackgroundColor,
            iconTheme: const IconThemeData(color: AppTheme.lightTextColor),
          ),

          // Corps principal qui dépend de l’état de asyncContracts (loading, error, data)
          body: asyncContracts.when(
            // Affiche un loader pendant le chargement
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),

            // Affiche un message d’erreur si une exception survient
            error: (err, stack) => Center(
              child: Text('Erreur: $err', style: const TextStyle(color: AppTheme.warningColor)),
            ),

            // Affiche la liste des contrats si tout est chargé
            data: (contracts) {
              // Si la liste est vide, affiche un message informatif
              if (contracts.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun contrat trouvé.',
                    style: AppTheme.bodyStyle.copyWith(color: AppTheme.subtleTextColor),
                  ),
                );
              }

              // Liste des contrats avec un padding inférieur pour laisser la place au FAB
              return ListView.builder(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 100.0),
                itemCount: contracts.length,
                itemBuilder: (context, index) {
                  final contract = contracts[index];
                  return ContractCard(contract: contract); // Affiche chaque contrat sous forme de carte
                },
              );
            },
          ),
        ),

        // Bouton flottant pour créer un nouveau contrat (visible uniquement pour le bailleur)
        if (isLandlord)
          Positioned(
            bottom: 160.0, // Position au-dessus de la barre de navigation
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () => context.go('/app/contracts/new'), // Redirection vers la page de création
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}

// Widget pour afficher une carte représentant un contrat
class ContractCard extends StatelessWidget {
  final Contract contract;
  const ContractCard({Key? key, required this.contract}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy'); // Format des dates

    // Sécurise les champs nullables (propriété, locataire, dates)
    final propertyName = contract.property?.name ?? 'Propriété Inconnue';
    final tenantName = contract.tenant?.fullName ?? 'Locataire Inconnu';
    final startDateFormatted = contract.startDate != null ? formatter.format(contract.startDate!) : 'N/A';
    final endDateFormatted = contract.endDate != null ? formatter.format(contract.endDate!) : 'N/A';

    return GestureDetector(
      // Clic sur la carte → ouvre la page de détails du contrat
      onTap: () => context.go('/app/contracts/${contract.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: AppTheme.lightTextColor.withOpacity(0.08), // Fond semi-transparent
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)), // Bordure légère
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom de la propriété
              Text(
                propertyName,
                style: AppTheme.headingStyle.copyWith(color: AppTheme.lightTextColor, fontSize: 18),
              ),
              const SizedBox(height: 8),

              // Nom du locataire
              Text(
                'Locataire: $tenantName',
                style: AppTheme.bodyStyle.copyWith(color: AppTheme.subtleTextColor),
              ),
              const SizedBox(height: 8),

              // Ligne affichant le loyer et le statut du contrat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Montant du loyer
                  Text(
                    '${contract.rentAmount.toStringAsFixed(2)} ${contract.currency} / mois',
                    style: AppTheme.bodyStyle.copyWith(color: AppTheme.lightTextColor, fontWeight: FontWeight.bold),
                  ),

                  // Statut du contrat (actif / en attente / terminé)
                  Chip(
                    label: Text(
                      contract.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: contract.status == 'active'
                        ? AppTheme.successColor // Vert si actif
                        : AppTheme.warningColor, // Orange sinon
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Affiche les dates du contrat (début - fin)
              Text(
                'Début: $startDateFormatted - Fin: $endDateFormatted',
                style: AppTheme.bodyStyle.copyWith(color: AppTheme.subtleTextColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
