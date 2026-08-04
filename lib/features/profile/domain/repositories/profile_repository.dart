import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updateProfile(
    String name,
    String technologyId,
    String experienceId, {
    String? preferredJobRole,
    String? preferredLocation,
    String? preferredWorkMode,
    double? expectedSalary,
    bool? jobAlertEnabled,
  });
  Future<ProfileEntity> setupProfile(String technologyId, String experienceId);
}
