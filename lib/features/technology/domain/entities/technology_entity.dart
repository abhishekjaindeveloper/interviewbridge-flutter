import 'package:equatable/equatable.dart';

class TechnologyEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool isActive;

  const TechnologyEntity({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, description, isActive];
}
