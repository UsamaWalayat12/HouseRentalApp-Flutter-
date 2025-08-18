import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

enum UserRole {
  tenant,
  landlord,
  admin,
}

enum VerificationStatus {
  unverified,
  pending,
  verified,
  rejected,
}

class UserModel extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profileImageUrl;
  final String? bio;
  final String role;
  final VerificationStatus verificationStatus;
  final double? rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? profile;
  final bool bookingConfirmations;
  final bool newMessages;
  final bool promotionalOffers;

  UserModel({
    required this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.phone,
    this.profileImageUrl,
    this.bio,
    required this.role,
    this.verificationStatus = VerificationStatus.unverified,
    this.rating,
    this.reviewCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.profile,
    this.bookingConfirmations = true,
    this.newMessages = true,
    this.promotionalOffers = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static UserModel get empty => UserModel(id: '', email: '', role: 'tenant');

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'],
      profileImageUrl: data['profileImageUrl'],
      bio: data['bio'],
      role: data['role'] ?? 'tenant',
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == data['verificationStatus'],
        orElse: () => VerificationStatus.unverified,
      ),
      rating: (data['rating'] as num?)?.toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
      profile: data['profile'] is Map ? Map<String, dynamic>.from(data['profile']) : null,
      bookingConfirmations: data['bookingConfirmations'] ?? true,
      newMessages: data['newMessages'] ?? true,
      promotionalOffers: data['promotionalOffers'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'role': role,
      'verificationStatus': verificationStatus.name,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'profile': profile,
      'bookingConfirmations': bookingConfirmations,
      'newMessages': newMessages,
      'promotionalOffers': promotionalOffers,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromMap(json, json['id'] as String);
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImageUrl,
    String? bio,
    String? role,
    VerificationStatus? verificationStatus,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? profile,
    bool? bookingConfirmations,
    bool? newMessages,
    bool? promotionalOffers,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
      bookingConfirmations: bookingConfirmations ?? this.bookingConfirmations,
      newMessages: newMessages ?? this.newMessages,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
    );
  }

  String get tenantName => fullName;

  String get propertyTitle => 'Default Property Title';

  String get dateRange => DateFormat('MMM dd, yyyy').format(createdAt) + ' - ' + DateFormat('MMM dd, yyyy').format(updatedAt);

  String get tenantId => id;

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    if (firstName.isEmpty && lastName.isEmpty) return '';
    if (firstName.isEmpty) return lastName[0].toUpperCase();
    if (lastName.isEmpty) return firstName[0].toUpperCase();
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  String get roleDisplayName {
    switch (role) {
      case 'tenant':
        return 'Tenant';
      case 'landlord':
        return 'Landlord';
      case 'admin':
        return 'Administrator';
      default:
        return role;
    }
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phone,
        profileImageUrl,
        bio,
        role,
        verificationStatus,
        rating,
        reviewCount,
        createdAt,
        updatedAt,
        profile,
        bookingConfirmations,
        newMessages,
        promotionalOffers,
      ];
}

