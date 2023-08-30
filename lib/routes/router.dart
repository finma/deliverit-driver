import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '/bloc/bloc.dart';
import '/pages/home/home_page.dart';
import '/pages/initial_page.dart';
import '/pages/select_mitra_page.dart';
import '/pages/signin_page.dart';
import '/pages/signup_page.dart';
import '/pages/upload_file_page.dart';

part 'route_names.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: Routes.home,
      builder: (context, state) => HomePage(),
      redirect: (context, state) async {
        FirebaseAuth auth = FirebaseAuth.instance;

        // debugPrint('user: ${auth.currentUser}');

        if (auth.currentUser == null) {
          return '/initial-page';
        }

        context
            .read<AuthBloc>()
            .add(AuthEventSaveCurrentUser(userId: auth.currentUser!.uid));

        return null;
      },
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
