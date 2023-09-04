import 'package:firebase_database/firebase_database.dart';

import '/models/vehicle.dart';

class Driver {
  late String? id;
  late String? address;
  late String? birthDate;
  late String? email;
  late String? imageKTP;
  late String? imageProfile;
  late String? imageSIM;
  late String? imageSTNK;
  late String? name;
  late String? newRide;
  late String? phoneNumber;
  late String? token;
  late Vehicle? vehicle;

  Driver({
    this.id,
    this.address,
    this.birthDate,
    this.email,
    this.imageKTP,
    this.imageProfile,
    this.imageSIM,
    this.imageSTNK,
    this.name,
    this.newRide,
    this.phoneNumber,
    this.token,
    this.vehicle,
  });

  Driver.fromMap(Map<dynamic, dynamic> data) {
    id = data['id'];
    address = data['address'];
    birthDate = data['birthDate'];
    email = data['email'];
    imageKTP = data['imageKTP'];
    imageProfile = data['imageProfile'];
    imageSIM = data['imageSIM'];
    imageSTNK = data['imageSTNK'];
    name = data['name'];
    newRide = data['newRide'];
    phoneNumber = data['phoneNumber'];
    token = data['token'];
    vehicle = Vehicle.fromMap(data['vehicle']);
  }

  Driver.fromSnapshot(DataSnapshot dataSnapshot)
      : this.fromMap(dataSnapshot.value as Map<dynamic, dynamic>);
}
