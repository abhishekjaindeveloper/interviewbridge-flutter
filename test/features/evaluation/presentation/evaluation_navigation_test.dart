import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/constants/app_constants.dart';
import 'package:interview_bridge_app/core/routes/route_constants.dart';
import 'package:interview_bridge_app/core/widgets/custom_button.dart';
import 'package:interview_bridge_app/features/evaluation/domain/entities/evaluation_entity.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/bloc/evaluation_bloc.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/bloc/evaluation_state.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/pages/evaluation_page.dart';
import 'package:interview_bridge_app/features/practice_session/domain/entities/practice_session_entity.dart';
import 'package:interview_bridge_app/features/practice_session/domain/usecases/get_practice_session_details_usecase.dart';
import 'package:interview_bridge_app/features/question/domain/entities/question_entity.dart';
import 'package:interview_bridge_app/features/question/domain/usecases/get_session_questions_usecase.dart';
import 'package:interview_bridge_app/features/evaluation/domain/usecases/evaluate_question_usecase.dart';
import 'package:interview_bridge_app/features/evaluation/domain/usecases/get_evaluation_result_usecase.dart';

class MockGetSessionQuestionsUseCase implements GetSessionQuestionsUseCase {
  final List<QuestionEntity> questions;
  MockGetSessionQuestionsUseCase(this.questions);
  @override
  Future<List<QuestionEntity>> call(String sessionId) async => questions;
}

class MockGetPracticeSessionDetailsUseCase implements GetPracticeSessionDetailsUseCase {
  @override
  Future<PracticeSessionEntity> call(String sessionId) async => PracticeSessionEntity(
        id: sessionId,
        userId: 'u-1',
        userName: 'Test User',
        technologyId: 't-1',
        technologyName: 'Java',
        experienceId: 'e-1',
        experienceLabel: '1 Year',
        totalQuestions: 1,
        completedQuestions: 1,
        averageScore: 9.0,
        sessionStatus: 'COMPLETED',
        startedAt: DateTime.now(),
      );
}

class MockEvaluateQuestionUseCase implements EvaluateQuestionUseCase {
  final EvaluationEntity evaluation;
  MockEvaluateQuestionUseCase(this.evaluation);
  @override
  Future<EvaluationEntity> call(String questionId) async => evaluation;
}

class MockGetEvaluationResultUseCase implements GetEvaluationResultUseCase {
  final EvaluationEntity evaluation;
  MockGetEvaluationResultUseCase(this.evaluation);
  @override
  Future<EvaluationEntity> call(String questionId) async => evaluation;
}

class TestEvaluationBloc extends EvaluationBloc {
  TestEvaluationBloc({
    required EvaluationState initialState,
    required List<QuestionEntity> questions,
    required EvaluationEntity evaluation,
  }) : super(
          getSessionQuestionsUseCase: MockGetSessionQuestionsUseCase(questions),
          getPracticeSessionDetailsUseCase: MockGetPracticeSessionDetailsUseCase(),
          evaluateQuestionUseCase: MockEvaluateQuestionUseCase(evaluation),
          getEvaluationResultUseCase: MockGetEvaluationResultUseCase(evaluation),
        ) {
    emit(initialState);
  }
}

