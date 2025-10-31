import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immobilx/pages/gestion/payment/tenant_payments_page.dart';
import 'package:immobilx/pages/gestion/payment/landlord_payments_page.dart';
import 'package:immobilx/pages/profile/profile_controller.dart';
import 'package:immobilx/utils/theme/app_theme.dart';

class PaymentsHubPage extends ConsumerWidget {
  const PaymentsHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    final isLandlord = profile.user?.roles?.any((r) => r.name == 'bailleur') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Paiements', style: AppTheme.headingStyle.copyWith(color: AppTheme.lightTextColor)),
        backgroundColor: AppTheme.darkBackgroundColor,
        elevation: 0,
      ),
      backgroundColor: AppTheme.darkBackgroundColor,
      body: isLandlord ? const LandlordPaymentsPage() : const TenantPaymentsPage(),
    );
  }
}




