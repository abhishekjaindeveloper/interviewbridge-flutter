import '../entities/evaluation_entity.dart';
import '../repositories/evaluation_repository.dart';

class GetEvaluationResultUseCase {
  final EvaluationRepository _repository;

  GetEvaluationResultUseCase(this._repository);

  Future<EvaluationEntity> call(String questionId) async {
    return await _repository.getEvaluationResult(questionId);
  }
}
