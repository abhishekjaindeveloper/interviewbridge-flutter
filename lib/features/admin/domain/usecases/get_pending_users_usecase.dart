import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class GetPendingUsersUseCase {
  final AdminRepository repository;

  GetPendingUsersUseCase(this.repository);

  Future<List<AdminEntity>> call() async {
    return await repository.getPendingUsers();
  }
}
