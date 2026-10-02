import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/constants/app_constants.dart';
import 'package:interview_bridge_app/features/question/domain/entities/question_entity.dart';
import 'package:interview_bridge_app/features/question/domain/entities/submit_answer_response_entity.dart';
import 'package:interview_bridge_app/features/question/domain/repositories/question_repository.dart';
import 'package:interview_bridge_app/features/question/domain/usecases/get_session_questions_usecase.dart';
import 'package:interview_bridge_app/features/question/domain/usecases/submit_answer_usecase.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_bloc.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_event.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_state.dart';
import 'package:interview_bridge_app/features/question/presentation/pages/question_page.dart';

class FakeQuestionRepository implements QuestionRepository {
  final List<QuestionEntity> questions;

  FakeQuestionRepository({required this.questions});

  @override
  Future<List<QuestionEntity>> getSessionQuestions(String sessionId) async {
    return questions;
  }

  @override
  Future<QuestionEntity> getQuestionByNumber(String sessionId, int questionNumber) async {
    return questions.firstWhere((q) => q.questionNumber == questionNumber);
  }

  @override
  Future<QuestionEntity> getQuestionDetails(String questionId) async {
    return questions.firstWhere((q) => q.id == questionId);
  }

  @override
  Future<SubmitAnswerResponseEntity> submitAnswer(String questionId, String answer) async {
    return const SubmitAnswerResponseEntity(
      questionId: 'q-1',
      sessionId: 'sess-1',
      questionNumber: 1,
      question: 'Explain Dependency Injection in Spring Boot.',
      userAnswer: 'Custom answer',
      questionStatus: 'ANSWERED',
      completedQuestions: 1,
      totalQuestions: 3,
      sessionStatus: 'IN_PROGRESS',
    );
  }
}

class TestQuestionBloc extends Bloc<QuestionEvent, QuestionState> implements QuestionBloc {
  @override
  final GetSessionQuestionsUseCase getSessionQuestionsUseCase;
  @override
  final SubmitAnswerUseCase submitAnswerUseCase;

  TestQuestionBloc({
    required QuestionState initialState,
    required this.getSessionQuestionsUseCase,
    required this.submitAnswerUseCase,
  }) : super(initialState) {
    on<NavigateToQuestionRequested>((event, emit) {
      final s = state;
      if (s is QuestionsLoaded) {
        emit(s.copyWith(currentIndex: event.index));
      }
    });
    on<LoadSessionQuestionsRequested>((event, emit) {});
    on<SubmitAnswerRequested>((event, emit) {});
    on<ResetQuestionState>((event, emit) {});
    on<ClearQuestionError>((event, emit) {});
  }
}

