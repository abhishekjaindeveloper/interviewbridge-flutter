import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/auth_wrapper.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/pages/technology_experience_selection_page.dart';
import 'route_constants.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.initial:
      case RouteConstants.login:
      case RouteConstants.home:
      case RouteConstants.pendingApproval:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AuthWrapper(),
        );
      case RouteConstants.register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterPage(),
        );
      case RouteConstants.profileSetup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TechnologyExperienceSelectionPage(),
        );
      case RouteConstants.adminDashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(body: Center(child: Text('Admin Dashboard Screen'))),
        );
      case RouteConstants.sessionStart:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(body: Center(child: Text('Start Session Screen'))),
        );
      case RouteConstants.sessionActive:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(body: Center(child: Text('Active Session Screen'))),
        );
      case RouteConstants.evaluationResults:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(body: Center(child: Text('Evaluation Results Screen'))),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
