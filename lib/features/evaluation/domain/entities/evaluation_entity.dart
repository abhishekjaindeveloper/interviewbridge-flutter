import 'package:equatable/equatable.dart';

class EvaluationEntity extends Equatable {
  final String questionId;
  final String sessionId;
  final int questionNumber;
  final String question;
  final String userAnswer;
  final String? translatedAnswer;
  final String? improvedAnswer;
  final String? explanation;
  final int? score;
  final String evaluationStatus;
  final DateTime? evaluatedAt;

  const EvaluationEntity({
    required this.questionId,
    required this.sessionId,
    required this.questionNumber,
    required this.question,
    required this.userAnswer,
    this.translatedAnswer,
    this.improvedAnswer,
    this.explanation,
    this.score,
    required this.evaluationStatus,
    this.evaluatedAt,
  });

  @override
  List<Object?> get props => [
        questionId,
        sessionId,
        questionNumber,
        question,
        userAnswer,
        translatedAnswer,
        improvedAnswer,
        explanation,
        score,
        evaluationStatus,
        evaluatedAt,
      ];
}
