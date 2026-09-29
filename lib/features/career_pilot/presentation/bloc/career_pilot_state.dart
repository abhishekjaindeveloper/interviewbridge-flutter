import 'package:equatable/equatable.dart';
import '../../domain/entities/matched_job_entity.dart';

abstract class CareerPilotState extends Equatable {
  const CareerPilotState();

  @override
  List<Object?> get props => [];
}

class CareerPilotInitial extends CareerPilotState {}

class CareerPilotLoading extends CareerPilotState {}

class CareerPilotJobsLoaded extends CareerPilotState {
  final List<MatchedJobEntity> jobs;

  const CareerPilotJobsLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class CareerPilotJobsEmpty extends CareerPilotState {}

class CareerPilotError extends CareerPilotState {
  final String message;

  const CareerPilotError(this.message);

  @override
  List<Object?> get props => [message];
}

class JobDetailsLoading extends CareerPilotState {}

class JobDetailsLoaded extends CareerPilotState {
  final MatchedJobEntity job;

  const JobDetailsLoaded(this.job);

  @override
  List<Object?> get props => [job];
}

class JobDetailsError extends CareerPilotState {
  final String message;

  const JobDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
