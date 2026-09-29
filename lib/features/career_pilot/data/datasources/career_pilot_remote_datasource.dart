import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/matched_job_model.dart';

abstract class CareerPilotRemoteDataSource {
  Future<List<MatchedJobModel>> getMatchedJobs();
  Future<MatchedJobModel> getJobDetails(String jobId);
}

class CareerPilotRemoteDataSourceImpl implements CareerPilotRemoteDataSource {
  final ApiClient _apiClient;

  CareerPilotRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<MatchedJobModel>> getMatchedJobs() async {
    final response = await _apiClient.get(ApiConstants.userMatchedJobs);
    final data = response.data;
    if (data != null && data['data'] != null) {
      final list = data['data'] as List<dynamic>;
      return list
          .map((json) => MatchedJobModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<MatchedJobModel> getJobDetails(String jobId) async {
    final response = await _apiClient.get(ApiConstants.userJobDetailsUrl(jobId));
    final data = response.data;
    if (data != null && data['data'] != null) {
      return MatchedJobModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load job details');
  }
}
