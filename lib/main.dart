import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/bloc_observer/app_bloc_observer.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/app_colors.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up global BLoC observer
  Bloc.observer = AppBlocObserver();
  
  // Initialize dependency injection
  await di.init();
  
  // Resolve theme cubit and apply initial theme to AppColors
  final themeCubit = di.sl<ThemeCubit>();
  if (themeCubit.state == ThemeMode.dark) {
    AppColors.setToDark();
  } else {
    AppColors.setToLight();
  }
  
  runApp(App(initialTheme: themeCubit.state));
}
