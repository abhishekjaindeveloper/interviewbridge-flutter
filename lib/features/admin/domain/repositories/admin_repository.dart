import '../entities/admin_entity.dart';
import '../entities/admin_user_statistics_entity.dart';
import '../entities/paginated_users_entity.dart';

abstract class AdminRepository {
  Future<List<AdminEntity>> getPendingUsers();
  Future<void> approveUser(String id);
  Future<void> rejectUser(String id, String reason);
  Future<AdminUserStatisticsEntity> getUserStatistics();
  Future<PaginatedUsersEntity> getUsers(int page, int size, {String? search, String? approvalStatus, bool? isActive});
  Future<void> activateUser(String id);
  Future<void> deactivateUser(String id);
}
