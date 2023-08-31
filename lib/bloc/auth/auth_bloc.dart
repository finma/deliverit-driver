import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/config/firebase.dart';
import '/models/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  FirebaseAuth auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthStateUnauthenticated()) {
    on<AuthEventLogin>(_authEventLogin);

    on<AuthEventRegister>(_authEventRegister);

    on<AuthEventSaveCurrentUser>(_authEventSaveCurrentUser);

    on<AuthEventLogout>(_authEventLogout);
  }

  void _authEventLogin(AuthEventLogin event, Emitter<AuthState> emit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      emit(AuthStateLoading());

      final UserCredential response = await auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // print('response: ${response.user}');

      if (response.user != null) {
        final DatabaseEvent user =
            await driverRef.child(response.user!.uid).once();

        // print('user: ${user.snapshot.key}');

        if (user.snapshot.value != null) {
          prefs.setString('userId', user.snapshot.key!);
          emit(AuthStateAuthenticated(user: User.fromSnapshot(user.snapshot)));
        } else {
          auth.signOut();

          emit(AuthStateError('User tidak ditemukan'));
        }
      } else {
        auth.signOut();

        emit(AuthStateError('Sign In Failed'));
      }

      // emit(AuthStateLogin());
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'user-not-found') {
        message = 'Email tidak ditemukan';
      } else if (e.code == 'wrong-password') {
        message = 'Kata sandi salah';
      } else {
        message = 'Sign In Failed';
      }

      emit(AuthStateError(message));
    } catch (e) {
      emit(AuthStateError(e.toString()));
    }
  }

  void _authEventSaveCurrentUser(
      AuthEventSaveCurrentUser event, Emitter<AuthState> emit) async {
    final DatabaseEvent user = await driverRef.child(event.userId).once();

    // print('save user: ${user.snapshot.value}');

    emit(AuthStateAuthenticated(user: User.fromSnapshot(user.snapshot)));
  }

  void _authEventRegister(
      AuthEventRegister event, Emitter<AuthState> emit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      emit(AuthStateLoading());

      final UserCredential response = await auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // print('response: $response');

      if (response.user != null) {
        Map userData = {
          'name': event.name,
          'email': event.email,
          'phoneNumber': event.phoneNumber,
          'address': event.address,
          'birthDate': event.birthDate,
        };

        await driverRef.child(response.user!.uid).set(userData);

        final DatabaseEvent user =
            await driverRef.child(response.user!.uid).once();

        prefs.setString('userId', user.snapshot.key!);
        emit(AuthStateAuthenticated(user: User.fromSnapshot(user.snapshot)));
      } else {
        emit(AuthStateError('Sign Up Failed'));
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'weak-password') {
        message = 'Kata sandi terlalu lemah';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email sudah digunakan';
      } else {
        message = 'Sign Up Failed';
      }

      emit(AuthStateError(message));
    } catch (e) {
      emit(AuthStateError(e.toString()));
    }
  }

  void _authEventLogout(AuthEventLogout event, Emitter<AuthState> emit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      emit(AuthStateLoading());

      await auth.signOut();

      prefs.remove('userId');
      emit(AuthStateUnauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthStateError(e.message.toString()));
    } catch (e) {
      emit(AuthStateError(e.toString()));
    }
  }
}
