import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/auth_wrapper.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/terms_conditions_page.dart';
import '../../features/auth/presentation/pages/privacy_policy_page.dart';
import '../../features/profile/presentation/pages/technology_experience_selection_page.dart';
import '../../features/practice_session/presentation/pages/practice_session_page.dart';
import '../../features/practice_session/presentation/pages/session_history_page.dart';
import '../../features/question/presentation/pages/question_page.dart';
import '../../features/evaluation/presentation/pages/evaluation_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import 'route_constants.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.initial:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashPage(),
        );
      case RouteConstants.landing:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LandingPage(),
        );
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
      case RouteConstants.termsConditions:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TermsConditionsPage(),
        );
      case RouteConstants.privacyPolicy:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PrivacyPolicyPage(),
        );
      case RouteConstants.profileSetup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TechnologyExperienceSelectionPage(),
        );
      case RouteConstants.sessionStart:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PracticeSessionPage(),
        );
      case RouteConstants.sessionHistory:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SessionHistoryPage(),
        );
      case RouteConstants.adminDashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminDashboardPage(),
        );
      case RouteConstants.sessionActive:
        final sessionId = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => QuestionPage(sessionId: sessionId),
        );
      case RouteConstants.evaluationResults:
        final sessionId = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EvaluationPage(sessionId: sessionId),
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
