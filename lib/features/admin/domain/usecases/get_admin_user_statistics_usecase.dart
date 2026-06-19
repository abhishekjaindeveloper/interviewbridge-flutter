import '../repositories/admin_repository.dart';
import '../entities/admin_user_statistics_entity.dart';

class GetAdminUserStatisticsUseCase {
  final AdminRepository repository;

  GetAdminUserStatisticsUseCase(this.repository);

  Future<AdminUserStatisticsEntity> call() async {
    return await repository.getUserStatistics();
  }
}
