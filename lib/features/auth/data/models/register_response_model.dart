import '../../domain/entities/user_entity.dart';

class RegisterResponseModel {
  final String token;
  final String email;
  final String name;
  final String role;
  final String approvalStatus;

  const RegisterResponseModel({
    required this.token,
    required this.email,
    required this.name,
    required this.role,
    required this.approvalStatus,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      token: json['token'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      approvalStatus: json['approvalStatus'] as String? ?? '',
    );
  }

  AuthUserEntity toEntity() {
    return AuthUserEntity(
      name: name,
      email: email,
      role: role,
      approvalStatus: approvalStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'name': name,
      'role': role,
      'approvalStatus': approvalStatus,
    };
  }
}
