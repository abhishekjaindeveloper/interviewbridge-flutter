import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/technology_model.dart';

abstract class TechnologyRemoteDataSource {
  Future<List<TechnologyModel>> getActiveTechnologies();
  Future<List<TechnologyModel>> getAllTechnologies();
  Future<TechnologyModel> createTechnology(String name, String description);
  Future<TechnologyModel> updateTechnology(String id, String name, String description);
  Future<void> activateTechnology(String id);
  Future<void> deactivateTechnology(String id);
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

  @override
  Future<List<TechnologyModel>> getAllTechnologies() async {
    final response = await _apiClient.get(ApiConstants.adminTechnologies);
    final dataList = response.data['data'] as List<dynamic>? ?? [];
    return dataList
        .map((json) => TechnologyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TechnologyModel> createTechnology(String name, String description) async {
    final response = await _apiClient.post(
      ApiConstants.adminTechnologies,
      data: {
        'technologyName': name,
        'description': description,
      },
    );
    return TechnologyModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<TechnologyModel> updateTechnology(String id, String name, String description) async {
    final response = await _apiClient.put(
      '${ApiConstants.adminTechnologies}/$id',
      data: {
        'technologyName': name,
        'description': description,
      },
    );
    return TechnologyModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> activateTechnology(String id) async {
    await _apiClient.patch('${ApiConstants.adminTechnologies}/$id/activate');
  }

  @override
  Future<void> deactivateTechnology(String id) async {
    await _apiClient.patch('${ApiConstants.adminTechnologies}/$id/deactivate');
  }
}
