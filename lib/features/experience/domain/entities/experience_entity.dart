import 'package:equatable/equatable.dart';

class ExperienceEntity extends Equatable {
  final String id;
  final String experienceLabel;

  const ExperienceEntity({
    required this.id,
    required this.experienceLabel,
  });

  @override
  List<Object?> get props => [id, experienceLabel];
}
