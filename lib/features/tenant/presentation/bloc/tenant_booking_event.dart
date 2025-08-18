import 'package:equatable/equatable.dart';

abstract class TenantBookingEvent extends Equatable {
  const TenantBookingEvent();

  @override
  List<Object> get props => [];
}

class LoadTenantBookings extends TenantBookingEvent {}

class FilterBookings extends TenantBookingEvent {
  final String status;

  const FilterBookings(this.status);

  @override
  List<Object> get props => [status];
}

class CancelBooking extends TenantBookingEvent {
  final String bookingId;

  const CancelBooking(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}
