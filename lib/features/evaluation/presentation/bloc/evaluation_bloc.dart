import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../practice_session/domain/usecases/get_practice_session_details_usecase.dart';
import '../../../question/domain/entities/question_entity.dart';
import '../../../question/domain/usecases/get_session_questions_usecase.dart';
import '../../domain/usecases/evaluate_question_usecase.dart';
import '../../domain/usecases/get_evaluation_result_usecase.dart';
import '../../../../core/constants/app_constants.dart';
import 'evaluation_event.dart';
import 'evaluation_state.dart';

class EvaluationBloc extends Bloc<EvaluationEvent, EvaluationState> {
  final GetSessionQuestionsUseCase getSessionQuestionsUseCase;
  final GetPracticeSessionDetailsUseCase getPracticeSessionDetailsUseCase;
  final EvaluateQuestionUseCase evaluateQuestionUseCase;
  final GetEvaluationResultUseCase getEvaluationResultUseCase;

  EvaluationBloc({
    required this.getSessionQuestionsUseCase,
    required this.getPracticeSessionDetailsUseCase,
    required this.evaluateQuestionUseCase,
    required this.getEvaluationResultUseCase,
  }) : super(EvaluationInitial()) {
    on<LoadSessionQuestionsRequested>(_onLoadSessionQuestions);
    on<GetEvaluationRequested>(_onGetEvaluation);
    on<TriggerEvaluationRequested>(_onTriggerEvaluation);
    on<ResetEvaluationState>(_onResetEvaluation);
  }

  void _onLoadSessionQuestions(
    LoadSessionQuestionsRequested event,
    Emitter<EvaluationState> emit,
  ) async {
    emit(EvaluationLoading());
    try {
      final questions = await getSessionQuestionsUseCase(event.sessionId);
      double averageScore = 0.0;
      try {
        final session = await getPracticeSessionDetailsUseCase(event.sessionId);
        averageScore = session.averageScore;
      } catch (_) {
        // Fallback if session details fetch fails
      }

      if (questions.isEmpty) {
        emit(const EvaluationLoaded(
          questions: [],
          currentIndex: 0,
          averageScore: 0.0,
        ));
        return;
      }

      // Find first answered index to auto-select
      int initialIndex = questions.indexWhere(
        (q) => q.questionStatus.toUpperCase() == 'ANSWERED',
      );
      if (initialIndex == -1) {
        initialIndex = 0;
      }

      final activeQuestion = questions[initialIndex];
      final isAnswered = activeQuestion.questionStatus.toUpperCase() == 'ANSWERED';
      final isEvaluated = activeQuestion.evaluationStatus?.toUpperCase() == 'COMPLETED';

      if (isAnswered && isEvaluated) {
        emit(EvaluationLoaded(
          questions: questions,
          currentIndex: initialIndex,
          averageScore: averageScore,
          isEvaluating: false,
        ));
        
        // Load the evaluation details lazily
        try {
          final eval = await getEvaluationResultUseCase(activeQuestion.id);
          final currentState = state;
          if (currentState is EvaluationLoaded && currentState.currentIndex == initialIndex) {
            emit(currentState.copyWith(activeEvaluation: eval));
          }
        } catch (e) {
          developer.log('Error in EvaluationBloc', error: e);
          final currentState = state;
          if (currentState is EvaluationLoaded) {
            emit(currentState.copyWith(
              evaluateError: e is AppException ? e.message : AppConstants.errorGeneric,
            ));
          }
        }
      } else {
        emit(EvaluationLoaded(
          questions: questions,
          currentIndex: initialIndex,
          averageScore: averageScore,
        ));
      }
    } on AppException catch (e) {
      emit(EvaluationError(e.message));
    } catch (e) {
      developer.log('Error in EvaluationBloc', error: e);
      emit(EvaluationError(AppConstants.errorGeneric));
    }
  }

