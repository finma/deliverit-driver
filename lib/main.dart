import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import '/bloc/bloc.dart';
import '/cubit/cubit.dart';
import '/config/app_color.dart';
import '/routes/router.dart';
import '/widgets/custom_datepicker_widget.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initializeDateFormatting('id', null).then(
    (_) => runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc()),
          BlocProvider(create: (_) => DateTimePickerCubit()),
          BlocProvider(create: (_) => DriverBloc()),
          BlocProvider(create: (_) => DriverCubit()),
          BlocProvider(create: (_) => NavigationCubit()),
          BlocProvider(create: (_) => UploadFileCubit()),
          BlocProvider(create: (_) => VehicleCubit()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        primaryColor: AppColor.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColor.primary,
          secondary: AppColor.secondary,
        ),
      ),
      builder: EasyLoading.init(),
      routerConfig: router,
    );
  }
}
