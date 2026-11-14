import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sticker_flutter/features/home_screen/presentation/home_screen.dart';
import 'package:sticker_flutter/helpers/all_routes.dart';
import 'package:sticker_flutter/helpers/di.dart';
import 'package:sticker_flutter/helpers/navigation_service.dart';
import 'package:sticker_flutter/networks/dio/dio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Setup Dependency Injection
  diSetup();

  // Initialize Dio Client
  DioSingleton.instance.create();

  // Configure Status Bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Sticker Studio',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF0D0F18),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFABC1D),
              brightness: Brightness.dark,
            ),
          ),
          navigatorKey: NavigationService.navigatorKey,
          onGenerateRoute: RouteGenerator.generateRoute,
          home: const HomeScreen(),
        );
      },
    );
  }
}
