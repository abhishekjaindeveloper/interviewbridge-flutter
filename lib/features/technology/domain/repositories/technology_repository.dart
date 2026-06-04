import '../entities/technology_entity.dart';

abstract class TechnologyRepository {
  Future<List<TechnologyEntity>> getActiveTechnologies();
}
