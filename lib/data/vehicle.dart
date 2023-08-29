import '/config/app_asset.dart';
import '/models/vehicle.dart';

class DataVehicle {
  static final all = <Vehicle>[
    Vehicle(
      id: 1,
      name: 'Pick Up',
      image: AppAsset.fotoVehiclePickup,
      maxWeight: 1000,
      price: 8000,
    ),
    Vehicle(
      id: 2,
      name: 'Truk',
      image: AppAsset.fotoVehicleTruck,
      maxWeight: 2000,
      price: 12000,
    ),
    Vehicle(
      id: 3,
      name: 'Truk Box',
      image: AppAsset.fotoVehicleTruckBox,
      maxWeight: 2000,
      price: 15000,
    ),
  ];
}
