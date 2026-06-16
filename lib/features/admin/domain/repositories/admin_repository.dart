import '../entities/admin_entity.dart';

abstract class AdminRepository {
  Future<List<AdminEntity>> getPendingUsers();
  Future<void> approveUser(String id);
  Future<void> rejectUser(String id);
}
