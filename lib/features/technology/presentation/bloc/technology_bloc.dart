import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/usecases/get_technologies_usecase.dart';
import '../../../../core/constants/app_constants.dart';
import 'technology_event.dart';
import 'technology_state.dart';

class TechnologyBloc extends Bloc<TechnologyEvent, TechnologyState> {
  final GetTechnologiesUseCase getTechnologiesUseCase;

  TechnologyBloc({
    required this.getTechnologiesUseCase,
  }) : super(TechnologyInitial()) {
    on<FetchTechnologies>(_onFetchTechnologies);
    on<ResetTechnologyState>((event, emit) => emit(TechnologyInitial()));
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
      developer.log('Error in TechnologyBloc', error: e);
      emit(TechnologyError(AppConstants.errorGeneric));
    }
  }
}
