import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_a_home/shared/models/booking_model.dart';

class LandlordBookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<BookingModel>> getBookings(String landlordId, String status) {
    print('Repository: Getting bookings for landlord: $landlordId with status: $status');

    try {
      final query = _firestore
        .collection('bookings')
          .where('landlordId', isEqualTo: landlordId);
      
      print('Repository: Created base query');

      // Only add status filter if it's not empty
      final finalQuery = status.isNotEmpty
          ? query.where('status', isEqualTo: status.toLowerCase())
          : query;

      print('Repository: Final query created with status filter: ${status.isNotEmpty}');

      return finalQuery
          .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) {
            print('Repository: Received ${snapshot.docs.length} documents');
            
            final bookings = snapshot.docs.map((doc) {
              try {
                print('Repository: Processing document ${doc.id}');
                print('Repository: Document data: ${doc.data()}');
                return BookingModel.fromFirestore(doc);
              } catch (e) {
                print('Repository: Error parsing document ${doc.id}: $e');
                rethrow;
              }
            }).toList();

            print('Repository: Successfully parsed ${bookings.length} bookings');
            return bookings;
          });
    } catch (e) {
      print('Repository: Error in getBookings: $e');
      rethrow;
    }
  }

    Future<void> updateBookingStatus(String bookingId, String status) async {
    print('Repository: Updating booking $bookingId to status: $status');

    try {
    await _firestore.collection('bookings').doc(bookingId).update({
        'status': status.toLowerCase(),
        'updatedAt': FieldValue.serverTimestamp(),
    });
      print('Repository: Successfully updated booking status');
    } catch (e) {
      print('Repository: Error updating booking status: $e');
      throw Exception('Failed to update booking status: $e');
    }
  }
}
