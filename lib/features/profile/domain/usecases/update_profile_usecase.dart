import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<ProfileEntity> call(
    String name,
    String technologyId,
    String experienceId, {
    String? preferredJobRole,
    String? preferredLocation,
    String? preferredWorkMode,
    double? expectedSalary,
    bool? jobAlertEnabled,
  }) async {
    return await _repository.updateProfile(
      name,
      technologyId,
      experienceId,
      preferredJobRole: preferredJobRole,
      preferredLocation: preferredLocation,
      preferredWorkMode: preferredWorkMode,
      expectedSalary: expectedSalary,
      jobAlertEnabled: jobAlertEnabled,
    );
  }
}
