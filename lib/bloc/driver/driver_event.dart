part of 'driver_bloc.dart';

sealed class DriverEvent {}

final class DriverEventSetEarnings extends DriverEvent {
  DriverEventSetEarnings({
    required this.userId,
    required this.rideRequestId,
    required this.earnings,
  });

  final String userId;
  final String rideRequestId;
  final double earnings;
}
