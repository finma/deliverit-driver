import 'package:uuid/uuid.dart';

var uuid = const Uuid();

enum PayloadSize { small, medium, large }

class Payload {
  String? id;
  String name;
  PayloadSize size;
  int qty;

  Payload({
    String? id,
    required this.name,
    required this.size,
    this.qty = 0,
  }) : id = id ?? uuid.v4();

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
        id: json["id"],
        name: json["name"],
        size: stringToSize(json["size"]),
        qty: json["qty"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "size": sizeToString(size),
        "qty": qty,
      };

  static String sizeToString(PayloadSize size) {
    switch (size) {
      case PayloadSize.small:
        return 'kecil';
      case PayloadSize.medium:
        return 'sedang';
      case PayloadSize.large:
        return 'besar';
      default:
        throw Exception('Invalid payload size: $size');
    }
  }

  static PayloadSize stringToSize(String size) {
    switch (size) {
      case 'kecil':
        return PayloadSize.small;
      case 'sedang':
        return PayloadSize.medium;
      case 'besar':
        return PayloadSize.large;
      default:
        throw Exception('Invalid payload size: $size');
    }
  }
}
