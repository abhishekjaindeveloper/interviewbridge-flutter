import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/technology_model.dart';

abstract class TechnologyRemoteDataSource {
  Future<List<TechnologyModel>> getActiveTechnologies();
}

class TechnologyRemoteDataSourceImpl implements TechnologyRemoteDataSource {
  final ApiClient _apiClient;

  TechnologyRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<TechnologyModel>> getActiveTechnologies() async {
    final response = await _apiClient.get(ApiConstants.userTechnologies);
    final dataList = response.data['data'] as List<dynamic>? ?? [];
    return dataList
        .map((json) => TechnologyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
