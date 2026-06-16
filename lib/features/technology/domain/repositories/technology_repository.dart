import '../entities/technology_entity.dart';

abstract class TechnologyRepository {
  Future<List<TechnologyEntity>> getActiveTechnologies();
  Future<List<TechnologyEntity>> getAllTechnologies();
  Future<TechnologyEntity> createTechnology(String name, String description);
  Future<TechnologyEntity> updateTechnology(String id, String name, String description);
  Future<void> activateTechnology(String id);
  Future<void> deactivateTechnology(String id);
}
