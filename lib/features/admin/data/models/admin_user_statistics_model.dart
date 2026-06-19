import '../../domain/entities/admin_user_statistics_entity.dart';

class AdminUserStatisticsModel extends AdminUserStatisticsEntity {
  const AdminUserStatisticsModel({
    required super.totalUsers,
    required super.activeUsers,
    required super.inactiveUsers,
    required super.pendingUsers,
  });

  factory AdminUserStatisticsModel.fromJson(Map<String, dynamic> json) {
    return AdminUserStatisticsModel(
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
      inactiveUsers: json['inactiveUsers'] as int? ?? 0,
      pendingUsers: json['pendingUsers'] as int? ?? 0,
    );
  }
}