  void _onGetEvaluation(
    GetEvaluationRequested event,
    Emitter<EvaluationState> emit,
  ) async {
    final currentState = state;
    if (currentState is EvaluationLoaded) {
      emit(currentState.copyWith(
        currentIndex: event.index,
        clearActiveEvaluation: true,
        clearEvaluateError: true,
      ));

      final activeQuestion = currentState.questions[event.index];
      final isAnswered = activeQuestion.questionStatus.toUpperCase() == 'ANSWERED';
      final isEvaluated = activeQuestion.evaluationStatus?.toUpperCase() == 'COMPLETED';

      if (isAnswered && isEvaluated) {
        try {
          final eval = await getEvaluationResultUseCase(event.questionId);
          final updatedState = state;
          // Verify user hasn't switched questions in the meantime
          if (updatedState is EvaluationLoaded && updatedState.currentIndex == event.index) {
            emit(updatedState.copyWith(activeEvaluation: eval));
          }
        } on AppException catch (e) {
          final updatedState = state;
          if (updatedState is EvaluationLoaded && updatedState.currentIndex == event.index) {
            emit(updatedState.copyWith(evaluateError: e.message));
          }
        } catch (e) {
          developer.log('Error in EvaluationBloc', error: e);
          final updatedState = state;
          if (updatedState is EvaluationLoaded && updatedState.currentIndex == event.index) {
            emit(updatedState.copyWith(evaluateError: AppConstants.errorGeneric));
          }
        }
      }
    }
  }

  void _onTriggerEvaluation(
    TriggerEvaluationRequested event,
    Emitter<EvaluationState> emit,
  ) async {
    final currentState = state;
    if (currentState is EvaluationLoaded && !currentState.isEvaluating) {
      emit(currentState.copyWith(
        isEvaluating: true,
        clearEvaluateError: true,
        clearActiveEvaluation: true,
      ));

      try {
        final eval = await evaluateQuestionUseCase(event.questionId);
        
        // Update local question entry in list
        final updatedQuestions = currentState.questions.map((q) {
          if (q.id == event.questionId) {
            return QuestionEntity(
              id: q.id,
              practiceSessionId: q.practiceSessionId,
              questionNumber: q.questionNumber,
              question: q.question,
              userAnswer: q.userAnswer,
              translatedAnswer: eval.translatedAnswer,
              improvedAnswer: eval.improvedAnswer,
              explanation: eval.explanation,
              score: eval.score,
              questionStatus: q.questionStatus,
              evaluationStatus: 'COMPLETED',
              evaluatedAt: eval.evaluatedAt,
              createdAt: q.createdAt,
              updatedAt: q.updatedAt,
            );
          }
          return q;
        }).toList();

        // Refresh average score of the session
        double newAverageScore = currentState.averageScore;
        try {
          final session = await getPracticeSessionDetailsUseCase(eval.sessionId);
          newAverageScore = session.averageScore;
        } catch (_) {}

        final updatedState = state;
        if (updatedState is EvaluationLoaded && updatedState.currentIndex == event.index) {
          emit(updatedState.copyWith(
            questions: updatedQuestions,
            averageScore: newAverageScore,
            activeEvaluation: eval,
            isEvaluating: false,
          ));
        }
      } on AppException catch (e) {
        final updatedState = state;
        if (updatedState is EvaluationLoaded && updatedState.currentIndex == event.index) {
          emit(updatedState.copyWith(
            isEvaluating: false,
            evaluateError: e.message,
          ));
        }
      } catch (e) {
        developer.log('Error in EvaluationBloc', error: e);
        final updatedState = state;
        if (updatedState is EvaluationLoaded && updatedState.currentIndex == event.index) {
          emit(updatedState.copyWith(
            isEvaluating: false,
            evaluateError: AppConstants.errorGeneric,
          ));
        }
      }
    }
  }

  void _onResetEvaluation(
    ResetEvaluationState event,
    Emitter<EvaluationState> emit,
  ) {
    emit(EvaluationInitial());
  }
}
