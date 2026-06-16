import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/experience_model.dart';

abstract class ExperienceRemoteDataSource {
  Future<List<ExperienceModel>> getActiveExperiences();
  Future<List<ExperienceModel>> getAllExperiences();
  Future<ExperienceModel> createExperience(String label);
  Future<ExperienceModel> updateExperience(String id, String label);
  Future<void> activateExperience(String id);
  Future<void> deactivateExperience(String id);
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

  @override
  Future<List<ExperienceModel>> getAllExperiences() async {
    final response = await _apiClient.get(ApiConstants.adminExperiences);
    final dataList = response.data['data'] as List<dynamic>? ?? [];
    return dataList
        .map((json) => ExperienceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ExperienceModel> createExperience(String label) async {
    final response = await _apiClient.post(
      ApiConstants.adminExperiences,
      data: {
        'experienceLabel': label,
      },
    );
    return ExperienceModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ExperienceModel> updateExperience(String id, String label) async {
    final response = await _apiClient.put(
      '${ApiConstants.adminExperiences}/$id',
      data: {
        'experienceLabel': label,
      },
    );
    return ExperienceModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> activateExperience(String id) async {
    await _apiClient.patch('${ApiConstants.adminExperiences}/$id/activate');
  }

  @override
  Future<void> deactivateExperience(String id) async {
    await _apiClient.patch('${ApiConstants.adminExperiences}/$id/deactivate');
  }
}
