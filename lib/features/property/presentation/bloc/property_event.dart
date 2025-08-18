part of 'property_bloc.dart';

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

class LoadProperties extends PropertyEvent {
  const LoadProperties();
}

class SearchProperties extends PropertyEvent {
  final String? query;
  final String? propertyType;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final int? bathrooms;
  final String? city;

  const SearchProperties({
    this.query,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.bathrooms,
    this.city,
  });

  @override
  List<Object?> get props => [
        query,
        propertyType,
        minPrice,
        maxPrice,
        bedrooms,
        bathrooms,
        city,
      ];
}

class LoadPropertyDetails extends PropertyEvent {
  final String propertyId;

  const LoadPropertyDetails({required this.propertyId});

  @override
  List<Object> get props => [propertyId];
}

class LoadPropertiesByLandlord extends PropertyEvent {
  final String landlordId;

  const LoadPropertiesByLandlord({required this.landlordId});

  @override
  List<Object> get props => [landlordId];
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

  const DeleteProperty(this.propertyId);

  @override
  List<Object> get props => [propertyId];
}

class TogglePropertyAvailability extends PropertyEvent {
  final String propertyId;
  final bool isAvailable;

  const TogglePropertyAvailability({required this.propertyId, required this.isAvailable});

  @override
  List<Object> get props => [propertyId, isAvailable];
}
