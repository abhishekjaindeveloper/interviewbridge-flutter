import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/exceptions/app_exceptions.dart';
import 'package:interview_bridge_app/features/practice_session/domain/entities/practice_session_entity.dart';
import 'package:interview_bridge_app/features/practice_session/domain/usecases/get_practice_session_details_usecase.dart';
import 'package:interview_bridge_app/features/question/domain/entities/question_entity.dart';
import 'package:interview_bridge_app/features/question/domain/usecases/get_session_questions_usecase.dart';
import 'package:interview_bridge_app/features/evaluation/domain/entities/evaluation_entity.dart';
import 'package:interview_bridge_app/features/evaluation/domain/usecases/evaluate_question_usecase.dart';
import 'package:interview_bridge_app/features/evaluation/domain/usecases/get_evaluation_result_usecase.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/bloc/evaluation_bloc.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/bloc/evaluation_event.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/bloc/evaluation_state.dart';

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

class MockGetPracticeSessionDetailsUseCase implements GetPracticeSessionDetailsUseCase {
  PracticeSessionEntity? result;
  AppException? error;

  @override
  Future<PracticeSessionEntity> call(String sessionId) async {
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

class MockEvaluateQuestionUseCase implements EvaluateQuestionUseCase {
  EvaluationEntity? result;
  AppException? error;

  @override
  Future<EvaluationEntity> call(String questionId) async {
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

class MockGetEvaluationResultUseCase implements GetEvaluationResultUseCase {
  EvaluationEntity? result;
  AppException? error;

  @override
  Future<EvaluationEntity> call(String questionId) async {
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
  group('EvaluationBloc', () {
    late MockGetSessionQuestionsUseCase mockGetSessionQuestions;
    late MockGetPracticeSessionDetailsUseCase mockGetSessionDetails;
    late MockEvaluateQuestionUseCase mockEvaluateQuestion;
    late MockGetEvaluationResultUseCase mockGetEvaluationResult;
    late EvaluationBloc bloc;

    final q1 = const QuestionEntity(
      id: 'q-1',
      practiceSessionId: 'sess-123',
      questionNumber: 1,
      question: 'Question 1Text',
      questionStatus: 'ANSWERED',
      evaluationStatus: 'COMPLETED',
      score: 8,
    );

    final q2 = const QuestionEntity(
      id: 'q-2',
      practiceSessionId: 'sess-123',
      questionNumber: 2,
      question: 'Question 2Text',
      questionStatus: 'ANSWERED',
      evaluationStatus: 'PENDING',
    );

    final sessionDetails = PracticeSessionEntity(
      id: 'sess-123',
      userId: 'user-1',
      userName: 'John Doe',
      technologyId: 'tech-1',
      technologyName: 'Java',
      experienceId: 'exp-1',
      experienceLabel: 'Senior',
      sessionStatus: 'COMPLETED',
      totalQuestions: 2,
      completedQuestions: 2,
      averageScore: 8.0,
      createdAt: DateTime.now(),
    );

    final eval1 = EvaluationEntity(
      questionId: 'q-1',
      sessionId: 'sess-123',
      questionNumber: 1,
      question: 'Question 1Text',
      userAnswer: 'My Answer',
      translatedAnswer: 'My Answer Translation',
      improvedAnswer: 'Improved Answer Text',
      explanation: 'AI Feedback explanation text',
      score: 8,
      evaluationStatus: 'COMPLETED',
      evaluatedAt: DateTime.now(),
    );

    setUp(() {
      mockGetSessionQuestions = MockGetSessionQuestionsUseCase();
      mockGetSessionDetails = MockGetPracticeSessionDetailsUseCase();
      mockEvaluateQuestion = MockEvaluateQuestionUseCase();
      mockGetEvaluationResult = MockGetEvaluationResultUseCase();

      bloc = EvaluationBloc(
        getSessionQuestionsUseCase: mockGetSessionQuestions,
        getPracticeSessionDetailsUseCase: mockGetSessionDetails,
        evaluateQuestionUseCase: mockEvaluateQuestion,
        getEvaluationResultUseCase: mockGetEvaluationResult,
      );
    });

    test('initial state should be EvaluationInitial', () {
      expect(bloc.state, equals(EvaluationInitial()));
    });

    group('LoadSessionQuestionsRequested', () {
      test('should emit [EvaluationLoading, EvaluationLoaded] with session details and lazily fetch evaluation', () async {
        mockGetSessionQuestions.result = [q1, q2];
        mockGetSessionDetails.result = sessionDetails;
        mockGetEvaluationResult.result = eval1;

        final expectedStates = [
          EvaluationLoading(),
          EvaluationLoaded(
            questions: [q1, q2],
            currentIndex: 0,
            averageScore: 8.0,
            isEvaluating: false,
          ),
          EvaluationLoaded(
            questions: [q1, q2],
            currentIndex: 0,
            averageScore: 8.0,
            activeEvaluation: eval1,
            isEvaluating: false,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const LoadSessionQuestionsRequested('sess-123'));
      });

      test('should emit [EvaluationLoading, EvaluationError] when fetch session questions fails', () async {
        mockGetSessionQuestions.error = ServerException('Failed to load questions');

        final expectedStates = [
          EvaluationLoading(),
          const EvaluationError('Failed to load questions'),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const LoadSessionQuestionsRequested('sess-123'));
      });
    });

    group('GetEvaluationRequested', () {
      test('should emit [EvaluationLoaded] with updated index and lazy load evaluation details if evaluated', () async {
        mockGetEvaluationResult.result = eval1;

        bloc.emit(EvaluationLoaded(
          questions: [q1, q2],
          currentIndex: 1,
          averageScore: 8.0,
          activeEvaluation: null,
        ));

        final expectedStates = [
          EvaluationLoaded(
            questions: [q1, q2],
            currentIndex: 0,
            averageScore: 8.0,
            activeEvaluation: null,
          ),
          EvaluationLoaded(
            questions: [q1, q2],
            currentIndex: 0,
            averageScore: 8.0,
            activeEvaluation: eval1,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const GetEvaluationRequested(questionId: 'q-1', index: 0));
      });
    });

    group('TriggerEvaluationRequested', () {
      test('should emit evaluating progress and updated loaded state with fresh evaluation', () async {
        mockEvaluateQuestion.result = eval1;
        mockGetSessionDetails.result = sessionDetails;

        bloc.emit(EvaluationLoaded(
          questions: [q1, q2],
          currentIndex: 1,
          averageScore: 4.0,
          activeEvaluation: null,
        ));

        final updatedQ1 = QuestionEntity(
          id: 'q-1',
          practiceSessionId: 'sess-123',
          questionNumber: 1,
          question: 'Question 1Text',
          userAnswer: q1.userAnswer,
          translatedAnswer: eval1.translatedAnswer,
          improvedAnswer: eval1.improvedAnswer,
          explanation: eval1.explanation,
          score: 8,
          questionStatus: 'ANSWERED',
          evaluationStatus: 'COMPLETED',
          evaluatedAt: eval1.evaluatedAt,
          createdAt: q1.createdAt,
          updatedAt: q1.updatedAt,
        );

        final expectedStates = [
          EvaluationLoaded(
            questions: [q1, q2],
            currentIndex: 1,
            averageScore: 4.0,
            activeEvaluation: null,
            isEvaluating: true,
          ),
          EvaluationLoaded(
            questions: [updatedQ1, q2],
            currentIndex: 1,
            averageScore: 8.0, // refreshed from mockGetSessionDetails
            activeEvaluation: eval1,
            isEvaluating: false,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const TriggerEvaluationRequested(questionId: 'q-1', index: 1));
      });

      test('should prevent duplicate triggers if already evaluating', () async {
        bloc.emit(EvaluationLoaded(
          questions: [q1, q2],
          currentIndex: 1,
          averageScore: 4.0,
          activeEvaluation: null,
          isEvaluating: true,
        ));

        expect(bloc.state, isA<EvaluationLoaded>());
        // Expect no new states to be emitted
        bloc.stream.listen((state) {
          fail('Should not emit state when isEvaluating is already true');
        });

        bloc.add(const TriggerEvaluationRequested(questionId: 'q-1', index: 1));
        await Future.delayed(const Duration(milliseconds: 50));
      });
    });

    group('ResetEvaluationState', () {
      test('should reset to EvaluationInitial state', () async {
        bloc.emit(EvaluationLoaded(
          questions: [q1],
          currentIndex: 0,
          averageScore: 8.0,
        ));

        final expectedStates = [
          EvaluationInitial(),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(ResetEvaluationState());
      });
    });
  });
}
