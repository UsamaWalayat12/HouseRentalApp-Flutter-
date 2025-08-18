import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

class Booking {
  final String? id;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final DateTime bookingDate;
  final BookingStatus status;
  final double totalAmount;
  final String? propertyTitle;
  final String? tenantName;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String? specialRequests;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    this.id,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    required this.bookingDate,
    required this.status,
    required this.totalAmount,
    this.propertyTitle,
    this.tenantName,
    required this.checkInDate,
    required this.checkOutDate,
    this.specialRequests,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'tenantId': tenantId,
      'landlordId': landlordId,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'status': status.toString().split('.').last,
      'totalAmount': totalAmount,
      'propertyTitle': propertyTitle,
      'tenantName': tenantName,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'specialRequests': specialRequests,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

    DateTime _parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      }
      if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Booking(
      id: doc.id,
      propertyId: data['propertyId'] ?? '',
      tenantId: data['tenantId'] ?? '',
      landlordId: data['landlordId'] ?? '',
      bookingDate: _parseDate(data['bookingDate']),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'pending'),
        orElse: () => BookingStatus.pending,
      ),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      propertyTitle: data['propertyTitle'],
      tenantName: data['tenantName'],
      checkInDate: _parseDate(data['checkInDate']),
      checkOutDate: _parseDate(data['checkOutDate']),
      specialRequests: data['specialRequests'],
      notes: data['notes'],
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  Booking copyWith({
    String? id,
    String? propertyId,
    String? tenantId,
    String? landlordId,
    DateTime? bookingDate,
    BookingStatus? status,
    double? totalAmount,
    String? propertyTitle,
    String? tenantName,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? specialRequests,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      tenantId: tenantId ?? this.tenantId,
      landlordId: landlordId ?? this.landlordId,
      bookingDate: bookingDate ?? this.bookingDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      tenantName: tenantName ?? this.tenantName,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      specialRequests: specialRequests ?? this.specialRequests,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convenience getters
  DateTime get checkIn => checkInDate;
  DateTime get checkOut => checkOutDate;
}
