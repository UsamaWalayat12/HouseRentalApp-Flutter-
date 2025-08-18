part of 'landlord_booking_bloc.dart';

abstract class LandlordBookingState extends Equatable {
  const LandlordBookingState();

  @override
  List<Object> get props => [];
}

class LandlordBookingInitial extends LandlordBookingState {}

class LandlordBookingLoading extends LandlordBookingState {}

class LandlordBookingLoaded extends LandlordBookingState {
  final List<BookingModel> bookings;

  const LandlordBookingLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}

class LandlordBookingError extends LandlordBookingState {
  final String message;

  const LandlordBookingError(this.message);

  @override
  List<Object> get props => [message];
}
