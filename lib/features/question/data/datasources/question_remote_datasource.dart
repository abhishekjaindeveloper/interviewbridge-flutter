import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/question_model.dart';
import '../models/submit_answer_response_model.dart';

abstract class QuestionRemoteDataSource {
  Future<List<QuestionModel>> getSessionQuestions(String sessionId);
  Future<QuestionModel> getQuestionByNumber(String sessionId, int questionNumber);
  Future<QuestionModel> getQuestionDetails(String questionId);
  Future<SubmitAnswerResponseModel> submitAnswer(String questionId, String answer);
}

class QuestionRemoteDataSourceImpl implements QuestionRemoteDataSource {
  final ApiClient _apiClient;

  QuestionRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<QuestionModel>> getSessionQuestions(String sessionId) async {
    final response = await _apiClient.get(
      ApiConstants.sessionQuestionsUrl(sessionId),
    );
    final dataList = response.data['data'] as List<dynamic>? ?? [];
    return dataList
        .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<QuestionModel> getQuestionByNumber(String sessionId, int questionNumber) async {
    final response = await _apiClient.get(
      ApiConstants.questionByNumberUrl(sessionId, questionNumber),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return QuestionModel.fromJson(data);
  }

  @override
  Future<QuestionModel> getQuestionDetails(String questionId) async {
    final response = await _apiClient.get(
      ApiConstants.questionDetailsUrl(questionId),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return QuestionModel.fromJson(data);
  }

  @override
  Future<SubmitAnswerResponseModel> submitAnswer(String questionId, String answer) async {
    final response = await _apiClient.post(
      ApiConstants.submitAnswerUrl(questionId),
      data: {
        'answer': answer,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return SubmitAnswerResponseModel.fromJson(data);
  }
}
