import 'package:go_router/go_router.dart';

import '/pages/home/home_page.dart';
import '/pages/initial_page.dart';
import '/pages/signin_page.dart';

part 'route_names.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: Routes.home,
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/initial-page',
      name: Routes.initialPage,
      builder: (context, state) => InitialPage(),
    ),
    GoRoute(
      path: '/signin',
      name: Routes.signin,
      builder: (context, state) => SignInPage(),
    ),
  ],
);
