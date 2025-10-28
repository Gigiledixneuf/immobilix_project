import 'package:flutter/material.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class TenantsSection extends StatelessWidget {
  const TenantsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildTenantAvatar('Mark R.', 'https://randomuser.me/api/portraits/men/32.jpg'),
              _buildTenantAvatar('Kris', 'https://randomuser.me/api/portraits/men/33.jpg'),
              _buildTenantAvatar('Helen T.', 'https://randomuser.me/api/portraits/women/32.jpg'),
              _buildTenantAvatar('Tony Gym', 'https://randomuser.me/api/portraits/men/34.jpg'),
              _buildAddButton(),
            ],
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
