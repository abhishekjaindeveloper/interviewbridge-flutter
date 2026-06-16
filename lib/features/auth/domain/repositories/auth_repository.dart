import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthUserEntity> login(String email, String password);
  Future<AuthUserEntity> register(
    String name,
    String email,
    String phoneNumber,
    String password,
    bool termsAccepted,
  );
  Future<void> logout();
  Future<AuthUserEntity?> getLoggedInUser();
}
