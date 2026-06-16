import '../repositories/admin_repository.dart';

class ApproveUserUseCase {
  final AdminRepository repository;

  ApproveUserUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.approveUser(id);
  }
}
