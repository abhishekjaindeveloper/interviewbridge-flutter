import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/constants/app_constants.dart';
import 'package:interview_bridge_app/core/widgets/custom_button.dart';
import 'package:interview_bridge_app/features/question/domain/entities/question_entity.dart';
import 'package:interview_bridge_app/features/question/domain/entities/submit_answer_response_entity.dart';
import 'package:interview_bridge_app/features/question/domain/repositories/question_repository.dart';
import 'package:interview_bridge_app/features/question/domain/usecases/get_session_questions_usecase.dart';
import 'package:interview_bridge_app/features/question/domain/usecases/submit_answer_usecase.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_bloc.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_event.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_state.dart';
import 'package:interview_bridge_app/features/question/presentation/pages/question_page.dart';

class MockQuestionRepository implements QuestionRepository {
  final List<QuestionEntity> questions;
  String? lastSubmittedAnswer;
  int submitCount = 0;

  MockQuestionRepository({required this.questions});

  @override
  Future<List<QuestionEntity>> getSessionQuestions(String sessionId) async => questions;

  @override
  Future<QuestionEntity> getQuestionByNumber(String sessionId, int questionNumber) async =>
      questions.firstWhere((q) => q.questionNumber == questionNumber);

  @override
  Future<QuestionEntity> getQuestionDetails(String questionId) async =>
      questions.firstWhere((q) => q.id == questionId);

  @override
  Future<SubmitAnswerResponseEntity> submitAnswer(String questionId, String answer) async {
    lastSubmittedAnswer = answer;
    submitCount++;
    return SubmitAnswerResponseEntity(
      questionId: questionId,
      sessionId: 'sess-1',
      questionNumber: 1,
      question: 'Explain Dependency Injection in Spring Boot.',
      userAnswer: answer,
      questionStatus: 'ANSWERED',
      completedQuestions: 1,
      totalQuestions: 1,
      sessionStatus: 'IN_PROGRESS',
    );
  }
}

class TestQuestionBloc extends QuestionBloc {
  TestQuestionBloc({
    required super.getSessionQuestionsUseCase,
    required super.submitAnswerUseCase,
    required QuestionState initialState,
  }) {
    emit(initialState);
  }
}

void main() {
  const q1AnsweredPendingEval = QuestionEntity(
    id: 'q-1',
    practiceSessionId: 'sess-1',
    questionNumber: 1,
    question: 'Explain Dependency Injection in Spring Boot.',
    userAnswer: 'First answer draft',
    questionStatus: 'ANSWERED',
    evaluationStatus: 'PENDING',
    score: null,
  );

  const q1CompletedEval = QuestionEntity(
    id: 'q-1',
    practiceSessionId: 'sess-1',
    questionNumber: 1,
    question: 'Explain Dependency Injection in Spring Boot.',
    userAnswer: 'Final evaluated answer',
    questionStatus: 'ANSWERED',
    evaluationStatus: 'COMPLETED',
    score: 9,
  );

  Widget createWidgetUnderTest(QuestionBloc bloc) {
    return MaterialApp(
      home: BlocProvider<QuestionBloc>.value(
        value: bloc,
        child: const QuestionPage(sessionId: 'sess-1'),
      ),
    );
  }

  testWidgets('BUG 1: Answer can be edited and resubmitted after first submission when evaluation is not COMPLETED',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = MockQuestionRepository(questions: [q1AnsweredPendingEval]);
    final getUsecase = GetSessionQuestionsUseCase(repo);
    final submitUsecase = SubmitAnswerUseCase(repo);

    final bloc = TestQuestionBloc(
      getSessionQuestionsUseCase: getUsecase,
      submitAnswerUseCase: submitUsecase,
      initialState: const QuestionsLoaded(
        questions: [q1AnsweredPendingEval],
        currentIndex: 0,
        completedQuestions: 1,
        totalQuestions: 1,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest(bloc));
    await tester.pump();

    // 1. Text field must contain the initial userAnswer and be editable
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);
    final textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.enabled, isTrue);
    expect(textField.controller?.text, equals('First answer draft'));

    // 2. Submit button must be available and not locked with "Duplicate submission prevented"
    final submitBtnFinder = find.widgetWithText(CustomButton, AppConstants.submitAnswerButton);
    expect(submitBtnFinder, findsOneWidget);
    expect(find.text(AppConstants.duplicateSubmissionWarning), findsNothing);

    // 3. User edits their answer
    await tester.enterText(textFieldFinder, 'Updated improved second answer');
    await tester.pump();

    // 4. User taps Submit Answer
    await tester.ensureVisible(submitBtnFinder);
    await tester.tap(submitBtnFinder);
    await tester.pump();

    // 5. Verify the latest answer was submitted to use case
    expect(repo.lastSubmittedAnswer, equals('Updated improved second answer'));
    expect(repo.submitCount, equals(1));
  });

  testWidgets('BUG 1: Resubmission does not increment completedQuestions', (tester) async {
    final repo = MockQuestionRepository(questions: [q1AnsweredPendingEval]);
    final getUsecase = GetSessionQuestionsUseCase(repo);
    final submitUsecase = SubmitAnswerUseCase(repo);

    final bloc = QuestionBloc(
      getSessionQuestionsUseCase: getUsecase,
      submitAnswerUseCase: submitUsecase,
    );

    // Initial load: 1 answered out of 1
    bloc.emit(const QuestionsLoaded(
      questions: [q1AnsweredPendingEval],
      currentIndex: 0,
      completedQuestions: 1,
      totalQuestions: 1,
    ));

    // Request resubmission for already answered question
    bloc.add(const SubmitAnswerRequested(
      questionId: 'q-1',
      answer: 'Resubmitted answer',
    ));

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AnswerSubmitting>(),
        isA<AnswerSubmitted>().having((s) => s.completedQuestions, 'completedQuestions', equals(1)),
        isA<QuestionCompleted>().having((s) => s.completedQuestions, 'completedQuestions', equals(1)),
      ]),
    );

    expect((bloc.state as QuestionsLoaded).completedQuestions, equals(1));
  });

  testWidgets('BUG 1: Question with COMPLETED evaluation remains locked and cannot be edited', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = MockQuestionRepository(questions: [q1CompletedEval]);
    final getUsecase = GetSessionQuestionsUseCase(repo);
    final submitUsecase = SubmitAnswerUseCase(repo);

    final bloc = TestQuestionBloc(
      getSessionQuestionsUseCase: getUsecase,
      submitAnswerUseCase: submitUsecase,
      initialState: const QuestionsLoaded(
        questions: [q1CompletedEval],
        currentIndex: 0,
        completedQuestions: 1,
        totalQuestions: 1,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest(bloc));
    await tester.pump();

    // Text field must be disabled
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);

    // Button should display duplicate submission warning and be disabled
    expect(find.text(AppConstants.duplicateSubmissionWarning), findsOneWidget);
    final submitBtn = tester.widget<CustomButton>(
        find.widgetWithText(CustomButton, AppConstants.duplicateSubmissionWarning));
    expect(submitBtn.onPressed, isNull);
  });
}
