part of 'driver_bloc.dart';

sealed class DriverBlocState {}

final class DriverInitial extends DriverBlocState {}

class DriverStateLoading extends DriverBlocState {}

class DriverStateSuccess extends DriverBlocState {}

class DriverStateError extends DriverBlocState {
  DriverStateError(this.message);

  final String message;
}
