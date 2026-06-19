import '../repositories/admin_repository.dart';

class ActivateUserUseCase {
  final AdminRepository repository;

  ActivateUserUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.activateUser(id);
  }
}
