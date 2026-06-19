import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_constants.dart';
import 'core/routes/route_navigator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/technology/presentation/bloc/technology_bloc.dart';
import 'features/experience/presentation/bloc/experience_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/practice_session/presentation/bloc/practice_session_bloc.dart';
import 'features/question/presentation/bloc/question_bloc.dart';
import 'features/evaluation/presentation/bloc/evaluation_bloc.dart';
import 'injection_container.dart';

class App extends StatefulWidget {
  final ThemeMode initialTheme;
  const App({super.key, required this.initialTheme});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final themeCubit = sl<ThemeCubit>();
    if (themeCubit.state == ThemeMode.system) {
      setState(() {
        _updateThemeColors(ThemeMode.system);
      });
    }
  }

  void _updateThemeColors(ThemeMode themeMode) {
    if (themeMode == ThemeMode.dark) {
      AppColors.setToDark();
    } else if (themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      if (brightness == Brightness.dark) {
        AppColors.setToDark();
      } else {
        AppColors.setToLight();
      }
    } else {
      AppColors.setToLight();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
        BlocProvider<TechnologyBloc>(create: (_) => sl<TechnologyBloc>()),
        BlocProvider<ExperienceBloc>(create: (_) => sl<ExperienceBloc>()),
        BlocProvider<PracticeSessionBloc>(create: (_) => sl<PracticeSessionBloc>()),
        BlocProvider<QuestionBloc>(create: (_) => sl<QuestionBloc>()),
        BlocProvider<EvaluationBloc>(create: (_) => sl<EvaluationBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          _updateThemeColors(themeMode);

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            navigatorKey: RouteNavigator.navigatorKey,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: RouteConstants.initial,
          );
        },
      ),
    );
  }
}
