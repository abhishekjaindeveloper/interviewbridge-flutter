import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingUsers extends AdminEvent {}

class ApproveUser extends AdminEvent {
  final String userId;
  const ApproveUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RejectUser extends AdminEvent {
  final String userId;
  final String reason;
  const RejectUser(this.userId, this.reason);

  @override
  List<Object?> get props => [userId, reason];
}

class LoadAdminStatistics extends AdminEvent {}

class LoadUsersList extends AdminEvent {
  final int page;
  final int size;
  final String? search;
  final String? approvalStatus;
  final bool? isActive;

  const LoadUsersList({
    required this.page,
    required this.size,
    this.search,
    this.approvalStatus,
    this.isActive,
  });

  @override
  List<Object?> get props => [page, size, search, approvalStatus, isActive];
}

class ActivateUserAccount extends AdminEvent {
  final String userId;
  const ActivateUserAccount(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DeactivateUserAccount extends AdminEvent {
  final String userId;
  const DeactivateUserAccount(this.userId);

  @override
  List<Object?> get props => [userId];
}
