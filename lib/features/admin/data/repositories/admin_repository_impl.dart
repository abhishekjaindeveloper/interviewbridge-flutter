import '../../domain/entities/admin_entity.dart';
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
  Future<void> rejectUser(String id) async {
    await remoteDataSource.rejectUser(id);
  }
}
