import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/entities/admin_user_statistics_entity.dart';
import '../../domain/entities/paginated_users_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<AdminEntity> pendingUsers;
  const AdminLoaded(this.pendingUsers);

  @override
  List<Object?> get props => [pendingUsers];
}

class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminStatisticsLoaded extends AdminState {
  final AdminUserStatisticsEntity statistics;
  const AdminStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class AdminUsersListLoading extends AdminState {}

class AdminUsersListLoaded extends AdminState {
  final PaginatedUsersEntity paginatedUsers;
  const AdminUsersListLoaded(this.paginatedUsers);

  @override
  List<Object?> get props => [paginatedUsers];
}

class AdminUsersListError extends AdminState {
  final String message;
  const AdminUsersListError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserStatusToggledSuccess extends AdminState {
  final String message;
  const UserStatusToggledSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
