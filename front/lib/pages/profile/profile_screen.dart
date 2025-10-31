import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/business/models/user/user.dart';
import 'package:immobilx/pages/intro/appCtrl.dart';
import 'package:immobilx/pages/profile/profile_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  // Utilisation d'une méthode de déconnexion stylisée pour s'intégrer au thème sombre
  Future<void> _showLogoutConfirmationDialog(BuildContext context, AppCtrl appController) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // Thème sombre pour la popup
          backgroundColor: AppTheme.darkBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

          title: const Text(
            'Confirmer la Déconnexion',
            style: TextStyle(color: AppTheme.lightTextColor),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter de votre compte ImmobiliX ?',
            style: TextStyle(color: AppTheme.subtleTextColor),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler', style: TextStyle(color: AppTheme.primaryColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                appController.logout(); // Procéder à la déconnexion
              },
              child: const Text('Se déconnecter', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final appController = ref.read(appCtrlProvider.notifier);

    return Scaffold(
      // Changement du fond en sombre
      backgroundColor: AppTheme.darkBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(color: AppTheme.lightTextColor, fontWeight: FontWeight.bold),
        ),
        // Rendre l'AppBar transparente pour se fondre dans le fond sombre
        backgroundColor: AppTheme.darkBackgroundColor,
        elevation: 0,
      ),

      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : profileState.error != null
          ? Center(
        child: Text(
          'Erreur: ${profileState.error}',
          style: const TextStyle(color: AppTheme.warningColor),
        ),
      )
          : profileState.user == null
          ? Center(child: Text('Aucune information utilisateur.', style: AppTheme.bodyStyle.copyWith(color: AppTheme.subtleTextColor)))
          : _buildProfileContent(context, profileState.user!, appController),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user, AppCtrl appController) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildProfileHeader(user),
        const SizedBox(height: 30),
        // Utilisation de la carte stylée (dark mode)
        _buildInfoCard(user),
        const SizedBox(height: 30),
        _buildActions(context, appController),
      ],
    );
  }

  Widget _buildProfileHeader(User user) {
    return Column(
      children: [
        // Avatar : utilise le primaryColor (bleu vif)
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primaryColor,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 10),
        // Texte en blanc
        Text(
          user.fullName ?? 'Nom non disponible',
          style: AppTheme.headingStyle.copyWith(fontSize: 24, color: AppTheme.lightTextColor),
        ),
        // Texte subtil
        Text(
          user.roles?.map((r) => r.name).join(', ') ?? 'Rôle non défini',
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.subtleTextColor),
        ),
      ],
    );
  }

  Widget _buildInfoCard(User user) {
    return Container(
      // Style de carte sombre et moderne
      decoration: BoxDecoration(
        color: AppTheme.lightTextColor.withOpacity(0.08), // Similaire à l'effet de verre
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', user.email),
          // Ligne de séparation subtile en blanc/gris
          Divider(color: AppTheme.lightTextColor.withOpacity(0.2)),
          _buildInfoRow(Icons.phone_outlined, 'Téléphone', user.portable),
          Divider(color: AppTheme.lightTextColor.withOpacity(0.2)),
          _buildInfoRow(Icons.calendar_today_outlined, 'Membre depuis', user.createdAt?.toString().substring(0, 10)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Icône en couleur subtile ou accent
          Icon(icon, color: AppTheme.subtleTextColor),
          const SizedBox(width: 16),
          // Label en blanc/clair
          Text(
              label,
              style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightTextColor
              )
          ),
          const Spacer(),
          // Valeur en blanc
          Text(value ?? 'Non défini', style: AppTheme.bodyStyle.copyWith(color: AppTheme.lightTextColor)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppCtrl appController) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            // Style de bouton primaire inchangé (Bleu vif sur fond sombre)
            style: AppTheme.primaryButtonStyle,
            onPressed: () {
              // Utilisation de goNamed pour la navigation au lieu du chemin brut
              context.goNamed('edit_profile_page');
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Modifier mon profil'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            // Style du bouton de déconnexion (contour rouge vif)
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent, // Texte en rouge clair
              side: const BorderSide(color: Colors.redAccent, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              _showLogoutConfirmationDialog(context, appController);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
          ),
        ),
      ],
    );
  }
}
