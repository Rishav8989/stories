import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.blue,
    titleTextStyle: const TextStyle(
      color: Colors.blue,
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w700,
      fontSize: 22,
    ),
    iconTheme: const IconThemeData(color: Colors.blue),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w700,
      color: Colors.black87,
      fontSize: 20,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w700,
      color: Colors.black87,
      fontSize: 20,
    ),
    bodyMedium: TextStyle(
      color: Colors.black87,
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    bodyLarge: TextStyle(
      color: Colors.black87,
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
    labelLarge: TextStyle(
      color: Colors.black87,
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w600,
      fontSize: 17,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontFamily: 'Merriweather',
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  iconTheme: const IconThemeData(color: Color.fromARGB(255, 56, 73, 82)),
  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.blueAccent,
    surface: Colors.white,
    onSurfaceVariant: Colors.black87,
    onSurface: Colors.black87,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  ),
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color.fromARGB(255, 32, 32, 32),
  primaryColor: Colors.blue,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 26, 26, 26),
    titleTextStyle: TextStyle(
      color: Colors.white70,
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w700,
      fontSize: 22,
    ),
    iconTheme: IconThemeData(color: Colors.white70),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: const Color.fromARGB(255, 48, 48, 48),
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w700,
      color: Colors.white70,
      fontSize: 20,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w700,
      color: Colors.white70,
      fontSize: 20,
    ),
    bodyMedium: TextStyle(
      color: Colors.white70,
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    bodyLarge: TextStyle(
      color: Colors.white70,
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
    labelLarge: TextStyle(
      color: Colors.white70,
      fontFamily: 'Merriweather',
      fontWeight: FontWeight.w600,
      fontSize: 17,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  iconTheme: const IconThemeData(color: Colors.white70),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontFamily: 'Merriweather',
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    ),
  ),
  colorScheme: ColorScheme.dark().copyWith(
    surface: Colors.grey[850],
    primary: Colors.blue,
  ),
);
