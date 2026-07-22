import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/usecases/get_logged_in_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/validate_token_usecase.dart';
import '../../../../core/constants/app_constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetLoggedInUserUseCase getLoggedInUserUseCase;
  final ValidateTokenUseCase validateTokenUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getLoggedInUserUseCase,
    required this.validateTokenUseCase,
  }) : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<LoadCurrentUser>(_onLoadCurrentUser);
    on<ClearRegistrationState>(_onClearRegistrationState);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await getLoggedInUserUseCase();
      if (user != null) {
        try {
          final freshUser = await validateTokenUseCase();
          if (freshUser.approvalStatus == 'REJECTED') {
            await logoutUseCase();
            emit(AuthRejected(freshUser.rejectionReason ?? ''));
          } else if (freshUser.isActive == false) {
            await logoutUseCase();
            emit(AuthError(AppConstants.errorDisabledAccount));
          } else {
            emit(Authenticated(freshUser));
          }
        } on DioException catch (dioErr) {
          final statusCode = dioErr.response?.statusCode;
          if (statusCode == 401 || statusCode == 403 || statusCode == 404) {
            await logoutUseCase();
            emit(Unauthenticated());
          } else {
            // Server offline or connection timeout: gracefully fall back to cached user session
            emit(Authenticated(user));
          }
        } catch (_) {
          await logoutUseCase();
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(event.email, event.password);
      emit(Authenticated(user));
    } on UserRejectedException catch (e) {
      emit(AuthRejected(e.rejectionReason));
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      developer.log('Error in AuthBloc', error: e);
      emit(AuthError(AppConstants.errorGeneric));
    }
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(
        event.name,
        event.email,
        event.phoneNumber,
        event.password,
        event.termsAccepted,
      );
      emit(Authenticated(user));
    } on PhoneAlreadyRegisteredException catch (e) {
      emit(PhoneAlreadyRegistered(e.message));
    } on EmailAlreadyRegisteredException catch (e) {
      emit(EmailAlreadyRegistered(e.message));
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      developer.log('Error in AuthBloc', error: e);
      emit(AuthError(AppConstants.errorGeneric));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
    } catch (e) {
      developer.log('Error in AuthBloc logout', error: e);
    }
    emit(Unauthenticated());
  }

  void _onLoadCurrentUser(LoadCurrentUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await getLoggedInUserUseCase();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      developer.log('Error in AuthBloc', error: e);
      emit(AuthError(AppConstants.errorGeneric));
    }
  }

  void _onClearRegistrationState(ClearRegistrationState event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
      emit(Unauthenticated());
    } catch (e) {
      developer.log('Error clearing registration state', error: e);
      emit(Unauthenticated());
    }
  }
}
