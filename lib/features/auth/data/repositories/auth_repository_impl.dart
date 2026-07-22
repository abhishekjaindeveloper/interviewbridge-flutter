import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<AuthUserEntity> login(String email, String password) async {
    try {
      final model = await _remoteDataSource.login(email, password);
      await _localDataSource.saveToken(model.token);
      final entity = model.toEntity();
      await _localDataSource.saveUser(entity);
      return entity;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<AuthUserEntity> register(
    String name,
    String email,
    String phoneNumber,
    String password,
    bool termsAccepted,
  ) async {
    try {
      final model = await _remoteDataSource.register(
        name,
        email,
        phoneNumber,
        password,
        termsAccepted,
      );
      if (model.token.isNotEmpty) {
        await _localDataSource.saveToken(model.token);
      }
      final entity = model.toEntity();
      await _localDataSource.saveUser(entity);
      return entity;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearToken();
    await _localDataSource.clearUser();
  }

  bool _isJwtExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }
      String payload = parts[1];
      int padding = 4 - (payload.length % 4);
      if (padding != 4) {
        payload += '=' * padding;
      }
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      final decodedString = utf8.decode(base64Decode(payload));
      final decodedMap = jsonDecode(decodedString);
      if (decodedMap is Map<String, dynamic> && decodedMap.containsKey('exp')) {
        final exp = decodedMap['exp'] as int;
        final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        return DateTime.now().isAfter(expDate);
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<AuthUserEntity?> getLoggedInUser() async {
    try {
      final token = await _localDataSource.getToken();
      if (token == null || token.isEmpty || _isJwtExpired(token)) {
        await logout();
        return null;
      }
      final user = await _localDataSource.getUser();
      if (user == null) {
        await logout();
        return null;
      }
      return user;
    } catch (_) {
      try {
        await logout();
      } catch (_) {}
      return null;
    }
  }

  @override
  Future<AuthUserEntity> validateToken() async {
    try {
      final model = await _remoteDataSource.validateToken();
      await _localDataSource.saveUser(model);
      return model;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  AppException _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(AppConstants.noConnection);
    }

    if (e.response != null) {
      final status = e.response!.statusCode;
      final data = e.response!.data;
      
      String message = AppConstants.errorGeneric;
      String rejectionReason = '';
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          final serverMsg = data['message'] as String?;
          if (serverMsg != null && serverMsg.isNotEmpty) {
            message = serverMsg;
          }
        }
        if (data.containsKey('rejectionReason')) {
          final serverReason = data['rejectionReason'] as String?;
          if (serverReason != null && serverReason.isNotEmpty) {
            rejectionReason = serverReason;
          }
        }
      }

      final normalizedMsg = message.toLowerCase();

      if (normalizedMsg.contains('email or phone number not found') || normalizedMsg.contains('user not found')) {
        return InvalidCredentialsException(AppConstants.errorUserNotFound);
      }

      if (normalizedMsg.contains('incorrect password')) {
        return InvalidCredentialsException(AppConstants.errorIncorrectPassword);
      }

      if (normalizedMsg.contains('pending admin approval') || normalizedMsg.contains('pending approval')) {
        return AccountPendingApprovalException(AppConstants.pendingUserMessage);
      }

      if (normalizedMsg.contains('rejected') || (data is Map<String, dynamic> && data['rejectionReason'] != null)) {
        return UserRejectedException(rejectionReason.isNotEmpty ? rejectionReason : AppConstants.notAvailablePlaceholder);
      }

      if (normalizedMsg.contains('phone number already registered')) {
        return PhoneAlreadyRegisteredException();
      }

      if (normalizedMsg.contains('email already exists') || normalizedMsg.contains('email address already registered')) {
        return EmailAlreadyRegisteredException();
      }

      if (normalizedMsg.contains('inactive') || normalizedMsg.contains('disabled')) {
        return InvalidCredentialsException(AppConstants.errorDisabledAccount);
      }

      if (normalizedMsg.contains('invalid email or password') || normalizedMsg.contains('invalid credentials')) {
        return InvalidCredentialsException(AppConstants.errorInvalidCredentials);
      }

      if (status == 401) {
        return UnauthorizedException(message);
      }

      if (status == 403) {
        return AccessDeniedException(message);
      }

      return ServerException(message);
    }

    return AppException(AppConstants.errorGeneric);
  }
}
