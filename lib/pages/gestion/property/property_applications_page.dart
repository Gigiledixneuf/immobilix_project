import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:immobilx/business/models/gestion/application.dart';
import 'package:immobilx/business/services/gestion/propertyNetworkService.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

final _serviceProvider = Provider<PropertyNetworkService>((ref) => GetIt.I<PropertyNetworkService>());

final applicationsProvider = FutureProvider.family<List<ApplicationModel>, int>((ref, propertyId) async {
  final s = ref.read(_serviceProvider);
  // Assurez-vous que l'appel API est fait pour l'ID entier
  return s.getApplicationsForProperty(propertyId: propertyId);
});

class PropertyApplicationsPage extends ConsumerWidget {
  final int propertyId;
  const PropertyApplicationsPage({super.key, required this.propertyId});

  // Fonction utilitaire pour obtenir la couleur du statut
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.warningColor;
      case 'pending':
      default:
        return AppTheme.primaryBlue;
    }
  }

  // Fonction pour gérer les actions et invalider le provider
  void _handleAction(BuildContext context, WidgetRef ref, Future<void> action, String successMessage) async {
    try {
      await action;
      // Invalider le provider pour forcer le rafraîchissement des données
      ref.invalidate(applicationsProvider(propertyId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: AppTheme.successColor),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.warningColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncApps = ref.watch(applicationsProvider(propertyId));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Candidatures',
          style: AppTheme.headingStyle.copyWith(fontSize: 20, color: AppTheme.lightTextColor),
        ),
        backgroundColor: AppTheme.darkBackgroundColor,
        elevation: 0,
      ),
      backgroundColor: AppTheme.darkBackgroundColor,
      body: asyncApps.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(
          child: Text('Erreur: $e', style: const TextStyle(color: AppTheme.warningColor)),
        ),
        data: (apps) {
          if (apps.isEmpty) {
            return const Center(
              child: Text('Aucune candidature pour ce logement', style: TextStyle(color: AppTheme.subtleTextColor)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final a = apps[index];

              // Assurez-vous que l'ID est un entier avant de l'utiliser dans l'action
              final applicationIdInt = int.tryParse(a.id) ?? 0;
              final isPending = a.status.toLowerCase() == 'pending';

              return Card(
                color: AppTheme.darkPrimary,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ligne 1: Nom du locataire et Statut (Chip)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            a.tenant?.fullName ?? 'Locataire #${a.tenantId}',
                            style: AppTheme.bodyStyle.copyWith(color: AppTheme.lightTextColor, fontWeight: FontWeight.bold),
                          ),
                          Chip(
                            label: Text(
                              a.status.toUpperCase(),
                              style: TextStyle(
                                color: AppTheme.darkBackgroundColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: _getStatusColor(a.status),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Ligne 2: Message/Description
                      if (a.message != null && a.message!.isNotEmpty)
                        Text(
                          a.message!,
                          style: const TextStyle(color: AppTheme.subtleTextColor, fontStyle: FontStyle.italic),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.darkBackgroundColor, height: 1),
                      const SizedBox(height: 16),

                      // Ligne 3: Actions (Centrées et stylisées)
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: [
                          if (isPending)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text('Accepter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor,
                                foregroundColor: AppTheme.darkBackgroundColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _handleAction(
                                  context,
                                  ref,
                                  ref.read(_serviceProvider).acceptApplication(applicationId: applicationIdInt),
                                  'Candidature acceptée !'
                              ),
                            ),

                          if (isPending)
                            OutlinedButton.icon(
                              icon: const Icon(Icons.close),
                              label: const Text('Refuser'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.warningColor,
                                side: const BorderSide(color: AppTheme.warningColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _handleAction(
                                  context,
                                  ref,
                                  ref.read(_serviceProvider).rejectApplication(applicationId: applicationIdInt),
                                  'Candidature refusée.'
                              ),
                            ),

                          // Bouton Créer contrat (toujours disponible, mais plus foncé pour être moins prioritaire)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('Créer contrat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: AppTheme.darkBackgroundColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _handleAction(
                                context,
                                ref,
                                ref.read(_serviceProvider).createContractFromApplication(applicationId: applicationIdInt),
                                'Contrat créé à partir de la candidature.'
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
