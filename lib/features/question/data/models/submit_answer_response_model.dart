import '../../domain/entities/submit_answer_response_entity.dart';

class SubmitAnswerResponseModel extends SubmitAnswerResponseEntity {
  const SubmitAnswerResponseModel({
    required super.questionId,
    required super.sessionId,
    required super.questionNumber,
    required super.question,
    required super.userAnswer,
    required super.questionStatus,
    required super.completedQuestions,
    required super.totalQuestions,
    required super.sessionStatus,
  });

  factory SubmitAnswerResponseModel.fromJson(Map<String, dynamic> json) {
    return SubmitAnswerResponseModel(
      questionId: json['questionId'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      questionNumber: json['questionNumber'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      userAnswer: json['userAnswer'] as String? ?? '',
      questionStatus: json['questionStatus'] as String? ?? 'ANSWERED',
      completedQuestions: json['completedQuestions'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      sessionStatus: json['sessionStatus'] as String? ?? 'IN_PROGRESS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'sessionId': sessionId,
      'questionNumber': questionNumber,
      'question': question,
      'userAnswer': userAnswer,
      'questionStatus': questionStatus,
      'completedQuestions': completedQuestions,
      'totalQuestions': totalQuestions,
      'sessionStatus': sessionStatus,
    };
  }

  SubmitAnswerResponseEntity toEntity() {
    return SubmitAnswerResponseEntity(
      questionId: questionId,
      sessionId: sessionId,
      questionNumber: questionNumber,
      question: question,
      userAnswer: userAnswer,
      questionStatus: questionStatus,
      completedQuestions: completedQuestions,
      totalQuestions: totalQuestions,
      sessionStatus: sessionStatus,
    );
  }
}
