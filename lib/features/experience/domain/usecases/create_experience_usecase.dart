import '../entities/experience_entity.dart';
import '../repositories/experience_repository.dart';

class CreateExperienceUseCase {
  final ExperienceRepository _repository;

  CreateExperienceUseCase(this._repository);

  Future<ExperienceEntity> call(String label) async {
    return await _repository.createExperience(label);
  }
}
