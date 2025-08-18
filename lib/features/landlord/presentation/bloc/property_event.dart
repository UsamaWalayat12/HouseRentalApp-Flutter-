part of 'property_bloc.dart';

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object> get props => [];
}

class AddProperty extends PropertyEvent {
  final PropertyModel property;

  const AddProperty({required this.property});

  @override
  List<Object> get props => [property];
}

class UpdateProperty extends PropertyEvent {
  final PropertyModel property;

  const UpdateProperty({required this.property});

  @override
  List<Object> get props => [property];
}

class DeleteProperty extends PropertyEvent {
  final String propertyId;

  const DeleteProperty({required this.propertyId});

  @override
  List<Object> get props => [propertyId];
} 