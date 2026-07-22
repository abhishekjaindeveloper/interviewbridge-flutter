import 'package:get_it/get_it.dart';
import 'data/datasources/experience_remote_datasource.dart';
import 'data/repositories/experience_repository_impl.dart';
import 'domain/repositories/experience_repository.dart';
import 'domain/usecases/get_experiences_usecase.dart';
import 'domain/usecases/get_all_experiences_usecase.dart';
import 'domain/usecases/create_experience_usecase.dart';
import 'domain/usecases/update_experience_usecase.dart';
import 'domain/usecases/activate_experience_usecase.dart';
import 'domain/usecases/deactivate_experience_usecase.dart';
import 'presentation/bloc/experience_bloc.dart';

void initExperience(GetIt sl) {
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
}
