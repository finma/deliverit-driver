import 'package:firebase_database/firebase_database.dart';

DatabaseReference driverRef = FirebaseDatabase.instance.ref().child('drivers');
DatabaseReference newRequestRef =
    FirebaseDatabase.instance.ref().child('rideRequests');
