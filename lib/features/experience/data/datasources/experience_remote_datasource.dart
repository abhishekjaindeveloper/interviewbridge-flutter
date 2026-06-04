import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/experience_model.dart';

abstract class ExperienceRemoteDataSource {
  Future<List<ExperienceModel>> getActiveExperiences();
}

class ExperienceRemoteDataSourceImpl implements ExperienceRemoteDataSource {
  final ApiClient _apiClient;

  ExperienceRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ExperienceModel>> getActiveExperiences() async {
    final response = await _apiClient.get(ApiConstants.userExperiences);
    final dataList = response.data['data'] as List<dynamic>? ?? [];
    return dataList
        .map((json) => ExperienceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
