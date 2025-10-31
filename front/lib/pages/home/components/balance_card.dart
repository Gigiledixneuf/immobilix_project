import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // NÉCESSAIRE pour ConsumerWidget et WidgetRef

import '../../profile/profile_controller.dart';

// 1. CHANGER StatelessWidget pour ConsumerWidget
class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  // La signature de build est correcte pour ConsumerWidget
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    // On utilise une valeur vide si l'objet user ou fullName est null
    final userName = profileState.user?.fullName ?? 'Utilisateur';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            // 2. RETIRER le mot-clé const de Column et de sa liste children
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ // La liste des enfants ne doit plus être const
                const Text(
                  'Solde',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  '\$155,832.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // Utilisation de la variable userName pour afficher le nom
                      // J'ai remplacé 'SAMANTA JOHNS, ${user?.fullName ?? ''}!' par une version plus simple:
                      userName,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const Text(
                      '.... 3144',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}