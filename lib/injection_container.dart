import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/network/api_client.dart';
import 'core/network/api_interceptors.dart';
import 'core/storage/secure_storage_service.dart';

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

// Technology Feature
import 'features/technology/data/datasources/technology_remote_datasource.dart';
import 'features/technology/data/repositories/technology_repository_impl.dart';
import 'features/technology/domain/repositories/technology_repository.dart';
import 'features/technology/domain/usecases/get_technologies_usecase.dart';
import 'features/technology/presentation/bloc/technology_bloc.dart';

// Experience Feature
import 'features/experience/data/datasources/experience_remote_datasource.dart';
import 'features/experience/data/repositories/experience_repository_impl.dart';
import 'features/experience/domain/repositories/experience_repository.dart';
import 'features/experience/domain/usecases/get_experiences_usecase.dart';
import 'features/experience/presentation/bloc/experience_bloc.dart';

// Profile Feature
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/domain/usecases/setup_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================================
  // CORE & EXTERNAL DEPENDENCIES
  // ==========================================
  
  // Flutter Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService(sl()));

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
  
  // 3. Technology Feature
  sl.registerFactory(
    () => TechnologyBloc(
      getTechnologiesUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetTechnologiesUseCase(sl()));
  sl.registerLazySingleton<TechnologyRepository>(() => TechnologyRepositoryImpl(sl()));
  sl.registerLazySingleton<TechnologyRemoteDataSource>(() => TechnologyRemoteDataSourceImpl(sl()));

  // 4. Experience Feature
  sl.registerFactory(
    () => ExperienceBloc(
      getExperiencesUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetExperiencesUseCase(sl()));
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
  // 7. Question Feature
  // 8. Evaluation Feature
}
