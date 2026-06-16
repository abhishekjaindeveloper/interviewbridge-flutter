import 'package:equatable/equatable.dart';

class ExperienceEntity extends Equatable {
  final String id;
  final String experienceLabel;
  final bool isActive;

  const ExperienceEntity({
    required this.id,
    required this.experienceLabel,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, experienceLabel, isActive];
}
