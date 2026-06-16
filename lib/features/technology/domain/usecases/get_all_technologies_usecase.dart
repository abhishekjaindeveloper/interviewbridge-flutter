import '../entities/technology_entity.dart';
import '../repositories/technology_repository.dart';

class GetAllTechnologiesUseCase {
  final TechnologyRepository _repository;

  GetAllTechnologiesUseCase(this._repository);

  Future<List<TechnologyEntity>> call() async {
    return await _repository.getAllTechnologies();
  }
}
