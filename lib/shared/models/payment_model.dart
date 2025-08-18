import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

enum PaymentType {
  rent,
  deposit,
  fee,
  refund,
}

class PaymentModel {
  final String id;
  final String bookingId;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final double amount;
  final PaymentType type;
  final PaymentStatus status;
  final String paymentMethod;
  final String? transactionId;
  final DateTime dueDate;
  final DateTime? paidDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    required this.amount,
    required this.type,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    required this.dueDate,
    this.paidDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'propertyId': propertyId,
      'tenantId': tenantId,
      'landlordId': landlordId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'dueDate': Timestamp.fromDate(dueDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      propertyId: json['propertyId'] ?? '',
      tenantId: json['tenantId'] ?? '',
      landlordId: json['landlordId'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      type: PaymentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PaymentType.rent,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: json['paymentMethod'] ?? 'card',
      transactionId: json['transactionId'],
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      paidDate: json['paidDate'] != null ? (json['paidDate'] as Timestamp).toDate() : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? propertyId,
    String? tenantId,
    String? landlordId,
    double? amount,
    PaymentType? type,
    PaymentStatus? status,
    String? paymentMethod,
    String? transactionId,
    DateTime? dueDate,
    DateTime? paidDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      propertyId: propertyId ?? this.propertyId,
      tenantId: tenantId ?? this.tenantId,
      landlordId: landlordId ?? this.landlordId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

