import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/features/question/data/models/question_model.dart';
import 'package:interview_bridge_app/features/question/domain/entities/question_entity.dart';

void main() {
  group('QuestionModel', () {
    final tQuestionJson = {
      'id': 'q-1',
      'practiceSessionId': 'session-100',
      'questionNumber': 1,
      'question': 'Explain the difference between HashMap and ConcurrentHashMap in Java.',
      'userAnswer': 'HashMap is not synchronized while ConcurrentHashMap is thread-safe.',
      'referenceAnswer': 'HashMap is non-synchronized and permits null keys/values, whereas ConcurrentHashMap is thread-safe using bucket-level locking and does not permit null keys/values.',
      'translatedAnswer': null,
      'improvedAnswer': null,
      'explanation': null,
      'score': null,
      'questionStatus': 'ANSWERED',
      'evaluationStatus': 'PENDING',
      'evaluatedAt': null,
      'createdAt': '2026-10-01T12:00:00.000Z',
      'updatedAt': '2026-10-01T12:05:00.000Z',
    };

    test('A: parses referenceAnswer from JSON', () {
      final model = QuestionModel.fromJson(tQuestionJson);

      expect(model.id, 'q-1');
      expect(model.practiceSessionId, 'session-100');
      expect(model.questionNumber, 1);
      expect(model.question, 'Explain the difference between HashMap and ConcurrentHashMap in Java.');
      expect(model.referenceAnswer, 'HashMap is non-synchronized and permits null keys/values, whereas ConcurrentHashMap is thread-safe using bucket-level locking and does not permit null keys/values.');
      expect(model.userAnswer, 'HashMap is not synchronized while ConcurrentHashMap is thread-safe.');
      expect(model.questionStatus, 'ANSWERED');
    });

    test('B: handles missing referenceAnswer without crashing and defaults to null', () {
      final legacyJson = {
        'id': 'q-legacy',
        'practiceSessionId': 'session-legacy',
        'questionNumber': 2,
        'question': 'What is an abstract class?',
        'questionStatus': 'PENDING',
      };

      final model = QuestionModel.fromJson(legacyJson);

      expect(model.id, 'q-legacy');
      expect(model.referenceAnswer, isNull);
      expect(model.questionNumber, 2);
      expect(model.questionStatus, 'PENDING');
    });

    test('C: toEntity() preserves referenceAnswer', () {
      final model = QuestionModel.fromJson(tQuestionJson);
      final entity = model.toEntity();

      expect(entity, isA<QuestionEntity>());
      expect(entity.id, model.id);
      expect(entity.referenceAnswer, model.referenceAnswer);
      expect(entity.question, model.question);
      expect(entity.userAnswer, model.userAnswer);
    });

    test('toJson() serializes referenceAnswer', () {
      final model = QuestionModel.fromJson(tQuestionJson);
      final json = model.toJson();

      expect(json['id'], 'q-1');
      expect(json['referenceAnswer'], 'HashMap is non-synchronized and permits null keys/values, whereas ConcurrentHashMap is thread-safe using bucket-level locking and does not permit null keys/values.');
    });
  });
}
