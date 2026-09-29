import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/matched_job_entity.dart';
import '../../domain/repositories/career_pilot_repository.dart';
import '../datasources/career_pilot_remote_datasource.dart';

class CareerPilotRepositoryImpl implements CareerPilotRepository {
  final CareerPilotRemoteDataSource _remoteDataSource;

  CareerPilotRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<MatchedJobEntity>> getMatchedJobs() async {
    try {
      return await _remoteDataSource.getMatchedJobs();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }

  @override
  Future<MatchedJobEntity> getJobDetails(String jobId) async {
    try {
      return await _remoteDataSource.getJobDetails(jobId);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
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

      if (status == 401 || status == 403) {
        return UnauthorizedException(message);
      }

      return ServerException(message);
    }

    return AppException(AppConstants.errorGeneric);
  }
}
