import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/practice_session_entity.dart';
import '../../domain/repositories/practice_session_repository.dart';
import '../datasources/practice_session_remote_datasource.dart';

class PracticeSessionRepositoryImpl implements PracticeSessionRepository {
  final PracticeSessionRemoteDataSource _remoteDataSource;

  PracticeSessionRepositoryImpl(this._remoteDataSource);

  @override
  Future<PracticeSessionEntity> createSession(
    String technologyId,
    String experienceId,
    int totalQuestions,
  ) async {
    try {
      final model = await _remoteDataSource.createSession(technologyId, experienceId, totalQuestions);
      return model.toEntity();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<PracticeSessionEntity> getSessionDetails(String sessionId) async {
    try {
      final model = await _remoteDataSource.getSessionDetails(sessionId);
      return model.toEntity();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<PracticeSessionEntity>> getSessionHistory() async {
    try {
      final models = await _remoteDataSource.getSessionHistory();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> generateQuestions(String sessionId) async {
    try {
      await _remoteDataSource.generateQuestions(sessionId);
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
