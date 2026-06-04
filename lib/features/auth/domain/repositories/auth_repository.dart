import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthUserEntity> login(String email, String password);
  Future<AuthUserEntity> register(String name, String email, String password);
  Future<void> logout();
  Future<AuthUserEntity?> getLoggedInUser();
}
