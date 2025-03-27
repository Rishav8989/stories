import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

ThemeData lightTheme = ThemeData(
  // **Light Theme - White and Blue - BOLDER FONTS**
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.blue,
    titleTextStyle: TextStyle(
      color: Colors.blue,
      fontFamily: GoogleFonts.montserrat().fontFamily, // **Montserrat - Bolder, Modern**
      fontWeight: FontWeight.w700, // **Bold (Weight 700)** - Even bolder AppBar title
      fontSize: 22, // Slightly larger AppBar title for more impact
    ),
    iconTheme: const IconThemeData(color: Colors.blue),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Colors.white,
  ),
  textTheme: TextTheme(
    // Using Montserrat for Headings and Titles - Bolder and Modern
    headlineSmall: TextStyle(fontFamily: GoogleFonts.montserrat().fontFamily, fontWeight: FontWeight.w700, color: Colors.black87), // Bolder Headings
    titleLarge: TextStyle(fontFamily: GoogleFonts.montserrat().fontFamily, fontWeight: FontWeight.w700, color: Colors.black87),   // Bolder Titles
    // Using Open Sans for Body Text - Readable and Clean, but still a bit bolder than default Roboto
    bodyMedium: TextStyle(
      color: Colors.black87,
      fontFamily: GoogleFonts.openSans().fontFamily, // **Open Sans - Readable, slightly bolder body text**
      fontWeight: FontWeight.w600, // **Semi-Bold (Weight 600)** - Make body text a bit bolder
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      textStyle: TextStyle(
        fontFamily: GoogleFonts.montserrat().fontFamily, // **Montserrat for Button Text - Bolder Buttons**
        fontWeight: FontWeight.w700, // **Bold Button Text**
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
  // **Dark Theme - Dark Grey - BOLDER FONTS**
  scaffoldBackgroundColor: const Color.fromARGB(255, 32, 32, 32), // Dark Grey
  primaryColor: Colors.blue,
  appBarTheme: AppBarTheme(
    backgroundColor: const Color.fromARGB(255, 26, 26, 26), // Slightly darker Grey AppBar
    titleTextStyle: TextStyle(
      color: Colors.white70, // Less bright white for dark grey background
      fontFamily: GoogleFonts.montserrat().fontFamily, // **Montserrat - Bolder, Modern** (Same as light theme)
      fontWeight: FontWeight.w700, // **Bold (Weight 700)** - Bolder AppBar title
      fontSize: 22, // Slightly larger AppBar title
    ),
    iconTheme: const IconThemeData(color: Colors.white70), // Less bright white icons
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: const Color.fromARGB(255, 48, 48, 48), // Medium Dark Grey Drawer
  ),
  textTheme: TextTheme(
    // Using Montserrat for Headings and Titles - Bolder and Modern
    headlineSmall: TextStyle(fontFamily: GoogleFonts.montserrat().fontFamily, fontWeight: FontWeight.w700, color: Colors.white70), // Bolder Headings
    titleLarge: TextStyle(fontFamily: GoogleFonts.montserrat().fontFamily, fontWeight: FontWeight.w700, color: Colors.white70),   // Bolder Titles
    // Using Open Sans for Body Text - Readable and Clean, but still a bit bolder than default Roboto
    bodyMedium: TextStyle(
      color: Colors.white70, // Less bright white text
      fontFamily: GoogleFonts.openSans().fontFamily, // **Open Sans - Readable, slightly bolder body text** (Same as light theme)
      fontWeight: FontWeight.w600, // **Semi-Bold (Weight 600)** - Make body text a bit bolder (Same as light theme)
    ),
    // Customize other text styles here for dark theme if needed
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  iconTheme: const IconThemeData(color: Colors.white70), // Less bright white icons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      textStyle: TextStyle(
        fontFamily: GoogleFonts.montserrat().fontFamily, // **Montserrat for Button Text - Bolder Buttons** (Same as light theme)
        fontWeight: FontWeight.w700, // **Bold Button Text** (Same as light theme)
      ),
    ),
  ),
  colorScheme: ColorScheme.dark().copyWith(
    surface: Colors.grey[850],   // Dark Grey Background
    primary: Colors.blue,
  ),
);