void main() {
  const dummyQuestion = QuestionEntity(
    id: 'q-1',
    practiceSessionId: 'sess-1',
    questionNumber: 1,
    question: 'Explain Dependency Injection in Spring Boot.',
    userAnswer: 'DI is inversion of control where container injects dependencies.',
    questionStatus: 'ANSWERED',
    evaluationStatus: 'COMPLETED',
    score: 9,
  );

  final dummyEvaluation = EvaluationEntity(
    questionId: 'q-1',
    sessionId: 'sess-1',
    questionNumber: 1,
    question: 'Explain Dependency Injection in Spring Boot.',
    userAnswer: 'DI is inversion of control where container injects dependencies.',
    score: 9,
    whatWasCorrect: 'Good explanation of IoC and container management.',
    whatWasMissing: 'Could mention @Autowired or constructor injection.',
    translatedAnswer: null,
    improvedAnswer: 'DI allows decoupling.',
    explanation: 'Clear answer.',
    evaluationStatus: 'COMPLETED',
    evaluatedAt: DateTime.now(),
  );

  final loadedState = EvaluationLoaded(
    questions: const [dummyQuestion],
    currentIndex: 0,
    averageScore: 9.0,
    activeEvaluation: dummyEvaluation,
  );

  testWidgets('BUG 2: EvaluationPage Back pops cleanly when canPop is true', (tester) async {
    final bloc = TestEvaluationBloc(
      initialState: loadedState,
      questions: const [dummyQuestion],
      evaluation: dummyEvaluation,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: RouteConstants.evaluationResults),
                    builder: (_) => BlocProvider<EvaluationBloc>.value(
                      value: bloc,
                      child: const EvaluationPage(sessionId: 'sess-1'),
                    ),
                  ),
                );
              },
              child: const Text('Open Evaluation'),
            ),
          ),
        ),
      ),
    );

    // Open EvaluationPage
    await tester.tap(find.text('Open Evaluation'));
    await tester.pumpAndSettle();

    expect(find.byType(EvaluationPage), findsOneWidget);

    // Press AppBar Back button
    final backBtn = find.byIcon(Icons.arrow_back);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verification: We returned back to initial page without any exception
    expect(find.text('Open Evaluation'), findsOneWidget);
    expect(find.byType(EvaluationPage), findsNothing);
  });

  testWidgets('BUG 2: EvaluationPage Back navigates safely to Home when canPop is false', (tester) async {
    final bloc = TestEvaluationBloc(
      initialState: loadedState,
      questions: const [dummyQuestion],
      evaluation: dummyEvaluation,
    );

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: RouteConstants.evaluationResults,
        routes: {
          RouteConstants.evaluationResults: (_) => BlocProvider<EvaluationBloc>.value(
                value: bloc,
                child: const EvaluationPage(sessionId: 'sess-1'),
              ),
          RouteConstants.home: (_) => const Scaffold(body: Text('Home Screen')),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EvaluationPage), findsOneWidget);

    // Press Back when no other route is on the stack
    final backBtn = find.byIcon(Icons.arrow_back);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Must navigate to Home Screen safely without Navigator assertion
    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('BUG 2: Rapid/repeated Back taps do not cause Navigator assertion or multiple pops', (tester) async {
    final bloc = TestEvaluationBloc(
      initialState: loadedState,
      questions: const [dummyQuestion],
      evaluation: dummyEvaluation,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: RouteConstants.evaluationResults),
                    builder: (_) => BlocProvider<EvaluationBloc>.value(
                      value: bloc,
                      child: const EvaluationPage(sessionId: 'sess-1'),
                    ),
                  ),
                );
              },
              child: const Text('Open Evaluation'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Evaluation'));
    await tester.pumpAndSettle();

    final backBtn = find.byIcon(Icons.arrow_back);

    // Rapid double tap
    await tester.tap(backBtn);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(find.text('Open Evaluation'), findsOneWidget);
  });

  testWidgets('BUG 2: Back to Session History button navigates safely without popUntil assertion', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final bloc = TestEvaluationBloc(
      initialState: loadedState,
      questions: const [dummyQuestion],
      evaluation: dummyEvaluation,
    );

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: RouteConstants.evaluationResults,
        routes: {
          RouteConstants.evaluationResults: (_) => BlocProvider<EvaluationBloc>.value(
                value: bloc,
                child: const EvaluationPage(sessionId: 'sess-1'),
              ),
          RouteConstants.home: (_) => const Scaffold(body: Text('Home Screen')),
          RouteConstants.sessionHistory: (_) => const Scaffold(body: Text('Session History Screen')),
        },
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap "Back to Session History"
    final historyBtn = find.widgetWithText(TextButton, AppConstants.backToHistoryButton);
    expect(historyBtn, findsOneWidget);
    await tester.ensureVisible(historyBtn);
    await tester.tap(historyBtn);
    await tester.pumpAndSettle();

    // Must safely reach Session History Screen
    expect(find.text('Session History Screen'), findsOneWidget);
  });

  testWidgets('BUG 2: Finish Session button navigates safely to Home', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final bloc = TestEvaluationBloc(
      initialState: loadedState,
      questions: const [dummyQuestion],
      evaluation: dummyEvaluation,
    );

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: RouteConstants.evaluationResults,
        routes: {
          RouteConstants.evaluationResults: (_) => BlocProvider<EvaluationBloc>.value(
                value: bloc,
                child: const EvaluationPage(sessionId: 'sess-1'),
              ),
          RouteConstants.home: (_) => const Scaffold(body: Text('Home Screen')),
        },
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap "Finish Session"
    final finishBtn = find.widgetWithText(CustomButton, AppConstants.closeSessionButton);
    expect(finishBtn, findsOneWidget);
    await tester.ensureVisible(finishBtn);
    await tester.tap(finishBtn);
    await tester.pumpAndSettle();

    // Must safely reach Home Screen
    expect(find.text('Home Screen'), findsOneWidget);
  });
}
