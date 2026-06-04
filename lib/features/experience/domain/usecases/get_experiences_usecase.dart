import '../entities/experience_entity.dart';
import '../repositories/experience_repository.dart';

class GetExperiencesUseCase {
  final ExperienceRepository _repository;

  GetExperiencesUseCase(this._repository);

  Future<List<ExperienceEntity>> call() async {
    return await _repository.getActiveExperiences();
  }
}
