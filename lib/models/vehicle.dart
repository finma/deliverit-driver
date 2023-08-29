class Vehicle {
  int id;
  String name;
  String image;
  double maxWeight;
  double price;

  Vehicle({
    required this.id,
    required this.name,
    required this.image,
    required this.maxWeight,
    required this.price,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        maxWeight: json["max_weight"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "max_weight": maxWeight,
        "price": price,
      };
}
