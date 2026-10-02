import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/features/evaluation/data/models/evaluation_model.dart';
import 'package:interview_bridge_app/features/evaluation/domain/entities/evaluation_entity.dart';

void main() {
  group('EvaluationModel', () {
    final tEvaluationJson = {
      'questionId': 'q-101',
      'sessionId': 's-202',
      'questionNumber': 1,
      'question': 'What is polymorphism?',
      'userAnswer': 'Polymorphism allows objects to take multiple forms.',
      'translatedAnswer': 'Polymorphism enables multiple forms.',
      'improvedAnswer': 'Polymorphism allows classes to define different behaviors via inheritance and interfaces.',
      'explanation': 'Good conceptual explanation with room for code examples.',
      'score': 8,
      'whatWasCorrect': 'Correctly identified that polymorphism allows objects to take multiple forms.',
      'whatWasMissing': 'Missing distinction between compile-time and runtime polymorphism.',
      'evaluationStatus': 'COMPLETED',
      'evaluatedAt': '2026-10-01T10:00:00.000Z',
    };

    test('A & B & D: parses whatWasCorrect, whatWasMissing, and all existing fields correctly from JSON', () {
      final model = EvaluationModel.fromJson(tEvaluationJson);

      expect(model.questionId, 'q-101');
      expect(model.sessionId, 's-202');
      expect(model.questionNumber, 1);
      expect(model.question, 'What is polymorphism?');
      expect(model.userAnswer, 'Polymorphism allows objects to take multiple forms.');
      expect(model.translatedAnswer, 'Polymorphism enables multiple forms.');
      expect(model.improvedAnswer, 'Polymorphism allows classes to define different behaviors via inheritance and interfaces.');
      expect(model.explanation, 'Good conceptual explanation with room for code examples.');
      expect(model.score, 8);
      // New fields
      expect(model.whatWasCorrect, 'Correctly identified that polymorphism allows objects to take multiple forms.');
      expect(model.whatWasMissing, 'Missing distinction between compile-time and runtime polymorphism.');
      expect(model.evaluationStatus, 'COMPLETED');
      expect(model.evaluatedAt, DateTime.parse('2026-10-01T10:00:00.000Z'));
    });

    test('C: toEntity preserves whatWasCorrect and whatWasMissing alongside all fields', () {
      final model = EvaluationModel.fromJson(tEvaluationJson);
      final entity = model.toEntity();

      expect(entity, isA<EvaluationEntity>());
      expect(entity.questionId, model.questionId);
      expect(entity.score, 8);
      expect(entity.whatWasCorrect, model.whatWasCorrect);
      expect(entity.whatWasMissing, model.whatWasMissing);
      expect(entity.translatedAnswer, model.translatedAnswer);
      expect(entity.improvedAnswer, model.improvedAnswer);
      expect(entity.explanation, model.explanation);
    });

    test('E: missing new fields in older JSON does not crash and defaults gracefully to null', () {
      final legacyJson = {
        'questionId': 'q-legacy',
        'sessionId': 's-legacy',
        'questionNumber': 2,
        'question': 'What is encapsulation?',
        'userAnswer': 'Encapsulation is data hiding.',
        'translatedAnswer': null,
        'improvedAnswer': 'Encapsulation bundles data and methods.',
        'explanation': 'Basic answer provided.',
        'score': 7,
        'evaluationStatus': 'COMPLETED',
      };

      final model = EvaluationModel.fromJson(legacyJson);

      expect(model.questionId, 'q-legacy');
      expect(model.score, 7);
      expect(model.whatWasCorrect, isNull);
      expect(model.whatWasMissing, isNull);
      expect(model.translatedAnswer, isNull);
    });

    test('toJson serializes whatWasCorrect and whatWasMissing correctly', () {
      final model = EvaluationModel.fromJson(tEvaluationJson);
      final json = model.toJson();

      expect(json['whatWasCorrect'], 'Correctly identified that polymorphism allows objects to take multiple forms.');
      expect(json['whatWasMissing'], 'Missing distinction between compile-time and runtime polymorphism.');
      expect(json['score'], 8);
      expect(json['questionId'], 'q-101');
    });
  });
}
