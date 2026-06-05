import 'package:equatable/equatable.dart';

class SubmitAnswerResponseEntity extends Equatable {
  final String questionId;
  final String sessionId;
  final int questionNumber;
  final String question;
  final String userAnswer;
  final String questionStatus;
  final int completedQuestions;
  final int totalQuestions;
  final String sessionStatus;

  const SubmitAnswerResponseEntity({
    required this.questionId,
    required this.sessionId,
    required this.questionNumber,
    required this.question,
    required this.userAnswer,
    required this.questionStatus,
    required this.completedQuestions,
    required this.totalQuestions,
    required this.sessionStatus,
  });

  @override
  List<Object?> get props => [
        questionId,
        sessionId,
        questionNumber,
        question,
        userAnswer,
        questionStatus,
        completedQuestions,
        totalQuestions,
        sessionStatus,
      ];
}
