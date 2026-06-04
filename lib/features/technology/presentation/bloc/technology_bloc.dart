import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/usecases/get_technologies_usecase.dart';
import 'technology_event.dart';
import 'technology_state.dart';

class TechnologyBloc extends Bloc<TechnologyEvent, TechnologyState> {
  final GetTechnologiesUseCase getTechnologiesUseCase;

  TechnologyBloc({
    required this.getTechnologiesUseCase,
  }) : super(TechnologyInitial()) {
    on<FetchTechnologies>(_onFetchTechnologies);
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
      emit(TechnologyError(e.toString()));
    }
  }
}
