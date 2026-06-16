import '../repositories/admin_repository.dart';

class RejectUserUseCase {
  final AdminRepository repository;

  RejectUserUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.rejectUser(id);
  }
}
