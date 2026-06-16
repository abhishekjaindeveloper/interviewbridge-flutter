import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_entity.dart';

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
