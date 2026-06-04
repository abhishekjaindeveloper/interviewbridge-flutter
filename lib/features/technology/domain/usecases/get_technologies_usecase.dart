import '../entities/technology_entity.dart';
import '../repositories/technology_repository.dart';

class GetTechnologiesUseCase {
  final TechnologyRepository _repository;

  GetTechnologiesUseCase(this._repository);

  Future<List<TechnologyEntity>> call() async {
    return await _repository.getActiveTechnologies();
  }
}
