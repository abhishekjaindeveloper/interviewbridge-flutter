import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<ProfileEntity> call(String name, String technologyId, String experienceId) async {
    return await _repository.updateProfile(name, technologyId, experienceId);
  }
}
