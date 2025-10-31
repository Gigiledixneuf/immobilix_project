import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Pour la gestion d’état avec Riverpod
import 'package:immobilx/business/services/contrat/contrat_networt_service.dart'; // Service réseau des contrats
import 'package:immobilx/main.dart'; // Contient probablement le getIt (injection de dépendances)
import 'package:immobilx/pages/profile/profile_controller.dart'; // Contrôleur du profil utilisateur
import 'package:immobilx/utils/theme/app_theme.dart'; // Thèmes de l’application
import 'package:go_router/go_router.dart'; // Pour la navigation entre les pages
import '../../../business/models/contrat/contrat.dart'; // Modèle Contract
import '../../../business/models/gestion/payment.dart'; // Modèle Payment
import 'contract_list_page.dart'; // Page de la liste des contrats
import 'package:intl/intl.dart'; // Pour le formatage des dates

// =============================
// 🔹 PROVIDERS (pour charger les données via Riverpod)
// =============================

// Provider pour récupérer les détails d’un contrat spécifique à partir de son ID
final contractDetailsProvider = FutureProvider.family<Contract, int>((ref, id) async {
  final contractService = getIt<ContractNetworkService>(); // Injection du service réseau
  return contractService.getContractDetails(id); // Appel API
});

// Provider pour récupérer la liste des paiements liés à un contrat
final contractPaymentsProvider = FutureProvider.family<List<Payment>, int>((ref, id) async {
  final contractService = getIt<ContractNetworkService>();
  return contractService.getContractPayments(id);
});

// =============================
// 🔹 WIDGET PRINCIPAL : ContractDetailsPage
// =============================
class ContractDetailsPage extends ConsumerWidget {
  final int contractId; // ID du contrat dont on veut voir les détails

