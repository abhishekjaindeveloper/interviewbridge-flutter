import 'package:equatable/equatable.dart';

abstract class PracticeSessionEvent extends Equatable {
  const PracticeSessionEvent();

  @override
  List<Object?> get props => [];
}

class CreateSessionRequested extends PracticeSessionEvent {
  final String technologyId;
  final String experienceId;
  final int totalQuestions;

  const CreateSessionRequested({
    required this.technologyId,
    required this.experienceId,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [technologyId, experienceId, totalQuestions];
}

class GenerateQuestionsRequested extends PracticeSessionEvent {
  final String sessionId;

  const GenerateQuestionsRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class LoadSessionHistoryRequested extends PracticeSessionEvent {}

class LoadSessionDetailsRequested extends PracticeSessionEvent {
  final String sessionId;

  const LoadSessionDetailsRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class ResetSessionState extends PracticeSessionEvent {}
