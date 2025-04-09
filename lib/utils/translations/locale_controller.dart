// lib/controllers/locale_controller.dart  <-- Note:  I've changed the path to be more conventional
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stories/utils/translations/translation_service.dart';

class LocaleController extends GetxController {
  // Correct: Access fallbackLocale statically using the class name.
  final _currentLocale = Rx<Locale>(TranslationService.fallbackLocale);
  late SharedPreferences _prefs;
  final String _localeKey = 'app_locale';

  @override
  void onInit() {
    super.onInit();
    _loadLocaleFromPreferences();
  }

  Locale get currentLocale => _currentLocale.value;

  Future<void> setLocale(Locale locale) async {
    _currentLocale.value = locale;
    Get.updateLocale(locale);
    await _saveLocaleToPreferences(locale);
  }

  void changeLocale(String languageCode, String countryCode) {
    final locale = Locale(languageCode, countryCode);
    setLocale(locale);
  }

  Future<void> _loadLocaleFromPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    String? localeString = _prefs.getString(_localeKey);
    if (localeString != null) {
      List<String> parts = localeString.split('_');
      if (parts.length == 2) {
        try {
          final savedLocale = Locale(parts[0], parts[1]);
          _currentLocale.value = savedLocale;
          Get.updateLocale(savedLocale); // Apply locale immediately
        } catch (e) {
          print('Error loading locale: $e');
          // Fallback to default if loading fails -  Corrected:  Static access
          _currentLocale.value = TranslationService.fallbackLocale;
          Get.updateLocale(TranslationService.fallbackLocale);
        }
      }
    }
    // If no locale is saved, it will default to the initial value (fallbackLocale)
  }

  Future<void> _saveLocaleToPreferences(Locale locale) async {
    await _prefs.setString(_localeKey, '${locale.languageCode}_${locale.countryCode}');
  }
}