import '../../domain/entities/evaluation_entity.dart';

class EvaluationModel extends EvaluationEntity {
  const EvaluationModel({
    required super.questionId,
    required super.sessionId,
    required super.questionNumber,
    required super.question,
    required super.userAnswer,
    super.translatedAnswer,
    super.improvedAnswer,
    super.explanation,
    super.score,
    required super.evaluationStatus,
    super.evaluatedAt,
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      questionId: json['questionId'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      questionNumber: json['questionNumber'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      userAnswer: json['userAnswer'] as String? ?? '',
      translatedAnswer: json['translatedAnswer'] as String?,
      improvedAnswer: json['improvedAnswer'] as String?,
      explanation: json['explanation'] as String?,
      score: json['score'] as int?,
      evaluationStatus: json['evaluationStatus'] as String? ?? 'PENDING',
      evaluatedAt: json['evaluatedAt'] != null
          ? DateTime.tryParse(json['evaluatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'sessionId': sessionId,
      'questionNumber': questionNumber,
      'question': question,
      'userAnswer': userAnswer,
      'translatedAnswer': translatedAnswer,
      'improvedAnswer': improvedAnswer,
      'explanation': explanation,
      'score': score,
      'evaluationStatus': evaluationStatus,
      'evaluatedAt': evaluatedAt?.toIso8601String(),
    };
  }

  EvaluationEntity toEntity() {
    return EvaluationEntity(
      questionId: questionId,
      sessionId: sessionId,
      questionNumber: questionNumber,
      question: question,
      userAnswer: userAnswer,
      translatedAnswer: translatedAnswer,
      improvedAnswer: improvedAnswer,
      explanation: explanation,
      score: score,
      evaluationStatus: evaluationStatus,
      evaluatedAt: evaluatedAt,
    );
  }
}
