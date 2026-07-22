import 'package:equatable/equatable.dart';
import '../../domain/entities/question_entity.dart';

abstract class QuestionState extends Equatable {
  const QuestionState();

  @override
  List<Object?> get props => [];
}

class QuestionInitial extends QuestionState {}

class QuestionLoading extends QuestionState {}

class QuestionError extends QuestionState {
  final String message;

  const QuestionError(this.message);

  @override
  List<Object?> get props => [message];
}

class QuestionsLoaded extends QuestionState {
  final List<QuestionEntity> questions;
  final int currentIndex;
  final int completedQuestions;
  final int totalQuestions;
  final String? errorMessage;

  const QuestionsLoaded({
    required this.questions,
    required this.currentIndex,
    required this.completedQuestions,
    required this.totalQuestions,
    this.errorMessage,
  });

  QuestionsLoaded copyWith({
    List<QuestionEntity>? questions,
    int? currentIndex,
    int? completedQuestions,
    int? totalQuestions,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return QuestionsLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      completedQuestions: completedQuestions ?? this.completedQuestions,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [questions, currentIndex, completedQuestions, totalQuestions, errorMessage];
}

class AnswerSubmitting extends QuestionsLoaded {
  const AnswerSubmitting({
    required super.questions,
    required super.currentIndex,
    required super.completedQuestions,
    required super.totalQuestions,
    super.errorMessage,
  });
}

class AnswerSubmitted extends QuestionsLoaded {
  const AnswerSubmitted({
    required super.questions,
    required super.currentIndex,
    required super.completedQuestions,
    required super.totalQuestions,
    super.errorMessage,
  });
}

class QuestionCompleted extends QuestionsLoaded {
  const QuestionCompleted({
    required super.questions,
    required super.currentIndex,
    required super.completedQuestions,
    required super.totalQuestions,
    super.errorMessage,
  });
}
