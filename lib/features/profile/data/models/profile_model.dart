import '../../domain/entities/profile_entity.dart';
import '../../../technology/data/models/technology_model.dart';
import '../../../experience/data/models/experience_model.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.role,
    super.technology,
    super.experience,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      technology: json['technology'] != null
          ? TechnologyModel.fromJson(json['technology'] as Map<String, dynamic>)
          : null,
      experience: json['experience'] != null
          ? ExperienceModel.fromJson(json['experience'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'technology': technology != null ? (technology as TechnologyModel).toJson() : null,
      'experience': experience != null ? (experience as ExperienceModel).toJson() : null,
    };
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: userId,
      name: name,
      email: email,
      role: role,
      technology: technology,
      experience: experience,
    );
  }
}
