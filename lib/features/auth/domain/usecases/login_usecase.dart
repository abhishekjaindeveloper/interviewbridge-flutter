import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthUserEntity> call(String email, String password) async {
    return await _repository.login(email, password);
  }
}
