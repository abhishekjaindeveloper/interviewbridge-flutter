import '../repositories/practice_session_repository.dart';

class GenerateQuestionsUseCase {
  final PracticeSessionRepository _repository;

  GenerateQuestionsUseCase(this._repository);

  Future<void> call(String sessionId) async {
    await _repository.generateQuestions(sessionId);
  }
}
