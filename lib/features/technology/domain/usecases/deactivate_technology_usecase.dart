import '../repositories/technology_repository.dart';

class DeactivateTechnologyUseCase {
  final TechnologyRepository _repository;

  DeactivateTechnologyUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.deactivateTechnology(id);
  }
}
