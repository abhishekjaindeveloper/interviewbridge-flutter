import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/evaluation_entity.dart';
import '../../domain/repositories/evaluation_repository.dart';
import '../datasources/evaluation_remote_datasource.dart';

class EvaluationRepositoryImpl implements EvaluationRepository {
  final EvaluationRemoteDataSource _remoteDataSource;

  EvaluationRepositoryImpl(this._remoteDataSource);

  @override
  Future<EvaluationEntity> evaluateQuestion(String questionId) async {
    try {
      final model = await _remoteDataSource.evaluateQuestion(questionId);
      return model.toEntity();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<EvaluationEntity> getEvaluationResult(String questionId) async {
    try {
      final model = await _remoteDataSource.getEvaluationResult(questionId);
      return model.toEntity();
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
