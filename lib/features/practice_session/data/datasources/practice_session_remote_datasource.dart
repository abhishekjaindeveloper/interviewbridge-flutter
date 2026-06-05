import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/practice_session_model.dart';

abstract class PracticeSessionRemoteDataSource {
  Future<PracticeSessionModel> createSession(String technologyId, String experienceId, int totalQuestions);
  Future<PracticeSessionModel> getSessionDetails(String sessionId);
  Future<List<PracticeSessionModel>> getSessionHistory();
  Future<void> generateQuestions(String sessionId);
}

class PracticeSessionRemoteDataSourceImpl implements PracticeSessionRemoteDataSource {
  final ApiClient _apiClient;

  PracticeSessionRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PracticeSessionModel> createSession(
    String technologyId,
    String experienceId,
    int totalQuestions,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.practiceSessions,
      data: {
        'technologyId': technologyId,
        'experienceId': experienceId,
        'totalQuestions': totalQuestions,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return PracticeSessionModel.fromJson(data);
  }

  @override
  Future<PracticeSessionModel> getSessionDetails(String sessionId) async {
    final response = await _apiClient.get(
      '${ApiConstants.practiceSessions}/$sessionId',
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return PracticeSessionModel.fromJson(data);
  }

  @override
  Future<List<PracticeSessionModel>> getSessionHistory() async {
    final response = await _apiClient.get(ApiConstants.practiceSessions);
    final dataList = response.data['data'] as List<dynamic>? ?? [];
    return dataList
        .map((json) => PracticeSessionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> generateQuestions(String sessionId) async {
    await _apiClient.post(
      ApiConstants.generateQuestionsUrl(sessionId),
    );
  }
}
