import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/exceptions/app_exceptions.dart';
import 'package:interview_bridge_app/features/practice_session/domain/entities/practice_session_entity.dart';
import 'package:interview_bridge_app/features/practice_session/domain/usecases/create_practice_session_usecase.dart';
import 'package:interview_bridge_app/features/practice_session/domain/usecases/get_practice_sessions_usecase.dart';
import 'package:interview_bridge_app/features/practice_session/domain/usecases/get_practice_session_details_usecase.dart';
import 'package:interview_bridge_app/features/practice_session/domain/usecases/generate_questions_usecase.dart';
import 'package:interview_bridge_app/features/practice_session/presentation/bloc/practice_session_bloc.dart';
import 'package:interview_bridge_app/features/practice_session/presentation/bloc/practice_session_event.dart';
import 'package:interview_bridge_app/features/practice_session/presentation/bloc/practice_session_state.dart';

// ============================================================================
// MANUAL MOCKS
// ============================================================================

class MockCreatePracticeSessionUseCase implements CreatePracticeSessionUseCase {
  PracticeSessionEntity? result;
  AppException? error;

  @override
  Future<PracticeSessionEntity> call(String technologyId, String experienceId, int totalQuestions) async {
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

class MockGetPracticeSessionsUseCase implements GetPracticeSessionsUseCase {
  List<PracticeSessionEntity>? result;
  AppException? error;

  @override
  Future<List<PracticeSessionEntity>> call() async {
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

class MockGenerateQuestionsUseCase implements GenerateQuestionsUseCase {
  AppException? error;
  bool called = false;

  @override
  Future<void> call(String sessionId) async {
    called = true;
    if (error != null) {
      throw error!;
    }
  }
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('PracticeSessionBloc', () {
    late MockCreatePracticeSessionUseCase mockCreatePracticeSession;
    late MockGetPracticeSessionsUseCase mockGetPracticeSessions;
    late MockGetPracticeSessionDetailsUseCase mockGetPracticeSessionDetails;
    late MockGenerateQuestionsUseCase mockGenerateQuestions;
    late PracticeSessionBloc bloc;

    final dummySession = PracticeSessionEntity(
      id: 'session-123',
      userId: 'user-456',
      userName: 'Test User',
      technologyId: 'tech-flutter',
      technologyName: 'Flutter',
      experienceId: 'exp-mid',
      experienceLabel: 'Mid Level',
      sessionStatus: 'CREATED',
      totalQuestions: 10,
      completedQuestions: 0,
      averageScore: 0.0,
      createdAt: DateTime(2026, 6, 5),
    );

    setUp(() {
      mockCreatePracticeSession = MockCreatePracticeSessionUseCase();
      mockGetPracticeSessions = MockGetPracticeSessionsUseCase();
      mockGetPracticeSessionDetails = MockGetPracticeSessionDetailsUseCase();
      mockGenerateQuestions = MockGenerateQuestionsUseCase();

      bloc = PracticeSessionBloc(
        createPracticeSessionUseCase: mockCreatePracticeSession,
        getPracticeSessionsUseCase: mockGetPracticeSessions,
        getPracticeSessionDetailsUseCase: mockGetPracticeSessionDetails,
        generateQuestionsUseCase: mockGenerateQuestions,
      );
    });

    test('initial state should be PracticeSessionInitial', () {
      expect(bloc.state, equals(PracticeSessionInitial()));
    });

    group('CreateSessionRequested', () {
      test('should emit [PracticeSessionLoading, PracticeSessionCreated] when successful', () async {
        mockCreatePracticeSession.result = dummySession;

        final expectedStates = [
          PracticeSessionLoading(),
          PracticeSessionCreated(dummySession),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const CreateSessionRequested(
          technologyId: 'tech-flutter',
          experienceId: 'exp-mid',
          totalQuestions: 10,
        ));
      });

      test('should emit [PracticeSessionLoading, PracticeSessionError] when fails', () async {
        mockCreatePracticeSession.error = NetworkException('Server connection failed');

        final expectedStates = [
          PracticeSessionLoading(),
          const PracticeSessionError('Server connection failed'),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const CreateSessionRequested(
          technologyId: 'tech-flutter',
          experienceId: 'exp-mid',
          totalQuestions: 10,
        ));
      });
    });

    group('GenerateQuestionsRequested', () {
      test('should emit [PracticeSessionLoading, PracticeQuestionsGenerated] when successful', () async {
        final updatedSession = PracticeSessionEntity(
          id: 'session-123',
          userId: 'user-456',
          userName: 'Test User',
          technologyId: 'tech-flutter',
          technologyName: 'Flutter',
          experienceId: 'exp-mid',
          experienceLabel: 'Mid Level',
          sessionStatus: 'IN_PROGRESS',
          totalQuestions: 10,
          completedQuestions: 0,
          averageScore: 0.0,
          createdAt: DateTime(2026, 6, 5),
        );
        mockGetPracticeSessionDetails.result = updatedSession;

        final expectedStates = [
          PracticeSessionLoading(),
          PracticeQuestionsGenerated(updatedSession),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const GenerateQuestionsRequested('session-123'));
      });

      test('should emit [PracticeSessionLoading, PracticeSessionError] when generation fails', () async {
        mockGenerateQuestions.error = ServerException('Failed to generate questions');

        final expectedStates = [
          PracticeSessionLoading(),
          const PracticeSessionError('Failed to generate questions'),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const GenerateQuestionsRequested('session-123'));
      });
    });

    group('LoadSessionHistoryRequested', () {
      test('should emit [PracticeSessionLoading, PracticeSessionsLoaded] when list is not empty', () async {
        final list = [dummySession];
        mockGetPracticeSessions.result = list;

        final expectedStates = [
          PracticeSessionLoading(),
          PracticeSessionsLoaded(list),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(LoadSessionHistoryRequested());
      });

      test('should emit [PracticeSessionLoading, PracticeSessionsEmpty] when list is empty', () async {
        mockGetPracticeSessions.result = [];

        final expectedStates = [
          PracticeSessionLoading(),
          PracticeSessionsEmpty(),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(LoadSessionHistoryRequested());
      });

      test('should emit [PracticeSessionLoading, PracticeSessionError] when fails', () async {
        mockGetPracticeSessions.error = NetworkException('No connection');

        final expectedStates = [
          PracticeSessionLoading(),
          const PracticeSessionError('No connection'),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(LoadSessionHistoryRequested());
      });

      test('should emit sorted sessions by createdAt DESC when successful', () async {
        final session1 = PracticeSessionEntity(
          id: 'session-1',
          userId: 'user-456',
          userName: 'Test User',
          technologyId: 'tech-flutter',
          technologyName: 'Flutter',
          experienceId: 'exp-mid',
          experienceLabel: 'Mid Level',
          sessionStatus: 'CREATED',
          totalQuestions: 10,
          completedQuestions: 0,
          averageScore: 0.0,
          createdAt: DateTime(2026, 6, 1),
        );
        final session2 = PracticeSessionEntity(
          id: 'session-2',
          userId: 'user-456',
          userName: 'Test User',
          technologyId: 'tech-flutter',
          technologyName: 'Flutter',
          experienceId: 'exp-mid',
          experienceLabel: 'Mid Level',
          sessionStatus: 'CREATED',
          totalQuestions: 10,
          completedQuestions: 0,
          averageScore: 0.0,
          createdAt: DateTime(2026, 6, 5),
        );
        final session3 = PracticeSessionEntity(
          id: 'session-3',
          userId: 'user-456',
          userName: 'Test User',
          technologyId: 'tech-flutter',
          technologyName: 'Flutter',
          experienceId: 'exp-mid',
          experienceLabel: 'Mid Level',
          sessionStatus: 'CREATED',
          totalQuestions: 10,
          completedQuestions: 0,
          averageScore: 0.0,
          createdAt: DateTime(2026, 6, 3),
        );

        mockGetPracticeSessions.result = [session1, session2, session3];

        final expectedStates = [
          PracticeSessionLoading(),
          PracticeSessionsLoaded([session2, session3, session1]),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(LoadSessionHistoryRequested());
      });
    });

    group('LoadSessionDetailsRequested', () {
      test('should emit [PracticeSessionLoading, PracticeSessionDetailsLoaded] when successful', () async {
        mockGetPracticeSessionDetails.result = dummySession;

        final expectedStates = [
          PracticeSessionLoading(),
          PracticeSessionDetailsLoaded(dummySession),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const LoadSessionDetailsRequested('session-123'));
      });

      test('should emit [PracticeSessionLoading, PracticeSessionError] when fails', () async {
        mockGetPracticeSessionDetails.error = CacheException('Local cache read failed');

        final expectedStates = [
          PracticeSessionLoading(),
          const PracticeSessionError('Local cache read failed'),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const LoadSessionDetailsRequested('session-123'));
      });
    });

    group('ResetSessionState', () {
      test('should emit [PracticeSessionInitial] when state is reset', () async {
        final expectedStates = [
          PracticeSessionInitial(),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(ResetSessionState());
      });
    });
  });
}
