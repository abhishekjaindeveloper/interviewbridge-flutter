import 'package:equatable/equatable.dart';

abstract class TechnologyEvent extends Equatable {
  const TechnologyEvent();

  @override
  List<Object?> get props => [];
}

class FetchTechnologies extends TechnologyEvent {}

class ResetTechnologyState extends TechnologyEvent {}

class LoadTechnologies extends TechnologyEvent {}

class CreateTechnology extends TechnologyEvent {
  final String name;
  final String description;

  const CreateTechnology({required this.name, required this.description});

  @override
  List<Object?> get props => [name, description];
}

class UpdateTechnology extends TechnologyEvent {
  final String id;
  final String name;
  final String description;

  const UpdateTechnology({required this.id, required this.name, required this.description});

  @override
  List<Object?> get props => [id, name, description];
}

class ActivateTechnology extends TechnologyEvent {
  final String id;

  const ActivateTechnology(this.id);

  @override
  List<Object?> get props => [id];
}

class DeactivateTechnology extends TechnologyEvent {
  final String id;

  const DeactivateTechnology(this.id);

  @override
  List<Object?> get props => [id];
}
