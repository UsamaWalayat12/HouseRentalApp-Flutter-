import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_a_home/shared/models/booking_model.dart';

class TenantBookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<BookingModel>> getBookings(BookingStatus status) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('bookings')
        .where('tenantId', isEqualTo: user.uid)
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              BookingModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> updateBooking(BookingModel booking) async {
    await _firestore
        .collection('bookings')
        .doc(booking.id)
        .update(booking.toJson());
  }

  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
