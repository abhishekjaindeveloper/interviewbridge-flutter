import '../../domain/entities/technology_entity.dart';

class TechnologyModel extends TechnologyEntity {
  const TechnologyModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory TechnologyModel.fromJson(Map<String, dynamic> json) {
    return TechnologyModel(
      id: json['id'] as String? ?? '',
      name: json['technologyName'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'technologyName': name,
      'description': description,
    };
  }

  TechnologyEntity toEntity() {
    return TechnologyEntity(
      id: id,
      name: name,
      description: description,
    );
  }
}