void main() {
  const tQuestion1 = QuestionEntity(
    id: 'q-1',
    practiceSessionId: 'sess-1',
    questionNumber: 1,
    question: 'Explain Dependency Injection in Spring Boot.',
    userAnswer: null,
    referenceAnswer: 'Dependency Injection is an IoC pattern where Spring injects beans at runtime.',
    questionStatus: 'PENDING',
  );

  const tQuestion2 = QuestionEntity(
    id: 'q-2',
    practiceSessionId: 'sess-1',
    questionNumber: 2,
    question: 'What is the role of @SpringBootApplication?',
    userAnswer: null,
    referenceAnswer: null, // Null reference answer
    questionStatus: 'PENDING',
  );

  const tQuestion3 = QuestionEntity(
    id: 'q-3',
    practiceSessionId: 'sess-1',
    questionNumber: 3,
    question: 'What is Maven?',
    userAnswer: null,
    referenceAnswer: '   ', // Blank whitespace reference answer
    questionStatus: 'PENDING',
  );

  final List<QuestionEntity> tQuestions = [tQuestion1, tQuestion2, tQuestion3];

  late FakeQuestionRepository repository;

  setUp(() {
    repository = FakeQuestionRepository(questions: tQuestions);
  });

  Widget createWidgetUnderTest({required int currentIndex, TestQuestionBloc? testBloc}) {
    final bloc = testBloc ??
        TestQuestionBloc(
          initialState: QuestionsLoaded(
            questions: tQuestions,
            currentIndex: currentIndex,
            completedQuestions: 0,
            totalQuestions: 3,
          ),
          getSessionQuestionsUseCase: GetSessionQuestionsUseCase(repository),
          submitAnswerUseCase: SubmitAnswerUseCase(repository),
        );

    return MaterialApp(
      home: BlocProvider<QuestionBloc>.value(
        value: bloc,
        child: const QuestionPage(sessionId: 'sess-1'),
      ),
    );
  }

  group('QuestionPage Show Reference Answer', () {
    testWidgets('D, E, F, G: toggling Show Reference Answer reveals and hides content', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest(currentIndex: 0));
      await tester.pumpAndSettle();

      // D: Button shows "Show Reference Answer" when referenceAnswer is present
      expect(find.text(AppConstants.showReferenceAnswerTitle), findsOneWidget);

      // E: Reference answer text is hidden initially
      expect(find.text(tQuestion1.referenceAnswer!), findsNothing);
      expect(find.text(AppConstants.referenceAnswerTitle), findsNothing);

      // F: Tap "Show Reference Answer"
      await tester.tap(find.text(AppConstants.showReferenceAnswerTitle));
      await tester.pumpAndSettle();

      // Button toggles to "Hide Reference Answer"
      expect(find.text(AppConstants.hideReferenceAnswerTitle), findsOneWidget);
      expect(find.text(AppConstants.showReferenceAnswerTitle), findsNothing);

      // Reference Answer title and text are displayed
      expect(find.text(AppConstants.referenceAnswerTitle), findsOneWidget);
      expect(find.text(tQuestion1.referenceAnswer!), findsOneWidget);

      // G: Tap "Hide Reference Answer"
      await tester.tap(find.text(AppConstants.hideReferenceAnswerTitle));
      await tester.pumpAndSettle();

      // Button reverts to "Show Reference Answer" and content is hidden
      expect(find.text(AppConstants.showReferenceAnswerTitle), findsOneWidget);
      expect(find.text(AppConstants.hideReferenceAnswerTitle), findsNothing);
      expect(find.text(tQuestion1.referenceAnswer!), findsNothing);
      expect(find.text(AppConstants.referenceAnswerTitle), findsNothing);
    });

    testWidgets('I: Null or blank referenceAnswer does not show the button', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Question 2 has null referenceAnswer
      await tester.pumpWidget(createWidgetUnderTest(currentIndex: 1));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.showReferenceAnswerTitle), findsNothing);
      expect(find.text(AppConstants.hideReferenceAnswerTitle), findsNothing);

      // Question 3 has blank whitespace referenceAnswer
      await tester.pumpWidget(createWidgetUnderTest(currentIndex: 2));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.showReferenceAnswerTitle), findsNothing);
      expect(find.text(AppConstants.hideReferenceAnswerTitle), findsNothing);
    });

    testWidgets('J: Moving to another question resets reference answer visibility', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Expand reference answer on Question 1
      await tester.pumpWidget(createWidgetUnderTest(currentIndex: 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppConstants.showReferenceAnswerTitle));
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.hideReferenceAnswerTitle), findsOneWidget);
      expect(find.text(tQuestion1.referenceAnswer!), findsOneWidget);

      // Move to Question 2
      await tester.pumpWidget(createWidgetUnderTest(currentIndex: 1));
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.showReferenceAnswerTitle), findsNothing);

      // Return to Question 1: reference answer must start hidden
      await tester.pumpWidget(createWidgetUnderTest(currentIndex: 0));
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.showReferenceAnswerTitle), findsOneWidget);
      expect(find.text(AppConstants.hideReferenceAnswerTitle), findsNothing);
      expect(find.text(tQuestion1.referenceAnswer!), findsNothing);
    });

    testWidgets('K, L, M: Existing answer input, submission, and UI remain fully functional', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest(currentIndex: 0));
      await tester.pumpAndSettle();

      // M: Progress, question number, and question text render
      expect(find.text(AppConstants.questionOfTotal(1, 3)), findsOneWidget);
      expect(find.text(tQuestion1.question), findsOneWidget);

      // K: Answer input remains usable
      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);
      await tester.enterText(inputFinder, 'My customized answer for Q1.');
      await tester.pump();
      expect(find.text('My customized answer for Q1.'), findsOneWidget);

      // Submit button is present and usable
      expect(find.text(AppConstants.submitAnswerButton), findsOneWidget);

      // L: Navigation buttons are present
      expect(find.text(AppConstants.previousQuestionButton), findsOneWidget);
      expect(find.text(AppConstants.nextQuestionButton), findsOneWidget);
    });
  });
}
