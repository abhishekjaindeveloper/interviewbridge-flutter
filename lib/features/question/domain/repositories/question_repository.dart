import '../entities/question_entity.dart';
import '../entities/submit_answer_response_entity.dart';

abstract class QuestionRepository {
  Future<List<QuestionEntity>> getSessionQuestions(String sessionId);
  Future<QuestionEntity> getQuestionByNumber(String sessionId, int questionNumber);
  Future<QuestionEntity> getQuestionDetails(String questionId);
  Future<SubmitAnswerResponseEntity> submitAnswer(String questionId, String answer);
}
