import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/usecases/get_experiences_usecase.dart';
import '../../../../core/constants/app_constants.dart';
import 'experience_event.dart';
import 'experience_state.dart';

class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  final GetExperiencesUseCase getExperiencesUseCase;

  ExperienceBloc({
    required this.getExperiencesUseCase,
  }) : super(ExperienceInitial()) {
    on<FetchExperiences>(_onFetchExperiences);
    on<ResetExperienceState>((event, emit) => emit(ExperienceInitial()));
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
      developer.log('Error in ExperienceBloc', error: e);
      emit(ExperienceError(AppConstants.errorGeneric));
    }
  }
}
