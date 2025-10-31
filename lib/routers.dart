import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/pages/auth/login/login_screen.dart';
import 'package:immobilx/pages/auth/register/register_screen.dart';
import 'package:immobilx/pages/auth/welcom/welcom_screen.dart';
import 'package:immobilx/pages/bailleur/property_datail.dart';
import 'package:immobilx/pages/gestion/contrat/contract_details_page.dart';
import 'package:immobilx/pages/gestion/contrat/contract_form_page.dart';
import 'package:immobilx/pages/gestion/contrat/contract_list_page.dart';
import 'package:immobilx/pages/gestion/property/property_list_page.dart';
import 'package:immobilx/pages/gestion/property/public_property_list_page.dart';
import 'package:immobilx/pages/gestion/property/property_applications_page.dart';
import 'package:immobilx/pages/profile/edit/edit_profile_screen.dart';
import 'package:immobilx/pages/profile/profile_screen.dart';
import 'package:immobilx/pages/bailleur/add_property_page.dart';
import 'package:immobilx/pages/widget/app_shell.dart';
import 'package:immobilx/pages/widget/onboarding_page.dart';
import 'package:immobilx/pages/gestion/payment/payments_hub_page.dart';
import 'business/models/contrat/contrat.dart';
import 'pages/gestion/payment/payment_form_page.dart';
import 'pages/404/not_found_page.dart';
import 'pages/intro/appCtrl.dart';
import 'utils/navigationUtils.dart';
import './main.dart';
import 'pages/home/homePage.dart';
import 'utils/onboarding_provider.dart'; // Importez le nouveau provider

final routerConfigProvider = Provider<GoRouter>((ref) {
  final navigatorKey = getIt<NavigationUtils>().navigatorKey;
  /*
   routes restreintes
  */
  final shellRoutes = [
    GoRoute(
      path: "/app/home",
      name: 'home_page',
      builder: (ctx, state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/app/payments',
      name: 'payments_hub_page',
      builder: (ctx, state) {
        return const PaymentsHubPage();
      },
    ),
    GoRoute(
      path: '/app/properties',
      name: 'property_list_page',
      builder: (ctx, state) {
        return const PropertyListPage();
      },
    ),
    GoRoute(
      path: "/app/profile",
      name: 'profile_page',
      builder: (ctx, state) {
        return ProfilePage();
      },
      routes: [
        GoRoute(
          path: "edit",
          name: 'edit_profile_page',
          builder: (ctx, state) {
            return EditProfilePage();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/app/contracts',
      name: 'contracts_list_page',
      builder: (ctx, state) {
        return const ContractListPage();
      },
    ),
  ];

  final authRoutes = [
    GoRoute(
      path: "/app/bailleur/properties/new",
      name: 'add_property_page',
      builder: (ctx, state) {
        return AddPropertyPage();
      },
    ),
    GoRoute(
      path: '/app/properties/:id',
      name: 'property_details_page',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PropertyDetailsPage(propertyId: id);
      },
    ),
    GoRoute(
      path: '/app/properties/:id/applications',
      name: 'property_applications_page',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PropertyApplicationsPage(propertyId: id);
      },
    ),

    GoRoute(
      path: '/app/contracts/new',
      name: 'contract_create_page',
      builder: (context, state) => const ContractFormPage(),
    ),

    // 2. DÉPLACER LA ROUTE D'ÉDITION EN DEUXIÈME (avant :id)
    // Elle utilise un segment fixe ('/edit') APRES l'ID.
    GoRoute(
      path: '/app/contracts/:id/edit',
      name: 'contract_edit_page',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        // We'll pass the contract object itself to the form page
        // This requires fetching it first, which is better done in the widget
        // For simplicity, we'll just pass the ID and the form will fetch it
        return ContractFormPage(contract: state.extra as Contract?);
      },
    ),
    GoRoute(
      path: '/app/contracts/:id/pay',
      name: 'payment_form_page',
      builder: (context, state) {
        return PaymentFormPage(contract: state.extra as Contract);
      },
    ),

    // 3. LA ROUTE DE DÉTAILS VIENT EN DERNIER
    GoRoute(
      path: '/app/contracts/:id',
      name: 'contract_details_page',
      builder: (context, state) {
        // Cette conversion est maintenant sûre, car 'new' et '/edit' ont été interceptés
        final id = int.parse(state.pathParameters['id']!);
        return ContractDetailsPage(contractId: id);
      },
    ),
  ];

  /*
   routes publics
  */
  final noAuthRoutes = [
    // Nouvelle route pour la page d'onboarding
    GoRoute(
      path: "/public/onboarding",
      name: 'onboarding_page',
      builder: (ctx, state) {
        return OnboardingPage();
      },
    ),
    GoRoute(
      path: "/public/welcome",
      name: 'welcome_page',
      builder: (ctx, state) {
        return WelcomePage();
      },
    ),
    GoRoute(
      path: "/public/login",
      name: 'login_page',
      builder: (ctx, state) {
        return LoginPage();
      },
    ),
    GoRoute(
      path: "/public/register",
      name: 'register_page',
      builder: (ctx, state) {
        return RegisterPage();
      },
    ),
    GoRoute(
      path: "/public/properties",
      name: 'public_property_list_page',
      builder: (ctx, state) {
        return const PublicPropertyListPage();
      },
    ),
  ];

  /*
CONFIGURATION  DES ROUTES
*/
  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: "/public/welcome",
    redirect: (context, state) {
      // Étape 1 : Vérification de l'onboarding
      final onboardingCompleted = ref.watch(onboardingProvider);
      final isOnboarding = state.matchedLocation.startsWith("/public/onboarding");

      if (!onboardingCompleted && !isOnboarding) {
        return "/public/onboarding";
      }

      // Étape 2 : Vérification de l'authentification (votre logique existante)
      var appState = ref.watch(appCtrlProvider);
      var user = appState.user;

      // Redirection vers la page d'accueil si l'utilisateur est connecté et sur une page publique
      if (user != null && state.matchedLocation.startsWith("/public")) {
        // Assurez-vous que l'utilisateur ne soit pas coincé sur la page d'onboarding
        if (isOnboarding) {
          return "/app/home";
        }
        return "/app/home";
      }

      // Redirection vers la page d'accueil si l'utilisateur n'est pas connecté
      // et essaie d'accéder à une page restreinte
      if (user == null && state.matchedLocation.startsWith("/app")) {
        return "/public/welcome";
      }

      return null;
    },
    routes: [
      ...noAuthRoutes,
      ...authRoutes,
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: shellRoutes,
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});
