import 'package:deliverit_driver/config/map_config.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

class AssistentMethod {
  static void disabledHomeLiveLocation(String userId) {
    homeScreenStreamSubscription?.pause();
    Geofire.removeLocation(userId);
  }

  static void enabledHomeLiveLocation(String userId) {
    homeScreenStreamSubscription!.resume();
    Geofire.setLocation(
      userId,
      currentLocation!.latitude,
      currentLocation!.longitude,
    );
  }
}
