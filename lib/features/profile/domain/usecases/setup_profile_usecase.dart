import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class SetupProfileUseCase {
  final ProfileRepository _repository;

  SetupProfileUseCase(this._repository);

  Future<ProfileEntity> call(String technologyId, String experienceId) async {
    return await _repository.setupProfile(technologyId, experienceId);
  }
}
