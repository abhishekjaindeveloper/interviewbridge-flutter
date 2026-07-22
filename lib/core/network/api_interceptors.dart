import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/secure_storage_service.dart';
import '../constants/api_constants.dart';
import '../routes/route_navigator.dart';
import '../routes/route_constants.dart';
import '../widgets/error_dialog.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

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
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;
      final isPublic = path.contains('/api/auth/login') || path.contains('/api/auth/register');

      if (!isPublic) {
        final authHeader = err.requestOptions.headers['Authorization'] as String?;
        final hasAuth = authHeader != null && authHeader.isNotEmpty;

        if (hasAuth) {
          final context = RouteNavigator.navigatorKey.currentContext;
          if (context != null) {
            Future.microtask(() async {
              await _storageService.clearAuthData();
              
              final isValidateToken = path.endsWith(ApiConstants.validateToken) || path.contains(ApiConstants.validateToken);
              if (context.mounted && !isValidateToken) {
                ErrorDialog.show(
                  context: context,
                  title: 'Session Expired',
                  message: 'Your session has expired. Please login again.',
                  confirmButtonText: 'Login',
                  onConfirm: () {
                    final authBloc = context.read<AuthBloc>();
                    authBloc.add(LogoutRequested());
                    
                    RouteNavigator.pushNamedAndRemoveUntil(
                      RouteConstants.login,
                      (route) => false,
                    );
                  },
                );
              }
            });
          }
        }
      }
    }
    super.onError(err, handler);
  }
}
