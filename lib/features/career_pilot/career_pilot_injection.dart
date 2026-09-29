import 'package:get_it/get_it.dart';
import 'data/datasources/career_pilot_remote_datasource.dart';
import 'data/repositories/career_pilot_repository_impl.dart';
import 'domain/repositories/career_pilot_repository.dart';
import 'domain/usecases/get_matched_jobs_usecase.dart';
import 'domain/usecases/get_job_details_usecase.dart';
import 'presentation/bloc/career_pilot_bloc.dart';

void initCareerPilot(GetIt sl) {
  sl.registerFactory(
    () => CareerPilotBloc(
      getMatchedJobsUseCase: sl(),
      getJobDetailsUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetMatchedJobsUseCase(sl()));
  sl.registerLazySingleton(() => GetJobDetailsUseCase(sl()));
  sl.registerLazySingleton<CareerPilotRepository>(() => CareerPilotRepositoryImpl(sl()));
  sl.registerLazySingleton<CareerPilotRemoteDataSource>(() => CareerPilotRemoteDataSourceImpl(sl()));
}
