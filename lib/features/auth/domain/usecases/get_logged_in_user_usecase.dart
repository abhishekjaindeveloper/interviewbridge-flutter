import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetLoggedInUserUseCase {
  final AuthRepository _repository;

  GetLoggedInUserUseCase(this._repository);

  Future<AuthUserEntity?> call() async {
    return await _repository.getLoggedInUser();
  }
}
