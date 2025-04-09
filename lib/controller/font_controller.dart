import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontController extends GetxController {
  final RxString selectedFont = 'Roboto'.obs;
  final List<String> _availableFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Merriweather',
    'Noto Sans'
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
    selectedFont.value = font;
    await _saveFontToPreferences(font);
    Get.forceAppUpdate();
  }

  Future<void> switchToRoboto() async {
    await setFont('Roboto');
  }

  Future<void> switchToOpenSans() async {
    await setFont('Open Sans');
  }

  Future<void> switchToLato() async {
    await setFont('Lato');
  }

  Future<void> switchToMerriweather() async {
    await setFont('Merriweather');
  }

  Future<void> switchToNotoSans() async {
    await setFont('Noto Sans');
  }

  TextStyle getTextStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontFamily: selectedFont.value,
    );
  }
} 