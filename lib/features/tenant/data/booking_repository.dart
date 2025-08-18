import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rent_a_home/shared/models/booking.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(FirebaseFirestore.instance);
});

class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository(this._firestore);

  Future<void> createBooking(Booking booking) async {
    try {
      // Convert the booking to JSON and ensure status is stored as a string
      final bookingData = booking.toJson();
      // Make sure status is stored as the enum value name
      bookingData['status'] = booking.status.toString().split('.').last;
      
      await _firestore.collection('bookings').add(bookingData);
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> updateBooking(Booking booking) async {
    try {
      // Convert the booking to JSON and ensure status is stored as a string
      final bookingData = booking.toJson();
      // Make sure status is stored as the enum value name
      bookingData['status'] = booking.status.toString().split('.').last;
      
      await _firestore.collection('bookings').doc(booking.id).update(bookingData);
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<Booking?> getExistingBooking(String propertyId, String tenantId) async {
    try {
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('propertyId', isEqualTo: propertyId)
          .where('tenantId', isEqualTo: tenantId)
          .where('status', whereIn: ['Pending', 'Accepted'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Booking.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
