import 'package:equatable/equatable.dart';

class AdminEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;
  final String approvalStatus;
  final bool isActive;
  final DateTime? createdAt;

  const AdminEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.approvalStatus,
    this.isActive = true,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phoneNumber,
        role,
        approvalStatus,
        isActive,
        createdAt,
      ];
}
