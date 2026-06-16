import 'package:equatable/equatable.dart';

abstract class ExperienceEvent extends Equatable {
  const ExperienceEvent();

  @override
  List<Object?> get props => [];
}

class FetchExperiences extends ExperienceEvent {}

class ResetExperienceState extends ExperienceEvent {}

class LoadExperiences extends ExperienceEvent {}

class CreateExperience extends ExperienceEvent {
  final String label;

  const CreateExperience({required this.label});

  @override
  List<Object?> get props => [label];
}

class UpdateExperience extends ExperienceEvent {
  final String id;
  final String label;

  const UpdateExperience({required this.id, required this.label});

  @override
  List<Object?> get props => [id, label];
}

class ActivateExperience extends ExperienceEvent {
  final String id;

  const ActivateExperience(this.id);

  @override
  List<Object?> get props => [id];
}

class DeactivateExperience extends ExperienceEvent {
  final String id;

  const DeactivateExperience(this.id);

  @override
  List<Object?> get props => [id];
}
