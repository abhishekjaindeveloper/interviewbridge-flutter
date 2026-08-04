import 'package:equatable/equatable.dart';
import '../../../technology/domain/entities/technology_entity.dart';
import '../../../experience/domain/entities/experience_entity.dart';

class ProfileEntity extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final TechnologyEntity? technology;
  final ExperienceEntity? experience;
  final String? preferredJobRole;
  final String? preferredLocation;
  final String? preferredWorkMode;
  final double? expectedSalary;
  final bool? jobAlertEnabled;
  final String? profileStatus;

  const ProfileEntity({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.technology,
    this.experience,
    this.preferredJobRole,
    this.preferredLocation,
    this.preferredWorkMode,
    this.expectedSalary,
    this.jobAlertEnabled,
    this.profileStatus,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        phoneNumber,
        role,
        technology,
        experience,
        preferredJobRole,
        preferredLocation,
        preferredWorkMode,
        expectedSalary,
        jobAlertEnabled,
        profileStatus,
      ];
}
