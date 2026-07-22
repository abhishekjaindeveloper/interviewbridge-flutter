import '../../domain/entities/user_entity.dart';

class UserModel extends AuthUserEntity {
  const UserModel({
    super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.role,
    required super.approvalStatus,
    super.isActive,
    super.rejectionReason,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? '',
      approvalStatus: json['approvalStatus'] as String? ?? '',
      isActive: json['isActive'] as bool?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'approvalStatus': approvalStatus,
      if (isActive != null) 'isActive': isActive,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }
}
