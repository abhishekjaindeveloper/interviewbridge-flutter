import '../../domain/entities/experience_entity.dart';

class ExperienceModel extends ExperienceEntity {
  const ExperienceModel({
    required super.id,
    required super.experienceLabel,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] as String? ?? '',
      experienceLabel: json['experienceLabel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'experienceLabel': experienceLabel,
    };
  }

  ExperienceEntity toEntity() {
    return ExperienceEntity(
      id: id,
      experienceLabel: experienceLabel,
    );
  }
}
