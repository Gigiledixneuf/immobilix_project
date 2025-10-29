import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/business/models/gestion/property.dart';
import 'package:immobilx/business/services/gestion/propertyNetworkService.dart';
import 'package:immobilx/main.dart';
import '../../utils/theme/app_theme.dart';

// Providers inchangés (assurez-vous que les dépendances sont correctes)
final propertyServiceProvider = Provider<PropertyNetworkService>((ref) => getIt<PropertyNetworkService>());

final propertyListProvider = FutureProvider<List<Property>>((ref) async {
  final propertyService = ref.read(propertyServiceProvider);
  await Future.delayed(const Duration(milliseconds: 500));
  return await propertyService.getProperties();
});

class PropertyManagementScreen extends ConsumerWidget {
  const PropertyManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProperties = ref.watch(propertyListProvider);

    // Utilisation de la couleur de fond sombre (darkBackgroundColor)
    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundColor,

      body: CustomScrollView(
        slivers: [
          // AppBar Personnalisée avec Bouton Retour (GoRouter)
          SliverAppBar(
            backgroundColor: AppTheme.darkBackgroundColor,
            floating: true,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppTheme.lightTextColor),
              onPressed: () {
                // Fonction de retour vers la page précédente (HomeScreen)
                context.goNamed('home_page');
              },
            ),
            title: const Text(
              'Mes Logements',
              style: TextStyle(
                color: AppTheme.lightTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: asyncProperties.when(
              // État de chargement
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              ),
              // État d'erreur
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: Text('Erreur: $err', style: const TextStyle(color: AppTheme.warningColor)),
                ),
              ),
              // Affichage des données
              data: (properties) {
                if (properties.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Aucun logement enregistré.',
                        style: AppTheme.bodyStyle.copyWith(color: AppTheme.subtleTextColor),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final property = properties[index];
                      // Utilisation de la carte stylée
                      return PropertyCard(property: property);
                    },
                    childCount: properties.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
// ----------------------------------------------------------------------
// Composant de Carte (PropertyCard) - Adapté au modèle existant
// ----------------------------------------------------------------------

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Utilisation du design sombre avec effet subtil
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.lightTextColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

        leading: const Icon(
          Icons.apartment,
          color: AppTheme.primaryColor,
          size: 30,
        ),

        title: Text(
          property.name,
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.lightTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          property.address,
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.subtleTextColor,
            fontSize: 14,
          ),
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // AFFICHAGE DU LOYER : Utilisation de property.price
            // Nous assumons la devise 'USDC' pour l'affichage, faute de champ 'currency'
            Text(
              '${property.price.toStringAsFixed(2)} USDC',
              style: AppTheme.headingStyle.copyWith(
                fontSize: 18,
                color: AppTheme.lightTextColor,
              ),
            ),
            // AFFICHAGE DES LOCATAIRES : Simulé (1 locataire)
            Text(
              '1 locataire assigné',
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 12,
                color: AppTheme.subtleTextColor,
              ),
            ),
          ],
        ),

        onTap: () {
          // Action lors du clic (détails du logement)
          // context.push('/property/${property.id}');
        },
      ),
    );
  }
}