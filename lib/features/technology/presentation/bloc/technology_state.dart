import 'package:equatable/equatable.dart';
import '../../domain/entities/technology_entity.dart';

abstract class TechnologyState extends Equatable {
  const TechnologyState();

  @override
  List<Object?> get props => [];
}

class TechnologyInitial extends TechnologyState {}

class TechnologyLoading extends TechnologyState {}

class TechnologyLoaded extends TechnologyState {
  final List<TechnologyEntity> technologies;

  const TechnologyLoaded(this.technologies);

  @override
  List<Object?> get props => [technologies];
}

class TechnologyError extends TechnologyState {
  final String message;

  const TechnologyError(this.message);

  @override
  List<Object?> get props => [message];
}

class TechnologyActionSuccess extends TechnologyState {
  final String message;

  const TechnologyActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
