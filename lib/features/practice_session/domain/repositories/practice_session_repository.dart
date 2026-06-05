import '../entities/practice_session_entity.dart';

abstract class PracticeSessionRepository {
  Future<PracticeSessionEntity> createSession(String technologyId, String experienceId, int totalQuestions);
  Future<PracticeSessionEntity> getSessionDetails(String sessionId);
  Future<List<PracticeSessionEntity>> getSessionHistory();
  Future<void> generateQuestions(String sessionId);
}
