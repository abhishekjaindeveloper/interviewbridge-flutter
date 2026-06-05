import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/submit_answer_response_entity.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/question_remote_datasource.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionRemoteDataSource _remoteDataSource;

  QuestionRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<QuestionEntity>> getSessionQuestions(String sessionId) async {
    try {
      final models = await _remoteDataSource.getSessionQuestions(sessionId);
      return models.map((m) => m.toEntity()).toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<QuestionEntity> getQuestionByNumber(String sessionId, int questionNumber) async {
    try {
      final model = await _remoteDataSource.getQuestionByNumber(sessionId, questionNumber);
      return model.toEntity();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<QuestionEntity> getQuestionDetails(String questionId) async {
    try {
      final model = await _remoteDataSource.getQuestionDetails(questionId);
      return model.toEntity();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<SubmitAnswerResponseEntity> submitAnswer(String questionId, String answer) async {
    try {
      final model = await _remoteDataSource.submitAnswer(questionId, answer);
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
