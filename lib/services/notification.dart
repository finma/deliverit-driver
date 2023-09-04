import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '/models/map_address.dart';
import '/models/payload.dart';
import '/models/user_delivery.dart';
import '/models/vehicle.dart';
import '/routes/router.dart';

import '/config/firebase.dart';
import '/models/ride_details.dart';

/// Handle background message
/// fetch data ride request from firebase
/// and navigate to notification page
Future<void> handleBackgroundMessage(
  RemoteMessage message,
  BuildContext context,
) async {
  final String rideRequestId = message.data['ride_request_id'];
  final DatabaseEvent rideRequest =
      await newRequestRef.child(rideRequestId).once();
  final Map<dynamic, dynamic>? dataRide =
      rideRequest.snapshot.value as Map<dynamic, dynamic>?;

  if (dataRide != null) {
    final Map<String, dynamic> dataRideMap =
        Map<String, dynamic>.from(dataRide);

    String paymentMethod = dataRideMap['paymentMethod'].toString();
    double distance = double.parse(dataRideMap['distance'].toString());
    double totalPayment = double.parse(dataRideMap['totalPayment'].toString());
    int carrier = int.parse(dataRideMap['carrier'].toString());

    MapAddress pickup = MapAddress.fromJson((dataRideMap['pickup']));
    MapAddress dropoff = MapAddress.fromJson(dataRideMap['dropoff']);

    UserDelivery sender = UserDelivery.fromJson(dataRideMap['sender']);
    UserDelivery receiver = UserDelivery.fromJson(dataRideMap['receiver']);

    List<Payload> payloads = (dataRideMap['payloads'] as List).map((e) {
      return Payload(
        id: e['id'].toString(),
        name: e['name'].toString(),
        size: Payload.stringToSize(e['size']),
        qty: e['qty'],
      );
    }).toList();

    Vehicle vehicle = Vehicle.fromJson(dataRideMap['vehicle']);

    RideDetails rideDetails = RideDetails(
      rideRequestId: rideRequestId,
      sender: sender,
      receiver: receiver,
      paymentMethod: paymentMethod,
      distance: distance,
      totalPayment: totalPayment,
      pickup: pickup,
      dropoff: dropoff,
      payloads: payloads,
      vehicle: vehicle,
      carrier: carrier,
    );

    // print('rideDetails: ${rideDetails.toJson()}');

    if (context.mounted) {
      context.goNamed(Routes.notificationRequest, extra: rideDetails);
    }
  }
}

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Android Notification Channel
  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Initialize notification
  Future<void> initNotifications(BuildContext context) async {
    await firebaseMessaging.requestPermission();
    final fCMToken = await firebaseMessaging.getToken();
    // print('FCM Token: $fCMToken');

    // save token to firebase
    if (auth.currentUser != null) {
      driverRef.child(auth.currentUser!.uid).child('token').set(fCMToken);
    }

    // subscribe to topic
    firebaseMessaging.subscribeToTopic('alldrivers');
    firebaseMessaging.subscribeToTopic('allusers');

    if (context.mounted) {
      initPushNotification(context);
      initLocalNotifications(context);
    }
  }

  /// Initialize push notification
  Future initPushNotification(BuildContext context) async {
    // RemoteMessage? initialMessage =
    //     await FirebaseMessaging.instance.getInitialMessage();

    // if (initialMessage != null && context.mounted) {
    //   print('initialMessage: $initialMessage');
    //   handleBackgroundMessage(initialMessage, context);
    // }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        // print('onMessageOpenedApp: $message');
        handleBackgroundMessage(message, context);
      },
    );

    FirebaseMessaging.onMessage.listen(
      (message) {
        // print('onMessage: $message');
        final notification = message.notification;

        if (notification == null) return;

        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@mipmap/launcher_icon',
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );

        handleBackgroundMessage(message, context);
      },
    );
  }

  Future initLocalNotifications(BuildContext context) async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const settings = InitializationSettings(iOS: iOS, android: android);

    await _localNotifications.initialize(settings,
        onDidReceiveNotificationResponse: (payload) {
      final message = RemoteMessage.fromMap(jsonDecode(payload as String));
      // print('onDidReceiveNotificationResponse: $message');
      handleBackgroundMessage(message, context);
    });

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidChannel);
  }
}
