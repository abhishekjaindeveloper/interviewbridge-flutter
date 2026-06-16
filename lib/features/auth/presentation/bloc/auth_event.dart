import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final bool termsAccepted;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.termsAccepted,
  });

  @override
  List<Object?> get props => [name, email, phoneNumber, password, termsAccepted];
}

class LogoutRequested extends AuthEvent {}

class LoadCurrentUser extends AuthEvent {}

class ClearRegistrationState extends AuthEvent {}
