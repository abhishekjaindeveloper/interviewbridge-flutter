import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> writeToken(String token) async {
    await _storage.write(key: StorageConstants.keyJwtToken, value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: StorageConstants.keyJwtToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: StorageConstants.keyJwtToken);
  }

  Future<void> writeUserEmail(String email) async {
    await _storage.write(key: StorageConstants.keyUserEmail, value: email);
  }

  Future<String?> readUserEmail() async {
    return await _storage.read(key: StorageConstants.keyUserEmail);
  }

  Future<void> writeUserName(String name) async {
    await _storage.write(key: StorageConstants.keyUserName, value: name);
  }

  Future<String?> readUserName() async {
    return await _storage.read(key: StorageConstants.keyUserName);
  }

  Future<void> writeUserRole(String role) async {
    await _storage.write(key: StorageConstants.keyUserRole, value: role);
  }

  Future<String?> readUserRole() async {
    return await _storage.read(key: StorageConstants.keyUserRole);
  }

  Future<void> writeApprovalStatus(String status) async {
    await _storage.write(key: StorageConstants.keyApprovalStatus, value: status);
  }

  Future<String?> readApprovalStatus() async {
    return await _storage.read(key: StorageConstants.keyApprovalStatus);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
