import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/usecases/get_experiences_usecase.dart';
import '../../domain/usecases/get_all_experiences_usecase.dart';
import '../../domain/usecases/create_experience_usecase.dart';
import '../../domain/usecases/update_experience_usecase.dart';
import '../../domain/usecases/activate_experience_usecase.dart';
import '../../domain/usecases/deactivate_experience_usecase.dart';
import '../../../../core/constants/app_constants.dart';
import 'experience_event.dart';
import 'experience_state.dart';

class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  final GetExperiencesUseCase getExperiencesUseCase;
  final GetAllExperiencesUseCase getAllExperiencesUseCase;
  final CreateExperienceUseCase createExperienceUseCase;
  final UpdateExperienceUseCase updateExperienceUseCase;
  final ActivateExperienceUseCase activateExperienceUseCase;
  final DeactivateExperienceUseCase deactivateExperienceUseCase;

  ExperienceBloc({
    required this.getExperiencesUseCase,
    required this.getAllExperiencesUseCase,
    required this.createExperienceUseCase,
    required this.updateExperienceUseCase,
    required this.activateExperienceUseCase,
    required this.deactivateExperienceUseCase,
  }) : super(ExperienceInitial()) {
    on<FetchExperiences>(_onFetchExperiences);
    on<ResetExperienceState>((event, emit) => emit(ExperienceInitial()));
    on<LoadExperiences>(_onLoadExperiences);
    on<CreateExperience>(_onCreateExperience);
    on<UpdateExperience>(_onUpdateExperience);
    on<ActivateExperience>(_onActivateExperience);
    on<DeactivateExperience>(_onDeactivateExperience);
  }

  void _onFetchExperiences(
    FetchExperiences event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      final list = await getExperiencesUseCase();
      emit(ExperienceLoaded(list));
    } on AppException catch (e) {
      emit(ExperienceError(e.message));
    } catch (e) {
      developer.log('Error in ExperienceBloc (Fetch)', error: e);
      emit(ExperienceError(AppConstants.errorGeneric));
    }
  }

  void _onLoadExperiences(
    LoadExperiences event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      final list = await getAllExperiencesUseCase();
      emit(ExperienceLoaded(list));
    } on AppException catch (e) {
      emit(ExperienceError(e.message));
    } catch (e) {
      developer.log('Error in ExperienceBloc (Load)', error: e);
      emit(ExperienceError(AppConstants.expLoadFailed));
    }
  }

  void _onCreateExperience(
    CreateExperience event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      await createExperienceUseCase(event.label);
      emit(const ExperienceActionSuccess(AppConstants.expCreateSuccess));
      add(LoadExperiences());
    } on AppException catch (e) {
      emit(ExperienceError(e.message));
    } catch (e) {
      developer.log('Error in ExperienceBloc (Create)', error: e);
      emit(ExperienceError(AppConstants.errorGeneric));
    }
  }

  void _onUpdateExperience(
    UpdateExperience event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      await updateExperienceUseCase(event.id, event.label);
      emit(const ExperienceActionSuccess(AppConstants.expUpdateSuccess));
      add(LoadExperiences());
    } on AppException catch (e) {
      emit(ExperienceError(e.message));
    } catch (e) {
      developer.log('Error in ExperienceBloc (Update)', error: e);
      emit(ExperienceError(AppConstants.errorGeneric));
    }
  }

  void _onActivateExperience(
    ActivateExperience event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      await activateExperienceUseCase(event.id);
      emit(const ExperienceActionSuccess(AppConstants.expActivateSuccess));
      add(LoadExperiences());
    } on AppException catch (e) {
      emit(ExperienceError(e.message));
    } catch (e) {
      developer.log('Error in ExperienceBloc (Activate)', error: e);
      emit(ExperienceError(AppConstants.errorGeneric));
    }
  }

  void _onDeactivateExperience(
    DeactivateExperience event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      await deactivateExperienceUseCase(event.id);
      emit(const ExperienceActionSuccess(AppConstants.expDeactivateSuccess));
      add(LoadExperiences());
    } on AppException catch (e) {
      emit(ExperienceError(e.message));
    } catch (e) {
      developer.log('Error in ExperienceBloc (Deactivate)', error: e);
      emit(ExperienceError(AppConstants.errorGeneric));
    }
  }
}
