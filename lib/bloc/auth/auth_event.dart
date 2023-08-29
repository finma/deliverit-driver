part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthEventLogin extends AuthEvent {
  AuthEventLogin({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class AuthEventSaveCurrentUser extends AuthEvent {
  AuthEventSaveCurrentUser({required this.userId});

  final String userId;
}

class AuthEventRegister extends AuthEvent {
  AuthEventRegister({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  final String name;
  final String email;
  final String phoneNumber;
  final String password;
}

class AuthEventLogout extends AuthEvent {}
