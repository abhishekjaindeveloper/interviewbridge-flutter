import 'package:equatable/equatable.dart';

class QuestionEntity extends Equatable {
  final String id;
  final String practiceSessionId;
  final int questionNumber;
  final String question;
  final String? userAnswer;
  final String? translatedAnswer;
  final String? improvedAnswer;
  final String? explanation;
  final int? score;
  final String questionStatus;
  final String? evaluationStatus;
  final DateTime? evaluatedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QuestionEntity({
    required this.id,
    required this.practiceSessionId,
    required this.questionNumber,
    required this.question,
    this.userAnswer,
    this.translatedAnswer,
    this.improvedAnswer,
    this.explanation,
    this.score,
    required this.questionStatus,
    this.evaluationStatus,
    this.evaluatedAt,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        practiceSessionId,
        questionNumber,
        question,
        userAnswer,
        translatedAnswer,
        improvedAnswer,
        explanation,
        score,
        questionStatus,
        evaluationStatus,
        evaluatedAt,
        createdAt,
        updatedAt,
      ];
}
