import '../entities/experience_entity.dart';

abstract class ExperienceRepository {
  Future<List<ExperienceEntity>> getActiveExperiences();
  Future<List<ExperienceEntity>> getAllExperiences();
  Future<ExperienceEntity> createExperience(String label);
  Future<ExperienceEntity> updateExperience(String id, String label);
  Future<void> activateExperience(String id);
  Future<void> deactivateExperience(String id);
}
