import 'dart:ui'; // Pour appliquer des effets de flou sur le fond du BottomNavBar
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

// ✅ Liste des routes principales de l’application accessibles via la barre de navigation
const List<String> navRoutes = [
  '/app/home',
  '/app/contracts',
  '/app/transactions',
  '/app/stats',
  '/app/profile',
];

// ✅ Provider Riverpod pour suivre l’onglet actuellement sélectionné
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

// 🧱 AppShell : structure principale contenant le contenu (child) et la barre de navigation
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🧭 Observe la position actuelle dans la navigation (index de l’onglet sélectionné)
    final selectedIndex = ref.watch(selectedTabIndexProvider);

    // 🔁 Fonction exécutée quand un onglet est sélectionné
    void onTapped(int index) {
      if (selectedIndex != index) {
        // Met à jour l’onglet sélectionné
        ref.read(selectedTabIndexProvider.notifier).state = index;
        // Redirige l’utilisateur vers la route correspondante
        context.go(navRoutes[index]);
      }
    }

    return Scaffold(
      body: child, // Contenu principal de la page
      extendBody: true, // Permet au contenu de passer sous la BottomNavBar pour un effet visuel fluide
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onTapped: onTapped,
      ),
    );
  }
}

// 🎨 Composant personnalisé pour la barre de navigation inférieure
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    // 🔽 Récupère la marge inférieure du téléphone (notch, gestes, etc.)
    final double safeAreaPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      // Ajoute de l’espace autour de la barre (notamment en bas)
      padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0 + safeAreaPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30), // Coins arrondis
        child: BackdropFilter(
          // 💧 Effet de flou sur le fond (verre dépoli)
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.darkPrimary.withOpacity(0.8), // Couleur semi-transparente
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.1)), // Bordure subtile
            ),
            // 🔹 Organisation horizontale des icônes
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.pentagon_outlined,
                  index: 0,
                  isActive: selectedIndex == 0,
                  onTap: onTapped,
                ),
                _NavItem(
                  icon: Icons.article_outlined,
                  index: 1,
                  isActive: selectedIndex == 1,
                  onTap: onTapped,
                ),
                _NavItem(
                  icon: Icons.remove_red_eye_outlined,
                  index: 2,
                  isActive: selectedIndex == 2,
                  onTap: onTapped,
                ),
                _NavItem(
                  icon: Icons.bar_chart_sharp,
                  index: 3,
                  isActive: selectedIndex == 3,
                  onTap: onTapped,
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  index: 4,
                  isActive: selectedIndex == 4,
                  onTap: onTapped,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🔘 Élément individuel de la barre de navigation (icône + état actif/inactif)
class _NavItem extends StatelessWidget {
  final IconData icon; // L’icône à afficher
  final bool isActive; // Si l’onglet est actuellement sélectionné
  final int index; // Position de l’élément dans la barre
  final Function(int) onTap; // Fonction appelée lors du clic

  const _NavItem({
    required this.icon,
    required this.index,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 👆 Lorsqu'on clique sur l’icône
      onTap: () => onTap(index),
      child: SizedBox(
        width: 70, // Largeur fixe de chaque bouton
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône principale
            Icon(
              icon,
              color: isActive ? AppTheme.primaryBlue : Colors.white70, // Couleur différente si actif
              size: 28,
            ),
            // 🔵 Petit indicateur circulaire en dessous si actif
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
