import 'package:flutter/material.dart';

class RouteNavigator {
  RouteNavigator._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T, TO>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }

  static Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  static void pop<T>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }
}
