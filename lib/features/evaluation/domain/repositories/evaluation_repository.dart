import '../entities/evaluation_entity.dart';

abstract class EvaluationRepository {
  Future<EvaluationEntity> evaluateQuestion(String questionId);
  Future<EvaluationEntity> getEvaluationResult(String questionId);
}
