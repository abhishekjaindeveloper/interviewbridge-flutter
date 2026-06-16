import '../repositories/technology_repository.dart';

class ActivateTechnologyUseCase {
  final TechnologyRepository _repository;

  ActivateTechnologyUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.activateTechnology(id);
  }
}
