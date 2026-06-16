import '../repositories/experience_repository.dart';

class ActivateExperienceUseCase {
  final ExperienceRepository _repository;

  ActivateExperienceUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.activateExperience(id);
  }
}
