import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/business/models/user/user.dart'; // Assurez-vous d'importer User
import 'package:immobilx/pages/intro/appCtrl.dart';
import 'package:immobilx/pages/profile/profile_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  // Méthode pour afficher la popup de confirmation
  Future<void> _showLogoutConfirmationDialog(BuildContext context, AppCtrl appController) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // L'utilisateur doit choisir une option
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fermer la popup
              },
            ),
            TextButton(
              child: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fermer la popup
                appController.logout(); // Procéder à la déconnexion
              },
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
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.error != null
          ? Center(
        child: Text(
          'Erreur: ${profileState.error}',
          style: const TextStyle(color: Colors.red),
        ),
      )
          : profileState.user == null
          ? const Center(child: Text('Aucune information utilisateur trouvée.'))
          : _buildProfileContent(context, profileState.user!, appController),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user, AppCtrl appController) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildProfileHeader(user),
        const SizedBox(height: 30),
        _buildInfoCard(user),
        const SizedBox(height: 30),
        _buildActions(context, appController),
      ],
    );
  }

  Widget _buildProfileHeader(User user) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primaryColor,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          user.fullName ?? 'Nom non disponible',
          style: AppTheme.headingStyle.copyWith(fontSize: 24),
        ),
        Text(
          user.roles?.map((r) => r.name).join(', ') ?? 'Rôle non défini',
          style: AppTheme.bodyStyle.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoCard(User user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.email_outlined, 'Email', user.email),
            const Divider(),
            _buildInfoRow(Icons.phone_outlined, 'Téléphone', user.portable),
            const Divider(),
            _buildInfoRow(Icons.calendar_today_outlined, 'Membre depuis', user.createdAt?.toString().substring(0, 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Text(label, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value ?? 'Non défini', style: AppTheme.bodyStyle),
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
            style: AppTheme.primaryButtonStyle,
            onPressed: () {
              context.go('/app/profile/edit');
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Modifier mon profil'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              // Appeler la méthode qui affiche la popup
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
