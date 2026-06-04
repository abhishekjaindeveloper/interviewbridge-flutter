import '../../domain/entities/auth_token_entity.dart';

class AuthTokenModel extends AuthTokenEntity {
  const AuthTokenModel({required super.token});

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
