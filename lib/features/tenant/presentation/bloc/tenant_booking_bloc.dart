import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rent_a_home/features/tenant/presentation/providers/booking_provider.dart';
import 'package:rent_a_home/shared/models/booking.dart';

import 'tenant_booking_event.dart';
import 'tenant_booking_state.dart';

class TenantBookingBloc extends Bloc<TenantBookingEvent, TenantBookingState> {
  final BookingProvider bookingProvider;

  TenantBookingBloc({required this.bookingProvider}) : super(TenantBookingInitial()) {
        on<LoadTenantBookings>((event, emit) async {
      emit(TenantBookingLoading());
      try {
        final bookings = await bookingProvider.getTenantBookings();
        emit(TenantBookingLoaded(
          allBookings: bookings,
          filteredBookings: bookings, // Initially, show all
          activeFilter: 'All',
        ));
      } catch (e) {
        emit(TenantBookingError(e.toString()));
      }
    });

    on<FilterBookings>((event, emit) {
      final currentState = state;
      if (currentState is TenantBookingLoaded) {
        final List<Booking> filteredList;
        if (event.status == 'All') {
          filteredList = currentState.allBookings;
        } else {
          filteredList = currentState.allBookings
              .where((booking) => booking.status == event.status)
              .toList();
        }
        emit(currentState.copyWith(
          filteredBookings: filteredList,
          activeFilter: event.status,
        ));
      }
    });

    on<CancelBooking>((event, emit) async {
      final currentState = state;
      if (currentState is TenantBookingLoaded) {
        try {
          await bookingProvider.cancelBooking(event.bookingId);
          // Update the local state to reflect the cancellation
          final updatedBookings = currentState.allBookings.map((booking) {
            if (booking.id == event.bookingId) {
              return booking.copyWith(status: BookingStatus.cancelled);
            }
            return booking;
          }).toList();

          // Re-apply the current filter
          final filteredBookings = _filterBookings(updatedBookings, currentState.activeFilter);
          emit(TenantBookingLoaded(
            allBookings: updatedBookings,
            filteredBookings: filteredBookings,
            activeFilter: currentState.activeFilter,
          ));
        } catch (e) {
          emit(TenantBookingError('Failed to cancel booking: ${e.toString()}'));
        }
      }
    });
  }

  List<Booking> _filterBookings(List<Booking> bookings, String filter) {
    if (filter == 'All') {
      return bookings;
    }
    return bookings
        .where((booking) => booking.status == filter)
        .toList();
  }
}
