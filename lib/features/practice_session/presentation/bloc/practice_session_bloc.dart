import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/practice_session_entity.dart';
import '../../domain/usecases/create_practice_session_usecase.dart';
import '../../domain/usecases/get_practice_sessions_usecase.dart';
import '../../domain/usecases/get_practice_session_details_usecase.dart';
import '../../domain/usecases/generate_questions_usecase.dart';
import '../../../../core/constants/app_constants.dart';
import 'practice_session_event.dart';
import 'practice_session_state.dart';

class PracticeSessionBloc extends Bloc<PracticeSessionEvent, PracticeSessionState> {
  final CreatePracticeSessionUseCase createPracticeSessionUseCase;
  final GetPracticeSessionsUseCase getPracticeSessionsUseCase;
  final GetPracticeSessionDetailsUseCase getPracticeSessionDetailsUseCase;
  final GenerateQuestionsUseCase generateQuestionsUseCase;

  PracticeSessionBloc({
    required this.createPracticeSessionUseCase,
    required this.getPracticeSessionsUseCase,
    required this.getPracticeSessionDetailsUseCase,
    required this.generateQuestionsUseCase,
  }) : super(PracticeSessionInitial()) {
    on<CreateSessionRequested>(_onCreateSessionRequested);
    on<GenerateQuestionsRequested>(_onGenerateQuestionsRequested);
    on<LoadSessionHistoryRequested>(_onLoadSessionHistoryRequested);
    on<LoadSessionDetailsRequested>(_onLoadSessionDetailsRequested);
    on<ResetSessionState>(_onResetSessionState);
  }

  void _onCreateSessionRequested(
    CreateSessionRequested event,
    Emitter<PracticeSessionState> emit,
  ) async {
    emit(PracticeSessionLoading());
    try {
      final session = await createPracticeSessionUseCase(
        event.technologyId,
        event.experienceId,
        event.totalQuestions,
      );
      emit(PracticeSessionCreated(session));
    } on AppException catch (e) {
      emit(PracticeSessionError(e.message));
    } catch (e) {
      developer.log('Error in PracticeSessionBloc', error: e);
      emit(PracticeSessionError(AppConstants.errorGeneric));
    }
  }

  void _onGenerateQuestionsRequested(
    GenerateQuestionsRequested event,
    Emitter<PracticeSessionState> emit,
  ) async {
    emit(PracticeSessionLoading());
    try {
      await generateQuestionsUseCase(event.sessionId);
      // Fetch latest session details to get the updated status/progress
      final updatedSession = await getPracticeSessionDetailsUseCase(event.sessionId);
      emit(PracticeQuestionsGenerated(updatedSession));
    } on AppException catch (e) {
      emit(PracticeSessionError(e.message));
    } catch (e) {
      developer.log('Error in PracticeSessionBloc', error: e);
      emit(PracticeSessionError(AppConstants.errorGeneric));
    }
  }

  void _onLoadSessionHistoryRequested(
    LoadSessionHistoryRequested event,
    Emitter<PracticeSessionState> emit,
  ) async {
    emit(PracticeSessionLoading());
    try {
      final list = await getPracticeSessionsUseCase();
      final sortedList = List<PracticeSessionEntity>.from(list)
        ..sort((a, b) {
          final aTime = a.createdAt;
          final bTime = b.createdAt;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
      if (sortedList.isEmpty) {
        emit(PracticeSessionsEmpty());
      } else {
        emit(PracticeSessionsLoaded(sortedList));
      }
    } on AppException catch (e) {
      emit(PracticeSessionError(e.message));
    } catch (e) {
      developer.log('Error in PracticeSessionBloc', error: e);
      emit(PracticeSessionError(AppConstants.errorGeneric));
    }
  }

  void _onResetSessionState(
    ResetSessionState event,
    Emitter<PracticeSessionState> emit,
  ) {
    emit(PracticeSessionInitial());
  }

  void _onLoadSessionDetailsRequested(
    LoadSessionDetailsRequested event,
    Emitter<PracticeSessionState> emit,
  ) async {
    emit(PracticeSessionLoading());
    try {
      final session = await getPracticeSessionDetailsUseCase(event.sessionId);
      emit(PracticeSessionDetailsLoaded(session));
    } on AppException catch (e) {
      emit(PracticeSessionError(e.message));
    } catch (e) {
      developer.log('Error in PracticeSessionBloc', error: e);
      emit(PracticeSessionError(AppConstants.errorGeneric));
    }
  }
}
