import '../entities/experience_entity.dart';
import '../repositories/experience_repository.dart';

class UpdateExperienceUseCase {
  final ExperienceRepository _repository;

  UpdateExperienceUseCase(this._repository);

  Future<ExperienceEntity> call(String id, String label) async {
    return await _repository.updateExperience(id, label);
  }
}
