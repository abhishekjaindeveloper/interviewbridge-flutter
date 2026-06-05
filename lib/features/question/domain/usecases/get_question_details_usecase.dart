import '../entities/question_entity.dart';
import '../repositories/question_repository.dart';

class GetQuestionDetailsUseCase {
  final QuestionRepository _repository;

  GetQuestionDetailsUseCase(this._repository);

  Future<QuestionEntity> call(String questionId) async {
    return await _repository.getQuestionDetails(questionId);
  }
}
