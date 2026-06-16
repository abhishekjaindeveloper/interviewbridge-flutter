import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<AuthUserEntity> call(
    String name,
    String email,
    String phoneNumber,
    String password,
    bool termsAccepted,
  ) async {
    return await _repository.register(name, email, phoneNumber, password, termsAccepted);
  }
}
