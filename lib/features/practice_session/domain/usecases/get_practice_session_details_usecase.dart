import '../entities/practice_session_entity.dart';
import '../repositories/practice_session_repository.dart';

class GetPracticeSessionDetailsUseCase {
  final PracticeSessionRepository _repository;

  GetPracticeSessionDetailsUseCase(this._repository);

  Future<PracticeSessionEntity> call(String sessionId) async {
    return await _repository.getSessionDetails(sessionId);
  }
}
