import 'package:get_it/get_it.dart';
import 'data/datasources/question_remote_datasource.dart';
import 'data/repositories/question_repository_impl.dart';
import 'domain/repositories/question_repository.dart';
import 'domain/usecases/get_session_questions_usecase.dart';
import 'domain/usecases/submit_answer_usecase.dart';
import 'presentation/bloc/question_bloc.dart';

void initQuestion(GetIt sl) {
  sl.registerFactory(
    () => QuestionBloc(
      getSessionQuestionsUseCase: sl(),
      submitAnswerUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetSessionQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitAnswerUseCase(sl()));
  sl.registerLazySingleton<QuestionRepository>(() => QuestionRepositoryImpl(sl()));
  sl.registerLazySingleton<QuestionRemoteDataSource>(() => QuestionRemoteDataSourceImpl(sl()));
}
