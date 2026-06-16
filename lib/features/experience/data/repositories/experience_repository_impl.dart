import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/experience_entity.dart';
import '../../domain/repositories/experience_repository.dart';
import '../datasources/experience_remote_datasource.dart';

class ExperienceRepositoryImpl implements ExperienceRepository {
  final ExperienceRemoteDataSource _remoteDataSource;

  ExperienceRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ExperienceEntity>> getActiveExperiences() async {
    try {
      final models = await _remoteDataSource.getActiveExperiences();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<ExperienceEntity>> getAllExperiences() async {
    try {
      final models = await _remoteDataSource.getAllExperiences();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<ExperienceEntity> createExperience(String label) async {
    try {
      final model = await _remoteDataSource.createExperience(label);
      return model.toEntity();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<ExperienceEntity> updateExperience(String id, String label) async {
    try {
      final model = await _remoteDataSource.updateExperience(id, label);
      return model.toEntity();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> activateExperience(String id) async {
    try {
      await _remoteDataSource.activateExperience(id);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> deactivateExperience(String id) async {
    try {
      await _remoteDataSource.deactivateExperience(id);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  AppException _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException(AppConstants.noConnection);
    }
    
    if (e.type == DioExceptionType.connectionError) {
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

      if (status == 401 || status == 403) {
        return UnauthorizedException(message);
      }

      return ServerException(message);
    }

    return AppException(AppConstants.errorGeneric);
  }
}
