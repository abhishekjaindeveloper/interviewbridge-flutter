import '../../domain/entities/technology_entity.dart';

class TechnologyModel extends TechnologyEntity {
  const TechnologyModel({
    required super.id,
    required super.name,
    required super.description,
    super.isActive = true,
  });

  factory TechnologyModel.fromJson(Map<String, dynamic> json) {
    return TechnologyModel(
      id: json['id'] as String? ?? '',
      name: json['technologyName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'technologyName': name,
      'description': description,
      'isActive': isActive,
    };
  }

  TechnologyEntity toEntity() {
    return TechnologyEntity(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
    );
  }
}
