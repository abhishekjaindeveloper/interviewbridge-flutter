import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_constants.dart';
import 'core/routes/route_navigator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/technology/presentation/bloc/technology_bloc.dart';
import 'features/experience/presentation/bloc/experience_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/practice_session/presentation/bloc/practice_session_bloc.dart';
import 'features/question/presentation/bloc/question_bloc.dart';
import 'features/evaluation/presentation/bloc/evaluation_bloc.dart';
import 'injection_container.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
        BlocProvider<TechnologyBloc>(create: (_) => sl<TechnologyBloc>()),
        BlocProvider<ExperienceBloc>(create: (_) => sl<ExperienceBloc>()),
        BlocProvider<PracticeSessionBloc>(create: (_) => sl<PracticeSessionBloc>()),
        BlocProvider<QuestionBloc>(create: (_) => sl<QuestionBloc>()),
        BlocProvider<EvaluationBloc>(create: (_) => sl<EvaluationBloc>()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        navigatorKey: RouteNavigator.navigatorKey,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: RouteConstants.initial,
      ),
    );
  }
}
