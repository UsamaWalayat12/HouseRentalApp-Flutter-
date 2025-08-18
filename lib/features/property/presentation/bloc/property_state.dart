part of 'property_bloc.dart';

abstract class PropertyState extends Equatable {
  const PropertyState();

  @override
  List<Object> get props => [];
}

class PropertyInitial extends PropertyState {}

class PropertyLoading extends PropertyState {}

class PropertyLoaded extends PropertyState {
  final List<PropertyModel> properties;

  const PropertyLoaded({required this.properties});

  @override
  List<Object> get props => [properties];
}

class PropertyDetailsLoaded extends PropertyState {
  final PropertyModel property;

  const PropertyDetailsLoaded({required this.property});

  @override
  List<Object> get props => [property];
}

class PropertyAdded extends PropertyState {
  final String propertyId;

  const PropertyAdded({required this.propertyId});

  @override
  List<Object> get props => [propertyId];
}

class PropertyUpdated extends PropertyState {}

class PropertyDeleted extends PropertyState {}

class PropertyError extends PropertyState {
  final String message;

  const PropertyError({required this.message});

  @override
  List<Object> get props => [message];
}

