class MapAddress {
  String? placeFormattedAddress;
  String? placeName;
  String? placeId;
  double? latitude;
  double? longitude;

  MapAddress({
    this.placeFormattedAddress,
    this.placeName,
    this.placeId,
    this.latitude,
    this.longitude,
  });

  factory MapAddress.fromJson(Map<dynamic, dynamic> json) => MapAddress(
        placeFormattedAddress: json["place_formatted_address"],
        placeName: json["place_name"],
        placeId: json["place_id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "place_formatted_address": placeFormattedAddress,
        "place_name": placeName,
        "place_id": placeId,
        "latitude": latitude,
        "longitude": longitude,
      };
}
