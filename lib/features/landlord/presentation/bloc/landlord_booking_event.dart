part of 'landlord_booking_bloc.dart';

abstract class LandlordBookingEvent extends Equatable {
  const LandlordBookingEvent();

  @override
  List<Object> get props => [];
}

class LoadBookings extends LandlordBookingEvent {
  final String landlordId;
  final String status;

  const LoadBookings(this.landlordId, this.status);

  @override
  List<Object> get props => [landlordId, status];
}

class UpdateBookingStatus extends LandlordBookingEvent {
  final String bookingId;
  final String status;

  const UpdateBookingStatus(this.bookingId, this.status);

  @override
  List<Object> get props => [bookingId, status];
}
