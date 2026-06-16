import '../entities/technology_entity.dart';
import '../repositories/technology_repository.dart';

class CreateTechnologyUseCase {
  final TechnologyRepository _repository;

  CreateTechnologyUseCase(this._repository);

  Future<TechnologyEntity> call(String name, String description) async {
    return await _repository.createTechnology(name, description);
  }
}
