import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'review_model.dart';

class PropertyModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // apartment, house, condo, etc.
  final double price;
  final String pricePeriod; // daily, weekly, monthly, yearly
  final String address;
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;
  final int bedrooms;
  final int bathrooms;
  final double? area; // in square meters
  final List<String> amenities;
  final List<String> imageUrls;
  final String landlordId;
  final String landlordName;
  final String? landlordPhone;
  final String? landlordEmail;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? rating;
  final int reviewCount;
  final String? virtualTourUrl;
  final List<ReviewModel>? reviews;
  final Map<String, dynamic>? additionalInfo;

  const PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.pricePeriod,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    this.latitude,
    this.longitude,
    required this.bedrooms,
    required this.bathrooms,
    this.area,
    required this.amenities,
    required this.imageUrls,
    required this.landlordId,
    required this.landlordName,
    this.landlordPhone,
    this.landlordEmail,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.reviewCount = 0,
    this.virtualTourUrl,
    this.reviews,
    this.additionalInfo,
  });

  factory PropertyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PropertyModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      pricePeriod: data['pricePeriod'] ?? 'monthly',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      bedrooms: data['bedrooms'] ?? 0,
      bathrooms: data['bathrooms'] ?? 0,
      area: data['area']?.toDouble(),
      amenities: List<String>.from(data['amenities'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      landlordId: data['landlordId'] ?? '',
      landlordName: data['landlordName'] ?? '',
      landlordPhone: data['landlordPhone'],
      landlordEmail: data['landlordEmail'],
      isAvailable: data['isAvailable'] ?? true,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      rating: data['rating']?.toDouble(),
      reviewCount: data["reviewCount"] ?? 0,
      virtualTourUrl: data["virtualTourUrl"],
      reviews: (data["reviews"] as List<dynamic>?)?.map((e) => ReviewModel.fromJson(e)).toList(),
      additionalInfo: data["additionalInfo"],
    );
  }

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      pricePeriod: json['pricePeriod'] ?? 'monthly',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: json['area']?.toDouble(),
      amenities: List<String>.from(json['amenities'] ?? []),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      landlordId: json['landlordId'] ?? '',
      landlordName: json['landlordName'] ?? '',
      landlordPhone: json['landlordPhone'],
      landlordEmail: json['landlordEmail'],
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      rating: json['rating']?.toDouble(),
      reviewCount: json["reviewCount"] ?? 0,
      virtualTourUrl: json["virtualTourUrl"],
      reviews: (json["reviews"] as List<dynamic>?)?.map((e) => ReviewModel.fromJson(e)).toList(),
      additionalInfo: json["additionalInfo"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'price': price,
      'pricePeriod': pricePeriod,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'amenities': amenities,
      'imageUrls': imageUrls,
      'landlordId': landlordId,
      'landlordName': landlordName,
      'landlordPhone': landlordPhone,
      'landlordEmail': landlordEmail,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'rating': rating,
      "reviewCount": reviewCount,
      "virtualTourUrl": virtualTourUrl,
      "reviews": reviews?.map((e) => e.toJson()).toList(),
      "additionalInfo": additionalInfo,
    };
  }

  // Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    
    if (value is Timestamp) {
      return value.toDate();
    }
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date string: $value, error: $e');
        return DateTime.now();
      }
    }
    
    if (value is DateTime) {
      return value;
    }
    
    // Fallback for any other type
    print('Unknown date format: $value (${value.runtimeType})');
    return DateTime.now();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)} / $pricePeriod';

  PropertyModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    double? price,
    String? pricePeriod,
    String? address,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    int? bedrooms,
    int? bathrooms,
    double? area,
    List<String>? amenities,
    List<String>? imageUrls,
    String? landlordId,
    String? landlordName,
    String? landlordPhone,
    String? landlordEmail,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewCount,
    String? virtualTourUrl,
    List<ReviewModel>? reviews,
    Map<String, dynamic>? additionalInfo,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      pricePeriod: pricePeriod ?? this.pricePeriod,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      amenities: amenities ?? this.amenities,
      imageUrls: imageUrls ?? this.imageUrls,
      landlordId: landlordId ?? this.landlordId,
      landlordName: landlordName ?? this.landlordName,
      landlordPhone: landlordPhone ?? this.landlordPhone,
      landlordEmail: landlordEmail ?? this.landlordEmail,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      virtualTourUrl: virtualTourUrl ?? this.virtualTourUrl,
      reviews: reviews ?? this.reviews,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  String get fullAddress => '$address, $city, $state, $country';
  
  String get priceDisplay => '\$${price.toStringAsFixed(0)}/$pricePeriod';

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        price,
        pricePeriod,
        address,
        city,
        state,
        country,
        latitude,
        longitude,
        bedrooms,
        bathrooms,
        area,
        amenities,
        imageUrls,
        landlordId,
        landlordName,
        landlordPhone,
        landlordEmail,
        isAvailable,
        createdAt,
        updatedAt,
        rating,
        reviewCount,
        virtualTourUrl,
        reviews,
        additionalInfo,
      ];
}