  const ContractDetailsPage({Key? key, required this.contractId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observation du provider des détails de contrat
    final asyncContract = ref.watch(contractDetailsProvider(contractId));

    // Récupération du profil utilisateur pour savoir s’il est bailleur ou locataire
    final profileState = ref.watch(profileControllerProvider);
    final user = profileState.user;
    final isLandlord = user?.roles?.any((role) => role.name == 'bailleur') ?? false;

    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundColor,
      appBar: AppBar(
        title: const Text('Détails du Contrat', style: TextStyle(color: AppTheme.lightTextColor)),
        backgroundColor: AppTheme.darkBackgroundColor,
        iconTheme: const IconThemeData(color: AppTheme.lightTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.lightTextColor),
          onPressed: () => context.goNamed('contracts_list_page'),
        ),
      ),

      // =============================
      // 🔹 Gestion des 3 états du FutureProvider (loading / error / data)
      // =============================
      body: asyncContract.when(
        // En cours de chargement
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),

        // En cas d’erreur
        error: (err, stack) => Center(
          child: Text('Erreur: $err', style: const TextStyle(color: AppTheme.warningColor)),
        ),

        // Une fois les données chargées
        data: (contract) {
          // Vérifie si l’utilisateur connecté est le propriétaire de la propriété liée au contrat
          final isOwner = isLandlord && contract.property.userId == user?.id;

          // =============================
          // 🔹 Corps principal : détails du contrat
          // =============================
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // --- Informations sur la propriété ---
                _buildSectionTitle('Informations sur la Propriété'),
                _buildDetailRow('Propriété:', contract.property.name),
                _buildDetailRow('Adresse:', '${contract.property.address}, ${contract.property.city}'),

                const SizedBox(height: 16),

                // --- Informations sur le locataire ---
                _buildSectionTitle('Informations sur le Locataire'),
                _buildDetailRow('Nom:', contract.tenant.fullName ?? 'N/A'),
                _buildDetailRow('Email:', contract.tenant.email ?? 'N/A'),
                _buildDetailRow('Téléphone:', contract.tenant.portable ?? 'N/A'),

                const SizedBox(height: 16),

                // --- Conditions du contrat ---
                _buildSectionTitle('Conditions du Contrat'),
                _buildDetailRow('Loyer Mensuel:', '${contract.rentAmount.toStringAsFixed(2)} ${contract.currency}'),
                _buildDetailRow(
                  'Statut:',
                  contract.status,
                  chipColor: contract.status == 'active'
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                ),
                _buildDetailRow('Date de début:', DateFormat('dd/MM/yyyy').format(contract.startDate)),
                _buildDetailRow(
                  'Date de fin:',
                  contract.endDate != null ? DateFormat('dd/MM/yyyy').format(contract.endDate!) : 'N/A',
                ),

                // --- Bouton de paiement pour le locataire ---
                if (user?.id == contract.tenantId.toString())
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Redirection vers la page de paiement
                          context.go('/app/contracts/${contract.id}/pay', extra: contract);
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Effectuer un Paiement'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // --- Détails du dépôt de garantie ---
                _buildSectionTitle('Dépôt de Garantie'),
                _buildDetailRow('Mois de dépôt:', contract.depositMonths.toString()),
                _buildDetailRow(
                  'Montant du dépôt:',
                  contract.depositAmount != null
                      ? '${contract.depositAmount!.toStringAsFixed(2)} ${contract.currency}'
                      : 'N/A',
                ),
                _buildDetailRow(
                  'Statut du dépôt:',
                  contract.depositStatus,
                  chipColor: contract.depositStatus == 'paid'
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                ),

                const SizedBox(height: 16),

                // --- Historique des paiements ---
                _buildSectionTitle('Historique des Paiements'),
                Consumer(
                  builder: (context, ref, child) {
                    final asyncPayments = ref.watch(contractPaymentsProvider(contractId));
                    return asyncPayments.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Erreur: $err'),
                      data: (payments) {
                        if (payments.isEmpty) {
                          return const Text('Aucun paiement enregistré.', style: TextStyle(color: AppTheme.subtleTextColor));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            final payment = payments[index];
                            return ListTile(
                              title: Text(
                                '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
                                style: const TextStyle(color: AppTheme.lightTextColor),
                              ),
                              subtitle: Text(
                                DateFormat('dd/MM/yyyy').format(payment.createdAt),
                                style: const TextStyle(color: AppTheme.subtleTextColor),
                              ),
                              trailing: Chip(
                                label: Text(payment.status, style: const TextStyle(color: Colors.white)),
                                backgroundColor: payment.status == 'PAID'
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                // --- Description du contrat ---
                if (contract.description != null && contract.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionTitle('Description'),
                  Text(
                    contract.description!,
                    style: AppTheme.bodyStyle.copyWith(color: AppTheme.lightTextColor),
                  ),
                ],

                // --- Boutons Modifier / Supprimer (pour le propriétaire uniquement) ---
                if (isOwner) ...[
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton Modifier
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/app/contracts/${contract.id}/edit', extra: contract);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                      ),

                      // Bouton Supprimer
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Confirmation avant suppression
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmer la suppression'),
                              content: const Text('Êtes-vous sûr de vouloir supprimer ce contrat ?'),
                              actions: [
                                TextButton(onPressed: () => context.pop(false), child: const Text('Annuler')),
                                TextButton(onPressed: () => context.pop(true), child: const Text('Supprimer')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              // Suppression du contrat
                              await getIt<ContractNetworkService>().deleteContract(contract.id);
                              ref.refresh(contractListProvider); // Actualise la liste
                              context.pop(); // Retour à la page précédente
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Supprimer'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningColor),
                      ),
                    ],
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  // =============================
  // 🔹 MÉTHODES UTILITAIRES D’AFFICHAGE
  // =============================

  // Titre de section stylisé
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.headingStyle.copyWith(color: AppTheme.primaryColor, fontSize: 20),
    );
  }

  // Ligne d’information avec possibilité d’afficher un badge (Chip)
  Widget _buildDetailRow(String label, String value, {Color? chipColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyStyle.copyWith(color: AppTheme.subtleTextColor)),
          if (chipColor != null)
            Chip(
              label: Text(value, style: const TextStyle(color: Colors.white)),
              backgroundColor: chipColor,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
            )
          else
            Text(
              value,
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.lightTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
