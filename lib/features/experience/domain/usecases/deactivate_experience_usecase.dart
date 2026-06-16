import '../repositories/experience_repository.dart';

class DeactivateExperienceUseCase {
  final ExperienceRepository _repository;

  DeactivateExperienceUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.deactivateExperience(id);
  }
}
