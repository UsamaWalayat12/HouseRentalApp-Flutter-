import '../../shared/models/property_model.dart';
import 'firebase_service.dart';

class PropertyService {
  // Add a new property
  static Future<String> addProperty(PropertyModel property) async {
    try {
      return await FirebaseService.addProperty(property);
    } catch (e) {
      throw Exception('Failed to add property: ${e.toString()}');
    }
  }

  // Update an existing property
  static Future<void> updateProperty(PropertyModel property) async {
    try {
      await FirebaseService.updateProperty(property);
    } catch (e) {
      throw Exception('Failed to update property: ${e.toString()}');
    }
  }

  // Delete a property
  static Future<void> deleteProperty(String propertyId) async {
    try {
      await FirebaseService.deleteProperty(propertyId);
    } catch (e) {
      throw Exception('Failed to delete property: ${e.toString()}');
    }
  }

  // Get a single property by ID
  static Future<PropertyModel?> getProperty(String propertyId) async {
    try {
      return await FirebaseService.getProperty(propertyId);
    } catch (e) {
      throw Exception('Failed to get property: ${e.toString()}');
    }
  }

  // Get all available properties (stream)
  static Stream<List<PropertyModel>> getProperties() {
    return FirebaseService.getProperties();
  }

  // Get properties by landlord (stream)
  static Stream<List<PropertyModel>> getPropertiesByLandlord(String landlordId) {
    return FirebaseService.getPropertiesByLandlord(landlordId);
  }

  // Search properties with filters
  static Future<List<PropertyModel>> searchProperties({
    String? query,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    String? city,
  }) async {
    try {
      return await FirebaseService.searchProperties(
        query: query,
        propertyType: propertyType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        city: city,
      );
    } catch (e) {
      throw Exception('Failed to search properties: ${e.toString()}');
    }
  }

  // Get featured properties (top rated)
  static Future<List<PropertyModel>> getFeaturedProperties({int limit = 10}) async {
    try {
      final properties = await FirebaseService.searchProperties();
      // Sort by rating and return top properties
      properties.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      return properties.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get featured properties: ${e.toString()}');
    }
  }

  // Get properties by city
  static Future<List<PropertyModel>> getPropertiesByCity(String city) async {
    try {
      return await FirebaseService.searchProperties(city: city);
    } catch (e) {
      throw Exception('Failed to get properties by city: ${e.toString()}');
    }
  }

  // Get properties by type
  static Future<List<PropertyModel>> getPropertiesByType(String type) async {
    try {
      return await FirebaseService.searchProperties(propertyType: type);
    } catch (e) {
      throw Exception('Failed to get properties by type: ${e.toString()}');
    }
  }

  // Get properties in price range
  static Future<List<PropertyModel>> getPropertiesInPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      return await FirebaseService.searchProperties(
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
    } catch (e) {
      throw Exception('Failed to get properties in price range: ${e.toString()}');
    }
  }

  // Update property availability
  static Future<void> updatePropertyAvailability(
    String propertyId,
    bool isAvailable,
  ) async {
    try {
      final property = await FirebaseService.getProperty(propertyId);
      if (property != null) {
        final updatedProperty = property.copyWith(isAvailable: isAvailable);
        await FirebaseService.updateProperty(updatedProperty);
      }
    } catch (e) {
      throw Exception('Failed to update property availability: ${e.toString()}');
    }
  }

  // Update property rating (called after new review)
  static Future<void> updatePropertyRating(String propertyId) async {
    try {
      await FirebaseService.updatePropertyRating(propertyId);
    } catch (e) {
      throw Exception('Failed to update property rating: ${e.toString()}');
    }
  }
}

