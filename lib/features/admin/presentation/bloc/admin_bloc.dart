import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_event.dart';
import 'admin_state.dart';
import '../../domain/usecases/get_pending_users_usecase.dart';
import '../../domain/usecases/approve_user_usecase.dart';
import '../../domain/usecases/reject_user_usecase.dart';
import '../../domain/usecases/get_admin_user_statistics_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/activate_user_usecase.dart';
import '../../domain/usecases/deactivate_user_usecase.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetPendingUsersUseCase getPendingUsersUseCase;
  final ApproveUserUseCase approveUserUseCase;
  final RejectUserUseCase rejectUserUseCase;
  final GetAdminUserStatisticsUseCase getAdminUserStatisticsUseCase;
  final GetUsersUseCase getUsersUseCase;
  final ActivateUserUseCase activateUserUseCase;
  final DeactivateUserUseCase deactivateUserUseCase;

  AdminBloc({
    required this.getPendingUsersUseCase,
    required this.approveUserUseCase,
    required this.rejectUserUseCase,
    required this.getAdminUserStatisticsUseCase,
    required this.getUsersUseCase,
    required this.activateUserUseCase,
    required this.deactivateUserUseCase,
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
        await rejectUserUseCase(event.userId, event.reason);
        emit(const AdminActionSuccess('User rejected successfully.'));
        add(LoadPendingUsers());
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    });

    on<LoadAdminStatistics>((event, emit) async {
      emit(AdminLoading());
      try {
        final stats = await getAdminUserStatisticsUseCase();
        emit(AdminStatisticsLoaded(stats));
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    });

    on<LoadUsersList>((event, emit) async {
      emit(AdminUsersListLoading());
      try {
        final users = await getUsersUseCase(
          event.page,
          event.size,
          search: event.search,
          approvalStatus: event.approvalStatus,
          isActive: event.isActive,
        );
        emit(AdminUsersListLoaded(users));
      } catch (e) {
        emit(AdminUsersListError(e.toString()));
      }
    });

    on<ActivateUserAccount>((event, emit) async {
      emit(AdminLoading());
      try {
        await activateUserUseCase(event.userId);
        emit(const UserStatusToggledSuccess('User activated successfully.'));
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    });

    on<DeactivateUserAccount>((event, emit) async {
      emit(AdminLoading());
      try {
        await deactivateUserUseCase(event.userId);
        emit(const UserStatusToggledSuccess('User deactivated successfully.'));
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    });
  }
}
