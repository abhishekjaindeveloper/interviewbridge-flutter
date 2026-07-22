import 'package:get_it/get_it.dart';
import 'data/datasources/technology_remote_datasource.dart';
import 'data/repositories/technology_repository_impl.dart';
import 'domain/repositories/technology_repository.dart';
import 'domain/usecases/get_technologies_usecase.dart';
import 'domain/usecases/get_all_technologies_usecase.dart';
import 'domain/usecases/create_technology_usecase.dart';
import 'domain/usecases/update_technology_usecase.dart';
import 'domain/usecases/activate_technology_usecase.dart';
import 'domain/usecases/deactivate_technology_usecase.dart';
import 'presentation/bloc/technology_bloc.dart';

void initTechnology(GetIt sl) {
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
}
