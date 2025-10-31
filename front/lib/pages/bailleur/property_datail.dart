import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/business/models/gestion/property.dart';
import 'package:immobilx/business/services/gestion/propertyNetworkService.dart';
import 'package:immobilx/main.dart';
import 'package:immobilx/utils/theme/app_theme.dart'; // Import pour le thème

// --- CONSTANTES MISES À JOUR ---
// ATTENTION : '10.0.2.2' est l'IP pour l'émulateur Android.
const String BASE_API_URL = 'http://localhost:3333';
const String PLACEHOLDER_IMAGE_URL = 'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg';
// ------------------------------

final propertyDetailsProvider = FutureProvider.family<Property, int>((ref, id) async {
  final propertyService = getIt<PropertyNetworkService>();
  return propertyService.getProperty(id);
});

class PropertyDetailsPage extends ConsumerWidget {
  final int propertyId;

  const PropertyDetailsPage({Key? key, required this.propertyId}) : super(key: key);

  // Widget utilitaire pour afficher les détails dans une carte stylisée
  Widget _buildDetailCard(BuildContext context, Property property) {
    // Style de la carte sombre et moderne
    final cardDecoration = BoxDecoration(
      color: AppTheme.lightTextColor.withOpacity(0.08), // Fond semi-transparent
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
    );

    // Fonction pour créer une ligne de détail stylisée
    Widget _buildDetailRow(IconData icon, String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodyStyle.copyWith(color: AppTheme.subtleTextColor),
              ),
            ),
            Text(
              value,
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.lightTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildDetailRow(Icons.apartment, 'Type', property.type),
          Divider(color: AppTheme.lightTextColor.withOpacity(0.1)),
          _buildDetailRow(Icons.square_foot, 'Surface', '${property.surface} m²'),
          Divider(color: AppTheme.lightTextColor.withOpacity(0.1)),
          _buildDetailRow(Icons.meeting_room, 'Pièces', property.rooms.toString()),
          Divider(color: AppTheme.lightTextColor.withOpacity(0.1)),
          _buildDetailRow(Icons.people, 'Capacité', property.capacity.toString()),
          Divider(color: AppTheme.lightTextColor.withOpacity(0.1)),
          _buildDetailRow(Icons.euro, 'Prix', '${property.price} €'),
        ],
      ),
    );
  }

  // Widget utilitaire pour les informations du bailleur
  Widget _buildLandlordInfo(BuildContext context, Property property) {
    if (property.user == null) return const SizedBox.shrink();

    // Style de la carte sombre et moderne pour le bailleur
    final cardDecoration = BoxDecoration(
      color: AppTheme.lightTextColor.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.subtleTextColor.withOpacity(0.2)),
    );

    // Style de ListTile adapté au dark mode
    Widget _buildContactTile(IconData icon, String? value) {
      if (value == null || value.isEmpty) return const SizedBox.shrink();
      return ListTile(
        leading: Icon(icon, color: AppTheme.subtleTextColor),
        title: Text(
          value,
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.lightTextColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Informations du bailleur',
          style: AppTheme.headingStyle.copyWith(fontSize: 20, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: cardDecoration,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactTile(Icons.person, property.user!.fullName),
              _buildContactTile(Icons.email, property.user!.email),
              _buildContactTile(Icons.phone, property.user!.portable),
            ],
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsyncValue = ref.watch(propertyDetailsProvider(propertyId));

    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundColor, // Fond sombre
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.lightTextColor),
          onPressed: () => context.goNamed('property_list_page'),
        ),
        title: Text(
          'Détails du logement',
          style: AppTheme.headingStyle.copyWith(fontSize: 20, color: AppTheme.lightTextColor),
        ),
      ),
      body: propertyAsyncValue.when(
        data: (property) {
          // 1. Déterminer l'URL de l'image
          final imageUrl = property.mainPhotoUrl != null
              ? '$BASE_API_URL/uploads/properties/${property.mainPhotoUrl}'
              : PLACEHOLDER_IMAGE_URL;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Afficher l'image avec un effet arrondi
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: AppTheme.darkBackgroundColor.withOpacity(0.5),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Si l'image échoue, on affiche une icône stylisée
                      return Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTextColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 60,
                            color: AppTheme.subtleTextColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Titre du logement
                Text(
                  property.name,
                  style: AppTheme.headingStyle.copyWith(fontSize: 28, color: AppTheme.lightTextColor),
                ),
                const SizedBox(height: 8),
                // Adresse
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${property.address}, ${property.city}',
                        style: AppTheme.bodyStyle.copyWith(color: AppTheme.subtleTextColor, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  property.description ?? 'Pas de description disponible.',
                  style: AppTheme.bodyStyle.copyWith(color: AppTheme.subtleTextColor, height: 1.5),
                ),
                const SizedBox(height: 24),

                // Carte d'informations (nouvelle implémentation stylisée)
                _buildDetailCard(context, property),

                // Informations du bailleur
                _buildLandlordInfo(context, property),

                // Espace pour le bouton de contact (à implémenter si nécessaire)
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Erreur lors du chargement des détails: $error',
              style: AppTheme.bodyStyle.copyWith(color: AppTheme.warningColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
