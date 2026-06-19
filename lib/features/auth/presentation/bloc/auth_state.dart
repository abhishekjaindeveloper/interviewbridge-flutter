import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final AuthUserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthRejected extends AuthState {
  final String rejectionReason;

  const AuthRejected(this.rejectionReason);

  @override
  List<Object?> get props => [rejectionReason];
}

class PhoneAlreadyRegistered extends AuthState {
  final String message;
  const PhoneAlreadyRegistered(this.message);

  @override
  List<Object?> get props => [message];
}

class EmailAlreadyRegistered extends AuthState {
  final String message;
  const EmailAlreadyRegistered(this.message);

  @override
  List<Object?> get props => [message];
}
