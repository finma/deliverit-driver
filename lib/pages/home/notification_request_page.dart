import 'dart:async';

import 'package:action_slider/action_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/bloc/bloc.dart';
import '/config/app_asset.dart';
import '/config/app_color.dart';
import '/config/app_format.dart';
import '/config/app_symbol.dart';
import '/config/firebase.dart';
import '/config/map_config.dart';
import '/cubit/cubit.dart';
import '/data/payload.dart';
import '/data/vehicle.dart';
import '/helper/assistant_method.dart';
import '/models/payload.dart';
import '/models/ride_details.dart';
import '/models/vehicle.dart';
import '/services/googlemap.dart';

// ignore: must_be_immutable
class NotificationRidePage extends HookWidget {
  final RideDetails rideDetails;

  NotificationRidePage({super.key, required this.rideDetails});

  late GoogleMapController newRideGoogleMapController;

  final payloads = DataPayload.all;
  final vehicles = DataVehicle.all;

  final double bottomSheetHeight = 160;
  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(-7.319563, 108.202972),
    zoom: 14.4746,
  );

  Geolocator geolocator = Geolocator();
  late BitmapDescriptor animatingMarkerIcon;

  @override
  Widget build(BuildContext context) {
    final driverCubit = context.read<DriverCubit>();

    //* show google map when ride request accepted
    final isShowGoogleMap = useState(false);
    final isDirectionLoaded = useState(false);

    final Completer<GoogleMapController> controllerGoogleMap =
        Completer<GoogleMapController>();

    final markerSet = useState<Set<Marker>>(<Marker>{});
    final polylineSet = useState<Set<Polyline>>(<Polyline>{});
    final circleSet = useState<Set<Circle>>(<Circle>{});
    final polylineCoordinates = useState<List<LatLng>>(<LatLng>[]);
    final myPosition = useState<Position?>(null);
    final status = useState('accepted');
    final btnTitle = useState('Sampai di lokasi pengambilan');

    // * GET PLACE DIRECTION AND DRAW ROUTE ON MAP
    Future<void> getPlaceDirection(
      LatLng pickupLatLng,
      LatLng dropoffLatLng,
    ) async {
      // * GET PICK UP AND DROP OFF ADDRESS
      LatLng pickUpLatLng =
          LatLng(pickupLatLng.latitude, pickupLatLng.longitude);
      LatLng dropOffLatLng =
          LatLng(dropoffLatLng.latitude, dropoffLatLng.longitude);

      //* GET DIRECTION DETAILS
      var details = await GoogleMapService.obtainPlaceDirectionDetails(
          pickUpLatLng, dropOffLatLng);

      // * DECODE POLYLINE POINTS
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPolylinePointsResult =
          polylinePoints.decodePolyline(details.encodedPoints!);

      // * ADD DECODED POLYLINE POINTS TO ARRAY
      polylineCoordinates.value.clear();
      if (decodedPolylinePointsResult.isNotEmpty) {
        for (var pointLatLng in decodedPolylinePointsResult) {
          polylineCoordinates.value.add(
            LatLng(pointLatLng.latitude, pointLatLng.longitude),
          );
        }
      }

      // * CREATE POLYLINE
      polylineSet.value.clear();
      Polyline polyline = Polyline(
        polylineId: const PolylineId('polylineId'),
        color: AppColor.primary,
        jointType: JointType.round,
        points: polylineCoordinates.value,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.value.add(polyline);

      // * CREATE BOUND LATLNG TO FIT TWO MARKERS
      LatLngBounds latLngBounds;
      if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
          pickUpLatLng.longitude > dropOffLatLng.longitude) {
        latLngBounds =
            LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
      } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
        latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
        );
      } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
        latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
        );
      } else {
        latLngBounds =
            LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
      }

      // * MOVE CAMERA TO FIT TWO MARKERS
      newRideGoogleMapController
          .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

      // * CREATE MARKER
      Marker pickUpMarker = Marker(
        markerId: const MarkerId('pickUpId'),
        position: pickUpLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      Marker dropOffMarker = Marker(
        markerId: const MarkerId('dropOffId'),
        position: dropOffLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      markerSet.value.add(pickUpMarker);
      markerSet.value.add(dropOffMarker);

      // * CREATE CIRCLE
      Circle pickUpCircle = Circle(
        circleId: const CircleId('pickUpId'),
        fillColor: AppColor.primary,
        center: pickUpLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: AppColor.primary,
      );

      Circle dropOffCircle = Circle(
        circleId: const CircleId('dropOffId'),
        fillColor: AppColor.primary,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: AppColor.primary,
      );

      circleSet.value.add(pickUpCircle);
      circleSet.value.add(dropOffCircle);
    }

    // * CREATE MARKER ICON PICKUP ON MAP
    createIconMarker(context);

    // * RIDE LIVE LOCAITON UPDATES
    void getRideLiveLocationUpdates() {
      rideStreamSubscription =
          Geolocator.getPositionStream().listen((Position position) {
        currentLocation = position;
        myPosition.value = position;
        LatLng mPosition = LatLng(position.latitude, position.longitude);

        Marker animatingMarker = Marker(
          markerId: const MarkerId('animating'),
          position: mPosition,
          icon: animatingMarkerIcon,
          infoWindow: const InfoWindow(title: 'Lokasi Anda'),
        );

        CameraPosition cameraPosition = CameraPosition(
          target: mPosition,
          zoom: 18.5,
        );
        newRideGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markerSet.value
            .removeWhere((marker) => marker.markerId.value == 'animating');
        markerSet.value.add(animatingMarker);
      });
    }

    return WillPopScope(
      onWillPop: () async {
        // Cant go back
        return Future.value(false);
      },
      child: Scaffold(
        appBar: !isShowGoogleMap.value
            ? AppBar(
                elevation: 0,
                centerTitle: true,
                title: SizedBox(
                  width: 90,
                  child: Image.asset(
                    AppAsset.logoDeliveritText2,
                    fit: BoxFit.contain,
                  ),
                ),
                backgroundColor: Colors.white,
              )
            : null,
        bottomSheet: Visibility(
          visible: !isShowGoogleMap.value,
          replacement: Container(
            // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            height: 340,
            decoration: const BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Column(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 3),
                                Text(
                                  status.value != 'accepted' ||
                                          status.value != 'arived_pickup'
                                      ? 'Alamat tujuan'
                                      : 'Alamat pengambilan',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  status.value != 'accepted' ||
                                          status.value != 'arived_pickup'
                                      ? rideDetails.dropoff.placeName!
                                      : rideDetails.pickup.placeName!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  status.value != 'accepted' ||
                                          status.value != 'arived_pickup'
                                      ? rideDetails
                                          .dropoff.placeFormattedAddress!
                                      : rideDetails
                                          .pickup.placeFormattedAddress!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.outlined_flag_rounded,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 3),
                                Text(
                                  status.value != 'accepted' ||
                                          status.value != 'arived_pickup'
                                      ? rideDetails.sender.note != null &&
                                              rideDetails.sender.note != ''
                                          ? rideDetails.sender.note!
                                          : 'Tidak ada catatan'
                                      : rideDetails.receiver.note != null &&
                                              rideDetails.receiver.note != ''
                                          ? rideDetails.receiver.note!
                                          : 'Tidak ada catatan',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: ActionSlider.standard(
                    foregroundBorderRadius: BorderRadius.circular(10),
                    backgroundBorderRadius: BorderRadius.circular(15),
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                    successIcon: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                    ),
                    sliderBehavior: SliderBehavior.stretch,
                    loadingIcon: const SizedBox(
                      width: 55,
                      child: Center(
                        child: SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    action: (controller) async {
                      controller.loading();

                      String rideRequestId = rideDetails.rideRequestId;
                      LatLng pickupLatLng = LatLng(
                        rideDetails.pickup.latitude!,
                        rideDetails.pickup.longitude!,
                      );

                      LatLng dropoffLatLng = LatLng(
                        rideDetails.dropoff.latitude!,
                        rideDetails.dropoff.longitude!,
                      );

                      switch (status.value) {
                        case 'accepted':
                          status.value = 'arrived_pickup';
                          btnTitle.value = 'Barang sudah dimuat';
                          await getPlaceDirection(pickupLatLng, dropoffLatLng);
                          break;

                        case 'arrived_pickup':
                          status.value = 'already_picked_up';
                          btnTitle.value = 'Mulai perjalanan';
                          break;

                        case 'already_picked_up':
                          status.value = 'onride';
                          btnTitle.value = 'Sampai di lokasi tujuan';
                          break;

                        case 'onride':
                          status.value = 'arrived_dropoff';
                          btnTitle.value = 'Barang sudah diturunkan';
                          break;

                        case 'arrived_dropoff':
                          status.value = 'delivered';
                          btnTitle.value = 'Selesai antar';
                          break;

                        case 'delivered':
                          status.value = 'completed';
                          newRequestRef
                              .child(rideRequestId)
                              .child('fares')
                              .set(rideDetails.totalPayment);
                          rideStreamSubscription!.cancel();
                          btnTitle.value = 'Selesai';
                          controller.success();
                          break;

                        default:
                          break;
                      }

                      newRequestRef
                          .child(rideRequestId)
                          .child('status')
                          .set(status.value);
                      await Future.delayed(const Duration(seconds: 2));
                      controller.reset();
                    },
                    child: Text(
                      btnTitle.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColor.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          child: _buildBottomSheet(
            context,
            distance: rideDetails.distance,
            totalPayment: rideDetails.totalPayment,
            paymentMethod: rideDetails.paymentMethod,
            isShowGoogleMap: isShowGoogleMap,
          ),
        ),
        body: Visibility(
          visible: isShowGoogleMap.value,
          replacement: _buildDetailRideRequest(),
          child: SafeArea(
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: initialCameraPosition,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                  markers: markerSet.value,
                  polylines: polylineSet.value,
                  circles: circleSet.value,
                  onMapCreated: (controller) async {
                    EasyLoading.show(status: 'Loading...');

                    controllerGoogleMap.complete(controller);
                    newRideGoogleMapController = controller;

                    var currentLatLng = LatLng(
                      driverCubit.state.currentPosition!.latitude,
                      driverCubit.state.currentPosition!.longitude,
                    );
                    var pickupLatLng = LatLng(
                      rideDetails.pickup.latitude!,
                      rideDetails.pickup.longitude!,
                    );

                    await getPlaceDirection(currentLatLng, pickupLatLng);

                    getRideLiveLocationUpdates();

                    EasyLoading.dismiss();

                    isDirectionLoaded.value = true;
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _buildDetailRideRequest() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, bottomSheetHeight + 16),
      child: Column(
        children: <Widget>[
          //* Card Pickup Address
          _buildCardAddress(
            title: 'Alamat pengambilan',
            userName: rideDetails.sender.name,
            placeName: rideDetails.pickup.placeName!,
            address: rideDetails.pickup.placeFormattedAddress!,
            phoneNumber: rideDetails.sender.phoneNumber,
            note: rideDetails.sender.note,
          ),
          const SizedBox(height: 24),

          //* Card Dropoff Address
          _buildCardAddress(
            title: 'Alamat pengiriman',
            userName: rideDetails.receiver.name,
            placeName: rideDetails.dropoff.placeName!,
            address: rideDetails.dropoff.placeFormattedAddress!,
            phoneNumber: rideDetails.receiver.phoneNumber,
            note: rideDetails.receiver.note,
          ),
          const SizedBox(height: 24),

          //* Card List Payload
          _buildCardListPayload(payloads: rideDetails.payloads),
          const SizedBox(height: 24),

          //* Card Vehicle
          _buildCardVehicle(
            vehicle: rideDetails.vehicle,
            carrier: rideDetails.carrier,
          ),
        ],
      ),
    );
  }

  Container _buildBottomSheet(BuildContext context,
      {required double distance,
      required double totalPayment,
      required String paymentMethod,
      required ValueNotifier<bool> isShowGoogleMap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      height: bottomSheetHeight,
      decoration: const BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: IntrinsicHeight(
        child: Column(
          children: [
            _buildItemSheet(
                title: 'Jarak',
                value: '${AppFormat.countDistance(distance)} km'),
            const SizedBox(height: 4),
            _buildItemSheet(
              title: 'Tarif',
              value: AppFormat.currency(totalPayment),
            ),
            const SizedBox(height: 4),
            _buildItemSheet(
              title: 'Pembayaran',
              value: paymentMethod,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildButton(
                  label: 'Tolak',
                  color: AppColor.danger,
                  onTap: () {
                    audioPlayer.stop();

                    // todo: add function to reject ride request
                  },
                ),
                _buildButton(
                  label: 'Terima',
                  color: AppColor.success,
                  onTap: () {
                    // todo: add function to accept ride request
                    audioPlayer.stop();
                    checkAvailibilityOfRide(context, isShowGoogleMap);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildButton({
    required String label,
    required Color color,
    required void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 36,
          vertical: 12,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Row _buildItemSheet({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  Container _buildCardAddress({
    required String title,
    required String userName,
    required String placeName,
    required String address,
    required String phoneNumber,
    String? note,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
        ),
        //create box shadow
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Column(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColor.primary,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      placeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )
            ],
          ),
          const Divider(thickness: 1, height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.person_outline_rounded, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    Text(
                      '$phoneNumber ($userName)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.outlined_flag_rounded, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    Text(
                      note != null && note != '' ? note : 'Tidak ada catatan',
                      // note  ?? 'Tidak ada catatan',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container _buildCardListPayload({
    required List<Payload> payloads,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
        ),
        //create box shadow
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Column(
                children: [
                  Icon(
                    CupertinoIcons.cube_box,
                    color: AppColor.primary,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    const Text('Barang yang akan dikirim'),
                    const SizedBox(height: 8),
                    ...payloads
                        .map((payload) => _buildItemPayload(payload))
                        .toList()
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Column _buildItemPayload(Payload payload) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payload.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    Payload.sizeToString(payload.size),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('${AppSymbol.multiplication} ${payload.qty}'),
          ],
        ),
        const Divider(thickness: 1, height: 24)
      ],
    );
  }

  Container _buildCardVehicle(
      {required Vehicle vehicle, required int carrier}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
        ),
        //create box shadow
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Column(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    color: AppColor.primary,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3),
                  const Text('Mobil yang dipilih'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            vehicle.image,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$carrier pengangkut tambahan',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  void checkAvailibilityOfRide(
    BuildContext context,
    ValueNotifier<bool> isShowGoogleMap,
  ) async {
    final auth = context.read<AuthBloc>();
    String userId = auth.state.user.id;

    DatabaseReference rideRequestRef =
        FirebaseDatabase.instance.ref().child('drivers/$userId/newRide');
    DatabaseEvent response = await rideRequestRef.once();
    String? theRideId;

    if (response.snapshot.value != null) {
      theRideId = response.snapshot.value.toString();
    } else {
      Fluttertoast.showToast(
        msg: 'Pesanan sudah tidak ada',
        timeInSecForIosWeb: 2,
      );
    }

    // print('debug console: theRideId $theRideId');

    if (theRideId == rideDetails.rideRequestId) {
      rideRequestRef.set('accepted');
      if (context.mounted) {
        AssistentMethod.disabledHomeLiveLocation(userId);
        acceptRideRequest(context);
        isShowGoogleMap.value = true;
      }
    } else if (theRideId == 'canceled') {
      Fluttertoast.showToast(
        msg: 'Pesanan sudah dibatalkan',
        timeInSecForIosWeb: 2,
      );
    } else if (theRideId == 'timeout') {
      Fluttertoast.showToast(
        msg: 'Pesanan sudah kadaluarsa',
        timeInSecForIosWeb: 2,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Pesanan sudah tidak ada',
        timeInSecForIosWeb: 2,
      );
    }
  }

  void acceptRideRequest(BuildContext context) {
    newRequestRef
        .child(rideDetails.rideRequestId)
        .child('status')
        .set('accepted');
    newRequestRef
        .child(rideDetails.rideRequestId)
        .child('driverId')
        .set(driverInformation.id);
    newRequestRef
        .child(rideDetails.rideRequestId)
        .child('driverName')
        .set(driverInformation.name);
    newRequestRef
        .child(rideDetails.rideRequestId)
        .child('driverPhone')
        .set(driverInformation.phoneNumber);
    newRequestRef
        .child(rideDetails.rideRequestId)
        .child('driverVehicle')
        .set(driverInformation.vehicle!.toJson());

    Map locMap = {
      'latitude': context
          .read<DriverCubit>()
          .state
          .currentPosition!
          .latitude
          .toString(),
      'longitude': context
          .read<DriverCubit>()
          .state
          .currentPosition!
          .longitude
          .toString(),
    };

    newRequestRef
        .child(rideDetails.rideRequestId)
        .child('driverLocation')
        .set(locMap);
  }

  void createIconMarker(BuildContext context) {
    ImageConfiguration imageConfiguration =
        createLocalImageConfiguration(context, size: const Size(2, 2));
    BitmapDescriptor.fromAssetImage(imageConfiguration, AppAsset.iconPickup)
        .then((value) {
      animatingMarkerIcon = value;
    });
  }
}
