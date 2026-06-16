import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/technology_entity.dart';
import '../../domain/repositories/technology_repository.dart';
import '../datasources/technology_remote_datasource.dart';

class TechnologyRepositoryImpl implements TechnologyRepository {
  final TechnologyRemoteDataSource _remoteDataSource;

  TechnologyRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TechnologyEntity>> getActiveTechnologies() async {
    try {
      final models = await _remoteDataSource.getActiveTechnologies();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<TechnologyEntity>> getAllTechnologies() async {
    try {
      final models = await _remoteDataSource.getAllTechnologies();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<TechnologyEntity> createTechnology(String name, String description) async {
    try {
      final model = await _remoteDataSource.createTechnology(name, description);
      return model.toEntity();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<TechnologyEntity> updateTechnology(String id, String name, String description) async {
    try {
      final model = await _remoteDataSource.updateTechnology(id, name, description);
      return model.toEntity();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> activateTechnology(String id) async {
    try {
      await _remoteDataSource.activateTechnology(id);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> deactivateTechnology(String id) async {
    try {
      await _remoteDataSource.deactivateTechnology(id);
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
