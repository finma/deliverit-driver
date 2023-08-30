import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // * CONTROLLER GOOGLE MAP
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;

  // * CURRENT LOCATION
  Position? currentLocation;
  Geolocator geoLocator = Geolocator();

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
              onMapCreated: (controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                locatePosition();
              },
            )
          ],
        ),
      ),
    );
  }
}
