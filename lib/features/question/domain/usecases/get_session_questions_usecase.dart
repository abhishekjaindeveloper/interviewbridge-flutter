import '../entities/question_entity.dart';
import '../repositories/question_repository.dart';

class GetSessionQuestionsUseCase {
  final QuestionRepository _repository;

  GetSessionQuestionsUseCase(this._repository);

  Future<List<QuestionEntity>> call(String sessionId) async {
    return await _repository.getSessionQuestions(sessionId);
  }
}
