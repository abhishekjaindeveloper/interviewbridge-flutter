import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(
    String name,
    String technologyId,
    String experienceId, {
    String? preferredJobRole,
    String? preferredLocation,
    String? preferredWorkMode,
    double? expectedSalary,
    bool? jobAlertEnabled,
  });
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
  Future<ProfileModel> updateProfile(
    String name,
    String technologyId,
    String experienceId, {
    String? preferredJobRole,
    String? preferredLocation,
    String? preferredWorkMode,
    double? expectedSalary,
    bool? jobAlertEnabled,
  }) async {
    final Map<String, dynamic> body = {'name': name};
    if (technologyId.isNotEmpty) {
      body['technologyId'] = technologyId;
    }
    if (experienceId.isNotEmpty) {
      body['experienceId'] = experienceId;
    }
    if (preferredJobRole != null) {
      body['preferredJobRole'] = preferredJobRole;
    }
    if (preferredLocation != null) {
      body['preferredLocation'] = preferredLocation;
    }
    if (preferredWorkMode != null) {
      body['preferredWorkMode'] = preferredWorkMode;
    }
    if (expectedSalary != null) {
      body['expectedSalary'] = expectedSalary;
    }
    if (jobAlertEnabled != null) {
      body['jobAlertEnabled'] = jobAlertEnabled;
    }
    final response = await _apiClient.put(
      ApiConstants.userProfile,
      data: body,
    );
    final data = response.data['data'] as Map<String, dynamic>;
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
