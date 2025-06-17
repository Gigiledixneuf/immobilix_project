import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/404/not_found_page.dart';
import 'pages/intro/appCtrl.dart';
import 'pages/intro/introPage.dart';
import 'utils/navigationUtils.dart';
import './main.dart';
import 'pages/home/homePage.dart';

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
  ];

  /*
   routes publics
  */
  final noAuthRoutes = [
    GoRoute(
      path: "/public/intro",
      name: 'intro_page',
      builder: (ctx, state) {
        return IntroPage();
      },
    ),
  ];

  /*
CONFIGURATION  DES ROUTES
*/
  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: "/public/intro",
    redirect: (context, state) {
      var appState = ref.watch(appCtrlProvider);
      var user = appState.user;

      // redirection vers la page d'accueil si l'utilisateur est connecté
      if (user != null && state.matchedLocation.startsWith("/public")) {
        return "/app/home";
      }

      // redirection vers la page d'intro si l'utilisateur n'est pas connecté
      /*if (user == null && state.matchedLocation.startsWith("/app")) {
        return "/public/intro";
      }*/

      return null;
    },
    routes: [...noAuthRoutes, ...authRoutes],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});
