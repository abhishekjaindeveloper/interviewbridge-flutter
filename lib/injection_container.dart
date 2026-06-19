import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/network/api_client.dart';
import 'core/network/api_interceptors.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/theme_storage_service.dart';
import 'core/theme/theme_cubit.dart';

// Auth Feature
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_logged_in_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Admin Feature
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/admin/domain/usecases/get_pending_users_usecase.dart';
import 'features/admin/domain/usecases/approve_user_usecase.dart';
import 'features/admin/domain/usecases/reject_user_usecase.dart';
import 'features/admin/domain/usecases/get_admin_user_statistics_usecase.dart';
import 'features/admin/domain/usecases/get_users_usecase.dart';
import 'features/admin/domain/usecases/activate_user_usecase.dart';
import 'features/admin/domain/usecases/deactivate_user_usecase.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/data/datasources/admin_remote_datasource.dart';

// Technology Feature
import 'features/technology/data/datasources/technology_remote_datasource.dart';
import 'features/technology/data/repositories/technology_repository_impl.dart';
import 'features/technology/domain/repositories/technology_repository.dart';
import 'features/technology/domain/usecases/get_technologies_usecase.dart';
import 'features/technology/domain/usecases/get_all_technologies_usecase.dart';
import 'features/technology/domain/usecases/create_technology_usecase.dart';
import 'features/technology/domain/usecases/update_technology_usecase.dart';
import 'features/technology/domain/usecases/activate_technology_usecase.dart';
import 'features/technology/domain/usecases/deactivate_technology_usecase.dart';
import 'features/technology/presentation/bloc/technology_bloc.dart';

// Experience Feature
import 'features/experience/data/datasources/experience_remote_datasource.dart';
import 'features/experience/data/repositories/experience_repository_impl.dart';
import 'features/experience/domain/repositories/experience_repository.dart';
import 'features/experience/domain/usecases/get_experiences_usecase.dart';
import 'features/experience/domain/usecases/get_all_experiences_usecase.dart';
import 'features/experience/domain/usecases/create_experience_usecase.dart';
import 'features/experience/domain/usecases/update_experience_usecase.dart';
import 'features/experience/domain/usecases/activate_experience_usecase.dart';
import 'features/experience/domain/usecases/deactivate_experience_usecase.dart';
import 'features/experience/presentation/bloc/experience_bloc.dart';

// Profile Feature
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/domain/usecases/setup_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

// Practice Session Feature
import 'features/practice_session/data/datasources/practice_session_remote_datasource.dart';
import 'features/practice_session/data/repositories/practice_session_repository_impl.dart';
import 'features/practice_session/domain/repositories/practice_session_repository.dart';
import 'features/practice_session/domain/usecases/create_practice_session_usecase.dart';
import 'features/practice_session/domain/usecases/get_practice_sessions_usecase.dart';
import 'features/practice_session/domain/usecases/get_practice_session_details_usecase.dart';
import 'features/practice_session/domain/usecases/generate_questions_usecase.dart';
import 'features/practice_session/presentation/bloc/practice_session_bloc.dart';

// Question Feature
import 'features/question/data/datasources/question_remote_datasource.dart';
import 'features/question/data/repositories/question_repository_impl.dart';
import 'features/question/domain/repositories/question_repository.dart';
import 'features/question/domain/usecases/get_session_questions_usecase.dart';
import 'features/question/domain/usecases/get_question_by_number_usecase.dart';
import 'features/question/domain/usecases/get_question_details_usecase.dart';
import 'features/question/domain/usecases/submit_answer_usecase.dart';
import 'features/question/presentation/bloc/question_bloc.dart';

