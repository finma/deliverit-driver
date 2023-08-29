import 'package:firebase_database/firebase_database.dart';

class User {
  late String id;
  late String email;
  late String name;
  late String address;
  late String birthDate;
  late String phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
  });

  User.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key!;
    final Map<dynamic, dynamic>? data =
        dataSnapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      email = data['email'];
      name = data['name'];
      phoneNumber = data['phoneNumber'];
      address = data['address'];
      birthDate = data['birthDate'];
    }
  }
}
