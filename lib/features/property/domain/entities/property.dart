import 'package:equatable/equatable.dart';

class Property extends Equatable {
  final String id;
  final String title;
  final String type;
  final String description;
  final double price;
  final String priceDisplay;
  final List<String> imageUrls;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final int bedrooms;
  final int bathrooms;
  final double? area;
  final List<String> amenities;
  final bool isAvailable;
  final String landlordId;
  final double? rating;

  const Property({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.price,
    required this.priceDisplay,
    required this.imageUrls,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    required this.bedrooms,
    required this.bathrooms,
    this.area,
    required this.amenities,
    required this.isAvailable,
    required this.landlordId,
    this.rating,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        description,
        price,
        priceDisplay,
        imageUrls,
        address,
        city,
        state,
        zipCode,
        latitude,
        longitude,
        bedrooms,
        bathrooms,
        area,
        amenities,
        isAvailable,
        landlordId,
        rating,
      ];
}
