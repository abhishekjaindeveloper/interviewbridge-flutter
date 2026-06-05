import '../entities/question_entity.dart';
import '../repositories/question_repository.dart';

class GetQuestionByNumberUseCase {
  final QuestionRepository _repository;

  GetQuestionByNumberUseCase(this._repository);

  Future<QuestionEntity> call(String sessionId, int questionNumber) async {
    return await _repository.getQuestionByNumber(sessionId, questionNumber);
  }
}