// Evaluation Feature
import 'features/evaluation/data/datasources/evaluation_remote_datasource.dart';
import 'features/evaluation/data/repositories/evaluation_repository_impl.dart';
import 'features/evaluation/domain/repositories/evaluation_repository.dart';
import 'features/evaluation/domain/usecases/evaluate_question_usecase.dart';
import 'features/evaluation/domain/usecases/get_evaluation_result_usecase.dart';
import 'features/evaluation/presentation/bloc/evaluation_bloc.dart';

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
  // FEATURES (BLoCs, UseCases, Repos, Sources)
  // ==========================================
  
  // 1. Auth Feature
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getLoggedInUserUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetLoggedInUserUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl()));

  // 2. Admin Feature
  sl.registerFactory(
    () => AdminBloc(
      getPendingUsersUseCase: sl(),
      approveUserUseCase: sl(),
      rejectUserUseCase: sl(),
      getAdminUserStatisticsUseCase: sl(),
      getUsersUseCase: sl(),
      activateUserUseCase: sl(),
      deactivateUserUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetPendingUsersUseCase(sl()));
  sl.registerLazySingleton(() => ApproveUserUseCase(sl()));
  sl.registerLazySingleton(() => RejectUserUseCase(sl()));
  sl.registerLazySingleton(() => GetAdminUserStatisticsUseCase(sl()));
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => ActivateUserUseCase(sl()));
  sl.registerLazySingleton(() => DeactivateUserUseCase(sl()));
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(sl()));
  sl.registerLazySingleton<AdminRemoteDataSource>(() => AdminRemoteDataSourceImpl(sl()));
  
  // 3. Technology Feature
  sl.registerFactory(
    () => TechnologyBloc(
      getTechnologiesUseCase: sl(),
      getAllTechnologiesUseCase: sl(),
      createTechnologyUseCase: sl(),
      updateTechnologyUseCase: sl(),
      activateTechnologyUseCase: sl(),
      deactivateTechnologyUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetTechnologiesUseCase(sl()));
  sl.registerLazySingleton(() => GetAllTechnologiesUseCase(sl()));
  sl.registerLazySingleton(() => CreateTechnologyUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTechnologyUseCase(sl()));
  sl.registerLazySingleton(() => ActivateTechnologyUseCase(sl()));
  sl.registerLazySingleton(() => DeactivateTechnologyUseCase(sl()));
  sl.registerLazySingleton<TechnologyRepository>(() => TechnologyRepositoryImpl(sl()));
  sl.registerLazySingleton<TechnologyRemoteDataSource>(() => TechnologyRemoteDataSourceImpl(sl()));

  // 4. Experience Feature
  sl.registerFactory(
    () => ExperienceBloc(
      getExperiencesUseCase: sl(),
      getAllExperiencesUseCase: sl(),
      createExperienceUseCase: sl(),
      updateExperienceUseCase: sl(),
      activateExperienceUseCase: sl(),
      deactivateExperienceUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetExperiencesUseCase(sl()));
  sl.registerLazySingleton(() => GetAllExperiencesUseCase(sl()));
  sl.registerLazySingleton(() => CreateExperienceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateExperienceUseCase(sl()));
  sl.registerLazySingleton(() => ActivateExperienceUseCase(sl()));
  sl.registerLazySingleton(() => DeactivateExperienceUseCase(sl()));
  sl.registerLazySingleton<ExperienceRepository>(() => ExperienceRepositoryImpl(sl()));
  sl.registerLazySingleton<ExperienceRemoteDataSource>(() => ExperienceRemoteDataSourceImpl(sl()));

  // 5. Profile Feature
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      setupProfileUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => SetupProfileUseCase(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(sl()));

  // 6. Practice Session Feature
  sl.registerFactory(
    () => PracticeSessionBloc(
      createPracticeSessionUseCase: sl(),
      getPracticeSessionsUseCase: sl(),
      getPracticeSessionDetailsUseCase: sl(),
      generateQuestionsUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => CreatePracticeSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetPracticeSessionsUseCase(sl()));
  sl.registerLazySingleton(() => GetPracticeSessionDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GenerateQuestionsUseCase(sl()));
  sl.registerLazySingleton<PracticeSessionRepository>(() => PracticeSessionRepositoryImpl(sl()));
  sl.registerLazySingleton<PracticeSessionRemoteDataSource>(() => PracticeSessionRemoteDataSourceImpl(sl()));

  // 7. Question Feature
  sl.registerFactory(
    () => QuestionBloc(
      getSessionQuestionsUseCase: sl(),
      submitAnswerUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetSessionQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => GetQuestionByNumberUseCase(sl()));
  sl.registerLazySingleton(() => GetQuestionDetailsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitAnswerUseCase(sl()));
  sl.registerLazySingleton<QuestionRepository>(() => QuestionRepositoryImpl(sl()));
  sl.registerLazySingleton<QuestionRemoteDataSource>(() => QuestionRemoteDataSourceImpl(sl()));

  // 8. Evaluation Feature
  sl.registerFactory(
    () => EvaluationBloc(
      getSessionQuestionsUseCase: sl(),
      getPracticeSessionDetailsUseCase: sl(),
      evaluateQuestionUseCase: sl(),
      getEvaluationResultUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => EvaluateQuestionUseCase(sl()));
  sl.registerLazySingleton(() => GetEvaluationResultUseCase(sl()));
  sl.registerLazySingleton<EvaluationRepository>(() => EvaluationRepositoryImpl(sl()));
  sl.registerLazySingleton<EvaluationRemoteDataSource>(() => EvaluationRemoteDataSourceImpl(sl()));
}
