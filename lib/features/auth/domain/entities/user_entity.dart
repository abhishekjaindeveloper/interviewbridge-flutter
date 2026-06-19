import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String approvalStatus;

  const AuthUserEntity({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.approvalStatus,
  });

  @override
  List<Object?> get props => [name, email, phoneNumber, role, approvalStatus];
}
