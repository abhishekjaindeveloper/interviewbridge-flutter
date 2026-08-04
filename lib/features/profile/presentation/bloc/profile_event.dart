import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class ResetProfileState extends ProfileEvent {}

class UpdateProfileRequested extends ProfileEvent {
  final String name;
  final String technologyId;
  final String experienceId;
  final String? preferredJobRole;
  final String? preferredLocation;
  final String? preferredWorkMode;
  final double? expectedSalary;
  final bool? jobAlertEnabled;

  const UpdateProfileRequested({
    required this.name,
    required this.technologyId,
    required this.experienceId,
    this.preferredJobRole,
    this.preferredLocation,
    this.preferredWorkMode,
    this.expectedSalary,
    this.jobAlertEnabled,
  });

  @override
  List<Object?> get props => [
        name,
        technologyId,
        experienceId,
        preferredJobRole,
        preferredLocation,
        preferredWorkMode,
        expectedSalary,
        jobAlertEnabled,
      ];
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
