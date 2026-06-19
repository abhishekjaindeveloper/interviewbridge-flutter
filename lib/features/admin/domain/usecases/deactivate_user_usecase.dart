import '../repositories/admin_repository.dart';

class DeactivateUserUseCase {
  final AdminRepository repository;

  DeactivateUserUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deactivateUser(id);
  }
}
