import 'package:equatable/equatable.dart';

class AdminEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;
  final String approvalStatus;
  final DateTime? createdAt;

  const AdminEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.approvalStatus,
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
        createdAt,
      ];
}
