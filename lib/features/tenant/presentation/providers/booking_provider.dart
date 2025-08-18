import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_a_home/shared/models/booking.dart';

class BookingProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .update({'status': 'Cancelled'});
    } catch (e) {
      rethrow;
    }
  }


  Future<List<Booking>> getTenantBookings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final snapshot = await _firestore
          .collection('bookings')
          .where('tenantId', isEqualTo: user.uid)
          .get();

      return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
