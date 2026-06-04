import 'package:equatable/equatable.dart';

abstract class ExperienceEvent extends Equatable {
  const ExperienceEvent();

  @override
  List<Object?> get props => [];
}

class FetchExperiences extends ExperienceEvent {}
