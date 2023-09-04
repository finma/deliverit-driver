import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/bloc/bloc.dart';
import '/pages/home/home_page.dart';
import '/models/ride_details.dart';
import '/pages/home/notification_request_page.dart';
import '/pages/initial_page.dart';
import '/pages/select_mitra_page.dart';
import '/pages/signin_page.dart';
import '/pages/signup_page.dart';
import '/pages/upload_file_page.dart';

part 'route_names.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(
      path: '/',
      name: Routes.home,
      builder: (context, state) => HomePage(),
      redirect: (context, state) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        FirebaseAuth auth = FirebaseAuth.instance;
        final String? userId = prefs.getString('userId');

        // print('user firebase: ${auth.currentUser}');
        // print('user pref: ${userId}');

        if (auth.currentUser == null || userId == null) {
          return '/initial-page';
        }

        if (context.mounted) {
          context
              .read<AuthBloc>()
              .add(AuthEventSaveCurrentUser(userId: auth.currentUser!.uid));
        }

        return null;
      },
      routes: [
        GoRoute(
          path: 'notification-ride-request',
          name: Routes.notificationRequest,
          pageBuilder: (context, state) {
            RideDetails rideDetails = state.extra as RideDetails;

            return CustomTransitionPage(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 1000),
              child: NotificationRidePage(rideDetails: rideDetails),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final tween = Tween<double>(begin: 0.0, end: 1.0);
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.linearToEaseOut,
                );

                return ScaleTransition(
                  scale: tween.animate(curvedAnimation),
                  child: child,
                );
              },
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/initial-page',
      name: Routes.initialPage,
      builder: (context, state) => InitialPage(),
      routes: [
        GoRoute(
          path: 'signin',
          name: Routes.signin,
          builder: (context, state) => SignInPage(),
        ),
        GoRoute(
          path: 'signup',
          name: Routes.signup,
          builder: (context, state) => SignUpPage(),
        ),
        GoRoute(
          path: 'select-mitra',
          name: Routes.selectMitra,
          builder: (context, state) => SelectMitraPage(),
          routes: [
            GoRoute(
              path: 'upload-file',
              name: Routes.uploadFile,
              builder: (context, state) => UploadFilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
