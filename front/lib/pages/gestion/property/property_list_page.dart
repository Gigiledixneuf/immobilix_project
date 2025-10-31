import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/business/models/gestion/property.dart';
import 'package:immobilx/business/services/gestion/propertyNetworkService.dart';
import 'package:immobilx/main.dart';
import 'package:immobilx/pages/home/components/property_summary_card.dart';
import 'package:immobilx/pages/profile/profile_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

// Provider pour le service des propriétés
final propertyServiceProvider = Provider<PropertyNetworkService>((ref) => getIt<PropertyNetworkService>());

// Provider pour récupérer la liste des propriétés du bailleur
final propertyListProvider = FutureProvider.autoDispose<List<Property>>((ref) async {
  final propertyService = ref.read(propertyServiceProvider);
  return await propertyService.getProperties();
});

// Provider pour récupérer les propriétés disponibles publiquement (affichage côté locataire)
final publicAvailablePropertiesProvider = FutureProvider.autoDispose<List<Property>>((ref) async {
  final propertyService = ref.read(propertyServiceProvider);
  return await propertyService.getPublicProperties(availableOnly: true);
});


class PropertyListPage extends ConsumerWidget {
  const PropertyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final isLandlord = profileState.user?.roles?.any((role) => role.name == 'bailleur') ?? false;

    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundColor,
      appBar: AppBar(
        title: Text(
          isLandlord ? 'Mes Biens' : 'Mon Logement',
          style: AppTheme.headingStyle.copyWith(fontSize: 20, color: AppTheme.lightTextColor),
        ),
        backgroundColor: AppTheme.darkBackgroundColor,
        elevation: 0,
      ),
      body: isLandlord ? _buildLandlordView(context, ref) : _buildTenantView(context, ref),
    );
  }

  // --- Vue pour le Bailleur ---
  Widget _buildLandlordView(BuildContext context, WidgetRef ref) {
    final asyncProperties = ref.watch(propertyListProvider);

    return asyncProperties.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      error: (err, stack) => Center(child: Text('Erreur: $err', style: const TextStyle(color: AppTheme.warningColor))),
      data: (properties) {
        if (properties.isEmpty) {
          return const Center(child: Text('Vous n\'avez encore ajouté aucun bien.', style: TextStyle(color: AppTheme.lightTextColor)));
        }
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                // Utilisation de la nouvelle carte pour une meilleure disposition
                return _PropertyCard(property: properties[index]);
              },
            ),
            // Bouton Flottant (légèrement ajusté pour le style)
            Positioned(
              right: 16,
              bottom: 160, // Déplacé plus bas pour ne pas être trop près du bord de la navigation
              child: FloatingActionButton.extended(
                backgroundColor: AppTheme.primaryColor,
                onPressed: () {
                  // Le nom de la route 'add_property_page' est utilisé selon le contexte des fichiers précédents
                  context.goNamed('add_property_page');
                },
                label: const Text(
                  'Ajouter un bien',
                  style: TextStyle(
                    color: AppTheme.lightTextColor, // Texte en blanc pour contraste sur primaryColor
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: const Icon(Icons.add_home_outlined,
                  color: AppTheme.chipLabelColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Vue pour le Locataire (inchangée) ---
  Widget _buildTenantView(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Mon logement'),
              Tab(text: 'Disponibles'),
            ],
            labelColor: AppTheme.lightTextColor,
            indicatorColor: AppTheme.primaryBlue,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                // Onglet 1: résumé du logement du locataire
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: PropertySummaryCard(),
                ),
                // Onglet 2: liste des logements disponibles
                const _AvailablePropertiesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Carte repensée pour afficher clairement les informations et les actions
class _PropertyCard extends StatelessWidget {
  final Property property;
  const _PropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.darkPrimary,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.go('/app/properties/${property.id}'); // Action principale : détails
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne 1: Nom et Loyer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      property.name,
                      style: AppTheme.bodyStyle.copyWith(color: AppTheme.lightTextColor, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis, // Empêche le débordement horizontal
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${property.price.toStringAsFixed(2)} \$ / mois',
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Ligne 2: Adresse et type
              Text(
                '${property.address} | ${property.city}',
                style: const TextStyle(color: AppTheme.subtleTextColor, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Ligne 3: Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Bouton Détails
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () {
                      context.push('/app/properties/${property.id}');
                    },
                    child: const Text('Détails'),
                  ),
                  const SizedBox(width: 8),

                  // Bouton Candidatures
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue, // Couleur d'action secondaire
                      foregroundColor: AppTheme.lightTextColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      context.push('/app/properties/${property.id}/applications');
                    },
                    child: const Text('Candidatures'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailablePropertiesTab extends ConsumerWidget {
  const _AvailablePropertiesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAvailable = ref.watch(publicAvailablePropertiesProvider);
    final propertyService = ref.read(propertyServiceProvider);

    return asyncAvailable.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      error: (err, _) => Center(
        child: Text('Erreur: $err', style: const TextStyle(color: AppTheme.warningColor)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text('Aucun logement disponible', style: TextStyle(color: AppTheme.lightTextColor)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final p = items[index];
            return Card(
              color: AppTheme.darkPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () {
                  // Action sur le tap pour voir les détails si la route existe
                  context.push('/app/properties/${p.id}');
                },
                title: Text(p.name, style: const TextStyle(color: AppTheme.lightTextColor, fontWeight: FontWeight.bold)),
                subtitle: Text('${p.city} • ${p.price.toStringAsFixed(2)} \$', style: const TextStyle(color: AppTheme.subtleTextColor)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.darkBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () async {
                    try {
                      // FIX: Conversion de String vers int pour propertyId
                      final propertyIdInt = int.parse(p.id);
                      await propertyService.applyToProperty(propertyId: propertyIdInt);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Candidature envoyée avec succès !'), backgroundColor: AppTheme.successColor),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: Impossible de postuler ($e)', maxLines: 2), backgroundColor: AppTheme.warningColor),
                        );
                      }
                    }
                  },
                  child: const Text('Postuler'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
