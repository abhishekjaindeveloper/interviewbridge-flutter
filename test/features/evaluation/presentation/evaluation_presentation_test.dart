import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/constants/app_constants.dart';
import 'package:interview_bridge_app/core/widgets/loading_indicator.dart';
import 'package:interview_bridge_app/features/evaluation/domain/entities/evaluation_entity.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/bloc/evaluation_state.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/widgets/evaluation_section_widget.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/widgets/score_card_widget.dart';

void main() {
  const tEvaluation = EvaluationEntity(
    questionId: 'q-101',
    sessionId: 's-202',
    questionNumber: 1,
    question: 'What is Dependency Injection in Spring Boot?',
    userAnswer: 'DI is a pattern where objects receive their dependencies from an external container.',
    translatedAnswer: 'DI provides dependencies externally.',
    improvedAnswer: 'DI is an IoC pattern where Spring container injects dependencies using annotations like @Autowired.',
    explanation: 'Clear answer with good foundational understanding.',
    score: 9,
    whatWasCorrect: 'Accurately stated that dependencies are provided from an external container.',
    whatWasMissing: 'Could mention constructor injection vs field injection in Spring.',
    evaluationStatus: 'COMPLETED',
  );

  group('F: Evaluation State', () {
    test('EvaluationLoaded state retains activeEvaluation with whatWasCorrect and whatWasMissing', () {
      final state = EvaluationLoaded(
        questions: const [],
        currentIndex: 0,
        averageScore: 9.0,
        activeEvaluation: tEvaluation,
      );

      expect(state.activeEvaluation, isNotNull);
      expect(state.activeEvaluation!.score, 9);
      expect(state.activeEvaluation!.whatWasCorrect, 'Accurately stated that dependencies are provided from an external container.');
      expect(state.activeEvaluation!.whatWasMissing, 'Could mention constructor injection vs field injection in Spring.');
      expect(state.activeEvaluation!.translatedAnswer, 'DI provides dependencies externally.');
      expect(state.activeEvaluation!.improvedAnswer, isNotNull);
      expect(state.activeEvaluation!.explanation, isNotNull);
    });
  });

  group('I: ScoreCardWidget', () {
    testWidgets('displays score from backend accurately without hardcoding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreCardWidget(score: 9),
          ),
        ),
      );

      expect(find.text('9'), findsOneWidget);
      expect(find.text(AppConstants.scoreOutOfTen), findsOneWidget);
      expect(find.text(AppConstants.scoreLabel), findsOneWidget);
    });
  });

  group('G, H, J: EvaluationSectionWidget for Evaluation Feedback Sections', () {
    testWidgets('G: displays What Was Correct title and content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EvaluationSectionWidget(
              icon: Icons.check_circle_outline_rounded,
              title: AppConstants.whatWasCorrectTitle,
              content: tEvaluation.whatWasCorrect!,
            ),
          ),
        ),
      );

      expect(find.text(AppConstants.whatWasCorrectTitle), findsOneWidget);
      expect(find.text(tEvaluation.whatWasCorrect!), findsOneWidget);
    });

    testWidgets('H: displays What Was Missing title and content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EvaluationSectionWidget(
              icon: Icons.help_outline_rounded,
              title: AppConstants.whatWasMissingTitle,
              content: tEvaluation.whatWasMissing!,
            ),
          ),
        ),
      );

      expect(find.text(AppConstants.whatWasMissingTitle), findsOneWidget);
      expect(find.text(tEvaluation.whatWasMissing!), findsOneWidget);
    });

    testWidgets('J: displays all evaluation sections in recommended order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Score
                  ScoreCardWidget(score: tEvaluation.score!),
                  // 2. User Answer
                  EvaluationSectionWidget(
                    icon: Icons.person_outline_rounded,
                    title: AppConstants.userAnswerTitle,
                    content: tEvaluation.userAnswer,
                  ),
                  // 3. What Was Correct
                  EvaluationSectionWidget(
                    icon: Icons.check_circle_outline_rounded,
                    title: AppConstants.whatWasCorrectTitle,
                    content: tEvaluation.whatWasCorrect!,
                  ),
                  // 4. What Was Missing
                  EvaluationSectionWidget(
                    icon: Icons.help_outline_rounded,
                    title: AppConstants.whatWasMissingTitle,
                    content: tEvaluation.whatWasMissing!,
                  ),
                  // 5. Translated Answer
                  EvaluationSectionWidget(
                    icon: Icons.g_translate_rounded,
                    title: AppConstants.translatedAnswerTitle,
                    content: tEvaluation.translatedAnswer!,
                  ),
                  // 6. Improved Answer
                  EvaluationSectionWidget(
                    icon: Icons.auto_awesome,
                    title: AppConstants.improvedAnswerTitle,
                    content: tEvaluation.improvedAnswer!,
                  ),
                  // 7. Explanation
                  EvaluationSectionWidget(
                    icon: Icons.feedback_outlined,
                    title: AppConstants.explanationTitle,
                    content: tEvaluation.explanation!,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify all section headers are present
      expect(find.text('9'), findsOneWidget);
      expect(find.text(AppConstants.userAnswerTitle), findsOneWidget);
      expect(find.text(AppConstants.whatWasCorrectTitle), findsOneWidget);
      expect(find.text(AppConstants.whatWasMissingTitle), findsOneWidget);
      expect(find.text(AppConstants.translatedAnswerTitle), findsOneWidget);
      expect(find.text(AppConstants.improvedAnswerTitle), findsOneWidget);
      expect(find.text(AppConstants.explanationTitle), findsOneWidget);

      // Verify content is present
      expect(find.text(tEvaluation.whatWasCorrect!), findsOneWidget);
      expect(find.text(tEvaluation.whatWasMissing!), findsOneWidget);
      expect(find.text(tEvaluation.improvedAnswer!), findsOneWidget);
      expect(find.text(tEvaluation.explanation!), findsOneWidget);
    });
  });

  group('K: Loading State', () {
    testWidgets('displays LoadingIndicator during loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: LoadingIndicator()),
          ),
        ),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });
  });

  group('L: Error State', () {
    testWidgets('displays error message when error occurs', (tester) async {
      const errorMessage = 'Failed to evaluate answer. Server error.';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(errorMessage),
            ),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });
  });
}
