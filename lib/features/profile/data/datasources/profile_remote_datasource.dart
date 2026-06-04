import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(String name, String technologyId, String experienceId);
  Future<ProfileModel> setupProfile(String technologyId, String experienceId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ProfileModel> getProfile() async {
    final response = await _apiClient.get(ApiConstants.userProfile);
    final data = response.data['data'] as Map<String, dynamic>;
    return ProfileModel.fromJson(data);
  }

  @override
  Future<ProfileModel> updateProfile(String name, String technologyId, String experienceId) async {
    final response = await _apiClient.put(
      ApiConstants.userProfile,
      data: {
        'technologyId': technologyId,
        'experienceId': experienceId,
        'name': name,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    // Override the name field with updated name since backend doesn't save it
    data['name'] = name;
    return ProfileModel.fromJson(data);
  }

  @override
  Future<ProfileModel> setupProfile(String technologyId, String experienceId) async {
    final response = await _apiClient.post(
      ApiConstants.userProfileSelection,
      data: {
        'technologyId': technologyId,
        'experienceId': experienceId,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return ProfileModel.fromJson(data);
  }
}
