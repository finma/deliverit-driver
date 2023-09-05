import 'package:deliverit_driver/models/map_address.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/config/map_config.dart';
import '/helper/api.dart';
import '/models/direction_details.dart';
import '/models/place_prediction.dart';

class GoogleMapService {
  static Future<MapAddress> searchCoordinateAddress(Position position) async {
    MapAddress address = MapAddress();
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    if (response != 'failed') {
      address.longitude = position.longitude;
      address.latitude = position.latitude;
      address.placeName = response['results'][0]['formatted_address'];
      address.placeFormattedAddress =
          response['results'][0]['formatted_address'];

      // debugPrint('address: ${response['results'][0]}');
    }

    return address;
  }

  static Future<List<PlacePrediction>> findPlace(String placeName) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:id&language=id';

    if (placeName.length > 1) {
      var response = await RequestHelper.getRequest(url);

      if (response != 'failed') {
        if (response['status'] == 'OK') {
          var predictions = response['predictions'];

          List<PlacePrediction> placeList = (predictions as List)
              .map((e) => PlacePrediction.fromJson(e))
              .toList();

          // debugPrint('prediction: ${placeList[0].mainText}');

          return placeList;
        }
      }
    }

    return [];
  }

  static Future<MapAddress> getPlaceAddressDetails(
    String placeId,
    BuildContext context,
  ) async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    MapAddress dropOffAddress = MapAddress();

    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    // debugPrint('response: ${response['result']['formatted_address']}');

    if (response != 'failed') {
      if (response['status'] == 'OK') {
        dropOffAddress.placeName = response['result']['name'];
        dropOffAddress.placeId = placeId;
        dropOffAddress.latitude =
            response['result']['geometry']['location']['lat'];
        dropOffAddress.longitude =
            response['result']['geometry']['location']['lng'];
        dropOffAddress.placeFormattedAddress =
            response['result']['formatted_address'];

        if (context.mounted) {
          // debugPrint('place address: ${dropOffAddress.placeName}');
          // context.read<DeliverCubit>().setDropOffAddress(dropOffAddress);
          context.pop();
          context.pop();
        }
      }
    }
    return dropOffAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey&components=country:id&language=id';

    var response = await RequestHelper.getRequest(url);
    DirectionDetails directionDetails = DirectionDetails();

    if (response != 'failed') {
      directionDetails.encodedPoints =
          response['routes'][0]['overview_polyline']['points'];

      directionDetails.durationText =
          response['routes'][0]['legs'][0]['duration']['text'];
      directionDetails.durationValue =
          response['routes'][0]['legs'][0]['duration']['value'];

      directionDetails.distanceText =
          response['routes'][0]['legs'][0]['distance']['text'];
      directionDetails.distanceValue =
          response['routes'][0]['legs'][0]['distance']['value'];
    }

    return directionDetails;
  }
}
