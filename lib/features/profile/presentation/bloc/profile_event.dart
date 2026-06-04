import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfileRequested extends ProfileEvent {
  final String name;
  final String technologyId;
  final String experienceId;

  const UpdateProfileRequested({
    required this.name,
    required this.technologyId,
    required this.experienceId,
  });

  @override
  List<Object?> get props => [name, technologyId, experienceId];
}

class SetupProfileSelection extends ProfileEvent {
  final String technologyId;
  final String experienceId;

  const SetupProfileSelection({
    required this.technologyId,
    required this.experienceId,
  });

  @override
  List<Object?> get props => [technologyId, experienceId];
}
