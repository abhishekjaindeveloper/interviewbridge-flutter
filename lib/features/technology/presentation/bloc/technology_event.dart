import 'package:equatable/equatable.dart';

abstract class TechnologyEvent extends Equatable {
  const TechnologyEvent();

  @override
  List<Object?> get props => [];
}

class FetchTechnologies extends TechnologyEvent {}
