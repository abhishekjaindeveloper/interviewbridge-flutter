import 'package:equatable/equatable.dart';

abstract class EvaluationEvent extends Equatable {
  const EvaluationEvent();

  @override
  List<Object?> get props => [];
}

class LoadSessionQuestionsRequested extends EvaluationEvent {
  final String sessionId;

  const LoadSessionQuestionsRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class GetEvaluationRequested extends EvaluationEvent {
  final String questionId;
  final int index;

  const GetEvaluationRequested({
    required this.questionId,
    required this.index,
  });

  @override
  List<Object?> get props => [questionId, index];
}

class TriggerEvaluationRequested extends EvaluationEvent {
  final String questionId;
  final int index;

  const TriggerEvaluationRequested({
    required this.questionId,
    required this.index,
  });

  @override
  List<Object?> get props => [questionId, index];
}

class ResetEvaluationState extends EvaluationEvent {}
