import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:immobilx/pages/auth/login/login_screen.dart';
import 'package:immobilx/pages/auth/register/register_screen.dart';
import 'package:immobilx/pages/auth/welcom/welcom_screen.dart';
import 'package:immobilx/pages/profile/edit/edit_profile_screen.dart';
import 'package:immobilx/pages/profile/profile_screen.dart';
import 'package:immobilx/pages/widget/onboarding_page.dart';
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
  final authRoutes = [
    GoRoute(
      path: "/app/home",
      name: 'home_page',
      builder: (ctx, state) {
        return HomePage();
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
    routes: [...noAuthRoutes, ...authRoutes],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});
