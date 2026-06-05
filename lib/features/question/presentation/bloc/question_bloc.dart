import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/usecases/get_session_questions_usecase.dart';
import '../../domain/usecases/submit_answer_usecase.dart';
import '../../../../core/constants/app_constants.dart';
import 'question_event.dart';
import 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final GetSessionQuestionsUseCase getSessionQuestionsUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;

  QuestionBloc({
    required this.getSessionQuestionsUseCase,
    required this.submitAnswerUseCase,
  }) : super(QuestionInitial()) {
    on<LoadSessionQuestionsRequested>(_onLoadSessionQuestions);
    on<NavigateToQuestionRequested>(_onNavigateToQuestion);
    on<SubmitAnswerRequested>(_onSubmitAnswer);
    on<ResetQuestionState>(_onResetQuestionState);
  }

  void _onLoadSessionQuestions(
    LoadSessionQuestionsRequested event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionLoading());
    try {
      final list = await getSessionQuestionsUseCase(event.sessionId);
      if (list.isEmpty) {
        emit(QuestionInitial());
        return;
      }
      
      // Calculate progress and find first unanswered index
      int completed = list.where((q) => q.questionStatus.toUpperCase() == 'ANSWERED').length;
      int firstUnanswered = list.indexWhere((q) => q.questionStatus.toUpperCase() != 'ANSWERED');
      int initialIndex = firstUnanswered == -1 ? 0 : firstUnanswered;
      
      final isCompleted = completed == list.length;

      if (isCompleted) {
        emit(QuestionCompleted(
          questions: list,
          currentIndex: initialIndex,
          completedQuestions: completed,
          totalQuestions: list.length,
        ));
      } else {
        emit(QuestionsLoaded(
          questions: list,
          currentIndex: initialIndex,
          completedQuestions: completed,
          totalQuestions: list.length,
        ));
      }
    } on AppException catch (e) {
      emit(QuestionError(e.message));
    } catch (e) {
      developer.log('Error in QuestionBloc', error: e);
      emit(QuestionError(AppConstants.errorGeneric));
    }
  }

  void _onNavigateToQuestion(
    NavigateToQuestionRequested event,
    Emitter<QuestionState> emit,
  ) {
    final currentState = state;
    if (currentState is QuestionsLoaded) {
      if (event.index >= 0 && event.index < currentState.questions.length) {
        final completed = currentState.completedQuestions;
        final total = currentState.totalQuestions;
        
        if (currentState is QuestionCompleted) {
          emit(QuestionCompleted(
            questions: currentState.questions,
            currentIndex: event.index,
            completedQuestions: completed,
            totalQuestions: total,
          ));
        } else {
          emit(QuestionsLoaded(
            questions: currentState.questions,
            currentIndex: event.index,
            completedQuestions: completed,
            totalQuestions: total,
          ));
        }
      }
    }
  }

  void _onSubmitAnswer(
    SubmitAnswerRequested event,
    Emitter<QuestionState> emit,
  ) async {
    final currentState = state;
    if (currentState is QuestionsLoaded && currentState is! AnswerSubmitting) {
      final questions = currentState.questions;
      final currentIndex = currentState.currentIndex;
      final totalQuestions = currentState.totalQuestions;
      
      emit(AnswerSubmitting(
        questions: questions,
        currentIndex: currentIndex,
        completedQuestions: currentState.completedQuestions,
        totalQuestions: totalQuestions,
      ));

      try {
        await submitAnswerUseCase(event.questionId, event.answer);
        
        // Update local list
        final updatedList = questions.map((q) {
          if (q.id == event.questionId) {
            return QuestionEntity(
              id: q.id,
              practiceSessionId: q.practiceSessionId,
              questionNumber: q.questionNumber,
              question: q.question,
              userAnswer: event.answer,
              questionStatus: 'ANSWERED',
              score: q.score,
              evaluationStatus: q.evaluationStatus,
              evaluatedAt: q.evaluatedAt,
              createdAt: q.createdAt,
              updatedAt: q.updatedAt,
            );
          }
          return q;
        }).toList();

        final newCompleted = updatedList.where((q) => q.questionStatus.toUpperCase() == 'ANSWERED').length;
        final isAllCompleted = newCompleted == totalQuestions;

        // Emit success state first to trigger UI feedback listener
        emit(AnswerSubmitted(
          questions: updatedList,
          currentIndex: currentIndex,
          completedQuestions: newCompleted,
          totalQuestions: totalQuestions,
        ));

        // Yield permanent state
        if (isAllCompleted) {
          emit(QuestionCompleted(
            questions: updatedList,
            currentIndex: currentIndex,
            completedQuestions: newCompleted,
            totalQuestions: totalQuestions,
          ));
        } else {
          emit(QuestionsLoaded(
            questions: updatedList,
            currentIndex: currentIndex,
            completedQuestions: newCompleted,
            totalQuestions: totalQuestions,
          ));
        }
      } on AppException catch (e) {
        emit(QuestionError(e.message));
        // Re-emit previous loaded state to allow user to retry
        emit(QuestionsLoaded(
          questions: questions,
          currentIndex: currentIndex,
          completedQuestions: currentState.completedQuestions,
          totalQuestions: totalQuestions,
        ));
      } catch (e) {
        developer.log('Error in QuestionBloc', error: e);
        emit(QuestionError(AppConstants.errorGeneric));
        emit(QuestionsLoaded(
          questions: questions,
          currentIndex: currentIndex,
          completedQuestions: currentState.completedQuestions,
          totalQuestions: totalQuestions,
        ));
      }
    }
  }

  void _onResetQuestionState(
    ResetQuestionState event,
    Emitter<QuestionState> emit,
  ) {
    emit(QuestionInitial());
  }
}
