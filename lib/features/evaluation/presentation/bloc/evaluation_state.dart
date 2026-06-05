import 'package:equatable/equatable.dart';
import '../../domain/entities/evaluation_entity.dart';
import '../../../question/domain/entities/question_entity.dart';

abstract class EvaluationState extends Equatable {
  const EvaluationState();

  @override
  List<Object?> get props => [];
}

class EvaluationInitial extends EvaluationState {}

class EvaluationLoading extends EvaluationState {}

class EvaluationLoaded extends EvaluationState {
  final List<QuestionEntity> questions;
  final int currentIndex;
  final double averageScore;
  final EvaluationEntity? activeEvaluation;
  final bool isEvaluating;
  final String? evaluateError;

  const EvaluationLoaded({
    required this.questions,
    required this.currentIndex,
    required this.averageScore,
    this.activeEvaluation,
    this.isEvaluating = false,
    this.evaluateError,
  });

  EvaluationLoaded copyWith({
    List<QuestionEntity>? questions,
    int? currentIndex,
    double? averageScore,
    EvaluationEntity? activeEvaluation,
    bool clearActiveEvaluation = false,
    bool? isEvaluating,
    String? evaluateError,
    bool clearEvaluateError = false,
  }) {
    return EvaluationLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      averageScore: averageScore ?? this.averageScore,
      activeEvaluation: clearActiveEvaluation
          ? null
          : (activeEvaluation ?? this.activeEvaluation),
      isEvaluating: isEvaluating ?? this.isEvaluating,
      evaluateError: clearEvaluateError ? null : (evaluateError ?? this.evaluateError),
    );
  }

  @override
  List<Object?> get props => [
        questions,
        currentIndex,
        averageScore,
        activeEvaluation,
        isEvaluating,
        evaluateError,
      ];
}

class EvaluationError extends EvaluationState {
  final String message;

  const EvaluationError(this.message);

  @override
  List<Object?> get props => [message];
}
