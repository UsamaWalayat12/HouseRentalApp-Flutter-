import 'package:cloud_firestore/cloud_firestore.dart';

class TourModel {
  final String id;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final DateTime tourDateTime;
  final String status; // e.g., 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;

  TourModel({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    required this.tourDateTime,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'tenantId': tenantId,
      'landlordId': landlordId,
      'tourDateTime': Timestamp.fromDate(tourDateTime),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      id: json['id'] ?? '',
      propertyId: json['propertyId'],
      tenantId: json['tenantId'],
      landlordId: json['landlordId'],
      tourDateTime: (json['tourDateTime'] as Timestamp).toDate(),
      status: json['status'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}
