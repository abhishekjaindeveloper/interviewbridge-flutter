import 'package:equatable/equatable.dart';
import '../../domain/entities/practice_session_entity.dart';

abstract class PracticeSessionState extends Equatable {
  const PracticeSessionState();

  @override
  List<Object?> get props => [];
}

class PracticeSessionInitial extends PracticeSessionState {}

class PracticeSessionLoading extends PracticeSessionState {}

class PracticeSessionsLoaded extends PracticeSessionState {
  final List<PracticeSessionEntity> sessions;

  const PracticeSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class PracticeSessionsEmpty extends PracticeSessionState {}

class PracticeSessionDetailsLoaded extends PracticeSessionState {
  final PracticeSessionEntity session;

  const PracticeSessionDetailsLoaded(this.session);

  @override
  List<Object?> get props => [session];
}

class PracticeSessionCreated extends PracticeSessionState {
  final PracticeSessionEntity session;

  const PracticeSessionCreated(this.session);

  @override
  List<Object?> get props => [session];
}

class PracticeQuestionsGenerated extends PracticeSessionState {
  final PracticeSessionEntity session;

  const PracticeQuestionsGenerated(this.session);

  @override
  List<Object?> get props => [session];
}

class PracticeSessionError extends PracticeSessionState {
  final String message;

  const PracticeSessionError(this.message);

  @override
  List<Object?> get props => [message];
}
