import '../entities/evaluation_entity.dart';
import '../repositories/evaluation_repository.dart';

class EvaluateQuestionUseCase {
  final EvaluationRepository _repository;

  EvaluateQuestionUseCase(this._repository);

  Future<EvaluationEntity> call(String questionId) async {
    return await _repository.evaluateQuestion(questionId);
  }
}
