import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

class ApiInterceptors extends Interceptor {
  final SecureStorageService _storageService;

  ApiInterceptors(this._storageService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Custom error logging or session expiration checks can go here
    super.onError(err, handler);
  }
}
