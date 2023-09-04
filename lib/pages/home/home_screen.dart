import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/config/app_asset.dart';
import '/cubit/cubit.dart';
import '/services/notification.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(-7.319563, 108.202972),
    zoom: 14.4746,
  );

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // * CONTROLLER GOOGLE MAP
  late GoogleMapController newGoogleMapController;
  late StreamSubscription<Position> homeScreenStreamSubscription;

  // * CURRENT LOCATION
  Position? currentLocation;
  Geolocator geoLocator = Geolocator();
  CameraPosition? myLocation;

  StateCubit<bool> isDriverAvailable = StateCubit(false);

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    DriverCubit driverCubit = context.read<DriverCubit>();

    // * CONTROLLER GOOGLE MAP
    final Completer<GoogleMapController> controllerGoogleMap =
        Completer<GoogleMapController>();

    // * SET INITIAL CAMERA POSITION
    if (driverCubit.state.currentPosition != null) {
      myLocation = CameraPosition(
        target: LatLng(
          driverCubit.state.currentPosition!.latitude,
          driverCubit.state.currentPosition!.longitude,
        ),
        zoom: 16,
      );
    }

    // * FUNCTION TO GET CURRENT LOCATION
    void locatePosition() async {
      bool serviceEnabled;
      LocationPermission permission;

      // * CHECK LOCATION SERVICE
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled');
      }

      // * CHECK LOCATION PERMISSION
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // * GET CURRENT LOCATION
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLocation = position;

      driverCubit.setValue(
        currentPosition: currentLocation,
      );

      // debugPrint('location: $position');

      // * MOVE CAMERA TO CURRENT LOCATION
      LatLng latlngPosition = LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition =
          CameraPosition(target: latlngPosition, zoom: 16);
      newGoogleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            BlocBuilder<DriverCubit, DriverState>(
              builder: (context, state) {
                if (state.currentPosition == null) {
                  locatePosition();
                }

                return GoogleMap(
                  mapType: MapType.normal,
                  myLocationButtonEnabled: true,
                  initialCameraPosition:
                      myLocation ?? HomeScreen.initialCameraPosition,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    controllerGoogleMap.complete(controller);
                    newGoogleMapController = controller;

                    // locatePosition();
                  },
                );
              },
            ),

            //* HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildAvatar(),
                  _buildOnlineOfflineDriver(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Positioned _buildOnlineOfflineDriver() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: BlocBuilder<StateCubit<bool>, bool>(
          bloc: isDriverAvailable,
          builder: (context, status) {
            return Material(
              color: status ? Colors.green : Colors.white,
              borderRadius: BorderRadius.circular(100),
              child: InkWell(
                onTap: () {
                  !status ? setOnline() : setOffline();
                },
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status ? 'Online' : 'Offline',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: status ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: status ? Colors.white : Colors.black,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Row _buildAvatar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(36),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Image.asset(
                AppAsset.profile,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // * FUNCTION TO SET DRIVER ONLINE
  void setOnline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    makeDriverOnlineNow(userId!);
    getLocationLiveUpdates(userId);
    isDriverAvailable.setSelectedValue(true);

    Fluttertoast.showToast(
      msg: 'Anda sedang online sekarang',
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 3,
    );
  }

  // * FUNCTION TO SET DRIVER OFFLINE
  void setOffline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    DatabaseReference rideRequestRef =
        FirebaseDatabase.instance.ref().child('drivers/$userId/newRide');

    Geofire.removeLocation(userId!);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    homeScreenStreamSubscription.cancel();

    isDriverAvailable.setSelectedValue(false);

    Fluttertoast.showToast(
      msg: 'Anda sedang offline sekarang',
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 3,
    );
  }

  //* SET LOCATION TO FIREBASE
  void makeDriverOnlineNow(String userId) async {
    DatabaseReference rideRequestRef =
        FirebaseDatabase.instance.ref().child('drivers/$userId/newRide');

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentLocation = position;

    Geofire.initialize('availableDrivers');
    Geofire.setLocation(
      userId,
      currentLocation!.latitude,
      currentLocation!.longitude,
    );

    rideRequestRef.onValue.listen((event) {});
  }

  //* GET LOCATION LIVE UPDATE
  void getLocationLiveUpdates(String userId) {
    homeScreenStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentLocation = position;
      Geofire.setLocation(userId, position.latitude, position.longitude);

      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void getCurrentDriverInfo() {
    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initNotifications(context);
  }
}
