import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/routes/app_routes.dart';
import 'package:stories/utils/app_initializer.dart';
import 'package:stories/utils/theme/app_theme.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:stories/controller/font_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontController = Get.put(FontController());
    final themeController = Get.find<ThemeController>();
    
    return Obx(() {
      final currentFont = fontController.selectedFont;
      
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stories App',
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        theme: lightTheme.copyWith(
          textTheme: lightTheme.textTheme.apply(
            fontFamily: currentFont,
          ),
          appBarTheme: lightTheme.appBarTheme.copyWith(
            titleTextStyle: lightTheme.appBarTheme.titleTextStyle?.copyWith(
              fontFamily: currentFont,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: TextStyle(
                fontFamily: currentFont,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
        darkTheme: darkTheme.copyWith(
          textTheme: darkTheme.textTheme.apply(
            fontFamily: currentFont,
          ),
          appBarTheme: darkTheme.appBarTheme.copyWith(
            titleTextStyle: darkTheme.appBarTheme.titleTextStyle?.copyWith(
              fontFamily: currentFont,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: TextStyle(
                fontFamily: currentFont,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
        themeMode: themeController.themeMode,
        initialRoute: AppRoutes.home,
        getPages: AppRoutes.pages,
      );
    });
  }
}