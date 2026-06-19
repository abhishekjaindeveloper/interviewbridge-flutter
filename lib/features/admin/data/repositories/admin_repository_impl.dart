import '../../domain/entities/admin_entity.dart';
import '../../domain/entities/admin_user_statistics_entity.dart';
import '../../domain/entities/paginated_users_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AdminEntity>> getPendingUsers() async {
    return await remoteDataSource.getPendingUsers();
  }

  @override
  Future<void> approveUser(String id) async {
    await remoteDataSource.approveUser(id);
  }

  @override
  Future<void> rejectUser(String id, String reason) async {
    await remoteDataSource.rejectUser(id, reason);
  }

  @override
  Future<AdminUserStatisticsEntity> getUserStatistics() async {
    return await remoteDataSource.getUserStatistics();
  }

  @override
  Future<PaginatedUsersEntity> getUsers(
    int page,
    int size, {
    String? search,
    String? approvalStatus,
    bool? isActive,
  }) async {
    return await remoteDataSource.getUsers(
      page,
      size,
      search: search,
      approvalStatus: approvalStatus,
      isActive: isActive,
    );
  }

  @override
  Future<void> activateUser(String id) async {
    await remoteDataSource.activateUser(id);
  }

  @override
  Future<void> deactivateUser(String id) async {
    await remoteDataSource.deactivateUser(id);
  }
}
