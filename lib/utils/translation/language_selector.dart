import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/utils/translation/locale_controller.dart';
import 'package:stories/utils/translation/translation_service.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LocaleController localeController = Get.find<LocaleController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: TranslationService.supportedLocales
              .map((Locale locale) => RadioListTile<Locale>(
                    title: Text(_getLanguageName(locale)),
                    value: locale,
                    groupValue: localeController.currentLocale,
                    onChanged: (Locale? newValue) {
                      if (newValue != null) {
                        localeController.setLocale(newValue);
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// **Helper function to get proper language names**
  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'bn':
        return 'বাংলা (Bengali)';
      case 'te':
        return 'తెలుగు (Telugu)';
      case 'mr':
        return 'मराठी (Marathi)';
      case 'ta':
        return 'தமிழ் (Tamil)';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}