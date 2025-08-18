import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/property_model.dart';
import '../../shared/models/booking.dart';
import '../../shared/models/payment_model.dart';
import 'firebase_service.dart';

class DataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed sample data for a landlord to test analytics
  static Future<void> seedSampleData(String landlordId) async {
    try {
      print('Starting to seed sample data for landlord: $landlordId');

      // 1. Create sample properties
      final properties = await _createSampleProperties(landlordId);
      print('Created ${properties.length} sample properties');

      // 2. Create sample bookings
      final bookings = await _createSampleBookings(landlordId, properties);
      print('Created ${bookings.length} sample bookings');

      // 3. Create sample payments
      final payments = await _createSamplePayments(landlordId, bookings);
      print('Created ${payments.length} sample payments');

      // 4. Create sample activities
      await _createSampleActivities(landlordId);
      print('Created sample activities');

      print('✅ Sample data seeding completed successfully!');
    } catch (e) {
      print('❌ Error seeding sample data: $e');
      throw Exception('Failed to seed sample data: $e');
    }
  }

  static Future<List<String>> _createSampleProperties(String landlordId) async {
    final properties = [
      {
        'title': 'Modern Downtown Apartment',
        'description': 'Beautiful 2-bedroom apartment in the heart of downtown with city views.',
        'type': 'apartment',
        'price': 1200.0,
        'pricePeriod': 'monthly',
        'address': '123 Main Street',
        'city': 'New York',
        'state': 'NY',
        'country': 'USA',
        'bedrooms': 2,
        'bathrooms': 2,
        'area': 85.5,
        'amenities': ['WiFi', 'Air Conditioning', 'Parking', 'Gym'],
        'imageUrls': [
          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=500',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=500'
        ],
        'landlordId': landlordId,
        'landlordName': 'John Doe',
        'isAvailable': true,
        'rating': 4.5,
        'reviewCount': 12,
      },
      {
        'title': 'Cozy Suburban House',
        'description': 'Spacious 3-bedroom house with garden in quiet neighborhood.',
        'type': 'house',
        'price': 1800.0,
        'pricePeriod': 'monthly',
        'address': '456 Oak Avenue',
        'city': 'Brooklyn',
        'state': 'NY',
        'country': 'USA',
        'bedrooms': 3,
        'bathrooms': 2,
        'area': 120.0,
        'amenities': ['WiFi', 'Garden', 'Parking', 'Pet Friendly'],
        'imageUrls': [
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=500',
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=500'
        ],
        'landlordId': landlordId,
        'landlordName': 'John Doe',
        'isAvailable': true,
        'rating': 4.8,
        'reviewCount': 8,
      },
      {
        'title': 'Luxury Studio Loft',
        'description': 'High-end studio with modern amenities and great location.',
        'type': 'studio',
        'price': 900.0,
        'pricePeriod': 'monthly',
        'address': '789 Pine Street',
        'city': 'Manhattan',
        'state': 'NY',
        'country': 'USA',
        'bedrooms': 1,
        'bathrooms': 1,
        'area': 45.0,
        'amenities': ['WiFi', 'Air Conditioning', 'Concierge', 'Roof Terrace'],
        'imageUrls': [
          'https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=500',
          'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=500'
        ],
        'landlordId': landlordId,
        'landlordName': 'John Doe',
        'isAvailable': true,
        'rating': 4.2,
        'reviewCount': 15,
      },
    ];

    final List<String> propertyIds = [];
    for (final property in properties) {
      final docRef = await _firestore.collection('properties').add({
        ...property,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      propertyIds.add(docRef.id);
    }

    return propertyIds;
  }

  static Future<List<String>> _createSampleBookings(String landlordId, List<String> propertyIds) async {
    final List<String> bookingIds = [];
    final now = DateTime.now();

    // Create bookings for the past 6 months with different statuses
    for (int i = 0; i < 12; i++) {
      final propertyId = propertyIds[i % propertyIds.length];
      final checkIn = now.subtract(Duration(days: 30 * i + 10));
      final checkOut = checkIn.add(const Duration(days: 7));
      
      final BookingStatus status;
      if (i < 3) {
        status = BookingStatus.completed;
      } else if (i < 6) {
        status = BookingStatus.confirmed;
      } else if (i < 9) {
        status = BookingStatus.pending;
      } else {
        status = BookingStatus.cancelled;
      }

      final booking = {
        'propertyId': propertyId,
        'tenantId': 'tenant_${i + 1}',
        'landlordId': landlordId,
        'checkIn': Timestamp.fromDate(checkIn),
        'checkOut': Timestamp.fromDate(checkOut),
        'guests': 2 + (i % 3),
        'totalAmount': 1200.0 + (i * 100),
        'status': status.toString().split('.').last,
        'notes': 'Sample booking ${i + 1}',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('bookings').add(booking);
      bookingIds.add(docRef.id);
    }

    return bookingIds;
  }

  static Future<List<String>> _createSamplePayments(String landlordId, List<String> bookingIds) async {
    final List<String> paymentIds = [];
    final now = DateTime.now();

    for (int i = 0; i < bookingIds.length; i++) {
      final bookingId = bookingIds[i];
      final amount = 1200.0 + (i * 100);
      
      final PaymentStatus status;
      if (i < 6) {
        status = PaymentStatus.completed;
      } else if (i < 9) {
        status = PaymentStatus.pending;
      } else {
        status = PaymentStatus.failed;
      }

      final payment = {
        'bookingId': bookingId,
        'propertyId': 'property_${i % 3 + 1}',
        'tenantId': 'tenant_${i + 1}',
        'landlordId': landlordId,
        'amount': amount,
        'type': PaymentType.rent.toString().split('.').last,
        'status': status.toString().split('.').last,
        'paymentMethod': ['credit_card', 'bank_transfer', 'paypal'][i % 3],
        'dueDate': Timestamp.fromDate(now.subtract(Duration(days: 30 * i))),
        'paidDate': status == PaymentStatus.completed ? Timestamp.fromDate(now.subtract(Duration(days: 30 * i - 2))) : null,
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 30 * i + 5))),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('payments').add(payment);
      paymentIds.add(docRef.id);
    }

    return paymentIds;
  }

  static Future<void> _createSampleActivities(String landlordId) async {
    final activities = [
      {
        'landlordId': landlordId,
        'type': 'booking',
        'title': 'New Booking Received',
        'description': 'New booking received for Modern Downtown Apartment',
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'landlordId': landlordId,
        'type': 'payment',
        'title': 'Payment Completed',
        'description': 'Payment of \$1200 completed for booking #12345',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      },
      {
        'landlordId': landlordId,
        'type': 'property',
        'title': 'Property Updated',
        'description': 'Updated amenities for Cozy Suburban House',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      },
      {
        'landlordId': landlordId,
        'type': 'review',
        'title': 'New Review',
        'description': 'Received 5-star review for Luxury Studio Loft',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      },
      {
        'landlordId': landlordId,
        'type': 'booking',
        'title': 'Booking Confirmed',
        'description': 'Booking confirmed for Cozy Suburban House',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
      },
    ];

    for (final activity in activities) {
      await _firestore.collection('activities').add(activity);
    }
  }

  /// Clear all sample data for a landlord
  static Future<void> clearSampleData(String landlordId) async {
    try {
      print('Clearing sample data for landlord: $landlordId');

      // Delete properties
      final propertiesSnapshot = await _firestore
          .collection('properties')
          .where('landlordId', isEqualTo: landlordId)
          .get();
      
      for (final doc in propertiesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete bookings
      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('landlordId', isEqualTo: landlordId)
          .get();
      
      for (final doc in bookingsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete payments
      final paymentsSnapshot = await _firestore
          .collection('payments')
          .where('landlordId', isEqualTo: landlordId)
          .get();
      
      for (final doc in paymentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete activities
      final activitiesSnapshot = await _firestore
          .collection('activities')
          .where('landlordId', isEqualTo: landlordId)
          .get();
      
      for (final doc in activitiesSnapshot.docs) {
        await doc.reference.delete();
      }

      print('✅ Sample data cleared successfully!');
    } catch (e) {
      print('❌ Error clearing sample data: $e');
      throw Exception('Failed to clear sample data: $e');
    }
  }
}
