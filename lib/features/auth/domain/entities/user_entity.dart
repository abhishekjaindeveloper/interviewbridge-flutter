import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  final String? id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String approvalStatus;
  final bool? isActive;
  final String? rejectionReason;

  const AuthUserEntity({
    this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.approvalStatus,
    this.isActive,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [id, name, email, phoneNumber, role, approvalStatus, isActive, rejectionReason];
}
