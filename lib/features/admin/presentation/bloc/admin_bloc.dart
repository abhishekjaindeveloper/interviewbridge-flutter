import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_event.dart';
import 'admin_state.dart';
import '../../domain/usecases/get_pending_users_usecase.dart';
import '../../domain/usecases/approve_user_usecase.dart';
import '../../domain/usecases/reject_user_usecase.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetPendingUsersUseCase getPendingUsersUseCase;
  final ApproveUserUseCase approveUserUseCase;
  final RejectUserUseCase rejectUserUseCase;

  AdminBloc({
    required this.getPendingUsersUseCase,
    required this.approveUserUseCase,
    required this.rejectUserUseCase,
  }) : super(AdminInitial()) {
    on<LoadPendingUsers>((event, emit) async {
      emit(AdminLoading());
      try {
        final users = await getPendingUsersUseCase();
        emit(AdminLoaded(users));
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    });

    on<ApproveUser>((event, emit) async {
      emit(AdminLoading());
      try {
        await approveUserUseCase(event.userId);
        emit(const AdminActionSuccess('User approved successfully.'));
        add(LoadPendingUsers());
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    });

    on<RejectUser>((event, emit) async {
      emit(AdminLoading());
      try {
        await rejectUserUseCase(event.userId);
        emit(const AdminActionSuccess('User rejected successfully.'));
        add(LoadPendingUsers());
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    });
  }
}
