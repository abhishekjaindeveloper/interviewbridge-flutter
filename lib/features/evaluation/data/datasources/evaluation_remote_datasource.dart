import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/evaluation_model.dart';

abstract class EvaluationRemoteDataSource {
  Future<EvaluationModel> evaluateQuestion(String questionId);
  Future<EvaluationModel> getEvaluationResult(String questionId);
}

class EvaluationRemoteDataSourceImpl implements EvaluationRemoteDataSource {
  final ApiClient _apiClient;

  EvaluationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<EvaluationModel> evaluateQuestion(String questionId) async {
    final response = await _apiClient.post(
      ApiConstants.evaluateQuestionUrl(questionId),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return EvaluationModel.fromJson(data);
  }

  @override
  Future<EvaluationModel> getEvaluationResult(String questionId) async {
    final response = await _apiClient.get(
      ApiConstants.questionEvaluationUrl(questionId),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return EvaluationModel.fromJson(data);
  }
}
