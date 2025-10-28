import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/pages/home/components/action_buttons.dart';
import 'package:immobilx/pages/home/components/balance_card.dart';
import 'package:immobilx/pages/home/components/tenants_sections.dart';
import 'package:immobilx/pages/home/components/transactions_list.dart';
import 'package:immobilx/pages/profile/profile_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

// Définir les routes de la barre de navigation
// ⚠️ ASSUREZ-VOUS QUE CES ROUTES EXISTENT DANS VOTRE CONFIGURATION GO_ROUTER
const List<String> navRoutes = [
  '/app/home',       // 0: Accueil (Home)
  '/app/transactions', // 1: Transactions (Exemple)
  '/app/stats',        // 2: Statistiques (Exemple)
  '/app/profile',      // 3: Profil (Exemple)
];

// Créer un provider pour gérer l'index actif de la barre de navigation
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final user = profileState.user;
    final isLandlord = user?.roles?.any((role) => role.name == 'bailleur') ?? false;

    // Lire l'index actif pour mettre en surbrillance l'icône
    final selectedIndex = ref.watch(selectedTabIndexProvider);

    // Fonction de navigation
    void onTapped(int index) {
      if (selectedIndex != index) {
        ref.read(selectedTabIndexProvider.notifier).state = index;
        // Naviguer vers la route correspondante
        context.go(navRoutes[index]);
      }
    }

    const double bottomNavBarHeight = 100.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.darkBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.darkBackgroundColor,
            pinned: true,
            title: Text(
              'Bonjour, ${user?.fullName ?? ''}!',
              style: const TextStyle(
                color: AppTheme.lightTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                // Cet IconButton navigue directement vers la route du profil (index 3)
                onPressed: () => onTapped(3),
                icon: const Icon(Icons.person_outline, color: AppTheme.lightTextColor),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BalanceCard(),
                      const SizedBox(height: 24),
                      const ActionButtons(),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            if (isLandlord) ...[
                              const TenantsSection(),
                              const SizedBox(height: 24),
                            ],
                            const TransactionsList(),
                            SizedBox(height: bottomNavBarHeight),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Passer l'index actif et la fonction de navigation au CustomBottomNavBar
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onTapped: onTapped,
      ),
    );
  }
}

// 💡 CustomBottomNavBar avec gestion de l'état (index) et du callback de navigation
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
    final double safeAreaPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0 + safeAreaPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.darkPrimary.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
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
                  icon: Icons.remove_red_eye_outlined,
                  index: 1,
                  isActive: selectedIndex == 1,
                  onTap: onTapped,
                ),
                _NavItem(
                  icon: Icons.bar_chart_sharp,
                  index: 2,
                  isActive: selectedIndex == 2,
                  onTap: onTapped,
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  index: 3,
                  isActive: selectedIndex == 3,
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final int index;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 Ajout d'un GestureDetector pour capter le clic
    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 70, // Zone de clic généreuse
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primaryBlue : Colors.white70,
              size: 28,
            ),
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