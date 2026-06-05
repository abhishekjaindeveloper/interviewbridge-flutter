import '../entities/submit_answer_response_entity.dart';
import '../repositories/question_repository.dart';

class SubmitAnswerUseCase {
  final QuestionRepository _repository;

  SubmitAnswerUseCase(this._repository);

  Future<SubmitAnswerResponseEntity> call(String questionId, String answer) async {
    return await _repository.submitAnswer(questionId, answer);
  }
}
