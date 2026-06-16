import '../entities/experience_entity.dart';
import '../repositories/experience_repository.dart';

class GetAllExperiencesUseCase {
  final ExperienceRepository _repository;

  GetAllExperiencesUseCase(this._repository);

  Future<List<ExperienceEntity>> call() async {
    return await _repository.getAllExperiences();
  }
}
