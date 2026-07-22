import 'package:get_it/get_it.dart';
import 'data/datasources/practice_session_remote_datasource.dart';
import 'data/repositories/practice_session_repository_impl.dart';
import 'domain/repositories/practice_session_repository.dart';
import 'domain/usecases/create_practice_session_usecase.dart';
import 'domain/usecases/get_practice_sessions_usecase.dart';
import 'domain/usecases/get_practice_session_details_usecase.dart';
import 'domain/usecases/generate_questions_usecase.dart';
import 'presentation/bloc/practice_session_bloc.dart';

void initPracticeSession(GetIt sl) {
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
}
