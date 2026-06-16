import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/usecases/get_technologies_usecase.dart';
import '../../domain/usecases/get_all_technologies_usecase.dart';
import '../../domain/usecases/create_technology_usecase.dart';
import '../../domain/usecases/update_technology_usecase.dart';
import '../../domain/usecases/activate_technology_usecase.dart';
import '../../domain/usecases/deactivate_technology_usecase.dart';
import '../../../../core/constants/app_constants.dart';
import 'technology_event.dart';
import 'technology_state.dart';

class TechnologyBloc extends Bloc<TechnologyEvent, TechnologyState> {
  final GetTechnologiesUseCase getTechnologiesUseCase;
  final GetAllTechnologiesUseCase getAllTechnologiesUseCase;
  final CreateTechnologyUseCase createTechnologyUseCase;
  final UpdateTechnologyUseCase updateTechnologyUseCase;
  final ActivateTechnologyUseCase activateTechnologyUseCase;
  final DeactivateTechnologyUseCase deactivateTechnologyUseCase;

  TechnologyBloc({
    required this.getTechnologiesUseCase,
    required this.getAllTechnologiesUseCase,
    required this.createTechnologyUseCase,
    required this.updateTechnologyUseCase,
    required this.activateTechnologyUseCase,
    required this.deactivateTechnologyUseCase,
  }) : super(TechnologyInitial()) {
    on<FetchTechnologies>(_onFetchTechnologies);
    on<ResetTechnologyState>((event, emit) => emit(TechnologyInitial()));
    on<LoadTechnologies>(_onLoadTechnologies);
    on<CreateTechnology>(_onCreateTechnology);
    on<UpdateTechnology>(_onUpdateTechnology);
    on<ActivateTechnology>(_onActivateTechnology);
    on<DeactivateTechnology>(_onDeactivateTechnology);
  }

  void _onFetchTechnologies(
    FetchTechnologies event,
    Emitter<TechnologyState> emit,
  ) async {
    emit(TechnologyLoading());
    try {
      final list = await getTechnologiesUseCase();
      emit(TechnologyLoaded(list));
    } on AppException catch (e) {
      emit(TechnologyError(e.message));
    } catch (e) {
      developer.log('Error in TechnologyBloc (Fetch)', error: e);
      emit(TechnologyError(AppConstants.errorGeneric));
    }
  }

  void _onLoadTechnologies(
    LoadTechnologies event,
    Emitter<TechnologyState> emit,
  ) async {
    emit(TechnologyLoading());
    try {
      final list = await getAllTechnologiesUseCase();
      emit(TechnologyLoaded(list));
    } on AppException catch (e) {
      emit(TechnologyError(e.message));
    } catch (e) {
      developer.log('Error in TechnologyBloc (Load)', error: e);
      emit(TechnologyError(AppConstants.techLoadFailed));
    }
  }

  void _onCreateTechnology(
    CreateTechnology event,
    Emitter<TechnologyState> emit,
  ) async {
    emit(TechnologyLoading());
    try {
      await createTechnologyUseCase(event.name, event.description);
      emit(const TechnologyActionSuccess(AppConstants.techCreateSuccess));
      add(LoadTechnologies());
    } on AppException catch (e) {
      emit(TechnologyError(e.message));
    } catch (e) {
      developer.log('Error in TechnologyBloc (Create)', error: e);
      emit(TechnologyError(AppConstants.errorGeneric));
    }
  }

  void _onUpdateTechnology(
    UpdateTechnology event,
    Emitter<TechnologyState> emit,
  ) async {
    emit(TechnologyLoading());
    try {
      await updateTechnologyUseCase(event.id, event.name, event.description);
      emit(const TechnologyActionSuccess(AppConstants.techUpdateSuccess));
      add(LoadTechnologies());
    } on AppException catch (e) {
      emit(TechnologyError(e.message));
    } catch (e) {
      developer.log('Error in TechnologyBloc (Update)', error: e);
      emit(TechnologyError(AppConstants.errorGeneric));
    }
  }

  void _onActivateTechnology(
    ActivateTechnology event,
    Emitter<TechnologyState> emit,
  ) async {
    emit(TechnologyLoading());
    try {
      await activateTechnologyUseCase(event.id);
      emit(const TechnologyActionSuccess(AppConstants.techActivateSuccess));
      add(LoadTechnologies());
    } on AppException catch (e) {
      emit(TechnologyError(e.message));
    } catch (e) {
      developer.log('Error in TechnologyBloc (Activate)', error: e);
      emit(TechnologyError(AppConstants.errorGeneric));
    }
  }

  void _onDeactivateTechnology(
    DeactivateTechnology event,
    Emitter<TechnologyState> emit,
  ) async {
    emit(TechnologyLoading());
    try {
      await deactivateTechnologyUseCase(event.id);
      emit(const TechnologyActionSuccess(AppConstants.techDeactivateSuccess));
      add(LoadTechnologies());
    } on AppException catch (e) {
      emit(TechnologyError(e.message));
    } catch (e) {
      developer.log('Error in TechnologyBloc (Deactivate)', error: e);
      emit(TechnologyError(AppConstants.errorGeneric));
    }
  }
}
