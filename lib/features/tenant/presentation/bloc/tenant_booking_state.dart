import 'package:equatable/equatable.dart';
import 'package:rent_a_home/shared/models/booking.dart';

abstract class TenantBookingState extends Equatable {
  const TenantBookingState();

  @override
  List<Object> get props => [];
}

class TenantBookingInitial extends TenantBookingState {}

class TenantBookingLoading extends TenantBookingState {}

class TenantBookingLoaded extends TenantBookingState {
  final List<Booking> allBookings;
  final List<Booking> filteredBookings;
  final String activeFilter; // e.g., 'All', 'Pending', 'Accepted'

  const TenantBookingLoaded({
    required this.allBookings,
    required this.filteredBookings,
    this.activeFilter = 'All',
  });

  TenantBookingLoaded copyWith({
    List<Booking>? allBookings,
    List<Booking>? filteredBookings,
    String? activeFilter,
  }) {
    return TenantBookingLoaded(
      allBookings: allBookings ?? this.allBookings,
      filteredBookings: filteredBookings ?? this.filteredBookings,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object> get props => [allBookings, filteredBookings, activeFilter];
}

class TenantBookingError extends TenantBookingState {
  final String message;

  const TenantBookingError(this.message);

  @override
  List<Object> get props => [message];
}
