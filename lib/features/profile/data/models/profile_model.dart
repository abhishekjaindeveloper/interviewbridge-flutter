import '../../domain/entities/profile_entity.dart';
import '../../../technology/data/models/technology_model.dart';
import '../../../experience/data/models/experience_model.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.role,
    super.technology,
    super.experience,
    super.preferredJobRole,
    super.preferredLocation,
    super.preferredWorkMode,
    super.expectedSalary,
    super.jobAlertEnabled,
    super.profileStatus,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? '',
      technology: json['technology'] != null
          ? TechnologyModel.fromJson(json['technology'] as Map<String, dynamic>)
          : null,
      experience: json['experience'] != null
          ? ExperienceModel.fromJson(json['experience'] as Map<String, dynamic>)
          : null,
      preferredJobRole: json['preferredJobRole'] as String?,
      preferredLocation: json['preferredLocation'] as String?,
      preferredWorkMode: json['preferredWorkMode'] as String?,
      expectedSalary: (json['expectedSalary'] as num?)?.toDouble(),
      jobAlertEnabled: json['jobAlertEnabled'] as bool?,
      profileStatus: json['profileStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'technology': technology != null ? (technology as TechnologyModel).toJson() : null,
      'experience': experience != null ? (experience as ExperienceModel).toJson() : null,
      'preferredJobRole': preferredJobRole,
      'preferredLocation': preferredLocation,
      'preferredWorkMode': preferredWorkMode,
      'expectedSalary': expectedSalary,
      'jobAlertEnabled': jobAlertEnabled,
      'profileStatus': profileStatus,
    };
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: userId,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      technology: technology,
      experience: experience,
      preferredJobRole: preferredJobRole,
      preferredLocation: preferredLocation,
      preferredWorkMode: preferredWorkMode,
      expectedSalary: expectedSalary,
      jobAlertEnabled: jobAlertEnabled,
      profileStatus: profileStatus,
    );
  }
}
