import 'package:flutter/material.dart';

// Base theme configuration
ThemeData _createTheme({
  required Color primaryColor,
  required Color secondaryColor,
  required Color backgroundColor,
  required Color textColor,
  required Color surfaceColor,
  required Color appBarColor,
  required Color iconColor,
  required Color cardColor,
  required Color dividerColor,
  required Color selectedColor,
  required Color unselectedColor,
  required double borderRadius,
  required double elevation,
  required String fontFamily,
}) {
  return ThemeData(
    useMaterial3: true,
    primarySwatch: MaterialColor(primaryColor.value, {
      50: primaryColor.withOpacity(0.1),
      100: primaryColor.withOpacity(0.2),
      200: primaryColor.withOpacity(0.3),
      300: primaryColor.withOpacity(0.4),
      400: primaryColor.withOpacity(0.5),
      500: primaryColor.withOpacity(0.6),
      600: primaryColor.withOpacity(0.7),
      700: primaryColor.withOpacity(0.8),
      800: primaryColor.withOpacity(0.9),
      900: primaryColor,
    }),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    dividerColor: dividerColor,
    appBarTheme: AppBarTheme(
      backgroundColor: appBarColor,
      foregroundColor: textColor,
      elevation: elevation,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      iconTheme: IconThemeData(color: iconColor),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: surfaceColor,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
    ),
    textTheme: TextTheme(
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        color: textColor,
        fontSize: 20,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        color: textColor,
        fontSize: 20,
      ),
      bodyMedium: TextStyle(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: TextStyle(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      labelLarge: TextStyle(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 17,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    iconTheme: IconThemeData(color: iconColor),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      elevation: elevation,
      type: BottomNavigationBarType.fixed,
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      onSurfaceVariant: textColor,
      onSurface: textColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
  );
}

// Light Theme
ThemeData lightTheme = _createTheme(
  primaryColor: Colors.blue,
  secondaryColor: Colors.blueAccent,
  backgroundColor: Colors.white,
  textColor: Colors.black87,
  surfaceColor: Colors.white,
  appBarColor: Colors.white,
  iconColor: const Color.fromARGB(255, 56, 73, 82),
  cardColor: Colors.white,
  dividerColor: Colors.grey.shade300,
  selectedColor: Colors.blue,
  unselectedColor: Colors.grey,
  borderRadius: 12.0,
  elevation: 2.0,
  fontFamily: 'Merriweather',
);

// Dark Theme
ThemeData darkTheme = _createTheme(
  primaryColor: Colors.blue,
  secondaryColor: Colors.blueAccent,
  backgroundColor: const Color.fromARGB(255, 32, 32, 32),
  textColor: Colors.white70,
  surfaceColor: const Color.fromARGB(255, 48, 48, 48),
  appBarColor: const Color.fromARGB(255, 26, 26, 26),
  iconColor: Colors.white70,
  cardColor: const Color.fromARGB(255, 48, 48, 48),
  dividerColor: Colors.grey.shade800,
  selectedColor: Colors.blue,
  unselectedColor: Colors.grey.shade600,
  borderRadius: 12.0,
  elevation: 4.0,
  fontFamily: 'Merriweather',
);

// Blue Theme
ThemeData blueTheme = _createTheme(
  primaryColor: const Color(0xFF1976D2),
  secondaryColor: const Color(0xFF42A5F5),
  backgroundColor: const Color(0xFFE3F2FD),
  textColor: const Color(0xFF0D47A1),
  surfaceColor: Colors.white,
  appBarColor: const Color(0xFFBBDEFB),
  iconColor: const Color(0xFF0D47A1),
  cardColor: Colors.white,
  dividerColor: const Color(0xFFBBDEFB),
  selectedColor: const Color(0xFF1976D2),
  unselectedColor: const Color(0xFF90CAF9),
  borderRadius: 16.0,
  elevation: 3.0,
  fontFamily: 'Roboto',
);

// Green Theme
ThemeData greenTheme = _createTheme(
  primaryColor: const Color(0xFF2E7D32),
  secondaryColor: const Color(0xFF66BB6A),
  backgroundColor: const Color(0xFFE8F5E9),
  textColor: const Color(0xFF1B5E20),
  surfaceColor: Colors.white,
  appBarColor: const Color(0xFFC8E6C9),
  iconColor: const Color(0xFF1B5E20),
  cardColor: Colors.white,
  dividerColor: const Color(0xFFC8E6C9),
  selectedColor: const Color(0xFF2E7D32),
  unselectedColor: const Color(0xFFA5D6A7),
  borderRadius: 20.0,
  elevation: 2.0,
  fontFamily: 'Lora',
);

// Purple Theme
ThemeData purpleTheme = _createTheme(
  primaryColor: const Color(0xFF7B1FA2),
  secondaryColor: const Color(0xFFBA68C8),
  backgroundColor: const Color(0xFFF3E5F5),
  textColor: const Color(0xFF4A148C),
  surfaceColor: Colors.white,
  appBarColor: const Color(0xFFE1BEE7),
  iconColor: const Color(0xFF4A148C),
  cardColor: Colors.white,
  dividerColor: const Color(0xFFE1BEE7),
  selectedColor: const Color(0xFF7B1FA2),
  unselectedColor: const Color(0xFFCE93D8),
  borderRadius: 24.0,
  elevation: 3.0,
  fontFamily: 'Playfair Display',
);

// Orange Theme
ThemeData orangeTheme = _createTheme(
  primaryColor: const Color(0xFFE65100),
  secondaryColor: const Color(0xFFFFA726),
  backgroundColor: const Color(0xFFFFF3E0),
  textColor: const Color(0xFFBF360C),
  surfaceColor: Colors.white,
  appBarColor: const Color(0xFFFFE0B2),
  iconColor: const Color(0xFFBF360C),
  cardColor: Colors.white,
  dividerColor: const Color(0xFFFFE0B2),
  selectedColor: const Color(0xFFE65100),
  unselectedColor: const Color(0xFFFFB74D),
  borderRadius: 28.0,
  elevation: 4.0,
  fontFamily: 'Source Serif Pro',
);

// Pink Theme
ThemeData pinkTheme = _createTheme(
  primaryColor: const Color(0xFFC2185B),
  secondaryColor: const Color(0xFFEC407A),
  backgroundColor: const Color(0xFFFCE4EC),
  textColor: const Color(0xFF880E4F),
  surfaceColor: Colors.white,
  appBarColor: const Color(0xFFF8BBD0),
  iconColor: const Color(0xFF880E4F),
  cardColor: Colors.white,
  dividerColor: const Color(0xFFF8BBD0),
  selectedColor: const Color(0xFFC2185B),
  unselectedColor: const Color(0xFFF48FB1),
  borderRadius: 32.0,
  elevation: 2.0,
  fontFamily: 'Crimson Text',
);

// Base theme configuration for reading
ThemeData _createReadingTheme({
  required Color backgroundColor,
  required Color textColor,
  required Color surfaceColor,
  required Color primaryColor,
  required Color accentColor,
  required double textScaleFactor,
  required String fontFamily,
  required double lineHeight,
  required double letterSpacing,
  required double paragraphSpacing,
  required bool isDark,
}) {
  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: surfaceColor,
    primaryColor: primaryColor,
    colorScheme: ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      background: backgroundColor,
      onBackground: textColor,
      surface: surfaceColor,
      onSurface: textColor,
    ),
    textTheme: TextTheme(
      headlineSmall: TextStyle(
        color: textColor,
        fontFamily: fontFamily,
        fontSize: 20 * textScaleFactor,
        height: lineHeight,
        letterSpacing: letterSpacing,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontFamily: fontFamily,
        fontSize: 20 * textScaleFactor,
        height: lineHeight,
        letterSpacing: letterSpacing,
      ),
      bodyMedium: TextStyle(
        color: textColor,
        fontFamily: fontFamily,
        fontSize: 16 * textScaleFactor,
        height: lineHeight,
        letterSpacing: letterSpacing,
      ),
      bodyLarge: TextStyle(
        color: textColor,
        fontFamily: fontFamily,
        fontSize: 18 * textScaleFactor,
        height: lineHeight,
        letterSpacing: letterSpacing,
      ),
      labelLarge: TextStyle(
        color: textColor,
        fontFamily: fontFamily,
        fontSize: 17 * textScaleFactor,
        height: lineHeight,
        letterSpacing: letterSpacing,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textColor,
        fontFamily: fontFamily,
        fontSize: 20 * textScaleFactor,
        height: lineHeight,
        letterSpacing: letterSpacing,
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: textColor.withOpacity(0.1),
      thickness: 1,
      space: paragraphSpacing,
    ),
  );
}

// Light Reading Theme - Optimized for daytime reading
ThemeData lightReadingTheme = _createReadingTheme(
  backgroundColor: const Color(0xFFF8F9FA),
  textColor: const Color(0xFF212529),
  surfaceColor: Colors.white,
  primaryColor: const Color(0xFF0D6EFD),
  accentColor: const Color(0xFF0DCAF0),
  textScaleFactor: 1.0,
  fontFamily: 'Merriweather',
  lineHeight: 1.6,
  letterSpacing: 0.5,
  paragraphSpacing: 24.0,
  isDark: false,
);

// Sepia Theme - Paper-like for extended reading
ThemeData sepiaTheme = _createReadingTheme(
  backgroundColor: const Color(0xFFFBF0D9),
  textColor: const Color(0xFF3E2723),
  surfaceColor: const Color(0xFFFFF8E1),
  primaryColor: const Color(0xFF8D6E63),
  accentColor: const Color(0xFFA1887F),
  textScaleFactor: 1.0,
  fontFamily: 'Lora',
  lineHeight: 1.7,
  letterSpacing: 0.3,
  paragraphSpacing: 28.0,
  isDark: false,
);

// Dark Reading Theme - Standard dark mode for night reading
ThemeData darkReadingTheme = _createReadingTheme(
  backgroundColor: const Color(0xFF1A1A1A),
  textColor: const Color(0xFFE0E0E0),
  surfaceColor: const Color(0xFF2D2D2D),
  primaryColor: const Color(0xFF90CAF9),
  accentColor: const Color(0xFF64B5F6),
  textScaleFactor: 1.0,
  fontFamily: 'Merriweather',
  lineHeight: 1.6,
  letterSpacing: 0.5,
  paragraphSpacing: 24.0,
  isDark: true,
);

// AMOLED Dark Theme - True black for OLED screens
ThemeData amoledDarkTheme = _createReadingTheme(
  backgroundColor: Colors.black,
  textColor: const Color(0xFFE0E0E0),
  surfaceColor: const Color(0xFF121212),
  primaryColor: const Color(0xFF90CAF9),
  accentColor: const Color(0xFF64B5F6),
  textScaleFactor: 1.0,
  fontFamily: 'Merriweather',
  lineHeight: 1.6,
  letterSpacing: 0.5,
  paragraphSpacing: 24.0,
  isDark: true,
);

// High Contrast Theme - For accessibility
ThemeData highContrastTheme = _createReadingTheme(
  backgroundColor: Colors.white,
  textColor: Colors.black,
  surfaceColor: Colors.white,
  primaryColor: Colors.black,
  accentColor: Colors.black,
  textScaleFactor: 1.2,
  fontFamily: 'Roboto',
  lineHeight: 1.8,
  letterSpacing: 0.8,
  paragraphSpacing: 32.0,
  isDark: false,
);

// Paper White Theme - Soft white with minimal blue light
ThemeData paperWhiteTheme = _createReadingTheme(
  backgroundColor: const Color(0xFFF5F5F5),
  textColor: const Color(0xFF2C3E50),
  surfaceColor: Colors.white,
  primaryColor: const Color(0xFF34495E),
  accentColor: const Color(0xFF7F8C8D),
  textScaleFactor: 1.0,
  fontFamily: 'Source Serif Pro',
  lineHeight: 1.7,
  letterSpacing: 0.4,
  paragraphSpacing: 26.0,
  isDark: false,
);

// Night Light Theme - Warm dark mode for night reading
ThemeData nightLightTheme = _createReadingTheme(
  backgroundColor: const Color(0xFF1E1E1E),
  textColor: const Color(0xFFFFF3E0),
  surfaceColor: const Color(0xFF2D2D2D),
  primaryColor: const Color(0xFFFFB74D),
  accentColor: const Color(0xFFFFA726),
  textScaleFactor: 1.0,
  fontFamily: 'Crimson Text',
  lineHeight: 1.6,
  letterSpacing: 0.5,
  paragraphSpacing: 24.0,
  isDark: true,
);
