class UserDelivery {
  String name;
  String phoneNumber;
  String? note;

  UserDelivery({
    required this.name,
    required this.phoneNumber,
    this.note,
  });

  factory UserDelivery.fromJson(Map<dynamic, dynamic> json) => UserDelivery(
        name: json["name"],
        phoneNumber: json["phone_number"],
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone_number": phoneNumber,
        "note": note,
      };
}
