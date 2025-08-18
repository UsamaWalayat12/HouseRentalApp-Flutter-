import '../../shared/models/booking.dart';
import 'firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  // Create a new booking
  static Future<String> createBooking(Booking booking) async {
    try {
      return await FirebaseService.createBooking(booking);
    } catch (e) {
      throw Exception('Failed to create booking: ${e.toString()}');
    }
  }

  // Update an existing booking
  static Future<void> updateBooking(Booking booking) async {
    try {
      await FirebaseService.updateBooking(booking);
    } catch (e) {
      throw Exception('Failed to update booking: ${e.toString()}');
    }
  }

  // Get a single booking by ID
  static Future<Booking?> getBooking(String bookingId) async {
    try {
      return await FirebaseService.getBooking(bookingId);
    } catch (e) {
      throw Exception('Failed to get booking: ${e.toString()}');
    }
  }

  // Get bookings by tenant (stream)
  static Stream<List<Booking>> getBookingsByTenant(String tenantId) {
    return FirebaseService.getBookingsByTenant(tenantId);
  }

  // Get bookings by landlord (stream)
  static Stream<List<Booking>> getBookingsByLandlord(String landlordId) {
    return FirebaseService.getBookingsByLandlord(landlordId);
  }

  // Get bookings by property (stream)
  static Stream<List<Booking>> getBookingsByProperty(String propertyId) {
    return FirebaseService.getBookingsByProperty(propertyId);
  }

  // Update booking status
  static Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      final booking = await FirebaseService.getBooking(bookingId);
      if (booking != null) {
        final updatedBooking = booking.copyWith(status: status);
        await FirebaseService.updateBooking(updatedBooking);
      }
    } catch (e) {
      throw Exception('Failed to update booking status: ${e.toString()}');
    }
  }

  // Accept booking (landlord action)
  static Future<void> acceptBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId, BookingStatus.confirmed);
    } catch (e) {
      throw Exception('Failed to accept booking: ${e.toString()}');
    }
  }

  // Reject booking (landlord action)
  static Future<void> rejectBooking(String bookingId, String reason) async {
    try {
      final booking = await FirebaseService.getBooking(bookingId);
      if (booking != null) {
        final updatedBooking = booking.copyWith(
          status: BookingStatus.cancelled,
          notes: reason,
        );
        await FirebaseService.updateBooking(updatedBooking);
      }
    } catch (e) {
      throw Exception('Failed to reject booking: ${e.toString()}');
    }
  }

  // Cancel booking (tenant action)
  static Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      final booking = await FirebaseService.getBooking(bookingId);
      if (booking != null) {
        final updatedBooking = booking.copyWith(
          status: BookingStatus.cancelled,
          notes: reason,
        );
        await FirebaseService.updateBooking(updatedBooking);
      }
    } catch (e) {
      throw Exception('Failed to cancel booking: ${e.toString()}');
    }
  }

  // Complete booking (when stay is finished)
  static Future<void> completeBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId, BookingStatus.completed);
    } catch (e) {
      throw Exception('Failed to complete booking: ${e.toString()}');
    }
  }

  // Check if dates are available for a property
  static Future<bool> checkAvailability(
    String propertyId,
    DateTime checkIn,
    DateTime checkOut,
  ) async {
    try {
      final bookingsStream = FirebaseService.getBookingsByProperty(propertyId);
      final bookings = await bookingsStream.first;
      
      // Check for overlapping bookings
      for (final booking in bookings) {
        if (booking.status == BookingStatus.confirmed ||
            booking.status == BookingStatus.pending) {
          // Check if dates overlap
          if (checkIn.isBefore(booking.checkOut) && checkOut.isAfter(booking.checkIn)) {
            return false; // Dates overlap, not available
          }
        }
      }
      
      return true; // No overlapping bookings found
    } catch (e) {
      throw Exception('Failed to check availability: ${e.toString()}');
    }
  }

  // Get booking statistics for landlord
  static Future<Map<String, dynamic>> getBookingStatistics(String landlordId) async {
    try {
      final bookingsStream = FirebaseService.getBookingsByLandlord(landlordId);
      final bookings = await bookingsStream.first;
      
      int totalBookings = bookings.length;
      int confirmedBookings = bookings.where((b) => b.status == BookingStatus.confirmed).length;
      int pendingBookings = bookings.where((b) => b.status == BookingStatus.pending).length;
      int cancelledBookings = bookings.where((b) => b.status == BookingStatus.cancelled).length;
      int completedBookings = bookings.where((b) => b.status == BookingStatus.completed).length;
      
      double totalRevenue = 0;
      for (final booking in bookings) {
        if (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.completed) {
          totalRevenue += booking.totalAmount;
        }
      }
      
      return {
        'totalBookings': totalBookings,
        'confirmedBookings': confirmedBookings,
        'pendingBookings': pendingBookings,
        'cancelledBookings': cancelledBookings,
        'completedBookings': completedBookings,
        'totalRevenue': totalRevenue,
        'averageBookingValue': totalBookings > 0 ? totalRevenue / totalBookings : 0,
      };
    } catch (e) {
      throw Exception('Failed to get booking statistics: ${e.toString()}');
    }
  }

  // Get upcoming bookings for tenant
  static Future<List<Booking>> getUpcomingBookings(String tenantId) async {
    try {
      final bookingsStream = FirebaseService.getBookingsByTenant(tenantId);
      final bookings = await bookingsStream.first;
      
      final now = DateTime.now();
      return bookings.where((booking) {
        return booking.checkIn.isAfter(now) && 
               (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending);
      }).toList()..sort((a, b) => a.checkIn.compareTo(b.checkIn));
    } catch (e) {
      throw Exception('Failed to get upcoming bookings: ${e.toString()}');
    }
  }

  // Get current bookings for tenant
  static Future<List<Booking>> getCurrentBookings(String tenantId) async {
    try {
      final bookingsStream = FirebaseService.getBookingsByTenant(tenantId);
      final bookings = await bookingsStream.first;
      
      final now = DateTime.now();
      return bookings.where((booking) {
        return booking.checkIn.isBefore(now) && 
               booking.checkOut.isAfter(now) && 
               booking.status == BookingStatus.confirmed;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get current bookings: ${e.toString()}');
    }
  }

  // Get booking history for tenant
  static Future<List<Booking>> getBookingHistory(String tenantId) async {
    try {
      final bookingsStream = FirebaseService.getBookingsByTenant(tenantId);
      final bookings = await bookingsStream.first;
      
      final now = DateTime.now();
      return bookings.where((booking) {
        return booking.checkOut.isBefore(now) && 
               booking.status == BookingStatus.completed;
      }).toList()..sort((a, b) => b.checkOut.compareTo(a.checkOut));
    } catch (e) {
      throw Exception('Failed to get booking history: ${e.toString()}');
    }
  }
}

