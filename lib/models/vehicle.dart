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

  factory Vehicle.fromJson(Map<dynamic, dynamic> json) => Vehicle(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        maxWeight: double.parse(json["max_weight"].toString()),
        price: double.parse(json["price"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "max_weight": maxWeight,
        "price": price,
      };
}
