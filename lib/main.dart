import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/routes/app_routes.dart';
import 'package:stories/utils/app_initializer.dart';
import 'package:stories/utils/theme/app_theme.dart';
import 'package:stories/utils/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stories App',
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Get.find<ThemeController>().themeMode,
      initialRoute: AppRoutes.home,
      getPages: AppRoutes.pages,
    );
  }
}