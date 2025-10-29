import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

const List<String> navRoutes = [
  '/app/home',
  '/app/transactions',
  '/app/stats',
  '/app/profile',
];

final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabIndexProvider);

    void onTapped(int index) {
      if (selectedIndex != index) {
        ref.read(selectedTabIndexProvider.notifier).state = index;
        context.go(navRoutes[index]);
      }
    }

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onTapped: onTapped,
      ),
    );
  }
}

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
    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 70,
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
