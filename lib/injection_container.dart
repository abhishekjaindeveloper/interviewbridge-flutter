import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/network/api_client.dart';
import 'core/network/api_interceptors.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/theme_storage_service.dart';
import 'core/theme/theme_cubit.dart';

// Feature DI registrations
import 'features/auth/auth_injection.dart';
import 'features/admin/admin_injection.dart';
import 'features/technology/technology_injection.dart';
import 'features/experience/experience_injection.dart';
import 'features/profile/profile_injection.dart';
import 'features/practice_session/practice_session_injection.dart';
import 'features/question/question_injection.dart';
import 'features/evaluation/evaluation_injection.dart';
import 'features/career_pilot/career_pilot_injection.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================================
  // CORE & EXTERNAL DEPENDENCIES
  // ==========================================
  
  // Flutter Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService(sl()));

  // Theme Storage & Cubit
  sl.registerLazySingleton<ThemeStorageService>(() => ThemeStorageService(sl()));
  final themeStorage = ThemeStorageService(const FlutterSecureStorage());
  final savedTheme = await themeStorage.readTheme();
  ThemeMode initialTheme = ThemeMode.light;
  if (savedTheme == 'dark') {
    initialTheme = ThemeMode.dark;
  } else if (savedTheme == 'system') {
    initialTheme = ThemeMode.system;
  }
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl(), initialTheme));

  // Network (Dio & ApiClient)
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<ApiInterceptors>(() => ApiInterceptors(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl(), sl()));

  // ==========================================
  // FEATURES (Delegated to feature injection files)
  // ==========================================
  
  initAuth(sl);
  initAdmin(sl);
  initTechnology(sl);
  initExperience(sl);
  initProfile(sl);
  initPracticeSession(sl);
  initQuestion(sl);
  initEvaluation(sl);
  initCareerPilot(sl);
}
