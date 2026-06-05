import '../entities/practice_session_entity.dart';
import '../repositories/practice_session_repository.dart';

class CreatePracticeSessionUseCase {
  final PracticeSessionRepository _repository;

  CreatePracticeSessionUseCase(this._repository);

  Future<PracticeSessionEntity> call(String technologyId, String experienceId, int totalQuestions) async {
    return await _repository.createSession(technologyId, experienceId, totalQuestions);
  }
}
