import 'package:get_it/get_it.dart';
import 'presentation/bloc/admin_bloc.dart';
import 'domain/usecases/get_pending_users_usecase.dart';
import 'domain/usecases/approve_user_usecase.dart';
import 'domain/usecases/reject_user_usecase.dart';
import 'domain/usecases/get_admin_user_statistics_usecase.dart';
import 'domain/usecases/get_users_usecase.dart';
import 'domain/usecases/activate_user_usecase.dart';
import 'domain/usecases/deactivate_user_usecase.dart';
import 'domain/repositories/admin_repository.dart';
import 'data/repositories/admin_repository_impl.dart';
import 'data/datasources/admin_remote_datasource.dart';

void initAdmin(GetIt sl) {
  sl.registerFactory(
    () => AdminBloc(
      getPendingUsersUseCase: sl(),
      approveUserUseCase: sl(),
      rejectUserUseCase: sl(),
      getAdminUserStatisticsUseCase: sl(),
      getUsersUseCase: sl(),
      activateUserUseCase: sl(),
      deactivateUserUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetPendingUsersUseCase(sl()));
  sl.registerLazySingleton(() => ApproveUserUseCase(sl()));
  sl.registerLazySingleton(() => RejectUserUseCase(sl()));
  sl.registerLazySingleton(() => GetAdminUserStatisticsUseCase(sl()));
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => ActivateUserUseCase(sl()));
  sl.registerLazySingleton(() => DeactivateUserUseCase(sl()));
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(sl()));
  sl.registerLazySingleton<AdminRemoteDataSource>(() => AdminRemoteDataSourceImpl(sl()));
}
