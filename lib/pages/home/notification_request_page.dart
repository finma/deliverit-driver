import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/config/app_asset.dart';
import '/config/app_color.dart';
import '/config/app_format.dart';
import '/config/app_symbol.dart';
import '/config/map_config.dart';
import '/data/payload.dart';
import '/data/vehicle.dart';
import '/models/payload.dart';
import '/models/ride_details.dart';
import '/models/vehicle.dart';

class NotificationRidePage extends StatelessWidget {
  final RideDetails rideDetails;

  NotificationRidePage({super.key, required this.rideDetails});

  final payloads = DataPayload.all;
  final vehicles = DataVehicle.all;

  final double bottomSheetHeight = 160;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Cant go back
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
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
        ),
        bottomSheet: _buildBottomSheet(
          distance: rideDetails.distance,
          totalPayment: rideDetails.totalPayment,
          paymentMethod: rideDetails.paymentMethod,
        ),
        body: SingleChildScrollView(
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
        ),
      ),
    );
  }

  Container _buildBottomSheet({
    required double distance,
    required double totalPayment,
    required String paymentMethod,
  }) {
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
                    audioPlayer.stop();

                    // todo: add function to accept ride request
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
}
