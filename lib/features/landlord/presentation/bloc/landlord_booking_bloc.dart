import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rent_a_home/features/landlord/data/landlord_booking_repository.dart';
import 'package:rent_a_home/shared/models/booking_model.dart';

part 'landlord_booking_event.dart';
part 'landlord_booking_state.dart';

class LandlordBookingBloc extends Bloc<LandlordBookingEvent, LandlordBookingState> {
  final LandlordBookingRepository _bookingRepository;

  LandlordBookingBloc(this._bookingRepository) : super(LandlordBookingInitial()) {
    on<LoadBookings>(_onLoadBookings);
    on<UpdateBookingStatus>(_onUpdateBookingStatus);
  }

  void _onLoadBookings(LoadBookings event, Emitter<LandlordBookingState> emit) async {
    emit(LandlordBookingLoading());
    try {
      await emit.forEach(
        _bookingRepository.getBookings(event.landlordId, event.status),
        onData: (List<BookingModel> bookings) => LandlordBookingLoaded(bookings),
        onError: (error, stackTrace) => LandlordBookingError(error.toString()),
      );
    } catch (e) {
      emit(LandlordBookingError(e.toString()));
    }
  }

  void _onUpdateBookingStatus(UpdateBookingStatus event, Emitter<LandlordBookingState> emit) async {
    final currentState = state;
    if (currentState is LandlordBookingLoaded) {
      try {
        await _bookingRepository.updateBookingStatus(event.bookingId, event.status);
        // The stream in _onLoadBookings will automatically handle the UI update
      } catch (e) {
        emit(LandlordBookingError('Failed to update booking: ${e.toString()}'));
      }
    }
  }
}
