import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/config/firebase.dart';

part 'driver_event.dart';
part 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverBlocState> {
  DriverBloc() : super(DriverInitial()) {
    on<DriverEventSetEarnings>(_setEarnings);
  }

  void _setEarnings(
      DriverEventSetEarnings event, Emitter<DriverBlocState> emit) async {
    try {
      emit(DriverStateLoading());

      final DatabaseEvent res =
          await driverRef.child(event.userId).child('earnings').once();

      if (res.snapshot.value != null) {
        // var data = res.snapshot.value as Map<dynamic, dynamic>;
        double oldEarnings = double.parse(res.snapshot.value.toString());
        double totalEarnings =
            double.parse((event.earnings + oldEarnings).toStringAsFixed(2));

        driverRef.child(event.userId).child('earnings').set(totalEarnings);
      } else {
        driverRef.child(event.userId).child('earnings').set(event.earnings);
      }

      emit(DriverStateSuccess());
    } catch (e) {
      emit(DriverStateError(e.toString()));
    }
  }
}
