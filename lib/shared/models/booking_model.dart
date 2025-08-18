import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, accepted, rejected, completed, cancelled, confirmed, checkedIn, checkedOut }

class BookingModel {
  final String? id;
  final DateTime? bookingDate;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String landlordId;
  final String propertyId;
  final String propertyTitle;
  final String? specialRequests;
  final BookingStatus status;
  final String tenantId;
  final String tenantName;
  final String? tenantEmail;
  final String? tenantPhone;
  final double totalAmount;
  final DateTime? updatedAt;
  final int guests;
  final DateTime createdAt;

  BookingModel({
    this.id,
    this.bookingDate,
    required this.checkInDate,
    required this.checkOutDate,
    required this.landlordId,
    required this.propertyId,
    required this.propertyTitle,
    this.specialRequests,
    required this.status,
    required this.tenantId,
    required this.tenantName,
    this.tenantEmail,
    this.tenantPhone,
    required this.totalAmount,
    this.updatedAt,
    this.guests = 1,
    DateTime? createdAt,
    double? depositAmount,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Helper function to parse dates that might be strings or timestamps
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      }
      return DateTime.now(); // Default value if parsing fails
    }

    return BookingModel(
       id: doc.id,
      bookingDate: data['bookingDate'] != null ? parseDate(data['bookingDate']) : null,
      checkInDate: parseDate(data['checkInDate']),
      checkOutDate: parseDate(data['checkOutDate']),
      landlordId: data['landlordId'] ?? '',
      propertyId: data['propertyId'] ?? '',
      propertyTitle: data['propertyTitle'] ?? '',
      specialRequests: data['specialRequests'] as String?,
      status: _parseStatus(data['status']),
      tenantId: data['tenantId'] ?? '',
      tenantName: data['tenantName'] ?? '',
      tenantEmail: data['tenantEmail'] as String?,
      tenantPhone: data['tenantPhone'] as String?,
      totalAmount: (data['totalAmount'] is String)
          ? double.tryParse(data['totalAmount']) ?? 0.0 
          : (data['totalAmount'] ?? 0.0).toDouble(),
      updatedAt: data['updatedAt'] != null ? parseDate(data['updatedAt']) : null,
      guests: (data['guests'] ?? 1) as int,
    );
  }

  String get guestName => '$tenantName (${guests} guests)';
  String get formattedTotalAmount => '\$$totalAmount';

  String get statusDisplay {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checkedIn:
        return 'Checked In';
      case BookingStatus.checkedOut:
        return 'Checked Out';
    }
  }

  String get dateRange => '${checkInDate.toLocal()} - ${checkOutDate.toLocal()}';

  String get statusDisplayName => statusDisplay;


  Map<String, dynamic> toFirestore() {
    return {
      'bookingDate': bookingDate != null ? Timestamp.fromDate(bookingDate!) : FieldValue.serverTimestamp(),
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'landlordId': landlordId,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'specialRequests': specialRequests,
      'status': status.toString().split('.').last,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'tenantEmail': tenantEmail,
      'tenantPhone': tenantPhone,
      'totalAmount': totalAmount,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'guests': guests,
    };
  }

  static BookingStatus _parseStatus(String? status) {
    if (status == null) return BookingStatus.pending;
    try {
      return BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == status.toLowerCase(),
        orElse: () => BookingStatus.pending,
      );
    } catch (_) {
      return BookingStatus.pending;
    }
  }

  BookingModel copyWith({
    String? id,
    DateTime? bookingDate,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? landlordId,
    String? propertyId,
    String? propertyTitle,
    String? specialRequests,
    BookingStatus? status,
    String? tenantId,
    String? tenantName,
    String? tenantEmail,
    String? tenantPhone,
    double? totalAmount,
    DateTime? updatedAt,
    int? guests,
  }) {
    return BookingModel(
      id: id ?? this.id,
      bookingDate: bookingDate ?? this.bookingDate,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      landlordId: landlordId ?? this.landlordId,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      tenantEmail: tenantEmail ?? this.tenantEmail,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      totalAmount: totalAmount ?? this.totalAmount,
      updatedAt: updatedAt ?? this.updatedAt,
      guests: guests ?? this.guests,
    );
  }
}