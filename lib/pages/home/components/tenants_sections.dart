import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immobilx/pages/home/tenants_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class TenantsSection extends ConsumerWidget {
  const TenantsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsState = ref.watch(tenantsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mes Locataires',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: tenantsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : tenantsState.errorMessage != null
              ? Center(child: Text(tenantsState.errorMessage!))
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tenantsState.tenants.length + 1, // +1 pour le bouton ajouter
            itemBuilder: (context, index) {
              if (index == tenantsState.tenants.length) {
                return _buildAddButton();
              }
              final tenant = tenantsState.tenants[index];
              // L'image de l'utilisateur ou une image par défaut
              final imageUrl = tenant.mainPhotoUrl ?? 'https://www.gravatar.com/avatar/?d=mp';
              return _buildTenantAvatar(tenant.fullName ?? 'N/A', imageUrl);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTenantAvatar(String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.lightOrange, // Utilisation du thème
          child: Icon(Icons.add, color: AppTheme.accentOrange, size: 30),
        ),
        const SizedBox(height: 8),
        const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
