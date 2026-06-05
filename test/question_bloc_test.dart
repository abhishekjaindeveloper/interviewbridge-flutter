import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/exceptions/app_exceptions.dart';
import 'package:interview_bridge_app/features/question/domain/entities/question_entity.dart';
import 'package:interview_bridge_app/features/question/domain/entities/submit_answer_response_entity.dart';
import 'package:interview_bridge_app/features/question/domain/usecases/get_session_questions_usecase.dart';
import 'package:interview_bridge_app/features/question/domain/usecases/submit_answer_usecase.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_bloc.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_event.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_state.dart';

// ============================================================================
// MANUAL MOCKS
// ============================================================================

class MockGetSessionQuestionsUseCase implements GetSessionQuestionsUseCase {
  List<QuestionEntity>? result;
  AppException? error;

  @override
  Future<List<QuestionEntity>> call(String sessionId) async {
    if (error != null) {
      throw error!;
    }
    return result ?? [];
  }
}

class MockSubmitAnswerUseCase implements SubmitAnswerUseCase {
  SubmitAnswerResponseEntity? result;
  AppException? error;

  @override
  Future<SubmitAnswerResponseEntity> call(String questionId, String answer) async {
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('QuestionBloc', () {
    late MockGetSessionQuestionsUseCase mockGetSessionQuestions;
    late MockSubmitAnswerUseCase mockSubmitAnswer;
    late QuestionBloc bloc;

    final q1 = const QuestionEntity(
      id: 'q-1',
      practiceSessionId: 'sess-123',
      questionNumber: 1,
      question: 'What is inheritance?',
      questionStatus: 'PENDING',
    );

    final q2 = const QuestionEntity(
      id: 'q-2',
      practiceSessionId: 'sess-123',
      questionNumber: 2,
      question: 'What is polymorphism?',
      questionStatus: 'PENDING',
    );

    setUp(() {
      mockGetSessionQuestions = MockGetSessionQuestionsUseCase();
      mockSubmitAnswer = MockSubmitAnswerUseCase();
      bloc = QuestionBloc(
        getSessionQuestionsUseCase: mockGetSessionQuestions,
        submitAnswerUseCase: mockSubmitAnswer,
      );
    });

    test('initial state should be QuestionInitial', () {
      expect(bloc.state, equals(QuestionInitial()));
    });

    group('LoadSessionQuestionsRequested', () {
      test('should emit [QuestionLoading, QuestionsLoaded] and auto-select first unanswered index', () async {
        final list = [
          const QuestionEntity(
            id: 'q-1',
            practiceSessionId: 'sess-123',
            questionNumber: 1,
            question: 'Q1',
            questionStatus: 'ANSWERED',
            userAnswer: 'Ans 1',
          ),
          q2,
        ];
        mockGetSessionQuestions.result = list;

        final expectedStates = [
          QuestionLoading(),
          QuestionsLoaded(
            questions: list,
            currentIndex: 1, // First unanswered question is q2 at index 1
            completedQuestions: 1,
            totalQuestions: 2,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const LoadSessionQuestionsRequested('sess-123'));
      });

      test('should emit [QuestionLoading, QuestionCompleted] if all questions are already answered', () async {
        final list = [
          const QuestionEntity(
            id: 'q-1',
            practiceSessionId: 'sess-123',
            questionNumber: 1,
            question: 'Q1',
            questionStatus: 'ANSWERED',
            userAnswer: 'Ans 1',
          ),
        ];
        mockGetSessionQuestions.result = list;

        final expectedStates = [
          QuestionLoading(),
          QuestionCompleted(
            questions: list,
            currentIndex: 0,
            completedQuestions: 1,
            totalQuestions: 1,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const LoadSessionQuestionsRequested('sess-123'));
      });

      test('should emit [QuestionLoading, QuestionError] when fetch fails', () async {
        mockGetSessionQuestions.error = NetworkException('Server not responding');

        final expectedStates = [
          QuestionLoading(),
          const QuestionError('Server not responding'),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const LoadSessionQuestionsRequested('sess-123'));
      });
    });

    group('NavigateToQuestionRequested', () {
      test('should update currentIndex and retain loaded list', () async {
        final list = [q1, q2];
        mockGetSessionQuestions.result = list;

        // Populate state first
        bloc.emit(QuestionsLoaded(
          questions: list,
          currentIndex: 0,
          completedQuestions: 0,
          totalQuestions: 2,
        ));

        final expectedStates = [
          QuestionsLoaded(
            questions: list,
            currentIndex: 1,
            completedQuestions: 0,
            totalQuestions: 2,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const NavigateToQuestionRequested(1));
      });
    });

    group('SubmitAnswerRequested', () {
      test('should emit [AnswerSubmitting, AnswerSubmitted, QuestionsLoaded] when answer is submitted successfully', () async {
        final list = [q1, q2];
        mockGetSessionQuestions.result = list;

        // Seed initial loaded state
        bloc.emit(QuestionsLoaded(
          questions: list,
          currentIndex: 0,
          completedQuestions: 0,
          totalQuestions: 2,
        ));

        final updatedQ1 = const QuestionEntity(
          id: 'q-1',
          practiceSessionId: 'sess-123',
          questionNumber: 1,
          question: 'What is inheritance?',
          questionStatus: 'ANSWERED',
          userAnswer: 'Answer body text',
        );

        mockSubmitAnswer.result = const SubmitAnswerResponseEntity(
          questionId: 'q-1',
          sessionId: 'sess-123',
          questionNumber: 1,
          question: 'What is inheritance?',
          userAnswer: 'Answer body text',
          questionStatus: 'ANSWERED',
          completedQuestions: 1,
          totalQuestions: 2,
          sessionStatus: 'IN_PROGRESS',
        );

        final expectedStates = [
          AnswerSubmitting(
            questions: list,
            currentIndex: 0,
            completedQuestions: 0,
            totalQuestions: 2,
          ),
          AnswerSubmitted(
            questions: [updatedQ1, q2],
            currentIndex: 0,
            completedQuestions: 1,
            totalQuestions: 2,
          ),
          QuestionsLoaded(
            questions: [updatedQ1, q2],
            currentIndex: 0,
            completedQuestions: 1,
            totalQuestions: 2,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const SubmitAnswerRequested(
          questionId: 'q-1',
          answer: 'Answer body text',
        ));
      });

      test('should emit [AnswerSubmitting, AnswerSubmitted, QuestionCompleted] when final question is answered', () async {
        final list = [
          const QuestionEntity(
            id: 'q-1',
            practiceSessionId: 'sess-123',
            questionNumber: 1,
            question: 'Q1',
            questionStatus: 'ANSWERED',
            userAnswer: 'Ans 1',
          ),
          q2,
        ];

        // Seed initial state with 1/2 answered, active on index 1 (unanswered q2)
        bloc.emit(QuestionsLoaded(
          questions: list,
          currentIndex: 1,
          completedQuestions: 1,
          totalQuestions: 2,
        ));

        final updatedQ2 = const QuestionEntity(
          id: 'q-2',
          practiceSessionId: 'sess-123',
          questionNumber: 2,
          question: 'What is polymorphism?',
          questionStatus: 'ANSWERED',
          userAnswer: 'Polymorphism is...',
        );

        mockSubmitAnswer.result = const SubmitAnswerResponseEntity(
          questionId: 'q-2',
          sessionId: 'sess-123',
          questionNumber: 2,
          question: 'What is polymorphism?',
          userAnswer: 'Polymorphism is...',
          questionStatus: 'ANSWERED',
          completedQuestions: 2,
          totalQuestions: 2,
          sessionStatus: 'COMPLETED',
        );

        final expectedStates = [
          AnswerSubmitting(
            questions: list,
            currentIndex: 1,
            completedQuestions: 1,
            totalQuestions: 2,
          ),
          AnswerSubmitted(
            questions: [list[0], updatedQ2],
            currentIndex: 1,
            completedQuestions: 2,
            totalQuestions: 2,
          ),
          QuestionCompleted(
            questions: [list[0], updatedQ2],
            currentIndex: 1,
            completedQuestions: 2,
            totalQuestions: 2,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const SubmitAnswerRequested(
          questionId: 'q-2',
          answer: 'Polymorphism is...',
        ));
      });

      test('should emit [AnswerSubmitting, QuestionError, QuestionsLoaded] when submission fails', () async {
        final list = [q1, q2];
        bloc.emit(QuestionsLoaded(
          questions: list,
          currentIndex: 0,
          completedQuestions: 0,
          totalQuestions: 2,
        ));

        mockSubmitAnswer.error = ServerException('Submission timed out');

        final expectedStates = [
          AnswerSubmitting(
            questions: list,
            currentIndex: 0,
            completedQuestions: 0,
            totalQuestions: 2,
          ),
          const QuestionError('Submission timed out'),
          QuestionsLoaded(
            questions: list,
            currentIndex: 0,
            completedQuestions: 0,
            totalQuestions: 2,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const SubmitAnswerRequested(
          questionId: 'q-1',
          answer: 'Short answer',
        ));
      });
    });

    group('ResetQuestionState', () {
      test('should emit [QuestionInitial] when ResetQuestionState is dispatched', () async {
        bloc.emit(QuestionsLoaded(
          questions: [q1],
          currentIndex: 0,
          completedQuestions: 0,
          totalQuestions: 1,
        ));

        final expectedStates = [
          QuestionInitial(),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(ResetQuestionState());
      });
    });
  });
}
