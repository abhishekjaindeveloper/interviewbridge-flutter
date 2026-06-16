import '../../domain/entities/experience_entity.dart';

class ExperienceModel extends ExperienceEntity {
  const ExperienceModel({
    required super.id,
    required super.experienceLabel,
    super.isActive = true,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] as String? ?? '',
      experienceLabel: json['experienceLabel'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'experienceLabel': experienceLabel,
      'isActive': isActive,
    };
  }

  ExperienceEntity toEntity() {
    return ExperienceEntity(
      id: id,
      experienceLabel: experienceLabel,
      isActive: isActive,
    );
  }
}
