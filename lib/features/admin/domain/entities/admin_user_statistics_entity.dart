import 'package:equatable/equatable.dart';

class AdminUserStatisticsEntity extends Equatable {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int pendingUsers;

  const AdminUserStatisticsEntity({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.pendingUsers,
  });

  @override
  List<Object?> get props => [totalUsers, activeUsers, inactiveUsers, pendingUsers];
}
