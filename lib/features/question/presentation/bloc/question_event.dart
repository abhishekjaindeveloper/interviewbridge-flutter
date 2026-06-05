import 'package:equatable/equatable.dart';

abstract class QuestionEvent extends Equatable {
  const QuestionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSessionQuestionsRequested extends QuestionEvent {
  final String sessionId;

  const LoadSessionQuestionsRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class SubmitAnswerRequested extends QuestionEvent {
  final String questionId;
  final String answer;

  const SubmitAnswerRequested({
    required this.questionId,
    required this.answer,
  });

  @override
  List<Object?> get props => [questionId, answer];
}

class NavigateToQuestionRequested extends QuestionEvent {
  final int index;

  const NavigateToQuestionRequested(this.index);

  @override
  List<Object?> get props => [index];
}

class ResetQuestionState extends QuestionEvent {}
