import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/models/property_model.dart';
import '../../../../core/services/property_service.dart';

part 'property_event.dart';
part 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  PropertyBloc() : super(PropertyInitial()) {
    on<LoadProperties>(_onLoadProperties);
    on<SearchProperties>(_onSearchProperties);
    on<LoadPropertyDetails>(_onLoadPropertyDetails);
    on<LoadPropertiesByLandlord>(_onLoadPropertiesByLandlord);
    on<AddProperty>(_onAddProperty);
    on<UpdateProperty>(_onUpdateProperty);
    on<DeleteProperty>(_onDeleteProperty);
    on<TogglePropertyAvailability>(_onTogglePropertyAvailability);
  }

  void _onLoadProperties(LoadProperties event, Emitter<PropertyState> emit) async {
    emit(PropertyLoading());
    try {
      await emit.forEach(
        PropertyService.getProperties(),
        onData: (List<PropertyModel> properties) => PropertyLoaded(properties: properties),
        onError: (error, stackTrace) => PropertyError(message: error.toString()),
      );
    } catch (e) {
      emit(PropertyError(message: 'Failed to load properties: ${e.toString()}'));
    }
  }

  void _onSearchProperties(SearchProperties event, Emitter<PropertyState> emit) async {
    emit(PropertyLoading());
    try {
      final properties = await PropertyService.searchProperties(
        query: event.query,
        propertyType: event.propertyType,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        bedrooms: event.bedrooms,
        bathrooms: event.bathrooms,
        city: event.city,
      );
      emit(PropertyLoaded(properties: properties));
    } catch (e) {
      emit(PropertyError(message: 'Failed to search properties: ${e.toString()}'));
    }
  }

  void _onLoadPropertyDetails(LoadPropertyDetails event, Emitter<PropertyState> emit) async {
    emit(PropertyLoading());
    try {
      final property = await PropertyService.getProperty(event.propertyId);
      if (property != null) {
        emit(PropertyDetailsLoaded(property: property));
      } else {
        emit(PropertyError(message: 'Property not found'));
      }
    } catch (e) {
      emit(PropertyError(message: 'Failed to load property details: ${e.toString()}'));
    }
  }

  void _onLoadPropertiesByLandlord(LoadPropertiesByLandlord event, Emitter<PropertyState> emit) async {
    emit(PropertyLoading());
    try {
      await emit.forEach(
        PropertyService.getPropertiesByLandlord(event.landlordId),
        onData: (List<PropertyModel> properties) => PropertyLoaded(properties: properties),
        onError: (error, stackTrace) => PropertyError(message: error.toString()),
      );
    } catch (e) {
      emit(PropertyError(message: 'Failed to load landlord properties: ${e.toString()}'));
    }
  }

  void _onAddProperty(AddProperty event, Emitter<PropertyState> emit) async {
    emit(PropertyLoading());
    try {
      final propertyId = await PropertyService.addProperty(event.property);
      emit(PropertyAdded(propertyId: propertyId));
    } catch (e) {
      emit(PropertyError(message: 'Failed to add property: ${e.toString()}'));
    }
  }

  void _onUpdateProperty(UpdateProperty event, Emitter<PropertyState> emit) async {
    final currentState = state;
    emit(PropertyLoading());
    try {
      await PropertyService.updateProperty(event.property);
      
      // Update the local state if we have PropertyLoaded state
      if (currentState is PropertyLoaded) {
        final properties = List<PropertyModel>.from(currentState.properties);
        final propertyIndex = properties.indexWhere((p) => p.id == event.property.id);
        
        if (propertyIndex != -1) {
          properties[propertyIndex] = event.property;
          emit(PropertyLoaded(properties: properties));
        } else {
          emit(PropertyLoaded(properties: properties));
        }
      }
      
      // Also emit PropertyUpdated for the UI to show success message and navigate back
      emit(PropertyUpdated());
    } catch (e) {
      // If update fails, restore the previous state
      if (currentState is PropertyLoaded) {
        emit(currentState);
      }
      emit(PropertyError(message: 'Failed to update property: ${e.toString()}'));
    }
  }

  void _onDeleteProperty(DeleteProperty event, Emitter<PropertyState> emit) async {
    final currentState = state;
    if (currentState is PropertyLoaded) {
      try {
        await PropertyService.deleteProperty(event.propertyId);
        // Optimistically update the UI by removing the deleted property from the list.
        final updatedProperties = currentState.properties
            .where((property) => property.id != event.propertyId)
            .toList();
        emit(PropertyLoaded(properties: updatedProperties));
        // The stream from `LoadProperties` will eventually emit the new state from Firestore,
        // ensuring consistency.
      } catch (e) {
        emit(PropertyError(message: 'Failed to delete property: ${e.toString()}'));
        // If the deletion fails, revert to the original state to maintain UI consistency.
        emit(currentState);
      }
    }
  }

  void _onTogglePropertyAvailability(
    TogglePropertyAvailability event,
    Emitter<PropertyState> emit,
  ) async {
    final currentState = state;
    if (currentState is PropertyLoaded) {
      final properties = List<PropertyModel>.from(currentState.properties);
      final propertyIndex = properties.indexWhere((p) => p.id == event.propertyId);

      if (propertyIndex != -1) {
        final originalProperty = properties[propertyIndex];
        final updatedProperty = originalProperty.copyWith(isAvailable: event.isAvailable);

        properties[propertyIndex] = updatedProperty;

        // Optimistically update the UI
        emit(PropertyLoaded(properties: properties));

        try {
          await PropertyService.updatePropertyAvailability(
            event.propertyId,
            event.isAvailable,
          );
          // If successful, the state is already correct.
        } catch (e) {
          // If the update fails, revert the change and emit an error.
          properties[propertyIndex] = originalProperty; // Revert
          emit(PropertyError(message: 'Failed to update availability: ${e.toString()}'));
          emit(PropertyLoaded(properties: properties)); // Emit the reverted list
        }
      }
    }
  }
}
