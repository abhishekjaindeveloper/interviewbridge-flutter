import '../../domain/entities/question_entity.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.practiceSessionId,
    required super.questionNumber,
    required super.question,
    super.userAnswer,
    super.translatedAnswer,
    super.improvedAnswer,
    super.explanation,
    super.score,
    required super.questionStatus,
    super.evaluationStatus,
    super.evaluatedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String? ?? '',
      practiceSessionId: json['practiceSessionId'] as String? ?? '',
      questionNumber: json['questionNumber'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      userAnswer: json['userAnswer'] as String?,
      translatedAnswer: json['translatedAnswer'] as String?,
      improvedAnswer: json['improvedAnswer'] as String?,
      explanation: json['explanation'] as String?,
      score: json['score'] as int?,
      questionStatus: json['questionStatus'] as String? ?? 'PENDING',
      evaluationStatus: json['evaluationStatus'] as String?,
      evaluatedAt: json['evaluatedAt'] != null ? DateTime.tryParse(json['evaluatedAt'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'practiceSessionId': practiceSessionId,
      'questionNumber': questionNumber,
      'question': question,
      'userAnswer': userAnswer,
      'translatedAnswer': translatedAnswer,
      'improvedAnswer': improvedAnswer,
      'explanation': explanation,
      'score': score,
      'questionStatus': questionStatus,
      'evaluationStatus': evaluationStatus,
      'evaluatedAt': evaluatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  QuestionEntity toEntity() {
    return QuestionEntity(
      id: id,
      practiceSessionId: practiceSessionId,
      questionNumber: questionNumber,
      question: question,
      userAnswer: userAnswer,
      translatedAnswer: translatedAnswer,
      improvedAnswer: improvedAnswer,
      explanation: explanation,
      score: score,
      questionStatus: questionStatus,
      evaluationStatus: evaluationStatus,
      evaluatedAt: evaluatedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
