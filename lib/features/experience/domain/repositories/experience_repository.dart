import '../entities/experience_entity.dart';

abstract class ExperienceRepository {
  Future<List<ExperienceEntity>> getActiveExperiences();
}
