import '../../domain/entities/user_entity.dart';

class RegisterResponseModel {
  final String token;
  final String email;
  final String name;
  final String phoneNumber;
  final String role;
  final String approvalStatus;

  const RegisterResponseModel({
    required this.token,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.approvalStatus,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      token: json['token'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? '',
      approvalStatus: json['approvalStatus'] as String? ?? '',
    );
  }

  AuthUserEntity toEntity() {
    return AuthUserEntity(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      approvalStatus: approvalStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role,
      'approvalStatus': approvalStatus,
    };
  }
}
