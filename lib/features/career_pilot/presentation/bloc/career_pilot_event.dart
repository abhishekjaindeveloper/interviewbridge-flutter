import 'package:equatable/equatable.dart';

abstract class CareerPilotEvent extends Equatable {
  const CareerPilotEvent();

  @override
  List<Object?> get props => [];
}

class FetchMatchedJobsRequested extends CareerPilotEvent {
  const FetchMatchedJobsRequested();
}

class FetchJobDetailsRequested extends CareerPilotEvent {
  final String jobId;

  const FetchJobDetailsRequested(this.jobId);

  @override
  List<Object?> get props => [jobId];
}
