import '../../domain/entities/user_entity.dart';

class UserModel extends AuthUserEntity {
  const UserModel({
    required super.name,
    required super.email,
    required super.role,
    required super.approvalStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      approvalStatus: json['approvalStatus'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'approvalStatus': approvalStatus,
    };
  }
}
