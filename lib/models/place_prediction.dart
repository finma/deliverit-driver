class PlacePrediction {
  String placeId;
  String mainText;
  String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) =>
      PlacePrediction(
        placeId: json["place_id"],
        mainText: json["structured_formatting"]["main_text"],
        secondaryText: json["structured_formatting"]["secondary_text"],
      );

  Map<String, dynamic> toJson() => {
        "place_id": placeId,
        "main_text": mainText,
        "secondary_text": secondaryText,
      };
}
