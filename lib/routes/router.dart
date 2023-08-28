import 'package:go_router/go_router.dart';

import '/pages/home/home_page.dart';

part 'route_names.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: Routes.home,
      builder: (context, state) => HomePage(),
    ),
  ],
);
