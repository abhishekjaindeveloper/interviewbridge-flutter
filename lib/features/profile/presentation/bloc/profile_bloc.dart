import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/setup_profile_usecase.dart';
import '../../../../core/constants/app_constants.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final SetupProfileUseCase setupProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.setupProfileUseCase,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<SetupProfileSelection>(_onSetupProfileSelection);
    on<ResetProfileState>((event, emit) => emit(ProfileInitial()));
  }

  void _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await getProfileUseCase();
      emit(ProfileLoaded(profile));
    } on AppException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      developer.log('Error in ProfileBloc', error: e);
      emit(ProfileError(AppConstants.errorGeneric));
    }
  }

  void _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());
    try {
      final profile = await updateProfileUseCase(
        event.name,
        event.technologyId,
        event.experienceId,
      );
      emit(ProfileUpdateSuccess(profile));
      emit(ProfileLoaded(profile)); // Re-emit loaded so UI displays updated state
    } on AppException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      developer.log('Error in ProfileBloc', error: e);
      emit(ProfileError(AppConstants.errorGeneric));
    }
  }

  void _onSetupProfileSelection(
    SetupProfileSelection event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await setupProfileUseCase(
        event.technologyId,
        event.experienceId,
      );
      emit(ProfileSetupSuccess(profile));
      emit(ProfileLoaded(profile)); // Re-emit loaded so UI displays updated state
    } on AppException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      developer.log('Error in ProfileBloc', error: e);
      emit(ProfileError(AppConstants.errorGeneric));
    }
  }
}
