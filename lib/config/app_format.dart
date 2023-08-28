import 'package:intl/intl.dart';

class AppFormat {
  static String date(String stringDate) {
    // 2023-12-31
    DateTime date = DateTime.parse(stringDate);
    return DateFormat('dd MMMM yyyy').format(date); // 31 Desember 2023
  }

  static String dateMonth(String stringDate) {
    // 2023-12-31
    DateTime date = DateTime.parse(stringDate);
    return DateFormat('dd MMMM').format(date); // 31 Desember
  }

  static String currency(double number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  } // Rp 1.000.000

  static double countTotalPayment({
    required double vehiclePrice,
    required double distance,
    required int carrier,
  }) {
    return (vehiclePrice * distance) + (carrier * 50000);
  } // 1000000

  static double countDistance(double distance) {
    return double.parse((distance / 1000).toStringAsFixed(2));
  } // 1.23
}
