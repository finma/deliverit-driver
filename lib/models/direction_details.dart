class DirectionDetails {
  String? distanceText;
  String? durationText;
  String? encodedPoints;
  int? distanceValue;
  int? durationValue;

  DirectionDetails({
    this.distanceText,
    this.durationText,
    this.encodedPoints,
    this.distanceValue,
    this.durationValue,
  });

  factory DirectionDetails.fromJson(Map<String, dynamic> json) =>
      DirectionDetails(
        distanceText: json["distance_text"],
        durationText: json["duration_text"],
        encodedPoints: json["encode_points"],
        distanceValue: json["distance_value"],
        durationValue: json["duration_value"],
      );

  Map<String, dynamic> toJson() => {
        "distance_text": distanceText,
        "duration_text": durationText,
        "encode_points": encodedPoints,
        "distance_value": distanceValue,
        "duration_value": durationValue,
      };
}
