import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class ValidateTokenUseCase {
  final AuthRepository _repository;

  ValidateTokenUseCase(this._repository);

  Future<AuthUserEntity> call() async {
    return await _repository.validateToken();
  }
}
