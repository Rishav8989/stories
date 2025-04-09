import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class FontController extends GetxController {
  final RxString selectedFont = 'Merriweather'.obs;
  final RxBool isLoading = false.obs;
  final List<String> _availableFonts = [
    'Merriweather',       // Classic serif for comfortable reading
    'Dancing Script',     // Handwritten style
    'Pacifico',           // Casual handwritten
    'Caveat',            // Natural handwriting
    'Roboto Mono',       // Monospace for code/technical content
    'Source Code Pro',   // Professional monospace
    'Playfair Display',  // Elegant serif for headings
    'Cormorant',         // Stylish serif
    'Alegreya',          // Elegant serif with personality
    'Lora',              // Classic serif with modern touch
  ];
  late SharedPreferences _prefs;
  final String _fontKey = 'app_font';

  List<String> get availableFonts => _availableFonts;

  @override
  void onInit() {
    super.onInit();
    loadFontFromPreferences();
  }

  Future<void> loadFontFromPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final fontName = _prefs.getString(_fontKey);
    if (fontName != null) {
      selectedFont.value = fontName;
    }
  }

  Future<void> _saveFontToPreferences(String font) async {
    await _prefs.setString(_fontKey, font);
  }

  Future<void> setFont(String font) async {
    try {
      isLoading.value = true;
      selectedFont.value = font;
      await _saveFontToPreferences(font);
      await Future.delayed(const Duration(milliseconds: 300)); // Add small delay for smooth transition
      Get.forceAppUpdate();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> switchToMerriweather() async => await setFont('Merriweather');
  Future<void> switchToDancingScript() async => await setFont('Dancing Script');
  Future<void> switchToPacifico() async => await setFont('Pacifico');
  Future<void> switchToCaveat() async => await setFont('Caveat');
  Future<void> switchToRobotoMono() async => await setFont('Roboto Mono');
  Future<void> switchToSourceCodePro() async => await setFont('Source Code Pro');
  Future<void> switchToPlayfairDisplay() async => await setFont('Playfair Display');
  Future<void> switchToCormorant() async => await setFont('Cormorant');
  Future<void> switchToAlegreya() async => await setFont('Alegreya');
  Future<void> switchToLora() async => await setFont('Lora');

  TextStyle getTextStyle(TextStyle baseStyle) {
    return GoogleFonts.getFont(
      selectedFont.value,
      textStyle: baseStyle,
    );
  }
} 