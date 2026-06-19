import '../repositories/admin_repository.dart';

class RejectUserUseCase {
  final AdminRepository repository;

  RejectUserUseCase(this.repository);

  Future<void> call(String id, String reason) async {
    await repository.rejectUser(id, reason);
  }
}
