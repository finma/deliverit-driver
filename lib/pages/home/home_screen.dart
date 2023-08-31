import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/bloc/bloc.dart';
import '/config/app_asset.dart';
import '/cubit/cubit.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // * CONTROLLER GOOGLE MAP
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;
  // late StreamSubscription<Position> homeScreenStreamSubscription;

  // * CURRENT LOCATION
  Position? currentLocation;
  Geolocator geoLocator = Geolocator();

  StateCubit<bool> isDriverAvailable = StateCubit(false);

  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(-7.319563, 108.202972),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
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

      // debugPrint('location: $position');

      // * MOVE CAMERA TO CURRENT LOCATION
      LatLng latlngPosition = LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition =
          CameraPosition(target: latlngPosition, zoom: 16);
      newGoogleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      // * GET CURRENT ADDRESS
      // if (context.mounted) {
      //   MapAddress address =
      //       await GoogleMapService.searchCoordinateAddress(position);

      //   // * ADD CURRENT ADDRESS AND POSITION TO CUBIT
      //   deliverCubit.setPickUpAddress(address);
      //   deliverCubit.addCurrentPosition(position);
      // }
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: initialCameraPosition,
              myLocationEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                locatePosition();
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
            print('status: $status');
            return Material(
              color: status ? Colors.green : Colors.white,
              borderRadius: BorderRadius.circular(100),
              child: InkWell(
                onTap: () {
                  if (!status) {
                    isDriverAvailable.setSelectedValue(true);
                  } else {
                    isDriverAvailable.setSelectedValue(false);
                  }
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

  // void makeDriverOnlineNow(
  //     {required DatabaseReference rideRequestRef,
  //     required String userId}) async {
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //   currentLocation = position;

  //   Geofire.initialize('availableDrivers');
  //   Geofire.setLocation(
  //     userId,
  //     currentLocation!.latitude,
  //     currentLocation!.longitude,
  //   );

  //   rideRequestRef.onValue.listen((event) {});
  // }

  // void getLocationLiveUpdates({required String userId}) {
  //   homeScreenStreamSubscription =
  //       Geolocator.getPositionStream().listen((Position position) {
  //     currentLocation = position;
  //     Geofire.setLocation(userId, position.latitude, position.longitude);

  //     LatLng latLng = LatLng(position.latitude, position.longitude);
  //     newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
  //   });
  // }
}
