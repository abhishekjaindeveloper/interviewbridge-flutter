import 'package:dio/dio.dart';
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

  @override
  Future<AuthUserEntity?> getLoggedInUser() async {
    try {
      final token = await _localDataSource.getToken();
      if (token == null || token.isEmpty) {
        return null;
      }
      return await _localDataSource.getUser();
    } catch (_) {
      return null;
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
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        final serverMsg = data['message'] as String?;
        if (serverMsg != null && serverMsg.isNotEmpty) {
          message = serverMsg;
        }
      }

      final normalizedMsg = message.toLowerCase();

      if (normalizedMsg.contains('pending admin approval') || normalizedMsg.contains('pending approval')) {
        return AccountPendingApprovalException(AppConstants.errorPendingApproval);
      }

      if (normalizedMsg.contains('rejected')) {
        return AccessDeniedException(AppConstants.errorRejected);
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
