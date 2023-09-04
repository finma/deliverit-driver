import '/models/map_address.dart';
import '/models/payload.dart';
import '/models/user_delivery.dart';
import '/models/vehicle.dart';

class RideDetails {
  String rideRequestId;
  String paymentMethod;
  double distance;
  double totalPayment;
  MapAddress pickup;
  MapAddress dropoff;
  UserDelivery sender;
  UserDelivery receiver;
  List<Payload> payloads;
  Vehicle vehicle;

  RideDetails({
    required this.rideRequestId,
    required this.sender,
    required this.receiver,
    required this.paymentMethod,
    required this.pickup,
    required this.dropoff,
    required this.payloads,
    required this.vehicle,
    required this.distance,
    required this.totalPayment,
  });

  // to json
  Map<String, dynamic> toJson() => {
        "ride_request_id": rideRequestId,
        "sender": sender.toJson(),
        "receiver": receiver.toJson(),
        "payment_method": paymentMethod,
        "pickup": pickup.toJson(),
        "dropoff": dropoff.toJson(),
        "payloads": payloads.map((e) => e.toJson()).toList(),
        "vehicle": vehicle.toJson(),
        "distance": distance,
        "total_payment": totalPayment,
      };
}
