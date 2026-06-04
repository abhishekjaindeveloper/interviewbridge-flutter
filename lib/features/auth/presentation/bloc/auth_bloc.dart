import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/usecases/get_logged_in_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetLoggedInUserUseCase getLoggedInUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getLoggedInUserUseCase,
  }) : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<LoadCurrentUser>(_onLoadCurrentUser);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await getLoggedInUserUseCase();
      if (user != null) {
        emit(Authenticated(user));
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
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(event.name, event.email, event.password);
      emit(Authenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
      emit(Unauthenticated());
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
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
      emit(AuthError(e.toString()));
    }
  }
}
