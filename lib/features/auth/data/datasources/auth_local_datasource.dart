import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> saveUser(AuthUserEntity user);
  Future<AuthUserEntity?> getUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService _secureStorageService;

  AuthLocalDataSourceImpl(this._secureStorageService);

  @override
  Future<void> saveToken(String token) async {
    await _secureStorageService.writeToken(token);
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorageService.readToken();
  }

  @override
  Future<void> clearToken() async {
    await _secureStorageService.deleteToken();
  }

  @override
  Future<void> saveUser(AuthUserEntity user) async {
    await _secureStorageService.writeUserName(user.name);
    await _secureStorageService.writeUserEmail(user.email);
    await _secureStorageService.writeUserRole(user.role);
    await _secureStorageService.writeApprovalStatus(user.approvalStatus);
    await _secureStorageService.writeUserPhone(user.phoneNumber);
  }

  @override
  Future<AuthUserEntity?> getUser() async {
    final email = await _secureStorageService.readUserEmail();
    final name = await _secureStorageService.readUserName();
    final role = await _secureStorageService.readUserRole();
    final status = await _secureStorageService.readApprovalStatus();
    final phone = await _secureStorageService.readUserPhone() ?? '';

    if (email == null || email.isEmpty ||
        name == null || name.isEmpty ||
        role == null || role.isEmpty ||
        status == null || status.isEmpty) {
      return null;
    }

    return AuthUserEntity(
      name: name,
      email: email,
      phoneNumber: phone,
      role: role,
      approvalStatus: status,
    );
  }

  @override
  Future<void> clearUser() async {
    await _secureStorageService.writeUserName('');
    await _secureStorageService.writeUserEmail('');
    await _secureStorageService.writeUserRole('');
    await _secureStorageService.writeApprovalStatus('');
    await _secureStorageService.writeUserPhone('');
  }
}
