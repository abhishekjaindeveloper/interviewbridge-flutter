import '../entities/technology_entity.dart';
import '../repositories/technology_repository.dart';

class UpdateTechnologyUseCase {
  final TechnologyRepository _repository;

  UpdateTechnologyUseCase(this._repository);

  Future<TechnologyEntity> call(String id, String name, String description) async {
    return await _repository.updateTechnology(id, name, description);
  }
}
