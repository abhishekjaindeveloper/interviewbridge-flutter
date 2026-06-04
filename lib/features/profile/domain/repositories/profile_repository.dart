import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updateProfile(String name, String technologyId, String experienceId);
  Future<ProfileEntity> setupProfile(String technologyId, String experienceId);
}
