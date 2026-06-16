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
  const RejectUser(this.userId);

  @override
  List<Object?> get props => [userId];
}
