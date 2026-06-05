import '../entities/practice_session_entity.dart';
import '../repositories/practice_session_repository.dart';

class GetPracticeSessionsUseCase {
  final PracticeSessionRepository _repository;

  GetPracticeSessionsUseCase(this._repository);

  Future<List<PracticeSessionEntity>> call() async {
    return await _repository.getSessionHistory();
  }
}
