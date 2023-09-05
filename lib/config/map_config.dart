import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:geolocator/geolocator.dart';

import '/models/driver.dart';

String mapKey = 'AIzaSyAb0VVTubNOlT-M8p4L5FyZnJoR9unOnxs';
String oldMapKey = 'AIzaSyDPaBgt_oedAQiUxlApwiPc9LCsx7W96pQ';

Position? currentLocation;

AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
Driver driverInformation = Driver();
