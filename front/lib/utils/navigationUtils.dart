import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class NavigationUtils {
  late GlobalKey<NavigatorState> navigatorKey;

  NavigationUtils() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  Future? navigateNamed(String routeName) {
    var context = navigatorKey.currentContext;
    return context?.pushNamed(routeName);
  }

  Future? navigate(String routeName) {
    var context = navigatorKey.currentContext;
    return context?.push(routeName);
  }

  goToNamed(String routeName) {
    var context = navigatorKey.currentContext;
    context?.goNamed(routeName);
  }

  goTo(String routeName) {
    var context = navigatorKey.currentContext;
    context?.go(routeName);
  }


  void replaceNamed(String routeName) {
    var context = navigatorKey.currentContext;
    context?.pushReplacementNamed(routeName);
  }
  void replace(String routeName) {
    var context = navigatorKey.currentContext;
    context?.pushReplacement(routeName);
  }

  pop() {
    var context = navigatorKey.currentContext;
    if (context != null && GoRouter.of(context).canPop()) {
      context.pop();
    }else{
      // exit app
      SystemNavigator.pop();
    }
  }
}
