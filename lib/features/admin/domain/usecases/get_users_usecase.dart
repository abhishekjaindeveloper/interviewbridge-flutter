import '../repositories/admin_repository.dart';
import '../entities/paginated_users_entity.dart';

class GetUsersUseCase {
  final AdminRepository repository;

  GetUsersUseCase(this.repository);

  Future<PaginatedUsersEntity> call(
    int page,
    int size, {
    String? search,
    String? approvalStatus,
    bool? isActive,
  }) async {
    return await repository.getUsers(
      page,
      size,
      search: search,
      approvalStatus: approvalStatus,
      isActive: isActive,
    );
  }
}
