import 'package:get_it/get_it.dart';
import 'data/datasources/evaluation_remote_datasource.dart';
import 'data/repositories/evaluation_repository_impl.dart';
import 'domain/repositories/evaluation_repository.dart';
import 'domain/usecases/evaluate_question_usecase.dart';
import 'domain/usecases/get_evaluation_result_usecase.dart';
import 'presentation/bloc/evaluation_bloc.dart';

void initEvaluation(GetIt sl) {
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
