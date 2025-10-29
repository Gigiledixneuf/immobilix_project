import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immobilx/pages/home/components/action_buttons.dart';
import 'package:immobilx/pages/home/components/balance_card.dart';
import 'package:immobilx/pages/home/components/tenants_sections.dart';
import 'package:immobilx/pages/home/components/transactions_list.dart';
import 'package:immobilx/pages/profile/profile_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final user = profileState.user;
    final isLandlord = user?.roles?.any((role) => role.name == 'bailleur') ?? false;

    return Scaffold(
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
                onPressed: () {
                  // La navigation est maintenant gérée par l'AppShell
                },
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
                      ActionButtons(isLandlord: isLandlord),
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
    );
  }
}
