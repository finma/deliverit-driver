import 'package:flutter_bloc/flutter_bloc.dart';

import '/models/vehicle.dart';

class VehicleCubit extends Cubit<Vehicle?> {
  VehicleCubit() : super(null);

  void setSelectedValue(Vehicle vehicle) {
    emit(vehicle);
  }
}
