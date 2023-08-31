import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

part 'driver_state.dart';

class DriverCubit extends Cubit<DriverState> {
  DriverCubit()
      : super(
          DriverState(
            currentPosition: null,
          ),
        );

  void setValue({
    Position? currentPosition,
  }) {
    final currentState = state;

    emit(DriverState(
      currentPosition: currentPosition ?? currentState.currentPosition,
    ));
  }
}
