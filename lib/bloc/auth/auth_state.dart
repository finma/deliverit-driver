part of 'auth_bloc.dart';

abstract class AuthState {
  get user => null;
}

class AuthStateUnauthenticated extends AuthState {}

class AuthStateAuthenticated extends AuthState {
  AuthStateAuthenticated({required this.user});

  @override
  final User user;
}

class AuthStateLoading extends AuthState {}

class AuthStateError extends AuthState {
  AuthStateError(this.message);

  final String message;
}
